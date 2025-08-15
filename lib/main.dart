import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:audioplayers/audioplayers.dart';

import 'prayer_times.dart'; // Ensure this file contains the PrayerTimesFetcher and PrayerTime class
import 'weather_service.dart'; // Ensure this file contains the WeatherService class
import 'get_next_prayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prayer Times & Weather',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PrayerTimesWeatherScreen(),
    );
  }
}

class PrayerTimesWeatherScreen extends StatefulWidget {
  const PrayerTimesWeatherScreen({super.key});

  @override
  _PrayerTimesWeatherScreenState createState() =>
      _PrayerTimesWeatherScreenState();
}

class _PrayerTimesWeatherScreenState extends State<PrayerTimesWeatherScreen> {
  List<PrayerTime>? prayerTimes;
  bool isLoadingPrayerTimes = true;
  double? temperature;
  bool isLoadingWeather = true;
  late Timer _timer;
  final String apiKey =
      'openWeatherMapApi'; // Your OpenWeatherMap API key d10bd5d398ebda3ba67463f8e85785e5
  final String cityName = 'Mostaganem';
  String gregorianDate = '';
  String hijriDate = '';
  String currentTime = '';
  Timer? timer; // Declare a Timer
  late bool isGregorianVisible;
  late AudioPlayer audioPlayer; // Declare AudioPlayer
  bool hasPlayedAudio = false; // Control repeated playback
  List<String> arabicDays = [
    'الاثنين', // Monday
    'الثلاثاء', // Tuesday
    'الأربعاء', // Wednesday
    'الخميس', // Thursday
    'الجمعة', // Friday
    'السبت', // Saturday
    'الأحد' // Sunday
  ];
  // Arabic prayer names
  final List<String> arabicPrayerNames = [
    'الفجر', // Fajr
    'الشروق', // Sunrise
    'الظهر', // Dhuhr
    'العصر', // Asr
    'المغرب', // Maghrib
    'العشاء' // Isha
  ];

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
    fetchWeather();
    displayDate(); // Initial display of the date and time
    timer = Timer.periodic(const Duration(seconds: 1),
        (Timer t) => displayDate()); // Update every second
    isGregorianVisible = true;
    _startTimer();
    audioPlayer = AudioPlayer(); // Initialize AudioPlayer
  }

// Method to play audio
  void playAudio() async {
    if (!hasPlayedAudio) {
      await audioPlayer
          .play(AssetSource('assets/adan.mp3')); // Example local file
      setState(() {
        hasPlayedAudio = true; // Avoid repeated playback
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        isGregorianVisible = !isGregorianVisible;
      });

      // Check condition and play audio
      if (prayerTimes != null && getNextPrayer(prayerTimes!).length == 1) {
        playAudio();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when disposing the widget
    audioPlayer.dispose(); // Dispose the audio player

    super.dispose();
  }

  Future<void> fetchPrayerTimes() async {
    // const url =
    //     "https://www.urdupoint.com/islam/mostaganem-prayer-timings.html";

    const url = kIsWeb
        ? 'https://cors-anywhere.herokuapp.com/https://www.urdupoint.com/islam/mostaganem-prayer-timings.html'
        : 'https://www.urdupoint.com/islam/mostaganem-prayer-timings.html';

    final fetcher = PrayerTimesFetcher();

    try {
      final times = await fetcher.getPrayerTimes(url);
      setState(() {
        prayerTimes = times;
        isLoadingPrayerTimes = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPrayerTimes = false;
      });
      if (kDebugMode) {
        print("Error fetching prayer times: $e");
      }
    }
  }

  Future<void> fetchWeather() async {
    final weatherService = WeatherService(apiKey);
    final temp = await weatherService.getWeather(cityName);
    setState(() {
      temperature = temp;
      isLoadingWeather = false;
    });
  }

  void displayDate() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);

    // Format Gregorian Date
    gregorianDate = '${now.day} ${getArabicMonth(now.month)} ${now.year}';
    // Format Hijri Date
    hijriDate =
        '${hijri.hDay} ${getArabicHijriMonth(hijri.hMonth)} ${hijri.hYear}';
    // Format Time
    currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // Refresh the UI
    setState(() {});
  }

  String getArabicMonth(int month) {
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return arabicMonths[month - 1];
  }

  String getArabicHijriMonth(int month) {
    const arabicHijriMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة'
    ];
    return arabicHijriMonths[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4E4BC),
          appBar: AppBar(
            title: const Center(
              child: Text(
                'مواقيت الصلاة',
                style: TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.brown[700],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F0E3),
                  border: Border.all(
                    color: const Color(0xFF8B4513),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFF8B0000), width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  isGregorianVisible
                                      ? gregorianDate
                                      : hijriDate,
                                  style: const TextStyle(
                                      color: Color(0xFFFF4444),
                                      fontFamily: 'Digital-7',
                                      fontSize: 24,
                                      letterSpacing: 2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFF8B0000), width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  arabicDays[DateTime.now().weekday - 1],
                                  style: const TextStyle(
                                    color: Color(0xFFFF4444),
                                    fontFamily: 'Digital-7',
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFF8B0000), width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  currentTime,
                                  style: const TextStyle(
                                    color: Color(0xFFFF4444),
                                    fontFamily: 'Digital-7',
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: isLoadingPrayerTimes
                          ? const Center(child: CircularProgressIndicator())
                          : prayerTimes != null && prayerTimes!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListView.builder(
                                    itemCount: prayerTimes!.length,
                                    itemBuilder: (context, index) {
                                      final prayerTime = prayerTimes![index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF8F0E3),
                                                  border: Border.all(
                                                    color: const Color(
                                                        0xFF8B4513), // Hex color for brown
                                                    width: 3,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  arabicPrayerNames[index],
                                                  style: const TextStyle(
                                                    color: Color(0xFF4A4A4A),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFF8B0000),
                                                      width: 1),
                                                ),
                                                child: Text(
                                                  prayerTime.time24h,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFF4444),
                                                    fontFamily: 'Digital-7',
                                                    fontSize: 28,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Text('No prayer times available')),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            isLoadingWeather
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : temperature != null
                                    ? Expanded(
                                        flex: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: const Color(0xFF8B0000),
                                                width: 1),
                                          ),
                                          child: Text(
                                            '${temperature!.toInt().toString()}°C',
                                            style: const TextStyle(
                                              color: Color(0xFFFF4444),
                                              fontFamily: 'Digital-7',
                                              fontSize: 28,
                                            ),
                                            textDirection: TextDirection.ltr,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Text(
                                                'Could not fetch weather data')),
                                      ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F0E3),
                                    border: Border.all(
                                      color: const Color(
                                          0xFF8B4513), // Hex color for brown
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    prayerTimes != null
                                        ? '${getNextPrayer(prayerTimes!)[0]}'
                                        : '-- --',
                                    style: const TextStyle(
                                      color: Color(0xFF4A4A4A),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xFF8B0000), width: 1),
                                ),
                                child: Text(
                                  prayerTimes != null
                                      ? (getNextPrayer(prayerTimes!).length == 2
                                          ? getNextPrayer(prayerTimes!)[1]
                                          : 'الآن')
                                      : '-- --',
                                  style: const TextStyle(
                                    color: Color(0xFFFF4444),
                                    fontFamily: 'Digital-7',
                                    fontSize: 28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
