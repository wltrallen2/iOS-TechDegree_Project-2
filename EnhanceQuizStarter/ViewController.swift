//
//  ViewController.swift
//  EnhanceQuizStarter
//
//  Created by Pasan Premaratne on 3/12/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//
//  Refractored by Walter Allen on 9/5/18.

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    // MARK: - Structs
    
    struct GameColors {
        static let blue = UIColor(red: 0.0, green: 145/255.0, blue: 183/255.0, alpha: 1.0)
        static let red = UIColor(red: 214.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        static let green = UIColor(red: 0.0, green: 118/255.0, blue: 0, alpha: 1.0)
    }
    
    // MARK: - Properties
    
    var quiz: Quiz?
    var answerButtons = [UIButton]()
    var timer = Timer()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var answerButtonStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTimedButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel.isHidden = true
        playButton.layer.cornerRadius = 8
        playTimedButton.layer.cornerRadius = 8
        for subview in answerButtonStackView.arrangedSubviews {
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 8
                answerButtons.append(button)
            }
        }
        
        GameSound(forResource: "GameSound", ofType: "wav").play()
        
        questionLabel.text = "Welcome to Random Trivia!"
        responseLabel.text = ""
        setOptions()
    }
    
    
    // MARK: - Helpers: Pre-Game
    
    // TODO: Finish documentation and comments and clean up code before submitting.
    func loadQuiz() {
        quiz = Quiz()
    }

    func setOptions() {
        promptForTimedMode()
        
        // promptForLevel() will be called when a user taps the timed mode button of their choice
    }
    
    func promptForLevel() {
        responseLabel.text = "What level game would you like to play?"
        responseLabel.isHidden = false
        
        playButton.isHidden = true
        playTimedButton.isHidden = true

        let gameOptions = Quiz.gameLevels
        for button in answerButtons {
            let buttonIndex = answerButtons.index(of: button)!
            if buttonIndex < gameOptions.count {
                button.removeTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(chooseLevel(_:)), for: .touchUpInside)
                button.setTitle(gameOptions[buttonIndex], for: .normal)
                enableAndFormat(button: button)
            } else {
                button.isHidden = true
            }
        }
        
        // runGame() will be called from the chooseLevel(_ :) target action
    }
    
    func promptForTimedMode() {
        for button in answerButtons {
            button.isHidden = true
        }
        
        playButton.isHidden = false
        playTimedButton.isHidden = false
    }
    
    // MARK: - Helpers: Timer
    func runTimer() {
        quiz?.runTimer(forTargetViewController: self,
                       usingSelector: #selector(updateTimer))
        updateTimerText()
        timerLabel.isHidden = false
    }
    
    func updateTimerText() {
        timerLabel.text = "\(quiz!.secondsLeft)"
    }
    
    // MARK: - Helpers: Game
    func enableAndFormat(button: UIButton) {
        button.backgroundColor = GameColors.blue
        button.alpha = 1.0
        button.isEnabled = true
        button.isHidden = false
    }
    
    func dimAnswerButtons() {
        for button in answerButtons {
            button.alpha = 0.25
            button.isEnabled = false
        }
    }
    
    func displayQuestion() {
        if let question = quiz?.getNextQuestion() {
            responseLabel.isHidden = true
            questionLabel.text = question.prompt
            
            let responses = quiz!.getLevelledResponsesForCurrentQuestion()
            
            for button in answerButtons {
                if let buttonIndex = answerButtons.index(of: button) {
                    if buttonIndex < responses.count {
                        button.setTitle(responses[buttonIndex], for: UIControlState.normal)
                        button.backgroundColor = GameColors.blue
                        enableAndFormat(button: button)
                    } else {
                        button.isHidden = true
                    }
                }
            }
        }
    }
    
    func displayScore() {
        // Hide the answer buttons
        for button in answerButtons {
            button.isHidden = true
        }
        
        questionLabel.text = "Game over!"
        responseLabel.text = "You correctly answered \(quiz!.score) out of \(quiz!.totalQuestionsAnswered()) questions!"
        responseLabel.isHidden = false
        
        setOptions()
    }
    
    
    func highlightCorrectAnswer() {
        if let correctAnswer = quiz?.getCurrentQuestion()?.correctAnswer {
            for button in answerButtons {
                if button.titleLabel?.text == correctAnswer {
                    button.backgroundColor = GameColors.green
                    button.alpha = 1.0
                }
            }
        }
    }
    
    func nextRound() {
        if quiz != nil && quiz!.hasNextQuestion() {
            displayQuestion()   // Continue game.
        } else {
            displayScore()      // Game is over.
        }
    }
    
    func loadNextRound(delay seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func runGame() {
        playButton.isHidden = true
        playTimedButton.isHidden = true
        
        if quiz!.isTimedGame {
            runTimer()
        }
        
        GameSound(forResource: "GameSound", ofType: "wav").play()
        
        displayQuestion()
    }

    // MARK: - Actions
    
    @objc func chooseLevel(_ sender: UIButton) {
        if let userChoice = sender.titleLabel?.text {
            quiz!.setLevel(forUserChoice: userChoice)
        }
        
        for button in answerButtons {
            button.removeTarget(self,
                                action: #selector(chooseLevel(_:)),
                                for: .touchUpInside)
            button.addTarget(self,
                             action: #selector(checkAnswer(_:)),
                             for: .touchUpInside)
        }

        runGame()
    }
    
    @objc func checkAnswer(_ sender: UIButton) {
        if let userResponse = sender.titleLabel?.text {
            dimAnswerButtons()
            sender.alpha = 1.0
            
            if quiz != nil && quiz!.isAnsweredCorrectly(withUserResponse: userResponse) {
                responseLabel.text = "🎉🎉🎉 Correct! 🎉🎉🎉"
                GameSound(forResource: "Bell", ofType: "wav").play()
            } else {
                responseLabel.text = "😣😖😫 Sorry! Wrong answer! 😫😖😣"
                GameSound(forResource: "Buzz", ofType: "wav").play()
                sender.backgroundColor = GameColors.red
            }
            
            highlightCorrectAnswer()
            responseLabel.isHidden = false
        }

        loadNextRound(delay: 2)
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
        loadQuiz()
        quiz!.isTimedGame = false
        promptForLevel()
    }
    
    @IBAction func playTimedGame(_ sender: UIButton) {
        loadQuiz()
        quiz!.isTimedGame = true
        updateTimerText()
        promptForLevel()
    }
    
    @objc func updateTimer() {
        if quiz!.updateTimer() <= 0 {
            displayScore()
            timerLabel.isHidden = true
        }
        
        updateTimerText()
    }
}
