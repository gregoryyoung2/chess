import Foundation

class MinimaxAI : Player {
    
    init (isLight: Bool, chess: Chess) {
        self.isLight = isLight
        self.chess = chess
    }
    
    override func move() {
    
        let moves = chess.getAllMoves(forLight: isLight, board: nil)
        
        var bestMove : Chess.ChessMove?
        var bestScore = Int.min
        
        for move in moves {
            let result = minimax(depth: 0, board: chess.board, isLight: isLight)
            if result > bestScore {
                bestMove = move
                bestScore = result
            }
        }
        
        guard let move = bestMove else {
            print("ERROR: No move found")
            return
        }
        
        chess.updatePosition(oldX: move.origin.x, oldY: move.origin.y, newX: move.dest.x, newY: move.dest.y)
        
    }
    
    private func evaluate(board: [[Chess.Piece]]) -> Int {
        
        var value = 0
        
        for r in 0..<board.count {
            for c in 0..<board[r].count {
                value += board[r][c].getBaseValue()
            }
        }
        
        return value
        
    }
    
    private func minimax(depth: Int, board: [[Chess.Piece]], isLight: Bool) -> Int {
        
        var board = board
        
        if depth == 0 {
            return self.evaluate(board: board) * (isLight ? 1 : -1)
        }
        
        var bestMove = isLight ? Int.min : Int.max
        
        let moves = chess.getAllMoves(forLight: isLight, board: board)
        
        for move in moves {
            
            let prev = board[move.origin.y][move.origin.x]
            let dest = board[move.dest.y][move.dest.x]
            
            board[move.dest.y][move.dest.x] = prev
            board[move.origin.y][move.origin.x] = .null
            
            let result = minimax(depth: depth - 1, board: board, isLight: !isLight)
            
            bestMove = isLight ? max(bestMove, result) : min(bestMove, result)
            
            board[move.dest.y][move.dest.x] = dest
            board[move.origin.y][move.origin.x] = prev
            
        }
        
        return bestMove
        
    }
    
    private(set) var isLight : Bool
    private(set) var chess : Chess
    
    private let depth = 2
    
}