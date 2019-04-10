import AVFoundation

class SlowEffect: Effect {
    private(set) var name = EffectFactory.EffectName.slow
    private(set) var rate = 0.5
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 1.0/2.0
        
        return [timePitchAU]
    }()
}
