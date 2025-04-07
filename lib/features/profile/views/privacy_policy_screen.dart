import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for CLASSET',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last Updated: April 5, 2025',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'At CLASSET, operated by MELUHA TECHNOLOGIES PRIVATE LIMITED, we prioritize the privacy and security of our users. This Privacy Policy describes how we collect, use, share, and safeguard personal information when you access our services through the website, Android, or iOS applications. By using our services, you consent to the practices outlined in this policy.',
            ),
            SizedBox(height: 16),
            Text(
              'Registered Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'MELUHA TECHNOLOGIES PRIVATE LIMITED,\n'
              '8-3-228, Srinivasa Village Dhruva-1, Flat No.305,\n'
              'Yousufguda, Hyderabad, Andhra Pradesh, India - 500045',
            ),
            SizedBox(height: 16),
            Text(
              'Definitions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Personal Information: Any data that identifies or can be used to identify an individual.\n\n'
              'Service: The CLASSET platform, including the website and mobile applications.\n\n'
              'Users: Individuals or entities accessing and using our services.',
            ),
            SizedBox(height: 16),
            Text(
              'Information We Collect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Personal Information:\n'
              'Name, contact details (email address, phone number, residential address), and government-issued identification.\n\n'
              'Payment Information:\n'
              'Fee-related payment data provided during transactions.\n\n'
              'Usage Data:\n'
              'Automatically collected information, such as device details, IP address, browser type, and activity on the service.',
            ),
            SizedBox(height: 16),
            Text(
              'Purpose of Data Collection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We collect information to:\n'
              '• Provide and maintain the services you access.\n'
              '• Facilitate account registration and management.\n'
              '• Process payments securely.\n'
              '• Communicate service updates, notifications, and relevant information.\n'
              '• Provide insights and analytics to improve user experience.',
            ),
            SizedBox(height: 16),
            Text(
              'Data Sharing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We limit sharing of user data and do so only under the following circumstances:\n\n'
              '• With Service Partners: To operate and maintain essential service functionalities, such as payment processing and notifications.\n'
              '• For Legal Compliance: To comply with applicable laws, regulations, and valid requests by public authorities.\n'
              '• In Business Transactions: In the event of business transfers, such as mergers or acquisitions, with prior notice provided to users.',
            ),
            SizedBox(height: 16),
            Text(
              'Data Retention',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Personal information is retained only as long as necessary for providing services and meeting legal obligations. Usage data may be retained longer for improving security and service features.',
            ),
            SizedBox(height: 16),
            Text(
              'User  Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'You have the right to access, update, or delete your personal information. Requests can be made through your account settings or by contacting us directly. In certain cases, data may be retained to fulfill legal obligations.',
            ),
            SizedBox(height: 16),
            Text(
              'Data Security',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We adopt appropriate measures to protect your information, including:\n\n'
              '• Encryption of data to secure communication during transmission.\n'
              '• Controlled access to data, limited to authorized personnel only.',
            ),
            SizedBox(height: 16),
            Text(
              'Children’s Privacy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Our services are not intended for individuals under the age of 13. If you believe that a child has provided personal information without parental consent, please contact us so that we can take appropriate action.',
            ),
            SizedBox(height: 16),
            Text(
              'Use of Cookies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Cookies may be used to enhance service performance and understand user preferences. Users can manage cookie settings through their browser but may experience limited functionality.',
            ),
            SizedBox(height: 16),
            Text(
              'Policy Updates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'This Privacy Policy is reviewed periodically to reflect changes in practices and legal requirements. Users will be notified of any updates before they come into effect.',
            ),
            SizedBox(height: 16),
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'For any privacy-related concerns or questions, please contact:\n\n'
              'Email: support@classet.in',
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 MELUHA TECHNOLOGIES PRIVATE LIMITED. All rights reserved.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
