import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              // 阅读设置
              _buildSectionHeader('阅读设置'),

              // 字体大小
              ListTile(
                title: const Text('字体大小'),
                subtitle: Text('${settings.fontSize.toInt()}sp'),
                trailing: SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setFontSize(value);
                          },
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),

              // 行高
              ListTile(
                title: const Text('行高'),
                subtitle: Text('${settings.lineHeight.toStringAsFixed(1)}倍'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: settings.lineHeight,
                    min: 1.2,
                    max: 2.0,
                    divisions: 8,
                    onChanged: (value) {
                      settings.setLineHeight(value);
                    },
                  ),
                ),
              ),

              // 页面边距
              ListTile(
                title: const Text('页面边距'),
                subtitle: Text('${settings.pagePadding.toInt()}px'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: settings.pagePadding,
                    min: 8,
                    max: 32,
                    divisions: 6,
                    onChanged: (value) {
                      settings.setPagePadding(value);
                    },
                  ),
                ),
              ),

              const Divider(),

              // 主题设置
              _buildSectionHeader('主题设置'),

              // 夜间模式
              SwitchListTile(
                title: const Text('夜间模式'),
                subtitle: const Text('开启深色主题'),
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.setDarkMode(value);
                },
              ),

              // 阅读主题选择
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '阅读主题',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: ReadTheme.values.map((theme) {
                        final isSelected = settings.currentTheme == theme;
                        return GestureDetector(
                          onTap: () {
                            settings.setTheme(theme);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                theme.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 字体设置
              _buildSectionHeader('字体设置'),
              ListTile(
                title: const Text('字体'),
                subtitle: Text(settings.fontFamily),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showFontPicker(context, settings);
                },
              ),

              const Divider(),

              // 关于
              _buildSectionHeader('关于'),
              const ListTile(
                title: Text('版本'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('重置所有设置'),
                textColor: Colors.red,
                onTap: () {
                  _showResetConfirm(context, settings);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context, SettingsProvider settings) {
    final fonts = [
      'Noto Serif SC',
      'Noto Sans SC',
      'ZCOOL XiaoWei',
      'Ma Shan Zheng',
      'Long Cang',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择字体',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...fonts.map((font) {
                return ListTile(
                  title: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                  trailing: settings.fontFamily == font
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    settings.setFontFamily(font);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirm(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认重置'),
          content: const Text('确定要重置所有设置吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                settings.resetToDefault();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('重置'),
            ),
          ],
        );
      },
    );
  }
}
