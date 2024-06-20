//
//  MemoTableViewCell.swift
//  iOSTermProject_khs2071021
//
//  Created by 김현서 on 6/14/24.
//

import UIKit

class MemoTableViewCell: UITableViewCell {

    @IBOutlet weak var gugunLabel: UILabel!    // 왼쪽 위: 자치구 이름
    @IBOutlet weak var shopNameLabel: UILabel! // 위쪽: 가게 이름
    @IBOutlet weak var memoLabel: UILabel!     // 아래쪽: 가게에 대한 메모
    @IBOutlet weak var infoButton: UIButton!   // 왼쪽 중간: 정보 보기 버튼

    override func awakeFromNib() {
        super.awakeFromNib()
        // 초기화 코드
        // 폰트 설정
        gugunLabel.font = UIFont(name: "DungGeunMo", size: 14) // 주소 이름 폰트 설정
        shopNameLabel.font = UIFont(name: "DungGeunMo", size: 14) // 가게 이름 폰트 설정
        memoLabel.font = UIFont(name: "DungGeunMo", size: 16) // 메모 폰트 설정
        infoButton.titleLabel?.font = UIFont(name: "DungGeunMo", size: 12) // 버튼 폰트 설정
        
        // 텍스트 색상 설정
        gugunLabel.textColor = UIColor.black // 자치구 이름 텍스트 색상
        shopNameLabel.textColor = UIColor.black // 가게 이름 텍스트 색상
        memoLabel.textColor = UIColor.black // 메모 텍스트 색상
        infoButton.setTitleColor(UIColor.blue, for: .normal) // 버튼 텍스트 색상
        
        // 메모 배경 설정
        memoLabel.layer.cornerRadius = 5 // 모서리 둥글게 설정
        memoLabel.layer.masksToBounds = true
    }

    // 셀이 재사용될 때 호출됩니다.
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀의 상태를 초기화합니다.
        gugunLabel.text = nil
        shopNameLabel.text = nil
        memoLabel.text = nil
    }
}

