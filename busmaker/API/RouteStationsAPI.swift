//
//  RouteStationsAPI.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import Foundation
import CoreLocation

// MARK: - 모델 정의
// 노선별 경유 정류소 목록 조회

struct RouteStationsResponse: Codable {
    let response: RouteStationsWrapper
}

struct RouteStationsWrapper: Codable {
    let header: ResponseHeader
    let body:   RouteStationsBody
}

struct RouteStationsBody: Codable {
    let items:   RouteStationsItems
    let numOfRows: Int
    let pageNo:    Int
    let totalCount:Int
}

struct RouteStationsItems: Codable {
    let item: [RouteStation]
}

/// 개별 정류소 정보
struct RouteStation: Codable {
    let routeid: String   // 노선ID
    let nodeid:  String   // 정류소ID
    let nodenm:  String   // 정류소명
    let nodeno:  String?  // 정류소번호 (옵션)
    let nodeord: Int      // 정류소순번
    let gpslati: String   // 위도
    let gpslong: String   // 경도
    let updowncd:String?  // 상하행구분코드 (옵션)
}

// MARK: - API 클라이언트

enum RouteStationsAPI {
    private static let serviceKey = "VIyokumz54z0pgrPhQPYtDCSTJjSgC9K0yTZPT8O3T7IAvHghfXxcof7hZT7RYiG77D83lUKqeciZMuaXYfKRg=="
    private static let baseURL    = "https://apis.data.go.kr/1613000/"

    /// 노선별 경유 정류소 목록 조회
    /// - Parameters:
    ///   - cityCode: 도시코드
    ///   - routeId: 노선ID
    ///   - numOfRows: 한 페이지 결과 수
    ///   - pageNo: 페이지 번호
    static func fetchStations(
        cityCode: String,
        routeId: String,
        numOfRows: Int = 100,
        pageNo: Int    = 1,
        completion: @escaping ([RouteStation]?) -> Void
    ) {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: "cityCode",    value: cityCode),
            .init(name: "routeId",     value: routeId),
            .init(name: "numOfRows",   value: "\(numOfRows)"),
            .init(name: "pageNo",      value: "\(pageNo)"),
            .init(name: "_type",       value: "json")
        ]
        guard let url = components.url else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let wrapper = try? JSONDecoder().decode(RouteStationsResponse.self, from: data)
            else {
                completion(nil)
                return
            }
            completion(wrapper.response.body.items.item)
        }.resume()
    }
}
