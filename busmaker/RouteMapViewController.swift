//
//  RouteMapViewController.swift
//  busmaker
//
//  Created by user269773 on 6/17/25.
//

import UIKit
import MapKit
import CoreLocation

class RouteMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var locationManager = CLLocationManager()
    /// 이전 화면에서 전달되는 Route 모델
    var selectedRoute: Route!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = .followWithHeading

        
        guard let route = selectedRoute else { return }

        // 1) 모든 좌표 배열: 출발 + 경유지 + 도착
        let coords: [CLLocationCoordinate2D] =
            [route.departureCoord] +
            route.viaStops.map { $0.coordinate } +
            [route.arrivalCoord]

        // 2) 지도 영역 계산 (경계에 맞춘 center & span)
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        let maxLat = lats.max()!, minLat = lats.min()!
        let maxLon = lons.max()!, minLon = lons.min()!
        let center = CLLocationCoordinate2D(
            latitude: (maxLat + minLat) / 2,
            longitude: (maxLon + minLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2,  // 20% 여유
            longitudeDelta: (maxLon - minLon) * 1.2
        )
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)

        // 3) 마커 추가
        // 3-1) 출발지
        let startAnno = MKPointAnnotation()
        startAnno.coordinate = route.departureCoord
        startAnno.title = "출발: \(route.startStation)"
        mapView.addAnnotation(startAnno)

        // 3-2) 경유 정류장
        for stop in route.viaStops {
            let anno = MKPointAnnotation()
            anno.coordinate = stop.coordinate
            anno.title = stop.name
            mapView.addAnnotation(anno)
        }

        // 3-3) 도착지
        let endAnno = MKPointAnnotation()
        endAnno.coordinate = route.arrivalCoord
        endAnno.title = "도착: \(route.endStation)"
        mapView.addAnnotation(endAnno)

        // 4) 폴리라인 그리기
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: line)
            renderer.lineWidth = 4
            renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.7)
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

