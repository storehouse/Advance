import Foundation

#if os(iOS) || os(tvOS)
import QuartzCore
#elseif os(OSX)
import CoreVideo
#endif


public final class Loop {
    
    private let frameSink: Sink<Frame>
    
    private let driver: Driver
    
    public init() {
        frameSink = Sink()
        driver = Driver()
        driver.callback = { [unowned self] frame in
            self.frameSink.send(value: frame)
        }
    }
    
    public var frames: Observable<Frame> {
        return frameSink.observable
    }
    
    public var paused: Bool {
        get { return driver.paused }
        set { driver.paused = newValue }
    }
    
}


public extension Loop {
    /// Info about a particular frame.
    public struct Frame : Equatable {
        
        public var previousTimestamp: Double
        
        /// The timestamp that the frame.
        public var timestamp: Double
        
        /// The current duration between frames.
        public var duration: Double {
            return timestamp - previousTimestamp
        }
        
        public static func ==(lhs: Frame, rhs: Frame) -> Bool {
            return lhs.timestamp == rhs.timestamp
                && lhs.previousTimestamp == rhs.previousTimestamp
        }
        
    }
}




#if os(iOS) || os(tvOS) // iOS support using CADisplayLink --------------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
fileprivate extension Loop {
    
    final class Driver {
    
        /// The callback to call for each frame.
        var callback: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var paused: Bool {
            get {
                return displayLink.isPaused
            }
            set {
                displayLink.isPaused = newValue
            }
        }
        
        /// The CADisplayLink that powers this DisplayLink instance.
        let displayLink: CADisplayLink
        
        /// The target for the CADisplayLink (because CADisplayLink retains its target).
        let target = DisplayLinkTarget()
        
        /// Creates a new paused DisplayLink instance.
        init() {
            displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
            displayLink.isPaused = true
            displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            
            target.callback = { [unowned self] (frame) in
                self.callback?(frame)
            }
        }
        
        deinit {
            displayLink.invalidate()
        }
        
        /// The target for the CADisplayLink (because CADisplayLink retains its target).
        internal final class DisplayLinkTarget {
            
            /// The callback to call for each frame.
            var callback: ((Loop.Frame) -> Void)? = nil
            
            /// Called for each frame from the CADisplayLink.
            @objc dynamic func frame(_ displayLink: CADisplayLink) {
                
                let frame = Frame(
                    previousTimestamp: displayLink.timestamp,
                    timestamp: displayLink.targetTimestamp)
                
                callback?(frame)
            }
        }
        
    }
}

#elseif os(OSX) // OS X support using CVDisplayLink --------------------------------------------------

fileprivate extension Loop {
    
    /// DisplayLink is used to hook into screen refreshes.
    final class Driver {
    
        /// The callback to call for each frame.
        var callback: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var paused: Bool = true {
            didSet {
                guard paused != oldValue else { return }
                if paused == true {
                    CVDisplayLinkStop(self.displayLink)
                } else {
                    CVDisplayLinkStart(self.displayLink)
                }
            }
        }
        
        /// The CVDisplayLink that powers this DisplayLink instance.
        var displayLink: CVDisplayLink = {
            var dl: CVDisplayLink? = nil
            CVDisplayLinkCreateWithActiveCGDisplays(&dl)
            return dl!
        }()
                
        init() {
            
            CVDisplayLinkSetOutputHandler(self.displayLink, { [weak self] (displayLink, inNow, inOutputTime, flageIn, flagsOut) -> CVReturn in
                let frame = Loop.Frame(
                    previousTimestamp: inNow.pointee.timeInterval,
                    timestamp: inOutputTime.pointee.timeInterval)
                
                DispatchQueue.main.async {
                    self?.frame(frame)
                }
                
                return kCVReturnSuccess
            })

        }
        
        deinit {
            paused = true
        }
        
        /// Called for each CVDisplayLink frame callback.
        func frame(_ frame: Frame) {
            guard paused == false else { return }
            callback?(frame)
        }
    
    }
}
    
fileprivate extension CVTimeStamp {
    var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(self.videoTimeScale)
    }
}

#endif // ------------------------------------------------------------------------------------------
