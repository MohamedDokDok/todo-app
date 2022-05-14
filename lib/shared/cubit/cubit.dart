import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_sqflite/modules/archive_tasks/archive_tasks_screen.dart';
import 'package:todo_app_sqflite/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app_sqflite/modules/new_task/new_task_screen.dart';
import 'package:todo_app_sqflite/shared/cubit/states.dart';

class AppCubitToDo extends Cubit<AppStates> {

  AppCubitToDo() : super(AppInitialState());

  static AppCubitToDo get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchiveTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archive Tasks',
  ];

  void changeIndex(index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarStat());
  }

  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('Data Base Created successfully');
        database
            .execute(
          'CREATE TABLE task (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)',
        )
            .then((value) {
          print('Table is created');
        }).catchError((onError) {
          print('Error when creating table $onError');
        });
      },
      onOpen: (database) {
        print('Data Base Oped successfully');
        getDataFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

   insertIntoDatabase({
    required String? title,
    required String? date,
    required String? time,
  }) async {
     await database!.transaction((txn) {
     return txn.rawInsert(
       'INSERT INTO task(title, date , time ,status) VALUES("$title","$date","$time", "New")'
     );
    }).then((value) {
        print('$value insert  successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((onError) {
        print('Error when inserting $onError');
      });
  }


  void updateDatabase({
    required String? status,
    required int? id,
  }){
    database!.rawUpdate(
      'UPDATE task SET status =? WHERE id =?',
      ['$status', id],
    );
    getDataFromDatabase(database);
    emit(AppUpdateDatabaseState());
  }

  void deleteDatabase({
    required int? id
  }){
    database!.rawUpdate(
      'DELETE FROM task WHERE id =?',
      [id],
    );
    getDataFromDatabase(database);
    emit(AppDeleteDatabaseState());
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM task').then((value) {
      value.forEach((element) {
        if (element['status'] == 'New')
          newTasks.add(element);
        else if(element['status'] == 'Done')
          doneTasks.add(element);
        else
          archiveTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }

  bool isBottomSheetShow = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool? isShow,
    required IconData? icon,
  }) {
    isBottomSheetShow = isShow!;
    fabIcon = icon!;
    emit(AppChangeBottomSheetState());
  }
}
