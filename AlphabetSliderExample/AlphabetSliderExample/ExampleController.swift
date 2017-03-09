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

import UIKit
import AlphabetSlider

class ExampleController: UIViewController {
    
    fileprivate let alphabet: [String] = "123456ABCDEFG-?%)(_#$%^@".characters.map() { return String($0) }
    
    @IBOutlet weak var indexSlider: AlphabetSlider!

    @IBOutlet weak var collection: UICollectionView!
    
    // Prevent the index from updating during animation and initialization.
    fileprivate var indexIsScrolling = true
    
    fileprivate var internalValue: Int = 0
        
    func scrollToIndex(_ sender: AlphabetSlider) {
        indexIsScrolling = true
        let indexPath = IndexPath(item: 0, section: sender.value)
        collection.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    override func viewDidLoad() {
        indexSlider.alphabet = alphabet
        collection.delegate = self
        collection.dataSource = self
        indexSlider.addTarget(self, action: #selector(scrollToIndex), for: .valueChanged)
    }
}



extension ExampleController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return alphabet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "orangeCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collection.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader", for: indexPath)
        if let view = view as? AlphabetHeader {
            view.sectionLabel.text = alphabet[indexPath.section]
        }
        return view
    }
}

extension ExampleController: UICollectionViewDelegate {
    // Disable the index scroll lock when the user scrolls the collection themselves.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexIsScrolling = false
    }
    
    // When a user is scrolling the collection, update the index view's value.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        internalValue = indexPath.section
        guard !indexIsScrolling else { return }
        indexSlider.value = internalValue
    }
}
