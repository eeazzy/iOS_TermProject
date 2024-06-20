//
//  MemoViewController.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/3/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MemoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var memos: [(key: String, district: String, name: String, memo: String, googleMapsURL: String?)] = []
    var ref: DatabaseReference!
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 테이블 뷰의 델리게이트와 데이터 소스 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        ref = Database.database().reference()
        fetchMemos()
    }
    
    func fetchMemos() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("사용자 ID가 없습니다.")
            return
        }
        
        ref.child("users").child(userId).child("savedShops").observe(.value) { snapshot in
            guard let snapshotValue = snapshot.value as? [String: Any] else {
                print("Snapshot에 데이터가 없습니다.")
                return
            }
            
        self.memos.removeAll()
            
        for (key, value) in snapshotValue {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let savedShop = try JSONDecoder().decode(SavedShop.self, from: jsonData)
                
                let memo = (key: key,
                            district: savedShop.district,
                            name: savedShop.name,
                            memo: savedShop.memo,
                            googleMapsURL: savedShop.googleMapsURL)
                self.memos.append(memo)
            } catch {
                print("Failed to decode saved shop data:", error.localizedDescription)
            }
        }
            
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as! MemoTableViewCell
        
        let memo = memos[indexPath.row]
        cell.gugunLabel.text = memo.district
        cell.shopNameLabel.text = memo.name
        cell.memoLabel.text = memo.memo
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
        if selectedIndexPath == indexPath {
            cell.accessoryType = .detailDisclosureButton
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 기존에 선택된 셀이 있다면 deselect 처리
        if let selectedIndexPath = selectedIndexPath {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        selectedIndexPath = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 선택 해제 시 selectedIndexPath를 nil로 설정하고 reloadRows를 통해 셀을 다시 로드하여 AccessoryType을 변경
        selectedIndexPath = nil
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        let memo = memos[sender.tag]
        
        guard let googleMapsURL = memo.googleMapsURL, let url = URL(string: googleMapsURL) else {
            print("Invalid Google Maps URL: \(memo.googleMapsURL ?? "nil")")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Failed to open Google Maps URL: \(googleMapsURL)")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let editAction = UIContextualAction(style: .normal, title: "수정") { (_, _, completionHandler) in
                self.editMemo(at: indexPath)
                completionHandler(true)
            }
            editAction.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 0.7)
            editAction.image = UIImage(systemName: "pencil")
            
            return UISwipeActionsConfiguration(actions: [editAction])
        }
        
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (_, _, completionHandler) in
            self.deleteMemo(at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func editMemo(at indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        performSegue(withIdentifier: "fixMemoSegue", sender: memo)
    }
    
    func deleteMemo(at indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("사용자 ID가 없습니다.")
            return
        }
        
        ref.child("users").child(userId).child("savedShops").child(memo.key).removeValue { error, _ in
            if let error = error {
                print("Failed to delete memo: \(error.localizedDescription)")
            } else {
                print("Memo deleted successfully")
                self.fetchMemos()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fixMemoSegue",
           let destinationVC = segue.destination as? RememoViewController,
           let memo = sender as? (key: String, district: String, name: String, memo: String, googleMapsURL: String?) {
            
            destinationVC.memoKey = memo.key
            destinationVC.currentMemo = memo.memo
            destinationVC.currentDistrict = memo.district
            destinationVC.currentShopName = memo.name
        }
    }
}
