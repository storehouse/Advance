/// The state of the event.
public enum EventState<T> {
    
    /// The event is active and accepting new payloads.
    case active
    
    /// The event is closed. Subsequent calls to `fire(payload:)` will be ignored.
    case closed(T)
}

/// A simple EventType implementation.
public final class Event<T> {
    
    /// The current state of the event.
    fileprivate (set) public var state = EventState<T>.active
    
    public typealias Observer = (T) -> Void
    
    fileprivate var observers: [Observer] = []
    fileprivate var keyedObservers: [String:Observer] = [:]
    
    /// Returns `true` if the event state is `Closed`.
    public var closed: Bool {
        if case .active = state {
            return false
        } else {
            return true
        }
    }
    
    fileprivate var closedValue: T? {
        if case let .closed(v) = state {
            return v
        }
        return nil
    }
    
    /// Notifies observers.
    ///
    /// If the event has been closed, this has no effect.
    ///
    /// - parameter payload: A value to be passed to each observer.
    public func fire(value: T) {
        guard closed == false else { return }
        deliver(value: value)
    }
    
    /// Closes the event.
    ///
    /// If the event has already been closed, this has no effect.
    ///
    /// Calls all observers with the given payload. Once an event is closed,
    /// calling `fire(payload:)` or `close(payload:)` will have no effect.
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    public func close(value: T) {
        guard closed == false else { return }
        state = .closed(value)
        deliver(value: value)
    }
    
    fileprivate func deliver(value: T) {
        for o in observers {
            o(value)
        }
        for o in keyedObservers.values {
            o(value)
        }
    }
    
    /// Adds an observer.
    ///
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    ///
    /// - parameter observer: A closure that will be executed when this event
    ///   is fired.
    public func observe(_ observer: @escaping Observer) {
        guard closed == false else {
            observer(closedValue!)
            return
        }
        observers.append(observer)
    }
    
    /// Adds an observer for a key.
    ///
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    ///
    /// - seeAlso: func unobserve(key:)
    /// - parameter observer: A closure that will be executed when this event
    ///   is fired.
    /// - parameter key: A string that identifies this observer, which can
    ///   be used to remove the observer.
    public func observe(_ observer: @escaping Observer, key: String) {
        guard closed == false else {
            observer(closedValue!)
            return
        }
        keyedObservers[key] = observer
    }
    
    /// Removed an observer with a given key.
    ///
    /// - seeAlso: func observe(observer:key:)
    /// - parameter key: A string that identifies the observer to be removed.
    ///   If an observer does not exist for the given key, the method returns
    ///   without impact.
    public func removeObserver(for key: String) {
        keyedObservers.removeValue(forKey: key)
    }
}
