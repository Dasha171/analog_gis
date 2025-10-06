import 'package:flutter/material.dart';

class RouteOptionsWidget extends StatefulWidget {
  const RouteOptionsWidget({super.key});

  @override
  State<RouteOptionsWidget> createState() => _RouteOptionsWidgetState();
}

class _RouteOptionsWidgetState extends State<RouteOptionsWidget> {
  bool _avoidTolls = false;
  bool _avoidHighways = false;
  bool _avoidFerries = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки маршрута',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Избегать платных дорог',
            value: _avoidTolls,
            onChanged: (value) {
              setState(() {
                _avoidTolls = value;
              });
            },
          ),
          _buildOptionTile(
            title: 'Избегать автомагистралей',
            value: _avoidHighways,
            onChanged: (value) {
              setState(() {
                _avoidHighways = value;
              });
            },
          ),
          _buildOptionTile(
            title: 'Избегать паромов',
            value: _avoidFerries,
            onChanged: (value) {
              setState(() {
                _avoidFerries = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptionTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
