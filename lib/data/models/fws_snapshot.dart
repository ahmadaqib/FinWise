import 'package:hive/hive.dart';

part 'fws_snapshot.g.dart';

@HiveType(typeId: 13)
class FWSSnapshot extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double score; // 0-1000

  @HiveField(2)
  double flowComponent;

  @HiveField(3)
  double quadrantComponent;

  @HiveField(4)
  double behaviorComponent;

  @HiveField(5)
  double anchorComponent;

  FWSSnapshot({
    required this.date,
    required this.score,
    required this.flowComponent,
    required this.quadrantComponent,
    required this.behaviorComponent,
    required this.anchorComponent,
  });
}
