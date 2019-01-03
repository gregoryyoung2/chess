import Foundation
import SpriteKit

class Board : SKNode {
    
    override init() {
        super.init()
    }
    
    convenience init (size : CGFloat) {
        
        self.init()
        
        self.size = size
        
        var squareIsLight = true
        
        let squareSize = size / 8.0
        
        print("Square Size: \(squareSize)")
        
        for y in 0..<8 {
            for x in 0..<8 {
                let child = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
                child.position = CGPoint(x: -size/2.0 + CGFloat(x) * squareSize + squareSize/2, y: -size/2.0 + CGFloat(y) * squareSize + squareSize/2)
                child.fillColor = squareIsLight ? SKColor(red: 1.0, green: 0.99, blue: 0.82, alpha: 1.0) : SKColor(red: 0.42, green: 0.27, blue: 0.23, alpha: 1.0)
                child.strokeColor = SKColor.clear
                squareIsLight = squareIsLight != true
                self.addChild(child)
            }
            squareIsLight = squareIsLight != true
        }
        
        contents = Array(repeating: (Array(repeating: nil, count: 8)), count: 8)
        
    }
    
    public func setPiece(x: Int, y: Int, piece: Chess.Piece) {
        
        if case .null = piece {
            guard let child = contents[x][y] else { return }
            child.removeFromParent()
        }
        else {
            contents[x][y] = Piece(type: piece, size: self.size/8 * 0.9)
            let drawX : CGFloat =  CGFloat(x)
            let drawY : CGFloat = 7.0 - CGFloat(y)
            contents[x][y]!.position = CGPoint(x: -size/2.0 + drawX * self.size/8 + self.size/8/2, y: -size/2.0 + drawY * self.size/8 + self.size/8/2)
            self.addChild(contents[x][y]!)
        }
    }
    
    public func setBoard(board : [[Chess.Piece]]) {
        
        for row in contents {
            for piece in row {
                guard let piece = piece else { continue }
                piece.removeFromParent()
            }
        }
        
        for y in 0..<8 {
            for x in 0..<8 {
                setPiece(x: x, y: y, piece: board[y][x])
            }
        }
    }
    
    public func setHints(possibleMoves: [Chess.ChessMove]) {
        for point in possibleMoves {
            let coord = pointToCoordinate(point.dest)
            
            let circle = SKShapeNode(circleOfRadius: self.size/8*0.15)
            circle.strokeColor = SKColor.clear
            circle.fillColor = point.attack ? SKColor.red : SKColor.lightGray
            
            circle.position = coord
            
            hints.append(circle)
            
            self.addChild(circle)
            
            
        }
    }
    
    public func removeHints() {
        for node in hints {
            node.removeFromParent()
        }
        hints = []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func pointToCoordinate(_ point: Chess.Point) -> CGPoint {
        return self.pointToCoordinate(x: point.x, y: point.y)
    }
    
    private func pointToCoordinate(x: Int, y: Int) -> CGPoint {
        let drawX : CGFloat = CGFloat(x)
        let drawY : CGFloat = 7.0 - CGFloat(y)
        
        return CGPoint(x: -size/2.0 + drawX * self.size/8 + self.size/8/2, y: -size/2.0 + drawY * self.size/8 + self.size/8/2)
    }
    
    private(set) var size : CGFloat = 0
    
    private(set) var contents : [[Piece?]] = []
    
    private(set) var hints : [SKShapeNode] = []
    
}
