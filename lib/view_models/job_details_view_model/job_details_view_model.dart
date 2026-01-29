class JobDetailsViewModel {
  JobDetailsViewModel._init();
  static JobDetailsViewModel? _instance;
  static JobDetailsViewModel get instance {
    _instance ??= JobDetailsViewModel._init();
    return _instance!;
  }

  JobDetailsViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
