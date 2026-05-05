import 'package:flutter/material.dart';
class LogIn extends StatefulWidget {
const LogIn({super.key});
@override
LogInState createState() => LogInState();
}
class LogInState extends State<LogIn> {
String textField1 = '';
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
padding: const EdgeInsets.only( top: 116, left: 16, right: 16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 48),
width: double.infinity,
child: Column(
children: [
IntrinsicWidth(
child: IntrinsicHeight(
child: Container(
padding: const EdgeInsets.only( bottom: 5),
margin: const EdgeInsets.only( bottom: 97),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 65,
height: 65,
child: Image.network(
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/eecjshwa_expires_30_days.png",
fit: BoxFit.fill,
)
),
Container(
margin: const EdgeInsets.only( left: 63),
child: Text(
"Centralis",
style: TextStyle(
color: Color(0xFF000000),
fontSize: 36,
),
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
crossAxisAlignment: CrossAxisAlignment.start,
children: [
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 34),
width: double.infinity,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
IntrinsicHeight(
child: Container(
alignment: Alignment.center,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFFCDD4D7),
),
margin: const EdgeInsets.only( bottom: 8),
width: double.infinity,
child: TextField(
style: TextStyle(
color: Color(0xFF5D737E),
fontSize: 16,
),
onChanged: (value) {
setState(() { textField1 = value; });
},
decoration: InputDecoration(
hintText: "Enter your email",
isDense: true,
contentPadding: const EdgeInsets.only( top: 12, bottom: 12, left: 17, right: 17),
border: InputBorder.none,
focusedBorder: InputBorder.none,
filled: false,
),
),
),
),
IntrinsicHeight(
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFFCDD4D7),
),
padding: const EdgeInsets.only( top: 8, bottom: 8, left: 17, right: 17),
margin: const EdgeInsets.only( bottom: 8),
width: double.infinity,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
"Password",
style: TextStyle(
color: Color(0xFF5D737E),
fontSize: 16,
),
),
Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(7),
),
width: 32,
height: 32,
child: ClipRRect(
borderRadius: BorderRadius.circular(7),
child: Image.network(
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/obqlmpj8_expires_30_days.png",
fit: BoxFit.fill,
)
)
),
]
),
),
),
IntrinsicHeight(
child: Container(
width: double.infinity,
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Container(
margin: const EdgeInsets.only( right: 1),
child: Text(
"Forgot password?",
style: TextStyle(
color: Color(0xFF007AFF),
fontSize: 12,
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
IntrinsicHeight(
child: Container(
width: double.infinity,
child: Column(
children: [
InkWell(
onTap: () { print('Pressed'); },
child: IntrinsicHeight(
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFF556973),
),
padding: const EdgeInsets.symmetric(vertical: 8),
margin: const EdgeInsets.only( bottom: 11),
width: double.infinity,
child: Column(
children: [
Text(
"Sign in",
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
IntrinsicWidth(
child: IntrinsicHeight(
child: Row(
children: [
Container(
margin: const EdgeInsets.only( right: 11),
child: Text(
"Dont have an account?",
style: TextStyle(
color: Color(0xFF1A1A1A),
fontSize: 12,
),
),
),
Text(
"Sign up now",
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