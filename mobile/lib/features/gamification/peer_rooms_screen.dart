import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class PeerRoomsScreen extends ConsumerStatefulWidget {
  const PeerRoomsScreen({super.key});
  @override
  ConsumerState<PeerRoomsScreen> createState() => _PeerRoomsScreenState();
}

class _PeerRoomsScreenState extends ConsumerState<PeerRoomsScreen> {
  final _gamificationService = GamificationService();
  List<PeerRoom> _rooms = [];
  List<Map<String, dynamic>> _currentRoomMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;
    try {
      _rooms = await _gamificationService.getPeerRooms(auth.user!.id);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Rooms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) => _buildRoomCard(_rooms[index]),
                  ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'join',
            onPressed: _showJoinDialog,
            child: const Icon(Icons.login),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'create',
            onPressed: _showCreateDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: AppColors.textHintOf(context)),
          const SizedBox(height: 16),
          Text('No peer rooms yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondaryOf(context))),
          const SizedBox(height: 8),
          Text('Create or join a room to compete with peers', style: TextStyle(color: AppColors.textHintOf(context))),
        ],
      ),
    );
  }

  Widget _buildRoomCard(PeerRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.group, color: AppColors.primary),
        ),
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Code: ${room.code}', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context))),
            Text('${room.examCategory} | Max ${room.maxMembers}', style: TextStyle(fontSize: 12, color: AppColors.textHintOf(context))),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textHintOf(context)),
        onTap: () => _showRoomDetail(room),
      ),
    );
  }

  void _showRoomDetail(PeerRoom room) async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<Map<String, dynamic>>>(
          future: _gamificationService.getPeerRoomMembers(room.id),
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.borderOf(context), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                      Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Code: ${room.code}', style: TextStyle(color: AppColors.textSecondaryOf(context))),
                          ],
                        ),
                      ),
                      if (room.createdBy == auth.user?.id)
                        TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Room?'),
                                content: Text('Delete "${room.name}"? All members will be removed.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await _gamificationService.deletePeerRoom(auth.user!.id, room.id);
                              Navigator.pop(context);
                              _loadData();
                            }
                          },
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        )
                      else
                        TextButton(
                          onPressed: () async {
                            await _gamificationService.leavePeerRoom(auth.user!.id, room.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _loadData();
                            }
                          },
                          child: const Text('Leave', style: TextStyle(color: AppColors.error)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('${members.length} Members', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final user = member['users'] as Map<String, dynamic>?;
                        final role = member['role'] ?? 'member';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              ((user?['full_name'] as String?) ?? 'U')[0].toUpperCase(),
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          title: Text(user?['full_name'] ?? 'Unknown'),
                          subtitle: Text(user?['email'] ?? ''),
                          trailing: role == 'admin'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Admin', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showJoinDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Room'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: 'Enter room code'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = ref.read(authProvider);
              if (auth.user == null || codeController.text.isEmpty) return;
              try {
                final room = await _gamificationService.joinPeerRoom(
                  auth.user!.id, codeController.text.toUpperCase(),
                );
                Navigator.pop(context);
                if (room != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Joined ${room.name}!')),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room not found')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Room name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = ref.read(authProvider);
              if (auth.user == null || nameController.text.isEmpty) return;
              await _gamificationService.createPeerRoom(
                userId: auth.user!.id,
                name: nameController.text,
                examCategory: auth.profile?.examCategory ?? 'General',
              );
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
