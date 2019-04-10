import AVFoundation

class AudioFXProcessor {
    private let maxNumberOfFrames: AVAudioFrameCount = 8192
    private let avAudioFile: AVAudioFile!
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioEngine = AVAudioEngine()
    
    init(audioFile: AudioFile) throws {
        self.avAudioFile = try AVAudioFile(forReading: audioFile.url)
    }
}

// MARK: - Private methods
extension AudioFXProcessor {
    private func prepareAudioEngine(forEffect effect: Effect) {
        // It's needed to stop and reset the audio engine before creating a new one to avoid crashing
        stop()
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        var previousNode: AVAudioNode = audioPlayerNode
        for audioUnit in effect.audioUnits {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.mainMixerNode, format: nil)
    }
}

// MARK: Internal methods
extension AudioFXProcessor {
    func manualAudioRender(effect: Effect) throws {
        prepareAudioEngine(forEffect: effect)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil)
        try audioEngine.enableManualRenderingMode(.offline, format: avAudioFile.processingFormat, maximumFrameCount: maxNumberOfFrames)
        
        try audioEngine.start()
        audioPlayerNode.play()
        
        let outputFile: AVAudioFile
        let url = try PersistenceManager.shared.urlForEffect(named: effect.name)
        let recordSettings = avAudioFile.fileFormat.settings
        outputFile = try AVAudioFile(forWriting: url, settings: recordSettings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!
        
        // Adjust the file size based on the effect rate
        let outputFileLength = Int64(Double(avAudioFile.length) / effect.rate)
        
        while audioEngine.manualRenderingSampleTime < outputFileLength {
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(outputFileLength - audioEngine.manualRenderingSampleTime))
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
    
    func play(withEffect effect: Effect) {
        audioPlayerNode = AVAudioPlayerNode()
        prepareAudioEngine(forEffect: effect)
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
