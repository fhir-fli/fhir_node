import 'dart:convert';

import 'package:fhir_node/src/fhir_node.dart';

/// A [FhirNode] over plain JSON, with no FHIR version linked: for tests of
/// model-independent code, and for tools that read a resource by element
/// name without a model to hand.
///
/// A map is an element, a list is a repeat, anything else is a primitive
/// whose [primitiveValue] is its text. The [fhirType] of a resource is its
/// `resourceType`; of any other element it is the **element name** the
/// node hangs under (`name`, `coding`), or the choice suffix for a choice
/// element (`value` finds `valueQuantity`, typed `Quantity`), because JSON
/// carries no type names. Code that needs real element types needs a
/// version's model.
class JsonNode implements FhirNode {
  /// Creates a node over [value] with the given [fhirType].
  JsonNode(this.value, this.fhirType);

  /// A resource from its JSON map; throws [FormatException] without a
  /// `resourceType`.
  factory JsonNode.resource(Map<String, dynamic> json) {
    final type = json['resourceType'];
    if (type is! String) {
      throw FormatException('A resource needs a resourceType', json);
    }
    return JsonNode(json, type);
  }

  /// The JSON this node is over: a map, a list, or a primitive.
  final Object? value;

  @override
  final String fhirType;

  /// The map this node is, for a resource or a complex element.
  Map<String, dynamic> get json => value! as Map<String, dynamic>;

  @override
  bool get isPrimitive => value is! Map && value is! List;

  @override
  bool get isResource => value is Map && json.containsKey('resourceType');

  @override
  String? get primitiveValue => isPrimitive ? value?.toString() : null;

  @override
  bool hasType(List<String> names) =>
      names.any((n) => n.toLowerCase() == fhirType.toLowerCase());

  @override
  bool isEmpty() => value == null;

  @override
  bool get isMetadataBased => false;

  @override
  bool equalsDeep(covariant FhirNode? other) =>
      other is JsonNode && jsonEncode(value) == jsonEncode(other.value);

  @override
  List<String> listChildrenNames() =>
      value is Map ? json.keys.toList() : const [];

  @override
  FhirNode? getChildByName(String name) {
    final all = getChildrenByName(name);
    if (all.length > 1) throw StateError('more than one child for $name');
    return all.isEmpty ? null : all.first;
  }

  @override
  List<FhirNode> getChildrenByName(String name, [bool checkValid = false]) {
    if (value is! Map) return const [];
    var v = json[name];
    var type = name;
    if (v == null) {
      for (final key in json.keys) {
        if (key.startsWith(name) &&
            key.length > name.length &&
            key[name.length].toUpperCase() == key[name.length]) {
          v = json[key];
          type = key.substring(name.length);
          break;
        }
      }
    }
    if (v == null) return const [];
    JsonNode node(Object? e) => JsonNode(
          e,
          e is Map<String, dynamic> && e['resourceType'] is String
              ? e['resourceType'] as String
              : type,
        );
    if (v is List) return [for (final e in v) node(e)];
    return [node(v)];
  }
}
