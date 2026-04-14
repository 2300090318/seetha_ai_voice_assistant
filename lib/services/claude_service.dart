import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/tool_result_model.dart';

class ClaudeService {
  final String apiKey;

  // Conversation memory: last 10 exchanges
  final List<Map<String, dynamic>> _history = [];

  ClaudeService({required this.apiKey});

  // ─── All 13 Tool Definitions ────────────────────────────────────────────────
  static List<Map<String, dynamic>> get toolDefinitions => [
        {
          'name': 'open_app',
          'description': 'Open any installed Android app by name',
          'input_schema': {
            'type': 'object',
            'properties': {
              'app_name': {'type': 'string'}
            },
            'required': ['app_name']
          }
        },
        {
          'name': 'play_music',
          'description': 'Play music on Spotify or YouTube',
          'input_schema': {
            'type': 'object',
            'properties': {
              'song_name': {'type': 'string'},
              'platform': {
                'type': 'string',
                'enum': ['spotify', 'youtube', 'auto']
              }
            },
            'required': ['song_name']
          }
        },
        {
          'name': 'pick_photo_from_gallery',
          'description': 'Open gallery for user to pick a photo to edit',
          'input_schema': {'type': 'object', 'properties': {}}
        },
        {
          'name': 'edit_photo',
          'description': 'Edit a photo with voice-specified operation',
          'input_schema': {
            'type': 'object',
            'properties': {
              'operation': {
                'type': 'string',
                'enum': [
                  'open_editor',
                  'crop',
                  'rotate',
                  'brightness',
                  'contrast',
                  'saturation',
                  'filter',
                  'flip',
                  'text_overlay',
                  'save'
                ]
              },
              'value': {'type': 'string'},
              'filter_name': {'type': 'string'}
            },
            'required': ['operation']
          }
        },
        {
          'name': 'pick_video_from_gallery',
          'description': 'Open gallery for user to pick a video to edit',
          'input_schema': {'type': 'object', 'properties': {}}
        },
        {
          'name': 'edit_video',
          'description': 'Edit a video with voice-specified operation',
          'input_schema': {
            'type': 'object',
            'properties': {
              'operation': {
                'type': 'string',
                'enum': [
                  'open_editor',
                  'trim',
                  'merge',
                  'add_music',
                  'mute',
                  'speed',
                  'compress',
                  'watermark',
                  'fade_in',
                  'fade_out',
                  'extract_audio',
                  'save'
                ]
              },
              'start_time': {'type': 'string'},
              'end_time': {'type': 'string'},
              'speed_value': {'type': 'number'},
              'text_value': {'type': 'string'}
            },
            'required': ['operation']
          }
        },
        {
          'name': 'search_web',
          'description': 'Search the web for any query',
          'input_schema': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'}
            },
            'required': ['query']
          }
        },
        {
          'name': 'make_call',
          'description': 'Call a contact from phone contacts',
          'input_schema': {
            'type': 'object',
            'properties': {
              'contact_name': {'type': 'string'}
            },
            'required': ['contact_name']
          }
        },
        {
          'name': 'send_whatsapp',
          'description': 'Send a WhatsApp message to a contact',
          'input_schema': {
            'type': 'object',
            'properties': {
              'contact_name': {'type': 'string'},
              'message': {'type': 'string'}
            },
            'required': ['contact_name', 'message']
          }
        },
        {
          'name': 'set_alarm',
          'description': 'Set an alarm or reminder',
          'input_schema': {
            'type': 'object',
            'properties': {
              'time': {'type': 'string'},
              'label': {'type': 'string'}
            },
            'required': ['time']
          }
        },
        {
          'name': 'get_weather',
          'description': 'Get current weather for a city',
          'input_schema': {
            'type': 'object',
            'properties': {
              'city': {'type': 'string'}
            },
            'required': ['city']
          }
        },
        {
          'name': 'get_news',
          'description': 'Get latest news headlines by topic',
          'input_schema': {
            'type': 'object',
            'properties': {
              'topic': {'type': 'string'}
            }
          }
        },
        {
          'name': 'get_current_time',
          'description': 'Get current date and time',
          'input_schema': {'type': 'object', 'properties': {}}
        },
      ];

  // ─── Send Message ───────────────────────────────────────────────────────────
  /// Returns (toolName, toolInput, toolUseId) if tool_use, else (null, null, null)
  Future<Map<String, dynamic>> sendMessage(String userMessage) async {
    // Add user message to history
    _history.add({'role': 'user', 'content': userMessage});

    // Trim to last 10 exchanges (20 messages)
    if (_history.length > 20) {
      _history.removeRange(0, _history.length - 20);
    }

    final body = jsonEncode({
      'model': AppStrings.model,
      'max_tokens': 1024,
      'system': AppStrings.systemPrompt,
      'tools': toolDefinitions,
      'messages': _history,
    });

    try {
      final response = await http.post(
        Uri.parse(AppStrings.baseUrl),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': AppStrings.anthropicVersion,
          'content-type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseResponse(data);
      } else if (response.statusCode == 401) {
        return {
          'type': 'error',
          'text': AppStrings.invalidApiKey,
          'code': 401,
        };
      } else {
        return {
          'type': 'error',
          'text': AppStrings.claudeError,
          'code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'type': 'error',
        'text': AppStrings.noInternet,
      };
    }
  }

  /// Send tool result back to Claude and get final text
  Future<String> sendToolResult(
    ToolResultModel result,
    List<Map<String, dynamic>> assistantContent,
  ) async {
    // Add assistant's tool_use message to history
    _history.add({'role': 'assistant', 'content': assistantContent});

    // Add tool result message
    _history.add({
      'role': 'user',
      'content': [result.toMap()],
    });

    final body = jsonEncode({
      'model': AppStrings.model,
      'max_tokens': 1024,
      'system': AppStrings.systemPrompt,
      'tools': toolDefinitions,
      'messages': _history,
    });

    try {
      final response = await http.post(
        Uri.parse(AppStrings.baseUrl),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': AppStrings.anthropicVersion,
          'content-type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = _parseResponse(data);
        return parsed['text'] ?? AppStrings.claudeError;
      }
      return AppStrings.claudeError;
    } catch (e) {
      return AppStrings.noInternet;
    }
  }

  Map<String, dynamic> _parseResponse(Map<String, dynamic> data) {
    final content = data['content'] as List<dynamic>? ?? [];

    String? textResponse;
    Map<String, dynamic>? toolUseBlock;
    List<Map<String, dynamic>> rawContent = [];

    for (final block in content) {
      final blockMap = block as Map<String, dynamic>;
      rawContent.add(blockMap);

      if (blockMap['type'] == 'text') {
        textResponse = blockMap['text'] as String?;
      } else if (blockMap['type'] == 'tool_use') {
        toolUseBlock = blockMap;
      }
    }

    if (toolUseBlock != null) {
      return {
        'type': 'tool_use',
        'tool_name': toolUseBlock['name'],
        'tool_input': toolUseBlock['input'],
        'tool_use_id': toolUseBlock['id'],
        'raw_content': rawContent,
        'text': textResponse,
      };
    }

    // Add assistant's text to history
    if (textResponse != null) {
      _history.add({'role': 'assistant', 'content': textResponse});
    }

    return {
      'type': 'text',
      'text': textResponse ?? '',
    };
  }

  void clearHistory() => _history.clear();
}
