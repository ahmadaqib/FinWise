// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_change_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomeChangeLogAdapter extends TypeAdapter<IncomeChangeLog> {
  @override
  final int typeId = 2;

  @override
  IncomeChangeLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncomeChangeLog(
      oldAmount: fields[0] as double,
      newAmount: fields[1] as double,
      changedAt: fields[2] as DateTime,
      reason: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeChangeLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.oldAmount)
      ..writeByte(1)
      ..write(obj.newAmount)
      ..writeByte(2)
      ..write(obj.changedAt)
      ..writeByte(3)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeChangeLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
