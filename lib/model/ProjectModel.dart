import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:DeadLine_newTask/widget/TaskItem.dart';
import 'Task.dart';

class ProjectModel extends ChangeNotifier {

  ProjectModel({required this.auth, required this.firestore});

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  
  Logger logger = Logger('ProjectModel');
  final List<Task> tasks = [];
  final List<bool> objectiveExpanded = [];

  // TODO 2022-0807 not in use
  List<TaskItem> get __taskItems => tasks
      .map((t) => TaskItem(
        t,
        false, 
        key: Key("${t.id}"),
      ),)
      .toList();

  List<ExpansionPanel> get expansionItems {
    List<ExpansionPanel> items = [];

    items.add(
      ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              dense: true,
              title: Text('Tasks'),
            );
          },
          body:
              taskBuilder(), // TODO 20210123 Remove future builder inside a Consumer
          isExpanded: objectiveExpanded.length == 0 ? false : objectiveExpanded.last),
    );

    return items;
  }

  void addTasks(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void setTasks(List<Task> _tasks) {
    this.tasks.clear();
    this.tasks.addAll(_tasks);
    notifyListeners();
  }

  void updateObjectiveExpanded(int index, bool isExpanded) {
    objectiveExpanded[index] = isExpanded;
    notifyListeners();
  }

  Widget taskBuilder() {
    final itemsToShow = __taskItems.where((t) {
      if (false) return true; // todo 20220202 pass the showCompletedTask in ProjectRoute
      return t.task.isDone == false;
    }).toList();

    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: itemsToShow.length,
      itemBuilder: (context, index) {
        return itemsToShow[index];
      },
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        var tasks = List<Task>.empty(growable: true);
        itemsToShow.forEach((item) {
          tasks.add(item.task);
        });

        debugPrint("old index=$oldIndex, processed newIndex=$newIndex");
        var taskMoving = tasks.removeAt(oldIndex);
        tasks.insert(newIndex, taskMoving);
        // Task.pushOrder(tasks, FirebaseFirestore.instance); // todo 20220202 push changes in background
      },
    );
  }
}
