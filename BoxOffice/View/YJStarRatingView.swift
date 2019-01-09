//
//  YJStarRatingView.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 22..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

@objc protocol YJStarRatingViewDelegate {
    @objc optional func starRatingView(_ ratingView: YJStarRatingView, willBeginUpdating rating: Double)
    @objc optional func starRatingView(_ ratingView: YJStarRatingView, isUpdating rating: Double)
    @objc optional func starRatingView(_ ratingView: YJStarRatingView, didEndUpdating rating: Double)
}

@IBDesignable
class YJStarRatingView: UIView {
    // MARK: - Properties
    // MARK: -
    var delegate: YJStarRatingViewDelegate?
    private var imageViews: [UIImageView] = []
    @IBInspectable var emptyImage: UIImage? {
        willSet {
            removeImageViews()
        }
        didSet {
            updateImageViews()
        }
    }
    @IBInspectable var fullImage: UIImage? {
        willSet {
            removeImageViews()
        }
        didSet {
            updateImageViews()
        }
    }
    @IBInspectable var halfImage: UIImage? {
        willSet {
            removeImageViews()
        }
        didSet {
            updateImageViews()
        }
    }
    /// 최댓값
    @IBInspectable var maxRating: Int = 5 {
        willSet {
            removeImageViews()
        }
        didSet {
            if maxRating < starCount {
                maxRating = starCount
            }
            updateImageViews()
        }
    }
    /// 최솟값
    @IBInspectable var minRating: Int = 0 {
        willSet {
            removeImageViews()
        }
        didSet {
            if minRating < 0 {
                minRating = 0
            }
            updateImageViews()
        }
    }
    /// 현재값
    @IBInspectable var currentRating: Double = 0 {
        willSet {
            removeImageViews()
        }
        didSet {
            if currentRating < Double(minRating) {
                currentRating = Double(minRating)
            } else if currentRating > Double(maxRating) {
                currentRating = Double(maxRating)
            }
            updateImageViews()
        }
    }
    /// 별 개수
    private var starCount: Int = 5
    /// 최댓값과 별 개수에 따라 변환된 값
    private var conversionValue: Double {
        get {
            return currentRating / ratio
        }
    }
    /// 최댓값과 별 개수에 따른 비율
    private var ratio: Double {
        get {
            return Double(maxRating / starCount)
        }
    }
    /// 1씩 증가, 0.5씩 증가, 소수점 단위로 증가 타입
    @objc enum RatingType: Int {
        case full
        case half
        case float
    }
    /// 타입, 기본값은 half(0.5씩 증가)
    @IBInspectable var type: RatingType = .half
    /// 터치에 따라 편집 가능 여부
    @IBInspectable var isEditable: Bool = true
    
    // MARK: - Initializers
    // MARK: -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateImageViews()
    }
    /// 기본 초기화 메서드
    required init(frame: CGRect, type: RatingType = .half, isEditable: Bool = true) {
        super.init(frame: frame)
        self.type = type
        self.isEditable = isEditable
        updateImageViews()
    }
    // 스토리보드 에러: IB Designables - Failed to render and update auto layout status, The agent crashed를 피하기 위한 구현
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(frame: CGRect, type: RatingType, isEditable: Bool, minRating: Int, maxRating: Int, currentRating: Double) {
        self.init(frame: frame, type: type, isEditable: isEditable)
        self.minRating = minRating
        self.maxRating = maxRating
        self.currentRating = currentRating
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let emptyImage = emptyImage else {
            return
        }
        let imageWidth = frame.size.width / CGFloat(starCount)
        let imageViewSize = setImageSize(emptyImage, size: CGSize(width: imageWidth, height: frame.size.height))
        let xOffset = (frame.size.width - (imageViewSize.width * CGFloat(starCount))) / CGFloat(starCount - 1)
        for i in 0 ..< starCount {
            let x = i == 0 ? 0 : CGFloat(i) * (xOffset + imageViewSize.width)
            let frame = CGRect(x: x, y: 0, width: imageViewSize.width, height: imageViewSize.height)
            let imageView = imageViews[i]
            imageView.frame = frame
        }
        updateLayout()
    }
    
    // MARK: - Custom Methods
    // MARK: -
    /// 별 개수에 따른 이미지뷰 업데이트 작업을 한다.
    private func updateImageViews() {
        guard imageViews.isEmpty else {
            return
        }
        for _ in 0 ..< starCount {
            let imageView = UIImageView()
            imageView.image = emptyImage
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            addSubview(imageView)
        }
        updateLayout()
    }
    /// 모든 이미지뷰를 지운다.
    private func removeImageViews() {
        for i in 0 ..< starCount {
            let imageView = imageViews[i]
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
    }
    /// 이미지(별)를 채우는 작업을 한다.
    private func updateLayout() {
        for i in 0 ..< starCount {
            let imageView = imageViews[i]
            if conversionValue >= Double(i + 1) {
                imageView.image = fullImage
            } else if conversionValue > Double(i),
                conversionValue < Double(i + 1) {
                let decimalValue = conversionValue - Double(i)
                if decimalValue < 0.5 {
                    imageView.image = emptyImage
                } else {
                    imageView.image = halfImage
                }
            } else {
                imageView.image = emptyImage
            }
        }
    }
    /// 이미지와 뷰의 비율에 맞게 적절한 사이즈를 반환한다.
    private func setImageSize(_ image: UIImage, size: CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height
        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width
            return CGSize(width: width, height: size.height)
        } else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height
            return CGSize(width: size.width, height: height)
        }
    }
    /// 터치에 따라 새로운 위치에 해당되는 currentRating 값을 설정한다.
    private func updateLocation(_ touch: UITouch) {
        guard isEditable else {
            return
        }
        delegate?.starRatingView?(self, willBeginUpdating: currentRating)
        let touchLocation = touch.location(in: self)
        var newRating: Double = 0
        for i in stride(from: starCount - 1, through: 0, by: -1) {
            let imageView = imageViews[i]
            if touchLocation.x <= imageView.frame.origin.x {
                continue
            }
            let newLocation = imageView.convert(touchLocation, from: self)
            if imageView.point(inside: newLocation, with: nil),
                type != .full {
                let decimalValue = Double(newLocation.x / imageView.frame.width)
                if type == .half {
                    newRating = Double(i) + (decimalValue > 0.75 ? 1 : (decimalValue > 0.25 ? 0.5 : 0))
                } else {
                    newRating = Double(i) + decimalValue
                }
            } else {
                newRating = Double(i) + 1
            }
            break
        }
        currentRating = newRating * ratio
        delegate?.starRatingView?(self, isUpdating: currentRating)
    }
    
    // MARK: - Touch Events
    // MARK: -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.starRatingView?(self, didEndUpdating: currentRating)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.starRatingView?(self, didEndUpdating: currentRating)
    }
}
