import 'dart:convert';
import 'package:http/http.dart' as http;

class SwipeService {
  final String baseUrl;

  SwipeService({required this.baseUrl});

  Future<void> createSwipe({
    required int universityId,
    required String swipeDirection,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/swipes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'university_id': universityId,
        'swipe_direction': swipeDirection,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create swipe: ${response.body}');
    }
  }

  Future<List<dynamic>> getMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<void> deleteMatch(int matchId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/matches/$matchId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete match');
    }
  }
} 