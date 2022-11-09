import 'package:projeto/main.dart';
import 'package:projeto/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Account extends StatefulWidget {
  Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;
  bool uploading = false;
  double total = 0;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    refs = (await storage.ref('images').listAll()).items;
    for (var ref in refs) {
      final arquivo = await ref.getDownloadURL();
      arquivos.add(arquivo);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hi, ${Provider.of<GroupState>(context).selfPlayer.name}!",
          style: TextStyle(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthService>().logout()),
        backgroundColor: Colors.black26,
      ),
      backgroundColor: Colors.black12,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: arquivos.isEmpty
                  ? const Center(child: Text('Não há imagens ainda.'))
                  : ListView.builder(
                      itemBuilder: (BuildContext context, index) {
                        return ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 40,
                            child: Image.network(
                              arquivos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(refs[index].fullPath),
                        );
                      },
                      itemCount: arquivos.length,
                    ),
            ),
    );
  }
}
