// AlphabetSlider incremental label slider
// Copyright (c) 2016, Raphael Traviss
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
	
	// We keep track of our value in three different places:
	// First of all, we have a public value to satisfy the UIControl API.
	open var value: Int {
		get {
			return Int(internalValue)
		}
		set {
			internalValue = Double(newValue)
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
	
	@IBInspectable open var slideIndicatorThickness: CGFloat = 5.0 {
		didSet {
			if slideIndicator != nil { slideIndicator.removeFromSuperlayer() }
			let slideLayer = CALayer()
			let theOrigin = CGPoint(x: bounds.origin.x + horizonalInset + (workingWidthPerLetter / 2), y: bounds.origin.y + bounds.height - slideIndicatorThickness)
			let theSize = CGSize(width: workingWidth / CGFloat(alphabet.count), height: slideIndicatorThickness)
			slideLayer.frame = CGRect(origin: theOrigin, size: theSize)
			slideLayer.backgroundColor = UIColor.orange.cgColor
			slideIndicator = slideLayer
			layer.addSublayer(slideIndicator)
		}
	}
	
	@IBInspectable open var horizonalInset: CGFloat = 0.0
	@IBInspectable open var baselineOffset: CGFloat = 0.0
	
	fileprivate var font: UIFont { get {
		return UIFont(name: fontName, size: fontSize) ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
	} }
	
	fileprivate var focusFont: UIFont { get {
		return UIFont(name: focusFontName, size: focusFontSize) ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
	} }
	
	
	
	
	
	// MARK: private internal state.
	
	// Dear Scroll View, if a user is using me, please don't update
	// my value when your cells appear on-screen.  You may read this 
	// variable, but please do not set it.
	open var userIsUsing = false {
		didSet {
			if (userIsUsing) {
				scrollViewIsUsing = false
			}
		}
	}

	
	// Dear Scroll View, I agree not to send you value changed events,
	// when you are the one that is generating those events.  I will read
	// the value you set here, but I will not write to it.
	open var scrollViewIsUsing = false
	
	
	
	fileprivate var previousLocation = CGPoint()
	
	// We keep track of the precise value the user has moved
	// their finger to.  This is used for precise tracking when the user
	// is dragging their finger over the control.
	fileprivate var internalValue: Double = 0.0 {
		didSet {
			// Enforce min/max values to protect our math.
			let sanitizedValue = min(max(internalValue, 0), Double(alphabet.count - 1))
			internalValue = sanitizedValue
			
			// Trigger an event only if we cross an integer boundary.
			guard Int(internalValue) != Int(oldValue) else { return }
			
			updateIndicator()
			
			// Re-render the text with the new selected index.
			setNeedsDisplay()

			// Skip the update event if an external object has set our value;
			// we wouldn't want to cause a loop (sending them a valueChanged notification,
			// which in turn causes them to update their collectionview, which in
			// turn updates our value, which in turn sends a valueChanged notification....
			guard userIsUsing && !scrollViewIsUsing else { return }
			
			// Send the event notification.
			self.sendActions(for: .valueChanged)
		}
	}
	
	// After we draw the letters, we know how wide each one is.  Store
	// those values here, so we can use them to properly position the
	// selection indicator.
	fileprivate var cachedLetterWidths = [CGFloat]()
	
	fileprivate var slideIndicator: CALayer!
	
	fileprivate var workingWidth: CGFloat {
		return bounds.width - (horizonalInset * 2)
	}
	
	// Calculate spacing per letter that will automatically center the text.
	fileprivate var workingWidthPerLetter: CGFloat {
		return workingWidth / CGFloat(alphabet.count + 1)
	}
	
	fileprivate func updateIndicator() {
		// Move the highlight underneath the selected index.
		// The indicator's distance from the left is equal to one unit of horizontal offset,
		// centered over a letter, plus one letter width for each rouned index, which will put
		// us right underneath the letter we just touched.
		// We add in a little fudge factor, since workingWidthPerLetter is actually different
		// than the actual width of the letter.
		var fudgeFactor: CGFloat
		if (cachedLetterWidths.count > Int(internalValue)) {
			// @TODO: this value is too aggressive.  Ignoring it for now.
			fudgeFactor = (workingWidthPerLetter - cachedLetterWidths[Int(internalValue)]) / 2
		}
		fudgeFactor = 1.0
		
		slideIndicator.frame.origin.x = horizonalInset + (workingWidthPerLetter / 2) + (workingWidthPerLetter * CGFloat(Int(internalValue))) + fudgeFactor
	}
	
	
	
	// MARK: UIControl overrides
	
	open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
		userIsUsing = true
		previousLocation = touch.location(in: self)
		let xPos = previousLocation.x
		
		// Convert the touched point to the drawn letter index and set our
		// internal precise value.
		internalValue = Double((xPos - horizonalInset - workingWidthPerLetter / 2) / workingWidthPerLetter)
	
		return true
	}
	
	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.continueTracking(touch, with: event)
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
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
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
		
		cachedLetterWidths.removeAll()
		
		for (index, _) in alphabet.enumerated() {
			let theAttributes = index == Int(internalValue) ? focusAttributes : attributes
			let letterString = NSAttributedString(string: alphabet[index], attributes: theAttributes)
			
			let letterSize = letterString.size()
			
			cachedLetterWidths.append(letterSize.width)
			
			let letterCenterDistance = letterSize.width / 2
			let yPosition = bounds.height / 2 - baselineOffset - letterSize.height / 2
			let xPosition = workingWidthPerLetter * (CGFloat(index) + 1) + horizonalInset - letterCenterDistance
			letterString.draw(in: CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: letterSize.width, height: letterSize.height)))
		}
	}
}
