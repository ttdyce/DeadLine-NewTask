import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'model/Project.dart';
import 'model/ProjectModel.dart';
import 'model/Task.dart';

class TaskRoute extends StatefulWidget {
  static const routeName = '/task';
  Task task;

  TaskRoute(this.task, {Key? key}) : super(key: key);

  @override
  TaskState createState() => TaskState();
}

class TaskState extends State<TaskRoute> {
  late final firestore =
      Provider.of<ProjectModel>(context, listen: false).firestore;
  late final auth =
      Provider.of<ProjectModel>(context, listen: false).auth;

  late final Task task = widget.task;
  late final String name = task.name;
  late final Project? project = task.inProject;

  @override
  void initState() {
    super.initState();

    debugPrint("Enter TaskRoute: ${task.name} (${task.id})");
  }

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
        appBar: AppBar(
          title: Text(project?.name ?? '<No project>'),
          actions: [
            IconButton(
              onPressed: () async {
                await task.push(auth.currentUser, firestore);
                Navigator.pop(context);
              },
              icon: Icon(Icons.done),
            )
          ], // todo 20210814 add a "ok" button for editing description
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: InkWell(
                  child: ListTile(
                    title: TextField(
                      controller: TextEditingController(text: task.name),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(),
                        border: InputBorder.none,
                      ),
                      onChanged: (newTaskName) async {
                        task.name = newTaskName;
                      },
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              Divider(
                thickness: 1,
              ),
              // todo 2022-0418 Use custom Radio widget for better code readability
              Card(
                child: InkWell(
                  child: ListTile(
                    dense: true,
                    title: Text('Important'),
                    leading: Icon(
                      task.isImportant ? Icons.star : Icons.star_border,
                      size: 15,
                    ),
                    trailing: task.isImportant
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                task.isImportant = false;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                            ),
                          )
                        : null,
                  ),
                  onTap: () {
                    setState(() {
                      task.isImportant = !task.isImportant;
                      if (task.isImportant == true) {
                        task.isUrgent = false;
                        task.isLater = false;
                      }
                      task.push(auth.currentUser, firestore);
                    });
                  },
                ),
              ),
              Card(
                child: InkWell(
                  child: ListTile(
                    dense: true,
                    title: Text('Urgent'),
                    leading: Icon(
                      task.isUrgent
                          ? Icons.timelapse
                          : Icons.timelapse_outlined,
                      size: 15,
                    ),
                    trailing: task.isUrgent
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                task.isUrgent = false;
                                task.push(auth.currentUser, firestore);
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                            ),
                          )
                        : null,
                  ),
                  onTap: () {
                    setState(() {
                      task.isUrgent = !task.isUrgent;
                      if (task.isUrgent == true) {
                        task.isImportant = false;
                        task.isLater = false;
                      }
                      task.push(auth.currentUser, firestore);
                    });
                  },
                ),
              ),
              Card(
                child: InkWell(
                  child: ListTile(
                    dense: true,
                    title: Text('Later'),
                    leading: Icon(
                      task.isLater
                          ? Icons.watch_later
                          : Icons.watch_later_outlined,
                      size: 15,
                    ),
                    trailing: task.isLater
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                task.isLater = false;
                                task.push(auth.currentUser, firestore);
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                            ),
                          )
                        : null,
                  ),
                  onTap: () {
                    setState(() {
                      task.isLater = !task.isLater;
                      if (task.isLater == true) {
                        task.isImportant = false;
                        task.isUrgent = false;
                      }
                      task.push(auth.currentUser, firestore);
                    });
                  },
                ),
              ),
              // todo 2022-0419 Pack complicated widgets here in small widgets
              Card(
                child: InkWell(
                  child: ListTile(
                    dense: true,
                    title: Text(task.targetOn == null
                        ? 'Set a Target'
                        : "Targets on ${DateFormat('yyyy-MM-dd').format(task.targetOn!)}"),
                    leading: Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                    ),
                    trailing: task.targetOn == null
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                task.targetOn = null;
                                task.push(auth.currentUser, firestore);
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                            ),
                          ),
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final target = await showDatePicker(
                      context: context,
                      initialDate: task.targetOn == null ? now : task.targetOn!,
                      firstDate: DateTime(now.year),
                      lastDate: DateTime(now.year + 3),
                    );
                    debugPrint("Picked target: $target");

                    if (target != null && task.targetOn != target) {
                      setState(() {
                        task.targetOn = target;
                      });
                      task.push(auth.currentUser, firestore);
                    }
                  },
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Card(
                child: InkWell(
                  child: ListTile(
                    title: TextField(
                      minLines: 3,
                      maxLines: null,
                      controller: TextEditingController(text: task.jottedDown),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(),
                        border: InputBorder.none,
                      ),
                      onChanged: (newJottedDown) async {
                        task.jottedDown = newJottedDown;
                      },
                    ),
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
