import 'package:flutter/material.dart';
class Verification extends StatefulWidget {
const Verification({super.key});
@override
VerificationState createState() => VerificationState();
}
class VerificationState extends State<Verification> {
@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Container(
constraints: const BoxConstraints.expand(),
color: Color(0xFFFFFFFF),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: IntrinsicHeight(
child: Container(
color: Color(0xFFEFF1F2),
width: double.infinity,
height: double.infinity,
child: SingleChildScrollView(
padding: const EdgeInsets.only( top: 61),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 36, left: 13, right: 13),
width: double.infinity,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
width: 24,
height: 24,
child: Image.network(
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/c6pwr1a3_expires_30_days.png",
fit: BoxFit.fill,
)
),
IntrinsicWidth(
child: IntrinsicHeight(
child: Container(
padding: const EdgeInsets.only( bottom: 1),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Centralis",
style: TextStyle(
color: Color(0xFF000000),
fontSize: 36,
),
),
]
),
),
),
),
Container(
width: 24,
height: 24,
child: SizedBox(),
),
]
),
),
),
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 48, left: 16, right: 16),
width: double.infinity,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
margin: const EdgeInsets.only( bottom: 23),
child: Text(
"Almost there",
style: TextStyle(
color: Color(0xFF273035),
fontSize: 21,
),
),
),
Container(
margin: const EdgeInsets.only( bottom: 25, left: 24, right: 24),
width: double.infinity,
child: Text(
"Please enter the 5-digit code sent to your email for verification.",
style: TextStyle(
color: Color(0xFF252525),
fontSize: 12,
),
textAlign: TextAlign.center,
),
),
Container(
margin: const EdgeInsets.only( bottom: 21, left: 9, right: 9),
height: 72,
width: double.infinity,
child: Image.network(
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/dcxicenu_expires_30_days.png",
fit: BoxFit.fill,
)
),
InkWell(
onTap: () { print('Pressed'); },
child: IntrinsicHeight(
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFF556973),
),
padding: const EdgeInsets.symmetric(vertical: 8),
margin: const EdgeInsets.only( bottom: 12, left: 1, right: 1),
width: double.infinity,
child: Column(
children: [
Text(
"Verify",
style: TextStyle(
color: Color(0xFFEFF1F2),
fontSize: 16,
),
),
]
),
),
),
),
IntrinsicHeight(
child: Container(
width: double.infinity,
child: Column(
children: [
IntrinsicWidth(
child: IntrinsicHeight(
child: Row(
children: [
Container(
margin: const EdgeInsets.only( right: 11),
child: Text(
"I didn’t receive a code",
style: TextStyle(
color: Color(0xFF1A1A1A),
fontSize: 12,
),
),
),
Text(
"Resend",
style: TextStyle(
color: Color(0xFF007AFF),
fontSize: 12,
),
),
]
),
),
),
]
),
),
),
]
),
),
),
],
)
),
),
),
),
],
),
),
),
);
}
}