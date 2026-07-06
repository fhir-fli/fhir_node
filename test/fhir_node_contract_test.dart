import 'package:fhir_node/fhir_node.dart';
import 'package:test/test.dart';

/// Executable documentation of the FhirNode contract's expected behavior,
/// exercised through a minimal in-memory implementation. Real implementers
/// (fhir_r4/r5/r6 FhirBase) must satisfy the same expectations.
class TestNode implements FhirNode {
  TestNode(this.type, {this.value, this.children = const {}});

  final String type;
  final String? value;
  final Map<String, List<TestNode>> children;

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
      children[name] ?? const <TestNode>[];

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
  bool equalsDeep(covariant TestNode? other) {
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
  TestNode patient() => TestNode(
        'Patient',
        children: <String, List<TestNode>>{
          'name': <TestNode>[
            TestNode(
              'HumanName',
              children: <String, List<TestNode>>{
                'given': <TestNode>[
                  TestNode('string', value: 'Peter'),
                  TestNode('string', value: 'James'),
                ],
              },
            ),
          ],
          'active': <TestNode>[TestNode('boolean', value: 'true')],
        },
      );

  test('navigation: getChildrenByName returns [] for unknown names', () {
    expect(patient().getChildrenByName('nope'), isEmpty);
  });

  test('navigation: getChildByName returns null for absent, throws for >1', () {
    final p = patient();
    expect(p.getChildByName('nope'), isNull);
    expect(p.getChildByName('active')?.primitiveValue, 'true');
    final name = p.getChildByName('name')!;
    expect(() => name.getChildByName('given'), throwsStateError);
  });

  test('primitives carry a value; complex nodes do not', () {
    final p = patient();
    expect(p.isPrimitive, isFalse);
    expect(p.primitiveValue, isNull);
    final active = p.getChildByName('active')!;
    expect(active.isPrimitive, isTrue);
    expect(active.primitiveValue, 'true');
  });

  test('hasType is case-insensitive', () {
    expect(patient().hasType(<String>['patient']), isTrue);
    expect(patient().hasType(<String>['Observation']), isFalse);
  });

  test('equalsDeep is structural and reflexive', () {
    final a = patient();
    final b = patient();
    expect(a.equalsDeep(a), isTrue);
    expect(a.equalsDeep(b), isTrue);
    expect(a.equalsDeep(null), isFalse);
    expect(
      a.equalsDeep(
        TestNode(
          'Patient',
          children: <String, List<TestNode>>{
            'active': <TestNode>[TestNode('boolean', value: 'false')],
          },
        ),
      ),
      isFalse,
    );
  });

  test('generated-model implementations report isMetadataBased false', () {
    // Only element-model (metadata-driven) implementations return true;
    // class-model implementations like fhir_r4's FhirBase — and this test
    // node — are the non-metadata side (Java Base.isMetadataBased()).
    expect(patient().isMetadataBased, isFalse);
  });
}
