import 'package:fhir_node/fhir_node.dart';
import 'package:test/test.dart';

void main() {
  final patient = JsonNode.resource({
    'resourceType': 'Patient',
    'id': 'p1',
    'active': true,
    'name': [
      {
        'family': 'Smith',
        'given': ['John', 'Q'],
      },
    ],
    'deceasedBoolean': false,
    'contained': [
      {'resourceType': 'Observation', 'id': 'o1'},
    ],
  });

  test('a resource is typed by its resourceType', () {
    expect(patient.fhirType, 'Patient');
    expect(patient.isResource, isTrue);
    expect(patient.isPrimitive, isFalse);
    expect(patient.hasType(['patient']), isTrue);
    expect(
      () => JsonNode.resource({'id': 'x'}),
      throwsFormatException,
    );
  });

  test('children by name: primitives, repeats, nested maps', () {
    expect(patient.getChildByName('id')?.primitiveValue, 'p1');
    expect(patient.getChildByName('active')?.primitiveValue, 'true');
    expect(patient.getChildByName('active')?.isPrimitive, isTrue);
    final name = patient.getChildrenByName('name').single;
    expect(name.fhirType, 'name');
    expect(name.getChildByName('family')?.primitiveValue, 'Smith');
    expect(
      name.getChildrenByName('given').map((g) => g.primitiveValue),
      ['John', 'Q'],
    );
    expect(() => name.getChildByName('given'), throwsStateError);
    expect(patient.getChildrenByName('missing'), isEmpty);
    expect(patient.getChildByName('missing'), isNull);
  });

  test('a choice element is found by its prefix and typed by its suffix', () {
    final deceased = patient.getChildByName('deceased');
    expect(deceased?.fhirType, 'Boolean');
    expect(deceased?.primitiveValue, 'false');
  });

  test('a nested resource is typed by its own resourceType', () {
    final contained = patient.getChildrenByName('contained').single;
    expect(contained.fhirType, 'Observation');
    expect(contained.isResource, isTrue);
  });

  test('listChildrenNames, isEmpty and equalsDeep', () {
    expect(patient.listChildrenNames(), contains('name'));
    expect(JsonNode(null, 'string').isEmpty(), isTrue);
    expect(patient.isEmpty(), isFalse);
    expect(
      patient.equalsDeep(JsonNode.resource(patient.json)),
      isTrue,
    );
    expect(
      patient.equalsDeep(JsonNode.resource({'resourceType': 'Patient'})),
      isFalse,
    );
    expect(patient.isMetadataBased, isFalse);
  });
}
