import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/university_service.dart';
import '../models/university.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityDetailScreen extends StatelessWidget {
  final University university;

  const UniversityDetailScreen({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(university.name),
        actions: [
          if (university.website != null)
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () async {
                final url = university.website!;
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            ),
          if (university.phoneNumber != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () async {
                final tel = 'tel:${university.phoneNumber}';
                if (await canLaunch(tel)) {
                  await launch(tel);
                }
              },
            ),
        ],
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
            if (university.description != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  university.description!,
                  style: const TextStyle(fontSize: 16),
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
                  // Admissions Statistics
                  if (university.applicantsTotal != null || 
                      university.admissionsTotal != null || 
                      university.enrolledTotal != null)
                    _buildInfoSection(
                      'Admissions Statistics',
                      [
                        if (university.applicantsTotal != null)
                          _buildInfoRow('Total Applicants', university.applicantsTotal!.toStringAsFixed(0)),
                        if (university.admissionsTotal != null)
                          _buildInfoRow('Total Admitted', university.admissionsTotal!.toStringAsFixed(0)),
                        if (university.enrolledTotal != null)
                          _buildInfoRow('Total Enrolled', university.enrolledTotal!.toStringAsFixed(0)),
                        if (university.admissionsTotal != null && university.applicantsTotal != null)
                          _buildInfoRow(
                            'Acceptance Rate',
                            '${((university.admissionsTotal! / university.applicantsTotal!) * 100).toStringAsFixed(1)}%'
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Test Scores
                  if (university.pctSubmitSat != null || university.pctSubmitAct != null)
                    _buildInfoSection(
                      'Test Scores',
                      [
                        if (university.pctSubmitSat != null)
                          _buildInfoRow('Submit SAT', '${(university.pctSubmitSat! * 1).toStringAsFixed(1)}%'),
                        if (university.satMath25 != null && university.satMath75 != null)
                          _buildInfoRow('SAT Math', '${university.satMath25!.toStringAsFixed(0)} - ${university.satMath75!.toStringAsFixed(0)}'),
                        if (university.satReading25 != null && university.satReading75 != null)
                          _buildInfoRow('SAT Reading', '${university.satReading25!.toStringAsFixed(0)} - ${university.satReading75!.toStringAsFixed(0)}'),
                        if (university.satWriting25 != null && university.satWriting75 != null)
                          _buildInfoRow('SAT Writing', '${university.satWriting25!.toStringAsFixed(0)} - ${university.satWriting75!.toStringAsFixed(0)}'),
                        if (university.pctSubmitAct != null)
                          _buildInfoRow('Submit ACT', '${(university.pctSubmitAct! * 1).toStringAsFixed(1)}%'),
                        if (university.actComposite25 != null && university.actComposite75 != null)
                          _buildInfoRow('ACT Composite', '${university.actComposite25!.toStringAsFixed(0)} - ${university.actComposite75!.toStringAsFixed(0)}'),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Institution Identity
                  _buildInfoSection(
                    'Institution Identity',
                    [
                      _buildInfoRow('Carnegie Classification', university.carnegieClassification),
                      _buildInfoRow('Control', university.controlOfInstitution),
                      if (university.isHbcu)
                        _buildInfoRow('HBCU', 'Yes'),
                      if (university.isTribal)
                        _buildInfoRow('Tribal College', 'Yes'),
                      if (university.religiousAffiliation != null)
                        _buildInfoRow('Religious Affiliation', university.religiousAffiliation!),
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