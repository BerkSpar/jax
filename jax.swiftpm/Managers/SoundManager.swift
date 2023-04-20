//
//  SoundManager.swift
//  jax
//
//  Created by Felipe Passos on 11/04/23.
//

import Foundation
import AVFAudio

class SoundManager {
    private var audioPlayers:[AVAudioPlayer] = []
    private var playbackAudioCount = 5
    
    init() {
        setup()
    }
    
    private func setup() {
        for i in 1...playbackAudioCount {
            let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "sound_\(i)", ofType: "mp3")!)

            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)

            let audioPlayer = try! AVAudioPlayer(contentsOf: sound)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 0
            audioPlayer.numberOfLoops = -1
            
            audioPlayers.append(audioPlayer)
        }
        
        for i in 1...playbackAudioCount {
            audioPlayers[i-1].play()
        }
    }
    
    func playPlayback(intensity: Int = 1) {
        for i in 1...playbackAudioCount {
            if (i <= intensity) {
                audioPlayers[i-1].setVolume(5, fadeDuration: 1)
            } else {
                audioPlayers[i-1].setVolume(0, fadeDuration: 3)
            }
        }
    }
}
