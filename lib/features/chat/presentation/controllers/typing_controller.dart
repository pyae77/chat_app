import 'dart:async';

import 'package:flutter_chat_app/features/chat/presentation/providers/chat_room_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/update_typing_status_usecase.dart';

class TypingController {
  final UpdateTypingStatusUseCase _useCase;
  final String chatRoomId;
  final String userId;

  Timer? _typingTimer;
  bool _isTyping = false;

  TypingController({
    required UpdateTypingStatusUseCase useCase,
    required this.chatRoomId,
    required this.userId,
  }) : _useCase = useCase;

  void handleTyping(String text) {
    _typingTimer?.cancel();

    final hasText = text.trim().isNotEmpty;

    if (hasText && !_isTyping) {
      _isTyping = true;
      _updateStatus(true);
    }

    if (!hasText) {
      stopTyping();
      return;
    }

    _typingTimer = Timer(
      const Duration(seconds: 2),
      stopTyping,
    );
  }

  Future<void> stopTyping() async {
    _typingTimer?.cancel();

    if (!_isTyping) return;

    _isTyping = false;
    await _updateStatus(false);
  }

  Future<void> _updateStatus(bool isTyping) async {
    final result = await _useCase(
      chatRoomId: chatRoomId,
      userId: userId,
      isTyping: isTyping,
    );

    result.fold(
      ifLeft: (failure) {
        print('Typing status error: ${failure.message}');
      },
      ifRight: (_) {},
    );
  }

  void dispose() {
    _typingTimer?.cancel();

    if (_isTyping) {
      _isTyping = false;
      _updateStatus(false);
    }
  }
}



final typingControllerProvider = Provider.autoDispose.family<
    TypingController,
    (String, String)>((ref, params) {

  final controller = TypingController(
    useCase: ref.watch(updateTypingStatusUseCaseProvider),
    chatRoomId: params.$1,
    userId: params.$2,
  );

  ref.onDispose(controller.dispose);

  return controller;
});