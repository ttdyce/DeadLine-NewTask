import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:DeadLine_newTask/ProjectRoute.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/ProjectArguments.dart';

import 'ProjectItemBottomSheet.dart';

class ProjectItem extends StatelessWidget {
  Project project;
  IconData leadingIcon;

  ProjectItem(this.project, {Key? key, this.leadingIcon = Icons.list_sharp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Rename',
          color: Colors.black45,
          icon: Icons.more_horiz,
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              // isScrollControlled: true,
              builder: (BuildContext context) {
                return ProjectItemBottomSheet(projectUpdating: project);
              },
            );

            print('Rename');
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () async {
            print('Delete clicked');
            bool reallyRemove = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Are you sure to remove project?'),
                      content: const Text(
                          'Both the project and its related task be Archived (currently is still deleted). '),
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
            if (reallyRemove) {
              project.remove(FirebaseAuth.instance.currentUser,
                  FirebaseFirestore.instance);
            }
          },
        ),
      ],
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              ProjectRoute.routeName,
              arguments: ProjectArguments(
                queryCondition: (query) =>
                    query.where('projectid', isEqualTo: project.id),
                project: project,
                name: project.name,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              dense: true,
              title: Text(
                project.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              leading: Icon(
                  leadingIcon), // todo 20220331 make leading icon a variable to support editor's choice icon/emoji
              trailing: Row(
                // todo 20220331 make trailing a number of Task
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                ],
              ),
              // disabled for simplistic
              // subtitle: ["", null].contains(project.description)
              //   ? null
              //   : Text(project.description ?? ""),
            ),
          ),
        ),
      ),
    );
  }
}
