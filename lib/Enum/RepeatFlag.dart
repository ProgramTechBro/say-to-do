enum RepeatFlag {
  Once,
  Daily,
  Weekly,
  Monthly,
}

RepeatFlag repeatFlagFromString(String value) {
  return RepeatFlag.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
    orElse: () => RepeatFlag.Once,
  );
}

String repeatFlagToString(RepeatFlag flag) {
  return flag.toString().split('.').last;
}
