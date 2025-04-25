class UniversityImage {
  final String url;
  final String altText;
  final String description;
  final String photographer;
  final String photographerUrl;

  UniversityImage({
    required this.url,
    required this.altText,
    required this.description,
    required this.photographer,
    required this.photographerUrl,
  });

  factory UniversityImage.fromJson(Map<String, dynamic> json) {
    return UniversityImage(
      url: json['url'],
      altText: json['alt_text'],
      description: json['description'],
      photographer: json['photographer'],
      photographerUrl: json['photographer_url'],
    );
  }
}

class University {
  final int id;
  final String name;
  final String state;
  final String sector;
  final String zip;
  final double latitude;
  final double longitude;
  final DegreeOfferings? degrees;
  final String? imageUrl;
  final String? imageAltText;
  final bool isHbcu;
  final bool isTribal;
  final String? religiousAffiliation;
  final String carnegieClassification;
  final String controlOfInstitution;
  final double? applicantsTotal;
  final double? admissionsTotal;
  final double? enrolledTotal;
  final double? pctSubmitSat;
  final double? pctSubmitAct;
  final double? satReading25;
  final double? satReading75;
  final double? satMath25;
  final double? satMath75;
  final double? satWriting25;
  final double? satWriting75;
  final double? actComposite25;
  final double? actComposite75;
  final String? description;
  final String? website;
  final String? phoneNumber;

  University({
    required this.id,
    required this.name,
    required this.state,
    required this.sector,
    required this.zip,
    required this.latitude,
    required this.longitude,
    this.degrees,
    this.imageUrl,
    this.imageAltText,
    required this.isHbcu,
    required this.isTribal,
    this.religiousAffiliation,
    required this.carnegieClassification,
    required this.controlOfInstitution,
    this.applicantsTotal,
    this.admissionsTotal,
    this.enrolledTotal,
    this.pctSubmitSat,
    this.pctSubmitAct,
    this.satReading25,
    this.satReading75,
    this.satMath25,
    this.satMath75,
    this.satWriting25,
    this.satWriting75,
    this.actComposite25,
    this.actComposite75,
    this.description,
    this.website,
    this.phoneNumber,
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
      imageUrl: json['image_url'],
      imageAltText: json['alt_text'],
      isHbcu: json['is_hbcu'] ?? false,
      isTribal: json['is_tribal'] ?? false,
      religiousAffiliation: json['religious_affiliation'] == 'Not applicable' ? null : json['religious_affiliation'],
      carnegieClassification: json['carnegie_classification'] ?? '',
      controlOfInstitution: json['control_of_institution'] ?? '',
      applicantsTotal: json['applicants_total']?.toDouble(),
      admissionsTotal: json['admissions_total']?.toDouble(),
      enrolledTotal: json['enrolled_total']?.toDouble(),
      pctSubmitSat: json['pct_submit_sat']?.toDouble(),
      pctSubmitAct: json['pct_submit_act']?.toDouble(),
      satReading25: json['sat_reading_25']?.toDouble(),
      satReading75: json['sat_reading_75']?.toDouble(),
      satMath25: json['sat_math_25']?.toDouble(),
      satMath75: json['sat_math_75']?.toDouble(),
      satWriting25: json['sat_writing_25']?.toDouble(),
      satWriting75: json['sat_writing_75']?.toDouble(),
      actComposite25: json['act_composite_25']?.toDouble(),
      actComposite75: json['act_composite_75']?.toDouble(),
      description: json['description'],
      website: json['website'],
      phoneNumber: json['phone_number'],
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