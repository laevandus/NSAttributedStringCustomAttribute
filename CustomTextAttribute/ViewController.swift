//
//  ViewController.swift
//  CustomTextAttribute
//
//  Created by Toomas Vahter on 02.11.2019.
//  Copyright © 2019 Augmented Code. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textView = TokenTextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let string = "The quick brown fox jumps over the lazy dog"
        let attributedString = NSMutableAttributedString(string: string)
        let value = "value"
        attributedString.addAttribute(.token, value: value, range: NSRange(location: 4, length: 5))
        textView.attributedText = attributedString

        self.textView = textView
    }
}

final class TokenTextView: UITextView {
    init(frame: CGRect) {
        let layoutManager = TokenLayoutManager()
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        textContainer.heightTracksTextView = true
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        super.init(frame: frame, textContainer: textContainer)
        updateLayoutManager()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updateLayoutManager()
        }
    }
    
    private func updateLayoutManager() {
        guard let layoutManager = layoutManager as? TokenLayoutManager else { return }
        layoutManager.textContainerOriginOffset = CGSize(width: textContainerInset.left, height: textContainerInset.top)
        layoutManager.invalidateDisplay(forCharacterRange: NSRange(location: 0, length: attributedText.length))
    }
}

extension NSAttributedString.Key {
    static let token = NSAttributedString.Key("Token")
}

final class TokenLayoutManager: NSLayoutManager {
    var textContainerOriginOffset: CGSize = .zero
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        textStorage?.enumerateAttribute(.token, in: characterRange, options: .longestEffectiveRangeNotRequired, using: { (value, subrange, _) in
            guard let token = value as? String, !token.isEmpty else { return }
            let tokenGlypeRange = glyphRange(forCharacterRange: subrange, actualCharacterRange: nil)
            drawToken(forGlyphRange: tokenGlypeRange)
        })
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }
    
    private func drawToken(forGlyphRange tokenGlypeRange: NSRange) {
        guard let textContainer = textContainer(forGlyphAt: tokenGlypeRange.location, effectiveRange: nil) else { return }
        let withinRange = NSRange(location: NSNotFound, length: 0)
        enumerateEnclosingRects(forGlyphRange: tokenGlypeRange, withinSelectedGlyphRange: withinRange, in: textContainer) { (rect, _) in
            let tokenRect = rect.offsetBy(dx: self.textContainerOriginOffset.width, dy: self.textContainerOriginOffset.height)
            UIColor(hue: 175.0/360.0, saturation: 0.24, brightness: 0.88, alpha: 1).setFill()
            UIBezierPath(roundedRect: tokenRect, cornerRadius: 4).fill()
        }
    }
}
