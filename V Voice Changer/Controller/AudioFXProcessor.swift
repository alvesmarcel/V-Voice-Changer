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
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private let maxNumberOfFrames: AVAudioFrameCount = 8096
    
    init(audioFile: AudioFile) throws {
        self.avAudioFile = try AVAudioFile(forReading: audioFile.url)
    }
    
    private func configureAudioEngineForEffect(_ effect: Effect) {
        audioEngine.stop()
        audioEngine.reset()
        audioEngine.attach(audioPlayerNode)
        var previousNode: AVAudioNode = audioPlayerNode
        for audioUnit in getAudioUnits(effect: effect) {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.outputNode, format: nil)
    }
    
    func manualAudioRender(effect: Effect, completionHandler: (_ outputFileURL: URL?, _ error: Error?) -> Void) {
        configureAudioEngineForEffect(effect)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil)
        do {
            try self.audioEngine.enableManualRenderingMode(.offline, format: avAudioFile.processingFormat, maximumFrameCount: maxNumberOfFrames)
        } catch {
            completionHandler(nil, error)
            return
        }
        
        do {
            try audioEngine.start()
            audioPlayerNode.play()
        } catch {
            completionHandler(nil, error)
            return
        }
        
        let outputFile: AVAudioFile
        do {
            let url = try PersistenceManager.shared.urlForFile(named: effect.rawValue)
//            if FileManager.default.fileExists(atPath: url.path) {
//                try? FileManager.default.removeItem(at: url)
//            }
            
            let recordSettings = avAudioFile.fileFormat.settings
            outputFile = try AVAudioFile(forWriting: url, settings: recordSettings)
        } catch {
            completionHandler(nil, error)
            return
        }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!
        
        while audioEngine.manualRenderingSampleTime < avAudioFile.length {
            do {
                let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(avAudioFile.length - audioEngine.manualRenderingSampleTime))
                let status = try audioEngine.renderOffline(framesToRender, to: buffer)
                switch status {
                case .success:
                    try outputFile.write(from: buffer)
                case .error:
                    completionHandler(nil, NSError(domain: "Render offline error", code: status.rawValue, userInfo: nil))
                    return
                default:
                    break
                }
            } catch {
                completionHandler(nil, error)
                return
            }
        }
        
        audioPlayerNode.stop()
        audioEngine.stop()
        completionHandler(outputFile.url, nil)
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
        if audioEngine.isInManualRenderingMode {
            audioEngine.disableManualRenderingMode()
        }
        configureAudioEngineForEffect(effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        audioPlayerNode.play()
    }
}
