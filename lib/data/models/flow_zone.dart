import 'package:hive/hive.dart';

part 'flow_zone.g.dart';

@HiveType(typeId: 11)
class FlowZone extends HiveObject {
  @HiveField(0)
  double shieldTarget; // target % (e.g. 25.0)

  @HiveField(1)
  double flowTarget; // target % (e.g. 45.0)

  @HiveField(2)
  double growTarget; // target % (e.g. 20.0)

  @HiveField(3)
  double freeTarget; // target % (e.g. 10.0)

  FlowZone({
    this.shieldTarget = 25.0,
    this.flowTarget = 45.0,
    this.growTarget = 20.0,
    this.freeTarget = 10.0,
  });
}
