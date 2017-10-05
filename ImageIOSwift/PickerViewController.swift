//
//  PickerViewController.swift
//  ImageService
//
//  Created by David Beck on 10/5/17.
//  Copyright © 2017 David Beck. All rights reserved.
//

import UIKit

class PickerViewController<DetailViewController: ImageSourceViewController>: UITableViewController {
	var options: [String] {
		return []
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		cell.textLabel?.text = options[indexPath.row]
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let option = options[indexPath.row]
		
		let viewController = DetailViewController(filename: option)
		let navigationController = UINavigationController(rootViewController: viewController)
		
		self.show(navigationController, sender: nil)
	}
}
