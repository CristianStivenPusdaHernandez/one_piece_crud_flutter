import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class CharacterService {
  static const String _baseUrl =
      'https://6a63af61b30b52361e1a90a0.mockapi.io/op/v1/characters';

  static Future<List<CharacterModel>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;

      return data
          .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar los personajes.');
  }

  static Future<CharacterModel> getById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return CharacterModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Error al cargar el personaje con id: $id.');
  }

  static Future<CharacterModel> create(CharacterModel character) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(character.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CharacterModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Error al crear el personaje.');
  }

  static Future<CharacterModel> update(String id, CharacterModel character) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(character.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CharacterModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Error al actualizar el personaje con id: $id.');
  }

  static Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (!(response.statusCode == 200 || response.statusCode == 204)) {
      throw Exception('Error al eliminar el personaje con id: $id.');
    }
  }
}
