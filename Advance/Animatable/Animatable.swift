/// Instances of `Animatable` wrap, and manage animated change to, a value 
/// conforming to `VectorConvertible`.
///
/// Using this class to represent a value is often cleaner than setting
/// up and managing animations independently, as `Animatable` conveniently
/// channels all changes to the value into the `changed` event. For example:
///
/// ``` 
/// class Foo {
///   let size: Animatable<CGSize>
///
///   (...)
///
///   init() {
///     size.changed.observe { [weak self] (val) in
///       self?.doSomethingWithSize(val)
///     }
///   }
/// }
///
/// let f = Foo()
/// f.size.animateTo(CGSize(width: 200.0, height: 200.0))
/// ```
///
public final class Animatable<Value: VectorConvertible> {
    
    /// `finished` will be true if the animation finished uninterrupted, or 
    /// false if it was cancelled.
    public typealias Completion = (Bool) -> Void
    
    /// Fires each time the `value` property changes.
    public let changed = Observable<Value>()
    
    // The animator that is driving the current animation, if any.
    fileprivate var animator: Animator<AnyValueAnimation<Value>>? = nil
    
    // Tracks the last publicly notified value – this lets us control when
    // events are fired (we always want to wait until the end of the
    // animation loop).
    fileprivate var currentValue: Value {
        didSet {
            guard currentValue != oldValue else { return }
            changed.send(value: value)
        }
    }
    
    /// Returns `true` if an animation is in progress.
    public var animating: Bool {
        return animator != nil
    }
    
    /// The current value of this `Animatable`.
    /// 
    /// Setting this property will cancel any animation that is in
    /// progress, and this `Animatable` will assume the new value immediately.
    public var value: Value {
        get {
            return currentValue
        }
        set {
            cancelAnimation()
            currentValue = newValue
        }
    }
    
    /// The current velocity reported by the in-flight animation, if any. If no
    /// animation is in progress, the returned value will be equivalent to
    /// `T.Vector.zero`
    public var velocity: Value {
        return animator?.animation.velocity ?? Value.zero
    }
    
    /// Creates an `Animatable` of T initialized to an initial value.
    ///
    /// - parameter value: The initial value of this animatable.
    public required init(value: Value) {
        currentValue = value
    }
    
    deinit {
        // Make sure we property fire the completion block for the in-flight
        // animation.
        cancelAnimation()
    }
    
    /// Runs the given animation until is either completes or is removed (by
    /// starting another animation or by directly setting the value).
    ///
    /// - parameter animation: The animation to be run.
    /// - parameter completion: An optional closure that will be called when this 
    ///   animation has completed. Its only argument is a `Boolean`, which will 
    ///   be `true` if the animation completed uninterrupted, or `false` if it
    ///   was removed for any other reason.
    public func animate<A: ValueAnimation>(with animation: A, completion: Completion? = nil) where A.Value == Value {
        
        // Cancel any in-flight animation. We observe the cancelled event of
        // animators that we create in order to clean up, so this will have
        // the side effect of nilling the `animator` property.
        cancelAnimation()
        assert(animator == nil)
        
        animator = AnimatorContext.shared.animate(AnyValueAnimation(animation: animation))
        
        animator?.changed.observe({ [unowned self] (a) -> Void in
            self.currentValue = a.value
        })
        
        animator?.cancelled.observe({ [unowned self] (a) -> Void in
            self.animator = nil
            completion?(false)
        })
        
        animator?.finished.observe({ [unowned self] (a) -> Void in
            self.animator = nil
            completion?(true)
        })
    }
    
    /// Cancels an in-flight animation, if present.
    public func cancelAnimation() {
        animator?.cancel()
    }
}
