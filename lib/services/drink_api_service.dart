import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drink.dart';

class DrinkApiService {
  static const String baseUrl = 'http://api-abp.thebamfams.web.id/core/drinks';

  // Get all drinks
  Future<List<Drink>> getAllDrinks() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> drinksData = jsonData['data'];
        return drinksData.map((drink) => Drink.fromJson(drink)).toList();
      } else {
        throw Exception('Failed to load drinks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching drinks: $e');
    }
  }

  // Get single drink by ID
  Future<Drink> getDrinkById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Drink.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load drink: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching drink: $e');
    }
  }

  // Create new drink
  Future<Drink> createDrink(Drink drink) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(drink.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Drink.fromJson(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create drink: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Error creating drink: $e');
    }
  }

  // Update drink
  Future<Drink> updateDrink(String id, Drink drink) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(drink.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Drink.fromJson(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to update drink: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Error updating drink: $e');
    }
  }

  // Delete drink
  Future<void> deleteDrink(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete drink: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting drink: $e');
    }
  }
}