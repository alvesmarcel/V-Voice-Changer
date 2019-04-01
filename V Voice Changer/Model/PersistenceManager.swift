import Foundation

class PersistenceManager {
    
    private(set) var currentAudioFile: AudioFile?
    private let fileNumberKey = "FileNumberKey"
    private let fileExtension = ".m4a"
    
    // Singleton pattern
    private init() {}
    static let shared = PersistenceManager()
    
    func createNewAudioFile() throws -> AudioFile {
        let fileName = "V\(fileExtension)"
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        self.currentAudioFile = AudioFile(name: fileName, url: fileURL)
        return self.currentAudioFile!
    }
}
