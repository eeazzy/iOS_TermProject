//
//  RememoViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/3/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RememoViewController: UIViewController {
    
    @IBOutlet weak var gugunLabel: UILabel!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var memoKey: String?
    var currentDistrict: String?
    var currentShopName: String?
    var currentMemo: String?
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
                
        gugunLabel.text = currentDistrict
        shopNameLabel.text = currentShopName
        memoTextView.text = currentMemo
        
        hideKeyboard()
        registerForKeyboardNotifications()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid,
              let memoKey = memoKey,
              let memoText = memoTextView.text else {
            print("Missing required data")
            return
        }
        
        let updatedMemo = [
            "memo": memoText
        ]
        
        ref.child("users").child(userId).child("savedShops").child(memoKey).updateChildValues(updatedMemo) { error, ref in
            if let error = error {
                print("Failed to update memo: \(error.localizedDescription)")
            } else {
                print("Memo updated successfully")
                self.showUpdateSuccessAlert()
            }
        }
    }
    
    func showUpdateSuccessAlert() {
        let alert = UIAlertController(title: "수정 완료", message: "메모가 성공적으로 수정되었습니다.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "확인", style: .default) 
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}
