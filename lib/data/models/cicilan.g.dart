// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cicilan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CicilanAdapter extends TypeAdapter<Cicilan> {
  @override
  final int typeId = 8;

  @override
  Cicilan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cicilan(
      id: fields[0] as String,
      name: fields[1] as String,
      totalAmount: fields[2] as double,
      monthlyAmount: fields[3] as double,
      totalTenor: fields[4] as int,
      startDate: fields[5] as DateTime,
      dueDay: fields[6] as int,
      isActive: fields[7] as bool,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Cicilan obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.monthlyAmount)
      ..writeByte(4)
      ..write(obj.totalTenor)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.dueDay)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CicilanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
