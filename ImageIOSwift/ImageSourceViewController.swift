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
	
	lazy var infoStackView = UIStackView()
	lazy var imageSizeLabel = UILabel()
	lazy var framesLabel = UILabel()
	
	private var nameLabels: [UILabel] = []
	
	func add(infoLabel: UIView, name: String, at index: Int? = 0) {
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
		
		if let index = index {
			infoStackView.insertArrangedSubview(lineView, at: index)
		} else {
			infoStackView.addArrangedSubview(lineView)
		}
		
		if let firstName = nameLabels.first {
			nameLabel.widthAnchor.constraint(equalTo: firstName.widthAnchor).isActive = true
		}
		nameLabels.append(nameLabel)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceVertical = true
		view.addSubview(scrollView)
		
		imageSourceView.translatesAutoresizingMaskIntoConstraints = false
		imageSourceView.backgroundColor = .lightGray
		imageSourceView.contentMode = .scaleAspectFit
		scrollView.addSubview(imageSourceView)
		
		infoStackView.translatesAutoresizingMaskIntoConstraints = false
		infoStackView.axis = .vertical
		infoStackView.spacing = 5
		scrollView.addSubview(infoStackView)
		
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
			
			imageSourceView.heightAnchor.constraint(equalTo: imageSourceView.widthAnchor),
			imageSourceView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
			imageSourceView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
			
			infoStackView.leadingAnchor.constraint(equalTo: imageSourceView.leadingAnchor),
			infoStackView.trailingAnchor.constraint(equalTo: imageSourceView.trailingAnchor),
			infoStackView.topAnchor.constraint(equalTo: imageSourceView.bottomAnchor, constant: 8),
		])
		
		if #available(iOS 11.0, *) {
			NSLayoutConstraint.activate([
				scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
				
				imageSourceView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 5),
				infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -5),
			])
		} else {
			NSLayoutConstraint.activate([
				imageSourceView.topAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.topAnchor),
				infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.layoutMarginsGuide.bottomAnchor),
			])
		}
		
		self.add(infoLabel: imageSizeLabel, name: "Image Size", at: nil)
		self.add(infoLabel: framesLabel, name: "Frames", at: nil)
		
		loadImageSource()
	}
	
	func loadImageSource() {
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
		
		imageSource = ImageSource(url: url)
	}
	
	@objc func updateInfo() {
		if let size = imageSource?.properties(at: 0)?.imageSize {
			imageSizeLabel.text = "\(Int(size.width))x\(Int(size.height))"
		} else {
			imageSizeLabel.text = nil
		}
		
		framesLabel.text = imageSource?.count.description
		
		if let properties = imageSource?.properties() {
			print("properties: \(properties)")
		}
		if let properties = imageSource?.properties(at: 0) {
			print("properties[0]: \(properties)")
		}
	}
}
