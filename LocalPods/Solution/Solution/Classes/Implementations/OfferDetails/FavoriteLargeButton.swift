//
//  FavoriteLargeButton.swift
//  Solution
//
//  Created by Genrikh Beraylik on 14.02.2024.
//

import UIKit

public protocol IFavoriteLargeButton: UIView {
    func configure(isFavorite: Bool, action: @escaping () -> Void)
}

final class FavoriteLargeButton: UIView, IFavoriteLargeButton {
    
    // UI
    
    private var favoriteAction: (() -> Void)?
    private let titleView = {
        let view = UILabel()
        view.text = "Добавить в избранное"
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    private let image = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()
    
    // init
    
    init() {
        super.init(frame: .zero)        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // public
    
    func configure(isFavorite: Bool, action: @escaping () -> Void) {
        if isFavorite {
            image.image = UIImage(systemName: "heart.fill")
        } else {
            image.image = UIImage(systemName: "heart")
        }
        favoriteAction = action
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFavoriteTap)))
    }
    
    // private
    
    @objc private func handleFavoriteTap() {
        favoriteAction?()
    }
    
    func setupUI() {
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            image.heightAnchor.constraint(equalToConstant: 24),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
        
        setupSelf()
    }
    
    func setupSelf() {
        backgroundColor = #colorLiteral(red: 0.5774894953, green: 0.8423841596, blue: 0.3632492423, alpha: 1)
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
}

