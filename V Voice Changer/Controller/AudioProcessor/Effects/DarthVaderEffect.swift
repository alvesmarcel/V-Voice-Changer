import AVFoundation

class DarthVaderEffect: Effect {
    private(set) var name = EffectFactory.EffectName.darthvader
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -1200
        
        return [timePitchAU]
    }()
}
