//
//  BOCollectionViewController.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 16..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class BOCollectionViewController: BOMovieViewController {
    struct DataModel {
        let moviesData: MoviesData
        var image: UIImage?
    }
    
    // MARK: - Properties
    // MARK: -
    private var cellWidth = ((UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale) - 40) / 2
    private var cellInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    private var refresher = UIRefreshControl()
    private var imageCache = ImageCache(name: "BoxOfficeMain")
    private var imagePrefetcher: ImagePrefetcher?
    private var dataModels = [DataModel]()
    
    // MARK: - Action methods
    // MARK: -
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            collectionView.isHidden = true
        }
    }
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
        }
    }
    
    // MARK: - IBAction
    // MARk: -
    @IBAction private func orderBtnTapped(_ sender: Any) {
        setOrderType()
    }
    @objc private func refresh() {
        requestMovies()
    }
    
    // MAKR: - View lifecycles
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // 리프레셔 설정 및 테이블 뷰에 추가.
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refresher)
        imagePrefetcher = ImagePrefetcher(imageCache: imageCache)
        registerOrderTypeNotification()
        requestMovies()
    }
    override func viewWillAppear(_ animated: Bool) {
        changeNavigationTitle()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // 가로, 세로모드 변경시마다 컬렉션뷰를 리로드하여 레이아웃을 수정한다.
        if !dataModels.isEmpty {
            collectionView.reloadData()
        }
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
    
    // MARK: - UI methods
    // MARK: -
    /// 네이게이션 타이틀을 변경한다.
    private func changeNavigationTitle() {
        guard let orderType = RequestAPI.orderType else {
            return
        }
        switch orderType {
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
        guard let orderType = RequestAPI.orderType else {
            return
        }
        // 리프레셔가 비활성 상태이면, 액티비티 인디케이터뷰 활성화
        if !refresher.isRefreshing {
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: true)
        }
        requestAPI.requestMovies(orderType) { [weak self ] (isSuccess, data, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(error) {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.collectionView.isHidden = true
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
                    self.collectionView.reloadData()
                }
            } else {
                self.errorHandler() {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.collectionView.isHidden = true
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
                    self.collectionView.isHidden = true
                }
                return
            }
            self.dataModels[index].image = image
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                let indexPath = IndexPath(row: index, section: 0)
                if self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
                    self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                }
            }
        }
    }
}

// MARK: - Identifier constants
// MARK: -
extension BOCollectionViewController {
    struct CellIdentifier {
        static let boCollectionViewCell = "BOCollectionViewCell"
    }
    struct SegueIdentifier {
        static let goToDetailVC = "GoToDetailVCFromCollectionVC"
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
// MARK: -
extension BOCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.boCollectionViewCell, for: indexPath) as? BOCollectionViewCell,
            let dataModel = dataModels[safeIndex: indexPath.row] else {
                return UICollectionViewCell()
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let dataModel = dataModels[safeIndex: indexPath.row] {
            performSegue(withIdentifier: SegueIdentifier.goToDetailVC, sender: dataModel.moviesData)
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
// MARK: -
extension BOCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { downloadMovieImage(index: $0.row) }
    }
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            guard let dataModel = dataModels[safeIndex: indexPath.row],
                let url = URL(string: dataModel.moviesData.thumb) else {
                    return
            }
            imagePrefetcher?.cancelPrefetching(url: url)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// MARK: -
extension BOCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth * 2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInsets: UIEdgeInsets
        if UIDevice.current.orientation.isLandscape {
            // 셀 개수는 3개, 셀 크기는 유지하면서 화면에서 남은 공간을 적절히 분배.
            let inset = (UIScreen.main.bounds.width - (cellWidth * 3)) / 4
            edgeInsets = UIEdgeInsets(top: 10, left: inset, bottom: 0, right: inset)
            return edgeInsets
        }
        edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        return edgeInsets
    }
}
