import Foundation
import CoreGraphics
import Advance

typealias SimpleTransform = VectorPair<CGFloat, CGFloat>

extension SimpleTransform {
    init() {
        self.init(scale: 1, rotation: 0)
    }

    init(scale: CGFloat, rotation: CGFloat) {
        self.init(first: scale, second: rotation)
    }

    var scale: CGFloat {
        get { first }
        set { first = newValue }
    }

    var rotation: CGFloat {
        get { second }
        set { second = newValue }
    }

    var affineTransform: CGAffineTransform {
        var t = CGAffineTransform.identity
        t = t.rotated(by: rotation)
        t = t.scaledBy(x: scale, y: scale)
        return t
    }
}

extension SimpleTransform: VectorConvertible {
    public typealias AnimatableData = VectorPair<CGFloat, CGFloat>
}
