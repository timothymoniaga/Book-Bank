//
//  DictionaryService.swift
//  Word Bank
//
//  Created by Timothy moniaga on 13/4/2026.
//

import Foundation

import Foundation

struct DictionaryResponse: Codable {
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let license: License
    let sourceUrls: [String]
}

// MARK: - Phonetics
struct Phonetic: Codable {
    let text: String?
    let audio: String?
    let sourceUrl: String?
    let license: License?
}

// MARK: - Meaning
struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms: [String]
    let antonyms: [String]
}

// MARK: - Definition
struct Definition: Codable {
    let definition: String
    let synonyms: [String]
    let antonyms: [String]
    let example: String?
}

// MARK: - License
struct License: Codable {
    let name: String
    let url: String
}

import Foundation

struct DictionaryService {
    
    func fetchEntry(for word: String) async throws -> [DictionaryResponse] {
        let trimmedWord = word.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let encodedWord = trimmedWord.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? trimmedWord
        
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(encodedWord)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode([DictionaryResponse].self, from: data)
        return decoded
    }
}
