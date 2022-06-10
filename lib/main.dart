import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payme_flutter_sdk/payme_flutter_sdk.dart';
import 'package:payme_flutter_sdk_example/row_input.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

const APP_TOKEN_DEFAULT_SANDBOX =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6OTUsImlhdCI6MTY1MTczMjM0Nn0.TFsg9wizgtWa7EbGzrjC2Gn55TScsJzKGjfeN78bhlg";
const PUBLIC_KEY_DEFAULT_SANDBOX = "-----BEGIN PUBLIC KEY-----\n" +
    "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAId28RoBckMTTPqVCC3c1f+fH+BbdVvv\n" +
    "wDkSf+0zmaUlCFyQpassU3+8CvM6QbeYSYGWp1YIwGqg2wTF94zT4eECAwEAAQ==\n" +
    "-----END PUBLIC KEY-----";
const SECRET_KEY_DEFAULT_SANDBOX = "b5d8cf6c30d9cb4a861036bdde44c137";
const PRIVATE_KEY_DEFAULT_SANDBOX = "-----BEGIN RSA PRIVATE KEY-----\n" +
    "MIIBOwIBAAJBAMEKxNcErAKSzmWcps6HVScLctpdDkBiygA3Pif9rk8BoSU0BYAs\n" +
    "G5pW8yRmhCwVMRQq+VhJNZq+MejueSBICz8CAwEAAQJBALfa29K1/mWNEMqyQiSd\n" +
    "vDotqzvSOQqVjDJcavSHpgZTrQM+YzWwMKAHXLABYCY4K0t01AjXPPMYBueJtFeA\n" +
    "i3ECIQDpb6Fp0yGgulR9LHVcrmEQ4ZTADLEASg+0bxVjv9vkWwIhANOzlw9zDMRr\n" +
    "i/5bwttz/YBgY/nMj7YIEy/v4htmllntAiA5jLDRoyCOPIGp3nUMpVz+yW5froFQ\n" +
    "nfGjPSOb1OgEMwIhAI4FhyvoJQKIm8wyRxDuSXycLbXhU+/sjuKz7V4wfmEpAiBb\n" +
    "PmELTX6BquyCs9jUzoPxDWKQSQGvVUwcWXtpnYxSvQ==\n" +
    "-----END RSA PRIVATE KEY-----";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _accountStatus = 'Not Connected. Please LOGIN first';
  bool _connected = false;
  PaymeFlutterSdkPayCode _payCode = PaymeFlutterSdkPayCode.PAYME;
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sdkArgs = PaymeFlutterSdkConfig(
      appToken: APP_TOKEN_DEFAULT_SANDBOX,
      publicKey: PUBLIC_KEY_DEFAULT_SANDBOX,
      privateKey: PRIVATE_KEY_DEFAULT_SANDBOX,
      secretKey: SECRET_KEY_DEFAULT_SANDBOX,
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PayME SDK Example'),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_accountStatus),
                ),
                _buildTextField('UserId', _userIdController),
                _buildTextField('Phone', _phoneController),
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildButton(() async {
                        try {
                          final status = await PaymeFlutterSdk.login(
                              _userIdController.text,
                              _phoneController.text,
                              sdkArgs);
                          setState(() {
                            _accountStatus = status.toString();
                            _connected = true;
                          });
                        } catch (e) {
                          setState(() {
                            _connected = false;
                          });
                        }
                      }, 'Login'),
                      _buildButton(() async {
                        try {
                          await PaymeFlutterSdk.logout();
                          setState(() {
                            _accountStatus =
                                'Not Connected. Please LOGIN first';
                            _connected = false;
                          });
                        } catch (e) {
                          setState(() {
                            _connected = false;
                          });
                        }
                      }, 'Logout'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDropdown(),
                      _buildButton(() {
                        PaymeFlutterSdk.openWallet();
                      }, 'Open Wallet'),
                      _buildButton(() async {
                        try {
                          await PaymeFlutterSdk.openKYC();
                        } on PlatformException catch (e) {
                          showAlertDialog(context,
                              content: e.message ?? 'Có lỗi xảy ra');
                        }
                      }, 'Open KYC'),
                      RowFunction(
                        placeholder: 'Deposit amount',
                        onPress: (value) async {
                          if (value.isEmpty) {
                            return;
                          }
                          try {
                            final response = await PaymeFlutterSdk.deposit(
                                amount: int.parse(value));
                          } on PlatformException catch (e) {
                            showAlertDialog(context,
                                title: 'Lỗi',
                                content: e.message ?? 'Có lỗi xảy ra');
                          }
                        },
                        text: 'deposit',
                      ),
                      RowFunction(
                        placeholder: 'Withdraw amount',
                        onPress: (value) async {
                          if (value.isEmpty) {
                            return;
                          }
                          try {
                            final response = await PaymeFlutterSdk.withdraw(
                                amount: int.parse(value));
                          } on PlatformException catch (e) {
                            showAlertDialog(context,
                                title: 'Lỗi',
                                content: e.message ?? 'Có lỗi xảy ra');
                          }
                        },
                        text: 'withdraw',
                      ),
                      RowFunction(
                        placeholder: 'Transfer amount',
                        onPress: (value) async {
                          if (value.isEmpty) {
                            return;
                          }
                          try {
                            final response = await PaymeFlutterSdk.transfer(
                                amount: int.parse(value));
                          } on PlatformException catch (e) {
                            showAlertDialog(context,
                                title: 'Lỗi',
                                content: e.message ?? 'Có lỗi xảy ra');
                          }
                        },
                        text: 'transfer',
                      ),
                      RowFunction(
                        placeholder: 'Pay amount',
                        onPress: (value) async {
                          if (value.isEmpty) {
                            return;
                          }
                          try {
                            final response = await PaymeFlutterSdk.pay(
                                int.parse(value),
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                _payCode);
                          } on PlatformException catch (e) {
                            if (e.code != 'USER_CANCELLED') {
                              showAlertDialog(context,
                                  title: 'Lỗi',
                                  content: e.message ?? 'Có lỗi xảy ra');
                            }
                          }
                        },
                        text: 'pay',
                      ),
                      _buildButton(() async {
                        try {
                          final response =
                              await PaymeFlutterSdk.getSupportedServices();
                          showAlertDialog(context,
                              title: 'Lấy danh sách thành công',
                              content: response.toString());
                        } on PlatformException catch (e) {
                          showAlertDialog(context,
                              content: e.message ?? 'Có lỗi xảy ra');
                        }
                      }, 'Lấy danh sách dịch vụ'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(VoidCallback onPress, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
      child: Container(
          height: 40,
          child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ))),
            onPressed: onPress,
            child: Text(text),
          )),
    );
  }

  Widget _buildTextField(String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26.0),
          ),
          hintText: placeholder,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Text('Select PAYCODE: '),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(30)),
            child: DropdownButton<PaymeFlutterSdkPayCode>(
              value: _payCode,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 42,
              underline: SizedBox(),
              items: [
                PaymeFlutterSdkPayCode.PAYME,
                PaymeFlutterSdkPayCode.ATM,
                PaymeFlutterSdkPayCode.CREDIT,
                PaymeFlutterSdkPayCode.MANUAL_BANK,
                PaymeFlutterSdkPayCode.VN_PAY,
                PaymeFlutterSdkPayCode.MOMO,
                PaymeFlutterSdkPayCode.VIET_QR,
              ].map((PaymeFlutterSdkPayCode value) {
                return DropdownMenuItem(
                  value: value,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Text(value.toString().split('.').last),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _payCode = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context,
      {String title = 'Thông báo', String content = 'Có lỗi xảy ra'}) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("Đã hiểu"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
