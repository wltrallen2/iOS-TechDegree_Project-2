//
//  QuestionProvider.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//


import GameKit

class QuestionProvider {
    let questions = [
        Question(prompt: "This was the only president to server more than two consecutive terms",
                 correctAnswer: "Franklin D. Roosevelt",
                 misdirectors: ["George Washington",
                                "Woodrow Wilson",
                                "Andrew Jackson"]),
        Question(prompt: "Which of the following countries has the most residents",
                 correctAnswer: "Nigeria",
                 misdirectors: ["Russia",
                                "Iran",
                                "Vietnam"]),
        Question(prompt: "In what year was the United Nations founded",
                 correctAnswer: "1945",
                 misdirectors: ["1918",
                                "1919",
                                "1954"]),
        Question(prompt: "The Titanic departed from the United Kingdom. Where was it supposed to arrive?",
                 correctAnswer: "New York City",
                 misdirectors: ["Paris",
                                "Washington, D. C.",
                                "Boston"]),
        Question(prompt: "Which nation produces the most oil?",
                 correctAnswer: "Canada",
                 misdirectors: ["Iran",
                                "Iraq",
                                "Brazil"]),
        Question(prompt: "Which country has most recently won consecutive World Cups in Soccer?",
                 correctAnswer: "Brazil",
                 misdirectors: ["Italy",
                                "Argentina",
                                "Spain"]),
        Question(prompt: "Which of the following rivers is longest?",
                 correctAnswer: "Mississippi",
                 misdirectors: ["Yangtze",
                                "Congo",
                                "Mekong"]),
        Question(prompt: "Which city is the oldest?",
                 correctAnswer: "Mexico City",
                 misdirectors: ["Cape Town",
                                "San Juan",
                                "Sydney"]),
        Question(prompt: "Which country was the first to allow women to vote in national elections?",
                 correctAnswer: "Poland",
                 misdirectors: ["United States",
                                "Sweden",
                                "Senegal"]),
        Question(prompt: "Which of these countries won the most medals in the 2012 Summer Games?",
                 correctAnswer: "Great Britain",
                 misdirectors: ["France",
                                "Germany",
                                "Japan"])
    ]
    
    /// Returns a set of unique questions from the question bank. The number of questions
    /// returned is based on the withQuestionCount parameter.
    func getSetOfRandomQuestions(withQuestionCount numQuestions: Int) -> [Question] {
        // Returns the full questions array if the number of questions requested
        // is equal to or greater than the number of questions in the bank.
        if numQuestions >= questions.count {
            return questions
        }
        
        // Else, creates an empty Question array and an array to keep track
        // of the indices of each question that will be added to the new array.
        var questionArray = [Question]()
        
        let numTotalQuestions = questions.count
        var questionIndices = [Int]()
        
        /* Generates a random number between 0 and the number of questions less one.
         * Then, checks to see if that question has already been used from the question bank.
         * If so, the index is modified until it matches a question that has not been added.
         * The unique question is added to the new question array and the index of that
         * question is added to the indices array.
         */
        for _ in 0...numQuestions {
            var randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: numTotalQuestions)
            while questionIndices.contains(randomIndex) {
                randomIndex += 1
                if randomIndex >= numTotalQuestions {
                    randomIndex = 0
                }
            }
            
            questionArray.append(questions[randomIndex])
            questionIndices.append(randomIndex)
        }
        
        return questionArray
    }
}
