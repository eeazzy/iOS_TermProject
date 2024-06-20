//
//  UserManager.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/16/24.
//

import Foundation
import FirebaseAuth

class UserManager {
    
    static let shared = UserManager()

    private init() {} // 외부에서 초기화 방지

    var currentUser: User? // 현재 사용자 정보 저장 변수

    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            completion(true)
        } else {
            self.currentUser = nil
            completion(false)
        }
    }
}

