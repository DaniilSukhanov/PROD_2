//
//  OfferHeaderView.swift
//  Solution
//
//  Created by Genrikh Beraylik on 14.02.2024.
//

import UIKit

public protocol IOfferHeaderView: UIView {
    func configure(value: String, text: String, image: UIImage, color: UIColor)
}

final class OfferHeaderView: UIView, IOfferHeaderView {
    
    // UI
    
    private let image = UIImageView()
    private let valueView = UILabel()
    private let textView = UILabel()
    
    // init
    
    init() {
        super.init(frame: .zero)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // public
    
    func configure(value: String, text: String, image: UIImage, color: UIColor) {
        valueView.font = .systemFont(ofSize: 36, weight: .bold)
        textView.font = .systemFont(ofSize: 24, weight: .bold)
        textView.numberOfLines = 0
        textView.text = text
        valueView.text = value
        self.image.contentMode = .scaleAspectFit
        self.image.image = image
        backgroundColor = color
        
    }
    
    // private
    
    private func configureUI() {
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueView)
        valueView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 16),
            image.heightAnchor.constraint(equalToConstant: 122),
            image.widthAnchor.constraint(equalToConstant: 122),
            
            valueView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueView.bottomAnchor.constraint(equalTo: textView.topAnchor)
        ])
    }
}

