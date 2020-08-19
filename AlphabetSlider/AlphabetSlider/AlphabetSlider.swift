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
      style_indicator()
      rebuild_caches()
      setNeedsDisplay()
    }
	}
	
	// We keep track of our value in three different places:
	// First of all, we have a public value to satisfy the UIControl API.
  open var value: Int = 0 { didSet {
    // Trigger an event only if we cross an integer boundary.
    guard alphabet.count > 0 else { return }
    guard value != oldValue else { return }
    
    
    // Bounds-check the value we've been set to.  Out-of-bounds values could be
    // passed in from a ScrollView that has more sections than we have letters, or from
    // a touch event, between the UIView's bounds and the content area.
    value = min(max(value, 0), alphabet.count - 1)
    
    // Move the indicator the new position, and adjust its width
    move_indicator(value)
    
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

	
	
	// MARK: public display properties.
	
	// Interface Builder does not support setting UIFont directly; supply both a valid font name, and a size.
	@IBInspectable open var fontName: String = ""
	@IBInspectable open var fontSize: CGFloat = -1.0 // Intentionally invalid values as default.
	@IBInspectable open var fontColor: UIColor = UIColor.darkGray
	
	@IBInspectable open var focusFontName: String = ""
	@IBInspectable open var focusFontSize: CGFloat = -1.0
	@IBInspectable open var focusFontColor: UIColor = UIColor.lightGray
  
  @IBInspectable open var letter_spacing: CGFloat = 5.0
  @IBInspectable open var indicatorColor: UIColor = .orange { didSet {
    style_indicator()
  }}
	
  @IBInspectable open var slideIndicatorThickness: CGFloat = 5.0 { didSet {
    style_indicator()
  }}
	
	@IBInspectable open var horizontalInset: CGFloat = 0.0
	@IBInspectable open var baselineOffset: CGFloat = 0.0
	
	fileprivate var font: UIFont { get {
		return UIFont(
      name: fontName,
      size: fontSize
    )
    ?? UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
	}}
	
	fileprivate var focusFont: UIFont { get {
		return UIFont(
      name: focusFontName,
      size: focusFontSize
    )
    ?? UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
	}}
	
	
	
	
	
	// MARK: private internal state.

	
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
  
  fileprivate var cache_0_renderables = [NSMutableAttributedString]()
  
  // After we draw the letters, we know how wide each one is.  Store
  // those values here, so we can use them to properly position the
  // selection indicator.
  fileprivate var cache_1_renderable_widths = [CGFloat]()
  
  fileprivate var cache_1_focus_widths = [CGFloat]()
  
  // The start points for every letter.  Combined with cache_1_renderable widths to
  // find the boundary of every letter, within content_width X coord space.
  fileprivate var cache_2_letter_start_points = [CGFloat]()
  
  fileprivate var cache_2_horiz_center_offset: CGFloat = 0.0
  
  fileprivate var slideIndicator = CALayer()
  
  // The total width consumed by the rendered letters within view.bounds.
  fileprivate var content_width: CGFloat {
    return cache_1_renderable_widths.reduce(0.0, { acc_result, width in
      return acc_result + width + letter_spacing
    }) - letter_spacing
  }
  
  
  // MARK: private helper functions.
  
  fileprivate func rebuild_caches() {
    let normal_attr = [
      convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): fontColor,
      convertFromNSAttributedStringKey(NSAttributedString.Key.font): font
      ] as [String : Any]

    cache_0_renderables = alphabet.map({ NSMutableAttributedString(string: $0, attributes: convertToOptionalNSAttributedStringKeyDictionary(normal_attr)) })
    cache_1_renderable_widths = cache_0_renderables.map({ $0.size().width })

    // Next, calculate how much free space, if any, is left within the view's bounds, and
    // center the working area inside this extra space.

    let free_space = bounds.width - content_width - (horizontalInset * 2)
    cache_2_horiz_center_offset = max(0, free_space) / 2

    // Finally, pre-compute the CGPoint boundaries, within working_width, of each letter.
    cache_2_letter_start_points = cache_1_renderable_widths.enumerated().reduce(
      [CGFloat](),
      { start_points, index_width in
        let (index, _) = index_width
        let start_point: CGFloat = index == 0 ?
          // The first letter always starts at the 0.0 point of the content space.
          0.0
          // Otherwise, this letter's start point is equal to the last letter's start
          // point, plus its width, plus the letter spacing.
          : start_points.last! + letter_spacing + cache_1_renderable_widths[index - 1]
        return start_points + [start_point]
      })
    ;
  }
  
  fileprivate func style_indicator() {
    slideIndicator.backgroundColor = indicatorColor.cgColor
    let existing_frame = slideIndicator.frame
    slideIndicator.frame = CGRect(origin: existing_frame.origin, size: CGSize(width: existing_frame.width, height: slideIndicatorThickness))
  }
  
  fileprivate func move_indicator(_ index: Int) {
    let start_point = cache_2_letter_start_points[index]
    let new_size = CGSize(width: cache_1_renderable_widths[index], height: slideIndicatorThickness)
    let new_origin = CGPoint(
      x: horizontalInset + cache_2_horiz_center_offset + start_point,
      y: bounds.height - slideIndicatorThickness
    )
    slideIndicator.frame = CGRect(origin: new_origin, size: new_size)
  }
  
  // Note: x_loc is a CGPoint x value within content_width's coord system.
  fileprivate func set_value_from_touch(_ x_loc: CGFloat) {
    let working_x = x_loc - horizontalInset - cache_2_horiz_center_offset
    let found_index = cache_2_letter_start_points.reduce(-1, { the_index, left_bound in
    guard left_bound < working_x else { return the_index }
    return the_index + 1
    })
    value = found_index
  }
  
  
  
  // MARK: initilialization
  override public init(frame: CGRect) {
    super.init(frame: frame)
    layer.addSublayer(slideIndicator)
  }
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.addSublayer(slideIndicator)
  }
  

	
	
	// MARK: UIControl overrides
	
	open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
    guard alphabet.count > 0 else { return false }
		userIsUsing = true
    set_value_from_touch(touch.location(in: self).x)
		return true
	}
	
	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.continueTracking(touch, with: event)
    guard alphabet.count > 0 else { return false }
    set_value_from_touch(touch.location(in: self).x)
		return true
	}
	
  
	
	// MARK: drawing code
	
	open override func draw(_ rect: CGRect) {
		// Paint over our previous drawing.
		backgroundColor?.setFill()
  
    let letter_width_pairs = zip(cache_0_renderables, cache_1_renderable_widths)
    
    var x_offset: CGFloat = horizontalInset + cache_2_horiz_center_offset
		for pair in letter_width_pairs {
      let (letter, width) = pair
			let y_offset = bounds.height / 2 - baselineOffset - font.lineHeight / 2
			letter.draw(in: CGRect(origin: CGPoint(x: x_offset, y: y_offset), size: CGSize(width: width, height: font.lineHeight)))
      x_offset = x_offset + width + letter_spacing
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
