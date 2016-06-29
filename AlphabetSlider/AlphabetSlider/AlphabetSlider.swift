//
//  AlphabetSlider.swift
//  AlphabetSlider
//
//  Created by Raphael on 6/24/16.
//  Copyright © 2016 Raphael. All rights reserved.
//

import Foundation

public class AlphabetSlider: UIControl {
    
    // MARK: public API and data model
    public var alphabet: [String] = "ABCDEFGHiiimmmmQRSTUVWXYZ".characters.map() { return String($0) } {
        didSet { setNeedsDisplay() }
    }
    
    public var value: Int {
        get {
            return storedValue
        }
        set {
            storedValue = newValue
            internalValue = Double(newValue)
            setNeedsDisplay()
        }
    }
    
    
    
    // MARK: public display properties.
    
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
    
    public var horizonalInset = CGFloat(10.0)
    public var baselineOffset = CGFloat(10.0)
    
    
    
    // MARK: private internal state.
    
    private var previousLocation = CGPoint()
    
    private var internalValue: Double = 0.0
    
    private var storedValue: Int = 0
    
    
    
    // MARK: UIControl overrides
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        // @todo: move the thumb layer and value to this location.
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
        
        if newValue != storedValue {
            storedValue = newValue
            self.sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
        }

        return true
    }
    
    
    
    // MARK: Initialization
    
    private func initialize() {
        print(previousLocation)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    
    // MARK: drawing code
    
    public override func drawRect(rect: CGRect) {
        guard alphabet.count > 0 else { return }

        let paragraph = NSMutableParagraphStyle()
//        paragraph.alignment = .Center
        
        // Paint over our previous drawing.
        backgroundColor?.setFill()
        
        let attributes = [
            NSForegroundColorAttributeName: fontColor,
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraph,
            NSBackgroundColorAttributeName: UIColor.orangeColor()
        ]
        let focusAttributes = [
            NSForegroundColorAttributeName: focusFontColor,
            NSFontAttributeName: focusFont,
            NSParagraphStyleAttributeName: paragraph,
            NSBackgroundColorAttributeName: UIColor.orangeColor()
        ]
        
        // Deduce the height of our letters for bottom alignment.
        let focusLetter = NSAttributedString(string: alphabet[value], attributes: focusAttributes)
        let focusLetterSize = focusLetter.size()
        let focusHeight = bounds.height - focusLetterSize.height
        let yPosition = focusLetterSize.height - baselineOffset
        
        // Deduce the width of our letters for use with drawInRect
        let letterWidth = NSAttributedString(string: "M", attributes: attributes).size().width
        
        // Deduce the width of our final letter for centering.
        let lastWidth = NSAttributedString(string: alphabet.last!, attributes: attributes).size().width
        
        // Deduce our actual spacing per letter to keep the alphabet centered.
        let workingWidth = bounds.width - (horizonalInset * 2)
        let idealSpacePerLetter = workingWidth / CGFloat(alphabet.count) // Ideal spacing for a monospace font.
        let realWidth = (idealSpacePerLetter * (CGFloat(alphabet.count) - CGFloat(1.0))) + (lastWidth / 2) // Adjusted width, subsituting the last ideal width for the actual width.
        let spacePerLetter = realWidth / (CGFloat(alphabet.count) - 1)
        
        // Deduce the inset needed to center the alphabet.
        let alphabetInset = workingWidth - spacePerLetter * (CGFloat(alphabet.count) - 1)
        
        // @todo: cache our realWidth, so we can do a ratio with the dragging locations.
        
        
        for (index, letter) in alphabet.enumerate() {
            let xPosition = spacePerLetter * CGFloat(index) + horizonalInset + alphabetInset / 2
            
            if index == storedValue {
                focusLetter.drawInRect(CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: focusLetterSize.width, height: focusHeight)))
            } else {
                let letterString = NSAttributedString(string: letter, attributes: attributes)
                letterString.drawInRect(CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: letterWidth, height: focusHeight)))
            }
        }
    }
}