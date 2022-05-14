import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:todo_app_sqflite/shared/cubit/cubit.dart';

Widget defaultTextFormFiled({
  required TextEditingController? controller,
  TextInputType? boardType,
  bool isObscure = false,
  required String? label,
  required IconData? prefixIcon,
  IconData? suffixIcon,
  Function? onSubmit,
  FormFieldValidator<String>? validate,
  Function? suffixPress,
  GestureTapCallback? onTap,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: boardType,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: (){
                  suffixPress!();
                },
              )
            : null,
      ),
      onFieldSubmitted: (s){
        onSubmit!(s);
      },
      validator: validate,
      onTap: onTap,
    );

//--------------------------------------------------------------------

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubitToDo.get(context).deleteDatabase(
          id: model['id'],
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text(
                '${model['time']}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            IconButton(
                icon: Icon(Icons.check_box),
                color: Colors.green,
                onPressed: () {
                  AppCubitToDo.get(context).updateDatabase(
                    status: 'Done',
                    id: model['id'],
                  );
                }),
            IconButton(
                icon: Icon(Icons.archive_outlined),
                color: Colors.grey,
                onPressed: () {
                  AppCubitToDo.get(context).updateDatabase(
                    status: 'Archive',
                    id: model['id'],
                  );
                }),
          ],
        ),
      ),
    );

//------------------------------------------------------------------------

Widget tasksBuilder(
    {required List<Map>? tasks,
      required BuildContext? context,
    }) {
  return Conditional.single(
    context: context!,
    conditionBuilder: (context) => tasks!.length > 0,
    widgetBuilder: (context) => ListView.separated(
      itemBuilder: (context, index) {
        return buildTaskItem(tasks![index], context);
      },
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 20.0,
        ),
        child: Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300],
        ),
      ),
      itemCount: tasks!.length,
    ),
    fallbackBuilder: (context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 100.0,
            color: Colors.grey,
          ),
          Text(
            'No Tasks Yet, Please Add Some Tasks',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
