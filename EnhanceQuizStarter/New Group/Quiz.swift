//
//  Quiz.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import Foundation
import GameKit

class Quiz {
    
    enum Level {
        case easy
        case hard
        case mixed
    }
    
    static let gameLevels = ["Easy", "Hard", "Mix It Up"]

    let questions: [Question]
    
    // TODO: For future implementation, allow user to select the number of questions per round and length of timed rounds
    let numQuestionsPerRound: Int = 4
    let totalSecondsForTimedRound: Int = 15
    
    var levelForRound: Level = .easy
    var isTimedGame: Bool = false
    var timer = Timer()
    var secondsLeft: Int = 0
    var currentQuestionIndex: Int = -1 // No question is loaded at initialization of game
    var score: Int = 0
    
    
    /// Initializes an instance of Quiz that has the number of questions as passed
    /// through the parameter withQuestionCount.
    init() {
        self.questions = QuestionProvider().getAllQuestionsInRandomOrder()
    }
    
    /// Returns a Bool that is true is there are additional questions left in the quiz,
    /// and false if there are no additional questions left.
    func hasNextQuestion() -> Bool {
        let nextQuestionIndex = currentQuestionIndex + 1
        if (isTimedGame && secondsLeft > 0) || nextQuestionIndex < numQuestionsPerRound {
            return nextQuestionIndex < questions.count
        }
        
        return false
            
    }
    
    ///Returns the current question
    func getCurrentQuestion() -> Question? {
        if currentQuestionIndex >= 0 && currentQuestionIndex < questions.count {
            return questions[currentQuestionIndex]
        }
        
        return nil
    }
    
    /// Returns a question if there are additional questions left in the question bank,
    /// or nil if there are no additional questions left in the question bank.
    func getNextQuestion() -> Question? {
        if !hasNextQuestion () {
            return nil
        }
        
        currentQuestionIndex += 1
        return getCurrentQuestion()
    }
    
    func getLevelledResponsesForCurrentQuestion() -> [String] {
        if let question = getCurrentQuestion() {
            let numAnswers = getNumAnswers(forLevel: levelForRound)
            return question.getCorrectAnswerAndMisdirectors(forNumberOfSlots: numAnswers)
        }
        
        return [String]()
    }
    
    func getNumAnswers(forLevel level: Level) -> Int {
        switch level {
        case .easy: return 3
        case .hard: return 4
        default: return getRandomNumberOfAnswerSlots()
        }
    }
    
    func getRandomNumberOfAnswerSlots() -> Int {
        return 3 + (GKRandomSource.sharedRandom().nextInt(upperBound: 2))
    }
    
    func setLevel(forUserChoice level: String) {
        switch level {
        case "Easy":
            levelForRound = .easy
        case "Hard":
            levelForRound = .hard
        default:
            levelForRound = .mixed
        }
    }
    
    func totalQuestionsAnswered() -> Int {
        return currentQuestionIndex + 1
    }
    
    /// Returns a Bool that is true if the question is answered correctly, and
    /// false if the question is answered incorrectly. Additionally, isAnsweredCorrectly()
    /// increments the score by 1 if the question is answered correctly.
    func isAnsweredCorrectly(withUserResponse response: String) -> Bool {
        if questions[currentQuestionIndex].correctAnswer == response {
            score += 1
            return true
        }

        return false
    }
    
    // MARK: - Timer
    
    func runTimer(forTargetViewController vc: ViewController, usingSelector selector: Selector) {
        secondsLeft = totalSecondsForTimedRound
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: vc,
                                     selector: selector,
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func updateTimer() -> Int {
        secondsLeft -= 1
        
        if secondsLeft <= 0 {
            timer.invalidate()
        }
        
        return secondsLeft
    }
}
