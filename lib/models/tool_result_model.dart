class ToolResultModel {
  final String toolUseId;
  final String content;
  final bool isError;

  ToolResultModel({
    required this.toolUseId,
    required this.content,
    this.isError = false,
  });

  Map<String, dynamic> toMap() => {
        'type': 'tool_result',
        'tool_use_id': toolUseId,
        'content': content,
        'is_error': isError,
      };
}
