import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:DeadLine_newTask/model/Task.dart';

import 'Project.dart';

class ProjectArguments {
  Project? project;
  bool showProjectName;
  String name;
  Query Function(Query query) queryCondition;
  void Function(Task task)? addTaskSettings;

  ProjectArguments({
    required this.queryCondition,
    required this.name,
    this.project,
    this.showProjectName = false, 
    this.addTaskSettings,
  });
}
