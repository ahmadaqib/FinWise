// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomeSourceAdapter extends TypeAdapter<IncomeSource> {
  @override
  final int typeId = 1;

  @override
  IncomeSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncomeSource(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as String,
      receivedOnDay: fields[4] as int,
      isActive: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      deactivatedAt: fields[7] as DateTime?,
      changeLog: (fields[8] as List).cast<IncomeChangeLog>(),
    );
  }

  @override
  void write(BinaryWriter writer, IncomeSource obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.receivedOnDay)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.deactivatedAt)
      ..writeByte(8)
      ..write(obj.changeLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
