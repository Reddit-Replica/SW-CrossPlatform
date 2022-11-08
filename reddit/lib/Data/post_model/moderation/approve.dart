/// A widget that displays a text field with a label.
/// date: 8/11/2022
/// @Author: Ahmed Atta

class Approve {
  String? approvedBy;
  String? approvedDate;

  Approve({this.approvedBy, this.approvedDate});

  factory Approve.fromJson(Map<String, dynamic> json) => Approve(
        approvedBy: json['approvedBy'] as String?,
        approvedDate: json['approvedDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'approvedBy': approvedBy,
        'approvedDate': approvedDate,
      };
}
