
enum CXInstrumentationType {
  mobileVitals('mobileVitals'),
  custom('custom'),
  errors('errors'),
  network('network'),
  userActions('userActions'),
  anr('anr'),
  lifeCycle('lifeCycle');

  final String value;
  const CXInstrumentationType(this.value);

  // Factory constructor to create an enum instance from a string value
  factory CXInstrumentationType.fromValue(String value) {
    return CXInstrumentationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid CXInstrumentationType value: $value'),
    );
  }
}