import 'package:sqflite/sqflite.dart';
import 'package:whoosh/core/dbmodel/BluetoothDbModel.dart';

class DbLite{
  String dataBase = "woosh.db";
  String path = "";
  late Database database;
  String bluetoothDeviceTable = 'bluetoothDevice';
  DbLite(){
    initDatabase();
  }
  initDatabase() async{
    var databasesPath = await getDatabasesPath();
    path = databasesPath+"/"+dataBase;
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE IF NOT EXISTS $bluetoothDeviceTable (id INTEGER AUTO_INCREMENT PRIMARY KEY,device_id VARCHAR(255) NOT NULL,name TEXT, type TEXT)');
    });
  }

  openDb() async{
      
  }

  getDatabase() async{
    database = await openDatabase(path, version: 1);
    return database;
  }

  deleteDb() async{
    await deleteDatabase(path);
  }
  
  insertBluetoothDb(BluetoothDbModel bluetoothDbModel) async{
    int? count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM $bluetoothDeviceTable where name="${bluetoothDbModel.name}"'));
    
    if(count!=null &&  count > 0){
        return false;
    }
    else{
      await database.transaction((txn) async {
      int insterted = await txn.rawInsert(
          'INSERT INTO $bluetoothDeviceTable(device_id, name, type) VALUES("${bluetoothDbModel.deviceId}", "${bluetoothDbModel.name}", "${bluetoothDbModel.type}")');
      print(insterted);
      });
      
      return true;
    }
  }

  getAllBlueToothDevices() async{
    //print(database);
    List<Map<String, Object?>> records = await database.query(bluetoothDeviceTable);
    return records;
  }
}