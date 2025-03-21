import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
