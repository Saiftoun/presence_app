import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/features/admin/models/academic_class.dart';

void main() {
  group('AcademicClass', () {
    test('reads the project class fields and student roster', () {
      final academicClass = AcademicClass.fromMap('class-1', {
        'name': 'Informatique',
        'group': 'DSI 3.1',
        'description': 'Cours du matin',
        'teacherId': 'teacher-1',
        'studentIds': ['student-1', 'student-2'],
        'active': true,
      });

      expect(academicClass.id, 'class-1');
      expect(academicClass.name, 'Informatique');
      expect(academicClass.group, 'DSI 3.1');
      expect(academicClass.description, 'Cours du matin');
      expect(academicClass.teacherId, 'teacher-1');
      expect(academicClass.studentIds, ['student-1', 'student-2']);
      expect(academicClass.isActive, isTrue);
    });

    test('defaults a missing active field to active for older records', () {
      final academicClass = AcademicClass.fromMap('class-2', {
        'name': 'Mathématiques',
        'group': 'L2',
        'description': '',
        'teacherId': 'teacher-2',
      });

      expect(academicClass.isActive, isTrue);
      expect(academicClass.studentIds, isEmpty);
    });
  });
}
