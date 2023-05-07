import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:Expense_Recorder/pages/category_page.dart';
import 'package:Expense_Recorder/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Expense_Recorder/pages/transaction_page.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  // bikin menu bar jadi widget
  late List<Widget> _children;
  // default pagenya yaitu index 0 yaitu menu home
  late int currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    updateView(0, DateTime.now());
    super.initState();
  }

  // function update view
  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }
      currentIndex = index;
      _children = [
        HomePage(
          selectedDate: selectedDate,
        ),
        CategoryPage()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // library calender
        // dikasih kondisi
        appBar: (currentIndex == 0)
            ? CalendarAppBar(
                accent: Colors.indigo,
                backButton: false,
                locale: 'id',
                onDateChanged: (value) {
                  setState(() {
                    print('SELECTED DATE !' + value.toString());
                    selectedDate = value;
                    updateView(0, selectedDate);
                  });
                },
                firstDate: DateTime.now().subtract(Duration(days: 140)),
                lastDate: DateTime.now(),
              )
            : PreferredSize(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 16),
                    child: Text(
                      "Categories",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(100)),
        // tombol tambah
        floatingActionButton:
            // tanda tambah di bungkus widget visibleity aga munculnya hanya di page home
            Visibility(
          visible: (currentIndex == 0) ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              // navigasi ke page addtransaction
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => TransactionPage(),
              ))
                  .then((value) {
                setState(() {});
              });
            },
            backgroundColor: Colors.indigo,
            child: Icon(Icons.add),
          ),
        ),
        // memanggil chil default di body utama
        body: _children[currentIndex],
        // agar menu tambah ditengah
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // menubar yg dibawah
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  updateView(0, DateTime.now());
                },
                icon: Icon(Icons.home),
              ),
              SizedBox(
                width: 20,
              ),
              IconButton(
                  onPressed: () {
                    updateView(1, null);
                  },
                  icon: Icon(Icons.list))
            ],
          ),
        ));
  }
}
