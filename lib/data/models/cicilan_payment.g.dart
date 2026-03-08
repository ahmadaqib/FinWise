// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cicilan_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CicilanPaymentAdapter extends TypeAdapter<CicilanPayment> {
  @override
  final int typeId = 9;

  @override
  CicilanPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CicilanPayment(
      id: fields[0] as String,
      cicilanId: fields[1] as String,
      paymentNumber: fields[2] as int,
      amount: fields[3] as double,
      paidDate: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CicilanPayment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cicilanId)
      ..writeByte(2)
      ..write(obj.paymentNumber)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paidDate)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CicilanPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
