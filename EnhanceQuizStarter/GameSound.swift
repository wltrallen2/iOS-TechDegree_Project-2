//
//  GameSound.swift
//  EnhanceQuizStarter
//
//  Created by Walter Allen on 9/16/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import AudioToolbox

class GameSound {
    let soundUrl: URL!
    
    init(forResource resource: String, ofType type: String) {
        let path = Bundle.main.path(forResource: resource, ofType: type)
        soundUrl = URL(fileURLWithPath: path!)
    }
    
    func play() {
        var systemSoundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &systemSoundID)
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
