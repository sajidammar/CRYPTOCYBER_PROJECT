import 'package:cryptocyber/screens/analysis_screens/mainanalysisscreen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable, camel_case_types
class sidebarbutton extends StatelessWidget {
  sidebarbutton(IconData icon, String label,Widget screenname, {super.key}) {
    this.icon = icon;
    this.label = label;
    this.screenname = screenname;
  }

  IconData? icon;
  String? label;
  Widget? screenname;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (cont)=>screenname!));
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        foregroundColor: Colors.white,
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon, color: Colors.tealAccent),
      label: Text(label!),
    );
  }

  // (IconData icon, String label)
}

// ignore: must_be_immutable
class BuildMainArea extends StatelessWidget {
  BuildMainArea({super.key, bool showDrawerButtonn = true}) {
    this.showDrawerButton = showDrawerButtonn;
  }
  bool? showDrawerButton;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoCyber'),
        leading:
            showDrawerButton!
                ? Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                )
                : null,
      ),
      drawer:
          showDrawerButton!
              ? Drawer(
                child: Container(
                  width: 220,
                  color: const Color(0xFF101622),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DrawerHeader(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Colors.tealAccent,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'CryptoCyber Menu',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      sidebarbutton(Icons.vpn_key, 'Encryption',Placeholder()),
                      sidebarbutton(Icons.lock_open, 'Decryption',Placeholder()),
                      sidebarbutton(Icons.analytics, 'Analysis',MainAnalysisScreen()),
                      sidebarbutton(Icons.settings, 'Settings',Placeholder()),
                    ],
                  ),
                ),
              )
              : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(flex: 1, child: LogoPanel()),
            const SizedBox(height: 16),
            Expanded(flex: 1, child: DetailsPanel()),
          ],
        ),
      ),
    );
  }
}

class LogoPanel extends StatelessWidget {
  const LogoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: const Color.fromARGB(255, 33, 35, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          fit: StackFit.expand,
          children: [Image.asset('images/mainscreen.jpg')],
        ),
      ),
    );
  }
}

class DetailsPanel extends StatelessWidget {
  const DetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: const Color.fromARGB(255, 33, 35, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Dtails CryptoCyber',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.tealAccent),
                  onPressed: () {},
                  tooltip: 'Show The Service In This Program',
                ),
              ],
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 50,
                  children: [
                    SizedBox(width: double.infinity),
                    Icon(size: 100, Icons.enhanced_encryption),
                    Icon(size: 100, Icons.vpn_key),
                    Icon(size: 100, Icons.analytics_outlined),
                    Icon(size: 100, Icons.no_encryption_gmailerrorred),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
