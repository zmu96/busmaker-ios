//
//  NaverSearchApi.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import Foundation
import CoreLocation

// JSON 파싱용 모델
struct PlaceSearchResponse: Codable {
    let items: [PlaceItem]
}
struct PlaceItem: Codable {
    let title: String       // 장소명
    let mapx: String        // 경도(x)
    let mapy: String        // 위도(y)
}

enum NaverSearchAPI {
    static let clientId     = "yTz4od8ygkXfSJGYwiZN"
    static let clientSecret = "YAjT5uvHdn"

    /// 키워드로 장소 1건만 조회하여 좌표 콜백
    static func searchPlace(_ keyword: String,
                            completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url   = URL(string:
                "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=1")
        else {
            completion(nil); return
        }

        var request = URLRequest(url: url)
        request.addValue(clientId,     forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let resp = try? JSONDecoder().decode(PlaceSearchResponse.self, from: data),
                  let first = resp.items.first,
                  let x = Double(first.mapx),
                  let y = Double(first.mapy)
            else {
                completion(nil); return
            }
            // mapy=위도, mapx=경도
            completion(CLLocationCoordinate2D(latitude: y,
                                              longitude: x))
        }
        .resume()
    }
}
