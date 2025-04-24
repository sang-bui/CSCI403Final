import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/university_service.dart';
import '../models/university.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'university_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<University> _universities = [];
  List<University> _allUniversities = []; // Store all universities
  Set<String> _allStates = {}; // Store all available states
  Map<int, String> _universityImages = {}; // Cache for university images
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;
  final List<University> _likedUniversities = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _dragDistance = 0.0;
  bool _isDragging = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  
  // Filter state
  List<String> _selectedStates = [];
  String? _selectedSector;
  bool _offersBachelors = false;
  bool _offersMasters = false;
  bool _offersDoctorate = false;

  @override
  void initState() {
    super.initState();
    _loadInitialUniversities();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialUniversities() async {
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
          _allUniversities = universities;
          _universities = universities;
          _allStates = universities.map((u) => u.state).toSet();
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

  Future<void> _loadUniversities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = Provider.of<UniversityService>(context, listen: false);
      final universities = await service.getUniversities(
        states: _selectedStates.isNotEmpty ? _selectedStates : null,
        sector: _selectedSector,
        offersBachelors: _offersBachelors ? true : null,
        offersMasters: _offersMasters ? true : null,
        offersDoctorate: _offersDoctorate ? true : null,
      );
      developer.log('Loaded universities: ${universities.length}');
      
      if (mounted) {
        setState(() {
          _universities = universities;
          _currentIndex = 0;
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

  Future<void> _loadUniversityImage(int universityId) async {
    if (_universityImages.containsKey(universityId)) return;
    
    try {
      final service = Provider.of<UniversityService>(context, listen: false);
      final imageData = await service.getUniversityImage(universityId);
      
      if (mounted) {
        setState(() {
          _universityImages[universityId] = imageData['image_url'];
        });
      }
    } catch (e) {
      developer.log('Error loading university image: $e');
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
      _isLiked = _dragDistance > 0;
      _isDisliked = _dragDistance < 0;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      if (_dragDistance.abs() > 100) {
        if (_dragDistance > 0) {
          _onLike();
        } else {
          _onDislike();
        }
      } else {
        _dragDistance = 0;
        _isLiked = false;
        _isDisliked = false;
      }
    });
  }

  void _onLike() {
    if (_currentIndex < _universities.length) {
      setState(() {
        _likedUniversities.add(_universities[_currentIndex]);
        _currentIndex++;
        _dragDistance = 0;
        _isLiked = false;
        _isDisliked = false;
      });
    }
  }

  void _onDislike() {
    if (_currentIndex < _universities.length) {
      setState(() {
        _currentIndex++;
        _dragDistance = 0;
        _isLiked = false;
        _isDisliked = false;
      });
    }
  }

  Future<void> _showFilterDialog() async {
    // Create a copy of the current selected states to work with in the dialog
    List<String> tempSelectedStates = List.from(_selectedStates);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Universities'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // State filter
                  const Text('States', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getUniqueStates().map((state) {
                          final isSelected = tempSelectedStates.contains(state);
                          return FilterChip(
                            label: Text(state),
                            selected: isSelected,
                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  tempSelectedStates.add(state);
                                } else {
                                  tempSelectedStates.remove(state);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sector filter
                  DropdownButtonFormField<String>(
                    value: _selectedSector,
                    decoration: const InputDecoration(labelText: 'Sector'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Sectors')),
                      ..._getUniqueSectors().map((sector) => DropdownMenuItem(
                        value: sector,
                        child: Text(sector),
                      )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedSector = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Degree filters
                  const Text('Degree Programs', style: TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: const Text('Bachelor\'s Programs'),
                    value: _offersBachelors,
                    onChanged: (value) {
                      setDialogState(() {
                        _offersBachelors = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Master\'s Programs'),
                    value: _offersMasters,
                    onChanged: (value) {
                      setDialogState(() {
                        _offersMasters = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Doctorate Programs'),
                    value: _offersDoctorate,
                    onChanged: (value) {
                      setDialogState(() {
                        _offersDoctorate = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStates = tempSelectedStates;
                  });
                  Navigator.pop(context);
                  _loadUniversities();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        }
      ),
    );
  }

  List<String> _getUniqueStates() {
    final states = _allStates.toList();
    states.sort();
    return states;
  }

  List<String> _getUniqueSectors() {
    final sectors = _universities.map((u) => u.sector).toSet().toList();
    sectors.sort();
    return sectors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Swiper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _universities.isEmpty || _currentIndex >= _universities.length
                  ? const Center(child: Text('No more universities to show'))
                  : SizedBox.expand(
                      child: Stack(
                        children: [
                          // University Card
                          Center(
                            child: AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              left: _dragDistance,
                              child: GestureDetector(
                                onHorizontalDragStart: _onDragStart,
                                onHorizontalDragUpdate: _onDragUpdate,
                                onHorizontalDragEnd: _onDragEnd,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.75,
                                  child: _buildUniversityCard(_universities[_currentIndex]),
                                ),
                              ),
                            ),
                          ),
                          // Like Overlay
                          if (_isDragging && _isLiked)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: -0.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green, width: 4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'LIKE',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Dislike Overlay
                          if (_isDragging && _isDisliked)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: 0.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red, width: 4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'NOPE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Action Buttons
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  Icons.close,
                                  Colors.red,
                                  _onDislike,
                                ),
                                _buildActionButton(
                                  Icons.favorite,
                                  Colors.green,
                                  _onLike,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildUniversityCard(University university) {
    // Load image when card is built
    _loadUniversityImage(university.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UniversityDetailScreen(university: university),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Container(
                  color: Colors.grey[200],
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // University image or fallback
                      if (_universityImages.containsKey(university.id) && 
                          _universityImages[university.id]!.isNotEmpty)
                        Image.network(
                          _universityImages[university.id]!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage(university);
                          },
                        )
                      else
                        _buildFallbackImage(university),
                      // Location badge
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                university.state,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${university.state} - ${university.sector}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(university.zip),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage(University university) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.blue.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              university.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 32,
      ),
    );
  }
} 