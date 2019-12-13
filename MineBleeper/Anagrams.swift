//
//  Anagrams.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/12/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import Foundation

class WordTracker {
    
    let charactersRecord: [Character: Int]
    let characterCount: Int
    
    var checkCount = 0
    var exhausted: Bool { checkCount == characterCount}
    var characters: [Character: Int]
    
    init(word: String) {
        var characterDict: [Character: Int] = [:]
        
        for character in word {
            if let count = characterDict[character] {
                characterDict[character] = count + 1
            } else {
                characterDict[character] = 1
            }
        }
        
        characters = characterDict
        characterCount = word.count
        charactersRecord = characterDict
    }
    
    func checkCharacter(character: Character) -> Bool {
        guard let count = characters[character] else { return false }
        
        switch count {
        case 0: characters[character] = nil; return false
        default: characters[character] = count - 1; return true
        }
    }
    
    func reset() {
        characters = charactersRecord
        checkCount = 0
    }
    
}


class Node {
    let value: Character
    var children: [Character: Node]
    var word: (string: String, count: Int)?
    var furtherWords: [String]
    
    
    init(value: Character) {
        self.value = value
        self.children = [:]
        self.furtherWords = []
    }
}

class Trie {
    
    private var rootNode: Node = Node(value: "*")
    
    func addWord(word: String) {
        let characters: [Character] = Array(word)
        var currentNode = rootNode

        for character in characters {
            currentNode.furtherWords.append(word)
            if let node = currentNode.children[character] {
                currentNode = node
            } else {
                let node = Node(value: character)
                currentNode.children[character] = node
                currentNode = node
            }
        }
        
        if let wordCount = currentNode.word {
            currentNode.word = (string: wordCount.string, count: wordCount.count + 1)
        } else {
            currentNode.word = (string: word, count: 1)
        }
    }
    
    func removeInstanceOfWord(word: String) {
        let characters: [Character] = Array(word)
        var currentNode = rootNode
        
        for character in characters {
            if let node = currentNode.children[character] {
                currentNode = node
            } else {
                return
            }
        }
        
        if let wordCount = currentNode.word, wordCount.count > 1 {
            currentNode.word = (string: wordCount.string, count: wordCount.count - 1)
        } else {
            currentNode.word = nil
        }
    }
    
    func removeWord(word: String) {
        let characters: [Character] = Array(word)
        var currentNode = rootNode
        
        for character in characters {
            if let node = currentNode.children[character] {
                currentNode = node
            } else {
                return
            }
        }
        
        currentNode.word = nil
    }
    
    func checkWordExists(word: String) -> (includedWords: [String], wordExists: Bool, wordsIncludedIn: [String]) {
        
        let characters: [Character] = Array(word)
        var currentNode = rootNode
        
        var includedWords: [String] = []
        let wordExists: Bool
        var wordsIncludedIn: [String]? = nil
        
        for character in characters {
            if let node = currentNode.children[character] {
                currentNode = node
                if let string = currentNode.word?.string {
                    includedWords.append(string)
                }
            } else {
                return (includedWords, false, [])
            }
        }
        
        wordExists = (currentNode.word?.string == word)
        if wordExists { wordsIncludedIn = currentNode.furtherWords }
        
        return (includedWords, wordExists, wordsIncludedIn ?? [])
    }
    
    func checkAnagramExists(word: String) {
        let wordTracker = WordTracker(word: word)
        var currentNode = rootNode
         
        
        
        
    }
    
    func test(wordTracker: WordTracker, node: Node) {
        
    }
    
    
}



class easy {
    class Node {
        let value: Character
        var children: [Character: Node]
        var words: [String]
        
        
        init(value: Character) {
            self.value = value
            self.children = [:]
            self.words = []
        }
    }
    
    class trie {
        private var rootNode: Node = Node(value: "*")

        func addWord(word: String) {
            let characters: [Character] = Array(word).sorted()
            var currentNode = rootNode
            
            for character in characters {
                if let node = currentNode.children[character] {
                    currentNode = node
                } else {
                    let node = Node(value: character)
                    currentNode.children[character] = node
                    currentNode = node
                }
            }
            currentNode.words.append(word)
        }
        
        func removeWord(word: String) {
            
            let characters: [Character] = Array(word).sorted()
            var currentNode = rootNode
            
            for character in characters {
                if let node = currentNode.children[character] {
                    currentNode = node
                } else {
                    return
                }
            }
            
            currentNode.words = currentNode.words.filter {$0 == word}
        }
        
        func checkAnagram(word: String) -> [String] {
            let characters: [Character] = Array(word).sorted()
            var currentNode = rootNode
            
            for character in characters {
                if let node = currentNode.children[character] {
                    currentNode = node
                } else {
                    return []
                }
            }
            
            return currentNode.words
        }
        
        
    }
}
