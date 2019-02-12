import Foundation
import SpriteKit

class Piece : SKNode {
    
    override init() {
        super.init()
    }
    
    convenience init (type : Chess.Piece, size: CGFloat) {
        
        self.init()
        
        self.type = type
        
        let sprite = SKSpriteNode()
        
        switch type {
        case .null:
            sprite.texture = nil
        case .pawn (let light):
            sprite.texture = SKTexture(imageNamed: "pawn-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        case .bishop (let light):
            sprite.texture = SKTexture(imageNamed: "bishop-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        case .knight (let light):
            sprite.texture = SKTexture(imageNamed: "knight-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        case .rook (let light):
            sprite.texture = SKTexture(imageNamed: "rook-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        case.queen (let light):
            sprite.texture = SKTexture(imageNamed: "queen-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        case.king (let light):
            sprite.texture = SKTexture(imageNamed: "king-dark.png")
            sprite.color = light ? SKColor.white : SKColor.black
        }
       
        sprite.colorBlendFactor = 1.0
        sprite.size = CGSize(width: size, height: size)
        
        self.addChild(sprite)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private(set) var type : Chess.Piece = .null
    public var firstMove : Bool = true
    
    
}
