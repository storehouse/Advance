/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/// A vector with 1 component.
public typealias Vector1 = Scalar

extension Vector1: Vector {
    
    /// Creates a vector for which all components are equal to the given scalar.
    public init(scalar: Scalar) {
        self = scalar
    }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    public static var zero: Vector1 {
        return Vector1(0.0)
    }
    
    /// The number of scalar components in this vector type.
    public static var length: Int {
        return 1
    }
    
    public subscript(index: Int) -> Scalar {
        get {
            precondition(index == 0)
            return self
        }
        set {
            precondition(index == 0)
            self = newValue
        }
    }
    
    /// Interpolate between the given values.
    public func interpolatedTo(_ to: Vector1, alpha: Scalar) -> Vector1 {
        var result = self
        result.interpolateTo(to, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolateTo(_ to: Vector1, alpha: Scalar) {
        self += alpha * (to - self)
    }
}
