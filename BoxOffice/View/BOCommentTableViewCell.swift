//
//  BOCommentTableViewCell.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 23..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BOCommentTableViewCell: UITableViewCell {
    private lazy var dateFommater: DateFormatter = {
        let fommater = DateFormatter()
        fommater.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return fommater
    }()
    @IBOutlet var writerImageView: UIImageView!
    @IBOutlet private var writerLabel: UILabel!
    @IBOutlet private var timestampLabel: UILabel!
    @IBOutlet private var contentsLabel: UILabel!
    @IBOutlet private var starRatingView: YJStarRatingView! {
        didSet {
            starRatingView.maxRating = 10
            starRatingView.isEditable = false
            starRatingView.emptyImage = UIImage(named: "ic_star_large")
            starRatingView.fullImage = UIImage(named: "ic_star_large_full")
            starRatingView.halfImage = UIImage(named: "ic_star_large_half")
        }
    }
    
    override func prepareForReuse() {
        timestampLabel.text = ""
        writerImageView.image = UIImage(named: "ic_user_loading")
    }
    func updateContents(_ data: CommentData) {
        writerLabel.text = data.writer
        contentsLabel.text = data.contents
        if let time = data.timestamp {
            let date = Date(timeIntervalSince1970: time)
            timestampLabel.text = dateFommater.string(from: date)
        }
        starRatingView.currentRating = data.rating
    }
}
