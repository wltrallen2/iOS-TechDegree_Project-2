//
//  Quiz.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import Foundation
import GameKit

/// The quiz class represents a timed or untimed quiz. The timed quiz will allow for 15 second rounds and an unlimited number of questions from the question bank; however, after each question has been used once, previous questions will be repeated. For an untimed game, the quiz will allow for four unique questions.
///
/// Additionally, users can set the level for each round by setting the levelForRound property to easy, hard, or mixed using the Level enumerator. At the easy level, questions have three potential answers. For the hard level, questions have four potential answers. And for the mixed level, the qeustions are generated with either three or four answers (the number of answers chosen randomly).

class Quiz {
    
    /// An enumerator used to select the level for each quetion in the quiz, either easy, hard, or mixed.
    enum Level {
        case easy
        case hard
        case mixed
    }
    
    // MARK: - Static Constant
    // **************************************************************************************
    /// A static array of String objects used to identify the level for each game.
    static let gameLevels = ["Easy", "Hard", "Mix It Up"]
    
    // MARK: - Constants
    // **************************************************************************************
    // TODO: For future implementation, allow user to select the number of questions per round and length of timed rounds.
    let questions: [Question]
    let numAnswersForEasyLevel: Int = 3
    let numAnswersForHardLevel: Int = 4
    let numQuestionsPerRound: Int = 4
    let totalSecondsForTimedRound: Int = 15

    // MARK: - Properties
    // **************************************************************************************
    var currentQuestionIndex: Int = -1 // No question is loaded at initialization of game
    var isTimedGame: Bool = false
    var levelForRound: Level = .easy
    var timer = Timer()
    var score: Int = 0
    var secondsLeft: Int = 0
    
    
    // MARK: - Initializer
    // **************************************************************************************
    /// Initializes an instance of Quiz that has the number of questions as passed
    /// through the parameter withQuestionCount.
    init() {
        self.questions = QuestionProvider().getAllQuestionsInRandomOrder()
    }
    
    // MARK: - Methods
    // **************************************************************************************
    /// Returns a Bool that is true if the question is answered correctly, and false if the question is answered incorrectly. Additionally, isAnsweredCorrectly() increments the score by 1 if the question is answered correctly.
    func isAnsweredCorrectly(withUserResponse response: String) -> Bool {
        if questions[currentQuestionIndex].correctAnswer == response {
            score += 1
            return true
        }
        
        return false
    }
    
    /// Returns the current question
    func getCurrentQuestion() -> Question? {
        if currentQuestionIndex >= 0 && currentQuestionIndex < questions.count {
            return questions[currentQuestionIndex]
        }
        
        return nil
    }
    
    /// Returns an array of strings, one of which represents the correct answer and the others of which represent misdirectors. The number of strings in the array is determined by the quiz level.
    func getLevelledResponsesForCurrentQuestion() -> [String] {
        if let question = getCurrentQuestion() {
            let numAnswers = getNumAnswers(forLevel: levelForRound)
            return question.getCorrectAnswerAndMisdirectors(forNumberOfSlots: numAnswers)
        }
        
        return [String]()
    }
    
   /// Returns a question if there are additional questions left in the question bank, or nil if there are no additional questions left in the question bank.
    func getNextQuestion() -> Question? {
        if !hasNextQuestion () {
            return nil
        }
        
        currentQuestionIndex += 1
        return getCurrentQuestion()
    }
    
    /// Returns the number of potential answers given the passed Level parameter
    func getNumAnswers(forLevel level: Level) -> Int {
        switch level {
        case .easy: return numAnswersForEasyLevel
        case .hard: return numAnswersForHardLevel
        default: return getRandomNumberOfAnswerSlots()
        }
    }
    
    /// Returns a random number between the number of potential answers for the easy level and the number of potential answers for the hard level, inclusive.
    func getRandomNumberOfAnswerSlots() -> Int {
        let upperBound = getNumAnswers(forLevel: .hard) - getNumAnswers(forLevel: .easy)
        return getNumAnswers(forLevel: .easy) + (GKRandomSource.sharedRandom().nextInt(upperBound: upperBound))
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
    
    /// Sets the level of the round based on the string passed in as the forUserChoice parameter. If the string does not match the strings "Easy" or "Hard", the level will default to .mixed.
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
    
    /// Returns the total number of Questions that have been administered from the question bank for this quiz instance.
    func totalQuestionsAnswered() -> Int {
        return currentQuestionIndex + 1
    }
    
    // MARK: - Timer
    /// Resets the secondsLeft to the totalSecondsForTimedRound and starts the timer. The timer will fire the selector (as passed) in the passed ViewController.
    func runTimer(forTargetViewController vc: ViewController, usingSelector selector: Selector) {
        secondsLeft = totalSecondsForTimedRound
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: vc,
                                     selector: selector,
                                     userInfo: nil,
                                     repeats: true)
    }
    
    /// Updates the secondsLeft property decrementing it by one (1). If there are no seconds left, this helper method will invalidate the timer.
    ///
    /// Returns the number of seconds left in the secondsLeft property.
    @objc func updateTimer() -> Int {
        secondsLeft -= 1
        
        if secondsLeft <= 0 {
            timer.invalidate()
        }
        
        return secondsLeft
    }
}
