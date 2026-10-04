/// A navigable node of FHIR data — the model-reflection contract the
/// model-independent FHIRPath / CQL engines navigate — and the small set of
/// pieces every model-independent package in the family shares.
///
/// [FhirNode] is deliberately **not** a FHIRPath-specific type. Its members
/// (children by name, type name, primitive value) are general FHIR
/// reflection — exactly the surface the reference engines depend on (Java's
/// `Base.listChildrenByName`/`fhirType`, .NET Firely's `ITypedElement`).
///
/// Each FHIR version's `FhirBase` already implements these members natively,
/// so it satisfies [FhirNode] directly (covariant returns mean no method
/// bodies change). An engine written against [FhirNode] can therefore
/// navigate R4 / R5 / R6 data without importing any `fhir_r*` package.
///
/// Alongside the contract, since 0.6.1: [ResourceModel], what a version
/// supplies to a package that reads resources through [FhirNode] and
/// builds them only from JSON (`fhir_bulk`, `fhir_at_rest`);
/// [errorOperationOutcomeJson], the one error-issue OperationOutcome every
/// such package answers a failure with; and [JsonNode], a [FhirNode] over
/// plain JSON for tests and tools that have no model to hand.
library;

export 'src/fhir_node.dart';
export 'src/json_node.dart';
export 'src/operation_outcome_json.dart';
export 'src/resource_model.dart';
