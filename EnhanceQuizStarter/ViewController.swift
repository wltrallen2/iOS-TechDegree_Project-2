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
    
    // MARK: - Enums
    
    enum Level {
        case easy
        case hard
        case mixed
    }
    
    struct GameColors {
        static let blue = UIColor(red: 0.0, green: 145/255.0, blue: 183/255.0, alpha: 1.0)
        static let red = UIColor(red: 214.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        static let green = UIColor(red: 0.0, green: 118/255.0, blue: 0, alpha: 1.0)
    }
    
    // MARK: - Constants
    // TODO: For future implementation, allow user to select the number of questions per round and length of timed rounds
    let numQuestionsPerRound: Int = 4
    let totalSecondsForTimedRound: Int = 15
    
    // MARK: - Properties
    
    let questionsPerRound = 4
    var quiz: Quiz?

    var gameSound: SystemSoundID = 0
    var answerButtons = [UIButton]()
    var levelForRound: Level = .easy

    var secondsLeft: Int = 0
    var timer = Timer()
    var isTimedGame: Bool = false
    
    
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

        setOptions()
    }
    
    
    // MARK: - Helpers: Pre-Game
    
    func chooseGameType() {
        for button in answerButtons {
            button.isHidden = true
        }
        
        playButton.isHidden = false
        playTimedButton.isHidden = false
    }
    
    
    func setOptions() {
        questionLabel.text = "Welcome to Random Trivia!"
        responseLabel.text = "What level game would you like to play?"
        playButton.isHidden = true
        playTimedButton.isHidden = true
        
        let gameOptions = ["Easy", "Hard", "Mix It Up"]
        for button in answerButtons {
            let buttonIndex = answerButtons.index(of: button)!
            if buttonIndex < gameOptions.count {
                button.removeTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(chooseLevel(_:)), for: .touchUpInside)
                button.setTitle(gameOptions[buttonIndex], for: .normal)
                button.isHidden = false
            } else {
                button.isHidden = true
            }
        }
    }
    
    func setLevel(forUserChoice level: String) -> Level {
        switch level {
            case "Easy":
                return Level.easy
            case "Hard":
                return Level.hard
            default:
                return Level.mixed
        }
    }
    
    // MARK: - Helpers: Timer
    
    func runTimer() {
        secondsLeft = totalSecondsForTimedRound
        timerLabel.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func updateTimerText() {
        timerLabel.text = "\(secondsLeft)"
    }
    
    // MARK: - Helpers: Game
    func dimAnswerButtons() {
        for button in answerButtons {
            button.alpha = 0.25
            button.isEnabled = false
        }
    }
    
    func displayQuestion() {
        if !isTimedGame || secondsLeft > 0 {
            if let question = quiz?.getNextQuestion() {
                responseLabel.isHidden = true
                questionLabel.text = question.prompt
                
                let numAnswers = getNumAnswers(forLevel: levelForRound)
                let responses = question.getCorrectAnswerAndMisdirectors(forNumberOfSlots: numAnswers)
                
                for button in answerButtons {
                    if let buttonIndex = answerButtons.index(of: button) {
                        if buttonIndex < responses.count {
                            button.isEnabled = true
                            button.isHidden = false
                            button.alpha = 1.0
                            button.setTitle(responses[buttonIndex], for: UIControlState.normal)
                            button.backgroundColor = GameColors.blue
                        } else {
                            button.isHidden = true
                        }
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
        
        // Prompt user for next game
        chooseGameType()
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
            // Continue game
            displayQuestion()
        } else {
            // Game is over
            displayScore()
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
        
        if !isTimedGame {
            quiz = Quiz(withQuestionCount: questionsPerRound)
        } else {
            quiz = Quiz()
            runTimer()
        }
        
        GameSound(forResource: "GameSound", ofType: "wav").play()
        
        displayQuestion()
    }

    // MARK: - Actions
    
    @objc func chooseLevel(_ sender: UIButton) {
        if let userChoice = sender.titleLabel?.text {
            levelForRound = setLevel(forUserChoice: userChoice)
        }
        
        for button in answerButtons {
            button.removeTarget(self,
                                action: #selector(chooseLevel(_:)),
                                for: .touchUpInside)
            button.addTarget(self,
                             action: #selector(checkAnswer(_:)),
                             for: .touchUpInside)
        }

        chooseGameType()
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
        isTimedGame = false
        runGame()
    }
    
    @IBAction func playTimedGame(_ sender: UIButton) {
        isTimedGame = true
        secondsLeft = totalSecondsForTimedRound
        updateTimerText()
        runGame()
    }
    
    @objc func updateTimer() {
        secondsLeft -= 1

        if secondsLeft <= 0 {
            timer.invalidate()
            displayScore()
            timerLabel.isHidden = true
        }
        
        updateTimerText()
    }
}
