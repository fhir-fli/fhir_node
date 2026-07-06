// ignore_for_file: avoid_print
import 'package:fhir_node/fhir_node.dart';

/// A complete toy implementation of the [FhirNode] contract over plain
/// maps, demonstrating what any model package must provide. The real
/// implementers are the fhir_r4/r5/r6 `FhirBase` classes; the real
/// consumers are the fhirpath and cql engines.
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
      children[name] ?? const <MapNode>[];

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

  @override
  bool equalsDeep(covariant MapNode? other) {
    if (other == null ||
        type != other.type ||
        value != other.value ||
        children.length != other.children.length) {
      return false;
    }
    for (final entry in children.entries) {
      final theirs = other.children[entry.key];
      if (theirs == null || theirs.length != entry.value.length) {
        return false;
      }
      for (var i = 0; i < entry.value.length; i++) {
        if (!entry.value[i].equalsDeep(theirs[i])) {
          return false;
        }
      }
    }
    return true;
  }
}

void main() {
  final patient = MapNode(
    'Patient',
    children: <String, List<MapNode>>{
      'name': <MapNode>[
        MapNode(
          'HumanName',
          children: <String, List<MapNode>>{
            'family': <MapNode>[MapNode('string', value: 'Chalmers')],
            'given': <MapNode>[
              MapNode('string', value: 'Peter'),
              MapNode('string', value: 'James'),
            ],
          },
        ),
      ],
      'active': <MapNode>[MapNode('boolean', value: 'true')],
    },
  );

  // The navigation surface an engine uses:
  print(patient.fhirType); // Patient
  print(patient.isResource); // true
  print(patient.listChildrenNames()); // [name, active]

  final name = patient.getChildByName('name')!;
  final given = name.getChildrenByName('given');
  print(given.map((g) => g.primitiveValue).toList()); // [Peter, James]

  final active = patient.getChildByName('active')!;
  print(active.isPrimitive); // true
  print(active.primitiveValue); // true
  print(active.hasType(<String>['boolean', 'string'])); // true

  print(patient.equalsDeep(patient)); // true
}
