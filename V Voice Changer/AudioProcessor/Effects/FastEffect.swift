import AVFoundation

class FastEffect: Effect {
    private(set) var name = EffectFactory.EffectName.fast
    private(set) var rate = 2.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 2.0
        
        return [timePitchAU]
    }()
}
