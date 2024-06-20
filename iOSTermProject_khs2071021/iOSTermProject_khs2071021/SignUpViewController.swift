//
//  SignUpViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/13/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var idTextField: UITextField!
    
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "signupbg")
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)

        self.signupButton.layer.masksToBounds = true
        self.signupButton.layer.cornerRadius = 10
        
        backButton.titleLabel?.font = UIFont(name: "DungGeunMo", size: 16)
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                
        hideKeyboard()
        registerForKeyboardNotifications()
    }
    
    @objc func backButtonTapped() {
        // 현재 뷰 컨트롤러를 dismiss하여 이전 화면으로 돌아갑니다.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        
           guard let email = idTextField.text, !email.isEmpty else { return }
           guard let password = pwTextField.text, !password.isEmpty else { return }

           // Firebase에 사용자 등록
           Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   print("사용자 등록 실패: \(error.localizedDescription)")
                   self.showAlert(title: "회원가입 실패", message: "다시 입력해주세요")
                   return
               }

               print("사용자 등록 성공")
               self.showAlert(title: "회원가입 성공", message: "환영합니다")
               self.presentingViewController?.dismiss(animated: true)
           }
       }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

}
