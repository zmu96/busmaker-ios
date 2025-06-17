//
//  TravelTimeCalculator.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import Foundation
import CoreLocation

/// 총 소요 시간을 계산하는 유틸리티
/// 도보 구간(출발→첫 정류장, 마지막 정류장→도착지)과 버스 구간을 합산합니다.
struct TravelTimeCalculator {
    // MARK: - 설정 값
    /// 평균 도보 속도 (미터/분)
    private static let walkingSpeedMetersPerMinute: Double = 70.0
    /// 평균 버스 주행 속도 (미터/분), 예: 20km/h = (20 * 1000) / 60 ≈ 333.33 m/분
    private static let busSpeedMetersPerMinute: Double = 333.33
    /// 평균 정류장 정차 시간 (초)
    private static let dwellTimeSecondsPerStop: Double = 20.0

    // MARK: - Haversine 거리 계산
    /// 두 좌표 사이의 거리(미터)를 Haversine 공식으로 계산
    static func distanceBetween(_ a: CLLocationCoordinate2D,
                                _ b: CLLocationCoordinate2D) -> Double {
        let lat1 = a.latitude * .pi / 180
        let lon1 = a.longitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let lon2 = b.longitude * .pi / 180
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        let earthRadius = 6371000.0 // 미터
        let h = sin(dLat/2) * sin(dLat/2)
              + cos(lat1) * cos(lat2)
              * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(h), sqrt(1-h))
        return earthRadius * c
    }

    // MARK: - 도보 시간 계산
    /// 주어진 거리(미터)를 평균 도보 속도로 이동하는 데 걸리는 시간(분)을 올림하여 반환
    static func walkingTimeMinutes(for distance: Double) -> Int {
        guard distance > 0 else { return 0 }
        let minutes = distance / walkingSpeedMetersPerMinute
        return Int(ceil(minutes))
    }

    // MARK: - 버스 이동 시간 계산
    /// 경유 정류장 리스트를 받아, 주행 거리와 정차 시간을 합산하여 소요 시간(분)을 계산
    static func busTimeMinutes(for viaStops: [Stop]) -> Int {
        guard viaStops.count >= 2 else { return 0 }
        var totalMeters: Double = 0
        // 인접 정류장 거리 합산
        for i in 0..<(viaStops.count - 1) {
            let coordA = viaStops[i].coordinate
            let coordB = viaStops[i+1].coordinate
            totalMeters += distanceBetween(coordA, coordB)
        }
        // 주행 시간(분)
        let driveTime = totalMeters / busSpeedMetersPerMinute
        // 정차 시간(초) (정류장 수 - 1 만큼 정차)
        let stopsCount = viaStops.count - 1
        let dwellTimeMinutes = (dwellTimeSecondsPerStop * Double(stopsCount)) / 60.0
        // 합산 후 올림
        return Int(ceil(driveTime + dwellTimeMinutes))
    }

    // MARK: - 총 소요 시간 계산
    /// Route 모델을 받아, 도보+버스+도보 구간의 총 시간을 분 단위로 반환
    static func totalTravelTimeMinutes(for route: Route) -> Int {
        // 도보: 출발지→첫 정류장
        let firstStop = route.viaStops.first!
        let walk1Dist = distanceBetween(route.departureCoord, firstStop.coordinate)
        let walk1Min = walkingTimeMinutes(for: walk1Dist)
        // 버스: 첫 정류장→마지막 정류장
        let busMin = busTimeMinutes(for: route.viaStops)
        // 도보: 마지막 정류장→도착지
        let lastStop = route.viaStops.last!
        let walk2Dist = distanceBetween(lastStop.coordinate, route.arrivalCoord)
        let walk2Min = walkingTimeMinutes(for: walk2Dist)
        
        return walk1Min + busMin + walk2Min
    }
}

