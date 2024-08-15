enum SettingsEnum {
  manualBpm('MANUAL_BPM', 'Manually Set BPM'),
  themeMode('THEME_MODE', 'Theme'),
  requestPermission('REQUEST_PERMISSION', 'Request Permission'),
  ;

  final String key;
  final String label;
  const SettingsEnum(this.key, this.label);
}
