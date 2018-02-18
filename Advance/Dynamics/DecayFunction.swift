/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<T>: SimulationFunction where T: VectorConvertible {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to settle.
    public var threshold: Scalar = 0.1
    
    /// How much to erode the velocity.
    public var drag: Scalar = 3.0
    
    /// Creates a new `DecayFunction` instance.
    public init() {}
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(for state: SimulationState<T>) -> T {
        return -drag * state.velocity
    }
    
    public func status(for state: SimulationState<T>) -> SimulationResult<T> {
        let min = T(scalar: -threshold)
        let max = T(scalar: threshold)
        if state.velocity.clamped(min: min, max: max) == state.velocity {
            return .settled(value: state.value)
        } else {
            return .running
        }
    }
    
}
