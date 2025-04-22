import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/university.dart';

class UniversityService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<University>> getUniversities({int skip = 0, int limit = 100}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/universities/?skip=$skip&limit=$limit'));
      developer.log('API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        developer.log('Parsed data length: ${data.length}');
        
        final universities = data.map((json) {
          try {
            return University.fromJson(json);
          } catch (e) {
            developer.log('Error parsing university: $e');
            developer.log('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
        
        developer.log('Parsed universities length: ${universities.length}');
        return universities;
      } else {
        throw Exception('Failed to load universities: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getUniversities: $e');
      rethrow;
    }
  }

  Future<List<University>> searchUniversities(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse('$baseUrl/universities/search/$encodedQuery');
      developer.log('Search URL: $uri');

      final response = await http.get(uri);
      developer.log('Search Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => University.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search universities: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in searchUniversities: $e');
      rethrow;
    }
  }

  Future<List<University>> getUniversitiesByState(String state) async {
    try {
      final encodedState = Uri.encodeComponent(state);
      final uri = Uri.parse('$baseUrl/universities/state/$encodedState');
      
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => University.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load universities by state');
      }
    } catch (e) {
      developer.log('Error in getUniversitiesByState: $e');
      rethrow;
    }
  }

  Future<University> getUniversityDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/universities/$id'));
      if (response.statusCode == 200) {
        return University.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load university details');
      }
    } catch (e) {
      developer.log('Error in getUniversityDetails: $e');
      rethrow;
    }
  }
} 