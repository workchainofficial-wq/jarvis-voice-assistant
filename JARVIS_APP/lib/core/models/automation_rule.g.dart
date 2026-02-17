// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutomationRuleAdapter extends TypeAdapter<AutomationRule> {
  @override
  final int typeId = 1;

  @override
  AutomationRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutomationRule(
      id: fields[0] as String,
      name: fields[1] as String,
      trigger: fields[2] as String,
      triggerData: (fields[3] as Map).cast<String, dynamic>(),
      actions: (fields[4] as List).cast<String>(),
      enabled: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AutomationRule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.trigger)
      ..writeByte(3)
      ..write(obj.triggerData)
      ..writeByte(4)
      ..write(obj.actions)
      ..writeByte(5)
      ..write(obj.enabled)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
