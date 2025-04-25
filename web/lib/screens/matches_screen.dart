import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/swipe_service.dart';
import '../services/university_service.dart';
import '../models/university.dart';
import 'university_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  String? _error;
  Map<int, University> _universityCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final swipeService = Provider.of<SwipeService>(context, listen: false);
      final universityService = Provider.of<UniversityService>(context, listen: false);
      
      final matches = await swipeService.getMatches();

      // Fetch university details for matches
      for (var match in matches) {
        if (!_universityCache.containsKey(match['university_id'])) {
          final university = await universityService.getUniversity(match['university_id']);
          _universityCache[match['university_id']] = university;
        }
      }

      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMatch(int matchId) async {
    try {
      final service = Provider.of<SwipeService>(context, listen: false);
      await service.deleteMatch(matchId);
      await _loadData(); // Reload data to reflect changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete match: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _matches.isEmpty
                  ? const Center(child: Text('No matches yet'))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        final university = _universityCache[match['university_id']];
                        if (university == null) return const SizedBox.shrink();
                        
                        return Dismissible(
                          key: Key('match-${match['id']}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Match'),
                                content: const Text('Are you sure you want to delete this match?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) => _deleteMatch(match['id']),
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(university.name),
                              subtitle: Text('Matched on: ${match['match_timestamp']}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UniversityDetailScreen(university: university),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 