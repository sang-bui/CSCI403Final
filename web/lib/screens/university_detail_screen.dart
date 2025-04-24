import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/university_service.dart';
import '../models/university.dart';

class UniversityDetailScreen extends StatelessWidget {
  final University university;

  const UniversityDetailScreen({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(university.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(university.imageUrl ?? ''),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  university.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Information
                  _buildInfoSection(
                    'Location',
                    [
                      _buildInfoRow('State', university.state),
                      _buildInfoRow('ZIP Code', university.zip),
                      _buildInfoRow('Sector', university.sector),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Coordinates
                  _buildInfoSection(
                    'Coordinates',
                    [
                      _buildInfoRow('Latitude', university.latitude.toString()),
                      _buildInfoRow('Longitude', university.longitude.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Degree Offerings
                  if (university.degrees != null) ...[
                    _buildInfoSection(
                      'Degree Programs',
                      [
                        _buildInfoRow('Highest Degree', university.degrees!.highestDegree),
                        const SizedBox(height: 16),
                        _buildInfoRow('Bachelor\'s Programs', university.degrees!.offersBachelors ? 'Yes' : 'No'),
                        _buildInfoRow('Master\'s Programs', university.degrees!.offersMasters ? 'Yes' : 'No'),
                        _buildInfoRow('Doctorate Programs', university.degrees!.offersDoctorate ? 'Yes' : 'No'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      'Certificate Programs',
                      [
                        _buildInfoRow('1-Year Certificate', university.degrees!.offersYearCertificate ? 'Available' : 'Not offered'),
                        _buildInfoRow('Post-Bachelor\'s Certificate', university.degrees!.offersPostBachelorsCertificate ? 'Available' : 'Not offered'),
                        _buildInfoRow('Post-Master\'s Certificate', university.degrees!.offersPostMastersCertificate ? 'Available' : 'Not offered'),
                        _buildInfoRow('Post-Doctorate Certificate', university.degrees!.offersPostDoctorateCertificate ? 'Available' : 'Not offered'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 