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
    // **************************************************************************************
    /// A struct representing the three button colors used in the game (blue, red, and green)
    struct GameColors {
        static let blue = UIColor(red: 0.0, green: 145/255.0, blue: 183/255.0, alpha: 1.0)
        static let green = UIColor(red: 0.0, green: 118/255.0, blue: 0, alpha: 1.0)
        static let red = UIColor(red: 214.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    
    // MARK: - Properties
    // **************************************************************************************
    var answerButtons = [UIButton]()
    var quiz: Quiz?
    
    
    // MARK: - Outlets
    // **************************************************************************************
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var answerButtonStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTimedButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    // MARK: - Life Cycle Methods
    // **************************************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the time label
        timerLabel.isHidden = true
        
        // Round corners for all buttons and add all answer buttons to the answerButton array
        playButton.layer.cornerRadius = 8
        playTimedButton.layer.cornerRadius = 8
        for subview in answerButtonStackView.arrangedSubviews {
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 8
                answerButtons.append(button)
            }
        }
        
        // Play the beginning game sound
        GameSound(forResource: "GameSound", ofType: "wav").play()
        
        // Display welcome message, clear response label, and prompt user to set game options
        questionLabel.text = "Welcome to Random Trivia!"
        responseLabel.text = ""
        setOptions()
    }
    
    
    // MARK: - Helpers: Pre-Game
    // **************************************************************************************
    /// Create a new instance of the Quiz class and sets the isTimedGame property
    func loadQuiz(asTimedQuiz isTimedQuiz: Bool) {
        quiz = Quiz()
        quiz!.isTimedGame = isTimedQuiz
    }

    /// Prompts the user to select the level for the round of questions they are about to play.
    func promptForLevel() {
        // Set the label text and show the response label
        responseLabel.text = "What level game would you like to play?"
        responseLabel.isHidden = false
        
        // Hide the play buttons
        playButton.isHidden = true
        playTimedButton.isHidden = true
        
        // Set the titles for, format, and show the answerButton array using the names of the GameLevels.
        // Also, sets the targets for each button to the chooseLevel(_ :) selector.
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
    
    /// Prompts the user to select the mode of play (timed or untimed) for the next round of questions.
    func promptForTimedMode() {
        for button in answerButtons {
            button.isHidden = true
        }
        
        playButton.isHidden = false
        playTimedButton.isHidden = false
    }
    
    /// Called at the top of every game to start the option selection chain.
    func setOptions() {
        promptForTimedMode()
        // promptForLevel() will subsequently be called when a user taps the timed mode button of their choice
    }
    

    // MARK: - Helpers: Timer Management
    // **************************************************************************************
    /// Instantiates and runs the timer (a property of the Quiz class)
    func runTimer() {
        quiz?.runTimer(forTargetViewController: self,
                       usingSelector: #selector(updateTimer))
        updateTimerText()
        timerLabel.isHidden = false
    }
    
    /// Updates the text in the timer label to match the number of seconds left in the quiz.
    func updateTimerText() {
        timerLabel.text = "\(quiz!.secondsLeft)"
    }
    

    // MARK: - Helpers: Game Play
    // **************************************************************************************
    /// Dims and disables all buttons in the answerButtons array
    func dimAndDisableAnswerButtons() {
        for button in answerButtons {
            button.alpha = 0.25
            button.isEnabled = false
        }
    }
    
    /// Displays the question by setting the label text for the Question label. Then for each response to the question (determined by calling the getLevelledResponsesForCurrentQuestion method for the current quiz property), the function will change the title label and call a helper function to enable, format, and show the button. All unused buttons in the array will be hidden.
    func displayQuestion() {
        if let question = quiz?.getNextQuestion() {
            responseLabel.isHidden = true
            questionLabel.text = question.prompt
            
            let responses = quiz!.getLevelledResponsesForCurrentQuestion()
            
            for button in answerButtons {
                if let buttonIndex = answerButtons.index(of: button) {
                    if buttonIndex < responses.count {
                        button.setTitle(responses[buttonIndex], for: UIControlState.normal)
                        enableAndFormat(button: button)
                    } else {
                        button.isHidden = true
                    }
                }
            }
        }
    }
    
    /// Hides all buttons in the answerButtons array and changes the text in the question and response labels to indicate the end of the game and the player's score. Additionally, this function will call the setOptions() helper function to start the next round of game play.
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
    
    /// Enables, formats, and shows the answer buttons. Buttons are formatted using the blue GameColor and an alpha setting of 1.0.
    func enableAndFormat(button: UIButton) {
        button.backgroundColor = GameColors.blue
        button.alpha = 1.0
        button.isEnabled = true
        button.isHidden = false
    }
    
   /// Highlights the correct answer by changing the background color of the button to the GameColor red.
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
    
    /// Continues the game if there are questions left in an untimed game or if there is time left in a timed game. Otherwise, ends the game and displays the score.
    func nextQuestion() {
        if quiz != nil && quiz!.hasNextQuestion() {
            displayQuestion()   // Continue game.
        } else {
            displayScore()      // Game is over.
        }
    }
    
    /// Loads the next round allowing for a two second delay before calling the nextRound() helper function so that the user has time to review the correct or incorrect choices that have been highlighted.
    func loadNextQuestion(withDelayInSeconds seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextQuestion()
        }
    }
    
    /// If the user has selected a timed game, this function starts the timer. In the case of either a timed or an untimed game, this function plays the begin game sound and loads the next question.
    func runGame() {
        if quiz!.isTimedGame {
            runTimer()
        }
        
        GameSound(forResource: "GameSound", ofType: "wav").play()
        
        nextQuestion()
    }

    
    // MARK: - Target Actions
    // **************************************************************************************
    /// Processes the user's choice of answer by changing the text in the response label, dimming and disabling the buttons in the answerButtons array, and applying appropriate color to the correct answer (and the incorrect answer if the user made the wrong choice). Then, the function loads the next question with a timed delay.
    @objc func checkAnswer(_ sender: UIButton) {
        if let userResponse = sender.titleLabel?.text {
            dimAndDisableAnswerButtons()
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
        
        loadNextQuestion(withDelayInSeconds: 2)
    }
    
    /// Processes the user's choice of level and then calls the runGame() helper function.
    @objc func chooseLevel(_ sender: UIButton) {
        // Sets the level of the quiz based on the user choice
        if let userChoice = sender.titleLabel?.text {
            quiz!.setLevel(forUserChoice: userChoice)
        }
        
        // Resets the target action for all buttons in the answerButtons array to the checkAnswer(_ :) selector
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
    
    /// Loads a new untimed quiz and prompts the user to select the level for the questions.
    @IBAction func playAgain(_ sender: UIButton) {
        loadQuiz(asTimedQuiz: false)
        promptForLevel()
    }
    
    /// Loads a new timed quiz and prompts the user to select the level for the questions.
    @IBAction func playTimedGame(_ sender: UIButton) {
        loadQuiz(asTimedQuiz: true)
        updateTimerText()
        promptForLevel()
    }
    
    /// Calls the updateTimer() method for the current quiz instance and then updates the timer label using the value returned. If the value returned is equal to or less than zero, the timer label is hidden and the displayScore() helper method is called.
    @objc func updateTimer() {
        if quiz!.updateTimer() <= 0 {
            displayScore()
            timerLabel.isHidden = true
        }
        
        updateTimerText()
    }
}
