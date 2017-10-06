//
//  ImageSourceViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class ImageSourceViewController: UIViewController {
	let filename: String
	
	var imageSource: ImageSource? {
		didSet {
			if let oldValue = oldValue {
				NotificationCenter.default.removeObserver(self, name: nil, object: oldValue.cgImageSource)
			}
			
			updateInfo()
			imageSourceView.imageSource = imageSource
			imageView.image = imageSource?.image(at: 0)
			
			if let newValue = imageSource {
				NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: ImageSource.didUpdateData, object: newValue.cgImageSource)
			}
		}
	}
	
	required init(filename: String) {
		self.filename = filename
		
		super.init(nibName: nil, bundle: nil)
		
		self.title = filename
		
		self.automaticallyAdjustsScrollViewInsets = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - View Lifecycle
	
	lazy var scrollView = UIScrollView()
	
	lazy var imageSourceView = ImageSourceView()
	lazy var imageView = UIImageView()
	
	lazy var imagesStackView: UIStackView = UIStackView(arrangedSubviews: [
		self.imageSourceView,
		self.imageView,
	])
	
	lazy var infoStackView: UIStackView = UIStackView(arrangedSubviews: [
		self.imagesStackView
	])
	lazy var imageSizeLabel = UILabel()
	lazy var framesLabel = UILabel()
	lazy var propertiesLabel = UILabel()
	lazy var properties0Label = UILabel()
	
	private var nameLabels: [UILabel] = []
	
	func add(infoLabel: UIView, name: String) {
		let nameLabel = UILabel()
		nameLabel.text = "\(name):"
		nameLabel.textAlignment = .right
		nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
		nameLabel.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
		
		let lineView = UIStackView(arrangedSubviews: [
			nameLabel,
			infoLabel,
		])
		lineView.axis = .horizontal
		lineView.spacing = 5
		lineView.alignment = .firstBaseline
		infoStackView.addArrangedSubview(lineView)
		
		if let firstName = nameLabels.first {
			nameLabel.widthAnchor.constraint(equalTo: firstName.widthAnchor).isActive = true
		}
		nameLabels.append(nameLabel)
	}
	
	private func add(label text: String, to view: UIView) {
		let effect = UIBlurEffect(style: .dark)
		let background = UIVisualEffectView(effect: effect)
		background.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(background)
		
		let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))
		vibrancy.translatesAutoresizingMaskIntoConstraints = false
		background.contentView.addSubview(vibrancy)
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.textAlignment = .center
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		vibrancy.contentView.addSubview(label)
		
		NSLayoutConstraint.activate([
			background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			vibrancy.leadingAnchor.constraint(equalTo: background.leadingAnchor),
			vibrancy.trailingAnchor.constraint(equalTo: background.trailingAnchor),
			vibrancy.topAnchor.constraint(equalTo: background.topAnchor),
			vibrancy.bottomAnchor.constraint(equalTo: background.bottomAnchor),
			
			label.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
			label.topAnchor.constraint(equalTo: background.layoutMarginsGuide.topAnchor),
			label.bottomAnchor.constraint(equalTo: background.layoutMarginsGuide.bottomAnchor),
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceVertical = true
		view.addSubview(scrollView)
		
		imageSourceView.backgroundColor = .lightGray
		imageSourceView.contentMode = .scaleAspectFit
		add(label: "ImageSourceView", to: imageSourceView)
		
		imageView.backgroundColor = .lightGray
		imageView.contentMode = .scaleAspectFit
		add(label: "UIImageView", to: imageView)
		
		imagesStackView.axis = .horizontal
		imagesStackView.spacing = 10
		
		infoStackView.translatesAutoresizingMaskIntoConstraints = false
		infoStackView.axis = .vertical
		infoStackView.spacing = 5
		if #available(iOS 11.0, *) {
			infoStackView.setCustomSpacing(10, after: imagesStackView)
		}
		scrollView.addSubview(infoStackView)
		
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
			
			imageSourceView.heightAnchor.constraint(equalTo: imageSourceView.widthAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			
			infoStackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
			infoStackView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
		])
		
		if #available(iOS 11.0, *) {
			NSLayoutConstraint.activate([
				scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
				
				infoStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 5),
				infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -5),
			])
		} else {
			NSLayoutConstraint.activate([
				infoStackView.topAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.topAnchor),
				infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.layoutMarginsGuide.bottomAnchor),
			])
		}
		
		self.add(infoLabel: imageSizeLabel, name: "Image Size")
		self.add(infoLabel: framesLabel, name: "Frames")
		propertiesLabel.numberOfLines = 0
		self.add(infoLabel: propertiesLabel, name: "Properties")
		properties0Label.numberOfLines = 0
		self.add(infoLabel: properties0Label, name: "Properties[0]")
		
		loadImageSource()
	}
	
	func loadImageSource() {
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
		
		imageSource = ImageSource(url: url)
		
		imageView.image = UIImage(contentsOfFile: url.path)
	}
	
	@objc func updateInfo() {
		if let size = imageSource?.properties(at: 0)?.imageSize {
			imageSizeLabel.text = "\(Int(size.width))x\(Int(size.height))"
		} else {
			imageSizeLabel.text = nil
		}
		
		framesLabel.text = imageSource?.count.description
		
		propertiesLabel.text = imageSource?.properties()?.rawValue.description
		properties0Label.text = imageSource?.properties(at: 0)?.rawValue.description
	}
}
