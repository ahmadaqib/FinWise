// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiCacheAdapter extends TypeAdapter<AiCache> {
  @override
  final int typeId = 10;

  @override
  AiCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiCache(
      cacheKey: fields[0] as String,
      response: fields[1] as String,
      createdAt: fields[2] as DateTime,
      ttlMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AiCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cacheKey)
      ..writeByte(1)
      ..write(obj.response)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.ttlMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
