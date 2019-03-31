import Foundation

struct PersistenceManager {
    
    private let fileNumberKey = "FileNumberKey"
    private let fileExtension = ".m4a"
    private let currentFile = "V.m4a" // Currently, we are going to support only 1 audio file
    
    // Singleton pattern
    private init() {}
    static let shared = PersistenceManager()
    
    private func getFileURL(fileName: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            return fileURL
        } catch {
            print(error)
        }
        return nil
    }
    
    func getCurrentFileURL() -> URL? {
        return getFileURL(fileName: currentFile)
    }
}
