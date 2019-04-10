import AVFoundation

protocol Effect {
    var name: EffectFactory.EffectName { get }
    var rate: Double { get }
    var audioUnits: [AVAudioUnit] { get }
}
