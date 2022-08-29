import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:DeadLine_newTask/model/ProjectArguments.dart';
import 'package:DeadLine_newTask/theme.dart';
import 'package:DeadLine_newTask/widget/HelperListItem.dart';
import 'package:DeadLine_newTask/widget/ProjectItemBottomSheet.dart';

import 'ProjectRoute.dart';
import 'TaskRoute.dart';
import 'firebase_options.dart';
import 'model/Project.dart';
import 'model/ProjectModel.dart';
import 'model/Task.dart';
import 'widget/ProjectItem.dart';

late final FirebaseAuth firebaseAuth;
User? currentUser;
bool get loggedIn => currentUser != null;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  firebaseAuth = FirebaseAuth.instance;

  runApp(
    Main(
      projectModel: ProjectModel(
        auth: FirebaseAuth.instance, 
        firestore: FirebaseFirestore.instance,
      ),
    ),
  );
}

class Main extends StatelessWidget {
  Main({required ProjectModel this.projectModel});

  final ProjectModel projectModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => projectModel),
      ],
      child: MaterialApp(
        title: 'Deadline; New Task',
        darkTheme: mTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeRoute(
              title: 'Deadline; New Task',
              firestore:
                  Provider.of<ProjectModel>(context, listen: false).firestore),
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case TaskRoute.routeName:
              final task = settings.arguments as Task;

              return MaterialPageRoute(
                builder: (context) => TaskRoute(task),
              );
            case ProjectRoute.routeName:
              final args = settings.arguments as ProjectArguments;

              return MaterialPageRoute(
                builder: (context) => ProjectRoute(args),
              );
          }

          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
      ),
    );
  }
}

class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key, required this.title, required this.firestore})
      : super(key: key);
  final String title;
  final FirebaseFirestore firestore;

  @override
  HomeRouteState createState() => HomeRouteState();
}

class HomeRouteState extends State<HomeRoute> {
  Stream<QuerySnapshot>? _projectsStream;
  // final List<String> forYouItems = ;
  List<HelperListItem> helperListItems = [
    HelperListItem(
      key: Key('Your Day'),
      leadingIcon: Icons.sunny,
      name: 'Your Day',
      queryCondition: (Query query) => query.where(
        'targetOn',
        isEqualTo: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).toIso8601String(),
      ),
      addTaskSettings: (task) {
        task.targetOn = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
      },
    ),
    HelperListItem(
      key: Key('Important'),
      name: 'Important',
      leadingIcon: Icons.star,
      queryCondition: (Query query) => query.where('isImportant', isEqualTo: true),
      addTaskSettings: (task) {
        task.isImportant = true;
      },
    ),
    HelperListItem(
      key: Key('Later'),
      name: 'Later',
      leadingIcon: Icons.watch_later,
      queryCondition: (Query query) => query.where('isLater', isEqualTo: true),
      addTaskSettings: (task) {
        task.isLater = true;
      },
    ),
    HelperListItem(
      key: Key('Inbox'),
      name: 'Inbox',
      leadingIcon: Icons.inbox,
      queryCondition: (Query query) => query.where('projectid', isNull: true),
      addTaskSettings: (task){
        task.projectName = 'Inbox';
      },
    ),
  ];
  String? projectNameInput;

  final logger = Logger('HomeRouteState');

  @override
  void initState() {
    super.initState();

    firebaseAuth.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
        log("User has changed, current user is ${currentUser?.displayName ?? "null"}");

        if (currentUser != null)
          _projectsStream = Project.snapshots(currentUser, widget.firestore);
      });
    });

    // config logger
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<UserCredential> loginWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // todo 2022-0703 #platform firebaseAuth.signInWithPopup is not cross platform (only web)
    var credential = await firebaseAuth.signInWithPopup(googleProvider);

    // show Snackbar is logged in
    if (credential.user?.uid != null) {
      var msg = 'Logged in as ${credential.user!.displayName}';
      var snackBar = SnackBar(
        content: Text(msg),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return credential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!loggedIn)
            IconButton(
              onPressed: () async {
                await loginWithGoogle();
                if (currentUser != null) {
                  // await pullFirestore(currentUser!.uid);
                  log('dry loading...');
                }
              },
              icon: const Icon(Icons.login),
              tooltip: 'Login',
            )
          else
            IconButton(
              onPressed: () async {
                await firebaseAuth.signOut();

                setState(() {
                  // animes.clear();
                });

                var snackBar = const SnackBar(
                  content: Text('Logged out'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            )
        ],
      ),
      body: Column(
        children: [
          if (!loggedIn)
            Center(child: Text('Please login first!'))
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _projectsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading your projects");
                  }

                  final projectItems =
                      snapshot.data!.docs.map((DocumentSnapshot doc) {
                    final projectMap = doc.data()! as Map<String, dynamic>;
                    final id = doc.id;

                    Project project = Project.fromJson(projectMap).withId(id);
                    logger.info(
                        "StreamBuilder got project name: ${project.name} (${project.id})");

                    return ProjectItem(
                      project,
                      key: Key(project.id!),
                    );
                  }).toList();

                  return ReorderableListView.builder(
                    // todo 20211007 use StreamBuilder<QuerySnapshot> + widgetize ProjectTile. see https://firebase.flutter.dev/docs/firestore/usage#realtime-changes
                    itemCount: helperListItems.length + projectItems.length,
                    itemBuilder: (context, index) {
                      if (index < helperListItems.length) return helperListItems[index];

                      return projectItems[index - helperListItems.length];
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      var projects = List<Project>.empty(growable: true);
                      projectItems.forEach((item) {
                        projects.add(item.project);
                      });

                      debugPrint(
                          "old index=$oldIndex, processed newIndex=$newIndex");
                      var projectMoving = projects.removeAt(oldIndex);
                      projects.insert(newIndex, projectMoving);
                      // Project.pushOrder(projects, widget.firestore);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return ProjectItemBottomSheet();
            },
          );
        },
        tooltip: 'Add a project',
        child: Icon(Icons.add),
      ),
    );
  }
}
