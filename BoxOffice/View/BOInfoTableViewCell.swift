//
//  BOInfoTableViewCell.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 23..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BOInfoTableViewCell: UITableViewCell, BOMovieUI {
    @IBOutlet var thumnailImageView: UIImageView! {
        didSet {
            thumnailImageView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var gradeImageView: UIImageView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var genreDurationLabel: UILabel!
    @IBOutlet private var reservationLabel: UILabel!
    @IBOutlet private var userRatingLabel: UILabel!
    @IBOutlet private var starRatingView: YJStarRatingView! {
        didSet {
            starRatingView.isEditable = false
            starRatingView.maxRating = 10
            starRatingView.emptyImage = UIImage(named: "ic_star_large")
            starRatingView.fullImage = UIImage(named: "ic_star_large_full")
            starRatingView.halfImage = UIImage(named: "ic_star_large_half")
        }
    }
    @IBOutlet private var audienceLabel: UILabel!

    /// movieData 값에 따라 레이아웃을 설정한다.
    func updateContents(_ data: MovieData) {
        titleLabel.text = data.title
        setGradeImageView(gradeImageView, grade: data.grade)
        dateLabel.text = data.date
        genreDurationLabel.text = "\(data.genre)/\(data.duration)분"
        reservationLabel.text = "\(data.reservationGrade)위 \(data.reservationRate)%"
        userRatingLabel.text = "\(data.userRating)"
        starRatingView.currentRating = data.userRating
        audienceLabel.text = data.audience.toStringWithComma() ?? "\(data.audience)"
    }
}
