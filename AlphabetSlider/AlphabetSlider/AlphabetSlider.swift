// AlphabetSlider incremental label slider
// Copyright (c) 2016, Raphael Spencer
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

@IBDesignable
open class AlphabetSlider: UIControl {
    
    // MARK: public API and data model
    open var alphabet: [String] = "12345ABCDEFG!@#$%^&*()_.XYZ".characters.map() { return String($0) } {
        didSet { setNeedsDisplay() }
    }
    
    open var value: Int {
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
    
    // Interface Builder does not support setting UIFont directly; supply both a valid font name, and a size.
    @IBInspectable open var fontName: String = ""
    @IBInspectable open var fontSize: CGFloat = -1.0 // Intentionally invalid values as default.
    @IBInspectable open var fontColor: UIColor = UIColor.darkGray
    
    @IBInspectable open var focusFontName: String = ""
    @IBInspectable open var focusFontSize: CGFloat = -1.0
    @IBInspectable open var focusFontColor: UIColor = UIColor.lightGray
    
    fileprivate var font: UIFont { get {
        return UIFont(name: fontName, size: fontSize) ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    } }
    
    fileprivate var focusFont: UIFont { get {
        return UIFont(name: focusFontName, size: focusFontSize) ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
    } }
    
    @IBInspectable open var horizonalInset: CGFloat = 0.0
    @IBInspectable open var baselineOffset: CGFloat = 0.0
    
    
    
    // MARK: private internal state.
    
    fileprivate var previousLocation = CGPoint()
    
    // Keep track of the precise value, from 0 to alphabet.count.
    fileprivate var internalValue: Double = 0.0 {
        didSet {
            internalValue = min(max(internalValue, 0), Double(alphabet.count - 1))
            let newValue = Int(internalValue)
            
            if newValue != storedValue {
                storedValue = newValue
                self.sendActions(for: .valueChanged)
                setNeedsDisplay()
            }
        }
    }
    
    fileprivate var storedValue: Int = 0
    
    fileprivate var workingWidth: CGFloat {
        return bounds.width - (horizonalInset * 2)
    }
    
    
    
    // MARK: UIControl overrides
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        let xPos = previousLocation.x
        
        // Convert the touched point to the drawn letter index.
        let spacePerLetter = workingWidth / CGFloat(alphabet.count + 1)
        let index = (xPos - horizonalInset - spacePerLetter / 2) / spacePerLetter

        internalValue = Double(index)
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let xPos = location.x
        
        // If the touch was out-of-bounds, end tracking.
        guard xPos > horizonalInset && xPos < bounds.width - horizonalInset else { return false }
        
        // Track how much the user has dragged, in global coordinate space.
        let deltaDistance = Double(xPos - previousLocation.x)
        
        // Translate the touch delta into the actual working width of the drawn alphabet.
        let deltaValue = (Double(alphabet.count) + 1) * deltaDistance / Double(workingWidth)
        
        previousLocation = location
        internalValue += deltaValue
        
        return true
    }
    
    
    
    // MARK: Initialization
    
    fileprivate func initialize() {
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
    
    open override func draw(_ rect: CGRect) {
        guard alphabet.count > 0 else { return }

        // Paint over our previous drawing.
        backgroundColor?.setFill()
        
        let attributes = [
            NSForegroundColorAttributeName: fontColor,
            NSFontAttributeName: font
        ] as [String : Any]
        let focusAttributes = [
            NSForegroundColorAttributeName: focusFontColor,
            NSFontAttributeName: focusFont
        ] as [String : Any]

        // Calculate spacing that will automatically center the alphabet.
        let spacePerLetter = workingWidth / CGFloat(alphabet.count + 1)
        
        for (index, _) in alphabet.enumerated() {
            let theAttributes = index == storedValue ? focusAttributes : attributes
            let letterString = NSAttributedString(string: alphabet[index], attributes: theAttributes)
            
            let letterSize = letterString.size()
            let letterCenterDistance = letterSize.width / 2
            let yPosition = bounds.height / 2 - baselineOffset - letterSize.height / 2
            let xPosition = spacePerLetter * (CGFloat(index) + 1) + horizonalInset - letterCenterDistance
            letterString.draw(in: CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: letterSize.width, height: letterSize.height)))
        }
    }
}
