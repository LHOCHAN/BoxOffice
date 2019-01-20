//
//  BOWriteCommentViewController.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 23..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BOWriteCommentViewController: BOMovieViewController {
    // MARK: - Properties
    // MARK: -
    var movieData: MovieData?
    private let placeholderText = "한줄평을 작성해주세요"
    private var dataIsValid: Bool {
        if let writer = writerTextField.text, let contents = contentsTextView.text,
            !writer.isEmpty, !contents.isEmpty, contents != placeholderText,
            starRatingView.currentRating != 0 {
            return true
        }
        return false
    }
    
    // MARK: - IBOutlets
    // MARK: -
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var gradeImageView: UIImageView!
    @IBOutlet private var starRatingView: YJStarRatingView! {
        didSet {
            starRatingView.maxRating = 10
            starRatingView.isEditable = true
            starRatingView.emptyImage = UIImage(named: "ic_star_large")
            starRatingView.fullImage = UIImage(named: "ic_star_large_full")
            starRatingView.halfImage = UIImage(named: "ic_star_large_half")
            starRatingView.delegate = self
        }
    }
    @IBOutlet private var ratingLabel: UILabel! {
        didSet {
            ratingLabel.text = "0"
        }
    }
    @IBOutlet private var writerTextField: UITextField!
    @IBOutlet private var contentsTextView: UITextView! {
        didSet {
            contentsTextView.layer.borderColor = UIColor.red.cgColor
            contentsTextView.layer.borderWidth = 1.0
            contentsTextView.layer.cornerRadius = 5.0
            contentsTextView.text = placeholderText
            contentsTextView.textColor = UIColor.placeholderColor()
        }
    }
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorViewAnimating(activityIndicatorView, refresher: nil, isStart: false)
        }
    }
    
    // MARK: - Action methods
    // MARK: -
    @IBAction private func cancelBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction private func completionBtnTapped(_ sender: Any) {
        guard dataIsValid else {
            alert("닉네임과 한줄평, 평점을 모두 입력하세요.")
            return
        }
        postMovieComment()
    }
    /// 화면 터치시 편집을 종료한다.
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    // MARK: - View lifecycles
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        writerTextField.text = fetchWriter()
        if let movieData = movieData {
            titleLabel.text = movieData.title
            setGradeImageView(gradeImageView, grade: movieData.grade)
        }
    }
    
    // MARK: - Database methods
    // MARK: -
    /// 작성자를 영구저장소에 기록한다.
    private func setWriter(_ writer: String) {
        if !writer.isEmpty {
            UserDefaults.standard.set(writer, forKey: "writer")
        }
    }
    /// 작성자를 영구저장소에서 가져온다.
    private func fetchWriter() -> String? {
        if let writer = UserDefaults.standard.value(forKey: "writer") as? String {
            return writer
        }
        return nil
    }
    
    // MARK: - HTTP/HTTPS methods
    // MARK: -
    /// 평점을 게시한다.
    private func postMovieComment() {
        guard let id = movieData?.id,
            let writer = writerTextField.text,
            let contents = contentsTextView.text else {
                return
        }
        let rating = starRatingView.currentRating
        setWriter(writer)
        indicatorViewAnimating(activityIndicatorView, refresher: nil, isStart: false)
        requestAPI.postMovieComment(id, writer: writer, contents: contents, rating: rating) { [weak self] (isSuccess, _, error) in
            guard let self = self else { return }
            self.indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: false)
            if let error = error {
                self.errorHandler(error)
            }
            if isSuccess {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.errorHandler()
            }
        }
    }
}

// MARK: - YJStarRatingViewDelegate
// MARK:
extension BOWriteCommentViewController: YJStarRatingViewDelegate {
    /// starRatingView에서 업데이트 되는 값을 ratingLabel에 반영합니다.
    func starRatingView(_ ratingView: YJStarRatingView, isUpdating rating: Double) {
        ratingLabel.text = String(format: "%.f", rating)
    }
}

// MARK: - UITextFieldDelegate
// MARK: -
extension BOWriteCommentViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let writer = textField.text {
            textField.text = writer.trim()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - UITextViewDelegate
// MARK: -
extension BOWriteCommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.placeholderColor()
        }
    }
}
