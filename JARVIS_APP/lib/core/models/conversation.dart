import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 0)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String message;
  
  @HiveField(2)
  final bool isUser;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String? action;
  
  @HiveField(5)
  final Map<String, dynamic>? metadata;
  
  Conversation({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.action,
    this.metadata,
  });
}
