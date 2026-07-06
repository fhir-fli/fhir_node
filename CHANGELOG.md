## 0.1.0

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
