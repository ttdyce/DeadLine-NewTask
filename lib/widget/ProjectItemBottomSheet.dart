import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/Task.dart';

class ProjectItemBottomSheet extends StatelessWidget {
  Project? projectUpdating;
  String projectNameInput = "";
  TextEditingController textController = TextEditingController();

  ProjectItemBottomSheet({this.projectUpdating});

  @override
  Widget build(BuildContext context) {
    if (projectUpdating != null) textController.text = projectUpdating!.name;

    var taskTextField = TextField(
      controller: textController,
      autofocus: true,
      onChanged: (value) {
        projectNameInput = value;
      },
      onSubmitted: (value) {
        debugPrint(projectNameInput);
        if (projectUpdating == null) {
          var project = Project(projectNameInput);
          project.add(
              FirebaseAuth.instance.currentUser, FirebaseFirestore.instance);
        } else {
          projectUpdating!.name = projectNameInput;
          projectUpdating!.push(
            FirebaseAuth.instance.currentUser,
            FirebaseFirestore.instance,
          );
        }
        Navigator.pop(context);
      },
      decoration: InputDecoration(
          border: UnderlineInputBorder(), hintText: 'Project name'),
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
                  onPressed: () {
                    var project = Project(projectNameInput);
                    project.add(FirebaseAuth.instance.currentUser,
                        FirebaseFirestore.instance);
                    print(projectNameInput);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
  }
}
