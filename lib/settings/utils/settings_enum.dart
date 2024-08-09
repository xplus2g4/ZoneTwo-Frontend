enum SettingsEnum {
  defaultBpm('DEFAULT_BPM', 'Default BPM'),
  themeMode('THEME_MODE', 'Theme'),
  ;

  final String key;
  final String label;
  const SettingsEnum(this.key, this.label);
}
