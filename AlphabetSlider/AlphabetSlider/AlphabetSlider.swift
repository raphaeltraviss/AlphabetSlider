//
//  AlphabetSlider.swift
//  AlphabetSlider
//
//  Created by Raphael on 6/24/16.
//  Copyright © 2016 Raphael. All rights reserved.
//

import Foundation

public class AlphabetSlider: UIControl {
    
    public var alphabet: [String] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map() { return String($0) } {
        didSet { setNeedsDisplay() }
    }
    
    public var fontName = ""
    public var fontSize: CGFloat = -1.0 // Intentionally invalid starting value.
    public var fontColor = UIColor.darkGrayColor()
    
    public var focusFontName = ""
    public var focusFontSize: CGFloat = -1.0
    public var focusFontColor = UIColor.lightGrayColor()
    
    public var font: UIFont { get {
        return UIFont(name: fontName, size: fontSize) ?? UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    } }
    
    public var focusFont: UIFont { get {
        return UIFont(name: fontName, size: fontSize) ?? UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    } }
    
    
    
    // MARK: private internal state.
    
    private var previousLocation = CGPoint()
    
    private var internalValue: Double = 0.0
    
    public var value: Int = 0 { didSet { setNeedsDisplay() } }
    
    
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        return true
    }
    
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // Track how much user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = Double(alphabet.count) * deltaLocation / Double(bounds.width)
        
        previousLocation = location
        

        internalValue += deltaValue
        internalValue = min(max(internalValue, 0), Double(alphabet.count - 1))
        
        let newValue = Int(internalValue)
        
        if newValue != value {
            value = newValue
            self.sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
        }

        return true
    }
    
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
//        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: [], animations: { () -> Void in
//            let roundValue = round(self.value)
//            let thumbCenter = CGPoint(x: CGFloat(roundValue) * (self.bounds.width / CGFloat(self.maximumValue)), y: self.bounds.midY)
//            self.thumbLayer.frame = CGRect(x: thumbCenter.x - self.thumbWidth / 2, y: self.tickHight + self.thumbMargin , width: self.thumbWidth, height: self.thumbWidth)
//        }) { (Bool) -> Void in
//            self.value = round(self.value)
//            self.sendActionsForControlEvents(.ValueChanged)
//        }
    }
    
    public override func drawRect(rect: CGRect) {
        guard alphabet.count > 0 else { return }
        let spacePerLetter = bounds.width / CGFloat(alphabet.count)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        
        // Paint over our previous drawing.
        backgroundColor?.setFill()
        
        let attributes = [
            NSForegroundColorAttributeName: fontColor,
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraph
        ]
        let focusAttributes = [
            NSForegroundColorAttributeName: focusFontColor,
            NSFontAttributeName: focusFont,
            NSParagraphStyleAttributeName: paragraph
        ]
        
        // Deduce the height of our letters for bottom alignment.
        let focusLetter = NSAttributedString(string: alphabet[value], attributes: focusAttributes)
        let focusLetterSize = focusLetter.size()
        let focusHeight = bounds.height - focusLetterSize.height
        
        
        var letterHeight: CGFloat?
        
        // Deduce the width of our letters for use with drawInRect
        let letterWidth = NSAttributedString(string: "M", attributes: focusAttributes).size().width
        
        
        for (index, letter) in alphabet.enumerate() {
            let xPosition = spacePerLetter * CGFloat(index)
            if index == value {
                focusLetter.drawInRect(CGRect(origin: CGPoint(x: xPosition, y: focusHeight), size: CGSize(width: letterWidth, height: focusHeight)))
            } else {
                let letterString = NSAttributedString(string: letter, attributes: attributes)
                
                // Figure out the letter height of the normal letters only once.
                if letterHeight == nil {
                    letterHeight = letterString.size().height
                }
                
                letterString.drawInRect(CGRect(origin: CGPoint(x: xPosition, y: letterHeight!), size: CGSize(width: letterWidth, height: focusHeight)))
            }
        }
    }
}