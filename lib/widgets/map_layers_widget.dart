import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_layers_provider.dart';
import '../providers/theme_provider.dart';
import '../models/map_layer_model.dart';

class MapLayersWidget extends StatelessWidget {
  const MapLayersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapLayersProvider, ThemeProvider>(
      builder: (context, layersProvider, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок и кнопка закрытия
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Слои карты',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: themeProvider.textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: themeProvider.textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Список слоев
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: layersProvider.layers.map((layer) {
                    return _buildLayerItem(context, layersProvider, layer, themeProvider);
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerItem(BuildContext context, MapLayersProvider provider, MapLayer layer, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            provider.toggleLayer(layer.id);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка слоя
                Icon(
                  provider.getLayerIcon(layer.icon),
                  color: themeProvider.textColor,
                  size: 24,
                ),
                
                const SizedBox(width: 16),
                
                // Название слоя
                Expanded(
                  child: Text(
                    layer.name,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Переключатель
                _buildToggleSwitch(layer.isEnabled, themeProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isEnabled, ThemeProvider themeProvider) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isEnabled ? const Color(0xFF0C79FE) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isEnabled ? const Color(0xFF0C79FE) : themeProvider.textColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: isEnabled
          ? const Icon(
              Icons.check,
              color: Color(0xFF212121),
              size: 16,
            )
          : null,
    );
  }
}

// Функция для показа модального окна слоев
void showMapLayersModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: const MapLayersWidget(),
      ),
    ),
  );
}
