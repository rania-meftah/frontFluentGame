import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey,
      ),
      drawer:
          MediaQuery.of(context).size.width < 600 ? const AdminDrawer() : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600) const AdminDrawer(),
          const Expanded(child: AdminContent()),
        ],
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text("Menu Admin", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Gérer utilisateurs"),
            onTap: () {
              // TODO: navigation ou logique
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Gérer langues"),
            onTap: () {
              // TODO: navigation ou logique
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Déconnexion"),
            onTap: () {
              // TODO: logout + redirection
            },
          ),
        ],
      ),
    );
  }
}

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Bienvenue Admin 👋",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text("Voici les données clés et statistiques de l'application :"),
          // Ajoute ici des statistiques, graphiques, etc.
        ],
      ),
    );
  }
}
