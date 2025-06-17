//
//  RouteCalculator.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

// File: RouteCalculator.swift

import Foundation
import CoreLocation

/// 경로 계산 매니저 (직통 + 1회 환승)
final class RouteCalculator {
    // MARK: - 1) 직통 경로 계산
    static func calculateDirectRoutes(
        departure: CLLocationCoordinate2D,
        arrival:   CLLocationCoordinate2D,
        completion: @escaping ([Route]?) -> Void
    ) {
        // 1) 출발지 근접 정류소 조회
        BusStationAPI.fetchNearbyStations(coord: departure) { departStations in
            guard let departStations = departStations, !departStations.isEmpty else {
                completion(nil); return
            }
            // 2) 도착지 근접 정류소 조회
            BusStationAPI.fetchNearbyStations(coord: arrival) { arrivalStations in
                guard let arrivalStations = arrivalStations, !arrivalStations.isEmpty else {
                    completion(nil); return
                }
                var routes: [Route] = []
                let group = DispatchGroup()

                // 3) 출발-도착 정류소 조합별 처리
                for ds in departStations {
                    for asr in arrivalStations {
                        group.enter()
                        // 4) 출발 정류장 경유 노선 조회
                        RouteThroughAPI.fetchRoutes(cityCode: ds.citycode, nodeId: ds.nodeid) { stationRoutes in
                            guard let stationRoutes = stationRoutes else {
                                group.leave(); return
                            }
                            let subGroup = DispatchGroup()

                            for routeInfo in stationRoutes {
                                subGroup.enter()
                                RouteStationsAPI.fetchStations(
                                    cityCode: ds.citycode,
                                    routeId:  routeInfo.routeid
                                ) { routeStations in
                                    defer { subGroup.leave() }
                                    guard let routeStations = routeStations, !routeStations.isEmpty else { return }

                                    // 방향 필터 + 순번 정렬
                                    let direction = routeStations.first?.updowncd
                                    let filteredStations = routeStations
                                        .filter { $0.updowncd == direction }
                                        .sorted  { $0.nodeord < $1.nodeord }

                                    // 출발↔도착 구간 슬라이스
                                    guard let startOrder = filteredStations.first(where: { $0.nodeid == ds.nodeid })?.nodeord,
                                          let endOrder   = filteredStations.first(where: { $0.nodeid == asr.nodeid })?.nodeord
                                    else {
                                        return
                                    }
                                    let segment: [RouteStation]
                                    if startOrder <= endOrder {
                                        segment = filteredStations.filter { (startOrder...endOrder).contains($0.nodeord) }
                                    } else {
                                        let orders   = filteredStations.map { $0.nodeord }
                                        let minOrder = orders.min()!, maxOrder = orders.max()!
                                        let firstSeg = filteredStations.filter { $0.nodeord >= startOrder && $0.nodeord <= maxOrder }
                                        let secondSeg = filteredStations.filter { $0.nodeord >= minOrder   && $0.nodeord <= endOrder }
                                        segment = firstSeg + secondSeg
                                    }

                                    // Stop 모델 변환
                                    let viaStops: [Stop] = segment.map { st in
                                        Stop(
                                            id:         st.nodeid,
                                            name:       st.nodenm,
                                            order:      st.nodeord,
                                            direction:  st.updowncd,
                                            coordinate: CLLocationCoordinate2D(
                                                latitude:  Double(st.gpslati) ?? 0,
                                                longitude: Double(st.gpslong) ?? 0
                                            )
                                        )
                                    }
                                    // Route 생성
                                    let stopCount = max(0, viaStops.count - 1)
                                    let route = Route(
                                        busNumber:      routeInfo.routeno,
                                        startStation:   ds.nodenm,
                                        endStation:     asr.nodenm,
                                        stopCount:      stopCount,
                                        departureCoord: departure,
                                        arrivalCoord:   arrival,
                                        viaStops:       viaStops
                                    )
                                    routes.append(route)
                                }
                            }
                            subGroup.notify(queue: .main) { group.leave() }
                        }
                    }
                }
                // 5) 정렬 후 반환
                group.notify(queue: .main) {
                    completion(routes.sorted { $0.stopCount < $1.stopCount })
                }
            }
        }
    }

    // MARK: - 2) 최대 1회 환승 경로 계산
    static func calculateRoutesWithTransfer(
        departure: CLLocationCoordinate2D,
        arrival:   CLLocationCoordinate2D,
        completion: @escaping ([Route]?) -> Void
    ) {
        // 직통 경로 먼저 계산
        calculateDirectRoutes(departure: departure, arrival: arrival) { directRoutes in
            let direct = directRoutes ?? []

            BusStationAPI.fetchNearbyStations(coord: departure) { departStations in
                guard let departStations = departStations else {
                    completion(direct); return
                }
                BusStationAPI.fetchNearbyStations(coord: arrival) { arrivalStations in
                    guard let arrivalStations = arrivalStations else {
                        completion(direct); return
                    }

                    var transferRoutes: [Route] = []
                    let group = DispatchGroup()

                    for ds in departStations {
                        for asr in arrivalStations {
                            group.enter()
                            // 첫 버스 구간 노선 조회
                            RouteThroughAPI.fetchRoutes(cityCode: ds.citycode, nodeId: ds.nodeid) { firstLinks in
                                guard let firstLinks = firstLinks else { group.leave(); return }
                                let subGroup = DispatchGroup()

                                for link in firstLinks {
                                    subGroup.enter()
                                    RouteStationsAPI.fetchStations(cityCode: ds.citycode, routeId: link.routeid) { stations in
                                        defer { subGroup.leave() }
                                        guard let stations = stations, !stations.isEmpty else { return }

                                        // 1차 구간 viaStops
                                        let viaStops1 = filterAndSlice(
                                            stations: stations,
                                            startId:   ds.nodeid,
                                            endId:     nil
                                        )
                                        let candidates = viaStops1.dropLast()

                                        for transferStop in candidates {
                                            subGroup.enter()
                                            // 2차 버스 구간 노선 조회
                                            RouteThroughAPI.fetchRoutes(cityCode: ds.citycode, nodeId: transferStop.id) { secondLinks in
                                                defer { subGroup.leave() }
                                                guard let secondLinks = secondLinks else { return }

                                                for second in secondLinks {
                                                    subGroup.enter()
                                                    RouteStationsAPI.fetchStations(cityCode: ds.citycode, routeId: second.routeid) { secondStations in
                                                        defer { subGroup.leave() }
                                                        guard let secondStations = secondStations, !secondStations.isEmpty else { return }

                                                        let viaStops2 = filterAndSlice(
                                                            stations: secondStations,
                                                            startId:  transferStop.id,
                                                            endId:    asr.nodeid
                                                        )
                                                        let combined = viaStops1 + viaStops2.dropFirst()
                                                        let stopCount = max(0, combined.count - 1)
                                                        let route = Route(
                                                            busNumber:      "\(link.routeno) → \(second.routeno)",
                                                            startStation:   ds.nodenm,
                                                            endStation:     asr.nodenm,
                                                            stopCount:      stopCount,
                                                            departureCoord: departure,
                                                            arrivalCoord:   arrival,
                                                            viaStops:       combined
                                                        )
                                                        transferRoutes.append(route)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                subGroup.notify(queue: .main) { group.leave() }
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        let all = direct + transferRoutes
                        completion(all.sorted { $0.stopCount < $1.stopCount })
                    }
                }
            }
        }
    }
}

// MARK: - 공통 슬라이스 로직 (nodeord, updowncd 처리)
private func filterAndSlice(
    stations: [RouteStation],
    startId:  String,
    endId:    String?
) -> [Stop] {
    let direction = stations.first?.updowncd
    let filtered = stations
        .filter { $0.updowncd == direction }
        .sorted { $0.nodeord < $1.nodeord }

    guard let startOrder = filtered.first(where: { $0.nodeid == startId })?.nodeord else {
        return []
    }
    let segmentStations: [RouteStation]
    if let endId = endId,
       let endOrder = filtered.first(where: { $0.nodeid == endId })?.nodeord {
        if startOrder <= endOrder {
            segmentStations = filtered.filter { startOrder...endOrder ~= $0.nodeord }
        } else {
            let orders = filtered.map { $0.nodeord }
            let minO = orders.min()!, maxO = orders.max()!
            let firstSeg = filtered.filter { $0.nodeord >= startOrder && $0.nodeord <= maxO }
            let second = filtered.filter { $0.nodeord >= minO       && $0.nodeord <= endOrder }
            segmentStations = firstSeg + second
        }
    } else {
        segmentStations = filtered.filter { $0.nodeord >= startOrder }
    }

    return segmentStations.map {
        Stop(
            id:         $0.nodeid,
            name:       $0.nodenm,
            order:      $0.nodeord,
            direction:  $0.updowncd,
            coordinate: CLLocationCoordinate2D(
                latitude:  Double($0.gpslati) ?? 0,
                longitude: Double($0.gpslong) ?? 0
            )
        )
    }
}


