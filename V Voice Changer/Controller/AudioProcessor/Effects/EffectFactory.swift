import AVFoundation

class EffectFactory {
    
    enum EffectName: CaseIterable {
        case slow, fast, alien, darthvader, shaokahn, jigsaw, chipmunk
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
        case .alien:
            return AlienEffect()
        case .darthvader:
            return DarthVaderEffect()
        case .shaokahn:
            return ShaoKahnEffect()
        case .jigsaw:
            return JigsawEffect()
        case .chipmunk:
            return ChipmunkEffect()
        }
    }
}
