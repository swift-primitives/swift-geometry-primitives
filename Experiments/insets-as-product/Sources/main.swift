// MARK: - Geometry.Insets as Product<Height, Width, Height, Width>
// Purpose: Determine whether Geometry.Insets can be replaced by a Product typealias
//          with labeled accessors via extensions
// Hypothesis: Parameter-pack Product cannot support constrained extensions for
//             generic pack instantiations, blocking labeled accessors
//
// Toolchain: Apple Swift 6.2.4 (swiftlang-6.2.4.1.4 clang-1700.6.4.2)
// Platform: macOS 26.2 (arm64)
//
// Result: REFUTED — blocked by known compiler limitation:
//         "same-type requirements between packs and concrete types are not yet supported"
//         (swiftlang/swift test/Generics/variadic_generic_types.swift:128)
//
//         Three findings: (1) pack type not unwrapped inside concrete extensions,
//         (2) no generic pack-shape extensions possible, (3) free functions and
//         wrapper structs work as partial workarounds but don't justify replacing
//         the current named struct.
//
// Date: 2026-03-20

// ============================================================================
// Minimal type infrastructure
// ============================================================================

@dynamicMemberLookup
struct Product<each Element> {
    var values: (repeat each Element)

    init(_ values: repeat each Element) {
        self.values = (repeat each values)
    }

    subscript<T>(dynamicMember keyPath: KeyPath<(repeat each Element), T>) -> T {
        values[keyPath: keyPath]
    }
}

extension Product: Sendable where repeat each Element: Sendable {}
extension Product: Equatable where repeat each Element: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        func check<T: Equatable>(_ l: T, _ r: T) -> Bool { l == r }
        for element in repeat (check((each lhs.values), (each rhs.values))) {
            guard element else { return false }
        }
        return true
    }
}

struct Tagged<Tag, Value> {
    var rawValue: Value
    init(_ value: Value) { self.rawValue = value }
}

extension Tagged: Sendable where Value: Sendable {}
extension Tagged: Equatable where Value: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.rawValue == rhs.rawValue }
}
extension Tagged: AdditiveArithmetic where Value: AdditiveArithmetic {
    static var zero: Self { Self(Value.zero) }
    static func + (lhs: Self, rhs: Self) -> Self { Self(lhs.rawValue + rhs.rawValue) }
    static func - (lhs: Self, rhs: Self) -> Self { Self(lhs.rawValue - rhs.rawValue) }
}
extension Tagged {
    func map<U>(_ transform: (Value) -> U) -> Tagged<Tag, U> {
        Tagged<Tag, U>(transform(rawValue))
    }
}

enum XTag<Space> {}
enum YTag<Space> {}

enum Geometry<Scalar, Space> {
    typealias Width = Tagged<XTag<Space>, Scalar>
    typealias Height = Tagged<YTag<Space>, Scalar>
}

typealias Insets<S, Sp> = Product<
    Geometry<S, Sp>.Height,
    Geometry<S, Sp>.Width,
    Geometry<S, Sp>.Height,
    Geometry<S, Sp>.Width
>

// ============================================================================
// MARK: - Variant 1: Concrete pack extension — declaration
// Hypothesis: extension Product<Int, String, Double> { } compiles in 6.2.4
// Result: CONFIRMED — Build Succeeded (was error in Swift 5.9 ABI target)
// ============================================================================

extension Product<Int, String, Double> {
    func selfType() -> String { "\(type(of: self))" }
    // Output: Product<Pack{Int, String, Double}>
}

// ============================================================================
// MARK: - Variant 2: Pack unwrapping inside concrete extension
// Hypothesis: values is unwrapped to (Int, String, Double) inside the extension
// Result: REFUTED — compiler still treats values as (repeat each Element)
//
// Error: "pack expansion requires that 'each Element' and 'Int, String, Double'
//         have the same shape"
// Command: swift build
// ============================================================================

// Direct assignment fails:
// extension Product<Int, String, Double> {
//     var first: Int {
//         let t: (Int, String, Double) = values  // ❌
//         return t.0
//     }
// }
//
// Positional access fails:
// extension Product<Int, String, Double> {
//     var first: Int { values.0 }  // ❌ "value pack expansion can only appear..."
// }
//
// dynamicMemberLookup fails:
// extension Product<Int, String, Double> {
//     var first: Int { self.0 }  // ❌ "no dynamic member '0'"
// }

// ============================================================================
// MARK: - Variant 3: Force cast workaround
// Hypothesis: values as! (Int, String, Double) works at runtime
// Result: CONFIRMED — forced cast succeeds, positional access works after cast
// ============================================================================

extension Product<Int, String, Double> {
    func variant3() {
        let concrete = values as! (Int, String, Double)
        print("V3 — .0: \(concrete.0), .1: \(concrete.1), .2: \(concrete.2)")
        // Output: V3 — .0: 1, .1: hello, .2: 3.14
    }
}

// ============================================================================
// MARK: - Variant 4: Concrete extension with labeled getters via as!
// Hypothesis: labeled computed properties work using force-cast internally
// Result: CONFIRMED — but requires unsafe as! for each accessor
// ============================================================================

extension Product<
    Tagged<YTag<Void>, Double>,
    Tagged<XTag<Void>, Double>,
    Tagged<YTag<Void>, Double>,
    Tagged<XTag<Void>, Double>
> {
    private var concrete: (
        Tagged<YTag<Void>, Double>,
        Tagged<XTag<Void>, Double>,
        Tagged<YTag<Void>, Double>,
        Tagged<XTag<Void>, Double>
    ) {
        values as! (
            Tagged<YTag<Void>, Double>,
            Tagged<XTag<Void>, Double>,
            Tagged<YTag<Void>, Double>,
            Tagged<XTag<Void>, Double>
        )
    }

    var top: Tagged<YTag<Void>, Double> { concrete.0 }
    var leading: Tagged<XTag<Void>, Double> { concrete.1 }
    var bottom: Tagged<YTag<Void>, Double> { concrete.2 }
    var trailing: Tagged<XTag<Void>, Double> { concrete.3 }
}

func testVariant4() {
    typealias H = Geometry<Double, Void>.Height
    typealias W = Geometry<Double, Void>.Width
    let p = Product(H(10), W(20), H(30), W(40))
    print("V4 — top: \(p.top.rawValue), leading: \(p.leading.rawValue)")
    print("V4 — bottom: \(p.bottom.rawValue), trailing: \(p.trailing.rawValue)")
}

// ============================================================================
// MARK: - Variant 5: External dynamicMemberLookup (.0, .1, .2, .3)
// Hypothesis: positional access works at the call site, not inside extensions
// Result: CONFIRMED — p.0 works externally for any concrete Product
// ============================================================================

func testVariant5() {
    typealias H = Geometry<Double, Void>.Height
    typealias W = Geometry<Double, Void>.Width
    let p = Product(H(10), W(20), H(30), W(40))
    let v0: H = p.0
    let v1: W = p.1
    let v2: H = p.2
    let v3: W = p.3
    print("V5 — .0: \(v0.rawValue), .1: \(v1.rawValue), .2: \(v2.rawValue), .3: \(v3.rawValue)")
    // Output: V5 — .0: 10.0, .1: 20.0, .2: 30.0, .3: 40.0
}

// ============================================================================
// MARK: - Variant 6: Generic pack-shape constraint (extension)
// Hypothesis: no Swift syntax exists for generic pack-shape extensions
// Result: REFUTED — cannot introduce unbound generic parameters in extension
//
// What we need:
//   extension Product<Tagged<YTag<S>, V>, Tagged<XTag<S>, V>, ...> { ... }
//   (S, V are unbound — no syntax to introduce them)
//
// What the compiler test suite says (variadic_generic_types.swift:128):
//   extension WithPack<Int, Int> {}
//   // expected-error: same-type requirements between packs and concrete types
//   //                 are not yet supported
// ============================================================================

// ============================================================================
// MARK: - Variant 7: Free function labeled accessors (GENERIC — works!)
// Hypothesis: free functions CAN constrain pack shapes via generic parameters
// Result: CONFIRMED — generic parameters at function level provide the
//         unbound variables that extensions cannot introduce
// ============================================================================

func top<S, Sp>(of p: Insets<S, Sp>) -> Geometry<S, Sp>.Height { p.0 }
func leading<S, Sp>(of p: Insets<S, Sp>) -> Geometry<S, Sp>.Width { p.1 }
func bottom<S, Sp>(of p: Insets<S, Sp>) -> Geometry<S, Sp>.Height { p.2 }
func trailing<S, Sp>(of p: Insets<S, Sp>) -> Geometry<S, Sp>.Width { p.3 }

func testVariant7() {
    typealias H = Geometry<Double, Void>.Height
    typealias W = Geometry<Double, Void>.Width
    let p = Product(H(10), W(20), H(30), W(40))
    print("V7 — top: \(top(of: p).rawValue), leading: \(leading(of: p).rawValue)")
    print("V7 — bottom: \(bottom(of: p).rawValue), trailing: \(trailing(of: p).rawValue)")
    // Output: V7 — top: 10.0, leading: 20.0, bottom: 30.0, trailing: 40.0
}

// ============================================================================
// MARK: - Variant 8: Component-wise AdditiveArithmetic via pack iteration
// Hypothesis: Product can have .zero, +, - when all elements are AdditiveArithmetic
// Result: CONFIRMED — pack iteration for arithmetic compiles and runs correctly
// ============================================================================

extension Product: AdditiveArithmetic where repeat each Element: AdditiveArithmetic {
    static var zero: Self {
        Self(repeat (each Element).zero)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(repeat (each lhs.values) + (each rhs.values))
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(repeat (each lhs.values) - (each rhs.values))
    }
}

func testVariant8() {
    typealias H = Geometry<Double, Void>.Height
    typealias W = Geometry<Double, Void>.Width
    let a: Insets<Double, Void> = Product(H(10), W(20), H(30), W(40))
    let b: Insets<Double, Void> = Product(H(1), W(2), H(3), W(4))
    let sum = a + b
    let zero: Insets<Double, Void> = .zero
    print("V8 — sum top: \(top(of: sum).rawValue), sum leading: \(leading(of: sum).rawValue)")
    print("V8 — zero top: \(top(of: zero).rawValue)")
    // Output: sum top: 11.0, sum leading: 22.0, zero top: 0.0
}

// ============================================================================
// MARK: - Variant 9: Codable
// Hypothesis: Product cannot provide keyed Codable {"top":..., "leading":...}
// Result: REFUTED — three independent blockers:
//   1. Parameter-pack Codable not expressible in Swift 6.2
//   2. Even if added, would produce array [v0, v1, v2, v3], not keyed container
//   3. Keyed Codable with domain keys requires generic constrained extension (V6)
//
// Current Insets JSON shape: {"top": 10, "leading": 20, "bottom": 30, "trailing": 40}
// Replacing with Product would be a BREAKING CHANGE for all consumers.
// ============================================================================

func testVariant9() {
    print("V9 — No Codable: breaking JSON shape change")
}

// ============================================================================
// MARK: - Variant 10: Scalar → Height/Width conversion
// Hypothesis: a single Scalar can construct both Height and Width
// Result: CONFIRMED — both are Tagged wrappers, zero-cost phantom tagging
// ============================================================================

func testVariant10() {
    typealias H = Geometry<Double, Void>.Height
    typealias W = Geometry<Double, Void>.Width
    let scalar: Double = 72.0
    let h = H(scalar)
    let w = W(scalar)
    print("V10 — Height(\(h.rawValue)), Width(\(w.rawValue)) from same scalar")
    // Output: Height(72.0), Width(72.0)
}

// ============================================================================
// MARK: - Run all variants
// ============================================================================

print("=== V1: Concrete pack extension declaration ===")
let p1 = Product(1, "hello", 3.14)
print("V1 — selfType: \(p1.selfType())")

print("\n=== V3: Force cast workaround ===")
p1.variant3()

print("\n=== V4: Concrete labeled getters via as! ===")
testVariant4()

print("\n=== V5: External dynamicMemberLookup ===")
testVariant5()

print("\n=== V7: Free function labeled accessors ===")
testVariant7()

print("\n=== V8: Component-wise arithmetic ===")
testVariant8()

print("\n=== V9: Codable ===")
testVariant9()

print("\n=== V10: Scalar conversion ===")
testVariant10()

// ============================================================================
// MARK: - Results Summary
//
// V1  (concrete ext declaration):     CONFIRMED — compiles in 6.2.4 (was error in 5.9)
// V2  (pack unwrapping in ext):       REFUTED   — pack not unwrapped, "same shape" error
// V3  (force cast workaround):        CONFIRMED — as! works at runtime (unsafe)
// V4  (concrete labeled getters):     CONFIRMED — works via as! (only for concrete types)
// V5  (external .0/.1 access):        CONFIRMED — dynamicMemberLookup at call site
// V6  (generic pack-shape ext):       REFUTED   — no syntax, known compiler limitation
// V7  (free function accessors):      CONFIRMED — generic constraints at function level work
// V8  (component-wise arithmetic):    CONFIRMED — pack iteration for AdditiveArithmetic
// V9  (Codable):                      REFUTED   — no pack Codable, breaking JSON shape
// V10 (Scalar → Height/Width):        CONFIRMED — trivial
//
// OVERALL: REFUTED (as of Swift 6.2.4)
//
// ROOT CAUSE: Known compiler limitation — "same-type requirements between packs
// and concrete types are not yet supported" (swiftlang/swift test/Generics/
// variadic_generic_types.swift:128). The pack type (repeat each Element) is not
// unwrapped to the concrete tuple inside extensions, even when the extension
// fully specifies concrete type arguments. The runtime type IS correct (V1, V3),
// but the static type system doesn't narrow.
//
// VIABLE WORKAROUNDS (with trade-offs):
//
// 1. Free functions: top(of:), leading(of:) — generic, safe, but not .top syntax
// 2. Concrete extension + as!: .top/.leading — .top syntax but requires unsafe
//    cast and separate extension per concrete instantiation (no generics)
// 3. Wrapper struct: InsetsView<S, Sp> — full API but adds indirection layer,
//    essentially reimplements the named struct
//
// RECOMMENDATION: Keep Geometry.Insets as a named struct.
//
// Rationale:
// - The named struct provides labeled properties, Codable, map, and init(all:)
//   with zero workarounds
// - Product workarounds either sacrifice safety (as!), generality (concrete-only),
//   or syntax (.top not available, or wrapper indirection)
// - When/if Swift supports pack-concrete same-type requirements, this experiment
//   can be revisited — the approach becomes viable if V2 and V6 are unblocked
// - The Product type is correctly scoped for generic algebraic composition,
//   not domain-specific labeled containers
// ============================================================================
