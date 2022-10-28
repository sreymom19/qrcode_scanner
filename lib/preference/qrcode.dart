class QrCode {
  final String? name;
  QrCode({required this.name});
  factory QrCode.fromMap(Map<String, dynamic> map) {
    return QrCode(name: map["name"]);
  }
}