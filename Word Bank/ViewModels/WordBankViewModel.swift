//
//  WordBankViewModel.swift
//  Word Bank
//
//  Created by Timothy moniaga on 13/4/2026.
//

import Foundation
import Combine

final class WordBankViewModel: ObservableObject {
    @Published var words : [Word] = []
    
    
    func addWord(_ word: Word) {
        words.append(word)
    }
    
    func removeWord(_ word: Word) {
        
    }
}
