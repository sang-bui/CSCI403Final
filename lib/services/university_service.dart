import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/university.dart';

class UniversityService {
  static const String baseUrl = 'http://ada.mines.edu:8000'; // Your API server URL

  Future<List<University>> getUniversities({
    int skip = 0,
    int limit = 10,
    String? search,
    double? minScore,
    int? maxStudents,
    String? country,
  }) async {
    final queryParams = {
      'skip': skip.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
      if (minScore != null) 'min_score': minScore.toString(),
      if (maxStudents != null) 'max_students': maxStudents.toString(),
      if (country != null) 'country': country,
    };

    final uri = Uri.parse('$baseUrl/universities/').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => University.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load universities: ${response.statusCode}');
    }
  }

  Future<University> getUniversity(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/universities/$name'));

    if (response.statusCode == 200) {
      return University.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load university: ${response.statusCode}');
    }
  }

  Future<List<String>> getCountries() async {
    final response = await http.get(Uri.parse('$baseUrl/countries/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((country) => country.toString()).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }
} 