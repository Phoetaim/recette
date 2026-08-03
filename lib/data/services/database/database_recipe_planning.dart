import 'package:sqflite/sqflite.dart';

import '../../../domain/models/recipe/recipe_planning.dart';
import 'database.dart';

class DatabaseRecipePlanningService {
  DatabaseRecipePlanningService({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<RecipePlanning> addRecipePlanning(RecipePlanning planning) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object?> data = Map<String, Object?>.from(planning.toJson());
    data.remove('id');
    final id = await database.insert(TableNames.recipePlanning, data);
    return planning.copyWith(id: id);
  }

  Future<void> updateRecipePlanning(RecipePlanning planning) async {
    Database database = await _databaseService.getDatabase();
    Map<String, Object?> data = Map<String, Object?>.from(planning.toJson());
    data.remove('id');
    await database.update(
      TableNames.recipePlanning,
      data,
      where: 'id = ?',
      whereArgs: [planning.id!],
    );
  }

  Future<List<RecipePlanning>> getRecipePlanning() async {
    Database database = await _databaseService.getDatabase();
    final entries = await database.query(TableNames.recipePlanning);
    return entries.map((element) => RecipePlanning.fromJson(element)).toList();
  }

  Future<void> deleteRecipePlanning(int id) async {
    Database database = await _databaseService.getDatabase();
    await database.delete(TableNames.recipePlanning,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseService.close();
  }
}
