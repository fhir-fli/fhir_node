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

/// A navigable node of FHIR data — the read-only reflection contract that
/// model-independent engines (FHIRPath, CQL) use to walk FHIR data of any
/// version.
///
/// Each FHIR version's `FhirBase` implements these members natively
/// (covariant returns mean no method bodies change), so an engine written
/// against [FhirNode] navigates R4/R5/R6 data without importing any
/// `fhir_r*` package. The member shapes deliberately mirror the Java
/// reference (`Base.listChildrenByName`, `fhirType`, `equalsDeep`) and
/// .NET Firely's `ITypedElement` — do not "Dartify" them; the mirroring is
/// what lets implementers satisfy the contract with zero adaptation.
///
/// ## Scope and compatibility
///
/// This interface is **read-only navigation, permanently**. Mutation
/// (needed by e.g. the FHIR Mapping Language engine) will be a separate
/// interface (`MutableFhirNode`), added alongside — never here — because
/// every member added to this class is a breaking change for every
/// implementer. Implementers should pin an exact version or coordinate
/// upgrades; consumers (engines) can use normal caret constraints.
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

  /// Deep structural equality with [other]. Mirrors the Java reference's
  /// `Base.equalsDeep(Base)`.
  bool equalsDeep(covariant FhirNode? other);

  /// Whether this node comes from a metadata-driven (element-model)
  /// implementation rather than a generated class model. Mirrors the Java
  /// reference's `Base.isMetadataBased()`; deep-equality helpers use it to
  /// let the metadata-based side drive the comparison.
  bool get isMetadataBased;
}
