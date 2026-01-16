import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chat_models.dart';

/// Service for interacting with Google Gemini 2.5 Flash Lite API.
///
/// API key is loaded from .env file (GEMINI_API_KEY)
/// To get an API key, visit: https://aistudio.google.com/apikey
class ChatService {
  GenerativeModel? _model;
  ChatSession? _chat;
  final List<ChatMessage> _messages = [];
  bool _isInitialized = false;
  String? _initError;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isInitialized => _isInitialized;
  String? get initError => _initError;

  ChatService() {
    _initialize();
  }

  void _initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      _initError = 'Please add your Gemini API key to the .env file';
      _isInitialized = false;
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        systemInstruction: Content.text('''
You are SafeTravel AI, a helpful travel safety assistant for tourists in India.
Your role is to:
- Provide safety tips for traveling in different areas
- Answer questions about safe zones, caution zones, and danger zones
- Give advice on local customs, transportation, and emergency contacts
- Help users understand safety ratings and what they mean
- Be concise, friendly, and helpful

Keep responses brief (2-3 sentences max) unless the user asks for details.
Always prioritize user safety and recommend consulting local authorities for emergencies.
'''),
      );

      _chat = _model!.startChat();
      _isInitialized = true;
    } catch (e) {
      _initError = 'Failed to initialize AI: ${e.toString()}';
      _isInitialized = false;
    }
  }

  /// Send a message to Gemini and get a response.
  Future<ChatMessage> sendMessage(String userMessage) async {
    final userMsg = ChatMessage(
      content: userMessage,
      sender: MessageSender.user,
    );
    _messages.add(userMsg);

    if (!_isInitialized || _chat == null) {
      final errorMsg = ChatMessage(
        content: _initError ??
            'Chat service not available. Please configure your API key.',
        sender: MessageSender.bot,
      );
      _messages.add(errorMsg);
      return errorMsg;
    }

    try {
      final response = await _chat!.sendMessage(Content.text(userMessage));
      final botResponse =
          response.text ?? 'Sorry, I could not process that request.';

      final botMsg = ChatMessage(
        content: botResponse,
        sender: MessageSender.bot,
      );
      _messages.add(botMsg);

      return botMsg;
    } catch (e) {
      final errorMsg = ChatMessage(
        content: 'Sorry, I encountered an error. Please try again.',
        sender: MessageSender.bot,
      );
      _messages.add(errorMsg);
      return errorMsg;
    }
  }

  /// Clear chat history and start fresh.
  void clearHistory() {
    _messages.clear();
    if (_model != null) {
      _chat = _model!.startChat();
    }
  }
}
