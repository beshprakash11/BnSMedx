//
//  StereoMP3Player.swift
//  BnSMedxApp
//
//  Created by Besh Prakash Yogi on 18.02.26.
//

import Combine
import AVFoundation

class StereoMP3Player: ObservableObject {
    
    private let engine = AVAudioEngine()
    
    private let leftPlayer = AVAudioPlayerNode()
    private let rightPlayer = AVAudioPlayerNode()
    
    private let leftMixer = AVAudioMixerNode()
    private let rightMixer = AVAudioMixerNode()
    
    private var leftFile: AVAudioFile?
    private var rightFile: AVAudioFile?
    
    func setup(leftFileName: String, rightFileName: String) {
        
        guard let leftURL = Bundle.main.url(forResource: leftFileName, withExtension: "mp3"),
              let rightURL = Bundle.main.url(forResource: rightFileName, withExtension: "mp3") else {
            print("MP3 not found")
            return
        }
        
        do {
            leftFile = try AVAudioFile(forReading: leftURL)
            rightFile = try AVAudioFile(forReading: rightURL)
        } catch {
            print("File error:", error)
            return
        }
        
        // Attach nodes
        engine.attach(leftPlayer)
        engine.attach(rightPlayer)
        engine.attach(leftMixer)
        engine.attach(rightMixer)
        
        // Connect graph
        engine.connect(leftPlayer, to: leftMixer, format: leftFile!.processingFormat)
        engine.connect(rightPlayer, to: rightMixer, format: rightFile!.processingFormat)
        
        // Set stereo panning
        leftMixer.pan = -1.0   // full left
        rightMixer.pan = 1.0   // full right
        
        // Connect to output
        engine.connect(leftMixer, to: engine.mainMixerNode, format: nil)
        engine.connect(rightMixer, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Engine failed:", error)
        }
    }
    
    func play() {
        guard let leftFile = leftFile,
              let rightFile = rightFile else { return }
        
        leftPlayer.scheduleFile(leftFile, at: nil, completionHandler: nil)
        rightPlayer.scheduleFile(rightFile, at: nil, completionHandler: nil)
        
        leftPlayer.play()
        rightPlayer.play()
    }
    
    func stop() {
        leftPlayer.stop()
        rightPlayer.stop()
        engine.stop()
    }
}
