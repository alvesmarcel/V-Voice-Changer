import AVFoundation

class ShaoKahnEffect: Effect {
    private(set) var name = EffectFactory.EffectName.shaokahn
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.drumsBitBrush)
        distortionAU.wetDryMix = 40
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -500
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.largeChamber)
        reverbAU.wetDryMix = 40
        
        return [distortionAU, timePitchAU, reverbAU]
    }()
}
