//
//  QuestionProvider.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

//TODO: Add randomizer for questions
//TODO: Add randomizer for misdirectors
//TODO: Implement algorithm to keep up with questions asked for each instance of QuestionProvider
//TODO: Incorporate QuestionProvider into controller

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
}
