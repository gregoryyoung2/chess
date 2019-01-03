import Foundation

class RandomAI : Player {
    
    enum RandError : Error {
        case zeroMoves
    }
    
     init (isLight : Bool, chess : Chess) {
        self.isLight = isLight
        self.chess = chess
    }
    
    override public func move() {
        var x = Int.random(in: 0..<8)
        var y = Int.random(in: 0..<8)
        
        while true {
            
            do {
                let moves = try chess.getMoves(x: x, y: y)
                guard !moves.isEmpty else { throw RandError.zeroMoves }
                let move = moves[Int.random(in: 0..<moves.count)]
                chess.updatePosition(oldX: x, oldY: y, newX: move.x, newY: move.y)
            }
            catch {
                x = Int.random(in: 0..<8)
                y = Int.random(in: 0..<8)
                continue
            }
            break
            
        }
        
    }
    
    private(set) var isLight : Bool
    
    private var chess : Chess
    
}
