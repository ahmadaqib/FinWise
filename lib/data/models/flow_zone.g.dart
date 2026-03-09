// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_zone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlowZoneAdapter extends TypeAdapter<FlowZone> {
  @override
  final int typeId = 11;

  @override
  FlowZone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlowZone(
      shieldTarget: fields[0] as double,
      flowTarget: fields[1] as double,
      growTarget: fields[2] as double,
      freeTarget: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FlowZone obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.shieldTarget)
      ..writeByte(1)
      ..write(obj.flowTarget)
      ..writeByte(2)
      ..write(obj.growTarget)
      ..writeByte(3)
      ..write(obj.freeTarget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlowZoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
