import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'qr_database.db'),
    onCreate: ((db, version) {
      return db.execute(
          'CREATE TABLE visitors(id INTEGER PRIMARY KEY, name TEXT, position TEXT, company TEXT, type TEXT, email TEXT, phone TEXT )');
    }),
    version: 1,
  );

  Future<void> insertQR(ModelDB qr) async {
    final db = await database;
    await db.insert('visitors', qr.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ModelDB>> visitors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visitors');
    return List.generate(maps.length, (i) {
      return ModelDB(
        id: maps[i]['id'],
        //prefix: maps[i]['prefix'],
        name: maps[i]['name'],
        position: maps[i]['position'],
        company: maps[i]['company'],
        type: maps[i]['type'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
      );
    });
  }

  print(await visitors());
}

class ModelDB {
  final int? id;
  //final String prefix;
  final String name;
  final String position;
  final String company;
  final String type;
  final String email;
  final String phone;

  ModelDB({
    this.id,
    //required this.prefix,
    required this.name,
    required this.position,
    required this.company,
    required this.type,
    required this.email,
    required this.phone,
  });

  factory ModelDB.fromMap(Map<String, dynamic> map) {
    return ModelDB(
      id: map['id'],
     // prefix: map['prefix'],
      name: map['name'],
      position: map['position'],
      company: map['company'],
      type: map['type'],
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      //'prefix': prefix,
      'name': name,
      'position': position,
      'company': company,
      'type': type,
      'email': email,
      'phone': phone,
    };
  }

  @override
  String toString() {
    return 'ModelDB{id: $id, name : $name, position: $position,company $company, type : $type, email: $email, phone: $phone}';
  }
}
