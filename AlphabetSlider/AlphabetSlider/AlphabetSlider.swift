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
    
    public var horizonalInset = CGFloat(50.0)
    public var baselineOffset = CGFloat(0.0)
    
    
    
    // MARK: private internal state.
    
    private var previousLocation = CGPoint()
    
    // Keep track of the precise value, from 0 to alphabet.count.
    private var internalValue: Double = 0.0 {
        didSet {
            internalValue = min(max(internalValue, 0), Double(alphabet.count - 1))
            let newValue = Int(internalValue)
            
            if newValue != storedValue {
                storedValue = newValue
                self.sendActionsForControlEvents(.ValueChanged)
                setNeedsDisplay()
            }
        }
    }
    
    private var storedValue: Int = 0
    
    private var workingWidth: CGFloat {
        return bounds.width - (horizonalInset * 2)
    }
    
    
    
    // MARK: UIControl overrides
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        let xPos = previousLocation.x
        
        // Convert the touched point to the drawn letter index.
        let spacePerLetter = workingWidth / CGFloat(alphabet.count + 1)
        let index = (xPos - horizonalInset - spacePerLetter / 2) / spacePerLetter

        internalValue = Double(index)
        return true
    }
    
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        let xPos = location.x
        guard xPos > horizonalInset && xPos < bounds.width - horizonalInset else { return false }
        
        // Track how much user has dragged
        let deltaDistance = Double(xPos - previousLocation.x)
        
        // Translate the touch delta into the actual working width of the drawn alphabet.
        let deltaValue = Double(alphabet.count) * deltaDistance / Double(workingWidth)
        
        previousLocation = location
        internalValue += deltaValue
        
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

        // Paint over our previous drawing.
        backgroundColor?.setFill()
        
        let attributes = [
            NSForegroundColorAttributeName: fontColor,
            NSFontAttributeName: font
        ]
        let focusAttributes = [
            NSForegroundColorAttributeName: focusFontColor,
            NSFontAttributeName: focusFont
        ]

        // Calculate spacing that will automatically center the alphabet.
        let spacePerLetter = workingWidth / CGFloat(alphabet.count + 1)
        
        for (index, letter) in alphabet.enumerate() {
            let theAttributes = index == storedValue ? focusAttributes : attributes
            let letterString = NSAttributedString(string: alphabet[index], attributes: theAttributes)
            
            let letterSize = letterString.size()
            let letterCenterDistance = letterSize.width / 2
            let yPosition = bounds.height / 2 - baselineOffset - letterSize.height / 2
            let xPosition = spacePerLetter * (CGFloat(index) + 1) + horizonalInset - letterCenterDistance
            letterString.drawInRect(CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: letterSize.width, height: letterSize.height)))
        }
    }
}