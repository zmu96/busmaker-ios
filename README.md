# busmaker-ios
iOS 버스·도보 경로 탐색 앱 (네이버 검색 API, TAGO API 연동)

– Swift/MapKit 기반

---

## 📱 프로젝트 소개

**Busmaker**는 출발지와 도착지 입력만으로  
실제 지도(MapKit)에 경로를 표시해주는 iOS 버스 경로 탐색 앱입니다.  
지도와 리스트 UI를 모두 지원하며,  
실시간 내 위치(GPS) 기반 이동도 제공합니다.

---

## 🚩 주요 기능

- **출발지/도착지 장소 검색**
  - 장소명을 입력하면 네이버/카카오 등 장소 검색 API로 위경도 자동 변환
- **지도에 출발/도착 마커 표시**
  - MapKit에 출발지·도착지 위치를 마커로 표시
  - 두 위치를 선으로 연결(경로 시각화)
- **버스 정류장 자동 매핑**
  - 입력한 장소 근처(약 3~400m)의 실제 버스 정류장을 자동 검색/매핑
- **버스 경로 탐색**
  - 정류장 간 직통/환승 포함 노선을 검색, 각 경로의 버스 번호/정류장/요금/환승 정보 등을 리스트로 출력
- **경로 리스트 화면**
  - 여러 경로를 카드 형태로 리스트업, 각 카드에 소요시간/요금/환승정보/버스번호 등 표시 (최소 소요 시간 정렬)
- **지도-리스트 분리**
  - 지도(Map), 경로 리스트(RouteList) 화면 분리로 직관적인 UI 제공
- **실시간 내 위치 표시**
  - 내 위치(GPS)를 지도에 실시간 파란 점(마커)으로 표시, 사용자가 이동하면 자동 갱신

---

## 🗂️ 주요 화면 흐름

1. **메인(검색) 화면**  
   - 출발지/도착지 입력
   - 즐겨찾기, 최근 검색어 저장 기능  
2. **경로 리스트 화면**  
   - 추천 경로 카드 리스트로 표시 
   - 경로 카드 클릭 시 지도 이동
3. **지도(RouteMap) 화면**  
   - 선택 경로의 출발/도착 마커, 선 표시  
   - 내 위치 파란 점 실시간 표시

---

## 🛠️ 개발 환경

- **Swift (iOS)**
- **Xcode**
- **MapKit**
- **CoreLocation** (GPS)
- **MacInCloud** (클라우드에서 원격 Mac 환경을 임대 후 window 환경에서 개발)
- (장소 검색/버스 API: 네이버/TAGO)

---
## 경로 탐색 및 지도 표시 전체 과정
1. 출발지/도착지 입력
사용자는 앱 첫 화면에서 출발지와 도착지 장소명을 입력
네이버 검색 API(Naver Search API)를 사용해
 입력한 장소명을 실제 지도상의 위도/경도(좌표)로 변환

2. 주변 정류장 자동 매칭
변환된 출발지/도착지 좌표를 바탕으로
국토교통부 TAGO 버스정류소 정보 API로
 인근(반경 3~400m 등) 버스정류장 목록을 조회
출발/도착 각각 “최대 3개”의 후보 정류장 자동 추출

3. 정류소와 노선 정보 탐색
출발/도착지 정류장 조합별로
TAGO 노선정보 API를 이용
출발 정류장을 경유하는 노선/버스 목록 조회
각 노선별 전체 정류장 리스트 조회
도착지 정류장도 해당 노선에 포함되어 있는지 검사
직통, 환승 구간, 경유 정류장 등 조건에 따라 경로 후보 생성

4. 경로별 상세 이동 시간/구간 계산
각 경로에 대해:
버스 직통 경로: 출발지 ↔ 출발 정류장, 출발 정류장 ↔ 하차 정류장, 하차 정류장 ↔ 도착지
 (위/경도 좌표 이용 직접 거리 계산 + “도보 소요 시간” 추정 계산)
환승 포함 시: 중간 환승 정류장, 연결 가능한 노선까지 추가 탐색

5. 최적 경로 정렬 및 리스트 생성
“최소 소요 시간” 기준으로 경로들을 정렬 (기본 설정)
API 응답을 토대로 UI에 맞게 카드 형태의 경로 리스트 생성
구간별 요약, 버스/도보 구간 시각화, 상세 설명 추가

6. 지도 시각화
MapKit을 사용해
출발지/도착지/승차/하차/경유 정류장 등에 마커 표시
전체 경로(도보, 버스 등)는 폴리라인(선)으로 연결

7. 최종 결과 화면 표시
사용자가 경로를 선택하면
 선택된 경로에 따라 지도 화면에서
 사용자 실시간 위치 및 주요 지점 강조 표시


---

## ⚙️ 실행 방법

1. `git clone` 후 Xcode로 열기
2. Info.plist에서 위치 권한 설명(`NSLocationWhenInUseUsageDescription`) 추가
3. 실제 API키 필요, 사용 시 프로젝트 내 개인키 설정 / 1. https://www.data.go.kr/data/15098533/openapi.do (TAGO 버스 api), 2. https://developers.naver.com/products/service-api/search/search.md (네이버 search API)
4. 시뮬레이터/실기기에서 실행

---

## 📝 향후 개발 계획
  25.06.18
  macincloud 서버 오류로 readme에 해당 작업 내용 작성, 문제 해결 후 read.me에 있는 내용 기반으로 앱에 추가 예정
  
- 즐겨찾기 경로 저장/불러오기(readme에 작성 완료)
- 최근 검색어 기능
  
  ---
  
- 다양한 경로 필터(최소 환승 등)
- 정류장 상세 정보/버스 실시간 위치 연동 (api 추가 연결 필요)

---

## 📧 작성자

- 작성자: 한준서  
- 이메일/joonseo1.han@gmail.com

```

## 📝
macincloud 서버 오류로 read.me에 추가 작업 내용 작성 - **파일 추가 후 버튼 추가 및 아웃렛 연결 필요**

<즐겨찾기 데이터 구조 설계> - UserDefaults 사용
총 5개 파일 추가/수정
FavoriteRoute.swift
 → 즐겨찾기 데이터 모델(10자 제한)

FavoriteRouteManager.swift
 → 저장/불러오기/중복/최대 개수 정책

RouteListViewController.swift
 → ★ 버튼 누르면 즐겨찾기 추가

SearchViewController.swift
 → 해당 화면에 즐겨찾기 버튼 추가, 버튼 클릭 시 곧바로 지도 화면 이동

RouteMapViewController.swift
 → 전달받은 경로 정보를 마커/경로선으로 지도에 표시
ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 -파일 추가/수정 외 해야하는 작업-
 
 각 ViewController 간 데이터 전달
(예: 즐겨찾기 버튼 클릭 → RouteMapViewController에 정보 넘기기)

스토리보드(Storyboard)에서 UI 연결
(예: TableView, IBOutlet/IBAction 등)

버튼 디자인
ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// FavoriteRoute.swift  **신규 파일 생성**
import Foundation
import CoreLocation

struct FavoriteRoute: Codable, Equatable {
    let startName: String
    let startLatitude: Double
    let startLongitude: Double
    let endName: String
    let endLatitude: Double
    let endLongitude: Double
    
    // 10자 제한된 이름 반환 (즐겨찾기 버튼에 들어갈 문구, 10자 제한)
    var startNameShort: String {
        return startName.count > 10 ? String(startName.prefix(10)) + "…" : startName
    }
    var endNameShort: String {
        return endName.count > 10 ? String(endName.prefix(10)) + "…" : endName
    }
}
ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// FavoriteRouteManager.swift **신규 파일 생성**
import Foundation

class FavoriteRouteManager {
    static let shared = FavoriteRouteManager()
    private let key = "favoriteRoutes"
    private let maxCount = 5
    
    private init() {}
    
    func loadFavorites() -> [FavoriteRoute] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let routes = try? JSONDecoder().decode([FavoriteRoute].self, from: data) else {
            return []
        }
        return routes
    }
    
    func saveFavorites(_ routes: [FavoriteRoute]) {
        if let data = try? JSONEncoder().encode(routes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // 즐겨찾기 추가 (중복/최대개수 처리)
    func addFavorite(_ route: FavoriteRoute) -> Result<Void, FavoriteError> {
        var routes = loadFavorites()
        // 중복 검사
        if routes.contains(route) {
            return .failure(.duplicate)
        }
        // 최대 개수 초과
        if routes.count >= maxCount {
            return .failure(.overLimit)
        }
        routes.append(route)
        saveFavorites(routes)
        return .success(())
    }
    
    enum FavoriteError: Error {
        case duplicate
        case overLimit
    }
}

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// RouteListViewController.swift **내용 추가**
import UIKit

class RouteListViewController: UIViewController {
    // ... 기존 코드 생략

    // ★ 버튼 클릭 시
    func addToFavorites(route: Route) {
        let favorite = FavoriteRoute(
            startName: route.startName,
            startLatitude: route.startLat,
            startLongitude: route.startLng,
            endName: route.endName,
            endLatitude: route.endLat,
            endLongitude: route.endLng
        )
        let result = FavoriteRouteManager.shared.addFavorite(favorite)
        switch result {
        case .success():
            // 안내 메시지 or UI 갱신
            print("즐겨찾기에 추가되었습니다.")
        case .failure(let error):
            switch error {
            case .duplicate:
                print("이미 등록된 즐겨찾기입니다.")
            case .overLimit:
                print("즐겨찾기는 최대 5개까지 등록할 수 있습니다.")
            }
        }
    }
}

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// SearchViewController.swift  **내용 추가**
import UIKit

class SearchViewController: UIViewController {
    // ... 기존 코드

    @IBOutlet weak var favoritesStackView: UIStackView! // (Interface Builder로 추가)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtons()
    }

    func updateFavoriteButtons() {
        let favorites = FavoriteRouteManager.shared.loadFavorites()
        favoritesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for route in favorites {
            let button = UIButton(type: .system)
            button.setTitle("\(route.startNameShort) → \(route.endNameShort)", for: .normal)
            button.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
            button.tag = favorites.firstIndex(of: route) ?? 0
            favoritesStackView.addArrangedSubview(button)
        }
    }

    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let favorites = FavoriteRouteManager.shared.loadFavorites()
        let route = favorites[sender.tag]
        // RouteMapViewController로 이동, route 정보 전달
        showRouteOnMap(favoriteRoute: route)
    }

    func showRouteOnMap(favoriteRoute: FavoriteRoute) {
        // RouteMapViewController에 route 정보 넘기는 코드 구현
    }
}

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// RouteMapViewController.swift   **내용 추가**
import UIKit
import MapKit

class RouteMapViewController: UIViewController {
    var favoriteRoute: FavoriteRoute?

    // ... 기존 지도 코드

    override func viewDidLoad() {
        super.viewDidLoad()
        if let route = favoriteRoute {
            // 마커, 경로선 표시 코드 구현
            let start = CLLocationCoordinate2D(latitude: route.startLatitude, longitude: route.startLongitude)
            let end = CLLocationCoordinate2D(latitude: route.endLatitude, longitude: route.endLongitude)
            // 마커 추가, 폴리라인 추가 등
        }
    }
}



















