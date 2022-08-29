import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:DeadLine_newTask/TaskRoute.dart';
import 'package:DeadLine_newTask/model/Task.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/ProjectModel.dart';

class TaskItem extends StatefulWidget {
  Task task;
  bool showProjectName;

  TaskItem(this.task, this.showProjectName, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late final firestore =
      Provider.of<ProjectModel>(context, listen: false).firestore;
  late final auth = Provider.of<ProjectModel>(context, listen: false).auth;
  late Task task = widget.task;
  late bool showProjectName = widget.showProjectName;

  @override
  Widget build(BuildContext context) {
    var tagInName =
        task.name.split(' ').where((element) => element.startsWith('#'));
    var taskName = task.name;
    for (var tag in tagInName) {
      // e.g. tag: #maybe? -> pattern: " *#maybe\? *"
      taskName = taskName.replaceAll(RegExp(" *${RegExp.escape(tag)} "), '');
      debugPrint("tagInName tag=$tag");
    }
    debugPrint("taskName=$taskName");

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Details',
          color: Colors.black45,
          icon: Icons.more_horiz,
          onTap: () => print('Details'),
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            print('Delete clicked');
            task.remove(auth.currentUser, firestore);
          },
        ),
      ],
      child: Card(
        child: InkWell(
          child: ListTile(
            dense: true,
            leading: Checkbox(
              value: task.isDone,
              onChanged: (bool? value) {
                setState(
                  () {
                    task.isDone = value!;
                    task.push(auth.currentUser, firestore);
                  },
                );
              },
            ),
            title: Text(taskName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      task.isImportant = !task.isImportant;
                      task.push(auth.currentUser, firestore);
                    });
                  },
                  icon: Icon(task.isImportant ? Icons.star : Icons.star_border),
                )
              ],
            ),
            subtitle: ["", null].contains(task.jottedDown) && tagInName.isEmpty && !showProjectName && task.targetOn == null
                ? null
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(task.jottedDown ?? ""),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (task.targetOn != null) Text(
                            "\n ${DateFormat('yyyy-MM-dd').format(task.targetOn!)}"
                          )
                        ],
                      ),
                      Row(
                        children: [
                          if (showProjectName && task.projectName != null) Text(task.projectName!), 
                          ...tagInName
                              .map((tagName) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 4),
                                      child: ActionChip(
                                        label: Text(
                                          "${tagName}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        onPressed: () {
                                          debugPrint('clicked tag ${tagName}');
                                        },
                                      ),
                                    ),
                                  ))
                              .toList()
                        ],
                      ),
                    ],
                  ),
            onTap: () {
              Navigator.pushNamed(context, TaskRoute.routeName,
                  arguments: task);
            },
          ),
        ),
      ),
    );
  }
}
