import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/session_provider.dart';

class SidePanel extends ConsumerStatefulWidget {
  const SidePanel({super.key});

  @override
  ConsumerState<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends ConsumerState<SidePanel> {
  late TextEditingController _notesController;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _isSaved = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controller with existing notes if empty (to avoid overwriting user typing)
    final notes = ref.read(sessionProvider).notes;
    if (_notesController.text.isEmpty && notes.isNotEmpty) {
      _notesController.text = notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNotesChanged(String value) {
    setState(() {
      _isSaved = false;
      _isSaving = false;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _saveNotes();
    });
  }

  void _saveNotes() {
    setState(() {
      _isSaving = true;
    });

    // Save to provider
    ref.read(sessionProvider.notifier).updateNotes(_notesController.text);

    // Mock save delay for UI feedback
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    if (!state.isSidePanelOpen) return const SizedBox.shrink();

    return Container(
      width: 300,
      color: AppColors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.activeSidePanelTab == 0 ? 'Notes' : 'Chat',
                  style: AppTypography.lightTextTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: notifier.toggleSidePanel,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: state.activeSidePanelTab == 0
                ? _buildNotesTab()
                : _buildChatTab(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              onChanged: _onNotesChanged,
              decoration: const InputDecoration(
                hintText: 'Type your notes here...',
                border: InputBorder.none,
              ),
              style: AppTypography.lightTextTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_isSaving) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saving...',
                  style: AppTypography.lightTextTheme.bodySmall?.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ] else if (_isSaved) ...[
                const Icon(
                  IconlyLight.tickSquare,
                  size: 16,
                  color: AppColors.medicalGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-saved',
                  style: AppTypography.lightTextTheme.bodySmall?.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(SessionState state, SessionNotifier notifier) {
    final TextEditingController messageController = TextEditingController();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final msg = state.messages[index];
              return Align(
                alignment: msg.isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.medicalBlue
                        : AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isMe)
                        Text(
                          msg.senderName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGray,
                          ),
                        ),
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isMe ? Colors.white : AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceGray,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      notifier.sendMessage(value);
                      messageController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(IconlyBold.send, color: AppColors.medicalBlue),
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    notifier.sendMessage(messageController.text);
                    messageController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
