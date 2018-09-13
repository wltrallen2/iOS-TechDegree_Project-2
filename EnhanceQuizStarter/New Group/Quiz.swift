//
//  Quiz.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

class Quiz {

    let questions: [Question]
    
    var currentQuestionIndex: Int = -1 // No question is loaded at initialization of game
    var score: Int = 0
    
    
    /// Initializes an instance of Quiz that has the number of questions as passed
    /// through the parameter withQuestionCount.
    init(withQuestionCount numQuestions: Int) {
        self.questions = QuestionProvider().getSetOfRandomQuestions(withQuestionCount: numQuestions)
    }
    
    /// Initializes an instance of Quiz using all questions in the quesiton bank.
    convenience init() {
        let numQuestions = QuestionProvider().questions.count
        self.init(withQuestionCount: numQuestions)
    }
    
    /// Returns a Bool that is true is there are additional questions left in the quiz,
    /// and false if there are no additional questions left.
    func hasNextQuestion() -> Bool {
        return currentQuestionIndex + 1 < questions.count
    }
    
    ///Returns the current question
    func getCurrentQuestion() -> Question? {
        if currentQuestionIndex >= 0 {
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
        return questions[currentQuestionIndex]
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
}
