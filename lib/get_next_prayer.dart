import 'package:flutter_application_1/prayer_times.dart';
import 'package:intl/intl.dart';

List getNextPrayer(List<PrayerTime> prayerTimes) {
  final now = DateTime.now();
  DateFormat('HH:mm').format(now);

  final arabicNames = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء'
  };

  PrayerTime? nextPrayer;
  DateTime? nextTime;

  for (var prayer in prayerTimes) {
    if (prayer.name == 'Sunrise') continue; // Skip Sunrise

    final prayerTime = DateFormat('HH:mm').parse(prayer.time24h);
    final prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      prayerTime.hour,
      prayerTime.minute,
    );

    if (prayerDateTime.isAfter(now)) {
      if (nextTime == null || prayerDateTime.isBefore(nextTime)) {
        nextTime = prayerDateTime;
        nextPrayer = prayer;
      }
    }
  }

  if (nextPrayer == null) {
    // If no next prayer found, it means we've passed Isha, so next prayer is tomorrow's Fajr
    nextPrayer = prayerTimes.firstWhere((p) => p.name == 'Fajr');
    final fajrTime = DateFormat('HH:mm').parse(nextPrayer.time24h);
    nextTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      fajrTime.hour,
      fajrTime.minute,
    );
  }

  if (nextTime != null) {
    // final remaining = nextTime.difference(now);
    // final hours = remaining.inHours;
    // final minutes = remaining.inMinutes % 60;
    // final seconds = remaining.inSeconds % 60;

    if (true) {
      return ['${arabicNames[nextPrayer.name]}'];
    }
  }

  return ['-- --'];
}
