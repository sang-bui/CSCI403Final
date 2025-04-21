import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
          ),
        ),
      ),
      home: const CollegeSearchPage(),
    );
  }
}

class CollegeSearchPage extends StatefulWidget {
  const CollegeSearchPage({super.key});

  @override
  State<CollegeSearchPage> createState() => _CollegeSearchPageState();
}

class _CollegeSearchPageState extends State<CollegeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFilters = false;
  int _selectedIndex = 0;
  
  // Filter values
  RangeValues _satRange = const RangeValues(800, 1600);
  RangeValues _actRange = const RangeValues(1, 36);
  String _selectedLocation = 'Any';
  String _selectedType = 'Any';
  String _selectedSize = 'Any';
  double _maxTuition = 50000;

  final List<String> _locations = ['Any', 'Northeast', 'Southeast', 'Midwest', 'Southwest', 'West'];
  final List<String> _types = ['Any', 'Public', 'Private', 'Liberal Arts', 'Technical'];
  final List<String> _sizes = ['Any', 'Small (<5,000)', 'Medium (5,000-15,000)', 'Large (>15,000)'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'College Search',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your perfect college match',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search colleges...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      ),
                      label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: _buildFilterSection(),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Colleges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            // TODO: Navigate to college details
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'College ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Location ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildInfoChip('4 Year'),
                                    const SizedBox(width: 8),
                                    _buildInfoChip('Public'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle('SAT Score Range'),
        RangeSlider(
          values: _satRange,
          min: 800,
          max: 1600,
          divisions: 16,
          labels: RangeLabels(
            _satRange.start.round().toString(),
            _satRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _satRange = values;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildFilterTitle('ACT Score Range'),
        RangeSlider(
          values: _actRange,
          min: 1,
          max: 36,
          divisions: 35,
          labels: RangeLabels(
            _actRange.start.round().toString(),
            _actRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _actRange = values;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildFilterTitle('Location'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _locations.map((location) => FilterChip(
            label: Text(location),
            selected: location == _selectedLocation,
            onSelected: (bool selected) {
              setState(() {
                _selectedLocation = location;
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildFilterTitle('Type'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((type) => FilterChip(
            label: Text(type),
            selected: type == _selectedType,
            onSelected: (bool selected) {
              setState(() {
                _selectedType = type;
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildFilterTitle('Size'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sizes.map((size) => FilterChip(
            label: Text(size),
            selected: size == _selectedSize,
            onSelected: (bool selected) {
              setState(() {
                _selectedSize = size;
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildFilterTitle('Max Tuition (per year)'),
        Slider(
          value: _maxTuition,
          min: 0,
          max: 50000,
          divisions: 50,
          label: '\$${_maxTuition.round()}',
          onChanged: (value) {
            setState(() {
              _maxTuition = value;
            });
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Clear filters
                },
                child: const Text('Clear Filters'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _showFilters = false;
                  });
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
