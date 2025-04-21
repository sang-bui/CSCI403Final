class University {
  final String name;
  final String? country;
  final double? teaching;
  final double? international;
  final double? research;
  final double? citations;
  final double? income;
  final double? totalScore;
  final int? numStudents;
  final double? studentStaffRatio;
  final double? internationalStudents;
  final double? femaleMaleRatio;

  University({
    required this.name,
    this.country,
    this.teaching,
    this.international,
    this.research,
    this.citations,
    this.income,
    this.totalScore,
    this.numStudents,
    this.studentStaffRatio,
    this.internationalStudents,
    this.femaleMaleRatio,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      country: json['country'],
      teaching: json['teaching']?.toDouble(),
      international: json['international']?.toDouble(),
      research: json['research']?.toDouble(),
      citations: json['citations']?.toDouble(),
      income: json['income']?.toDouble(),
      totalScore: json['total_score']?.toDouble(),
      numStudents: json['num_students'],
      studentStaffRatio: json['student_staff_ratio']?.toDouble(),
      internationalStudents: json['international_students']?.toDouble(),
      femaleMaleRatio: json['female_male_ratio']?.toDouble(),
    );
  }
} 