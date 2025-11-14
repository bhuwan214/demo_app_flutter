import 'package:flutter/material.dart';
import "dart:convert";
import 'package:http/http.dart' as http;


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); 

  bool _isLoading =false;

Future<void> _signupUser() async{

  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final mobile =_mobileController.text.trim();
  final password = _passwordController.text.trim();


  if(firstName.isEmpty || lastName.isEmpty || mobile.isEmpty||password.isEmpty){
    ScaffoldMessenger.of(context,).showSnackBar(const SnackBar(content:Text("Please enter all fields")));
    return;
  }

  setState(()=>_isLoading=true);

  const String url =
  "https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/register";

  try{
    final response =await http.post(Uri.parse(url),
    headers:{
      'Accept':'application/json',
      'Content-Type':'application/json',
    },
    body:jsonEncode({
      'first_name':firstName,
      'last_name':lastName,
      'mobile':mobile,  
      'password':password,
      'device_token':
                    'eEcu_X4XMkspr7fsv6IlrL:APA91bFcUP60TtS7Nf-WMBhpxhFbXLuzYvVmo6e7Iczct6oNH3XUFrM1k0J2sr5pkQ-RGbF7Sssf7JWY5CZnEiApFnq5lvj4MajFpKZ7aqr32Jzxn1IR6W_zoJO7-vl-163q3xnEQ9QS',

    }),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}'); 

    // Check if response is JSON before decoding
    if (response.body.trim().startsWith('<')) {
      // Response is HTML, not JSON
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server error. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final data = jsonDecode(response.body);

    if(response.statusCode ==200||
        response.statusCode ==201||
        response.statusCode ==203){

          final isSuccess =data['status']==true || data['success']== true;

          if(isSuccess){
            ScaffoldMessenger.of(context,).showSnackBar(
              SnackBar(
                content:Text('Registeration Successful! Please verify OTP sent to $mobile'),
                backgroundColor: Colors.green,
             duration:const Duration(seconds:3),
              ),
            );
            
            // Navigator.push(context,
            // MaterialPageRoute(
            //   builder:(context)=> OTPVerificationPage(
            //     mobileNumber:mobile,
            //     firstName:firstName,
            //     lastName:lastName,
            //   ),
            // ),
            // );

          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content:Text(data['message']?? 'Registration failed'),
              backgroundColor: Colors.red,
              )
            );
          }
        } else if (response.statusCode ==409){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:Text(data['message'] ?? 'Mobile number already registered'),
            backgroundColor: Colors.red,
            duration:const Duration (seconds:4),
          )
          );
        } else{

          String errorMessage;
         switch (response.statusCode){
          case 400:
           errorMessage ="Invalid request. Please check your input.";
           break;
           case 500: 
           errorMessage ="Server error. Please try again later.";
           break;
           default:
           errorMessage = data['message'] ?? "Sign up failed. Please try again.";
         }

         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content :Text(errorMessage),backgroundColor: Colors.red), 
    );
  }
}catch(e){
  print('Signup Error: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Network error. Please check your connection.'),
      backgroundColor: Colors.red,
    ),
  );
} finally {
  setState(()=> _isLoading =false);
}
}

@override

void dispose(){
  _firstNameController.dispose();
  _lastNameController.dispose();  
  _mobileController.dispose();
  _passwordController.dispose();
  super.dispose();
}


   @override
  Widget build(BuildContext context) {
      return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/backdrop.png'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Handle image loading error silently
            debugPrint('Failed to load background image: $exception');
          },
        ),
      ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 130),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 250),
                        Form(
                          key: _formKey,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'First Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'Last Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'Mobile Number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade100,
                                    filled: true,
                                    hintText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color(0xff4c505b),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : IconButton(
                                              color: Colors.white,
                                              onPressed: _signupUser,
                                              icon: const Icon(
                                                  Icons.arrow_forward),
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: Color(0xff4c505b),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Dark mode toggle button - placed last to be on top
                // SafeArea(
                //   child: Align(
                //     alignment: Alignment.topRight,
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Material(
                //         color: Colors.black.withOpacity(0.3),
                //         borderRadius: BorderRadius.circular(30),
                //         child: IconButton(
                //           onPressed: () {
                //             isDarkNotifier.value = !isDarkNotifier.value;
                //             print('Dark mode toggled: ${isDarkNoti`ier.value}');
                //           },
                //           icon: Icon(
                //             isDark ? Icons.light_mode : Icons.dark_mode,
                //             color: Colors.white,
                //             size: 26,
                //           ),
                //           tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      }}