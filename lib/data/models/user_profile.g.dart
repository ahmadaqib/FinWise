// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      fixedIncome1: fields[1] as double,
      fixedIncome2: fields[2] as double,
      cicilanMonth1: fields[3] as double,
      cicilanNormal: fields[4] as double,
      isMonth1: fields[5] as bool,
      cicilanDueDay: fields[6] == null ? 24 : fields[6] as int,
      emergencyFundTarget: fields[7] == null ? 15000000 : fields[7] as double,
      monthlyPassiveTarget: fields[8] == null ? 5000000 : fields[8] as double,
      netWorthTarget: fields[9] == null ? 100000000 : fields[9] as double,
      salaryDate: fields[10] == null ? 25 : fields[10] as int,
      lastArchivedDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.fixedIncome1)
      ..writeByte(2)
      ..write(obj.fixedIncome2)
      ..writeByte(3)
      ..write(obj.cicilanMonth1)
      ..writeByte(4)
      ..write(obj.cicilanNormal)
      ..writeByte(5)
      ..write(obj.isMonth1)
      ..writeByte(6)
      ..write(obj.cicilanDueDay)
      ..writeByte(7)
      ..write(obj.emergencyFundTarget)
      ..writeByte(8)
      ..write(obj.monthlyPassiveTarget)
      ..writeByte(9)
      ..write(obj.netWorthTarget)
      ..writeByte(10)
      ..write(obj.salaryDate)
      ..writeByte(11)
      ..write(obj.lastArchivedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
