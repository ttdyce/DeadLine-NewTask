import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DeadLine_newTask/model/LexoRank.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/Task.dart';

import '../model/ProjectModel.dart';

class TaskItemBottomSheet extends StatefulWidget {
  List<Task> existingTasks;
  Project? project;
  void Function(Task task)? addTaskSettings;

  TaskItemBottomSheet(this.existingTasks, this.project,
      {this.addTaskSettings});

  @override
  State<TaskItemBottomSheet> createState() => _TaskItemBottomSheetState();
}

class _TaskItemBottomSheetState extends State<TaskItemBottomSheet> {
  late final firestore =
      Provider.of<ProjectModel>(context, listen: false).firestore;
  late final auth = Provider.of<ProjectModel>(context, listen: false).auth;

  String nameInput = "";

  @override
  Widget build(BuildContext context) {
    var taskTextField = TextField(
      autofocus: true,
      onChanged: (value) {
        nameInput = value;
      },
      onSubmitted: (_value) {
        performAdd();
      },
      decoration: InputDecoration(
          border: UnderlineInputBorder(), hintText: 'Task name'),
    );

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 80,
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(child: taskTextField),
                IconButton(
                    onPressed: performAdd,
                    icon: Icon(Icons.arrow_forward_ios_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void performAdd() async {
    var task = Task.withProject(nameInput, widget.project);
    if (widget.existingTasks.length == 0) {
      task.order = LexoRank.MIN.rank;
    } else if (widget.existingTasks.length == 1) {
      task.order = LexoRank.MAX.rank;
    } else {
      task.order = LexoRank.MAX.rank;

      var previousLast = widget.existingTasks.last;
      var left = widget.existingTasks[widget.existingTasks.length - 2].order;
      previousLast.order = LexoRank.generate(LexoRank(left), LexoRank.MAX);
      ;
      previousLast.push(auth.currentUser, firestore);
    }

    if (widget.addTaskSettings != null) widget.addTaskSettings!(task);
    await task.add(auth.currentUser, firestore);

    Navigator.pop(context);
  }
}
