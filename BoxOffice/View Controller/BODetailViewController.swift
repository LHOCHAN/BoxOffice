//
//  BODetailViewController.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 20..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BODetailViewController: BOMovieViewController {
    struct DataModel {
        var movieData: MovieData?
        var commentsData = [CommentData]()
        var movieImage: UIImage?
    }
    
    // MARK: - Properties
    // MARK: -
    var moviesData: MoviesData?
    private lazy var dataModel = DataModel()
    private var imageCache = ImageCache(name: "BoxOfficeDetail")
    private var imagePrefetcher: ImagePrefetcher?
    private lazy var cellImageViewTapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(cellImageViewTapped))
    }()
    private lazy var allSizeImageView: UIImageView = {
        let frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 88)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(allSizeImageViewTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    // MARK: - IBOutlets
    // MARK: -
    @IBOutlet private var tableView: UITableView! {
        didSet {
            let headerNib = UINib.init(nibName: CellIdentifier.boHeaderCell, bundle: nil)
            tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: CellIdentifier.boHeaderCell)
            tableView.isHidden = true
        }
    }
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorViewAnimating(activityIndicatorView, refresher: nil, isStart: false)
        }
    }
    
    // MARK: - Action methods
    // MARK: -
    /// 작성 버튼 클릭
    @objc private func composeBtnTapped() {
        guard let movieData = dataModel.movieData else {
            return
        }
        performSegue(withIdentifier: SegueIdentifier.goToWriteCommentVC, sender: movieData)
    }
    /// 셀 이미지뷰 탭 이벤트.
    @objc private func cellImageViewTapped() {
        for subView in view.subviews {
            subView.isHidden = true
        }
        view.addSubview(allSizeImageView)
        hideBar()
    }
    /// 전체 이미지뷰 탭 이벤트.
    @objc private func allSizeImageViewTapped() {
        allSizeImageView.removeFromSuperview()
        for subView in view.subviews {
            if subView === activityIndicatorView {
                continue
            }
            subView.isHidden = false
        }
        bringBar()
    }
    
    // MARK: - View Lifecycles
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePrefetcher = ImagePrefetcher(imageCache: imageCache)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMovie()
        changeNavigationTitle()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == SegueIdentifier.goToWriteCommentVC {
            guard let movieData = sender as? MovieData,
                let writeCommentVC = segue.destination as? BOWriteCommentViewController else {
                    return
            }
            writeCommentVC.movieData = movieData
        }
    }
    
    // MARK: - UI methods
    // MARK: -
    /// 네이게이션 타이틀을 변경한다.
    private func changeNavigationTitle() {
        guard let moviesData = moviesData else {
            return
        }
        let backItem = UIBarButtonItem()
        backItem.title = "영화목록"
        backItem.tintColor = UIColor.white
        navigationItem.title = "\(moviesData.title)"
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
    }
    /// 내비게이션, 탭바를 숨기는 메서드.
    private func hideBar() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.navigationController?.navigationBar.alpha = 0.0
            self.tabBarController?.tabBar.alpha = 0.0
            self.navigationController?.navigationBar.frame.size.height = 0.0
            self.tabBarController?.tabBar.frame.size.height = 0.0
            self.view.backgroundColor = UIColor.black
        })
    }
    /// 내비게이션, 탭바를 가져오는 메서드.
    private func bringBar() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.navigationController?.navigationBar.alpha = 1.0
            self.tabBarController?.tabBar.alpha = 1.0
            self.navigationController?.navigationBar.frame.size.height = 44.0
            self.tabBarController?.tabBar.frame.size.height = 44.0
            self.view.backgroundColor = UIColor.white
        })
    }
    
    // MARK: - HTTP/HTTPS methods
    // MARK: -
    /// 영화 데이터를 요청한다.
    private func requestMovie() {
        guard let moviesData = moviesData else {
            return
        }
        // 액티비티 인디케이터뷰 활성화
        indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: true)
        // 이미지 요청의 경우 다른 요청에서 얻어온 값을 파라미터로 사용하기 때문에
        // 디스패치 그룹을 사용하여 처리
        let dispatchGroup = DispatchGroup()
        // 오류 발생 여부
        var errorOccurred = false
        dispatchGroup.enter()
        requestAPI.requestMovieDetailInfo(moviesData.id) { [weak self ] (isSuccess, movie, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(error) {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: false)
                }
            }
            if isSuccess, let movie = movie as? MovieData {
                self.dataModel.movieData = movie
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        requestAPI.requestMovieComments(moviesData.id) { [weak self ] (isSuccess, comments, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(error) {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: false)
                }
            }
            if isSuccess, let comments = comments as? [CommentData] {
                self.dataModel.commentsData = comments
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        // 네트워크 호출이 끝나고 오류가 없다면 이미지를 요청한다.
        dispatchGroup.notify(queue: .global()) {
            if errorOccurred {
                self.errorHandler() {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: false)
                }
            } else {
                self.downloadMovieImage()
            }
        }
    }
    /// 영화 이미지를 요청한다.
    private func downloadMovieImage() {
        guard let movieData = dataModel.movieData,
            let url = URL(string: movieData.image) else {
                return
        }
        imagePrefetcher?.startPrefetching(url: url) { [weak self] (image) in
            guard let self = self else { return }
            self.indicatorViewAnimating(self.activityIndicatorView, refresher: nil, isStart: false)
            guard let image = image else {
                self.errorHandler() {
                    // 실패하였지만 이미지를 제외한 데이터는 갖고 있기 때문에 테이블 뷰를 리로드한다.
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
                return
            }
            self.dataModel.movieImage = image
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Identifier constants
// MARk: -
extension BODetailViewController {
    struct TableViewSection {
        static let movieInfo = 0
        static let movieSynopsis = 1
        static let movieDirectorActor = 2
        static let movieComments = 3
    }
    struct CellIdentifier {
        static let boHeaderCell = "BOHeaderCell"
        static let boInfoTableViewCell = "BOInfoTableViewCell"
        static let boSynopsisTableViewCell = "BOSynopsisTableViewCell"
        static let boActorTableViewCell = "BOActorTableViewCell"
        static let boCommentTableViewCell = "BOCommentTableViewCell"
    }
    struct SegueIdentifier {
        static let goToWriteCommentVC = "GoToWriteCommentVCFromDetailVC"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
// MARK: -
extension BODetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == TableViewSection.movieComments ? dataModel.commentsData.count : 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == TableViewSection.movieInfo ? 280 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movieData = dataModel.movieData else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case TableViewSection.movieInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.boInfoTableViewCell, for: indexPath) as? BOInfoTableViewCell else {
                return UITableViewCell()
            }
            cell.updateContents(movieData)
            // 셀에 이미지가 존재하고 탭할 경우, 전체 이미지로 확대한다.
            if let image = dataModel.movieImage {
                DispatchQueue.main.async {
                    cell.thumnailImageView.image = image
                }
                cell.thumnailImageView.addGestureRecognizer(cellImageViewTapGestureRecognizer)
                allSizeImageView.image = image
            }
            return cell
        case TableViewSection.movieSynopsis:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.boSynopsisTableViewCell, for: indexPath) as? BOSynopsisTableViewCell else {
                return UITableViewCell()
            }
            cell.contentLabel.text = movieData.synopsis
            return cell
        case TableViewSection.movieDirectorActor:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.boActorTableViewCell, for: indexPath) as? BOActorTableViewCell else {
                return UITableViewCell()
            }
            cell.directorLabel.text = movieData.director
            cell.actorLabel.text = movieData.actor
            return cell
        case TableViewSection.movieComments:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.boCommentTableViewCell, for: indexPath) as? BOCommentTableViewCell,
                let comment = dataModel.commentsData[safeIndex: indexPath.row] else {
                    return UITableViewCell()
            }
            cell.updateContents(comment)
            // 작성자 이미지가 존재할 경우 셀에 설정한다.
            if let writerImage = comment.writerImage {
                guard let url = URL(string: writerImage) else {
                    return UITableViewCell()
                }
                imagePrefetcher?.startPrefetching(url: url) { (image) in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        cell.writerImageView.image = image
                    }
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 테이블뷰 grouped 스타일의 경우 0으로 값을 두어도 상단에
        // 빈 공간이 생기는데 CGFloat 최소 값인 아래 값을 반환하면 해결된다.
        return section == TableViewSection.movieInfo ? CGFloat.leastNormalMagnitude : 50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellIdentifier.boHeaderCell) as? BOHeaderCell else {
            return nil
        }
        switch section {
        case TableViewSection.movieSynopsis:
            headerView.titleLabel.text = "줄거리"
            headerView.composeButton.isHidden = true
        case TableViewSection.movieDirectorActor:
            headerView.titleLabel.text = "감독/출연"
            headerView.composeButton.isHidden = true
        case TableViewSection.movieComments:
            headerView.titleLabel.text = "한줄평"
            headerView.composeButton.isHidden = false
            headerView.composeButton.addTarget(self, action: #selector(composeBtnTapped), for: .touchUpInside)
        default:
            return nil
        }
        return headerView
    }
}
