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
    
    //TODO: Incorporate QuestionProvider into controller
    
    // MARK: - Properties
    
    let questionsPerRound = 4
    var quiz: Quiz?

    var gameSound: SystemSoundID = 0
    
    // MARK: - Outlets
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = 8
        for button in answerButtons {
            button.layer.cornerRadius = 8
        }
        
        loadGameStartSound()
        playGameStartSound()
        showStartScreen()
        runGame()
    }
    
    // MARK: - Helpers
    
    func loadGameStartSound() {
        let path = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func showStartScreen() {
        
    }
    
    func runGame() {
        quiz = Quiz(withQuestionCount: questionsPerRound)
        displayQuestion()
    }
    
    func displayQuestion() {
        playButton.isHidden = true

        if let question = quiz?.getNextQuestion() {
            questionLabel.text = question.prompt
            for button in answerButtons {
                button.isHidden = false
                button.alpha = 1.0
                //TODO: Display responses
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
        
        //TODO: Enter message that displays how many questions correct out of how many answered.
        questionLabel.text = "Good game!"
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
    
    func dimAnswerButtons() {
        for button in answerButtons {
            button.alpha = 0.25
        }
    }
    
    // MARK: - Actions
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        if let userResponse = sender.titleLabel?.text {
            dimAnswerButtons()
            
            if quiz != nil && quiz!.isAnsweredCorrectly(withUserResponse: userResponse) {
                responseLabel.text = "Correct!"
            } else {
                responseLabel.text = "Sorry! Wrong answer!"
            }
        }
        
        loadNextRound(delay: 2)
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
        runGame()
    }
    

}

