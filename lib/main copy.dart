// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:hijri/hijri_calendar.dart';
// import 'prayer_times.dart'; // Ensure this file contains the PrayerTimesFetcher and PrayerTime class
// import 'weather_service.dart'; // Ensure this file contains the WeatherService class
// import 'get_next_prayer.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Prayer Times & Weather',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const PrayerTimesWeatherScreen(),
//     );
//   }
// }

// class PrayerTimesWeatherScreen extends StatefulWidget {
//   const PrayerTimesWeatherScreen({super.key});

//   @override
//   _PrayerTimesWeatherScreenState createState() =>
//       _PrayerTimesWeatherScreenState();
// }

// class _PrayerTimesWeatherScreenState extends State<PrayerTimesWeatherScreen> {
//   List<PrayerTime>? prayerTimes;
//   bool isLoadingPrayerTimes = true;
//   double? temperature;
//   bool isLoadingWeather = true;
//   late Timer _timer;
//   final String apiKey =
//       'd10bd5d398ebda3ba67463f8e85785e5'; // Your OpenWeatherMap API key
//   final String cityName = 'Mostaganem';
//   String gregorianDate = '';
//   String hijriDate = '';
//   String currentTime = '';
//   Timer? timer; // Declare a Timer
//   late bool isGregorianVisible;

//   // Arabic prayer names
//   final List<String> arabicPrayerNames = [
//     'الفجر', // Fajr
//     'الشروق', // Sunrise
//     'الظهر', // Dhuhr
//     'العصر', // Asr
//     'المغرب', // Maghrib
//     'العشاء' // Isha
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchPrayerTimes();
//     fetchWeather();
//     displayDate(); // Initial display of the date and time
//     timer = Timer.periodic(const Duration(seconds: 1),
//         (Timer t) => displayDate()); // Update every second
//     isGregorianVisible = true;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       setState(() {
//         isGregorianVisible = !isGregorianVisible; // Toggle visibility
//       });
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel(); // Cancel the timer when disposing the widget
//     super.dispose();
//   }

//   Future<void> fetchPrayerTimes() async {
//     const url =
//         "https://www.urdupoint.com/islam/mostaganem-prayer-timings.html";
//     final fetcher = PrayerTimesFetcher();

//     try {
//       final times = await fetcher.getPrayerTimes(url);
//       setState(() {
//         prayerTimes = times;
//         isLoadingPrayerTimes = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoadingPrayerTimes = false;
//       });
//       if (kDebugMode) {
//         print("Error fetching prayer times: $e");
//       }
//     }
//   }

//   Future<void> fetchWeather() async {
//     final weatherService = WeatherService(apiKey);
//     final temp = await weatherService.getWeather(cityName);
//     setState(() {
//       temperature = temp;
//       isLoadingWeather = false;
//     });
//   }

//   void displayDate() {
//     final now = DateTime.now();
//     final hijri = HijriCalendar.fromDate(now);

//     // Format Gregorian Date
//     gregorianDate = '${now.day} ${getArabicMonth(now.month)} ${now.year}';
//     // Format Hijri Date
//     hijriDate =
//         '${hijri.hDay} ${getArabicHijriMonth(hijri.hMonth)} ${hijri.hYear}';
//     // Format Time
//     currentTime =
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

//     // Refresh the UI
//     setState(() {});
//   }

//   String getArabicMonth(int month) {
//     const arabicMonths = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر'
//     ];
//     return arabicMonths[month - 1];
//   }

//   String getArabicHijriMonth(int month) {
//     const arabicHijriMonths = [
//       'محرم',
//       'صفر',
//       'ربيع الأول',
//       'ربيع الآخر',
//       'جمادى الأولى',
//       'جمادى الآخرة',
//       'رجب',
//       'شعبان',
//       'رمضان',
//       'شوال',
//       'ذو القعدة',
//       'ذو الحجة'
//     ];
//     return arabicHijriMonths[month - 1];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: const Color(0xFFF4E4BC),
//           appBar: AppBar(
//             title: const Center(
//               child: Text(
//                 'مواقيت الصلاة',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             backgroundColor: Colors.brown[700],
//           ),
//           body: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8F0E3),
//                   border: Border.all(
//                     color: const Color(0xFF8B4513), // Hex color for brown
//                     width: 3,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(5),
//                               border: Border.all(
//                                   color: const Color(0xFF8B0000), width: 1),
//                             ),
//                             child: ListTile(
//                               title: Text(
//                                 isGregorianVisible ? gregorianDate : hijriDate,
//                                 style: const TextStyle(
//                                     color: Color(0xFFFF4444),
//                                     fontFamily: 'Digital-7',
//                                     fontSize: 28,
//                                     height: 0,
//                                     letterSpacing: 2),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(5),
//                               border: Border.all(
//                                   color: const Color(0xFF8B0000), width: 1),
//                             ),
//                             child: ListTile(
//                               title: Text(
//                                 currentTime,
//                                 style: const TextStyle(
//                                   color: Color(0xFFFF4444),
//                                   fontFamily: 'Digital-7',
//                                   fontSize: 40,
//                                   height: 0,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: isLoadingPrayerTimes
//                           ? const Center(child: CircularProgressIndicator())
//                           : prayerTimes != null && prayerTimes!.isNotEmpty
//                               ? Padding(
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: ListView.builder(
//                                     itemCount: prayerTimes!.length,
//                                     itemBuilder: (context, index) {
//                                       final prayerTime = prayerTimes![index];
//                                       return Padding(
//                                         padding: const EdgeInsets.only(
//                                             top: 3, bottom: 10),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           mainAxisSize: MainAxisSize.max,
//                                           children: [
//                                             Expanded(
//                                               flex: 3,
//                                               child: Container(
//                                                 width: double.maxFinite,
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 13,
//                                                         horizontal: 12),
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       const Color(0xFFF8F0E3),
//                                                   border: Border.all(
//                                                     color: const Color(
//                                                         0xFF8B4513), // Hex color for brown
//                                                     width: 3,
//                                                   ),
//                                                   borderRadius:
//                                                       BorderRadius.circular(15),
//                                                 ),
//                                                 child: Text(
//                                                   arabicPrayerNames[index],
//                                                   style: const TextStyle(
//                                                     color: Color(0xFF4A4A4A),
//                                                     fontSize: 20,
//                                                     height: 0,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(width: 10),
//                                             Expanded(
//                                               flex: 7,
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 8,
//                                                         horizontal: 12),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.black,
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                   border: Border.all(
//                                                       color: const Color(
//                                                           0xFF8B0000),
//                                                       width: 1),
//                                                 ),
//                                                 child: Text(
//                                                   prayerTime.time24h,
//                                                   style: const TextStyle(
//                                                     color: Color(0xFFFF4444),
//                                                     fontFamily: 'Digital-7',
//                                                     fontSize: 38,
//                                                     height: 0,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : const Center(
//                                   child: Text('No prayer times available')),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Row(
//                         children: [
//                           isLoadingWeather
//                               ? const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Center(
//                                       child: CircularProgressIndicator()),
//                                 )
//                               : temperature != null
//                                   ? Expanded(
//                                       flex: 2,
//                                       child: Container(
//                                         width: double.maxFinite,
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 6),
//                                         decoration: BoxDecoration(
//                                           color: Colors.black,
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                           border: Border.all(
//                                               color: const Color(0xFF8B0000),
//                                               width: 1),
//                                         ),
//                                         child: Text(
//                                           '${temperature!.toInt().toString()}°C',
//                                           style: const TextStyle(
//                                             color: Color(0xFFFF4444),
//                                             fontFamily: 'Digital-7',
//                                             fontSize: 32,
//                                           ),
//                                           textDirection: TextDirection.ltr,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     )
//                                   : const Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Center(
//                                           child: Text(
//                                               'Could not fetch weather data')),
//                                     ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             flex: 4,
//                             child: Container(
//                               width: double.maxFinite,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.circular(5),
//                                 border: Border.all(
//                                     color: const Color(0xFF8B0000), width: 1),
//                               ),
//                               child: Text(
//                                 prayerTimes != null
//                                     ? getNextPrayer(prayerTimes!)
//                                     : '-- --',
//                                 style: const TextStyle(
//                                   color: Color(0xFFFF4444),
//                                   fontFamily: 'Digital-7',
//                                   fontSize: 28,
//                                   height: 0,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
