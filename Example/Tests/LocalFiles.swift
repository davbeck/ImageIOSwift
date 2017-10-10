//
//  LocalFiles.swift
//  ImageIOSwift_Example
//
//  Created by David Beck on 10/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation


func local(named name: String) -> URL? {
	return Bundle.main.url(forResource: name, withExtension: nil)
}
