class University {
  final int id;
  final String name;
  final String state;
  final String sector;
  final String zip;
  final double latitude;
  final double longitude;
  final DegreeOfferings? degrees;

  University({
    required this.id,
    required this.name,
    required this.state,
    required this.sector,
    required this.zip,
    required this.latitude,
    required this.longitude,
    this.degrees,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'],
      name: json['name'],
      state: json['state'],
      sector: json['sector'],
      zip: json['zip'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      degrees: json['degrees'] != null ? DegreeOfferings.fromJson(json['degrees']) : null,
    );
  }
}

class DegreeOfferings {
  final bool offersBachelors;
  final bool offersMasters;
  final bool offersDoctorate;
  final bool offersYearCertificate;
  final bool offersPostBachelorsCertificate;
  final bool offersPostMastersCertificate;
  final bool offersPostDoctorateCertificate;
  final String highestDegree;

  DegreeOfferings({
    required this.offersBachelors,
    required this.offersMasters,
    required this.offersDoctorate,
    required this.offersYearCertificate,
    required this.offersPostBachelorsCertificate,
    required this.offersPostMastersCertificate,
    required this.offersPostDoctorateCertificate,
    required this.highestDegree,
  });

  factory DegreeOfferings.fromJson(Map<String, dynamic> json) {
    return DegreeOfferings(
      offersBachelors: json['offers_bachelors'] ?? false,
      offersMasters: json['offers_masters'] ?? false,
      offersDoctorate: json['offers_doctorate'] ?? false,
      offersYearCertificate: json['offers_year_certificate'] ?? false,
      offersPostBachelorsCertificate: json['offers_post_bachelors_certificate'] ?? false,
      offersPostMastersCertificate: json['offers_post_masters_certificate'] ?? false,
      offersPostDoctorateCertificate: json['offers_post_doctorate_certificate'] ?? false,
      highestDegree: json['highest_degree'] ?? '',
    );
  }
} 