import UIKit

class LocationIndicator: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    

    
    // MARK: graphics
    
    override func drawInContext(ctx: CGContext) {
        print("we are drawing!")
        //// Color Declarations
        let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    
        
        //// Bezier Drawing
        
        UIGraphicsPushContext(ctx)
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 29.59, y: 14.3))
        bezierPath.addLineToPoint(CGPoint(x: 24.62, y: 14.3))
        bezierPath.addCurveToPoint(CGPoint(x: 19.89, y: 14.7), controlPoint1: CGPoint(x: 22.3, y: 14.3), controlPoint2: CGPoint(x: 21.14, y: 14.3))
        bezierPath.addCurveToPoint(CGPoint(x: 16.96, y: 17.63), controlPoint1: CGPoint(x: 18.53, y: 15.19), controlPoint2: CGPoint(x: 17.45, y: 16.27))
        bezierPath.addLineToPoint(CGPoint(x: 16.91, y: 17.83))
        bezierPath.addCurveToPoint(CGPoint(x: 16.56, y: 22.36), controlPoint1: CGPoint(x: 16.56, y: 18.88), controlPoint2: CGPoint(x: 16.56, y: 20.04))
        bezierPath.addLineToPoint(CGPoint(x: 16.56, y: 31.84))
        bezierPath.addCurveToPoint(CGPoint(x: 16.96, y: 36.57), controlPoint1: CGPoint(x: 16.56, y: 34.16), controlPoint2: CGPoint(x: 16.56, y: 35.32))
        bezierPath.addCurveToPoint(CGPoint(x: 19.89, y: 39.51), controlPoint1: CGPoint(x: 17.45, y: 37.94), controlPoint2: CGPoint(x: 18.53, y: 39.01))
        bezierPath.addLineToPoint(CGPoint(x: 20.09, y: 39.55))
        bezierPath.addCurveToPoint(CGPoint(x: 24.62, y: 39.9), controlPoint1: CGPoint(x: 21.14, y: 39.9), controlPoint2: CGPoint(x: 22.3, y: 39.9))
        bezierPath.addLineToPoint(CGPoint(x: 29.59, y: 39.9))
        bezierPath.addCurveToPoint(CGPoint(x: 34.31, y: 39.51), controlPoint1: CGPoint(x: 31.91, y: 39.9), controlPoint2: CGPoint(x: 33.07, y: 39.9))
        bezierPath.addCurveToPoint(CGPoint(x: 37.25, y: 36.57), controlPoint1: CGPoint(x: 35.68, y: 39.01), controlPoint2: CGPoint(x: 36.75, y: 37.94))
        bezierPath.addLineToPoint(CGPoint(x: 37.3, y: 36.37))
        bezierPath.addCurveToPoint(CGPoint(x: 37.64, y: 31.84), controlPoint1: CGPoint(x: 37.64, y: 35.32), controlPoint2: CGPoint(x: 37.64, y: 34.16))
        bezierPath.addLineToPoint(CGPoint(x: 37.64, y: 22.36))
        bezierPath.addCurveToPoint(CGPoint(x: 37.25, y: 17.63), controlPoint1: CGPoint(x: 37.64, y: 20.04), controlPoint2: CGPoint(x: 37.64, y: 18.88))
        bezierPath.addCurveToPoint(CGPoint(x: 34.31, y: 14.7), controlPoint1: CGPoint(x: 36.75, y: 16.27), controlPoint2: CGPoint(x: 35.68, y: 15.19))
        bezierPath.addLineToPoint(CGPoint(x: 34.11, y: 14.65))
        bezierPath.addCurveToPoint(CGPoint(x: 29.59, y: 14.3), controlPoint1: CGPoint(x: 33.07, y: 14.3), controlPoint2: CGPoint(x: 31.91, y: 14.3))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 54.2, y: 27.1))
        bezierPath.addCurveToPoint(CGPoint(x: 27.1, y: 54.2), controlPoint1: CGPoint(x: 54.2, y: 42.07), controlPoint2: CGPoint(x: 42.07, y: 54.2))
        bezierPath.addCurveToPoint(CGPoint(x: -0, y: 27.1), controlPoint1: CGPoint(x: 12.13, y: 54.2), controlPoint2: CGPoint(x: -0, y: 42.07))
        bezierPath.addCurveToPoint(CGPoint(x: 7.56, y: 8.32), controlPoint1: CGPoint(x: -0, y: 19.81), controlPoint2: CGPoint(x: 2.88, y: 13.19))
        bezierPath.addCurveToPoint(CGPoint(x: 27.1, y: 0), controlPoint1: CGPoint(x: 12.49, y: 3.19), controlPoint2: CGPoint(x: 19.42, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: 54.2, y: 27.1), controlPoint1: CGPoint(x: 42.07, y: 0), controlPoint2: CGPoint(x: 54.2, y: 12.13))
        bezierPath.closePath()
        color.setFill()
        bezierPath.fill()
        
        UIGraphicsPopContext()
    }
}
