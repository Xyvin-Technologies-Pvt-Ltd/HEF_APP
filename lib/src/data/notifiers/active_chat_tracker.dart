/// Tracks which conversation is currently open so foreground
/// chat notifications can be suppressed for that chat.
class ActiveChatTracker {
  ActiveChatTracker._();
  static final ActiveChatTracker instance = ActiveChatTracker._();

  String? _activeChatId;
  bool _isGroup = false;

  String? get activeChatId => _activeChatId;
  bool get isGroup => _isGroup;

  void setActive({required String chatId, bool isGroup = false}) {
    _activeChatId = chatId;
    _isGroup = isGroup;
  }

  void clear({String? chatId}) {
    if (chatId == null || _activeChatId == chatId) {
      _activeChatId = null;
      _isGroup = false;
    }
  }

  bool isViewingChat(String? chatId, {bool? isGroup}) {
    if (chatId == null || chatId.isEmpty || _activeChatId == null) {
      return false;
    }
    if (isGroup != null && isGroup != _isGroup) {
      return false;
    }
    return _activeChatId == chatId;
  }
}
