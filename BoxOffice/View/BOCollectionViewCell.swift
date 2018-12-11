//
//  BOCollectionViewCell.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 17..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BOCollectionViewCell: UICollectionViewCell, BOMovieUI {
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var gradeImageView: UIImageView!
    @IBOutlet private var ratingReservationLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    
    /// moviesData 값에 따라 레이아웃을 설정한다.
    func updateContents(_ data: MoviesData) {
        titleLabel.text = data.title
        setGradeImageView(gradeImageView, grade: data.grade)
        ratingReservationLabel.text = "\(data.reservationGrade)위(\(data.userRating)) / \(data.reservationRate)%"
        dateLabel.text = data.date
    }
}
