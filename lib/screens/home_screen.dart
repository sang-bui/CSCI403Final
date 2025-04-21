import 'package:flutter/material.dart';
import '../models/university.dart';
import '../services/university_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UniversityService _universityService = UniversityService();
  List<University> _universities = [];
  List<String> _countries = [];
  bool _isLoading = false;
  String? _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minScoreController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final countries = await _universityService.getCountries();
      setState(() => _countries = countries);
      await _fetchUniversities();
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUniversities() async {
    setState(() => _isLoading = true);
    try {
      final universities = await _universityService.getUniversities(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        country: _selectedCountry,
        minScore: _minScoreController.text.isEmpty
            ? null
            : double.tryParse(_minScoreController.text),
        maxStudents: _maxStudentsController.text.isEmpty
            ? null
            : int.tryParse(_maxStudentsController.text),
      );
      setState(() => _universities = universities);
    } catch (e) {
      _showError('Failed to fetch universities: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Rankings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Universities',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _fetchUniversities(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Countries'),
                          ),
                          ..._countries.map((country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCountry = value);
                          _fetchUniversities();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minScoreController,
                        decoration: const InputDecoration(
                          labelText: 'Min Score',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _fetchUniversities(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxStudentsController,
                        decoration: const InputDecoration(
                          labelText: 'Max Students',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _fetchUniversities(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _universities.length,
                    itemBuilder: (context, index) {
                      final university = _universities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(university.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (university.country != null)
                                Text('Country: ${university.country}'),
                              if (university.totalScore != null)
                                Text('Score: ${university.totalScore!.toStringAsFixed(1)}'),
                              if (university.numStudents != null)
                                Text('Students: ${university.numStudents}'),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to university details
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minScoreController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }
} 