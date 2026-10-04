import 'package:fhir_node/fhir_node.dart';
import 'package:test/test.dart';

void main() {
  test('one error issue, with only the parts given', () {
    expect(errorOperationOutcomeJson(details: 'HTTP 404'), {
      'resourceType': 'OperationOutcome',
      'issue': [
        {
          'severity': 'error',
          'code': 'invalid',
          'details': {'text': 'HTTP 404'},
        },
      ],
    });
    expect(
      errorOperationOutcomeJson(
        code: 'structure',
        diagnostics: 'body',
        contained: [
          {'resourceType': 'Patient', 'id': 'p'},
        ],
      ),
      {
        'resourceType': 'OperationOutcome',
        'contained': [
          {'resourceType': 'Patient', 'id': 'p'},
        ],
        'issue': [
          {'severity': 'error', 'code': 'structure', 'diagnostics': 'body'},
        ],
      },
    );
    expect(
      errorOperationOutcomeJson(contained: []).containsKey('contained'),
      isFalse,
    );
  });

  test('it reads back through JsonNode by element name', () {
    final oo = JsonNode.resource(
      errorOperationOutcomeJson(details: 'x', diagnostics: 'y'),
    );
    final issue = oo.getChildrenByName('issue').single;
    expect(issue.getChildByName('severity')?.primitiveValue, 'error');
    expect(
      issue.getChildByName('details')?.getChildByName('text')?.primitiveValue,
      'x',
    );
    expect(issue.getChildByName('diagnostics')?.primitiveValue, 'y');
  });
}
