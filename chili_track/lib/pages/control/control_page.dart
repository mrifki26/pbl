import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control")),
      body: Center(
        child: Switch(
          value: isOn,
          onChanged: (val) async {
            final messenger = ScaffoldMessenger.of(context);

            try {
              if (val) {
                await ApiService.wateringOn();
              } else {
                await ApiService.wateringOff();
              }
              if (!mounted) return;
              setState(() => isOn = val);
            } catch (_) {
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text("Gagal mengubah status pompa")),
              );
            }
          },
        ),
      ),
    );
  }
}
