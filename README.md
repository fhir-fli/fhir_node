# fhir_node

The minimal model-reflection interface of the
[fhir-fli](https://github.com/fhir-fli) ecosystem: `FhirNode` is the
read-only contract that model-independent engines
([fhirpath](https://github.com/fhir-fli/fhirpath), cql) use to navigate
FHIR data of **any** version without depending on a specific model package.

```
fhir_r4 ──implements──▶
fhir_r5 ──implements──▶  FhirNode  ◀──navigates── fhirpath / cql engines
fhir_r6 ──implements──▶
```

- **Implemented by**: each version's `FhirBase` (the root of the generated
  model classes in `fhir_r4`/`fhir_r5`/`fhir_r6`). Covariant returns mean
  the classes satisfy the contract with their existing member bodies.
- **Consumed by**: the standalone `fhirpath` and `cql` engines, and any
  other tool that wants version-independent FHIR navigation.

The member shapes deliberately mirror the Java reference implementation
(`Base.listChildrenByName`, `fhirType`, `equalsDeep`, `isMetadataBased`)
and are the same design point as .NET Firely's `ITypedElement`.

`fhir_node` has **no dependencies** — it is the smallest of the
model-independent foundation packages (with `ucum` and `fhirpath`) and the
one every version-agnostic engine builds on.

## Install

```yaml
dependencies:
  fhir_node: ^0.6.0
```

## Compatibility policy — read before depending on this

`FhirNode` is an interface that other packages `implements`. Under Dart
semantics **every member added to it is a breaking change for every
implementer** — there is no additive-minor escape hatch. Therefore:

- The interface is **read-only navigation, permanently**. Mutation support
  (for e.g. the FHIR Mapping Language engine) will ship as a *separate*
  interface (`MutableFhirNode`) so that adding it breaks nobody.
- **Implementers** (model packages) should pin an exact version or
  coordinate upgrades with their release train.
- **Consumers** (engines) can use normal caret constraints — calling
  members is never broken by additions.

## Implementing the contract

Any class with a FHIR-shaped tree can participate:

```dart
import 'package:fhir_node/fhir_node.dart';

class MapNode implements FhirNode {
  MapNode(this.type, {this.value, this.children = const {}});
  final String type;
  final String? value;
  final Map<String, List<MapNode>> children;

  @override
  String get fhirType => type;
  @override
  bool get isPrimitive => value != null;
  @override
  bool get isResource => type.isNotEmpty && type[0] == type[0].toUpperCase();
  @override
  String? get primitiveValue => value;
  @override
  bool get isMetadataBased => false;
  @override
  bool hasType(List<String> names) =>
      names.any((n) => n.toLowerCase() == type.toLowerCase());
  @override
  bool isEmpty() => value == null && children.isEmpty;
  @override
  List<FhirNode> getChildrenByName(String name, [bool checkValid = false]) =>
      children[name] ?? const [];
  @override
  List<String> listChildrenNames() => children.keys.toList();
  @override
  FhirNode? getChildByName(String name) {
    final matches = getChildrenByName(name);
    if (matches.length > 1) {
      throw StateError('Attempt to read a single child when there is more '
          'than one present ($name)');
    }
    return matches.isEmpty ? null : matches.first;
  }
  // equalsDeep: see example/fhir_node_example.dart
  ...
}
```

See `example/fhir_node_example.dart` for a complete runnable version.

## License

MIT © FHIR-FLI.
