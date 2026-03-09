// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlySummaryAdapter extends TypeAdapter<MonthlySummary> {
  @override
  final int typeId = 5;

  @override
  MonthlySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlySummary(
      month: fields[0] as int,
      year: fields[1] as int,
      totalIncome: fields[2] as double,
      totalExpense: fields[3] as double,
      cicilanPaid: fields[4] as bool,
      saldo: fields[5] as double,
      fwsScore: fields[6] as double?,
      zoneShieldSpent: fields[7] as double?,
      zoneFlowSpent: fields[8] as double?,
      zoneGrowSpent: fields[9] as double?,
      zoneFreeSpent: fields[10] as double?,
      startDate: fields[11] as DateTime?,
      endDate: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlySummary obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.month)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.totalIncome)
      ..writeByte(3)
      ..write(obj.totalExpense)
      ..writeByte(4)
      ..write(obj.cicilanPaid)
      ..writeByte(5)
      ..write(obj.saldo)
      ..writeByte(6)
      ..write(obj.fwsScore)
      ..writeByte(7)
      ..write(obj.zoneShieldSpent)
      ..writeByte(8)
      ..write(obj.zoneFlowSpent)
      ..writeByte(9)
      ..write(obj.zoneGrowSpent)
      ..writeByte(10)
      ..write(obj.zoneFreeSpent)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
