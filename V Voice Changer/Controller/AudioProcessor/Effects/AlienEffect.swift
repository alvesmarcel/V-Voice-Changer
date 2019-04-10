import AVFoundation

class AlienEffect: Effect {
    private(set) var name = EffectFactory.EffectName.alien
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 100
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechCosmicInterference)
        distortionAU.wetDryMix = 100
        
        return [timePitchAU, distortionAU]
    }()
}
