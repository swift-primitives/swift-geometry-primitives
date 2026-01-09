// Geometry.EdgeInsets.swift
// Insets from the edges of a rectangle.

extension Geometry {
    /// Insets from the edges of a rectangle with type-safe displacement values.
    ///
    /// Uses `Height` for vertical insets (top, bottom) and `Width` for horizontal
    /// insets (leading, trailing), ensuring type safety in layout calculations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let margins = Geometry<Double, Void>.EdgeInsets(
    ///     top: 72, leading: 72, bottom: 72, trailing: 72
    /// )
    /// let padded = rect.inset(by: margins)
    /// ```
    public struct EdgeInsets {
        /// Top inset (vertical displacement from top edge).
        public var top: Height

        /// Leading (left in LTR) inset (horizontal displacement from leading edge).
        public var leading: Width

        /// Bottom inset (vertical displacement from bottom edge).
        public var bottom: Height

        /// Trailing (right in LTR) inset (horizontal displacement from trailing edge).
        public var trailing: Width

        /// Creates edge insets from typed displacement values.
        ///
        /// - Parameters:
        ///   - top: Top inset (Height)
        ///   - leading: Leading inset (Width)
        ///   - bottom: Bottom inset (Height)
        ///   - trailing: Trailing inset (Width)
        @inlinable
        public init(
            top: consuming Height,
            leading: consuming Width,
            bottom: consuming Height,
            trailing: consuming Width
        ) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }
    }
}

extension Geometry.EdgeInsets: Sendable where Scalar: Sendable {}
extension Geometry.EdgeInsets: Equatable where Scalar: Equatable {}
extension Geometry.EdgeInsets: Hashable where Scalar: Hashable {}

// MARK: - Codable

#if !hasFeature(Embedded)
    extension Geometry.EdgeInsets: Codable where Scalar: Codable {
        private enum CodingKeys: String, CodingKey {
            case top, leading, bottom, trailing
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.top = try container.decode(Geometry.Height.self, forKey: .top)
            self.leading = try container.decode(Geometry.Width.self, forKey: .leading)
            self.bottom = try container.decode(Geometry.Height.self, forKey: .bottom)
            self.trailing = try container.decode(Geometry.Width.self, forKey: .trailing)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(top, forKey: .top)
            try container.encode(leading, forKey: .leading)
            try container.encode(bottom, forKey: .bottom)
            try container.encode(trailing, forKey: .trailing)
        }
    }
#endif

// MARK: - Convenience Initializers

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Creates edge insets with the same value on all edges.
    ///
    /// - Parameter all: The inset value for all edges
    @inlinable
    public init(all: Scalar) {
        self.top = Geometry.Height(all)
        self.leading = Geometry.Width(all)
        self.bottom = Geometry.Height(all)
        self.trailing = Geometry.Width(all)
    }

    /// Creates edge insets with horizontal and vertical values.
    ///
    /// - Parameters:
    ///   - horizontal: Inset for leading and trailing edges
    ///   - vertical: Inset for top and bottom edges
    @inlinable
    public init(horizontal: Geometry.Width, vertical: Geometry.Height) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Zero insets.
    @inlinable
    public static var zero: Self {
        Self(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    }
}

// MARK: - Functorial Map

extension Geometry.EdgeInsets {
    /// Creates edge insets by transforming each value of another edge insets.
    @inlinable
    public init<U>(
        _ other: borrowing Geometry<U, Space>.EdgeInsets,
        _ transform: (U) throws -> Scalar
    ) rethrows {
        self.init(
            top: try other.top.map(transform),
            leading: try other.leading.map(transform),
            bottom: try other.bottom.map(transform),
            trailing: try other.trailing.map(transform)
        )
    }

    /// Transforms each inset value using the given closure.
    @inlinable
    public func map<Result>(
        _ transform: (Scalar) throws -> Result
    ) rethrows -> Geometry<Result, Space>.EdgeInsets {
        Geometry<Result, Space>.EdgeInsets(
            top: try top.map(transform),
            leading: try leading.map(transform),
            bottom: try bottom.map(transform),
            trailing: try trailing.map(transform)
        )
    }
}

// MARK: - Monoid

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Combines two edge insets by adding their values.
    @inlinable
    public static func combined(_ lhs: borrowing Self, _ rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top + rhs.top,
            leading: lhs.leading + rhs.leading,
            bottom: lhs.bottom + rhs.bottom,
            trailing: lhs.trailing + rhs.trailing
        )
    }
}

// MARK: - Computed Properties

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Total horizontal inset (leading + trailing).
    @inlinable
    public var horizontal: Geometry.Width { leading + trailing }

    /// Total vertical inset (top + bottom).
    @inlinable
    public var vertical: Geometry.Height { top + bottom }
}
