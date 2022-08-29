import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
import 'package:DeadLine_newTask/model/Project.dart';

part 'Task.g.dart';

@JsonSerializable(explicitToJson: true)
class Task {
  static const COLLECTION_NAME = 'tasks';

  @JsonKey(ignore: true)
  String? id;
  String? projectid;
  String? projectName;

  String name;
  String? jottedDown;

  bool isImportant = false;
  bool isLater = false;
  bool isUrgent = false;
  TaskState? state;

  /// Lexorank order.
  /// Use multiple a-z instead of a number to provide mostly O(1) order updating.
  /// See also https://www.youtube.com/watch?v=OjQv9xMoFbg
  String? order;
  DateTime datetimeCreated = DateTime.now().toUtc();
  DateTime? targetOn;

  Project?
      _inProject; // store in runtime only, as db level is 2 collections: /project collection, /task collection

  Task({
    required this.name,
    this.jottedDown,
    this.state,
    this.targetOn,
  });

  Task.withName(String name)
      : this.name = name,
        this.jottedDown = '';

  Task.withProject(String name, Project? project)
      : this.name = name,
        this.jottedDown = '',
        this.projectid = project?.id,
        this.projectName = project?.name,
        this._inProject = project;

  @JsonKey(ignore: true)
  Project? get inProject => _inProject;

  bool get isDone => state == TaskState.Done;
  set isDone(bool val) {
    if (state != TaskState.Cancelled)
      state = val == true ? TaskState.Done : null;
  }

  @JsonKey(ignore: true)
  set inProject(Project? inProject) {
    _inProject = inProject;
    projectid = inProject!.id;
    projectName = inProject.name;
  }

  static Stream<QuerySnapshot<Task>> snapshots(
      User? currentUser, FirebaseFirestore firestore,
      {required Query<Object?> Function(Query<Object?> query) queryCondition}) {
    var query = firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Task.COLLECTION_NAME);
    var taskRef = queryCondition(query).orderBy('order').withConverter<Task>(
          fromFirestore: (snapshot, _) => Task.fromJson(snapshot.data()!),
          toFirestore: (task, _) => task.toJson(),
        );
    // .orderBy('datetimeCreated');

    // default not loading what is done
    // taskRef = taskRef.where('state', isNull: true);

    return taskRef.snapshots();
  }

  Future<void> push(User? currentUser, FirebaseFirestore firestore) async {
    CollectionReference tasksCollection = firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Task.COLLECTION_NAME);

    return tasksCollection.doc(id).update(this.toJson());
  }

  // using the `inProject` to add task to that project
  Future<Task> add(User? currentUser, FirebaseFirestore firestore) async {
    CollectionReference tasksCollection = firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Task.COLLECTION_NAME);

    var ref = await tasksCollection.add(this.toJson());
    id = ref.id;

    return this;
  }

  // todo 20210901 implement Task.remove, instead of delete
  Future<void> remove(User? currentUser, FirebaseFirestore firestore) async {
    return firestore
        .collection("users")
        .doc(currentUser!.email)
        .collection(Task.COLLECTION_NAME)
        .doc(id)
        .delete();
  }

  Task withId(String id) {
    this.id = id;
    return this;
  }

  // todo 20211016 maybe using too much update in Firestore
  /// update the Task.order in the tasks list, and push (make update) to Firestore
  // static void pushOrder(List<Task> tasks, firestore) {
  //   for (var i = 0; i < tasks.length; i++) {
  //     var task = tasks[i];
  //     // task.order = i;
  //     task.push(firestore);
  //   }
  // }

  /// A necessary factory constructor for creating a new Task instance
  /// from a map. Pass the map to the generated `_$TaskFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Task.
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskToJson`.
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

enum TaskState { Done, Cancelled }
