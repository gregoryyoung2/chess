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

        let moves = chess.getAllMoves()
        guard !moves.isEmpty else {
            print("Check/stalemate")
            return
        }
        
        var attackMove : Chess.ChessMove? = nil
        
        for move in moves {
            if move.attack {
                attackMove = move
                break
            }
        }
        
        let move = attackMove ?? moves[Int.random(in: 0..<moves.count)]
        
        chess.makeMove(move)
        
    }
    
    private(set) var isLight : Bool
    
    private var chess : Chess
    
}
