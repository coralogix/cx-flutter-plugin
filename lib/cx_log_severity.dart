enum CxLogSeverity {
  debug(1),
  verbose(2),
  info(3),
  warn(4),
  error(5),
  critical(6);

  final int value;
  const CxLogSeverity(this.value);

  static CxLogSeverity? fromValue(int value) {
    return CxLogSeverity.values.firstWhere(
      (severity) => severity.value == value
    );
  }
}