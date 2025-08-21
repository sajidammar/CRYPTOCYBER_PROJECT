import 'package:flutter/material.dart';
// import 'testing.dart';

// Widget sidebarbutton(IconData icon, String label) {
//   return TextButton.icon(
//     onPressed: () {},
//     style: TextButton.styleFrom(
//       padding: const EdgeInsets.all(16),
//       foregroundColor: Colors.white,
//       alignment: Alignment.centerLeft,
//     ),
//     icon: Icon(icon, color: Colors.tealAccent),
//     label: Text(label),
//   );
// }

// ignore: must_be_immutable
class sidebarbutton extends StatelessWidget {
  sidebarbutton(IconData icon, String label, {super.key}) {
    icon = icon;
    this.label = label;
  }

  IconData? icon;
  String? label;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton.icon(
      onPressed: () {},
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

// Widget buildMainArea({bool showDrawerButton = true}) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('CryptoCyber'),
//       leading:
//           showDrawerButton
//               ? Builder(
//                 builder:
//                     (context) => IconButton(
//                       icon: const Icon(Icons.menu),
//                       onPressed: () => Scaffold.of(context).openDrawer(),
//                     ),
//               )
//               : null,
//     ),
//     drawer:
//         showDrawerButton
//             ? Drawer(
//               child: Container(
//                 width: 220,
//                 color: const Color(0xFF101622),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     DrawerHeader(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(
//                             Icons.lock_outline,
//                             size: 48,
//                             color: Colors.tealAccent,
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'CrypTool Menu',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     sidebarbutton(Icons.vpn_key, 'Encryption'),
//                     sidebarbutton(Icons.lock_open, 'Decryption'),
//                     sidebarbutton(Icons.analytics, 'Analysis'),
//                     sidebarbutton(Icons.settings, 'Settings'),
//                   ],
//                 ),
//               ),
//             )
//             : null,
//     body: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Expanded(flex: 2, child: buildInputPanel()),
//           const SizedBox(height: 16),
//           Expanded(flex: 1, child: BuildOutputPanel()),
//         ],
//       ),
//     ),
//   );
// }
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
                      sidebarbutton(Icons.vpn_key, 'Encryption'),
                      sidebarbutton(Icons.lock_open, 'Decryption'),
                      sidebarbutton(Icons.analytics, 'Analysis'),
                      sidebarbutton(Icons.settings, 'Settings'),
                    ],
                  ),
                ),
              )
              : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(flex: 2, child: buildInputPanel()),
            const SizedBox(height: 16),
            Expanded(flex: 1, child: BuildOutputPanel()),
          ],
        ),
      ),
    );
  }
}

class buildInputPanel extends StatelessWidget {
  const buildInputPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: const Color(0xFF141B2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your text here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Key...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<String>(
                  value: 'AES-256',
                  dropdownColor: const Color(0xFF101622),
                  items: const [
                    DropdownMenuItem(value: 'AES-256', child: Text('AES-256')),
                    DropdownMenuItem(value: 'RSA', child: Text('RSA')),
                    DropdownMenuItem(
                      value: 'ChaCha20',
                      child: Text('ChaCha20'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Widget _buildInputPanel() {
//   return Card(
//     color: const Color(0xFF141B2D),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Input',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             maxLines: 3,
//             decoration: const InputDecoration(
//               hintText: 'Enter your text here...',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   decoration: const InputDecoration(
//                     hintText: 'Key...',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.auto_fix_high),
//                 label: const Text('Generate'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               DropdownButton<String>(
//                 value: 'AES-256',
//                 dropdownColor: const Color(0xFF101622),
//                 items: const [
//                   DropdownMenuItem(value: 'AES-256', child: Text('AES-256')),
//                   DropdownMenuItem(value: 'RSA', child: Text('RSA')),
//                   DropdownMenuItem(value: 'ChaCha20', child: Text('ChaCha20')),
//                 ],
//                 onChanged: (value) {},
//               ),
//               const SizedBox(width: 16),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.play_arrow),
//                 label: const Text('Run'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
class BuildOutputPanel extends StatelessWidget {
  const BuildOutputPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: const Color(0xFF141B2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Output',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.show_chart, color: Colors.tealAccent),
                  onPressed: () {},
                  tooltip: 'Show Analysis Graphs',
                ),
              ],
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Result will appear here...',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _buildOutputPanel() {
//   return Card(
//     color: const Color(0xFF141B2D),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text(
//                 'Output',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.show_chart, color: Colors.tealAccent),
//                 onPressed: () {},
//                 tooltip: 'Show Analysis Graphs',
//               ),
//             ],
//           ),
//           const Divider(),
//           const Expanded(
//             child: SingleChildScrollView(
//               child: Text(
//                 'Result will appear here...',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
