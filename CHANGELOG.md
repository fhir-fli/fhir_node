## 0.6.1

- Alongside the `FhirNode` contract (unchanged), the pieces every
  model-independent package in the family had started to copy:
  `ResourceModel<R>` (what a version supplies to a package that reads
  resources through `FhirNode` and builds them only from JSON: version,
  resource type names, from/to JSON), `errorOperationOutcomeJson` (the one
  error-issue OperationOutcome, as JSON, with optional contained
  resources), and `JsonNode` (a `FhirNode` over plain JSON, for tests and
  tools without a model; element types are element names).

## 0.6.0

> Versioned 0.6.0 (not 0.1.0) to ship on the same release train as
> the fhir_r4/r5/r6 family — the fhir-fli packages version in
> lockstep (ucum excepted, which is independent).

- Initial release: the read-only `FhirNode` model-reflection interface —
  `fhirType`, `isPrimitive`, `isResource`, `primitiveValue`, `hasType`,
  `isEmpty`, `getChildrenByName`, `listChildrenNames`, `getChildByName`,
  `equalsDeep`, `isMetadataBased`.
- Implemented by the `fhir_r4`/`fhir_r5`/`fhir_r6` `FhirBase` classes;
  consumed by the standalone `fhirpath` and `cql` engines.
- Scope commitment: this interface is read-only navigation, permanently.
  Mutation support will be a separate `MutableFhirNode` interface so that
  adding it never breaks implementers (see the compatibility policy in the
  README).
