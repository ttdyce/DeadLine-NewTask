import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:DeadLine_newTask/model/Task.dart';

part 'Project.g.dart';

@JsonSerializable()
class Project {
  static const COLLECTION_NAME = 'projects';

  @JsonKey(ignore: true)
  String? id;
  String name;
  int order = 0;
  String? description;
  ProjectPhrase phrase;
  ProjectState? state;

  Project(this.name, {this.state, this.phrase = ProjectPhrase.Idea});

  static Stream<QuerySnapshot> snapshots(
      User? currentUser, FirebaseFirestore firestore) {
    Query<Map<String, dynamic>> projectsCollection = firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Project.COLLECTION_NAME)
        .orderBy('name');

    projectsCollection.get().then((value) {
      if (!value.docs.isEmpty) log(value.docs.first.id);
    });
    return projectsCollection.snapshots();
  }

  void add(User? currentUser, FirebaseFirestore firestore) async {
    CollectionReference projectsCollection = firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Project.COLLECTION_NAME);
    final ref = await projectsCollection.add(this.toJson());
    id = ref.id;
  }

  Future<void> push(User? currentUser, FirebaseFirestore firestore) async {
    return firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Project.COLLECTION_NAME)
        .doc(id)
        .update(this.toJson());
  }

  // todo 20210901 implement Project.remove, instead of delete
  // remove this project and related tasks in Firestore
  Future<void> remove(User? currentUser, FirebaseFirestore firestore) async {
    DocumentReference<Map<String, dynamic>> userDoc = firestore
        .collection("users")
        .doc(currentUser!.email);
    var projectDoc = userDoc
        .collection(Project.COLLECTION_NAME)
        .doc(id);
    userDoc
        .collection(Task.COLLECTION_NAME)
        .where('projectid', isEqualTo: id)
        .get()
        .then((value) => value.docs.forEach((doc) {
              // deleting related tasks
              debugPrint("deleting ${doc.id}");
              doc.reference.delete();
            }));

    // deleting project
    return projectDoc.delete();
  }

  Project withId(String id) {
    this.id = id;
    return this;
  }

  // // todo 20211201 maybe using too much update in Firestore
  // /// update the Project.order in the projects list, and push (make update) to Firestore
  // static void pushOrder(List<Project> projects, firestore) {
  //   for (var i = 0; i < projects.length; i++) {
  //     var project = projects[i];
  //     project.order = i;
  //     // project.push(firestore);
  //   }
  // }

  /// A necessary factory constructor for creating a new Project instance
  /// from a map. Pass the map to the generated `_$ProjectFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Project.
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$ProjectToJson`.
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

enum ProjectPhrase { Idea, ProveOfIdea, Release }

enum ProjectState { Active, Inactive, Abandoned }
