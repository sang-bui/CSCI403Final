import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/university.dart';

class UniversityService {
  final String baseUrl;

  UniversityService({required this.baseUrl});

  Future<List<University>> getUniversities({
    int skip = 0,
    int limit = 100,
    List<String>? states,
    String? sector,
    bool? offersBachelors,
    bool? offersMasters,
    bool? offersDoctorate,
    bool? isHbcu,
    bool? isTribal,
    String? religiousAffiliation,
    String? controlOfInstitution,
  }) async {
    try {
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (states != null && states.isNotEmpty) {
        queryParams['states'] = states.join(',');
      }
      if (sector != null) queryParams['sector'] = sector;
      if (offersBachelors != null) queryParams['offers_bachelors'] = offersBachelors.toString();
      if (offersMasters != null) queryParams['offers_masters'] = offersMasters.toString();
      if (offersDoctorate != null) queryParams['offers_doctorate'] = offersDoctorate.toString();
      if (isHbcu != null) queryParams['is_hbcu'] = isHbcu.toString();
      if (isTribal != null) queryParams['is_tribal'] = isTribal.toString();
      if (religiousAffiliation != null) queryParams['religious_affiliation'] = religiousAffiliation;
      if (controlOfInstitution != null) queryParams['control_of_institution'] = controlOfInstitution;
      
      final uri = Uri.parse('$baseUrl/universities/').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      developer.log('API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        developer.log('Parsed data length: ${data.length}');
        
        // Fetch degree information for each university
        List<University> universities = [];
        for (var uniData in data) {
          try {
            // Get detailed university info including degrees
            final detailResponse = await http.get(
              Uri.parse('$baseUrl/universities/${uniData['id']}')
            );
            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              universities.add(University.fromJson({
                ...detailData['university'],
                'degrees': detailData['degrees']
              }));
            }
          } catch (e) {
            developer.log('Error fetching university details: $e');
            continue;
          }
        }
        
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

  Future<Map<String, dynamic>> getUniversityImage(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/universities/$id/image'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load university image');
      }
    } catch (e) {
      developer.log('Error in getUniversityImage: $e');
      rethrow;
    }
  }

  Future<List<UniversityImage>> getUniversityImages(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/universities/$id/images'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['images'] as List)
            .map((img) => UniversityImage.fromJson(img))
            .toList();
      } else {
        throw Exception('Failed to load university images');
      }
    } catch (e) {
      developer.log('Error in getUniversityImages: $e');
      rethrow;
    }
  }

  Future<List<String>> getAllStates() async {
    try {
      final uri = Uri.parse('$baseUrl/universities/states');
      developer.log('Fetching states from: $uri');
      final response = await http.get(uri);
      developer.log('States response status: ${response.statusCode}');
      developer.log('States response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter out any null values and convert to strings
        return data.where((state) => state != null).map((state) => state.toString()).toList()..sort();
      } else {
        developer.log('Failed to load states: ${response.statusCode}');
        throw Exception('Failed to load states: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getAllStates: $e');
      rethrow;
    }
  }

  Future<University> getUniversity(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/universities/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return University.fromJson({
          ...data['university'],
          'degrees': data['degrees']
        });
      } else {
        throw Exception('Failed to load university: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getUniversity: $e');
      rethrow;
    }
  }
} 