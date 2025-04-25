import 'package:flutter/material.dart';
import '../services/swipe_service.dart';

class SwipeScreen extends StatefulWidget {
  final SwipeService swipeService;

  const SwipeScreen({Key? key, required this.swipeService}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late final SwipeService _swipeService;
  List<dynamic> _swipeHistory = [];
  List<dynamic> _matches = [];
  dynamic _currentUniversity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _swipeService = widget.swipeService;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSwipeHistory(),
      _loadMatches(),
      _loadNextUniversity(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSwipeHistory() async {
    try {
      final history = await _swipeService.getSwipeHistory();
      setState(() {
        _swipeHistory = history;
      });
    } catch (e) {
      print('Error loading swipe history: $e');
    }
  }

  Future<void> _loadMatches() async {
    try {
      final matches = await _swipeService.getMatches();
      setState(() {
        _matches = matches;
      });
    } catch (e) {
      print('Error loading matches: $e');
    }
  }

  Future<void> _loadNextUniversity() async {
    // TODO: Implement university loading logic
    setState(() {
      _currentUniversity = null; // Placeholder
    });
  }

  Future<void> _handleSwipe(String direction) async {
    if (_currentUniversity == null) return;

    try {
      await _swipeService.createSwipe(
        universityId: _currentUniversity!['id'],
        swipeDirection: direction,
      );
      _loadNextUniversity();
    } catch (e) {
      print('Error creating swipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Swipe'),
      ),
      body: _currentUniversity == null
          ? const Center(child: Text('No more universities to show'))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentUniversity!['name']),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleSwipe('left'),
                        child: const Text('Left'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => _handleSwipe('right'),
                        child: const Text('Right'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 