class CommandResult {
  final bool success;
  final String action;
  final String response;
  final bool shouldSpeak;
  final String? needsPermission;
  final Map<String, dynamic>? metadata;
  
  CommandResult({
    required this.success,
    required this.action,
    required this.response,
    this.shouldSpeak = false,
    this.needsPermission,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'success': success,
    'action': action,
    'response': response,
    'shouldSpeak': shouldSpeak,
    'needsPermission': needsPermission,
    'metadata': metadata,
  };
  
  factory CommandResult.fromJson(Map<String, dynamic> json) => CommandResult(
    success: json['success'],
    action: json['action'],
    response: json['response'],
    shouldSpeak: json['shouldSpeak'] ?? false,
    needsPermission: json['needsPermission'],
    metadata: json['metadata'],
  );
}
