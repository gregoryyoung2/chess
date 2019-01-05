import Foundation

class MinimaxAI : Player {
    
    init (isLight: Bool, chess: Chess) {
        self.isLight = isLight
        self.chess = chess
    }
    
    override func move() {
    
        let moves = chess.getAllMoves(forLight: isLight, board: nil)
        
        var board = chess.board
        
        var bestMove : Chess.ChessMove?
        var bestScore = Int.min
        
        for move in moves {
            
            let prev = board[move.origin.y][move.origin.x]
            let dest = board[move.dest.y][move.dest.x]
            
            board[move.dest.y][move.dest.x] = prev
            board[move.origin.y][move.origin.x] = .null
            
            let result = minimax(depth: 2, board: board, isLight: isLight, α: Int.min, β: Int.max)
            
            if result > bestScore {
                bestMove = move
                bestScore = result
            }
            
            board[move.dest.y][move.dest.x] = dest
            board[move.origin.y][move.origin.x] = prev
            
//            print("Move \(board[move.origin.y][move.origin.x]) gives score \(result)")
        }
        
        guard let move = bestMove else {
            print("ERROR: No move found")
            return
        }
        
        print("Best score: \(bestScore)")
        
        chess.makeMove(move)
        
    }
    
    private func evaluate(board: [[Chess.Piece]]) -> Int {
        
        var value = 0
        
        for r in 0..<board.count {
            for c in 0..<board[r].count {
                value += board[r][c].getBaseValue()
                value += getPieceSquare(piece: board[r][c], point: Chess.Point(c, r))
            }
        }
        
        return value
        
    }
    
    private func minimax(depth: Int, board: [[Chess.Piece]], isLight: Bool, α: Int, β: Int) -> Int {
        
        var board = board
        
        var alpha = α
        var beta = β
        
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
            
            let result = minimax(depth: depth - 1, board: board, isLight: !isLight, α: alpha, β: beta)
            
            
            bestMove = isLight ? max(bestMove, result) : min(bestMove, result)
            
            board[move.dest.y][move.dest.x] = dest
            board[move.origin.y][move.origin.x] = prev
            
            alpha = isLight ? max(alpha, bestMove) : alpha
            beta = isLight ? beta : min(beta, bestMove)
            
            if beta <= alpha {
                return bestMove
            }
            
        }
        
        return bestMove
        
    }
    
    private func getPieceSquare(piece : Chess.Piece, point: Chess.Point) -> Int {
        switch piece {
        case .pawn(let l):
            return pawnTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        case .bishop(let l):
            return bishopTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        case .knight(let l):
            return knightTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        case .rook(let l):
            return rookTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        case .queen(let l):
            return queenTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        case .king(let l):
            return kingMidTable[l ? 0 : 7 - point.y][point.x] * (l ? 1 : -1)
        default:
            return 0
        }
    }
    
    private(set) var isLight : Bool
    private(set) var chess : Chess
    
    private let depth = 2
    
    private let pawnTable = [[   0,   0,   0,   0,   0,   0,   0,   0],
                             [  50,  50,  50,  50,  50,  50,  50,  50],
                             [  10,  10,  20,  30,  30,  20,  10,  10],
                             [   5,   5,  10,  25,  25,  10,   5,   5],
                             [   0,   0,   0,  20,  20,   0,   0,   0],
                             [   5,  -5, -10,   0,   0, -10,  -5,   5],
                             [   5,  10,  10, -20, -20,  10,  10,   5],
                             [   0,   0,   0,   0,   0,   0,   0,   0]]
    
    private let knightTable =  [[-50,-40,-30,-30,-30,-30,-40,-50],
                                [-40,-20,  0,  0,  0,  0,-20,-40],
                                [-30,  0, 10, 15, 15, 10,  0,-30],
                                [-30,  5, 15, 20, 20, 15,  5,-30],
                                [-30,  0, 15, 20, 20, 15,  0,-30],
                                [-30,  5, 10, 15, 15, 10,  5,-30],
                                [-40,-20,  0,  5,  5,  0,-20,-40],
                                [-50,-40,-30,-30,-30,-30,-40,-50]]
    
    private let bishopTable =  [[-20,-10,-10,-10,-10,-10,-10,-20],
                                [-10,  0,  0,  0,  0,  0,  0,-10],
                                [-10,  0,  5, 10, 10,  5,  0,-10],
                                [-10,  5,  5, 10, 10,  5,  5,-10],
                                [-10,  0, 10, 10, 10, 10,  0,-10],
                                [-10, 10, 10, 10, 10, 10, 10,-10],
                                [-10,  5,  0,  0,  0,  0,  5,-10],
                                [-20,-10,-10,-10,-10,-10,-10,-20]]
    
    private let rookTable =  [[0,  0,  0,  0,  0,  0,  0,  0],
                              [5, 10, 10, 10, 10, 10, 10,  5],
                              [-5,  0,  0,  0,  0,  0,  0, -5],
                              [-5,  0,  0,  0,  0,  0,  0, -5],
                              [-5,  0,  0,  0,  0,  0,  0, -5],
                              [-5,  0,  0,  0,  0,  0,  0, -5],
                              [-5,  0,  0,  0,  0,  0,  0, -5],
                              [0,  0,  0,  5,  5,  0,  0,  0]]
    
    private let queenTable =  [[-20,-10,-10, -5, -5,-10,-10,-20],
                               [-10,  0,  0,  0,  0,  0,  0,-10],
                               [-10,  0,  5,  5,  5,  5,  0,-10],
                               [-5,  0,  5,  5,  5,  5,  0, -5],
                               [ 0,  0,  5,  5,  5,  5,  0, -5],
                               [-10,  5,  5,  5,  5,  5,  0,-10],
                               [-10,  0,  5,  0,  0,  0,  0,-10],
                               [-20,-10,-10, -5, -5,-10,-10,-20]]
    
    private let kingMidTable =  [[-30,-40,-40,-50,-50,-40,-40,-30],
                                 [-30,-40,-40,-50,-50,-40,-40,-30],
                                 [-30,-40,-40,-50,-50,-40,-40,-30],
                                 [-30,-40,-40,-50,-50,-40,-40,-30],
                                 [-20,-30,-30,-40,-40,-30,-30,-20],
                                 [-10,-20,-20,-20,-20,-20,-20,-10],
                                 [20, 20,  0,  0,  0,  0, 20, 20],
                                 [20, 30, 10,  0,  0, 10, 30, 20]]
    
    private let kingEndTable =  [[-50,-40,-30,-20,-20,-30,-40,-50],
                                 [-30,-20,-10,  0,  0,-10,-20,-30],
                                 [-30,-10, 20, 30, 30, 20,-10,-30],
                                 [-30,-10, 30, 40, 40, 30,-10,-30],
                                 [-30,-10, 30, 40, 40, 30,-10,-30],
                                 [-30,-10, 20, 30, 30, 20,-10,-30],
                                 [-30,-30,  0,  0,  0,  0,-30,-30],
                                 [-50,-30,-30,-30,-30,-30,-30,-50]]
    
    
    
}
