import AVFoundation

class JigsawEffect: Effect {
    private(set) var name = EffectFactory.EffectName.jigsaw
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 20
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -300
        
        return [distortionAU, timePitchAU]
    }()
}
