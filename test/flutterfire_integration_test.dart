import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DeadLine_newTask/model/Task.dart';

void main() {
  test('Fake FirebaseFirestore basic test', () async {
    final firestore = FakeFirebaseFirestore();
    CollectionReference testCollection = firestore.collection('testCollection');
    final tasksRef = firestore.collection('testCollection').withConverter<Task>(
          // 'testCollection': Tasks collection
          fromFirestore: (snapshot, _) => Task.fromJson(snapshot.data()!),
          toFirestore: (task, _) => task.toJson(),
        );

    //add
    // the old way
    // await testCollection.add(Task.withName('test1').toJson());
    // await testCollection.add(Task.withName('test2').toJson());
    await tasksRef.add(Task.withName('test1'));
    await tasksRef.add(Task.withName('test2'));

    // var snapshot = await testCollection.get();
    var snapshot = await tasksRef.get().then((value) => value);
    var task = snapshot.docs.first;
    // update
    tasksRef.doc(task.id).update({"name": "testUpdated1"});

    // delete
    task = snapshot.docs.last;
    print(firestore.dump());
    print(task.id);
    await testCollection
        .doc(task.id)
        .delete()
        .then((value) => print("Deleted"))
        .catchError((error) => print("Failed to delete: $error"));
    print(firestore.dump());
    // testCollection.doc(task.id).delete();

    // snapshot = await testCollection.get();
    snapshot = await tasksRef.get();

    // print(firestore.dump());
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.get('name'), 'testUpdated1');

    // parsing back to Task
    print(snapshot.docs.first.data().name);
    print(snapshot.docs.last.data().name);
  });

  test('Fake FirebaseFirestore basic test (with model)', () async {
    final firestore = FakeFirebaseFirestore();
    Task task1 = Task.withName('test1');
    Task task2 = Task.withName('test2');

    //add
    await task1.add(null, firestore);
    await task2.add(null,firestore);

    //get
    Task.snapshots(null,firestore, queryCondition: (query) => query);

    // update
    task1.name = 'test1 revised';
    task1.push(null,firestore);

    // delete, not tested

    print(firestore.dump());
    print("task1.id: ${task1.id}");
    print("task2.id: ${task2.id}");

    // 20211020 The app now uses snapshots method, this old test is not appropriate now.
    // // print(firestore.dump());
    // var snapshot = await Task.snapshots(firestore);
    // expect(snapshot.docs.length, 2);
    // expect(snapshot.docs.first.snapshots('name'), 'test1 revised');
    //
    // // parsing back to Task
    // print(snapshot.docs.first.data() as Map<String, dynamic>);
    // print(snapshot.docs.last.data() as Map<String, dynamic>);
  });
}
