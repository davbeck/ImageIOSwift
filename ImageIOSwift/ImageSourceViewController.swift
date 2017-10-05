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
	
	required init(filename: String) {
		self.filename = filename
		
		super.init(nibName: nil, bundle: nil)
		
		self.title = filename
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - View Lifecycle
	
	lazy var imageSourceView = ImageSourceView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		imageSourceView.translatesAutoresizingMaskIntoConstraints = false
		imageSourceView.backgroundColor = .lightGray
		imageSourceView.contentMode = .scaleAspectFit
		view.addSubview(imageSourceView)
		
		NSLayoutConstraint.activate([
			imageSourceView.heightAnchor.constraint(equalTo: imageSourceView.widthAnchor),
			imageSourceView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			imageSourceView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			imageSourceView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}
}
