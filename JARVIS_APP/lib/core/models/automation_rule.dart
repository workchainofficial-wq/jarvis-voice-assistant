import 'package:hive/hive.dart';

part 'automation_rule.g.dart';

@HiveType(typeId: 1)
class AutomationRule extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String trigger; // time, location, event
  
  @HiveField(3)
  final Map<String, dynamic> triggerData;
  
  @HiveField(4)
  final List<String> actions;
  
  @HiveField(5)
  final bool enabled;
  
  @HiveField(6)
  final DateTime createdAt;
  
  AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.triggerData,
    required this.actions,
    required this.enabled,
    required this.createdAt,
  });
}
