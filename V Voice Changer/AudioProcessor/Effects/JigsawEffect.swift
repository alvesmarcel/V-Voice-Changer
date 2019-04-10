import AVFoundation

class JigsawEffect: Effect {
    private(set) var name = EffectFactory.EffectName.jigsaw
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.drumsBitBrush)
        distortionAU.wetDryMix = 13
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -343
        
        return [distortionAU, timePitchAU]
    }()
}
