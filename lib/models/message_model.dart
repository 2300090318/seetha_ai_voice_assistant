class MessageModel {
  final int? id;
  final String userMsg;
  final String seethaMsg;
  final String? toolUsed;
  final DateTime timestamp;

  MessageModel({
    this.id,
    required this.userMsg,
    required this.seethaMsg,
    this.toolUsed,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      userMsg: map['user_msg'] as String,
      seethaMsg: map['seetha_msg'] as String,
      toolUsed: map['tool_used'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_msg': userMsg,
        'seetha_msg': seethaMsg,
        'tool_used': toolUsed,
        'timestamp': timestamp.toIso8601String(),
      };
}
