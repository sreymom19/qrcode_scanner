class Printer {
  final String? name;
  final String? address;
  final int? type;

  Printer({required this.name, required this.address, required this.type});

  factory Printer.fromMap(Map<String, dynamic> map) {
    return Printer(
      name: map["name"],
      address: map["address"],
      type: map["type"],
    );
  }

  toJson() {
    return {"name": name, "address": address, "type": type};
  }
}


