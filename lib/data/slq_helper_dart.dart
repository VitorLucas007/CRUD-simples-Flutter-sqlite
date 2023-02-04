import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
""");
  }

// id: o id de um item
// title, description: nome e descrição da sua atividade
// created_at: a hora em que o item foi criado. Ele será tratado automaticamente pelo SQLite

static Future<sql.Database> db() async {
  return sql.openDatabase (
    'lista.db',
    version: 1,
    onCreate: (sql.Database database, int version) async {
      await createTables(database);
    }
  );
}


//Criando novo item 

static Future<int> createItem(String title, String? description) async {
  final db = await SQLHelper.db();
  final data = {'title': title, 'description': description};
  final id = await db.insert('items', data,
    conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
}

// Ler todas as listas

static Future<List<Map<String, dynamic>>> getItems() async {
  final db = await SQLHelper.db();
  return db.query('items', orderBy: 'id');
}

// Lê um único item por id
// O app não usa esse método mas coloquei aqui caso queira ver

static Future<List<Map<String, dynamic>>> getItem(int id) async {
  final db = await SQLHelper.db();
  return db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
}

// Atualizando um item pelo id

static Future<int> updateItem(
  int id, String title, String ? description) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createAt': DateTime.now().toString()
    };

    final result = 
      await db.update('items', data, where: 'id = ?', whereArgs: [id]);
      return result;
  }

  // Delete

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Algo deu errado para concluir a exclusão $err");
    }
  }
}