//
//  MessageModels.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 23/05/2019.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

struct Author: Codable {
	let login: String
}

struct MessageCreationHandler: Codable {
	let id: String
	let message: Message
}

struct Message: Codable {
	let author_id: String
	let content: String
	let messageable_id: String
	let messageable_type: String
}

struct MessageObtainer: Codable {
	var id: Int
	var author: Author
	var content: String
	var created_at: String
	var updated_at: String
	var replies: [MessageObtainer?]
}
