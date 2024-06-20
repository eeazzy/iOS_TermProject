//
//  LoginViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/3/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var SignupButton: UIButton!
   
    @IBOutlet weak var idTextField: UITextField!
    
    @IBOutlet weak var pwTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경 이미지 설정
        let backgroundImage = UIImage(named: "mainbg")
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        
        // 배경 이미지뷰를 뷰 계층 구조에 추가
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        self.LoginButton.layer.masksToBounds = true
        self.LoginButton.layer.cornerRadius = 10
        
        self.SignupButton.layer.masksToBounds = true
        self.SignupButton.layer.cornerRadius = 10
        
        self.SignupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)

        // UITextFieldDelegate 설정
        idTextField.delegate = self
        pwTextField.delegate = self
        
        hideKeyboard()
        registerForKeyboardNotifications()

    }
    
    @objc func signupButtonTapped() {
           // 스토리보드에서 SignUpViewController 인스턴스화
           guard let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewControllerID") as? SignUpViewController else { return }
           
           // 화면 전환 애니메이션 설정
           signUpViewController.modalTransitionStyle = .coverVertical
           
           // 전환된 화면이 보여지는 방법 설정 (fullScreen)
           signUpViewController.modalPresentationStyle = .fullScreen
           
           // 화면 전환
           self.present(signUpViewController, animated: true, completion: nil)
       }
    
    @IBAction func userLoginAction(_ sender: Any) {
        
        guard let email = idTextField.text, !email.isEmpty else { return }
        guard let password = pwTextField.text, !password.isEmpty else { return}
            
            // Firebase Auth Login
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "로그인 실패", message: "없는 사용자 입니다.")
                print("로그인 실패: \(error.localizedDescription)")
                return
            }
                        
            print("로그인 성공")
            // 사용자 정보 가져오기
            UserManager.shared.fetchCurrentUser { success in
                if success {
                    if let userEmail = UserManager.shared.currentUser?.email {
                        print("현재 로그인한 사용자 이메일: \(userEmail)")
                    }
                } else {
                    print("현재 로그인한 사용자 없음")
                }
            }
            
            self.navigateToSelectViewController()
        }
    }

    func navigateToSelectViewController() {
        if let selectVC = storyboard?.instantiateViewController(withIdentifier: "SelectViewControllerID") {
            selectVC.modalPresentationStyle = .fullScreen
            self.present(selectVC, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
