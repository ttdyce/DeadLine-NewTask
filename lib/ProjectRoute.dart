import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/ProjectArguments.dart';
import 'package:DeadLine_newTask/model/Task.dart';
import 'package:DeadLine_newTask/model/ProjectModel.dart';
import 'package:DeadLine_newTask/widget/ProjectItemBottomSheet.dart';
import 'package:DeadLine_newTask/widget/TaskItem.dart';
import 'package:DeadLine_newTask/widget/TaskItemBottomSheet.dart';

import 'model/LexoRank.dart';

class ProjectRoute extends StatefulWidget {
  static const routeName = '/project';
  ProjectArguments args;

  ProjectRoute(this.args);

  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<ProjectRoute> {
  late final ProjectArguments args = widget.args;
  late final String name = args.name;
  late final Project? project = args.project;
  late final bool showProjectName = args.showProjectName;

  late final firestore =
      Provider.of<ProjectModel>(context, listen: false).firestore;
  late final auth = Provider.of<ProjectModel>(context, listen: false).auth;
  late final Future<QuerySnapshot<Map<String, dynamic>>> _objectivesFuture;
  late final Stream<QuerySnapshot<Task>> _tasksStream =
      Task.snapshots(auth.currentUser, firestore, queryCondition: args.queryCondition);
  bool isTaskExpanded = true;

  List<Task> tasks = List<Task>.empty(growable: true);

  bool showCompletedTask = false;

  final logger = Logger('ProjectState');

  @override
  void initState() {
    super.initState();

    if (project == null)
      debugPrint("Enter ProjectRoute: ${name}");
    else
      debugPrint("Enter ProjectRoute: ${project!.name} (${project!.id})");
    // initObjectives();
    // initTasks();
  }

  // void initTasks() async {

  // tasks = (await _tasksFuture).docs.map((DocumentSnapshot doc) {
  //   final taskMap = doc.data()! as Map<String, dynamic>;
  //   final id = doc.id;
  //   debugPrint(id);

  //   var task = Task.fromJson(taskMap).withId(id);
  //   logger.info("initTasks got task name: ${task.name} (${task.id})");

  //   return task;
  // }).toList();

  // Provider.of<ProjectModel>(context, listen: false).setTasks(tasks);
  // }

  // void initObjectives() async {
  //   _objectivesFuture = Objective.get(firestore, projectid: project.id!);

  //   objectives = (await _objectivesFuture).docs.map((DocumentSnapshot doc) {
  //     final objectiveMap = doc.data()! as Map<String, dynamic>;
  //     final id = doc.id;
  //     debugPrint(id);

  //     var objective = Objective.fromJson(objectiveMap).withId(id);
  //     logger.info(
  //         "initObjectives got objective name: ${objective.name} (${objective.id})");

  //     return objective;
  //   }).toList();

  //   Provider.of<ProjectModel>(context, listen: false).setObjectives(objectives);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) async {
              switch (value) {
                case 'Remove project': // should be hidden from menu if project is null
                  bool reallyRemove = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Are you sure to remove project?'),
                            content: const Text(
                                'removed project will be Archived (currently deleted). '),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('OK'),
                              ),
                            ],
                          ));
                  if (reallyRemove)
                    project!
                        .remove(FirebaseAuth.instance.currentUser, firestore);

                  break;
                case 'Hide completed tasks':
                case 'Show completed tasks':
                  setState(() {
                    showCompletedTask = !showCompletedTask;
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                if (args.project != null) 'Remove project',
                if (showCompletedTask)
                  'Hide completed tasks'
                else
                  'Show completed tasks',
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ], // todo 20210814 add a "ok" button for editing description
      ),
      body: StreamBuilder<QuerySnapshot<Task>>(
        stream: _tasksStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Task>> snapshot) {
          if (snapshot.hasError) {
            logger.info(snapshot.error);
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          tasks.clear();
          tasks.addAll(snapshot.data!.docs.map((DocumentSnapshot<Task> doc) {
            final id = doc.id;
            var task = doc.data()!.withId(id);
            if (project != null) task.inProject = project;
            logger
                .info("_tasksStream got task name: ${task.name} (${task.id})");

            return task;
          }).toList());

          if (!showCompletedTask)
            tasks = tasks.where((element) => !element.isDone).toList();

          return ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              var nearby = newIndex == oldIndex + 1 || newIndex == oldIndex - 1;

              var from = tasks[oldIndex];
              var to = tasks[newIndex];
              var fromOriginal = from.order;
              var toOriginal = to.order;
              logger.info("Moving from $oldIndex to $newIndex");
              logger
                  .info("  moving task from: ${fromOriginal} to ${toOriginal}");

              if (nearby) {
                // swap from, to
                var tempOrder = from.order;
                from.order = to.order;
                to.order = tempOrder;
                logger.info("  moved task from: ${from.order} to ${to.order}");

                from.push(auth.currentUser, firestore);
                to.push(auth.currentUser, firestore);
              } else {
                // update from.order to new order, also update MIN/MAX mark
                var toPrev = newIndex - 1 < 0
                    ? LexoRank.MIN.rank
                    : tasks[newIndex - 1].order;
                var toNext = newIndex + 1 >= tasks.length
                    ? LexoRank.MAX.rank
                    : tasks[newIndex + 1].order;

                // before anything, do balancing first if needed
                var newRank = LexoRank.generate(
                  LexoRank(to.order),
                  oldIndex < newIndex ? LexoRank(toPrev) : LexoRank(toNext),
                );
                var balancingNeeded = newRank == null;
                if (balancingNeeded) {
                  logger.info('balancing...');
                  var balancedRank = LexoRank.balancing(
                      tasks.map((e) => LexoRank(e.order)).toList());
                  for (var i = 0; i < tasks.length; i++) {
                    tasks[i].order = balancedRank[i].rank;
                    tasks[i].push(auth.currentUser, firestore);
                  }
                  to = tasks[newIndex];
                  toPrev = newIndex - 1 < 0
                      ? LexoRank.MIN.rank
                      : tasks[newIndex - 1].order;
                  toNext = newIndex + 1 >= tasks.length
                      ? LexoRank.MAX.rank
                      : tasks[newIndex + 1].order;
                  logger.info(
                      "  done balancing, generating left=${to.order}, right=${(oldIndex < newIndex ? LexoRank(toPrev) : LexoRank(toNext)).rank}");
                  newRank = LexoRank.generate(
                    LexoRank(to.order),
                    oldIndex < newIndex ? LexoRank(toPrev) : LexoRank(toNext),
                  );
                }

                // from's MIN/MAX marker
                if (from.order == LexoRank.MIN.rank) {
                  var fromNext = tasks[1];
                  fromNext.order = LexoRank.MIN.rank;
                  fromNext.push(auth.currentUser, firestore);
                } else if (from.order == LexoRank.MAX.rank) {
                  var fromPrev = tasks[tasks.length - 2];
                  fromPrev.order = LexoRank.MAX.rank;
                  fromPrev.push(auth.currentUser, firestore);
                }

                // to's MIN/MAX marker, update from.order
                if (toPrev == to.order || toNext == to.order) {
                  var before = to.order;
                  from.order = to.order;
                  to.order = newRank;
                  to.push(auth.currentUser, firestore);

                  var after = to.order;
                  logger.info(
                      "  Update to, before=$before; after=$after; nearby=${(oldIndex < newIndex ? LexoRank(toPrev) : LexoRank(toNext)).rank}");
                } else {
                  var newRank = LexoRank.generate(
                    LexoRank(to.order),
                    newIndex > oldIndex ? LexoRank(toNext) : LexoRank(toPrev),
                  );
                  from.order = newRank;
                }

                var currentOrdering = tasks.map((e) => e.order).toList();
                logger.info("  planning to move task to ${from.order}");
                logger.info("  total tasks: ${currentOrdering}");
                from.push(auth.currentUser, firestore);
              }
            },
            children: tasks
                .map((task) => TaskItem(
                      task,
                      showProjectName,
                      key: Key("${task.id}"),
                    ))
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return TaskItemBottomSheet(
                tasks,
                project,
                addTaskSettings: args.addTaskSettings,
              );
            },
          );
        },
        tooltip: 'Add an item',
        child: Icon(Icons.add),
      ),
    );
  }
}
