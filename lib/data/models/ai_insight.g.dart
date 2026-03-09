// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiInsightAdapter extends TypeAdapter<AiInsight> {
  @override
  final int typeId = 12;

  @override
  AiInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiInsight(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      type: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isRead: fields[5] as bool,
      actionLabel: fields[6] as String?,
      actionRoute: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AiInsight obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.actionLabel)
      ..writeByte(7)
      ..write(obj.actionRoute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
