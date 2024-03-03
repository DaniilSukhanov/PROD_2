//
//  SpecialOfferView.swift
//  Solution
//
//  Created by Lada Zudova on 11.02.2024.
//

import Foundation
import UIKit

public struct SpecialOfferViewModel {
    public let title: String
    public let discountValue: String
    public let description: String
    public let bundleName: String?
    public let bundleBaseColor: UIColor?
    public let bundleSecondaryColor: UIColor?
    public let image: UIImage
    public let backgroundColor: UIColor
    public let isFavorite: Bool
    public let onTap: () -> ()
    public let favouriteTap: () -> ()

    public init(title: String, discountValue: String, description: String, bundleName: String?, bundleBaseColor: UIColor?, bundleSecondaryColor: UIColor?, image: UIImage, backgroundColor: UIColor, isFavorite: Bool, onTap: @escaping () -> Void, favouriteTap: @escaping () -> Void) {
        self.title = title
        self.discountValue = discountValue
        self.description = description
        self.bundleName = bundleName
        self.bundleBaseColor = bundleBaseColor
        self.bundleSecondaryColor = bundleSecondaryColor
        self.image = image
        self.backgroundColor = backgroundColor
        self.isFavorite = isFavorite
        self.onTap = onTap
        self.favouriteTap = favouriteTap
    }
}

public protocol ISpecialOfferView: UIView {
    func configure(viewModel: SpecialOfferViewModel)
}

final class SpecialOfferView: UIView, ISpecialOfferView {
    
    // --TODO--
    private let textDescriptionView = UILabel()
    private let titleView = UILabel()
    private let bundleNameView = UIPaddingLabel()
    private let bundleDescriptionView = UILabel()
    private let buttonFavorite = UIButton()
    private let textValueView = UILabel()
    private let image = UIImageView()
    private let borderView = UIView()
    
    private var viewModel: SpecialOfferViewModel?
    private var isFavorite: Bool = false
    
    // init
    
    init() {
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // public
    
    func configure(viewModel: SpecialOfferViewModel) {
        self.viewModel = viewModel
        addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textDescriptionView)
        textDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textValueView)
        textValueView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bundleNameView)
        bundleNameView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bundleDescriptionView)
        bundleDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonFavorite)
        buttonFavorite.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 152),
            
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            textValueView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textValueView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            image.topAnchor.constraint(equalTo: titleView.safeAreaLayoutGuide.bottomAnchor),
            image.heightAnchor.constraint(equalToConstant: 86),
            image.widthAnchor.constraint(equalToConstant: 86),
            
            textDescriptionView.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 14),
            textDescriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 19.5),
            textDescriptionView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -19.5),
            textDescriptionView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -40),
            
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: bundleNameView.topAnchor, constant: -7.5),
            
            bundleNameView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 7.5),
            bundleNameView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7.5),
            bundleNameView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            bundleDescriptionView.leadingAnchor.constraint(equalTo: bundleNameView.trailingAnchor, constant: 10),
            bundleDescriptionView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 11),
            bundleDescriptionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
        
            buttonFavorite.heightAnchor.constraint(equalToConstant: 32),
            buttonFavorite.widthAnchor.constraint(equalToConstant: 32),
            buttonFavorite.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonFavorite.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonFavorite.topAnchor.constraint(equalTo: borderView.bottomAnchor),
        ])
        setupDescription(viewModel)
        setupTitleView(viewModel)
        setupButtonFavorite(viewModel)
        setupTextValueView(viewModel)
        setupBundleDescriptionView(viewModel)
        setupImage(viewModel)
        setupBoarderView(viewModel)
        setupBundleNameView(viewModel)
        setupSelf(viewModel)
    }

    @objc private func updateLike() {
        viewModel?.favouriteTap()
    }
}

private extension SpecialOfferView {
    
    func setupBoarderView(_ viewModel: SpecialOfferViewModel) {
        borderView.layer.cornerRadius = 16
        borderView.clipsToBounds = true
        borderView.layer.masksToBounds = true
        borderView.backgroundColor = viewModel.backgroundColor
    }
    
    func setupImage(_ viewModel: SpecialOfferViewModel) {
        image.image = viewModel.image
        image.contentMode = .scaleAspectFit
    }
    
    func setupSelf(_ viewModel: SpecialOfferViewModel) {
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.masksToBounds = true
        backgroundColor = #colorLiteral(red: 0.9490196109, green: 0.9490196109, blue: 0.9490196109, alpha: 1)
    }
    
    func setupDescription(_ viewModel: SpecialOfferViewModel) {
        textDescriptionView.font = .systemFont(ofSize: 12, weight: .regular)
        textDescriptionView.text = viewModel.description
        textDescriptionView.numberOfLines = 0
        textDescriptionView.textAlignment = .left
        
    }
    
    func setupTitleView(_ viewModel: SpecialOfferViewModel) {
        titleView.font = .systemFont(ofSize: 15, weight: .semibold)
        titleView.text = viewModel.title
    }
    
    func setupBundleNameView(_ viewModel: SpecialOfferViewModel) {
        bundleNameView.text = viewModel.bundleName
        bundleNameView.font = .systemFont(ofSize: 8, weight: .bold)
        bundleNameView.layer.cornerRadius = 7
        bundleNameView.clipsToBounds = true
        bundleNameView.layer.masksToBounds = true
        bundleNameView.backgroundColor = viewModel.bundleBaseColor
        bundleNameView.paddingTop = 3.5
        bundleNameView.paddingLeft = 14
        bundleNameView.paddingRight = 14
        bundleNameView.paddingBottom = 3.5
        bundleNameView.layer.borderColor = UIColor.black.cgColor
        bundleNameView.layer.borderWidth = 1
        bundleNameView.textColor = viewModel.bundleSecondaryColor
        if viewModel.bundleName == nil {
            bundleNameView.isHidden = true
        }
    }
    
    func setupBundleDescriptionView(_ viewModel: SpecialOfferViewModel) {
        bundleDescriptionView.text = "Предложение специально для вас"
        bundleDescriptionView.font = .systemFont(ofSize: 8, weight: .medium)
        bundleDescriptionView.textColor = UIColor(hexString: "9A9A9A")
        if viewModel.bundleName == nil {
            bundleDescriptionView.isHidden = true
        }
    }
    
    func setupButtonFavorite(_ viewModel: SpecialOfferViewModel) {
        buttonFavorite.layoutIfNeeded()
        if viewModel.isFavorite {
            buttonFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            buttonFavorite.tintColor = .red
        } else {
            buttonFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
            buttonFavorite.tintColor = .tintColor
        }
        buttonFavorite.layer.cornerRadius = buttonFavorite.frame.width/2
        buttonFavorite.clipsToBounds = true
        buttonFavorite.layer.masksToBounds = true
        buttonFavorite.backgroundColor = #colorLiteral(red: 0.850980401, green: 0.850980401, blue: 0.850980401, alpha: 1)
        buttonFavorite.imageView?.contentMode = .scaleAspectFit
        let action = UIAction { [weak self]  _ in
            viewModel.favouriteTap()
            guard let viewModel = self?.viewModel else {
                return
            }
            let newViewModel = SpecialOfferViewModel(
                title: viewModel.title,
                discountValue: viewModel.discountValue,
                description: viewModel.description,
                bundleName: viewModel.bundleName,
                bundleBaseColor: viewModel.bundleBaseColor,
                bundleSecondaryColor: viewModel.bundleSecondaryColor,
                image: viewModel.image,
                backgroundColor: viewModel.backgroundColor,
                isFavorite: !viewModel.isFavorite,
                onTap: viewModel.onTap,
                favouriteTap: viewModel.favouriteTap
            )
            self?.viewModel = newViewModel
            if newViewModel.isFavorite {
                self?.buttonFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self?.buttonFavorite.tintColor = .red
            } else {
                self?.buttonFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
                self?.buttonFavorite.tintColor = .tintColor
            }
        }
        buttonFavorite.addAction(action, for: .touchDown)
    }
    
    func setupTextValueView(_ viewModel: SpecialOfferViewModel) {
        textValueView.text = viewModel.discountValue
        textValueView.font = .systemFont(ofSize: 15, weight: .semibold)
    }
}

final class SpecialOfferViewTableViewCell: UITableViewCell {

    private lazy var view = SpecialOfferView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        ])

        selectionStyle = .none
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: SpecialOfferViewModel) {
        view.configure(viewModel: viewModel)
    }
}


class UIPaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
}
