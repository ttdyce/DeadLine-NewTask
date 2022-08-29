import 'package:flutter_test/flutter_test.dart';
import 'package:DeadLine_newTask/model/Project.dart';
import 'package:DeadLine_newTask/model/Task.dart';

void main() {
  test('Task standalone test', () {
    var task = Task.withName('Code unit test');
    expect(task.name, 'Code unit test');
    expect(task.id, null);

    task = Task.withName('Code unit test id').withId('123');
    expect(task.name, 'Code unit test id');
    expect(task.id, '123');
  });

  test('Project standalone test', () {
    var project = Project('Second Project');
    expect(project.name, 'Second Project');
    expect(project.id, null);

    project = Project('Code unit test id').withId('123');
    expect(project.name, 'Code unit test id');
    expect(project.id, '123');
  });

  test('Task with Project test', () {
    var project = Project('Second Project').withId('P123');
    var task = Task.withProject('Code unit test', project).withId('T123');
    expect(task.projectid, 'P123');
    expect(task.inProject, project);
    expect(task.inProject!.name, 'Second Project');
  });
}
