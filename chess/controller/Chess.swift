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
        
        public static func ==(lhs: Piece, rhs: Piece) -> Bool {
            switch (lhs, rhs) {
            case let (.pawn(l), .pawn(r)),
                 let (.bishop(l), .bishop(r)),
                 let (.knight(l), .knight(r)),
                 let (.rook(l), .rook(r)),
                 let (.queen(l), .queen(r)),
                 let (.king(l), .king(r)):
                return l == r
            case (.null, .null):
                return true
            default:
                return false
            }
        }
        
        public func getBaseValue() -> Int {
            switch self {
            case .null:
                return 0
            case .pawn(let l):
                return 100 * (l ? 1 : -1)
            case .bishop(let l):
                return 333 * (l ? 1 : -1)
            case .knight(let l):
                return 320 * (l ? 1 : -1)
            case .rook(let l):
                return 510 * (l ? 1 : -1)
            case .queen(let l):
                return 880 * (l ? 1 : -1)
            case .king(let l):
                return 8800 * (l ? 1 : -1)
            }
        }
        
    }
    
    public enum ChessError : Error {
        case wrongTurn(String)
        case nullPiece
        case somethingWrong
        case pieceNotFound
    }
    
    struct ChessHistory {
        
        public init (move: ChessMove, first: Piece, second: Piece) {
            self.first.pos = move.origin
            self.first.piece = first
            
            self.second.pos = move.dest
            self.second.piece = second
        }
        
        var first: (pos: Point, piece: Piece)
        var second: (pos: Point, piece: Piece)
    }
    
    struct Point {
        
        public init (_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
        
        public var x: Int
        public var y: Int
    }
    
    struct ChessMove {
        
        public init (origin o : Point, dest d : Point, attack a : Bool = false) {
            self.origin = o
            self.dest = d
            self.attack = a
        }
        
        public var origin : Point
        public var dest : Point
        public var attack : Bool
    }
    
    public init(vh: CGFloat, vw: CGFloat, lightIsBottom lb: Bool = true) {
        
        self.viewHeight = vh
        self.viewWidth = vw
        
        self.lightBottom = lb
        self.lightTurn = false
        
        self.boardSprite = Board(size: self.viewWidth * 0.95)
        
        self.initBoard()
        
        self.boardSprite.setBoard(board: board)
        
        
        players.append(HumanPlayer())
//        players.append(RandomAI(isLight: false, chess: self))
        players.append(MinimaxAI(isLight: false, chess: self))
        
        nextTurn()
    }
    
    public func nextTurn() {
        lightTurn = lightTurn != true
        self.boardSprite.toggleCheck()
        if lightTurn {
            print("Light's turn")
            if isInCheck(light: lightTurn) {
                self.boardSprite.toggleCheck(pos: try? self.findPiece(piece: .king(true)))
            }
        }
        else {
            print("Dark's turn")
            players[1].move()
        }
    }
    
    public func getMoves(x: Int, y: Int, board: [[Piece]]? = nil) throws -> [ChessMove]  {
        
        var board = board ?? self.board
        
        var moves : [ChessMove] = []
        
        guard board[y][x].isLight == lightTurn else { throw ChessError.wrongTurn("It is \(self.lightTurn ? "light" : "dark")'s turn") }
        guard !board[y][x].isNull else { throw ChessError.nullPiece }

        let origin = Point(x, y)
        
        switch board[y][x] {
        case .pawn:
//            print("Calculating moves for pawn...")
            findPawnMoves(origin: origin, moves: &moves, board: board)
        case .bishop:
//            print("Calculating moves for bishop...")
            findLineMoves(origin: origin, change: self.diagChange, moves: &moves, board: board)
            break
        case .knight:
//            print("Calculating moves for knight...")
            findSingleMoves(origin: origin, change: self.knightChange, moves: &moves, board: board)
            break
        case .rook:
//            print("Calculating moves for rook...")
            findLineMoves(origin: origin, change: self.plusChange, moves: &moves, board: board)
            break
        case .queen:
//            print("Calculating moves for queen...")
            findLineMoves(origin: origin, change: self.eightChange, moves: &moves, board: board)
            break
        case .king:
//            print("Calculating moves for king...")
            findSingleMoves(origin: origin, change: self.eightChange, moves: &moves, board: board)
            break
        case .null:
            throw ChessError.somethingWrong
        }
        
        self.pruneCheck(moves: &moves, board: board)
        
        return moves
    }
    
    private func findPawnMoves(origin: Point, moves: inout [ChessMove], board : [[Piece]]? = nil) {
        
        let board = board ?? self.board
        
        let x = origin.x
        let y = origin.y
        if y > 0 && self.lightTurn {
            // If clear ahead, can move one forward
            if case .null = board[y-1][x] {
                moves.append(ChessMove(origin: origin, dest: Point(x, y - 1), attack: false))
                // If first move and clear ahead, can move two forward
                if (y == 6), case .null = board[y-2][x] {
                    moves.append(ChessMove(origin: origin, dest: Point(x, y - 2), attack: false))
                }
            }
            // Check for top left attack
            if x > 0 {
                if !board[y-1][x-1].isLight && !board[y-1][x-1].isNull && self.lightTurn {
                    moves.append(ChessMove(origin: origin, dest: Point(x - 1, y - 1), attack: true))
                }
            }
            // Check for top right attack
            if x < 7 {
                if !board[y-1][x+1].isLight && !board[y-1][x+1].isNull && self.lightTurn {
                    moves.append(ChessMove(origin: origin, dest: Point(x + 1, y - 1), attack: true))
                }
            }
        }
        else if y < 7 && self.darkTurn {
            // If clear ahead, can move one forward
            if case .null = board[y+1][x] {
                moves.append(ChessMove(origin: origin, dest: Point(x, y + 1), attack: false))
                // If first move and clear ahead, can move two forward
                if ( y == 1 ), case .null = board[y+2][x] {
                    moves.append(ChessMove(origin: origin, dest: Point(x, y + 2), attack: false))
                }
            }
            // Check for top left attack
            if x > 0 {
                if board[y+1][x-1].isLight && !board[y+1][x-1].isNull && self.darkTurn {
                    moves.append(ChessMove(origin: origin, dest: Point(x - 1, y + 1), attack: true))
                }
            }
            // Check for top right attack
            if x < 7 {
                if board[y+1][x+1].isLight && !board[y+1][x+1].isNull && self.darkTurn {
                    moves.append(ChessMove(origin: origin, dest: Point(x + 1, y + 1), attack: true))
                }
            }
        }
        
    }
    
    private func findLineMoves(origin: Point, change : [[Int]], moves : inout [ChessMove], board : [[Piece]]? = nil) {
        
        let board = board ?? self.board
        
        for i in 0..<change.count {
            var move = ChessMove(origin: origin, dest: Point(origin.x + change[i][0], origin.y + change[i][1]), attack: false)
            while (true) {
                if !inBounds(move.dest.x, move.dest.y) { break }
                if case .null = board[move.dest.y][move.dest.x] {
                    moves.append(move);
                    move.dest.x += change[i][0]
                    move.dest.y += change[i][1]
                }
                else if board[move.dest.y][move.dest.x].isLight != lightTurn {
                    move.attack = true
                    moves.append(move)
                    break
                }
                else {
                    break
                }
            }
        }
    }
    
    private func findSingleMoves(origin o: Point, change: [[Int]], moves: inout [ChessMove], board : [[Piece]]? = nil) {
        
        let board = board ?? self.board
        
        for i in change {
            if !inBounds(o.x + i[0], o.y + i[1]) { continue }
            if board[o.y+i[1]][o.x+i[0]].isLight == self.lightTurn { continue }
            moves.append(ChessMove(origin: o, dest: Point(o.x + i[0], o.y + i[1]), attack: !board[o.y+i[1]][o.x+i[0]].isNull && board[o.y+i[1]][o.x+i[0]].isLight != self.lightTurn))
        }
    }
    
    public func getAllMoves(forLight light : Bool? = nil, board : [[Piece]]? = nil) -> [ChessMove] {
        
        let board = board ?? self.board
        
        let prevLightTurn = self.lightTurn
        
        if let isLight = light {
            self.lightTurn = isLight
        }
        
        var moves : [ChessMove] = []
        
        for r in 0..<self.board.count {
            for c in 0..<self.board[r].count {
                do {
                    moves.append(contentsOf: try self.getMoves(x: c, y: r, board: board))
                }
                catch {
                    continue
                }
            }
        }
        
        self.lightTurn = prevLightTurn
        
        return moves
        
    }
    
    private func pruneCheck(moves: inout [ChessMove], board : [[Piece]]? = nil) {
        
        var board = board ?? self.board
        
        for i in (0..<moves.count).reversed() {
            let move = moves[i]
            let prev = board[move.origin.y][move.origin.x]
            let dest = board[move.dest.y][move.dest.x]
            
            board[move.dest.y][move.dest.x] = prev
            board[move.origin.y][move.origin.x] = .null
            
            if isInCheck(light: lightTurn, board: board) {
                moves.remove(at: i)
            }
            
            board[move.dest.y][move.dest.x] = dest
            board[move.origin.y][move.origin.x] = prev
            
        }
        
    }
    
    public func isInCheck(light : Bool, board : [[Piece]]? = nil) -> Bool {
        
        let board = board ?? self.board
        
        let opposing = light != true
        
        do {
            
            let kingPos = try findPiece(piece: .king(light), board: board)
            
            // First, check for a threatening knight
            for change in self.knightChange {
                if inBounds(kingPos.x+change[0], kingPos.y + change[1]) && board[kingPos.y + change[1]][kingPos.x+change[0]] == .knight(opposing) {
                    return true
                }
            }
            
            // Now, lets check for kings (this is only helpful for pruning)
            for change in self.eightChange {
                if inBounds(kingPos.x+change[0], kingPos.y + change[1]) && board[kingPos.y + change[1]][kingPos.x+change[0]] == .king(opposing) {
                    return true
                }
            }
            
            // Now, lets check the diagonals for queens and bishops
            for change in self.diagChange {
                var current = Point(kingPos.x + change[0], kingPos.y + change[1])
                while (true) {
                    if !inBounds(current.x, current.y) { break }
                    if case .null = board[current.y][current.x] {
                        current.x += change[0]
                        current.y += change[1]
                    }
                    else if board[current.y][current.x] == .queen(opposing) || board[current.y][current.x] == .bishop(opposing) {
                        return true
                    }
                    else {
                        break
                    }
                }
            }
            
            // Now, check the horiz/verts for queens and rooks
            for change in self.plusChange {
                var current = Point(kingPos.x + change[0], kingPos.y + change[1])
                while (true) {
                    if !inBounds(current.x, current.y) { break }
                    if case .null = board[current.y][current.x] {
                        current.x += change[0]
                        current.y += change[1]
                    }
                    else if board[current.y][current.x] == .queen(opposing) || board[current.y][current.x] == .rook(opposing) {
                        return true
                    }
                    else {
                        break
                    }
                }
            }
            
            // Lastly, the pawns...
            let y = kingPos.y + (light ? -1 : 1)
            
            if inBounds(kingPos.x-1, y) && board[y][kingPos.x-1] == .pawn(opposing) {
                return true
            }
            
            if inBounds(kingPos.x+1, y) && board[y][kingPos.x+1] == .pawn(opposing) {
                return true
            }
            
        }
        catch {
//            print("ERROR: Could not find king")
        }
        
        return false
    }
    
    public func findPiece(piece: Piece, board: [[Piece]]? = nil) throws -> Point {
        
        let board = board ?? self.board
        
        for r in 0..<board.count {
            for c in 0..<board[r].count {
                if piece == board[r][c] {
                    return Point(c,r)
                }
            }
        }
        throw ChessError.pieceNotFound
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
    
    public func makeMove(_ move: ChessMove) {
        
        history.append(ChessHistory(move: move, first: board[move.origin.y][move.origin.x], second: board[move.dest.y][move.dest.x]))
        
        updatePosition(oldX: move.origin.x, oldY: move.origin.y, newX: move.dest.x, newY: move.dest.y)
        
        defer { nextTurn() }
    }
    
    public func updatePosition(oldX: Int, oldY: Int, newX: Int, newY: Int) {
        board[newY][newX] = board[oldY][oldX]
        board[oldY][oldX] = .null
        boardSprite.setBoard(board: board)
    }
    
    public func resetBoard() {
        boardSprite.setBoard(board: board)
    }
    
    public func showMoves(moves: [ChessMove]) {
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
            self.board.append([.rook(false), .knight(false), .bishop(false), .king(false), .queen(false), .bishop(false), .knight(false), .rook(false)])
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
            self.board.append([.rook(false), .knight(false), .bishop(false), .king(false), .queen(false), .bishop(false), .knight(false), .rook(false)])
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
   
    private(set) var players : [Player] = []
    
    private(set) var history: [ChessHistory] = []
    
    private let diagChange = [[1,1], [-1, 1], [-1,-1], [1,-1]]
    private let plusChange = [[0,1], [1,0], [-1, 0], [0, -1]]
    private let eightChange = [[0,1], [1,0], [-1, 0], [0, -1], [1,1], [-1, 1], [-1,-1], [1,-1]]
    private let knightChange = [[2,1], [-2,1], [-2,-1], [2,-1], [1,2], [-1,2], [1,-2], [-1, -2]]
    
}
