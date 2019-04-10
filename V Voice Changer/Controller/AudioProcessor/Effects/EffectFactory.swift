import AVFoundation

class EffectFactory {
    
    enum EffectName: CaseIterable {
        case slow, fast, chipmunk, darthvader, shaokahn, jigsaw
    }
    
    // Singleton pattern
    private init() {}
    static let shared = EffectFactory()
    
    func effect(forName effectName: EffectFactory.EffectName) -> Effect {
        switch effectName {
        case .slow:
            return SlowEffect()
        case .fast:
            return FastEffect()
        case .chipmunk:
            return ChipmunkEffect()
        case .darthvader:
            return DarthVaderEffect()
        case .shaokahn:
            return ShaoKahnEffect()
        case .jigsaw:
            return JigsawEffect()
        }
    }
}
