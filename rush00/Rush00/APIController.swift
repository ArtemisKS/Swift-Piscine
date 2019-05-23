//
//  APIUsageController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

protocol APIDelegate: NSObjectProtocol {
    
}

class APIController {
    weak var delegate : APIDelegate?
    let token : String
    var login: String? = nil
    var author_id: Int? = nil
    let root: String = "https://api.intra.42.fr"
    
    init(token: String) {
        self.token = token
    }
    
    func query(params: [(String, String)] = [], url: String, body: Data? = nil, headers: [(String, String)] = [], method: String, completionHandler: @escaping (Data) -> Void) {
        var queryItems: [NSURLQueryItem] = []
        for item in params {
            queryItems.append(NSURLQueryItem(name: item.0, value: item.1))
        }
        let urlComps = NSURLComponents(string: root + url)!
        urlComps.queryItems = queryItems as [URLQueryItem]
        
        let accessRequest = NSMutableURLRequest(url: urlComps.url!)
        accessRequest.httpMethod = method
        accessRequest.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        
        for value in headers {
            accessRequest.setValue(value.1, forHTTPHeaderField: value.0)
        }
        
        if let b = body {
            accessRequest.httpBody = b
        }
        
        let task  = URLSession.shared.dataTask(with: accessRequest as URLRequest) {
            (data: Data?, urlResponse: URLResponse?, error: Error?) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            if let d = data {
                completionHandler(d)
            }
        }
        task.resume()
    }
    
    func topics(params: [(String, String)] = [], completionHandler: @escaping (Data) -> Void) {
        var updatableParams = params
        updatableParams.append(("page[size]", "100"))
        query(
            params: updatableParams,
            url: "/v2/topics",
            method: "GET",
            completionHandler: completionHandler
        )
    }
    
    func topics(author_id: String, completionHandler: @escaping (Data) -> Void) {
        let params = [("filter[author_id]", author_id)]
        topics(params: params, completionHandler: completionHandler)
    }
    
    func topics(sort: String, completionHandler: @escaping (Data) -> Void) {
        let params = [("sort", sort)]
        topics(params: params, completionHandler: completionHandler)
    }
    
    func userTopics(completionHandler: @escaping (Data) -> Void) {
        query(
            url: "/v2/me/topics",
            method: "GET",
            completionHandler: completionHandler
        )
    }
    
    func topicMessages(topic: TopicObtainer, completionHandler: @escaping (Data) -> Void) {
        query(
            url: "/v2/topics/\(topic.id)/messages",
            method: "GET",
            completionHandler: completionHandler
        )
    }

    func createTopic(topicCreate: TopicStructHandler, completionHandler: @escaping (Data) -> Void) {
        let data = try? JSONEncoder().encode(topicCreate)
        query(
            url: "/v2/topics",
            body: data,
            headers: [("Content-Type", "application/json")],
            method: "POST",
            completionHandler: completionHandler
        )
    }
    
    func createMessage(messageCreate: MessageCreationHandler, completionHandler: @escaping (Data) -> Void) {
        let data = try? JSONEncoder().encode(messageCreate)
        query(
            url: "/v2/messages",
            body: data,
            headers: [("Content-Type", "application/json")],
            method: "POST",
            completionHandler: completionHandler
        )
    }
    
    func me(completionHandler: @escaping (Data) -> Void) {
        query(
            params: [],
            url: "/v2/me",
            method: "GET",
            completionHandler: {
                d in
                do {
                    if let dic: NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        self.login = dic.value(forKey: "login") as? String
                        self.author_id = dic.value(forKey: "id") as? Int
                    }
                }
                catch (let err) {
                    print(err.localizedDescription)
                }
                completionHandler(d)
        }
        )
    }
    
    func deleteTopic(topic: TopicObtainer, completionHandler: @escaping (Data) -> Void) {
        deleteTopic(topicId: String(topic.id), completionHandler: completionHandler)
    }
    
    func deleteTopic(topicId: String, completionHandler: @escaping (Data) -> Void) {
        query(
            url: "/v2/topics/\(topicId)",
            method: "DELETE",
            completionHandler: completionHandler
        )
    }
    
    func updateTopic(topic: TopicObtainer, completionHandler: @escaping (Data) -> Void) {
        let updateData = [
            "topic": [
                "name": topic.name,
            ]
        ]
        let data = try? JSONEncoder().encode(updateData)
        query(
            url: "/v2/topics/\(topic.id)",
            body: data,
            headers: [("Content-Type", "application/json")],
            method: "PATCH",
            completionHandler: completionHandler
        )
    }
    
    func deleteMessage(message: MessageObtainer, completionHandler: @escaping (Data) -> Void) {
        query(
            url: "/v2/messages/\(message.id)",
            method: "DELETE",
            completionHandler: completionHandler
        )
    }
    
    func updateMessage(message: MessageCreationHandler, completionHandler: @escaping (Data) -> Void) {
        let data = try? JSONEncoder().encode(message.message)
        query(
            url: "/v2/messages/\(message.id)",
            body: data,
            headers: [("Content-Type", "application/json")],
            method: "PATCH",
            completionHandler: completionHandler
        )
    }
    
    func updateTopic(topic: TopicObtainer, author_id: String, completionHandler: @escaping (Data) -> Void) {
        let updateData = [
            "topic": [
                "name": topic.name,
                "author_id": author_id
            ]
        ]
        let data = try? JSONEncoder().encode(updateData)
        query(
            url: "/v2/topics/\(topic.id)",
            body: data,
            headers: [("Content-Type", "application/json")],
            method: "PATCH",
            completionHandler: completionHandler
        )
    }
}
