//
//  PhotoCell.swift
//  PhotoList
//
//  Created by Kawoou on 30/07/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {

    // MARK: - Property

    var photo: Photo? {
        didSet {
            reset()

            guard let photo = photo else { return }
            bind(photo: photo)
        }
    }

    // MARK: - Interface

    private var imageTask: URLSessionDataTask?

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    private lazy var activityIndicator = UIActivityIndicatorView(style: .white)

    // MARK: - Private

    private func reset() {
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
        imageView.alpha = 0

        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func bind(photo: Photo) {
        guard let url = URL(string: "http://letusgo-summer-19.kawoou.kr\(photo.url)") else { return }

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()

                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self?.imageView.image = image
                UIView.animate(withDuration: 0.5) {
                    self?.imageView.alpha = 1
                }
            }
        }
        imageTask?.resume()
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Public

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .darkGray

        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)

        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
