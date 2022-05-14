import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_sqflite/shared/component/component.dart';
import 'package:todo_app_sqflite/shared/cubit/cubit.dart';
import 'package:todo_app_sqflite/shared/cubit/states.dart';

class DoneTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<AppCubitToDo,AppStates>(
      listener: (context, state){},
      builder: (context, state){
        var tasks =AppCubitToDo.get(context).doneTasks;
        return  tasksBuilder(tasks: tasks, context: context);
      },
    );
  }
}