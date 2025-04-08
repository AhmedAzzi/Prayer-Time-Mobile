import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';

class PrayerTime {
  final String name;
  final String time12h;
  final String time24h;

  PrayerTime(this.name, this.time12h, this.time24h);
}

class PrayerTimesFetcher {
  Future<List<PrayerTime>> getPrayerTimes(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final prayerTimesTable = document.querySelector('.ptm_table tbody tr');

      if (prayerTimesTable != null) {
        final prayerTimes = <PrayerTime>[];

        for (var label in [
          "Fajr",
          "Sunrise",
          "Dhuhr",
          "Asr",
          "Maghrib",
          "Isha"
        ]) {
          final time12h = prayerTimesTable
                  .querySelector('td[data-label="$label"]')
                  ?.text
                  .trim() ??
              '';
          final time24h = _convertTo24h(time12h);
          prayerTimes.add(PrayerTime(label, time12h, time24h));
        }
        return prayerTimes;
      } else {
        throw Exception("Prayer times table not found");
      }
    } else {
      throw Exception("Failed to load prayer times");
    }
  }

  String _convertTo24h(String timeStr) {
    try {
      // Parse the input time string
      DateTime dateTime = DateFormat('h:mm a').parse(timeStr);

      // Format the parsed DateTime to 24-hour format
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      // Handle parsing errors
      if (kDebugMode) {
        print('Error parsing time: $e');
      }
      return '';
    }
  }
}
