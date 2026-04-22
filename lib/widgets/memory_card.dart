import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../services/memory_service.dart';

class MemoryCard extends StatelessWidget {
  final String capsuleId;
  final DocumentSnapshot memory;
  final Widget content;

  MemoryCard({
    Key? key,
    required this.capsuleId,
    required this.memory,
    required this.content,
  }) : super(key: key);

  final MemoryService _memoryService = MemoryService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) async {
              Navigator.pop(context);
              await _memoryService.toggleReaction(
                capsuleId: capsuleId,
                memoryId: memory.id,
                emoji: emoji.emoji,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = memory.data() as Map<String, dynamic>;
    
    String dateStr = '';
    if (data['createdAt'] != null) {
      DateTime dt = (data['createdAt'] as Timestamp).toDate();
      dateStr = DateFormat.yMMMd().add_jm().format(dt);
    }
    
    Map<String, dynamic> reactions = {};
    if (data.containsKey('reactions')) {
      reactions = Map<String, dynamic>.from(data['reactions']);
    }
    
    bool isOwner = data['createdBy'] == _currentUserId;

    List<Widget> reactionWidgets = reactions.values.map((v) {
      return Tooltip(
        message: v['name'],
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(v['emoji'], style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context),
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            content,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "by ${data['createdByName']}",
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                        if (dateStr.isNotEmpty)
                          Text(
                            dateStr,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  if (reactionWidgets.isNotEmpty)
                    Wrap(
                      children: reactionWidgets,
                    ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Delete Memory"),
                            content: const Text("Are you sure you want to delete this memory?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _memoryService.deleteMemory(
                            capsuleId: capsuleId,
                            memoryId: memory.id,
                            fileUrl: data['fileURL'] ?? '',
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
