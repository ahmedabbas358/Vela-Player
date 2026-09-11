enum NetworkType { wifi, cellular, offline }

enum ThermalState { normal, elevated, critical }

/// Telemetry and hardware state listener for battery, thermal, network, and audio focus.
class DeviceEventManager {
  static final DeviceEventManager instance = DeviceEventManager._();
  DeviceEventManager._();

  NetworkType _network = NetworkType.wifi;
  ThermalState _thermal = ThermalState.normal;
  double _batteryLevel = 0.85; // 85%

  NetworkType get network => _network;
  ThermalState get thermal => _thermal;
  double get batteryLevel => _batteryLevel;

  bool get isHeavyProcessingSafe => _batteryLevel > 0.15 && _thermal != ThermalState.critical;

  bool get allowCloudAIUpload {
    if (_network == NetworkType.offline) return false;
    // Default safe policy: avoid huge cellular AI uploads unless user explicitly allows
    if (_network == NetworkType.cellular) return false;
    return true;
  }

  void updateNetwork(NetworkType type) {
    _network = type;
  }

  void updateBattery(double level) {
    _batteryLevel = level;
  }

  void updateThermal(ThermalState state) {
    _thermal = state;
  }
}
