//
//  TopicModels.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 23/05/2019.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

struct TopicStructHandler: Codable {
	var topic: TopicStruct
}

struct TopicStruct: Codable {
	let author_id: String
	let cursus_ids: [String]
	let kind: String
	let language_id: String
	let messages_attributes: [Message]
	let name: String
	let tag_ids: [String]
}

struct TopicObtainer: Codable {
	let id: Int
	var name: String
	var author: Author
	var created_at: String
	let updated_at: String
}
