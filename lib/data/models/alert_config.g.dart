// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertConfigAdapter extends TypeAdapter<AlertConfig> {
  @override
  final int typeId = 6;

  @override
  AlertConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertConfig(
      alertType: fields[0] as String,
      threshold: fields[1] as double,
      isEnabled: fields[2] as bool,
      lastTriggered: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AlertConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.alertType)
      ..writeByte(1)
      ..write(obj.threshold)
      ..writeByte(2)
      ..write(obj.isEnabled)
      ..writeByte(3)
      ..write(obj.lastTriggered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
