import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/university_service.dart';
import '../models/university.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<University> _universities = [];
  bool _isLoading = false;
  String? _error;
  String _selectedState = '';
  bool _filterBachelors = false;
  bool _filterMasters = false;
  bool _filterDoctorate = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = Provider.of<UniversityService>(context, listen: false);
      final universities = await service.getUniversities();
      developer.log('Loaded universities: ${universities.length}');
      
      if (mounted) {
        setState(() {
          _universities = universities;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading universities: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUniversities(query);
    });
  }

  Future<void> _searchUniversities(String query) async {
    if (query.isEmpty) {
      _loadUniversities();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = Provider.of<UniversityService>(context, listen: false);
      developer.log('Searching for: $query');
      final universities = await service.searchUniversities(query);
      developer.log('Search results: ${universities.length}');
      
      if (mounted) {
        setState(() {
          _universities = universities;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error searching universities: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search universities...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _universities.isEmpty
                    ? const Center(
                        child: Text('No universities found'),
                      )
                    : ListView.builder(
                        itemCount: _universities.length,
                        itemBuilder: (context, index) {
                          final university = _universities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: ListTile(
                              title: Text(university.name),
                              subtitle: Text('${university.state} - ${university.sector}'),
                              onTap: () => _showUniversityDetails(university),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUniversities,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Universities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Offers Bachelor\'s'),
              value: _filterBachelors,
              onChanged: (value) {
                setState(() => _filterBachelors = value ?? false);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Offers Master\'s'),
              value: _filterMasters,
              onChanged: (value) {
                setState(() => _filterMasters = value ?? false);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Offers Doctorate'),
              value: _filterDoctorate,
              onChanged: (value) {
                setState(() => _filterDoctorate = value ?? false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUniversityDetails(University university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(university.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('State: ${university.state}'),
              Text('Sector: ${university.sector}'),
              Text('ZIP: ${university.zip}'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(university.latitude, university.longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(university.id.toString()),
                      position: LatLng(university.latitude, university.longitude),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 