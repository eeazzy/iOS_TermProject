//
//  ExtensionViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/13/24.
//

import UIKit

// UIViewController 확장
extension UIViewController: UITextFieldDelegate {
    
    // 화면을 탭했을 때 키보드를 숨기는 메서드
    func hideKeyboard() {
        // 제스처 인식기를 추가하여 화면을 탭할 때 키보드를 숨기도록 설정
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(UIViewController.dismissKeyboard))
        // tapGesture가 다른 제스처의 실행을 방해하지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        // 현재 활성화된 텍스트 입력(키보드)를 종료하여 키보드를 숨김
        view.endEditing(true)
    }
    
    // UITextFieldDelegate 메서드 - return 키를 누를 때 호출
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 키보드를 숨기기
        textField.resignFirstResponder()
        return true
    }
    
    // 키보드 이벤트에 대한 옵저버 추가
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 이벤트에 대한 옵저버 제거
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ sender: Notification) {
        // 키보드의 frame 값을 받아옴
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentResponder = UIResponder.currentResponder as? UIView else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedResponderFrame = view.convert(currentResponder.frame, from: currentResponder.superview)
        let responderBottomY = convertedResponderFrame.origin.y + convertedResponderFrame.size.height
        
        if responderBottomY > keyboardTopY {
            let offset = responderBottomY - keyboardTopY + 50 // 여유 공간 20 추가
            self.view.frame.origin.y = -offset
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        // 키보드가 숨겨질 때 화면을 원래 위치로 되돌림
        self.view.frame.origin.y = 0
    }
    
    func showAlert(title: String? = nil, message: String, completion: (() -> Void)? = nil) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
}

// 현재 응답받는 UI를 알아내기 위한 UIResponder 확장
extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static var currentResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}
