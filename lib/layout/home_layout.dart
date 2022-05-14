import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_sqflite/shared/component/component.dart';
import 'package:todo_app_sqflite/shared/cubit/cubit.dart';
import 'package:todo_app_sqflite/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubitToDo()..createDataBase(),
      child: BlocConsumer<AppCubitToDo, AppStates>(
         listener: (context,state){
           if(state is AppInsertDatabaseState){
             Navigator.pop(context);
           }
         },
        builder: (context, state){
          AppCubitToDo cubit = AppCubitToDo.get(context);
          return Scaffold(
             key: scaffoldKey,
             appBar: AppBar(
               title: Text(
                 cubit.titles[cubit.currentIndex],
               ),
             ),
             body: Conditional.single(
               context: context,
               conditionBuilder: (context) => state is! AppGetDatabaseLoadingState,
               widgetBuilder: (context) => cubit.screens[cubit.currentIndex],
               fallbackBuilder: (context) => Center(child: CircularProgressIndicator(),),
             ),
             bottomNavigationBar: BottomNavigationBar(
               elevation: 20.0,
               currentIndex: cubit.currentIndex,
               onTap: (index) {
                 cubit.changeIndex(index);
               },
               items: [
                 BottomNavigationBarItem(
                   label: 'New Task',
                   icon: Icon(Icons.menu),
                 ),
                 BottomNavigationBarItem(
                   label: 'Done Task',
                   icon: Icon(Icons.check_circle_outline),
                 ),
                 BottomNavigationBarItem(
                   label: 'Archive Task',
                   icon: Icon(Icons.archive_outlined),
                 ),
               ],
             ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShow)
                {
                  if (formKey.currentState!.validate())
                  {
                    cubit.insertIntoDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else
                {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(
                        20.0,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultTextFormFiled(
                              controller: titleController,
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Title',
                              prefixIcon: Icons.title,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            defaultTextFormFiled(
                              controller: timeController,
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text =value!.format(context).toString();
                                  print(value.format(context));
                                });
                              },
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'time must not be empty';
                                }

                                return null;
                              },
                              label: 'Task Time',
                              prefixIcon: Icons.watch_later_outlined,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            defaultTextFormFiled(
                              controller: dateController,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2030-05-03'),
                                ).then((value) {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value!);
                                });
                              },
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'date must not be empty';
                                    }

                                  },
                              label: 'Task Date',
                              prefixIcon: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 20.0,
                  )
                      .closed
                      .then((value)
                  {
                    cubit.changeBottomSheetState(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });

                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
           );
        },
      ),
    );
  }




}


