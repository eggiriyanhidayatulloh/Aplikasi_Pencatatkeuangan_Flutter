import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Expense_Recorder/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // default nilai nya yaitu pengeluaran
  bool isExpense = true;
  // manggil database
  final AppDb database = AppDb();
  // controller input category
  TextEditingController categoryNameController = TextEditingController();
  // buat variable untuk type, 2=> pengeluaran
  int type = 2;

  // future insert dummy, input sesuai type nya
  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
    print('Masuk :' + row.toString());
  }

  // manggil fungsi getallkategory dari database (fungsi untuk insert)
  Future<List<category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  // buat fungsi untuk update
  Future update(int categoryId, String newName) async {
    return await database.updateCategroyRepo(categoryId, newName);
  }

  // buat fungsi dioalog add
  // tambahin parameter untuk edit, jika category nya tidak null maka akan nampilin category yang di edt
  void OpenDialog(category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // isi nya dibungkus singlechil agar tdk pnjng kebawah
            content: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      (isExpense) ? "Add Expanse" : "Add Income",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: categoryNameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: "Input Name"),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // bikin kondisi untuk update karegori
                          if (category == null) {
                            insert(
                                categoryNameController.text, isExpense ? 2 : 1);
                          } else {
                            update(category.id, categoryNameController.text);
                          }

                          // jika di save pop up nya ilang
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                          setState(() {});
                          // agar saat save name category dialog langsung bersih
                          categoryNameController.clear();
                        },
                        child: Text("Save"))
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // tombol active
              Switch(
                value: isExpense,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                    // Jika value nya 2 maka true, jika tidak false, untuk jadi parameter di future builder
                    type = value ? 2 : 1;
                  });
                },
                inactiveTrackColor: Colors.indigo[400],
                inactiveThumbColor: Colors.indigo,
                activeColor: Colors.red,
              ),
              IconButton(
                  onPressed: () {
                    // parameter nya null, biar ga ke menu edits
                    OpenDialog(null);
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ),
        FutureBuilder<List<category>>(
            future: getAllCategory(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    // untuk lisrtview categorynya
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                leading: (isExpense)
                                    ? Icon(Icons.upload, color: Colors.red)
                                    : Icon(Icons.download,
                                        color: Colors.indigo),
                                // agar saat di switch categorynya sesuai type
                                title: Text(snapshot.data![index].name),
                                trailing: Row(
                                  // agar posisi icon nya kepinggir
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          // delete
                                          database.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete)),
                                    IconButton(
                                        onPressed: () {
                                          // ngambil isi category yg akan diedit
                                          OpenDialog(snapshot.data![index]);
                                        },
                                        icon: Icon(Icons.edit))
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: Text("Data Tidak Ada"),
                    );
                  }
                } else {
                  return Center(
                    child: Text("No has Data"),
                  );
                }
              }
            }),
      ],
    ));
  }
}
