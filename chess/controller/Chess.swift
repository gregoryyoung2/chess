import Foundation
import SpriteKit

class Chess {
    
    public enum Piece {
        case null
        case pawn(Bool)
        case bishop(Bool)
        case knight(Bool)
        case rook(Bool)
        case queen(Bool)
        case king(Bool)
        
        public var isLight : Bool {
            get {
                switch self {
                case .null:
                    return false
                case .pawn(let light):
                    return light
                case .bishop(let light):
                    return light
                case .knight(let light):
                    return light
                case .rook(let light):
                    return light
                case .queen(let light):
                    return light
                case .king(let light):
                    return light
                }
            }
        }
        
        public var isNull : Bool {
            get {
                switch self {
                case .null:
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    public enum ChessError : Error {
        case wrongTurn(String)
        case nullPiece
        case somethingWrong
    }
    
    public init(vh: CGFloat, vw: CGFloat, lightIsBottom lb: Bool = true) {
        
        self.viewHeight = vh
        self.viewWidth = vw
        
        self.lightBottom = lb
        self.lightTurn = true
        
        self.boardSprite = Board(size: self.viewWidth * 0.95)
        
        self.initBoard()
        
        self.boardSprite.setBoard(board: board)
        
    }
    
    public func getMoves(x: Int, y: Int) throws -> [(x: Int, y: Int, attack: Bool)]  {
        var moves : [(x: Int, y: Int, attack: Bool)] = []
        
        guard board[y][x].isLight == lightTurn else { throw ChessError.wrongTurn("It is \(self.lightTurn ? "light" : "dark")'s turn") }
        guard !board[y][x].isNull else { throw ChessError.nullPiece }

        
        switch board[y][x] {
        case .pawn:
            if y > 0 && self.lightTurn {
                // If clear ahead, can move one forward
                if case .null = board[y-1][x] {
                    moves.append((x: x, y: y - 1, attack: false))
                    // If first move and clear ahead, can move two forward
                    if (boardSprite.contents[x][y]?.firstMove ?? false), case .null = board[y-2][x] {
                        moves.append((x: x, y: y - 2, attack: false))
                    }
                }
                // Check for top left attack
                if x > 0 {
                    if !board[y-1][x-1].isLight && !board[y-1][x-1].isNull && self.lightTurn {
                        moves.append((x: x-1, y: y - 1, attack: true))
                    }
                }
                // Check for top right attack
                if x < 7 {
                    if !board[y-1][x+1].isLight && !board[y-1][x+1].isNull && self.lightTurn {
                        moves.append((x: x+1, y: y - 1, attack: true))
                    }
                }
                break
            }
            if y < 7 && self.darkTurn {
                // If clear ahead, can move one forward
                if case .null = board[y+1][x] {
                    moves.append((x: x, y: y + 1, attack: false))
                    // If first move and clear ahead, can move two forward
                    if (boardSprite.contents[x][y]?.firstMove ?? false), case .null = board[y+2][x] {
                        moves.append((x: x, y: y + 2, attack: false))
                    }
                }
                // Check for top left attack
                if x > 0 {
                    if !board[y+1][x-1].isLight && !board[y+1][x-1].isNull && self.lightTurn {
                        moves.append((x: x-1, y: y + 1, attack: true))
                    }
                }
                // Check for top right attack
                if x < 7 {
                    if !board[y+1][x+1].isLight && !board[y+1][x+1].isNull && self.lightTurn {
                        moves.append((x: x+1, y: y + 1, attack: true))
                    }
                }
                break
            }
        case .bishop:
            let change = [[1,1], [-1, 1], [-1,-1], [1,-1]]
            for i in 0..<change.count {
                var move = (x: x + change[i][0], y: y + change[i][1], attack: false)
                while (true) {
                    if !inBounds(move.x, move.y) { break }
                    if case .null = board[move.y][move.x] {
                        moves.append(move);
                        move.x += change[i][0]
                        move.y += change[i][1]
                    }
                    else if board[move.y][move.x].isLight != lightTurn {
                        move.attack = true
                        moves.append(move)
                        break
                    }
                }
            }
            break
        case .knight:
            let change = [[2,1], [-2,1], [-2,-1], [2,-1], [1,2], [-1,2], [1,-2], [-1, -2]]
            for i in change {
                if !inBounds(x + i[0], y + i[1]) { continue }
                if board[y+i[1]][x+i[0]].isLight == self.lightTurn { continue }
                moves.append((x: x + i[0], y: y + i[1], attack: !board[y+i[1]][x+i[0]].isNull && board[y+i[1]][x+i[0]].isLight != self.lightTurn))
            }
            break
        case .rook:
            let change = [[0,1], [1,0], [-1, 0], [0, -1]]
            for i in 0..<change.count {
                var move = (x: x + change[i][0], y: y + change[i][1], attack: false)
                while (true) {
                    if !inBounds(move.x, move.y) { break }
                    if case .null = board[move.y][move.x] {
                        moves.append(move);
                        move.x += change[i][0]
                        move.y += change[i][1]
                    }
                    else if board[move.y][move.x].isLight != lightTurn {
                        move.attack = true
                        moves.append(move)
                        break
                    }
                }
            }
        case .queen:
            let change = [[0,1], [1,0], [-1, 0], [0, -1], [1,1], [-1, 1], [-1,-1], [1,-1]]
            for i in 0..<change.count {
                var move = (x: x + change[i][0], y: y + change[i][1], attack: false)
                while (true) {
                    if !inBounds(move.x, move.y) { break }
                    if case .null = board[move.y][move.x] {
                        moves.append(move);
                        move.x += change[i][0]
                        move.y += change[i][1]
                    }
                    else if board[move.y][move.x].isLight != lightTurn {
                        move.attack = true
                        moves.append(move)
                        break
                    }
                }
            }
        case .king:
            let change = [[0,1], [1,0], [-1, 0], [0, -1], [1,1], [-1, 1], [-1,-1], [1,-1]]
            for i in change {
                if !inBounds(x + i[0], y + i[1]) { continue }
                if board[y+i[1]][x+i[0]].isLight == self.lightTurn { continue }
                moves.append((x: x + i[0], y: y + i[1], attack: !board[y+i[1]][x+i[0]].isNull && board[y+i[1]][x+i[0]].isLight != self.lightTurn))
            }
        case .null:
            throw ChessError.somethingWrong
        }
        
        return moves
    }
    
    public func getCoords(_ x: CGFloat, _ y: CGFloat) -> (x: Int, y: Int) {
        
        let x = x + boardSprite.size/2
        let y = y + boardSprite.size/2
        
        var newX = (x / (boardSprite.size/8.0))
        var newY = (y / (boardSprite.size/8.0))
        
        newX.round(.down)
        newY.round(.down)
        
        let val = (x: Int(newX), y: 7 - Int(newY))

        return val
    }
    
    public func updatePosition(oldX: Int, oldY: Int, newX: Int, newY: Int) {
        board[newY][newX] = board[oldY][oldX]
        board[oldY][oldX] = .null
        boardSprite.setBoard(board: board)
        
        boardSprite.contents[newX][newY]?.firstMove = false
    }
    
    public func resetBoard() {
        boardSprite.setBoard(board: board)
    }
    
    public func showMoves(moves: [(x: Int, y: Int, attack: Bool)]) {
        self.boardSprite.setHints(possibleMoves: moves)
    }
    
    public func removeMoves() {
        self.boardSprite.removeHints()
    }
    
    private func inBounds(_ x: Int, _ y: Int) -> Bool {
        if x < 8 && x >= 0 && y < 8 && y >= 0 { return true }
        else { return false }
    }
    
    
    
    private func initBoard() {
        
        if self.lightBottom {
            self.board.append([.rook(false), .knight(false), .bishop(false), .queen(false), .king(false), .bishop(false), .knight(false), .rook(false)])
        }
        else {
            self.board.append([.rook(true), .knight(true), .bishop(true), .king(true), .queen(true), .bishop(true), .knight(true), .rook(true)])
        }
    
        self.board.append(Array(repeating: .pawn(!self.lightBottom), count: 8))
    
        for _ in 1...4 {
            self.board.append(Array(repeating: .null, count: 8))
        }
    
        self.board.append(Array(repeating: .pawn(self.lightBottom), count: 8))
    
        if self.lightBottom {
            self.board.append([.rook(true), .knight(true), .bishop(true), .king(true), .queen(true), .bishop(true), .knight(true), .rook(true)])
        }
        else {
            self.board.append([.rook(false), .knight(false), .bishop(false), .queen(false), .king(false), .bishop(false), .knight(false), .rook(false)])
        }
        
    }
    
    private(set) var viewWidth : CGFloat
    private(set) var viewHeight : CGFloat
    
    private(set) var boardSprite : Board
    
    
    private(set) var lightTurn : Bool
   
    private(set) var lightBottom : Bool
    
    public var darkTurn : Bool { get { return !lightTurn } }
    public var darkBottom : Bool { get { return !lightBottom } }
    
    private(set) var board : [[Piece]] = []
   
    
}
