import AVFoundation

class ChipmunkEffect: Effect {
    private(set) var name = EffectFactory.EffectName.chipmunk
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 1300
        
        return [timePitchAU]
    }()
}
