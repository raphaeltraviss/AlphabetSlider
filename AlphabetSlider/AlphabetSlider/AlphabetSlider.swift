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
  
  // cached_letters shadows alphabet.
  open var alphabet: [String] = "12345ABCDEFG!@#$%^&*()_.XYZ".map({ String($0) }) {
		didSet {
      let normal_attr = [
        NSForegroundColorAttributeName: fontColor,
        NSFontAttributeName: font
      ] as [String : Any]
      
      cache_0_renderables = alphabet.map({ NSMutableAttributedString(string: $0, attributes: normal_attr) })
      cache_1_renderable_widths = cache_0_renderables.map({ $0.size().width })
      
      setNeedsDisplay()
    }
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
      // Initialize the slide indicator: we estimate its position and width, since alphabet hasn't
      // been set yet.
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
		return UIFont(
      name: fontName,
      size: fontSize
    )
    ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
	}}
	
	fileprivate var focusFont: UIFont { get {
		return UIFont(
      name: focusFontName,
      size: focusFontSize
    )
    ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
	}}
	
	
	
	
	
	// MARK: private internal state.
  
  fileprivate var cache_0_renderables = [NSMutableAttributedString]()
	
	// Dear Scroll View, if a user is using me, please don't update
	// my value when your cells appear on-screen.  You may read this 
	// variable, but please do not set it.
	open var userIsUsing = false { didSet {
    guard (userIsUsing) else { return }
    scrollViewIsUsing = false
  }}

	
	// Dear Scroll View, I agree not to send you value changed events,
	// when you are the one that is generating those events.  I will read
	// the value you set here, but I will not write to it.
	open var scrollViewIsUsing = false
	
	// Keep track of the last-touch UIView bounds coordinate, for UIKit
  // continueTracking method.
	fileprivate var previousLocation = CGPoint()
	
  
	// A float value that represents the integer index of the currently-focused letter.
  // @TODO: this could be a CGFloat, to make math easier.
	fileprivate var internalValue: Double = 0.0 { didSet {
    let max_value = max(0.0, Double(alphabet.count - 1))
    let sanitizedValue = max(0.0, min(internalValue, max_value))
    internalValue = sanitizedValue
    
    // Trigger an event only if we cross an integer boundary.
    let new_int = Int(internalValue)
    let old_int = Int(oldValue)
    guard new_int != old_int else { return }
    
    
    // Adjust the caches to consider the new integer boundary event.
    
    let normal_attr = [
      NSForegroundColorAttributeName: fontColor,
      NSFontAttributeName: font
    ] as [String : Any]
    let focus_attr = [
      NSForegroundColorAttributeName: focusFontColor,
      NSFontAttributeName: focusFont
    ] as [String : Any]

    let just_left_letter = cache_0_renderables[old_int]
    let just_entered_letter = cache_0_renderables[new_int]
    
    // Make the newly-entered string highlighted, and the just-exited letter normal.
    just_left_letter.setAttributes(normal_attr, range: NSMakeRange(0, just_left_letter.length))
    just_entered_letter.setAttributes(normal_attr, range: NSMakeRange(0, just_entered_letter.length))
    
    // Adjust the new widths in the cache
    cache_1_renderable_widths[old_int] = just_left_letter.size().width
    cache_1_renderable_widths[new_int] = just_entered_letter.size().width
    
    // Move the indicator the new position, and adjust its width
    // Add up the widths BEFORE the new selection, and place the indicator's frame's origin there.
    let before_letters_width: CGFloat = cache_1_renderable_widths.enumerated().reduce(0.0, { acc_result, elem_pair in
      let (index, width) = elem_pair
      guard index < new_int else { return acc_result }
      return acc_result + width
    })
    let new_origin = CGPoint(x: bounds.origin.x + horizonalInset + before_letters_width, y: bounds.origin.y + bounds.height - slideIndicatorThickness)
    let new_size = CGSize(width: cache_1_renderable_widths[new_int], height: slideIndicatorThickness)
    slideIndicator.frame = CGRect(origin: new_origin, size: new_size)

    
    // Re-render the text with the new selected index.
    setNeedsDisplay()

    // Skip the update event if an external object has set our value;
    // we wouldn't want to cause a loop (sending them a valueChanged notification,
    // which in turn causes them to update their collectionview, which in
    // turn updates our value, which in turn sends a valueChanged notification....
    guard userIsUsing && !scrollViewIsUsing else { return }
    
    // Send the event notification.
    self.sendActions(for: .valueChanged)
  } }
	
	// After we draw the letters, we know how wide each one is.  Store
	// those values here, so we can use them to properly position the
	// selection indicator.
	fileprivate var cache_1_renderable_widths = [CGFloat]()
	
	fileprivate var slideIndicator: CALayer!
	
	fileprivate var workingWidth: CGFloat {
		return bounds.width - (horizonalInset * 2)
	}
	
	// Calculate spacing per letter that will automatically center the text.
	fileprivate var workingWidthPerLetter: CGFloat {
		return workingWidth / CGFloat(alphabet.count + 1)
	}
	
	
	
	// MARK: UIControl overrides
	
	open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
    
    // If there are no letters in the alphabet, dragging can do nothing.
    guard alphabet.count > 0 else { return false }
    
    // Lock out UIScrollView events from affecting our value.
		userIsUsing = true

    // There are two coordinate systems within AlphabetSlider: one is the "absolute" grid
    // imposed by view.bounds, used by UIKit functions...
    let absolute_x = touch.location(in: self).x
    
    // Converting between the two is a matter of subtracting off the inset (around the
    // whole thing) and the extra 1/2 character spacing added on either side by
    // workingWidthPerLetter.
    let working_x = absolute_x - horizonalInset - workingWidthPerLetter / 2
    
    // Since our internalValue ranges between 0.0 and Double(alphabet.count - 1), divide
    // the x point units by the point unit per letter, to get the letter we are on.
		internalValue = Double(working_x / workingWidthPerLetter)
    
    // Set previous location, for the next UIKit continueTracking call.
    previousLocation = touch.location(in: self)
    
		return true
	}
	
	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.continueTracking(touch, with: event)
    
    // If there are no letters in the alphabet, dragging can do nothing.
    guard alphabet.count > 0 else { return false }
    
		let absolute_x = touch.location(in: self).x
		
		// If the touch was out-of-bounds, end tracking.
		guard (
      absolute_x > horizonalInset - workingWidthPerLetter / 2 &&
      absolute_x < bounds.width - horizonalInset
    ) else { return false }
		
		// Track how much the user has dragged, in global coordinate space.
		let delta_x = absolute_x - previousLocation.x
		
		// Convert the X movement (in units of dotpoints) into units of letter movement
    // from 0.0 to CGFloat(alphabet.count - 1).
    // NOTE: workingWidth does not take inot account the 1/2 letter width spacing on
    // either side of the slider, so add it back in.
		let delta_letter = delta_x * (CGFloat(alphabet.count) + 1) / workingWidth
		internalValue += Double(delta_letter)
    
    // Set state for next UIKit call to continueTracking.
    previousLocation = touch.location(in: self)
    
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
		// Paint over our previous drawing.
		backgroundColor?.setFill()
  
    let bogus_height: CGFloat = self.font.lineHeight
    let letter_width_pairs = zip(cache_0_renderables, cache_1_renderable_widths)
    
    var x_offset: CGFloat = 0.0
		for pair in letter_width_pairs {
      let (letter, width) = pair
			let yPosition = bounds.height / 2 - baselineOffset - bogus_height / 2
			let xPosition = x_offset + horizonalInset
			letter.draw(in: CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: width, height: bogus_height)))
      x_offset += width
		}
	}
}
