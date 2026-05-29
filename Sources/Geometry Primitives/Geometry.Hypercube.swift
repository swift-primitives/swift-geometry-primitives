// Geometry.Hypercube.swift
// N-dimensional hypercube (axis-aligned box with uniform side length).

public import Affine_Geometry_Primitives
public import Linear_Primitives
public import Dimension_Primitives

extension Geometry {
    /// N-dimensional hypercube — axis-aligned box with uniform side length.
    ///
    /// A hypercube has equal extent in all dimensions. In 2D this is a square,
    /// in 3D a cube.
    ///
    /// - `Hypercube<2>` = Square
    /// - `Hypercube<3>` = Cube
    ///
    /// ## Example
    ///
    /// ```swift
    /// let square = Geometry<Double, Void>.Square(
    ///     center: .zero,
    ///     halfSide: .init(50)
    /// )
    /// print(square.side)      // Magnitude with .width/.height projections
    /// print(square.diagonal)  // side × √2
    /// ```
    public struct Hypercube<let N: Int> {
        /// Center point.
        public var center: Point<N>

        /// Half of the side length (distance from center to face).
        public var halfSide: Linear<Scalar, Space>.Magnitude

        /// Creates a hypercube with the given center and half-side.
        @inlinable
        public init(center: consuming Point<N>, halfSide: consuming Linear<Scalar, Space>.Magnitude) {
            self.center = center
            self.halfSide = halfSide
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// 2-dimensional hypercube (square).
    public typealias Square = Hypercube<2>

    /// 3-dimensional hypercube (cube).
    public typealias Cube = Hypercube<3>
}

// MARK: - Conformances

extension Geometry.Hypercube: Sendable where Scalar: Sendable {}
extension Geometry.Hypercube: Equatable where Scalar: Equatable {}
extension Geometry.Hypercube: Hashable where Scalar: Hashable {}

#if !hasFeature(Embedded)
    extension Geometry.Hypercube: Codable where Scalar: Codable {}
#endif

// MARK: - Convenience Initializers

extension Geometry.Hypercube where Scalar: AdditiveArithmetic {
    /// Creates a hypercube centered at origin with given half-side.
    @inlinable
    public init(halfSide: Linear<Scalar, Space>.Magnitude) {
        self.init(center: .zero, halfSide: halfSide)
    }
}

extension Geometry.Hypercube where Scalar: FloatingPoint {
    /// Creates a hypercube with the given center and full side length.
    @inlinable
    public init(center: consuming Geometry.Point<N>, side: Linear<Scalar, Space>.Magnitude) {
        self.init(center: center, halfSide: Linear<Scalar, Space>.Magnitude(side.underlying / 2))
    }

    /// Creates a hypercube centered at origin with given full side length.
    @inlinable
    public init(side: Linear<Scalar, Space>.Magnitude) where Scalar: AdditiveArithmetic {
        self.init(center: .zero, halfSide: Linear<Scalar, Space>.Magnitude(side.underlying / 2))
    }
}

// MARK: - Static Properties

extension Geometry.Hypercube where Scalar: ExpressibleByIntegerLiteral & AdditiveArithmetic {
    /// Unit hypercube centered at origin with side length 1.
    @inlinable
    public static var unit: Self {
        Self(center: .zero, halfSide: .init(1))
    }
}

// MARK: - Common Properties

extension Geometry.Hypercube where Scalar: FloatingPoint {
    /// Full side length with projections to Width/Height.
    @inlinable
    public var side: Geometry.Magnitude {
        Geometry.Magnitude(Linear<Scalar, Space>.Magnitude(halfSide.underlying * 2))
    }
}

// MARK: - 2D Properties (Square)

extension Geometry.Hypercube where N == 2, Scalar: FloatingPoint {
    /// Diagonal length (side × √2).
    @inlinable
    public var diagonal: Geometry.Magnitude {
        let s = halfSide.underlying * 2
        return Geometry.Magnitude(Linear<Scalar, Space>.Magnitude(s * Scalar(2).squareRoot()))
    }

    /// Area (side²).
    @inlinable
    public var area: Geometry.Area {
        let s = halfSide.underlying * 2
        return Geometry.Area(s * s)
    }

    /// Perimeter (4 × side).
    @inlinable
    public var perimeter: Geometry.Perimeter {
        Geometry.Perimeter(halfSide.underlying * 8)
    }

    /// Axis-aligned bounding rectangle (same as the square itself for axis-aligned squares).
    @inlinable
    public var boundingBox: Geometry.Rectangle {
        Geometry.Rectangle(
            llx: center.x - halfSide,
            lly: center.y - halfSide,
            urx: center.x + halfSide,
            ury: center.y + halfSide
        )
    }
}

// MARK: - 2D Corner Access (Square)

extension Geometry.Hypercube where N == 2, Scalar: FloatingPoint {
    /// Lower-left x coordinate.
    @inlinable
    public var llx: Geometry.X {
        center.x - halfSide
    }

    /// Lower-left y coordinate.
    @inlinable
    public var lly: Geometry.Y {
        center.y - halfSide
    }

    /// Upper-right x coordinate.
    @inlinable
    public var urx: Geometry.X {
        center.x + halfSide
    }

    /// Upper-right y coordinate.
    @inlinable
    public var ury: Geometry.Y {
        center.y + halfSide
    }

    /// Width (same as side for square).
    @inlinable
    public var width: Geometry.Width {
        Geometry.Width(halfSide.underlying * 2)
    }

    /// Height (same as side for square).
    @inlinable
    public var height: Geometry.Height {
        Geometry.Height(halfSide.underlying * 2)
    }
}

// MARK: - 3D Properties (Cube)

extension Geometry.Hypercube where N == 3, Scalar: FloatingPoint {
    /// Space diagonal (side × √3).
    @inlinable
    public var diagonal: Geometry.Magnitude {
        let s = halfSide.underlying * 2
        return Geometry.Magnitude(Linear<Scalar, Space>.Magnitude(s * Scalar(3).squareRoot()))
    }

    /// Volume (side³).
    @inlinable
    public var volume: Scalar {
        let s = halfSide.underlying * 2
        return s * s * s
    }

    /// Surface area (6 × side²).
    @inlinable
    public var surfaceArea: Scalar {
        let s = halfSide.underlying * 2
        return 6 * s * s
    }
}

// MARK: - 2D Containment (Square)

extension Geometry.Hypercube where N == 2, Scalar: FloatingPoint {
    /// Checks if point is inside or on the square boundary.
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        let h = halfSide.underlying
        let dx = point.x.underlying - center.x.underlying
        let dy = point.y.underlying - center.y.underlying
        return dx >= -h && dx <= h && dy >= -h && dy <= h
    }
}

// MARK: - 2D Transformation (Square)

extension Geometry.Hypercube where N == 2, Scalar: FloatingPoint {
    /// Returns square translated by vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(center: center + vector, halfSide: halfSide)
    }

    /// Returns square scaled uniformly about its center.
    @inlinable
    public func scaled(by factor: Scale<1, Scalar>) -> Self {
        Self(
            center: center,
            halfSide: Linear<Scalar, Space>.Magnitude(halfSide.underlying * factor.value)
        )
    }
}

// MARK: - Functorial Map

extension Geometry.Hypercube {
    /// Transforms coordinates using the given closure.
    @inlinable
    public func map<Result, E: Swift.Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result, Space>.Hypercube<N> {
        Geometry<Result, Space>.Hypercube(
            center: try center.map(transform),
            halfSide: try halfSide.map(transform)
        )
    }
}
