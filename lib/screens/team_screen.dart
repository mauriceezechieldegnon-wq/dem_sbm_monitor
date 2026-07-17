import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../services/team_service.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GESTION D\'ÉQUIPE',
            style: AppTheme.displayFont(fontSize: 18)),
        backgroundColor: AppColors.navy,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        hintText: "Email de l'invité", filled: true),
                  ),
                ),
                // Dans la partie _buildInviteSection de ton team_screen.dart :
                IconButton(
                  icon: Icon(LucideIcons.userPlus, color: AppColors.cyan),
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isNotEmpty && email.contains('@')) {
                      TeamService.instance.inviteMember(email);
                      _emailController.clear();
                      // Optionnel : Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invitation envoyée")),
                      );
                    } else {
                      // Afficher une erreur si le champ est vide
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Veuillez entrer un email valide")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: TeamService.instance.teamStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final members = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final m = members[index];
                    return ListTile(
                      title: Text(m['email']),
                      trailing: Switch(
                        value: m['is_active'],
                        onChanged: (val) =>
                            TeamService.instance.toggleMemberStatus(m.id, val),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
