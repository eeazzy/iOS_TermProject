//
//  SelectViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/3/24.
//

import UIKit
import FirebaseAuth

class SelectViewController: UIViewController {
    let openAIClient = OpenAIClient()
    
    @IBOutlet weak var memoImageView: UIImageView!
    
    @IBOutlet weak var SelectButton: UIButton!
    
    @IBOutlet weak var SelectPickerView: UIPickerView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var seoulInfoLabel: UILabel!
    
    // 선택된 자치구 이름 저장
    var selectedGugun: String?
    
    // 서울의 자치구 목록 배열
    let gugunList: [String] = ["강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SelectButton.layer.masksToBounds = true
        self.SelectButton.layer.cornerRadius = 10
        
        seoulInfoLabel.font = UIFont(name: "DungGeunMo", size: 14)
        
        // UIPickerView의 delegate와 dataSource 설정
        SelectPickerView.delegate = self
        SelectPickerView.dataSource = self
        
        // 초기 선택 상태 설정
        let initialSelectedRow = 0
        SelectPickerView.selectRow(initialSelectedRow, inComponent: 0, animated: false)
        pickerView(SelectPickerView, didSelectRow: initialSelectedRow, inComponent: 0)
        
        // memoImageView에 TapGestureRecognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(memoImageViewTapped))
        memoImageView.isUserInteractionEnabled = true
        memoImageView.addGestureRecognizer(tapGesture)
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

        fetchSeoulTrivia()
    }
    
    func fetchSeoulTrivia() {
        let prompt = "서울 랜덤 간단 상식 1개 알려줘 짧게, 알고 계셨나요? 라고 대답 시작해"
        
        openAIClient.sendCompletionRequest(prompt: prompt) { [weak self] response, error in
            if let error = error {
                print("Error receiving OpenAI response: \(error.localizedDescription)")
                return
            }
            
            guard let response = response,
                  let choices = response["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("Failed to parse OpenAI response")
                return
            }
            
            DispatchQueue.main.async {
                self?.seoulInfoLabel.text = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    // memoImageView가 탭될 때 호출되는 메서드
    @objc func memoImageViewTapped() {
       performSegue(withIdentifier: "SelectToMemoSegue", sender: self)
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
    
    func navigateToLogin() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewControllerID") {
            UIApplication.shared.windows.first?.rootViewController = loginVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        
        guard let selectedGugun = self.selectedGugun else {
            let alert = UIAlertController(title: "경고", message: "구를 선택하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "selectToMapSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectToMapSegue" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.selectedGugun = selectedGugun
                mapViewController.modalPresentationStyle = .fullScreen
            }
        }
    }

}

// MARK: - UIPickerViewDataSource 및 UIPickerViewDelegate 구현
extension SelectViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // 피커뷰 열 수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 피커뷰 행 수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gugunList.count
    }
    // 피커뷰 각행 View
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        
        let gugunLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        gugunLabel.text = gugunList[row]
        gugunLabel.textAlignment = .center
        gugunLabel.font = UIFont(name: "DungGeunMo", size: 28)
        
        view.addSubview(gugunLabel)
        return view
    }
    // 피커뷰 행 높이
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGugun = gugunList[row]
        print("Selected row: \(row), Gugun: \(gugunList[row])")
    }
}


