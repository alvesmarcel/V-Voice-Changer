import AVFoundation

class ShaoKahnEffect: Effect {
    private(set) var name = EffectFactory.EffectName.shaokahn
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 10
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -400
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.mediumHall3)
        reverbAU.wetDryMix = 20
        
        return [distortionAU, timePitchAU, reverbAU]
    }()
}
