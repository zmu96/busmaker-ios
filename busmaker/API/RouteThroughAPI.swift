//
//  RouteThroughAPI.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

// File: RouteThroughAPI.swift

import Foundation

// MARK: - 모델 정의

/// 정류소별 경유 노선 목록 조회 응답 전체 구조
struct StationRoutesResponse: Codable {
    let response: StationRoutesWrapper
}

struct StationRoutesWrapper: Codable {
    let header: ResponseHeader
    let body:   StationRoutesBody
}

struct StationRoutesBody: Codable {
    let items:      StationRoutesItems
    let numOfRows:  Int
    let pageNo:     Int
    let totalCount: Int
}

struct StationRoutesItems: Codable {
    let item: [StationRoute]
}

/// 개별 노선 정보
struct StationRoute: Codable {
    let routeid:    String   // 노선ID
    let routeno:    String   // 노선번호
    let routetp:    String   // 노선유형
    let endnodenm:  String   // 종점명
    let startnodenm:String   // 기점명
}

// MARK: - API 클라이언트

enum RouteThroughAPI {
    private static let serviceKey = "VIyokumz54z0pgrPhQPYtDCSTJjSgC9K0yTZPT8O3T7IAvHghfXxcof7hZT7RYiG77D83lUKqeciZMuaXYfKRg=="
    private static let baseURL    = "https://apis.data.go.kr/1613000/"
    
    /// 정류소별 경유 노선 목록 조회
    /// - Parameters:
    ///   - cityCode: 도시코드
    ///   - nodeId: 정류소ID
    ///   - numOfRows: 한 페이지 결과 수 (기본 100)
    ///   - pageNo: 페이지 번호 (기본 1)
    ///   - completion: StationRoute 배열 또는 nil 호출
    static func fetchRoutes(
        cityCode: String,
        nodeId:   String,
        numOfRows: Int = 100,
        pageNo:    Int = 1,
        completion: @escaping ([StationRoute]?) -> Void
    ) {
        // URL 구성 (_type=json 으로 JSON 응답)
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: "cityCode",   value: cityCode),
            .init(name: "nodeid",     value: nodeId),
            .init(name: "numOfRows",  value: "\(numOfRows)"),
            .init(name: "pageNo",     value: "\(pageNo)"),
            .init(name: "_type",      value: "json")
        ]
        guard let url = components.url else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let wrapper = try? JSONDecoder().decode(StationRoutesResponse.self, from: data)
            else {
                completion(nil)
                return
            }
            completion(wrapper.response.body.items.item)
        }
        .resume()
    }
}

