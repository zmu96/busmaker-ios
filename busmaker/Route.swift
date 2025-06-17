//
//  Route.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import Foundation
import CoreLocation

// MARK: - 단일 정류장 정보
/// 정류소 고유 ID, 이름, 순번, 상하행 구분, 좌표까지 포함
struct Stop {
    let id: String                   // 정류소 고유 ID (nodeid)
    let name: String                 // 정류소명 (nodenm)
    let order: Int                   // 정류소 순번 (nodeord)
    let direction: String?           // 상하행 구분코드 ("0"=상행, "1"=하행)
    let coordinate: CLLocationCoordinate2D  // 위도/경도 좌표
}

// MARK: - 하나의 경로 후보 모델
/// 버스 번호, 출발/도착 정류장, 경유 정류장 리스트, 좌표, 구간 정류장 수 포함
struct Route {
    let busNumber: String                    // 버스 번호 (routeno)
    let startStation: String                 // 출발 정류장명
    let endStation: String                   // 도착 정류장명
    let stopCount: Int                       // 출발→도착까지 경유 정류장 수

    let departureCoord: CLLocationCoordinate2D  // 출발지 좌표
    let arrivalCoord:   CLLocationCoordinate2D  // 도착지 좌표

    let viaStops: [Stop]                     // 구간 내 경유 정류장 리스트
}

