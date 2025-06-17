//
//  SearchViewController.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//
import UIKit
import CoreLocation

class SearchViewController: UIViewController {
    @IBOutlet weak var departureTextField: UITextField!
    @IBOutlet weak var arrivalTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    // 변환된 좌표 저장
    private var departureCoord: CLLocationCoordinate2D?
    private var arrivalCoord:   CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 버튼 액션 연결
        searchButton.addTarget(
            self,
            action: #selector(onSearchTapped),
            for: .touchUpInside
        )
    }

    @objc func onSearchTapped() {
        // 1) 입력값 유효성 검사
        guard let departText = departureTextField.text, !departText.isEmpty,
              let arriveText = arrivalTextField.text, !arriveText.isEmpty else {
            showAlert("출발지와 도착지를 모두 입력하세요.")
            return
        }

        // 2) 두 검색(출발지, 도착지) 동시 처리
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        NaverSearchAPI.searchPlace(departText) { coord in
            self.departureCoord = coord
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        NaverSearchAPI.searchPlace(arriveText) { coord in
            self.arrivalCoord = coord
            dispatchGroup.leave()
        }

        // 3) 두 API 콜 모두 끝나면 화면 전환
        dispatchGroup.notify(queue: .main) {
            guard let from = self.departureCoord,
                  let to   = self.arrivalCoord else {
                self.showAlert("장소 검색에 실패했습니다.")
                return
            }
            self.performSegue(withIdentifier: "showRouteList", sender: nil)
        }
    }

    private func showAlert(_ message: String) {
        let ac = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteList",
           let vc = segue.destination as? RouteListViewController {
            vc.departureCoord = departureCoord
            vc.arrivalCoord   = arrivalCoord
        }
    }
}
