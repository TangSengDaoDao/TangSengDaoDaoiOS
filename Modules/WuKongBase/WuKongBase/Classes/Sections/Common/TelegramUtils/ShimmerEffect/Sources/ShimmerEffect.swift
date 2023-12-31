import UIKit
import AsyncDisplayKit

final class ShimmerEffectForegroundNode: ASDisplayNode {
    private var currentBackgroundColor: UIColor?
    private var currentForegroundColor: UIColor?
    private var currentHorizontal: Bool?
    private let imageNodeContainer: ASDisplayNode
    private let imageNode: ASImageNode
    
    private var absoluteLocation: (CGRect, CGSize)?
    private var isCurrentlyInHierarchy = false
    private var shouldBeAnimating = false
    
    override init() {
        self.imageNodeContainer = ASDisplayNode()
        self.imageNodeContainer.isLayerBacked = true
        
        self.imageNode = ASImageNode()
        self.imageNode.isLayerBacked = true
        self.imageNode.displaysAsynchronously = false
        self.imageNode.displayWithoutProcessing = true
        self.imageNode.contentMode = .scaleToFill
        
        super.init()
        
        self.isLayerBacked = true
        self.clipsToBounds = true
        
        self.imageNodeContainer.addSubnode(self.imageNode)
        self.addSubnode(self.imageNodeContainer)
    }
    
    override func didEnterHierarchy() {
        super.didEnterHierarchy()
        
        self.isCurrentlyInHierarchy = true
        self.updateAnimation()
    }
    
    override func didExitHierarchy() {
        super.didExitHierarchy()
        
        self.isCurrentlyInHierarchy = false
        self.updateAnimation()
    }
    
    func update(backgroundColor: UIColor, foregroundColor: UIColor, horizontal: Bool = false) {
        if let currentBackgroundColor = self.currentBackgroundColor, currentBackgroundColor.isEqual(backgroundColor), let currentForegroundColor = self.currentForegroundColor, currentForegroundColor.isEqual(foregroundColor), self.currentHorizontal == horizontal {
            return
        }
        self.currentBackgroundColor = backgroundColor
        self.currentForegroundColor = foregroundColor
        self.currentHorizontal = horizontal
        
        let image: UIImage?
        if horizontal {
            image = generateImage(CGSize(width: 320.0, height: 16.0), opaque: false, scale: 1.0, rotatedContext: { size, context in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setFillColor(backgroundColor.cgColor)
                context.fill(CGRect(origin: CGPoint(), size: size))
                
                context.clip(to: CGRect(origin: CGPoint(), size: size))
                
                let transparentColor = foregroundColor.withAlphaComponent(0.0).cgColor
                let peakColor = foregroundColor.cgColor
                
                var locations: [CGFloat] = [0.0, 0.5, 1.0]
                let colors: [CGColor] = [transparentColor, peakColor, transparentColor]
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)!
                
                context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: size.width, y: 0.0), options: CGGradientDrawingOptions())
            })
        } else {
            image = generateImage(CGSize(width: 16.0, height: 320.0), opaque: false, scale: 1.0, rotatedContext: { size, context in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setFillColor(backgroundColor.cgColor)
                context.fill(CGRect(origin: CGPoint(), size: size))
                
                context.clip(to: CGRect(origin: CGPoint(), size: size))
                
                let transparentColor = foregroundColor.withAlphaComponent(0.0).cgColor
                let peakColor = foregroundColor.cgColor
                
                var locations: [CGFloat] = [0.0, 0.5, 1.0]
                let colors: [CGColor] = [transparentColor, peakColor, transparentColor]
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)!
                
                context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: size.height), options: CGGradientDrawingOptions())
            })
        }
        self.imageNode.image = image
        self.updateAnimation()
    }
    
    func updateAbsoluteRect(_ rect: CGRect, within containerSize: CGSize) {
        if let absoluteLocation = self.absoluteLocation, absoluteLocation.0 == rect && absoluteLocation.1 == containerSize {
            return
        }
        let sizeUpdated = self.absoluteLocation?.1 != containerSize
        let frameUpdated = self.absoluteLocation?.0 != rect
        self.absoluteLocation = (rect, containerSize)
        
        if sizeUpdated {
            if self.shouldBeAnimating {
                self.imageNode.layer.removeAnimation(forKey: "shimmer")
                self.addImageAnimation()
            } else {
                self.updateAnimation()
            }
        }
        
        if frameUpdated {
            self.imageNodeContainer.frame = CGRect(origin: CGPoint(x: -rect.minX, y: -rect.minY), size: containerSize)
        }
    }
    
    private func updateAnimation() {
        let shouldBeAnimating = self.isCurrentlyInHierarchy && self.absoluteLocation != nil && self.currentHorizontal != nil
        if shouldBeAnimating != self.shouldBeAnimating {
            self.shouldBeAnimating = shouldBeAnimating
            if shouldBeAnimating {
                self.addImageAnimation()
            } else {
                self.imageNode.layer.removeAnimation(forKey: "shimmer")
            }
        }
    }
    
    private func addImageAnimation() {
        guard let containerSize = self.absoluteLocation?.1, let horizontal = self.currentHorizontal else {
            return
        }
        
        if horizontal {
            let gradientHeight: CGFloat = 320.0
            self.imageNode.frame = CGRect(origin: CGPoint(x: -gradientHeight, y: 0.0), size: CGSize(width: gradientHeight, height: containerSize.height))
            let animation = self.imageNode.layer.makeAnimation(from: 0.0 as NSNumber, to: (containerSize.width + gradientHeight) as NSNumber, keyPath: "position.x", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: 1.3 * 1.0, delay: 0.0, mediaTimingFunction: nil, removeOnCompletion: true, additive: true)
            animation.repeatCount = Float.infinity
            animation.beginTime = 1.0
            self.imageNode.layer.add(animation, forKey: "shimmer")
        } else {
            let gradientHeight: CGFloat = 250.0
            self.imageNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -gradientHeight), size: CGSize(width: containerSize.width, height: gradientHeight))
            let animation = self.imageNode.layer.makeAnimation(from: 0.0 as NSNumber, to: (containerSize.height + gradientHeight) as NSNumber, keyPath: "position.y", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: 1.3 * 1.0, delay: 0.0, mediaTimingFunction: nil, removeOnCompletion: true, additive: true)
            animation.repeatCount = Float.infinity
            animation.beginTime = 1.0
            self.imageNode.layer.add(animation, forKey: "shimmer")
        }
    }
}

public final class ShimmerEffectNode: ASDisplayNode {
    public enum Shape: Equatable {
        case circle(CGRect)
        case roundedRectLine(startPoint: CGPoint, width: CGFloat, diameter: CGFloat)
        case roundedRect(rect: CGRect, cornerRadius: CGFloat)
        case rect(rect: CGRect)
        case image(image: UIImage, rect: CGRect)
    }
    
    private let backgroundNode: ASDisplayNode
    private let effectNode: ShimmerEffectForegroundNode
    private let foregroundNode: ASImageNode
    
    private var currentShapes: [Shape] = []
    private var currentBackgroundColor: UIColor?
    private var currentForegroundColor: UIColor?
    private var currentShimmeringColor: UIColor?
    private var currentHorizontal: Bool?
    private var currentSize = CGSize()
    
    override public init() {
        self.backgroundNode = ASDisplayNode()
        
        self.effectNode = ShimmerEffectForegroundNode()
        
        self.foregroundNode = ASImageNode()
        self.foregroundNode.displaysAsynchronously = false
        self.foregroundNode.displayWithoutProcessing = true
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.effectNode)
        self.addSubnode(self.foregroundNode)
    }
    
    public func updateAbsoluteRect(_ rect: CGRect, within containerSize: CGSize) {
        self.effectNode.updateAbsoluteRect(rect, within: containerSize)
    }
    
    public func update(backgroundColor: UIColor, foregroundColor: UIColor, shimmeringColor: UIColor, shapes: [Shape], horizontal: Bool = false, size: CGSize) {
        if self.currentShapes == shapes, let currentBackgroundColor = self.currentBackgroundColor, currentBackgroundColor.isEqual(backgroundColor), let currentForegroundColor = self.currentForegroundColor, currentForegroundColor.isEqual(foregroundColor), let currentShimmeringColor = self.currentShimmeringColor, currentShimmeringColor.isEqual(shimmeringColor), horizontal == self.currentHorizontal, self.currentSize == size {
            return
        }
        
        self.currentBackgroundColor = backgroundColor
        self.currentForegroundColor = foregroundColor
        self.currentShimmeringColor = shimmeringColor
        self.currentShapes = shapes
        self.currentHorizontal = horizontal
        self.currentSize = size
        
        self.backgroundNode.backgroundColor = foregroundColor
        
        self.effectNode.update(backgroundColor: foregroundColor, foregroundColor: shimmeringColor, horizontal: horizontal)
        
        self.foregroundNode.image = generateImage(size, rotatedContext: { size, context in
            context.setFillColor(backgroundColor.cgColor)
            context.setBlendMode(.copy)
            context.fill(CGRect(origin: CGPoint(), size: size))
            
            context.setFillColor(UIColor.clear.cgColor)
            for shape in shapes {
                switch shape {
                case let .circle(frame):
                    context.fillEllipse(in: frame)
                case let .roundedRectLine(startPoint, width, diameter):
                    context.fillEllipse(in: CGRect(origin: startPoint, size: CGSize(width: diameter, height: diameter)))
                    context.fillEllipse(in: CGRect(origin: CGPoint(x: startPoint.x + width - diameter, y: startPoint.y), size: CGSize(width: diameter, height: diameter)))
                    context.fill(CGRect(origin: CGPoint(x: startPoint.x + diameter / 2.0, y: startPoint.y), size: CGSize(width: width - diameter, height: diameter)))
                case let .roundedRect(rect, radius):
                    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
                    UIGraphicsPushContext(context)
                    path.fill()
                    UIGraphicsPopContext()
                case let .rect(rect):
                    context.fill(rect)
                case let .image(image, rect):
                    if let image = image.cgImage {
                        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
                        context.scaleBy(x: 1.0, y: -1.0)
                        context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)
                        context.clip(to: rect, mask: image)
                        context.fill(rect)
                    }
                }
            }
        })
        
        self.backgroundNode.frame = CGRect(origin: CGPoint(), size: size)
        self.foregroundNode.frame = CGRect(origin: CGPoint(), size: size)
        self.effectNode.frame = CGRect(origin: CGPoint(), size: size)
    }
}
