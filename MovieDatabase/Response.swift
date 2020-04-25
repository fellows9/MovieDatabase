//
//  Response.swift
//  MovieDatabase
//
//  Created by Steven Fellows on 4/24/20.
//  Copyright © 2020 Steven Fellows. All rights reserved.
//

import Foundation

struct Response: Codable {
    var response: String
    var search: [Show]?
    var totalResults: String?
    var errorString: String?
    
    var reponseSucceeded: Bool {
        return response == "True"
    }
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case search = "Search"
        case totalResults = "totalResults"
        case errorString = "Error"
    }

    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(String.self, forKey: .response)
        search = try container.decodeIfPresent([Show].self, forKey: .search)
        totalResults = try container.decodeIfPresent(String.self, forKey: .totalResults)
        errorString = try container.decodeIfPresent(String.self, forKey: .errorString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response, forKey: .response)
        try container.encodeIfPresent(search, forKey: .search)
        try container.encodeIfPresent(totalResults, forKey: .totalResults)
        try container.encodeIfPresent(errorString, forKey: .errorString)
    }


}

enum showType: String, Codable {
    case movie
    case series
    case none
}

struct Show: Codable {
    var year: String = ""
    var type: showType = .none
    var title: String = ""
    var imdbID: String = ""
    var posterURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case year = "Year"
        case type = "Type"
        case title = "Title"
        case imdbID = "imdbID"
        case posterURL = "Poster"
    }
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        year = try container.decodeIfPresent(String.self, forKey: .year) ?? ""
        type = try container.decodeIfPresent(showType.self, forKey: .type) ?? .none
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        imdbID = try container.decodeIfPresent(String.self, forKey: .imdbID) ?? ""
        posterURL = try container.decodeIfPresent(URL.self, forKey: .posterURL)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(year, forKey: .year)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(imdbID, forKey: .imdbID)
        try container.encodeIfPresent(posterURL, forKey: .posterURL)
    }
}
