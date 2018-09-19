//
//  GameSound.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/16/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import AudioToolbox

/// Allows the user to load and play a sound using the AudioToolbox framework
class GameSound {
    let soundUrl: URL!
    
    /// Initializes a GameSound using the resource name and file type.
    init(forResource resource: String, ofType type: String) {
        let path = Bundle.main.path(forResource: resource, ofType: type)
        soundUrl = URL(fileURLWithPath: path!)
    }
    
    /// Plays the sound file using the soundURL as the path.
    func play() {
        var systemSoundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &systemSoundID)
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
