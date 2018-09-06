//
//  Question.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import GameKit

struct Question {
    let prompt: String
    let correctAnswer: String
    let misdirectors: [String]
    
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
