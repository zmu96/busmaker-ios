//
//  RouteListViewController.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import UIKit
import CoreLocation

// MARK: - Route List Screen
class RouteListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    // 화면 전환 시 전달받은 좌표
    var departureCoord: CLLocationCoordinate2D?
    var arrivalCoord:   CLLocationCoordinate2D?

    // 계산된 경로 후보 배열
    private var routes: [Route] = []

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        // 좌표가 준비되면 경로 계산 시작
        guard let depart = departureCoord, let arrive = arrivalCoord else { return }
        RouteCalculator.calculateRoutesWithTransfer(departure: depart, arrival: arrive) { [weak self] (result: [Route]?) in
            guard let self = self, let result = result else { return }
            self.routes = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - 화면 전환 준비
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap",
           let mapVC = segue.destination as? RouteMapViewController,
           let route = sender as? Route {
            mapVC.selectedRoute = route
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension RouteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let route = routes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteListCell", for: indexPath) as! RouteListCell
        cell.configure(with: route, index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = routes[indexPath.row]
        performSegue(withIdentifier: "showMap", sender: route)
    }
}

// MARK: - Custom Cell
class RouteListCell: UITableViewCell {
    @IBOutlet weak var routeTitleLabel: UILabel!     // "경로 1" 등
    @IBOutlet weak var totalTimeLabel: UILabel!      // "28분"
    @IBOutlet weak var costLabel: UILabel!           // "요금 1450원" (옵션)

    // 세그먼트 막대 뷰
    @IBOutlet weak var walk1BarView: UIView!
    @IBOutlet weak var busBarView: UIView!
    @IBOutlet weak var walk2BarView: UIView!

    // 각 구간 시간 레이블
    @IBOutlet weak var walking1Label: UILabel!  // "도보 1분"
    @IBOutlet weak var busLabel: UILabel!       // "버스 26분"
    @IBOutlet weak var walking2Label: UILabel!  // "도보 1분"

    // 상세 텍스트
    @IBOutlet weak var departureToBoardLabel: UILabel!   // "출발지 → 승차 정류장 도보"
    @IBOutlet weak var busInfoLabel: UILabel!            // "65 | 13정류장"
    @IBOutlet weak var alightStopLabel: UILabel!         // "용인동부경찰서 하차"
    @IBOutlet weak var alightToArrivalLabel: UILabel!    // "하차 정류장 → 도착지(도보)"

    @IBOutlet weak var navigateButton: UIButton!          // "바로 안내시작"

    /// 셀에 Route 데이터를 바인딩합니다.
    func configure(with route: Route, index: Int) {
        // 1) 기본 텍스트
        routeTitleLabel.text = "경로 \(index + 1)"
        let total = TravelTimeCalculator.totalTravelTimeMinutes(for: route)
        totalTimeLabel.text = "\(total)분"
        costLabel.text = "요금 1450원"

        // 2) 구간별 시간 계산
        let walk1 = TravelTimeCalculator.walkingTimeMinutes(
            for: TravelTimeCalculator.distanceBetween(route.departureCoord,
                                                    route.viaStops.first!.coordinate))
        let busTime = TravelTimeCalculator.busTimeMinutes(for: route.viaStops)
        let walk2 = TravelTimeCalculator.walkingTimeMinutes(
            for: TravelTimeCalculator.distanceBetween(route.viaStops.last!.coordinate,
                                                    route.arrivalCoord))
        walking1Label.text = "도보 \(walk1)분"
        busLabel.text      = "버스 \(busTime)분"
        walking2Label.text = "도보 \(walk2)분"

        // 3) 상세 텍스트
        departureToBoardLabel.text = "\(route.startStation) → \(route.viaStops.first!.name) 도보"
        busInfoLabel.text          = "\(route.busNumber) | \(route.stopCount)정류장"
        alightStopLabel.text       = "\(route.viaStops.last!.name) 하차"
        alightToArrivalLabel.text  = "하차 정류장 → \(route.endStation)(도보)"

        // 4) 프로그레스 바 -- 필요 시 커스텀 비율 적용
        let totalDouble = Double(total)
        walk1BarView.frame.size.width = contentView.frame.width * (Double(walk1) / totalDouble)
        busBarView.frame.size.width   = contentView.frame.width * (Double(busTime) / totalDouble)
        walk2BarView.frame.size.width = contentView.frame.width * (Double(walk2) / totalDouble)
    }
}
