//
//  ShopModel.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/16/24.
//

import Foundation

struct Shop: Codable {
    let name: String
    let address: String
    let rating: Double
    let googleMapsURL: String
    let latitude: Double?
    let longitude: Double?
    let businessHours: [String: String]

    enum CodingKeys: String, CodingKey {
        case name = "이름"
        case address = "주소"
        case rating = "평점"
        case googleMapsURL = "구글플레이스_사이트"
        case latitude = "좌표x"
        case longitude = "좌표y"
        case businessHours = "영업시간"
    }
}
