// Polygon.swift
// A polygon defined by an ordered sequence of vertices.

public import Affine_Geometry_Primitives
public import Algebra_Linear_Primitives
public import Dimension_Primitives

extension Geometry {
    /// A polygon in 2D space defined by an ordered sequence of vertices.
    ///
    /// Vertices are assumed to form a closed polygon (last vertex connects to first).
    /// For positive signed area, vertices should be ordered counter-clockwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // A square
    /// let square = Geometry<Double, Void>.Polygon(vertices: [
    ///     .init(x: 0, y: 0),
    ///     .init(x: 1, y: 0),
    ///     .init(x: 1, y: 1),
    ///     .init(x: 0, y: 1)
    /// ])
    /// print(square.area)       // 1.0
    /// print(square.perimeter)  // 4.0
    /// print(square.isConvex)   // true
    /// ```
    public struct Polygon {
        /// The vertices of the polygon in order
        public var vertices: [Point<2>]

        /// Create a polygon from an array of vertices
        @inlinable
        public init(vertices: consuming [Point<2>]) {
            self.vertices = vertices
        }
    }
}

extension Geometry.Polygon: Sendable where Scalar: Sendable {}
extension Geometry.Polygon: Equatable where Scalar: Equatable {}
extension Geometry.Polygon: Hashable where Scalar: Hashable {}

// MARK: - Codable
#if !hasFeature(Embedded)
    extension Geometry.Polygon: Codable where Scalar: Codable {}
#endif
// MARK: - Basic Properties

extension Geometry.Polygon {
    /// The number of vertices (and edges)
    @inlinable
    public var vertexCount: Int { vertices.count }

    /// Whether the polygon has at least 3 vertices
    @inlinable
    public var isValid: Bool { vertices.count >= 3 }
}

// MARK: - Edges

extension Geometry.Polygon where Scalar: AdditiveArithmetic {
    /// The edges of the polygon as line segments
    @inlinable
    public var edges: [Geometry.Line.Segment] {
        guard vertices.count >= 2 else { return [] }
        var result: [Geometry.Line.Segment] = []
        result.reserveCapacity(vertices.count)
        for i in 0..<vertices.count {
            let next = (i + 1) % vertices.count
            result.append(Geometry.Line.Segment(start: vertices[i], end: vertices[next]))
        }
        return result
    }
}

// MARK: - Area and Perimeter (SignedNumeric)

extension Geometry.Polygon where Scalar: SignedNumeric {
    /// The signed double area of the polygon using the shoelace formula.
    ///
    /// Positive if vertices are counter-clockwise, negative if clockwise.
    /// Returns a typed `Linear.Area` for dimensional safety.
    @inlinable
    public var signedDoubleArea: Linear<Scalar, Space>.Area {
        guard vertices.count >= 3 else { return Tagged(.zero) }

        let zeroX = Geometry.X.zero
        let zeroY = Geometry.Y.zero
        var sum: Linear<Scalar, Space>.Area = Tagged(.zero)

        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            // Coordinate - Coordinate.zero = Displacement
            let xi = vertices[i].x - zeroX
            let yi = vertices[i].y - zeroY
            let xj = vertices[j].x - zeroX
            let yj = vertices[j].y - zeroY
            // Dx × Dy = Area (typed multiplication)
            sum = sum + xi * yj - xj * yi
        }
        return sum
    }
}

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// The area of the polygon (always positive)
    @inlinable
    public var area: Geometry.Area { Geometry.area(of: self) }

    /// The perimeter of the polygon
    @inlinable
    public var perimeter: Geometry.Perimeter { Geometry.perimeter(of: self) }
}

// MARK: - Centroid (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint & SignedNumeric {
    /// The centroid (center of mass) of the polygon.
    ///
    /// Returns `nil` if the polygon has zero area.
    @inlinable
    public var centroid: Geometry.Point<2>? { Geometry.centroid(of: self) }
}

// MARK: - Bounding Box (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// The axis-aligned bounding box of the polygon.
    ///
    /// Returns `nil` if the polygon has no vertices.
    @inlinable
    public var boundingBox: Geometry.Rectangle? {
        guard let first = vertices.first else { return nil }

        var minX = first.x.underlying
        var maxX = first.x.underlying
        var minY = first.y.underlying
        var maxY = first.y.underlying

        for vertex in vertices.dropFirst() {
            minX = min(minX, vertex.x.underlying)
            maxX = max(maxX, vertex.x.underlying)
            minY = min(minY, vertex.y.underlying)
            maxY = max(maxY, vertex.y.underlying)
        }

        return Geometry.Rectangle(
            llx: Geometry.X(minX),
            lly: Geometry.Y(minY),
            urx: Geometry.X(maxX),
            ury: Geometry.Y(maxY)
        )
    }
}

// MARK: - Convexity (SignedNumeric)

extension Geometry.Polygon where Scalar: SignedNumeric & Comparable {
    /// Whether the polygon is convex.
    ///
    /// A polygon is convex if all interior angles are less than 180 degrees,
    /// which is equivalent to all cross products of consecutive edges having
    /// the same sign.
    @inlinable
    public var isConvex: Bool {
        guard vertices.count >= 3 else { return true }

        // Cross product of edge vectors: Dx × Dy - Dy × Dx = Area
        var sign: Linear<Scalar, Space>.Area?
        let zero: Linear<Scalar, Space>.Area = Tagged(.zero)

        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            let k = (i + 2) % vertices.count

            // Coordinate - Coordinate = Displacement
            let v1x = vertices[j].x - vertices[i].x
            let v1y = vertices[j].y - vertices[i].y
            let v2x = vertices[k].x - vertices[j].x
            let v2y = vertices[k].y - vertices[j].y

            // Dx × Dy = Area (typed cross product)
            let cross = v1x * v2y - v1y * v2x

            if let existingSign = sign {
                if cross > zero && existingSign < zero { return false }
                if cross < zero && existingSign > zero { return false }
            } else if cross != zero {
                sign = cross
            }
        }

        return true
    }
}

// MARK: - Winding and Orientation

extension Geometry.Polygon where Scalar: SignedNumeric & Comparable {
    /// Whether the vertices are ordered counter-clockwise.
    @inlinable
    public var isCounterClockwise: Bool {
        signedDoubleArea > Tagged(.zero)
    }

    /// Whether the vertices are ordered clockwise.
    @inlinable
    public var isClockwise: Bool {
        signedDoubleArea < Tagged(.zero)
    }

    /// Return a polygon with reversed vertex order.
    @inlinable
    public var reversed: Self {
        Self(vertices: vertices.reversed())
    }
}

// MARK: - Containment (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Check if a point is inside the polygon using the ray casting algorithm.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is inside the polygon
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        guard vertices.count >= 3 else { return false }

        var inside = false
        var j = vertices.endIndex - 1

        for i in 0..<vertices.count {
            let vi = vertices[i]
            let vj = vertices[j]

            if (vi.y.underlying > point.y.underlying) != (vj.y.underlying > point.y.underlying) {
                let slope = (vj.x.underlying - vi.x.underlying) / (vj.y.underlying - vi.y.underlying)
                let xIntersect = vi.x.underlying + slope * (point.y.underlying - vi.y.underlying)
                if point.x.underlying < xIntersect {
                    inside.toggle()
                }
            }
            j = i
        }

        return inside
    }

    /// Check if a point is on the boundary of the polygon.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is on any edge
    @inlinable
    public func isOnBoundary(_ point: Geometry.Point<2>) -> Bool {
        let threshold = Geometry.Distance(.ulpOfOne * 100)
        for edge in edges {
            if edge.distance(to: point) < threshold {
                return true
            }
        }
        return false
    }
}

// MARK: - Transformation (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Return a polygon translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(vertices: vertices.map { $0 + vector })
    }

    /// Return a polygon scaled uniformly about its centroid.
    @inlinable
    public func scaled(by factor: Scale<1, Scalar>) -> Self? {
        guard let center = centroid else { return nil }
        return scaled(by: factor, about: center)
    }

    /// Return a polygon scaled uniformly about a given point.
    @inlinable
    public func scaled(by factor: Scale<1, Scalar>, about point: Geometry.Point<2>) -> Self {
        // Mathematically: p' = center + factor × (p - center)
        // Using typed operations: Coordinate + Scale × Displacement = Coordinate
        Self(
            vertices: vertices.map { v in
                Geometry.Point(
                    x: point.x + factor * (v.x - point.x),
                    y: point.y + factor * (v.y - point.y)
                )
            }
        )
    }
}

// MARK: - Triangulation (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Triangulate the polygon using ear clipping.
    ///
    /// Works correctly for simple (non-self-intersecting) polygons.
    /// Returns an array of triangles that cover the polygon.
    ///
    /// - Returns: Array of triangles, or empty array if triangulation fails
    @inlinable
    public func triangulate() -> [Geometry.Triangle] {
        guard vertices.count >= 3 else { return [] }
        if vertices.count == 3 {
            return [Geometry.Triangle(a: vertices[0], b: vertices[1], c: vertices[2])]
        }

        // Simple ear clipping - works for convex polygons and many simple polygons
        var remaining = vertices
        var triangles: [Geometry.Triangle] = []
        triangles.reserveCapacity(vertices.count - 2)

        while remaining.count > 3 {
            var earFound = false

            for i in 0..<remaining.count {
                // reason: Canonical cyclic-polygon previous-vertex formula
                // in ear-clipping triangulation. `(i + N − 1) mod N` is the
                // unsigned-int standard for `i − 1 mod N` (avoiding negative
                // intermediate via `+N`). Math IS the expression.
                // swiftlint:disable:next cardinal_count_minus_one_anti_pattern
                let prev = (i + remaining.count - 1) % remaining.count
                let next = (i + 1) % remaining.count

                let a = remaining[prev]
                let b = remaining[i]
                let c = remaining[next]

                // Check if this is a convex vertex (ear candidate)
                // Coordinate - Coordinate = Displacement, Dx × Dy = Area
                let cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

                // For CCW polygon, ears have positive cross product
                guard cross > Tagged(Scalar(0)) else { continue }

                // Check if any other vertex is inside this triangle
                let triangle = Geometry.Triangle(a: a, b: b, c: c)
                var isEar = true

                for j in 0..<remaining.count {
                    if j == prev || j == i || j == next { continue }
                    if triangle.contains(remaining[j]) {
                        isEar = false
                        break
                    }
                }

                if isEar {
                    triangles.append(triangle)
                    remaining.remove(at: i)
                    earFound = true
                    break
                }
            }

            if !earFound {
                // Failed to find an ear - polygon might be self-intersecting
                break
            }
        }

        if remaining.count == 3 {
            triangles.append(Geometry.Triangle(a: remaining[0], b: remaining[1], c: remaining[2]))
        }

        return triangles
    }
}

// MARK: - Polygon Static Implementations

extension Geometry where Scalar: FloatingPoint {
    /// Calculate the area of a polygon (always positive).
    @inlinable
    public static func area(of polygon: Polygon) -> Area {
        let signedArea = signedDoubleArea(of: polygon)
        // abs of typed area, then divide by 2
        let absArea = signedArea.underlying < 0 ? -signedArea.underlying : signedArea.underlying
        return Area(absArea / 2)
    }

    /// Calculate the signed double area of a polygon using the shoelace formula.
    ///
    /// Returns a typed `Linear.Area` for dimensional safety.
    @inlinable
    public static func signedDoubleArea(of polygon: Polygon) -> Linear<Scalar, Space>.Area
    where Scalar: SignedNumeric {
        polygon.signedDoubleArea
    }

    /// Calculate the perimeter of a polygon.
    @inlinable
    public static func perimeter(of polygon: Polygon) -> Perimeter {
        guard polygon.vertices.count >= 2 else { return .zero }

        var sum: Length = .zero
        for i in 0..<polygon.vertices.count {
            let j = (i + 1) % polygon.vertices.count
            sum += polygon.vertices[i].distance(to: polygon.vertices[j])
        }
        return sum
    }

    /// Calculate the centroid (center of mass) of a polygon.
    @inlinable
    public static func centroid(of polygon: Polygon) -> Point<2>? where Scalar: SignedNumeric {
        guard polygon.vertices.count >= 3 else { return nil }

        // Use typed signedDoubleArea, extract raw value for centroid math
        let a = signedDoubleArea(of: polygon).underlying
        guard abs(a) > .ulpOfOne else { return nil }

        var cx: Scalar = .zero
        var cy: Scalar = .zero

        let zeroX = X.zero
        let zeroY = Y.zero

        for i in 0..<polygon.vertices.count {
            let j = (i + 1) % polygon.vertices.count
            // Coordinate - Coordinate.zero = Displacement
            let xi = polygon.vertices[i].x - zeroX
            let yi = polygon.vertices[i].y - zeroY
            let xj = polygon.vertices[j].x - zeroX
            let yj = polygon.vertices[j].y - zeroY
            // Dx × Dy = Area, extract raw value for centroid mixing
            let cross = (xi * yj - xj * yi).underlying
            // Centroid formula inherently mixes coordinates (weighted average)
            cx += (xi.underlying + xj.underlying) * cross
            cy += (yi.underlying + yj.underlying) * cross
        }

        // Normalize by 1/(3*area) to get centroid coordinates
        let factor: Scalar = 1 / (3 * a)
        return Point(x: X(cx * factor), y: Y(cy * factor))
    }
}

// MARK: - Functorial Map

extension Geometry.Polygon {
    /// Create a polygon by transforming the coordinates of another polygon
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U, Space>.Polygon,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        var result: [Geometry.Point<2>] = []
        result.reserveCapacity(other.vertices.count)
        for vertex in other.vertices {
            result.append(try Geometry.Point<2>(vertex, transform))
        }
        self.init(vertices: result)
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result, Space>.Polygon {
        var result: [Geometry<Result, Space>.Point<2>] = []
        result.reserveCapacity(vertices.count)
        for vertex in vertices {
            result.append(try vertex.map(transform))
        }
        return Geometry<Result, Space>.Polygon(vertices: result)
    }
}
