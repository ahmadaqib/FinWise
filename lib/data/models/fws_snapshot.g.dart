// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fws_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FWSSnapshotAdapter extends TypeAdapter<FWSSnapshot> {
  @override
  final int typeId = 13;

  @override
  FWSSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FWSSnapshot(
      date: fields[0] as DateTime,
      score: fields[1] as double,
      flowComponent: fields[2] as double,
      quadrantComponent: fields[3] as double,
      behaviorComponent: fields[4] as double,
      anchorComponent: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FWSSnapshot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.flowComponent)
      ..writeByte(3)
      ..write(obj.quadrantComponent)
      ..writeByte(4)
      ..write(obj.behaviorComponent)
      ..writeByte(5)
      ..write(obj.anchorComponent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FWSSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
