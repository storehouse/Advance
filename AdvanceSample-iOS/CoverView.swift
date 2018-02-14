import UIKit

final class CoverView: UIView {
    
    let logoView: UIImageView
    
    let urlLabel: UILabel
    
    var URLVisibility: CGFloat = 1.0 {
        didSet {
            urlLabel.alpha = URLVisibility
        }
    }
    
    override init(frame: CGRect) {
        logoView = UIImageView(image: UIImage(named: "logo"))
        logoView.tintColor = UIColor.white
        logoView.sizeToFit()
        
        urlLabel = UILabel(frame: CGRect.zero)
        
        var attribs: [NSAttributedStringKey: Any] = [:]
        attribs[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        attribs[NSAttributedStringKey.foregroundColor] = UIColor.white
        
        // attribs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        
        urlLabel.attributedText = NSAttributedString(string: "github.com/storehouse/Advance", attributes: attribs)
        urlLabel.sizeToFit()
        
        super.init(frame: frame)
        
        addSubview(logoView)
        addSubview(urlLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        urlLabel.center = CGPoint(x: bounds.midX, y: logoView.frame.maxY + 4.0 + urlLabel.bounds.height/2.0)
    }
    
}
