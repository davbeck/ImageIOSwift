//
//  MasterViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit
import ImageIOSwift


func local(named name: String) -> URL? {
	return Bundle.main.url(forResource: name, withExtension: nil)
}


struct ExampleList {
	var name: String
	var sources: [URL?]
	var detailViewControllerType: ImageSourceViewController.Type
	
	init(name: String, sources: [URL?], detailViewControllerType: ImageSourceViewController.Type = ImageSourceViewController.self) {
		self.name = name
		self.sources = sources
		self.detailViewControllerType = detailViewControllerType
	}
}


class MasterViewController: UITableViewController {
	let examples = [
		ExampleList(
			name: "Incremental Load",
			sources: [
				local(named: "interlaced.jpeg"),
				URL(string: "http://pooyak.com/p/progjpeg/jpegload.cgi?o=0"),
				local(named: "progressive.jpeg"),
				URL(string: "http://pooyak.com/p/progjpeg/jpegload.cgi?o=1"),
				local(named: "spring_1440x960.heic"),
				local(named: "animated.gif"),
				URL(string: "http://littlesvr.ca/apng/images/GenevaDrive.gif"),
				local(named: "animated.png"),
				URL(string: "http://littlesvr.ca/apng/images/GenevaDrive.png"),
			],
			detailViewControllerType: ProgressiveLoadViewController.self
		),
		ExampleList(
			name: "Animated",
			sources: [
				local(named: "animated.gif"),
				local(named: "transparent.gif"),
				local(named: "animated.png"),
				local(named: "transparent.png"),
				local(named: "starfield_animation.heic"),
				local(named: "sea1_animation.heic"),
				],
			detailViewControllerType: AnimatedViewController.self
		),
		ExampleList(
			name: "Orientations",
			sources: (1...8).map({ local(named: "Landscape_\($0).jpg") }) +
				(1...8).map({ local(named: "Portrait_\($0).jpg") })
		),
		ExampleList(
			name: "HEIC",
			sources: [
				local(named: "spring_1440x960.heic"),
				local(named: "autumn_1440x960.heic"),
				local(named: "winter_1440x960.heic"),
				local(named: "dog.heic"),
				local(named: "yard.heic"),
				local(named: "season_collection_1440x960.heic"),
				local(named: "random_collection_1440x960.heic"),
				local(named: "alpha_1440x960.heic"),
				local(named: "bird_burst.heic"),
				local(named: "grid_960x640.heic"),
				local(named: "starfield_animation.heic"),
				local(named: "sea1_animation.heic"),
				]
		),
		ExampleList(
			name: "Performance",
			sources: [
				local(named: "interlaced.jpeg"),
				local(named: "progressive.jpeg"),
				local(named: "animated.gif"),
				local(named: "animated.png"),
				local(named: "spring_1440x960.heic"),
				local(named: "autumn_1440x960.heic"),
				local(named: "winter_1440x960.heic"),
				local(named: "dog.heic"),
				local(named: "yard.heic"),
				local(named: "season_collection_1440x960.heic"),
				local(named: "random_collection_1440x960.heic"),
				local(named: "alpha_1440x960.heic"),
				local(named: "bird_burst.heic"),
				local(named: "grid_960x640.heic"),
				local(named: "starfield_animation.heic"),
				local(named: "sea1_animation.heic"),
			],
			detailViewControllerType: MetricsViewController.self
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

