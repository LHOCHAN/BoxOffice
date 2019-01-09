//
//  BOTableViewController.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 16..
//  Copyright © 2018년 최영준. All rights reserved.
//


import UIKit

class BOTableViewController: BOMovieViewController {
    struct DataModel {
        let moviesData: MoviesData
        var image: UIImage?
    }
    
    // MARK: - Properties
    // MARK: -
    private let cellHeight: CGFloat = 120
    private var refresher = UIRefreshControl()
    private var imageCache = ImageCache(name: "BoxOfficeMain")
    private var imagePrefetcher: ImagePrefetcher?
    private var dataModels = [DataModel]()
    
    // MARK: - IBOutlets
    // MARK: -
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.isHidden = true
        }
    }
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
        }
    }
    
    // MARK: - Action methods
    // MARk: -
    @IBAction private func orderBtnTapped(_ sender: Any) {
        setOrderType()
    }
    @objc private func refresh() {
        requestMovies()
    }
    
    // MARK: - View lifecycles
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // 리프레셔 설정 및 테이블 뷰에 추가.
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refresher)
        imagePrefetcher = ImagePrefetcher(imageCache: imageCache)
        registerOrderTypeNotification()
        requestMovies()
    }
    override func viewWillAppear(_ animated: Bool) {
        changeNavigationTitle()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == SegueIdentifier.goToDetailVC {
            guard let moviesData = sender as? MoviesData,
                let detailVC = segue.destination as? BODetailViewController else {
                    return
            }
            detailVC.moviesData = moviesData
        }
    }
    
    // MARK: - BOMovie protocol
    // MARK: -
    override func didReceiveNotification(_ notification: Notification) {
        super.didReceiveNotification(notification)
        changeNavigationTitle()
        requestMovies()
    }
    
    // MARK: - UI method
    // MARK: -
    /// 네이게이션 타이틀을 변경한다.
    private func changeNavigationTitle() {
        switch RequestAPI.orderType {
        case .reservationRate:
            navigationItem.title = "예매율"
        case .curation:
            navigationItem.title = "큐레이션"
        case .date:
            navigationItem.title = "개봉일"
        }
    }
    
    // MARK: - HTTP/HTTPS methods
    // MARK: -
    /// 영화 데이터를 요청한다.
    private func requestMovies() {
        dataModels.removeAll()
        // 리프레셔가 비활성 상태이면, 액티비티 인디케이터뷰 활성화
        if !refresher.isRefreshing {
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: true)
        }
        requestAPI.requestMovies(RequestAPI.orderType) { [weak self ] (isSuccess, data, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(error) {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.tableView.isHidden = true
                }
            }
            if isSuccess {
                guard let movieList = data as? [MoviesData] else {
                    return
                }
                movieList.forEach { (moviesData) in
                    let dataModel = DataModel(moviesData: moviesData, image: nil)
                    self.dataModels.append(dataModel)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.errorHandler() {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.tableView.isHidden = true
                }
            }
        }
    }
    /// 영화 이미지를 요청한다.
    private func downloadMovieImage(index: Int) {
        guard let dataModel = dataModels[safeIndex: index],
            let url = URL(string: dataModel.moviesData.thumb) else {
                return
        }
        imagePrefetcher?.startPrefetching(url: url) { [weak self] (image) in
            guard let self = self else { return }
            self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
            guard let image = image else {
                self.errorHandler() {
                    self.tableView.isHidden = true
                }
                return
            }
            self.dataModels[index].image = image
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                let indexPath = IndexPath(row: index, section: 0)
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
                }
            }
        }
    }
}

// MARK: - Identifier constants
// MARK: -
extension BOTableViewController {
    struct CellIdentifier {
        static let boTableViewCell = "BOTableViewCell"
    }
    struct SegueIdentifier {
        static let goToDetailVC = "GoToDetailVCFromTableVC"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
// MARK: -
extension BOTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.boTableViewCell, for: indexPath) as? BOTableViewCell,
            let dataModel = dataModels[safeIndex: indexPath.row] else {
                return UITableViewCell()
        }
        cell.updateContents(dataModel.moviesData)
        if let image = dataModel.image {
            DispatchQueue.main.async {
                cell.thumnailImageView.image = image
            }
        } else {
            self.downloadMovieImage(index: indexPath.row)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let dataModel = dataModels[safeIndex: indexPath.row] {
            performSegue(withIdentifier: SegueIdentifier.goToDetailVC, sender: dataModel.moviesData)
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
// MARK: -
extension BOTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { downloadMovieImage(index: $0.row) }
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            guard let dataModel = dataModels[safeIndex: indexPath.row],
                let url = URL(string: dataModel.moviesData.thumb) else {
                    return
            }
            imagePrefetcher?.cancelPrefetching(url: url)
        }
    }
}
