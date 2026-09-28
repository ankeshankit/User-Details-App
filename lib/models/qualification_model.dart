



class QualificationModel {
  String qualification;
  String passingYear;
  String marks;

  QualificationModel({
    this.qualification = '',
    this.passingYear = '',
    this.marks = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'qualification': qualification,
      'passingYear': passingYear,
      'marks': marks,
    };
  }

  factory QualificationModel.fromJson(Map<String, dynamic> json) {
    return QualificationModel(
      qualification: json['qualification']?.toString() ?? '',
      passingYear: json['passingYear']?.toString() ?? '',
      marks: json['marks']?.toString() ?? '',
    );
  }
}