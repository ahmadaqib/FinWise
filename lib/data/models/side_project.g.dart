// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SideProjectAdapter extends TypeAdapter<SideProject> {
  @override
  final int typeId = 7;

  @override
  SideProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideProject(
      id: fields[0] as String,
      amount: fields[1] as double,
      source: fields[2] as String,
      date: fields[3] as DateTime,
      allocation: (fields[4] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SideProject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.allocation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
