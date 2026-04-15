//
//  AddWordViewModel.swift
//  Word Bank
//
//  Created by Timothy moniaga on 13/4/2026.
//

import Foundation
import Combine
import SwiftData

final class AddWordViewModel: ObservableObject {
    
    @Published var query = ""
    @Published var dictionaryResponses: [DictionaryResponse] = []
//    @Published var definitions: [String] = []
    @Published var selectedDefinition: String?
    @Published var mainDefinitions = [String: [String]]()
    
    private let service = DictionaryService()
    
    var sortedPartsOfSpeech: [String] {
        let priority: [String: Int] = [
            "noun": 0,
            "verb": 1,
            "adjective": 2,
            "adverb": 3
        ]

        return mainDefinitions.keys.sorted { lhs, rhs in
            let lhsPriority = priority[lhs.lowercased(), default: 999]
            let rhsPriority = priority[rhs.lowercased(), default: 999]

            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }

            return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }
    
    
    func getMainDefinitions() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        
        guard !trimmed.isEmpty else {
            dictionaryResponses = []
            mainDefinitions = [:]
//            definitions = []
            return
        }
        
        mainDefinitions = [:]
        selectedDefinition = nil
        
        Task {
            do {
                let fetchedDictionaryResponses = try await service.fetchEntry(for: trimmed)
                dictionaryResponses = fetchedDictionaryResponses
                
                
                let firstEntityMeaning = fetchedDictionaryResponses.first?.meanings ?? []
                
                for meaning in firstEntityMeaning {
                    for definition in meaning.definitions {
                        mainDefinitions[meaning.partOfSpeech, default: []].append(definition.definition)
                    }
                }
            } catch {
                if (mainDefinitions.isEmpty) {
                    mainDefinitions = ["": ["Could not find word or word was spelt incorrectly"]]
                }
            }
        }
    }
    
    
    func addWord(context: ModelContext) {
        
        var definitions = dictionaryResponses.flatMap { entry in
            entry.meanings.flatMap { meaning in
                meaning.definitions.map(\.definition)
            }
        }
        
//        var synonms = extractSynonyms(from: dictionaryResponses.first ?? nil)
        let definitionAndMeaning = getDefinitionAndMeaning()!
                
        let newWord = Word(
            timestamp: Date(),
            word: query,
            definitions: definitions,
            mainDefinition: selectedDefinition ?? definitions.first ?? "",
            synonyms: definitionAndMeaning.meaning.synonyms,
            notes: "",
            partOfSpeech: definitionAndMeaning.meaning.partOfSpeech ,//from main definitions key
            example: definitionAndMeaning.definition.example ?? "No example available."
        )
        
        context.insert(newWord)
    }
    
    func getDefinitionAndMeaning() -> (definition: Definition, meaning: Meaning)? {
        guard let selectedDefinition else { return nil }
        
        guard let entry = dictionaryResponses.first else { return nil }
        
        for meaning in entry.meanings {
            if let def = meaning.definitions.first(where: { $0.definition == selectedDefinition }) {
                return (def, meaning)
            }
        }
        
        return nil
    }
    
    func deleteWord(_ word: Word, context: ModelContext) {
        context.delete(word)
    }
    
    
//    func extractKeyFromDefinitionDict() -> String{
//        guard let selectedDefinition else {
//            fatalError("No definition selected")
//        }
//        
//        let meanings = dictionaryResponses.first?.meanings ?? []
//        
//        let selectedPartOfSpeech = "test"
//        for meaning in dictionaryResponses.first!.meanings {
//            if meaning.definitions.contains(where: { $0.definition == selectedDefinition }) {
//                
//            }
//        }
//        
//        return ""
//    }
//    
    private func extractSynonyms(from entry: DictionaryResponse) -> [String] {
        let allSynonyms = entry.meanings.flatMap { meaning in
            meaning.synonyms + meaning.definitions.flatMap { $0.synonyms }
        }
        
        return Array(Set(allSynonyms))
    }
    
    
    
//    func getAllDefinitions() {
//        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !trimmed.isEmpty else {
//            dictionaryResponses = []
//            definitions = []
//            return
//        }
//        
//        Task {
//            do {
//                let fetchedDictionaryResponses = try await service.fetchEntry(for: trimmed)
//                dictionaryResponses = fetchedDictionaryResponses
//                
//                definitions = fetchedDictionaryResponses.flatMap { entry in
//                    entry.meanings.flatMap { meaning in
//                        meaning.definitions.map(\.definition)
//                    }
//                }
//            } catch {
//                definitions = ["Could not find word or word was spelt incorrectly"]
//            }
//        }
//    }
    
    

    
}
