//
//  SavedShopModel.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/16/24.
//

import Foundation

struct SavedShop: Codable {
    let name: String // 가게 이름
    let district: String // 자치구
    let memo: String // 사용자 메모
    var googleMapsURL: String

    init(name: String, district: String, memo: String, googleMapsURL: String) {
        self.name = name
        self.district = district
        self.memo = memo
        self.googleMapsURL = googleMapsURL
    }
}
