import 'package:Expense_Recorder/models/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpense = true;
  // dummy dropdown
  List<String> list = ['makan', 'jajan', 'transportasi'];
  // buat untuk nilai default dropdown nya
  late String dropDownValue = list.first;
  // buat controler untuk nilai date
  TextEditingController dateController = TextEditingController();
  // controller untuk detail
  TextEditingController detailController = TextEditingController();
  // controller untuk amount
  TextEditingController amountController = TextEditingController();
  // buat untuk variable database
  final AppDb database = AppDb();
  // buat varialbe untuk milih category
  category? selectedCategory;
  // variable untuk switch tipe nya
  late int type;

  // function untuk insert transaction
  Future insert(
      int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    // insert to database
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            transaction_date: date,
            amount: amount,
            createdAt: now,
            updatedAt: now));
    print("apa woii" + row.toString());
  }

  // panggil function untuk kategori kata di category_page
  Future<List<category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  // state untuk type
  @override
  void initState() {
    // TODO: implement initState
    type = 2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      // pake singlechild agar tdk ada error kuning
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: isExpense,
                  onChanged: (bool value) {
                    setState(() {
                      isExpense = value;
                      // jika tipe nya isExpen maka 2 jika tidak 1
                      type = (isExpense) ? 2 : 1;
                      // jika di switch select category nya kembali ke default
                      selectedCategory = null;
                    });
                  },
                  inactiveTrackColor: Colors.indigo[600],
                  inactiveThumbColor: Colors.indigo,
                  activeColor: Colors.red,
                ),
                Text(
                  isExpense ? 'Expense' : 'Income',
                  style: GoogleFonts.montserrat(fontSize: 15),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Amount",
                    hintText: "Input Nominal"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Category',
                style: GoogleFonts.montserrat(fontSize: 15),
              ),
            ),
            // bikin function untuk category agar langsung query ke database
            FutureBuilder<List<category>>(
                // parameternya type
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    // jika ada datanya
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        // jika pertamakali buka select category otomatis ke isi yg pertama
                        selectedCategory = snapshot.data!.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<category>(
                              // yang tampil data pertama
                              value: (selectedCategory == null)
                                  ? snapshot.data!.first
                                  : selectedCategory,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_downward),
                              // memparshing data category nya jadi item
                              // ketika value di rubah maka yang tampil ikut berubah
                              items: snapshot.data!.map((category item) {
                                return DropdownMenuItem<category>(
                                  // mengambil nilai item
                                  value: item,
                                  // yang tampil nya yaitu name
                                  child: Text(item.name),
                                );
                              }).toList(),
                              onChanged: (category? value) {
                                setState(() {
                                  // pemilihan category jadi value
                                  selectedCategory = value;
                                });
                              }),
                        );
                      } else {
                        return Center(
                          child: Text("No Has Data !"),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("No Has Data !"),
                      );
                    }
                  }
                }),
            // Widget dropdown

            SizedBox(
              height: 20,
            ),
            Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: detailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Detail",
                    hintText: "Input Detail"),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(labelText: "Enter Date"),
                // menampilkan tanggal dari intl  yg di pubspecyaml
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099));

                  if (pickedDate != null) {
                    // nilai tgl jadi string dngn variable formattedDate
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    dateController.text = formattedDate;
                  }
                },
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      insert(
                          int.parse(amountController.text),
                          DateTime.parse(dateController.text),
                          detailController.text,
                          selectedCategory!.id);
                      // ketika kesave kembali ke page awal
                      Navigator.pop(context, true);
                    },
                    child: Text("Save")))
          ],
        )),
      ),
    );
  }
}
