import AVFoundation

class AudioFXProcessor {
    enum Effect: String {
        case none
        case slow
        case fast
        case darthvader
        case chipmunk
        case jigsaw
        case shaokahn
        
        static let allValues = [none, slow, fast, darthvader, chipmunk, jigsaw, shaokahn]
    }
    
    private let avAudioFile: AVAudioFile!
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioEngine = AVAudioEngine()
    private let maxNumberOfFrames: AVAudioFrameCount = 8096
    
    init(audioFile: AudioFile) throws {
        self.avAudioFile = try AVAudioFile(forReading: audioFile.url)
    }
    
    private func prepareAudioEngineForEffect(_ effect: Effect) {
        // It's needed to stop and reset the audio engine before creating a new one to avoid crashing
        stop()
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        var previousNode: AVAudioNode = audioPlayerNode
        for audioUnit in getAudioUnits(effect: effect) {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.outputNode, format: nil)
    }
    
    func manualAudioRender(effect: Effect) throws {
        prepareAudioEngineForEffect(effect)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil)
        try audioEngine.enableManualRenderingMode(.offline, format: avAudioFile.processingFormat, maximumFrameCount: maxNumberOfFrames)

        try audioEngine.start()
        audioPlayerNode.play()
        
        let outputFile: AVAudioFile
        let url = try PersistenceManager.shared.urlForFile(named: effect.rawValue)
        let recordSettings = avAudioFile.fileFormat.settings
        outputFile = try AVAudioFile(forWriting: url, settings: recordSettings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!
        
        while audioEngine.manualRenderingSampleTime < avAudioFile.length {
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(avAudioFile.length - audioEngine.manualRenderingSampleTime))
            let status = try audioEngine.renderOffline(framesToRender, to: buffer)
            switch status {
            case .success:
                try outputFile.write(from: buffer)
            case .error:
                print("Error rendering offline audio")
                return
            default:
                break
            }
        }
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.disableManualRenderingMode()
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
    
    private func getAudioUnits(effect: Effect) -> [AVAudioUnit] {
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

    func play(withEffect effect: Effect) {
        audioPlayerNode = AVAudioPlayerNode()
        prepareAudioEngineForEffect(effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        audioPlayerNode.play()
    }
    
    func stop() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}
