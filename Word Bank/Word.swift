//
//  Item.swift
//  Word Bank
//
//  Created by Timothy moniaga on 12/4/2026.
//

import Foundation
import SwiftData


@Model
final class Word {
    var timestamp: Date
    var word: String
    var definitions: [String]
    var mainDefinition: String
    var synonyms: [String]
    var notes: String?
    var partOfSpeech: String
    var example: String

    init(timestamp: Date, word: String, definitions: [String], mainDefinition: String, synonyms: [String], notes: String? = nil, partOfSpeech: String, example: String) {
        self.timestamp = timestamp
        self.word = word
        self.definitions = definitions
        self.mainDefinition = mainDefinition
        self.synonyms = synonyms
        self.notes = notes
        self.partOfSpeech = partOfSpeech
        self.example = example
    }
}

