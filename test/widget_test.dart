// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DeadLine_newTask/main.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/Task.dart';
import 'package:DeadLine_newTask/model/ProjectModel.dart';

void main() {
  group('Page initialization', () {
    var nullAuth = FirebaseAuth.instance;
    var fakeStore = FakeFirebaseFirestore();
    // set dummy firestore project data for testing
    final project1 = Project('NHV');
    project1.add(null, fakeStore);
    final project2 = Project('ts project');
    project2.add(null, fakeStore);
    Project('Anime Log').add(null, fakeStore);

    testWidgets('Test Page1 initialization', (WidgetTester tester) async {
      await tester.pumpWidget(Main(
        projectModel: ProjectModel(auth: FirebaseAuth.instance, firestore: fakeStore),
      ));

      await tester.pump();

      // "Made for you" part
      expect(find.byIcon(Icons.sunny), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.byIcon(Icons.watch_later), findsOneWidget);

      // Projects part
      expect(find.byIcon(Icons.list_sharp), findsWidgets);
      expect(find.byKey(Key(project1.id!)), findsOneWidget);
    });

    testWidgets('Test Page2 For you initialization',
        (WidgetTester tester) async {
      final taskToday =
          await Task.withProject('Today', project2).add(nullAuth.currentUser, fakeStore);
      taskToday.targetOn = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final taskLater =
          await Task.withProject('Later', project2).add(nullAuth.currentUser, fakeStore);
      taskLater.isLater = true;

      final taskInbox = await Task(name: 'Inbox').add(nullAuth.currentUser, fakeStore);

      final taskImportant =
          await Task.withProject('Important', project2).add(nullAuth.currentUser, fakeStore);
      taskImportant.isImportant = true;

      for (var task in [taskToday, taskLater, taskInbox, taskImportant]) {
        await task.push(nullAuth.currentUser, fakeStore);
      }

      await tester.pumpWidget(Main(
        projectModel: ProjectModel(auth:nullAuth, firestore: fakeStore),
      ));
      await tester.pump();

      await tester.tap(find.byKey(Key('Your Day')));
      await tester.pumpAndSettle();
      // check if entered Page 2
      expect(find.byKey(Key('Your Day')), findsNothing);
      // dummy task created above
      expect(find.byKey(Key(taskToday.id!)), findsOneWidget);

      // check others For-you pages, and so on
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Important')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key(taskImportant.id!)), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Inbox')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key(taskInbox.id!)), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('Later')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key(taskLater.id!)), findsOneWidget);
    });

    testWidgets('Test Page2 Projects initialization',
        (WidgetTester tester) async {
      final taskThis =
          await Task.withProject('Fix this', project1).add(nullAuth.currentUser, fakeStore);
      final taskThat =
          await Task.withProject('Fix that', project1).add(nullAuth.currentUser, fakeStore);
      final taskFoo =
          await Task.withProject('Fix foo', project1).add(nullAuth.currentUser, fakeStore);
      final taskBar =
          await Task.withProject('Fix bar', project1).add(nullAuth.currentUser, fakeStore);

      await tester.pumpWidget(Main(
        projectModel: ProjectModel(auth: nullAuth, firestore: fakeStore),
      ));
      await tester.pump();

      await tester.tap(find.byKey(Key(project1.id!)));
      await tester.pumpAndSettle();

      // check if entered Page 2
      expect(find.byKey(Key(project1.id!)), findsNothing);
      // dummy task created above
      expect(find.byKey(Key(taskThis.id!)), findsOneWidget);
      expect(find.byKey(Key(taskThat.id!)), findsOneWidget);
      expect(find.byKey(Key(taskFoo.id!)), findsOneWidget);
      expect(find.byKey(Key(taskBar.id!)), findsOneWidget);
    });

    testWidgets('Test Page3 initialization', (WidgetTester tester) async {
      final task =
          await Task.withProject('Landing webpage', project1).add(nullAuth.currentUser, fakeStore);

      await tester.pumpWidget(Main(
        projectModel: ProjectModel(auth: nullAuth, firestore: fakeStore),
      ));
      await tester.pump();

      await tester.tap(find.byKey(Key(project1.id!)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key(task.id!)));
      await tester.pumpAndSettle();
      // check if entered Page 3
      expect(find.text(task.name), findsOneWidget);

      expect(find.text('Important'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.byIcon(Icons.watch_later_outlined), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.byIcon(Icons.timelapse_outlined), findsOneWidget);
      expect(find.text('Set a Target'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

      expect(
        find.byWidgetPredicate(
            (widget) => widget is TextField && widget.minLines == 3,
            description: 'widget that is storing Task.JottedDown'),
        findsOneWidget,
      );
    });
  });
}
