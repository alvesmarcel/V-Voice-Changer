import AVFoundation

class AudioFXProcessor {
    enum Effects {
        case none
        case slow
        case fast
        case darthvader
        case chipmunk
        case jigsaw
        case shaokahn
    }
    
    private let audioEngine: AVAudioEngine!
    private let avAudioFile: AVAudioFile!
    
    init(audioFile: AudioFile) throws {
        self.audioEngine = AVAudioEngine()
        self.avAudioFile = try AVAudioFile(forReading: audioFile.url)
        print(avAudioFile.url)
    }
    
    private func getPreprocessorAudioUnit() -> AVAudioUnitEQ {
        let eq = AVAudioUnitEQ(numberOfBands: 3)
        eq.bands[0].filterType = .highPass
        eq.bands[0].frequency = 80
        eq.bands[0].bypass = false
        
        eq.bands[1].filterType = .parametric
        eq.bands[1].frequency = 200
        eq.bands[1].gain = -3
        eq.bands[1].bandwidth = 50
        eq.bands[1].bypass = false
        
        eq.bands[2].filterType = .parametric
        eq.bands[2].frequency = 4000
        eq.bands[2].gain = 4
        eq.bands[2].bandwidth = 2000
        eq.bands[2].bypass = false

        return eq
    }
    
    private func getAudioUnits(effect: Effects) -> [AVAudioUnit] {
        var effectsArray: [AVAudioUnit] = [getPreprocessorAudioUnit()]
        switch effect {
        case .slow:
            let slow = AVAudioUnitTimePitch()
            slow.rate = 1.0/2.0
            effectsArray.append(slow)
        case .fast:
            let fast = AVAudioUnitTimePitch()
            fast.rate = 2.0
            effectsArray.append(fast)
        case .jigsaw:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.drumsBitBrush)
            distortion.wetDryMix = 13
            effectsArray.append(distortion)
            let pitch = AVAudioUnitTimePitch()
            pitch.pitch = -343
            effectsArray.append(pitch)
        case .shaokahn:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.drumsBitBrush)
            distortion.wetDryMix = 40
            effectsArray.append(distortion)
            let pitch = AVAudioUnitTimePitch()
            pitch.pitch = -500
            effectsArray.append(pitch)
            let reverb = AVAudioUnitReverb()
            reverb.loadFactoryPreset(.largeChamber)
            reverb.wetDryMix = 40
            effectsArray.append(reverb)
        case .chipmunk:
            let highPitch = AVAudioUnitTimePitch()
            highPitch.pitch = 1300
            effectsArray.append(highPitch)
        case .darthvader:
            let lowPitch = AVAudioUnitTimePitch()
            lowPitch.pitch = -1200
            effectsArray.append(lowPitch)
        default:
            print("No effect applied")
        }
        return effectsArray
    }

    func play(withEffect effect: Effects) {
        audioEngine.stop()
        audioEngine.reset()
        let audioPlayerNode = AVAudioPlayerNode()
        var previousNode: AVAudioNode = audioPlayerNode
        audioEngine.attach(previousNode)
        for audioUnit in getAudioUnits(effect: effect) {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        
        audioPlayerNode.play()
    }
}
