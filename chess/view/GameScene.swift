import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var chess : Chess?
    
    private var activePiece : Piece?
    private var activeMoves : [Chess.ChessMove] = []
    private var activeCoord : (x:Int, y:Int)?
    
    override func sceneDidLoad() {
        
        print("GameScene loaded with size: \(self.size)")
        
        self.size = UIScreen.main.bounds.size
        
        print("Resized to: \(self.size)")
        
        chess = Chess(vh: self.size.height, vw: self.size.width)
        
        guard let board = chess?.boardSprite else { return }
        
        board.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        self.addChild(board)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let board = self.chess?.boardSprite else { return }
        
        
        
        guard chess?.lightTurn ?? false else { return }

        for touch in touches {
            for row in board.contents {
                for piece in row {
                    let location = touch.location(in: board)
                    if piece?.contains(location) ?? false {
                        
                        do {
                            self.activeCoord = self.chess?.getCoords(location.x, location.y)
                            
                            guard let coords = self.activeCoord else { continue }
                            
                            self.activeMoves = try self.chess?.getMoves(x: coords.x, y: coords.y) ?? []
                            
                            self.chess?.showMoves(moves: self.activeMoves)
                            
                        }
                        catch let error {
                            print("ERROR: \(error)")
                            continue
                        }
                        
                        activePiece = piece
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let board = self.chess?.boardSprite else { return }
        
        for touch in touches {
            activePiece?.position = touch.location(in: board)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        self.chess?.removeMoves()
        
        var found = false
        
        guard let board = self.chess?.boardSprite else { return }
        
        guard let location = touches.first?.location(in: board) else { return }
        
        guard let newCoord = self.chess?.getCoords(location.x, location.y) else { return }
        
//        guard let activeCoord = self.activeCoord else { return }
        
        for move in self.activeMoves {
            if move.dest.x == newCoord.x && move.dest.y == newCoord.y {
                chess?.makeMove(move)
                found = true
                break
            }
        }

        if !found {
            self.chess?.resetBoard()
        }
        
        self.activePiece = nil
        self.activeMoves = []
        self.activeCoord = nil
    }

    
}
