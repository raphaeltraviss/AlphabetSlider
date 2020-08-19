Pod::Spec.new do |s|
  s.name         = "AlphabetSlider"
  s.version      = "3.0.7"
  s.summary      = "Provides an incremental slider for arbitary string values."

  s.description  = <<-DESC
Provides an incremental slider, allowing the user to select from any arbitary values of your choosing--alphabet letters, numbers, values, or anything else.  Hook this up to a UICollectionView or a UITableView and use it as an index to quickly scroll between sections.  As a user scrolls through a table or collection, you can use delegate methods to update the value of this slider, which is a nice way of displaying the user's overall progress through the table or collection.
DESC

  s.homepage     = "https://github.com/raphaeltraviss/AlphabetSlider"
  s.screenshots  = "https://raw.githubusercontent.com/raphaeltraviss/AlphabetSlider/9f06df32b978b63212f476e9da7a0cb4fcfbeeb3/demo.gif"
  s.license      = { :type => "BSD", :file => "LICENSE.txt" }
  s.author             = { "Raphael Traviss" => "raphael@skyleafdesign.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/raphaeltraviss/AlphabetSlider.git", :tag => "3.0.7" }

  s.source_files  = "AlphabetSlider/AlphabetSlider"
  s.framework  = "UIKit"
end
