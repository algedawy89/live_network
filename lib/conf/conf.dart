enum Conf {
  segment('segment'),
  videoDev('video_dev'),
  audioDev('audio_dev'),
  resolution('resluation'),
  group('group');

  final String value;

  const Conf(this.value);

  String getValue() {
    return value;
  }
}
