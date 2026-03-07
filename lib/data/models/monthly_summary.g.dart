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
    );
  }

  @override
  void write(BinaryWriter writer, MonthlySummary obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.saldo);
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
