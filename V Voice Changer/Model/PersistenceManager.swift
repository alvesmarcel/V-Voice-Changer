import Foundation

class PersistenceManager {
    
    private(set) var currentAudioFile: AudioFile?
    private let fileExtension = ".m4a"
    
    // Singleton pattern
    private init() {}
    static let shared = PersistenceManager()
    
    func urlForEffect(_ effect: AudioFXProcessor.Effect) throws -> URL {
        return try urlForFile(named: effect.rawValue)
    }
    
    func urlForFile(named fileName: String) throws -> URL {
        let fileName = "\(fileName)\(fileExtension)"
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    func createNewAudioFile() throws -> AudioFile {
        let fileName = "V"
        let fileURL = try urlForFile(named: fileName)
        self.currentAudioFile = AudioFile(name: fileName, url: fileURL)
        return self.currentAudioFile!
    }
}
