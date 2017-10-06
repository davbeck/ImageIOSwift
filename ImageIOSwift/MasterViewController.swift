//
//  MasterViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit


struct ExampleList {
	var name: String
	var filenames: [String]
	var detailViewControllerType: ImageSourceViewController.Type
	
	init(name: String, filenames: [String], detailViewControllerType: ImageSourceViewController.Type = ImageSourceViewController.self) {
		self.name = name
		self.filenames = filenames
		self.detailViewControllerType = detailViewControllerType
	}
}


class MasterViewController: UITableViewController {
	let examples = [
		ExampleList(
			name: "Incremental Load",
			filenames: [
				"interlaced.jpeg",
				"progressive.jpeg",
				"spring_1440x960.heic",
				"animated.gif",
				"animated.png",
			],
			detailViewControllerType: ProgressiveLoadViewController.self
		),
		ExampleList(
			name: "Animated",
			filenames: [
				"animated.gif",
				"transparent.gif",
				"animated.png",
				"transparent.png",
				"starfield_animation.heic",
				"sea1_animation.heic",
				],
			detailViewControllerType: AnimatedViewController.self
		),
		ExampleList(
			name: "Orientations",
			filenames: (1...8).map({ "Landscape_\($0).jpg" }) +
				(1...8).map({ "Portrait_\($0).jpg" })
		),
		ExampleList(
			name: "HEIC",
			filenames: [
				"spring_1440x960.heic",
				"autumn_1440x960.heic",
				"winter_1440x960.heic",
				"dog.heic",
				"yard.heic",
				"season_collection_1440x960.heic",
				"random_collection_1440x960.heic",
				"alpha_1440x960.heic",
				"bird_burst.heic",
				"grid_960x640.heic",
				"starfield_animation.heic",
				"sea1_animation.heic",
			]
		),
	]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = true
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return examples.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
		cell.textLabel?.text = examples[indexPath.row].name
		cell.accessoryType = .disclosureIndicator
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let example = examples[indexPath.row]
		
		let viewController = PickerViewController(example: example)
		
		self.show(viewController, sender: nil)
	}
}

