import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peer Rooms')),
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
          Icon(Icons.group_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No peer rooms yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Create or join a room to compete with peers', style: TextStyle(color: AppColors.textHint)),
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
            Text('Code: ${room.code}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${room.examCategory} | Max ${room.maxMembers}', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(room.code, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
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
