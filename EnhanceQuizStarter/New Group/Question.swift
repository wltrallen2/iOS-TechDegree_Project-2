//
//  Question.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import GameKit

/// A struct representing a trivia question. The struct consists of a prompt, the correct answer, and an array of incorrect answers.
struct Question {
    let prompt: String
    let correctAnswer: String
    let misdirectors: [String]
    
    // MARK: - Methods
    // **************************************************************************************
    /// Returns a string of arrays which includes the correct answer and enough misdirectors to fill the remaining number of requested slots. If there are not enough unique misdirectors in the misdirectors array, this method will return duplicate misdirectors to avoid returning empty strings or an array that doesn't contain enough items.
    func getCorrectAnswerAndMisdirectors(forNumberOfSlots slots: Int) -> [String] {
        var responses = [String]()
        var useIndices = [Int]()
        
        for _ in 0..<slots {
            var randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: slots)
            while useIndices.contains(randomNumber) {
                randomNumber += 1
                if randomNumber >= slots {
                    randomNumber = 0
                }
            }
            
            if randomNumber == slots - 1 {
                responses.append(correctAnswer)
            } else {
                while randomNumber >= misdirectors.count {
                    randomNumber /= 2
                }
                responses.append(misdirectors[randomNumber])
            }
            
            useIndices.append(randomNumber)
        }
        
        return responses
    }
}
