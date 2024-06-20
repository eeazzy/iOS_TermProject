//
//  MapViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/3/24.
//


import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    var selectedGugun: String?
    var shopsData: [Shop] = []
    var zoomInButton: UIButton!
    var zoomOutButton: UIButton!
    var zoomBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("selectedGugun: \(selectedGugun ?? "None")")
        
        mapview.delegate = self
        
        backButton.titleLabel?.font = UIFont(name: "DungGeunMo", size: 16)
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Add zoom background view
        zoomBackgroundView = UIView()
        zoomBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        zoomBackgroundView.layer.cornerRadius = 10
        zoomBackgroundView.layer.masksToBounds = true
        zoomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomBackgroundView)
        
        // Add zoom in button
        zoomInButton = UIButton(type: .custom)
        zoomInButton.setImage(UIImage(systemName: "plus"), for: .normal)
        zoomInButton.tintColor = .black
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomBackgroundView.addSubview(zoomInButton)
        
        // Add zoom out button
        zoomOutButton = UIButton(type: .custom)
        zoomOutButton.setImage(UIImage(systemName: "minus"), for: .normal)
        zoomOutButton.tintColor = .black
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        zoomBackgroundView.addSubview(zoomOutButton)
        
        setupConstraints()
        
        let initialLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
        centerMapOnLocation(location: initialLocation)
        
        loadShopData()
        
        // memoImageView에 TapGestureRecognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(memoImageViewTapped))
        memoImageView.isUserInteractionEnabled = true
        memoImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backButtonTapped() {
        // 현재 뷰 컨트롤러를 dismiss하여 이전 화면으로 돌아갑니다.
        dismiss(animated: true, completion: nil)
    }
    
    // memoImageView가 탭될 때 호출되는 메서드
    @objc func memoImageViewTapped() {
       performSegue(withIdentifier: "mapToMemoSegue", sender: self)
    }
    
    func loadShopData() {
        guard let selectedGugun = selectedGugun else {
            return
        }
        
        if let path = Bundle.main.path(forResource: "shopData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let shops = try JSONDecoder().decode([String: [Shop]].self, from: data)
                
                if let shopsInGugun = shops[selectedGugun] {
                    self.shopsData = shopsInGugun
                    showShopsOnMap()
                } else {
                    print("No shops found for \(selectedGugun)")
                    showAlert(title: "Error", message: "No shops found for \(selectedGugun)")
                }
            } catch {
                print("Error decoding shop data: \(error.localizedDescription)")
                showAlert(title: "Error", message: "Failed to load shop data.")
            }
        } else {
            print("Failed to locate shopData.json")
            showAlert(title: "Error", message: "Failed to locate shopData.json")
        }
    }
    
    func showShopsOnMap() {
        for shop in shopsData {
            if let latitude = shop.latitude, let longitude = shop.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = shop.name
                annotation.subtitle = "평점: \(shop.rating)"
                mapview.addAnnotation(annotation)
            } else {
                print("Missing latitude or longitude for shop: \(shop.name)")
            }
        }
        
        mapview.showAnnotations(mapview.annotations, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            zoomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            zoomBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            zoomBackgroundView.widthAnchor.constraint(equalToConstant: 80),
            zoomBackgroundView.heightAnchor.constraint(equalToConstant: 80),
            
            zoomInButton.centerXAnchor.constraint(equalTo: zoomBackgroundView.centerXAnchor),
            zoomInButton.topAnchor.constraint(equalTo: zoomBackgroundView.topAnchor, constant: 8),
            zoomInButton.widthAnchor.constraint(equalToConstant: 40),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),
            
            zoomOutButton.centerXAnchor.constraint(equalTo: zoomBackgroundView.centerXAnchor),
            zoomOutButton.bottomAnchor.constraint(equalTo: zoomBackgroundView.bottomAnchor, constant: -8),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 40),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func zoomIn() {
        var region = mapview.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapview.setRegion(region, animated: true)
    }
    
    @objc func zoomOut() {
        var region = mapview.region
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
        mapview.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            if let selectedShop = shopsData.first(where: { $0.name == annotation.title }) {
                performSegue(withIdentifier: "mapToDetailSegue", sender: selectedShop)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToDetailSegue" {
            if let detailVC = segue.destination as? DetailTableViewController,
               let selectedShop = sender as? Shop {
                detailVC.selectedShop = selectedShop
                detailVC.modalPresentationStyle = .fullScreen

            }
        }
    }
}

