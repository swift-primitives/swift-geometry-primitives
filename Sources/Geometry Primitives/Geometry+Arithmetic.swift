//
//  Geometry+Arithmetic.swift
//  swift-geometry-primitives
//
//  Created by Coen ten Thije Boonkkamp on 14/12/2025.
//

import Algebra_Linear_Primitives
public import Dimension_Primitives
import Real_Primitives

// MARK: - Size × Scale

/// Scales a size uniformly by a dimensionless scale factor.
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] * rhs.value
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size uniformly by a dimensionless scale factor (commutative).
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Size<N>
) -> Geometry<Scalar, Space>.Size<N> {
    rhs * lhs
}

/// Divides a size uniformly by a dimensionless scale factor.
@inlinable
public func / <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] / rhs.value
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size per-dimension by a matching scale factor.
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<N, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] * rhs.factors[i]
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size per-dimension by a matching scale factor (commutative).
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Scale<N, Scalar>,
    rhs: Geometry<Scalar, Space>.Size<N>
) -> Geometry<Scalar, Space>.Size<N> {
    rhs * lhs
}

/// Divides a size per-dimension by a matching scale factor.
@_disfavoredOverload
@inlinable
public func / <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<N, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] / rhs.factors[i]
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}
// MARK: - Negation

extension Geometry.Depth where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

extension Geometry.Depth where Scalar: AdditiveArithmetic {
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Comparable

extension Geometry.Depth: Comparable where Scalar: Comparable {
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

extension Geometry.Insets where Scalar: AdditiveArithmetic {
    /// Adds two edge insets component-wise.
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top + rhs.top,
            leading: lhs.leading + rhs.leading,
            bottom: lhs.bottom + rhs.bottom,
            trailing: lhs.trailing + rhs.trailing
        )
    }

    /// Subtracts two edge insets component-wise.
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top - rhs.top,
            leading: lhs.leading - rhs.leading,
            bottom: lhs.bottom - rhs.bottom,
            trailing: lhs.trailing - rhs.trailing
        )
    }
}

// MARK: - Negation

extension Geometry.Insets where Scalar: SignedNumeric {
    /// Negates all insets.
    @inlinable
    @_disfavoredOverload
    public static prefix func - (value: borrowing Self) -> Self {
        Self(
            top: -value.top,
            leading: -value.leading,
            bottom: -value.bottom,
            trailing: -value.trailing
        )
    }
}

extension Geometry.Size where Scalar: AdditiveArithmetic {
    /// Add two sizes component-wise
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = lhs.dimensions[i] + rhs.dimensions[i]
        }
        return Self(result)
    }

    /// Subtract two sizes component-wise
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = lhs.dimensions[i] - rhs.dimensions[i]
        }
        return Self(result)
    }
}

// MARK: - Negation

extension Geometry.Size where Scalar: SignedNumeric {
    /// Negate all dimensions
    @inlinable
    @_disfavoredOverload
    public static prefix func - (value: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = -value.dimensions[i]
        }
        return Self(result)
    }
}

// MARK: - Ratio Operators (Height / Height, Length / Length)

/// Ratio of two heights (dimensionless).
///
/// Returns a Scale<1> representing the ratio between two heights.
/// Disfavored to allow `Height / scalar` to use the scalar division operator.
@_disfavoredOverload
@inlinable
public func / <Scalar: FloatingPoint, Space>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Height
) -> Scale<1, Scalar> {
    Scale(lhs.rawValue / rhs.rawValue)
}

/// Ratio of two widths (dimensionless).
///
/// Returns a Scale<1> representing the ratio between two widths.
/// Disfavored to allow `Width / scalar` to use the scalar division operator.
@_disfavoredOverload
@inlinable
public func / <Scalar: FloatingPoint, Space>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.Width
) -> Scale<1, Scalar> {
    Scale(lhs.rawValue / rhs.rawValue)
}

/// Ratio of two lengths/magnitudes (dimensionless).
///
/// Returns a Scale<1> representing the ratio between two lengths.
/// Disfavored to allow `Length / scalar` to use the scalar division operator.
@_disfavoredOverload
@inlinable
public func / <Scalar: FloatingPoint, Space>(
    lhs: Linear<Scalar, Space>.Magnitude,
    rhs: Linear<Scalar, Space>.Magnitude
) -> Scale<1, Scalar> {
    Scale(lhs.rawValue / rhs.rawValue)
}

// MARK: - Height + Height, Width + Width

/// Adds two heights (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func + <Scalar: AdditiveArithmetic, Space>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height {
    Geometry<Scalar, Space>.Height(lhs.rawValue + rhs.rawValue)
}

/// Subtracts two heights (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func - <Scalar: AdditiveArithmetic, Space>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height {
    Geometry<Scalar, Space>.Height(lhs.rawValue - rhs.rawValue)
}

/// Adds two widths (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func + <Scalar: AdditiveArithmetic, Space>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width {
    Geometry<Scalar, Space>.Width(lhs.rawValue + rhs.rawValue)
}

/// Subtracts two widths (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func - <Scalar: AdditiveArithmetic, Space>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width {
    Geometry<Scalar, Space>.Width(lhs.rawValue - rhs.rawValue)
}

// MARK: - Quantized Height + Height, Width + Width

/// Adds two heights with quantization.
@inlinable
public func + <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue + rhs.rawValue, in: Space.self)
}

/// Subtracts two heights with quantization.
@inlinable
public func - <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue - rhs.rawValue, in: Space.self)
}

/// Adds two widths with quantization.
@inlinable
public func + <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue + rhs.rawValue, in: Space.self)
}

/// Subtracts two widths with quantization.
@inlinable
public func - <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue - rhs.rawValue, in: Space.self)
}

// MARK: - Height * Scale, Width * Scale

/// Scales a height by a dimensionless factor (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Height {
    Geometry<Scalar, Space>.Height(lhs.rawValue * rhs.value)
}

/// Scales a height by a dimensionless factor (commutative, non-quantized fallback).
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height {
    rhs * lhs
}

/// Scales a width by a dimensionless factor (non-quantized fallback).
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Width {
    Geometry<Scalar, Space>.Width(lhs.rawValue * rhs.value)
}

/// Scales a width by a dimensionless factor (commutative, non-quantized fallback).
@_disfavoredOverload
@inlinable
public func * <Scalar: FloatingPoint, Space>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width {
    rhs * lhs
}

// MARK: - Quantized Height * Scale, Width * Scale

/// Scales a height by a dimensionless factor with quantization.
@inlinable
public func * <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Height where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue * rhs.value, in: Space.self)
}

/// Scales a height by a dimensionless factor (commutative) with quantization.
@inlinable
public func * <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Height where Space.Scalar == Scalar {
    rhs * lhs
}

/// Scales a width by a dimensionless factor with quantization.
@inlinable
public func * <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Width where Space.Scalar == Scalar {
    ._quantize(lhs.rawValue * rhs.value, in: Space.self)
}

/// Scales a width by a dimensionless factor (commutative) with quantization.
@inlinable
public func * <Scalar: BinaryFloatingPoint, Space: Numeric.Quantized>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.Width where Space.Scalar == Scalar {
    rhs * lhs
}
