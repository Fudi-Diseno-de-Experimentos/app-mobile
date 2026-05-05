import 'package:flutter/material.dart';
class Register extends StatefulWidget {
const Register({super.key});
@override
RegisterState createState() => RegisterState();
}
class RegisterState extends State<Register> {
String textField1 = '';
String textField2 = '';
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
padding: const EdgeInsets.only( top: 61, left: 13, right: 13),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 36),
width: double.infinity,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
width: 24,
height: 24,
child: Image.network(
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/bf30vcwb_expires_30_days.png",
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
margin: const EdgeInsets.only( bottom: 48),
width: double.infinity,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
margin: const EdgeInsets.only( bottom: 30),
child: Text(
"Create your account",
style: TextStyle(
color: Color(0xFF273035),
fontSize: 21,
),
),
),
IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 42),
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
margin: const EdgeInsets.only( bottom: 18),
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
hintText: "Full name",
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
alignment: Alignment.center,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFFCDD4D7),
),
margin: const EdgeInsets.only( bottom: 18),
width: double.infinity,
child: TextField(
style: TextStyle(
color: Color(0xFF5D737E),
fontSize: 16,
),
onChanged: (value) {
setState(() { textField2 = value; });
},
decoration: InputDecoration(
hintText: "Enter email",
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
margin: const EdgeInsets.only( bottom: 18),
width: double.infinity,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
"Enter password",
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
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/o42ac9pv_expires_30_days.png",
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
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(6),
color: Color(0xFFCDD4D7),
),
padding: const EdgeInsets.only( top: 8, bottom: 8, left: 17, right: 17),
width: double.infinity,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
"Confirm password",
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
"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/zjuxg831_expires_30_days.png",
fit: BoxFit.fill,
)
)
),
]
),
),
),
]
),
),
),
IntrinsicWidth(
child: IntrinsicHeight(
child: Container(
margin: const EdgeInsets.only( bottom: 74, left: 24, right: 24),
width: double.infinity,
child: Row(
children: [
Container(
decoration: BoxDecoration(
border: Border.all(
color: Color(0xFFCBCBCB),
width: 1,
),
borderRadius: BorderRadius.circular(3),
),
margin: const EdgeInsets.only( right: 6),
width: 12,
height: 12,
child: SizedBox(),
),
Text(
"I agree to the Terms and Conditions and the Privacy Policy",
style: TextStyle(
color: Color(0xFF1A1A1A),
fontSize: 10,
),
),
]
),
),
),
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
margin: const EdgeInsets.only( bottom: 10),
width: double.infinity,
child: Column(
children: [
Text(
"Sign up",
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
"Already have an account?",
style: TextStyle(
color: Color(0xFF1A1A1A),
fontSize: 12,
),
),
),
Text(
"Sign in",
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