/// A navigable node of FHIR data — the model-reflection contract the
/// model-independent FHIRPath / CQL engines navigate.
///
/// This is deliberately **not** a FHIRPath-specific type. Its members
/// (children by name, type name, primitive value) are general FHIR
/// reflection — exactly the surface the reference engines depend on (Java's
/// `Base.listChildrenByName`/`fhirType`, .NET Firely's `ITypedElement`).
///
/// Each FHIR version's `FhirBase` already implements these members natively,
/// so it satisfies [FhirNode] directly (covariant returns mean no method
/// bodies change). An engine written against [FhirNode] can therefore
/// navigate R4 / R5 / R6 data without importing any `fhir_r*` package.
library;

abstract class FhirNode {
  /// The FHIR type name of this node (e.g. `'Patient'`, `'string'`).
  String get fhirType;

  /// Whether this node is a primitive (carries a single scalar value).
  bool get isPrimitive;

  /// Whether this node is a resource (the root of an independent FHIR data
  /// tree, as opposed to an element within one). Mirrors the Java
  /// reference's `Base.isResource()`.
  bool get isResource;

  /// The scalar value of a primitive node as a string, or `null`.
  String? get primitiveValue;

  /// Whether this node's [fhirType] matches any of [names]
  /// (case-insensitive).
  bool hasType(List<String> names);

  /// Whether this node has no value.
  bool isEmpty();

  /// The children of this node under the element [name].
  List<FhirNode> getChildrenByName(String name, [bool checkValid = false]);

  /// The element names under which this node can have children.
  List<String> listChildrenNames();

  /// The single child under [name], or `null` (throws if more than one).
  FhirNode? getChildByName(String name);
}
