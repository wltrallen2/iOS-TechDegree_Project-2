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
    
    // MARK: - Properties
    
    let questionsPerRound = 4
    var quiz: Quiz?

    var gameSound: SystemSoundID = 0
    
    // MARK: - Outlets
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var answerButtonStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    
    var answerButtons: [UIButton] = [UIButton]()
    var numQuestionsPerRound: Int = 4
    var levelForRound: Level = .easy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = 8

        loadGameStartSound()
        playGameStartSound()
        showStartScreen()
//        runGame()
    }
    
    // MARK: - Helpers: Sound
    
    func loadGameStartSound() {
        let path = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    // MARK: - Helpers: Pre-Game
    
    func showStartScreen() {
        //TODO: Implement this helper function
        questionLabel.text = "Welcome to Random Trivia!"
        responseLabel.text = "What level game would you like to play?"
        playButton.isHidden = true
        
        let gameOptions = ["Easy", "Hard", "Mix It Up"]
        formatAnswerButtons(forNumberOfAnswers: gameOptions.count)
        for button in answerButtons {
            button.removeTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(chooseLevel(_:)), for: .touchUpInside)
            let buttonIndex = answerButtons.index(of: button) ?? 0
            button.setTitle(gameOptions[buttonIndex], for: .normal)
        }
    }
    
    func setLevel(forUserChoice level: String) -> Level {
        //TODO: Fix "Mix It Up" option to randomize number of questions
        switch level {
            case "Easy":
                return Level.easy
            case "Hard":
                return Level.hard
            default:
                return Level.mixed
        }
    }
    
    
    // MARK: - Helpers: Game
    func dimAnswerButtons() {
        for button in answerButtons {
            button.alpha = 0.25
        }
    }
    
    func displayQuestion() {
        playButton.isHidden = true
        responseLabel.isHidden = true

        if let question = quiz?.getNextQuestion() {
            questionLabel.text = question.prompt
            
            let numAnswers = getNumAnswers(forLevel: levelForRound)
            let responses = question.getCorrectAnswerAndMisdirectors(forNumberOfSlots: numAnswers)
            var responseIndex = 0
            
            formatAnswerButtons(forNumberOfAnswers: numAnswers)
            for button in answerButtons {
                button.isHidden = false
                button.alpha = 1.0
                button.setTitle(responses[responseIndex], for: UIControlState.normal)
                responseIndex += 1
            }
        }
    }
    
    func displayScore() {
        // Hide the answer buttons
        for button in answerButtons {
            button.isHidden = true
        }
        
        // Display play again button
        playButton.isHidden = false
        
        questionLabel.text = "Good game!"
        responseLabel.text = "You correctly answered \(quiz!.score) out of \(questionsPerRound) questions!"
    }
    
    func formatAnswerButtons(forNumberOfAnswers numAnswers: Int) {
        let blueColor = UIColor(red: 44/255.0,
                                green: 97/255.0,
                                blue: 165/255.0,
                                alpha: 1.0)
        
        if answerButtons.count > numAnswers {
            let numButtonsToRemove = answerButtons.count - numAnswers
            for _ in 0..<numButtonsToRemove {
                let button = answerButtons[0]
                answerButtonStackView.removeArrangedSubview(button)
                answerButtons.remove(at: 0)
            }
        } else if answerButtons.count < numAnswers {
            let numAdditionalButtons = numAnswers - answerButtons.count
            for _ in 0..<numAdditionalButtons {
                let button = UIButton(type: .system)
                button.backgroundColor = blueColor
                button.setTitleColor(UIColor.white, for: .normal)
                button.layer.cornerRadius = 8
                button.addTarget(self,
                                 action: #selector(checkAnswer(_:)),
                                 for: .touchUpInside)
                answerButtonStackView.addArrangedSubview(button)
                answerButtons.append(button)
            }
        }
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
        quiz = Quiz(withQuestionCount: questionsPerRound)
        displayQuestion()
    }
    

    // MARK: - Actions
    
    @objc func chooseLevel(_ sender: UIButton) {
        if let userChoice = sender.titleLabel?.text {
            levelForRound = setLevel(forUserChoice: userChoice)
        }

        for button in answerButtons {
            if let index = answerButtons.index(of: button) {
                // ERROR: Buttons are appearing at upper left corner of screen when "removed."
                // Branching off here to attempt using .isHidden property for subviews in stack
                answerButtonStackView.removeArrangedSubview(answerButtons[index])
                answerButtons.remove(at: index)
            }
        }
        
        runGame()
    }
    
    @objc func checkAnswer(_ sender: UIButton) {
        if let userResponse = sender.titleLabel?.text {
            dimAnswerButtons()
            
            if quiz != nil && quiz!.isAnsweredCorrectly(withUserResponse: userResponse) {
                responseLabel.text = "Correct!"
            } else {
                responseLabel.text = "Sorry! Wrong answer!"
            }
            
            responseLabel.isHidden = false
        }
        
        loadNextRound(delay: 2)
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
        runGame()
    }
}

