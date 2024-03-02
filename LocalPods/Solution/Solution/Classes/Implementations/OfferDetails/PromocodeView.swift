//
//  PromocodeView.swift
//  Solution
//
//  Created by Genrikh Beraylik on 14.02.2024.
//

import UIKit

public protocol IPromocodeView: UIView {
    func configure(code: String)
}

final class PromocodeView: UIView, IPromocodeView {
    
    // UI
    
    private let title = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.text = "Промокод"
        return view
    }()
    private let promocode = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    private let image = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "rectangle.portrait.on.rectangle.portrait")
        view.tintColor = .black
        return view
    }()
    
    // init
    
    init() {
        super.init(frame: .zero)
        
        isHidden = true
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // public
    
    func configure(code: String) {
        isHidden = false
        promocode.text = code
    }
    
}

private extension PromocodeView {
    func setupUI() {
        addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(promocode)
        promocode.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            title.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            
            image.heightAnchor.constraint(equalToConstant: 17),
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            image.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            promocode.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -8),
            promocode.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            promocode.topAnchor.constraint(equalTo: topAnchor, constant: 11),
        ])
        
        setupSelf()
    }
    
    func setupSelf() {
        backgroundColor = #colorLiteral(red: 0.9215685725, green: 0.9215685725, blue: 0.9215685725, alpha: 1)
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
}
