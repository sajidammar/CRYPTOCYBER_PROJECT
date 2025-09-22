import 'package:cryptocyber/screens/drowerscreen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CryptoCyberApp',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0b0f1a),
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.deepPurpleAccent,
        ),
      ),

      home: ResponsiveScreen(),
    );
  }
}

class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            children: [
              // _buildSidebar(),
              Expanded(child: BuildMainArea()),
            ],
          );
        } else {
          return BuildMainArea();
        }
      },
    );
  }
}

// class _buildSidebar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       body: Container(
//         width: 220,
//         color: const Color(0xFF101622),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DrawerHeader(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.lock_outline, size: 48, color: Colors.tealAccent),
//                   SizedBox(height: 8),
//                   Text(
//                     'CrypTool Menu',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             _sidebarButton(Icons.vpn_key, 'Encryption'),
//             _sidebarButton(Icons.lock_open, 'Decryption'),
//             _sidebarButton(Icons.analytics, 'Analysis'),
//             _sidebarButton(Icons.settings, 'Settings'),
//           ],
//         ),
//       ),
//     );
//   }
// }
