//
//  ListViewController.swift
//  PhotoList
//
//  Created by Kawoou on 29/07/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit
import Moya

final class ListViewController: UIViewController {

    // MARK: - Constant

    private struct Constant {
        static let itemSpacing: CGFloat = 5
    }

    // MARK: - Interface

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        view.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self
        view.backgroundColor = .clear
        return view
    }()
    private lazy var flowLayout = UICollectionViewFlowLayout()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.tintColor = .darkGray
        return view
    }()

    // MARK: - Private

    private lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()

    private let provider = MoyaProvider<PhotoApi>()
    private let decoder = JSONDecoder()

    private var list: [Photo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private func request() {
        list = []
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        provider.request(.list) { [weak self] result in
            guard let ss = self else { return }

            switch result {
            case .success(let response):
                let list = try? ss.decoder.decode(PhotoResponse.self, from: response.data).list
                ss.list = list ?? []

            case .failure(let error):
                print(error)
            }

            ss.activityIndicator.isHidden = true
            ss.activityIndicator.stopAnimating()
        }
    }

    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupLayout() {
        let size = (view.bounds.width - Constant.itemSpacing * 3) / 2
        flowLayout.sectionInset = UIEdgeInsets(
            top: Constant.itemSpacing,
            left: Constant.itemSpacing,
            bottom: Constant.itemSpacing,
            right: Constant.itemSpacing
        )
        flowLayout.minimumInteritemSpacing = Constant.itemSpacing
        flowLayout.minimumLineSpacing = Constant.itemSpacing
        flowLayout.itemSize = CGSize(width: size, height: size)
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapAddButton(_:)))
    }

    private func openLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }

        picker.sourceType = .camera
        present(picker, animated: true)
    }

    // MARK: - Action

    @objc func tapAddButton(_ target: UIBarButtonItem) {
        let alertController = UIAlertController(title: "이미지 업로드", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(
            UIAlertAction(title: "사진앨범", style: .default) { [weak self] action in
                self?.openLibrary()
            }
        )
        alertController.addAction(
            UIAlertAction(title: "카메라", style: .default) { [weak self] action in
                self?.openCamera()
            }
        )
        alertController.addAction(
            UIAlertAction(title: "취소", style: .cancel)
        )

        present(alertController, animated: true)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List"

        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        setupLayout()
        setupConstraints()
        setupNavigationItem()
        request()
    }
}

extension ListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }

        if 0 <= indexPath.item, list.count > indexPath.item {
            cell.photo = list[indexPath.item]
        } else {
            cell.photo = nil
        }

        return cell
    }
}

extension ListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            provider.request(.upload(fileUrl: url)) { [weak self] result in
                self?.request()
            }
        }

        dismiss(animated: true, completion: nil)
    }
}
