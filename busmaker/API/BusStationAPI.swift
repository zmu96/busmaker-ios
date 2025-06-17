//
//  BusStationAPI.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//
import Foundation
import CoreLocation

// MARK: - 모델 정의

struct ProximateStationsResponse: Codable {
    let response: ProximateResponse
}

struct ProximateResponse: Codable {
    let header: ResponseHeader
    let body:   ProximateBody
}

struct ResponseHeader: Codable {
    let resultCode: String
    let resultMsg:  String
}

struct ProximateBody: Codable {
    let items: ProximateItems
    let numOfRows: Int
    let pageNo:    Int
    let totalCount:Int
}

struct ProximateItems: Codable {
    let item: [ProximateStation]
}

struct ProximateStation: Codable {
    let gpslati: String   // 위도
    let gpslong:String   // 경도
    let nodeid: String   // 정류소ID
    let nodenm: String   // 정류소명
    let citycode: String // 도시코드
}

// MARK: - API 클라이언트

enum BusStationAPI {
    private static let serviceKey = "VIyokumz54z0pgrPhQPYtDCSTJjSgC9K0yTZPT8O3T7IAvHghfXxcof7hZT7RYiG77D83lUKqeciZMuaXYfKRg=="
    private static let baseURL    = "https://apis.data.go.kr/1613000"
    
    /// 좌표 기반 근접 정류소 조회
    /// - Parameters:
    ///   - coord: 기준 위/경도
    ///   - radius: 반경(m) – API에는 없지만, 표시용으로 사용할 수 있음
    ///   - maxCount: 최대 개수 (JSON 파싱 후 slice)
    static func fetchNearbyStations(
        coord: CLLocationCoordinate2D,
        numOfRows: Int = 10,
        pageNo: Int    = 1,
        completion: @escaping ([ProximateStation]?) -> Void
    ) {
        // URL 구성 (_type=json 추가하여 JSON 응답 처리)
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: "gpsLati",     value: "\(coord.latitude)"),
            .init(name: "gpsLong",     value: "\(coord.longitude)"),
            .init(name: "numOfRows",   value: "\(numOfRows)"),
            .init(name: "pageNo",      value: "\(pageNo)"),
            .init(name: "_type",       value: "json")
        ]
        guard let url = components.url else {
            completion(nil)
            return
        }
        
        // 요청
        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard let data = data,
                  let wrapper = try? JSONDecoder().decode(ProximateStationsResponse.self, from: data)
            else {
                completion(nil)
                return
            }
            // 최대 3개만 반환
            let stations = Array(wrapper.response.body.items.item.prefix(3))
            completion(stations)
        }
        .resume()
    }
}
