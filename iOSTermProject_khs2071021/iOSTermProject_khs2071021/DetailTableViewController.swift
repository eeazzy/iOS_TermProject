//
//  DetailTableViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/15/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase 

class DetailTableViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var ShopNameLabel: UILabel!
    @IBOutlet weak var ratingFix: UILabel!
    @IBOutlet weak var RatingLabel: UILabel!
    @IBOutlet weak var openFix: UILabel!
    @IBOutlet weak var OpenLabel: UILabel!
    @IBOutlet weak var GoToURLLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var selectedShop: Shop? // 선택한 가게 정보를 저장할 변수
    var userId: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 사용자 ID 설정
        userId = Auth.auth().currentUser?.uid
    }
    
    func setupUI() {
        guard let shop = selectedShop else { return }
        
        SaveButton.titleLabel?.font = UIFont(name: "DungGeunMo", size: 16)
        backButton.titleLabel?.font = UIFont(name: "DungGeunMo", size: 16)
        ShopNameLabel.font = UIFont(name: "DungGeunMo", size: 35)
        ratingFix.font = UIFont(name: "DungGeunMo", size: 20)
        RatingLabel.font = UIFont(name: "DungGeunMo", size: 20)
        openFix.font = UIFont(name: "DungGeunMo", size: 18)
        OpenLabel.font = UIFont(name: "DungGeunMo", size: 23)
        GoToURLLabel.font = UIFont(name: "DungGeunMo", size: 20)
        
        ratingFix.textColor = .red
        openFix.textColor = .blue
        
        SaveButton.layer.masksToBounds = true
        SaveButton.layer.cornerRadius = 10
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        if let shop = selectedShop {
            ShopNameLabel.text = shop.name
            RatingLabel.text = "\(shop.rating)"
            
            var businessHoursText = ""
            for (day, time) in shop.businessHours {
                businessHoursText += "\(day): \(time)\n"
            }
            OpenLabel.text = businessHoursText
                
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGoogleMapsURL))
            GoToURLLabel.isUserInteractionEnabled = true
            GoToURLLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func backButtonTapped() {
        // 현재 뷰 컨트롤러를 dismiss하여 이전 화면으로 돌아갑니다.
        dismiss(animated: true, completion: nil)
    }
    
    @objc func openGoogleMapsURL() {
        guard let url = selectedShop?.googleMapsURL, let urlObject = URL(string: url) else {
            print("Invalid URL: \(selectedShop?.googleMapsURL ?? "nil")")
            return
        }
        
        if UIApplication.shared.canOpenURL(urlObject) {
            UIApplication.shared.open(urlObject, options: [:], completionHandler: nil)
        } else {
            print("Failed to open URL: \(url)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userId = userId, let shop = selectedShop else {
            print("사용자 ID나 선택한 가게 정보가 없습니다.")
            return
        }
        
        let alertController = UIAlertController(title: "메모 추가", message: "메모를 입력하세요", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "메모를 입력하세요"
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak alertController] _ in
            guard let memo = alertController?.textFields?.first?.text, !memo.isEmpty else {
                print("메모가 비어 있습니다.")
                return
            }
            // 구글 맵 URL
            guard let googleMapsURL = self.selectedShop?.googleMapsURL else {
                print("구글 맵 URL이 없습니다.")
                return
            }
            // 주소
            let district = shop.address
            // SavedShop 객체 생성
            let savedShop = SavedShop(name: shop.name, district: district, memo: memo, googleMapsURL: googleMapsURL)
            // Firebase에 저장
            self.saveSavedShopToFirebase(userId: userId, savedShop: savedShop)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Firebase에 저장
    func saveSavedShopToFirebase(userId: String, savedShop: SavedShop) {
        // Firebase Database 참조 생성
        let ref = Database.database().reference()
        // 사용자 경로 참조
        let userSavedShopsRef = ref.child("users").child(userId).child("savedShops").childByAutoId()
        // 가게 데이터 생성
        do {
            let shopData = try JSONEncoder().encode(savedShop)
            let shopDict = try JSONSerialization.jsonObject(with: shopData, options: []) as? [String: Any]
            // 데이터 저장
            userSavedShopsRef.setValue(shopDict) { error, ref in
                if let error = error {
                    print("Firebase에 데이터 저장 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("가게 정보가 Firebase에 성공적으로 저장되었습니다.")
                }
            }
        } catch {
            print("SavedShop 객체를 인코딩하는 동안 오류 발생: \(error)")
        }
    }
}
