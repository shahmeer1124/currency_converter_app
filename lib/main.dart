import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CurrencyConverter());
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  String fromCurrency = "USD";
  String toCurrency = "EUR";
  double amount = 0.0;
  double result = 0.0;
  var start_date = '2022-01-01';
  var end_date = '2022-01-31';
  Map<String, double> exchangeRates = {};

  Future<void> getExchangeRates(String start_date, String end_date) async {
    String url =
        "https://api.apilayer.com/currency_data/change?start_date=$start_date&end_date=$end_date";
    Map<String, String> headers = {
      "apikey": "9kRHp4F3a7MwAgQobb9ddKlnkfYveKJi"
    };
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData["success"] == true && responseData["change"] == true) {
        setState(() {
          exchangeRates.clear();
          responseData["quotes"].forEach((currencyCode, data) {
            exchangeRates[currencyCode.substring(3)] =
                data["end_rate"].toDouble();
          });
        });
        print("Exchange rates: $exchangeRates");
      } else {
        print("Error: ${responseData["error"]["info"]}");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    String start_date = "2022-01-01";
    String end_date = "2022-01-31";
    getExchangeRates(start_date, end_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[400],
      appBar: AppBar(
        title: Text("Currency Converter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter amount to convert',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                  value: fromCurrency,
                  onChanged: (value) {
                    setState(() {
                      fromCurrency = value!;
                      getExchangeRates(start_date, end_date);
                    });
                  },
                  items: exchangeRates.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  style: TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                ),
                Icon(Icons.arrow_forward),
                DropdownButton<String>(
                  value: toCurrency,
                  onChanged: (value) {
                    setState(() {
                      toCurrency = value!;
                    });
                  },
                  items: exchangeRates.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  result = amount *
                      exchangeRates[toCurrency]! /
                      exchangeRates[fromCurrency]!;
                });
              },
              child: Text("Convert"),
            ),
            SizedBox(height: 20.0),
            Text("$amount $fromCurrency = $result $toCurrency"),
          ],
        ),
      ),
    );
  }
}
