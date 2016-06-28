import UIKit
import AlphabetSlider

class ExampleController: UIViewController {
    // Intentionally make labels
    private let alphabet: [String] = "1234567ABCDEFGXYZ".characters.map() { return String($0) }
    
    @IBOutlet weak var indexSlider: AlphabetSlider!

    @IBOutlet weak var collection: UICollectionView!
    
    private var indexIsScrolling = false
    
    private var internalValue: Int = 0
        
    func scrollToIndex(sender: AlphabetSlider) {
        indexIsScrolling = true
        let indexPath = NSIndexPath(forItem: 0, inSection: sender.value)
        collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: true)
    }
    
    override func viewDidLoad() {
        indexSlider.alphabet = alphabet
        collection.delegate = self
        collection.dataSource = self
        indexSlider.addTarget(self, action: #selector(scrollToIndex), forControlEvents: .ValueChanged)
    }
}



extension ExampleController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return alphabet.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("orangeCell", forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collection.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath)
        if let view = view as? AlphabetHeader {
            view.sectionLabel.text = alphabet[indexPath.section]
        }
        return view
    }
}

extension ExampleController: UICollectionViewDelegate {
    // Disable the index scroll lock when the user scrolls the collection themselves.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        indexIsScrolling = false
    }
    
    // When a user is scrolling the collection, update the index view's value.
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        internalValue = indexPath.section
        guard !indexIsScrolling else { return }
        indexSlider.value = internalValue
    }
}