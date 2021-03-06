// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UserSettings _$_$_UserSettingsFromJson(Map<String, dynamic> json) {
  return _$_UserSettings(
    pingSettings: json['pingSettings'] == null
        ? null
        : PingSettings.fromJson(json['pingSettings'] as Map<String, dynamic>),
    shareSettings: json['shareSettings'] == null
        ? null
        : ShareSettings.fromJson(json['shareSettings'] as Map<String, dynamic>),
    showSystemNotification: json['showSystemNotification'] as bool,
    restoreHost: json['restoreHost'] as bool,
    nightMode: json['nightMode'] as bool,
  );
}

Map<String, dynamic> _$_$_UserSettingsToJson(_$_UserSettings instance) =>
    <String, dynamic>{
      'pingSettings': instance.pingSettings?.toJson(),
      'shareSettings': instance.shareSettings?.toJson(),
      'showSystemNotification': instance.showSystemNotification,
      'restoreHost': instance.restoreHost,
      'nightMode': instance.nightMode,
    };

_$_ShareSettings _$_$_ShareSettingsFromJson(Map<String, dynamic> json) {
  return _$_ShareSettings(
    shareResults: json['shareResults'] as bool,
    attachLocation: json['attachLocation'] as bool,
  );
}

Map<String, dynamic> _$_$_ShareSettingsToJson(_$_ShareSettings instance) =>
    <String, dynamic>{
      'shareResults': instance.shareResults,
      'attachLocation': instance.attachLocation,
    };

_$_PingSettings _$_$_PingSettingsFromJson(Map<String, dynamic> json) {
  return _$_PingSettings(
    count: json['count'] as int,
    packetSize: json['packetSize'] as int,
    interval: json['interval'] as int,
    timeout: json['timeout'] as int,
  );
}

Map<String, dynamic> _$_$_PingSettingsToJson(_$_PingSettings instance) =>
    <String, dynamic>{
      'count': instance.count,
      'packetSize': instance.packetSize,
      'interval': instance.interval,
      'timeout': instance.timeout,
    };
