
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/data_entry_controller.dart';
import 'data_entry_screen.dart';

class SavedRecordsScreen extends StatefulWidget {
  const SavedRecordsScreen({super.key});

  @override
  State<SavedRecordsScreen> createState() =>
      _SavedRecordsScreenState();
}

class _SavedRecordsScreenState
    extends State<SavedRecordsScreen> {
  // =========================================================
  // DATA
  // =========================================================

  List<Map<String, dynamic>> records = [];

  List<Map<String, dynamic>>
  filteredRecords = [];

  // =========================================================
  // SEARCH
  // =========================================================

  final TextEditingController searchController =
  TextEditingController();



  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    loadRecords();

    searchController.addListener(
      searchRecords,
    );
  }

  // =========================================================
  // LOAD RECORDS
  // =========================================================

  Future<void> loadRecords() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? data =
      prefs.getString(
        'user_records',
      );

      if (data == null ||
          data.isEmpty) {
        if (!mounted) return;

        setState(() {
          records = [];
          filteredRecords = [];
        });

        return;
      }

      final dynamic decoded =
      jsonDecode(data);

      if (decoded is List) {
        final List<Map<String, dynamic>>
        loadedRecords =
        decoded
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList();

        if (!mounted) return;

        setState(() {
          records = loadedRecords;
          filteredRecords =
              List.from(loadedRecords);
        });
      }
    } catch (e) {
      debugPrint(
        'LOAD RECORDS ERROR: $e',
      );
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void searchRecords() {
    final String query =
    searchController.text
        .trim()
        .toLowerCase();

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        filteredRecords =
            List.from(records);
      } else {
        filteredRecords =
            records.where((record) {
              final String name =
                  record['name']
                      ?.toString()
                      .toLowerCase() ??
                      '';

              final String profession =
                  record['profession']
                      ?.toString()
                      .toLowerCase() ??
                      '';

              final String age =
                  record['age']
                      ?.toString()
                      .toLowerCase() ??
                      '';

              final String gender =
                  record['gender']
                      ?.toString()
                      .toLowerCase() ??
                      '';

              final String language =
                  record['language']
                      ?.toString()
                      .toLowerCase() ??
                      '';

              return name.contains(query) ||
                  profession.contains(query) ||
                  age.contains(query) ||
                  gender.contains(query) ||
                  language.contains(query);
            }).toList();
      }
    });
  }

  // =========================================================
  // EDIT RECORD
  // =========================================================

  void editRecord(
      Map<String, dynamic> record,
      ) {
    try {
      DataEntryController controller;

      // IMPORTANT:
      // Existing controller ko use karo.
      if (Get.isRegistered<
          DataEntryController>()) {
        controller =
            Get.find<DataEntryController>();
      } else {
        controller =
            Get.put(DataEntryController());
      }

      // Selected record ko controller me load karo
      controller.loadRecordForEdit(
        record,
      );

      // Data entry screen open
      Get.to(
            () => DataEntryScreen(),
      )?.then((_) {
        // Update ke baad list refresh
        loadRecords();
      });
    } catch (e) {
      debugPrint(
        'EDIT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to open record for editing',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // =========================================================
  // ADD NEW RECORD
  // =========================================================

  void addNewRecord() {
    // Agar controller already registered hai,
    // to form clear karo.
    if (Get.isRegistered<
        DataEntryController>()) {
      final DataEntryController controller =
      Get.find<DataEntryController>();

      controller.clearForm();
    }

    Get.to(
          () => DataEntryScreen(),
    )?.then((_) {
      loadRecords();
    });
  }

  // =========================================================
  // DELETE CONFIRMATION
  // =========================================================

  void confirmDelete(
      Map<String, dynamic> record,
      ) {
    final String name =
        record['name']?.toString() ??
            'this record';

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Record',
        ),
        content: Text(
          'Are you sure you want to delete $name?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
            ),
          ),

          TextButton(
            onPressed: () async {
              Get.back();

              await deleteRecord(
                record['id']?.toString() ??
                    '',
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DELETE RECORD
  // =========================================================

  Future<void> deleteRecord(
      String recordId,
      ) async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? data =
      prefs.getString(
        'user_records',
      );

      if (data == null ||
          data.isEmpty) {
        return;
      }

      final dynamic decoded =
      jsonDecode(data);

      if (decoded is! List) {
        return;
      }

      final List<dynamic> updatedRecords =
      List<dynamic>.from(decoded);

      updatedRecords.removeWhere(
            (item) =>
        item is Map &&
            item['id']?.toString() ==
                recordId,
      );

      await prefs.setString(
        'user_records',
        jsonEncode(
          updatedRecords,
        ),
      );

      await loadRecords();

      Get.snackbar(
        'Deleted',
        'Record deleted successfully',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint(
        'DELETE ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to delete record',
        snackPosition:
        SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // DISPOSE SEARCH
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Records',
        ),
        centerTitle: true,
      ),

      // =======================================================
      // ADD BUTTON
      // =======================================================

      floatingActionButton:
      FloatingActionButton(
        onPressed: addNewRecord,
        child: const Icon(
          Icons.add,
        ),
      ),

      body: Column(
        children: [
          // =====================================================
          // SEARCH
          // =====================================================

          Padding(
            padding:
            const EdgeInsets.all(16),
            child: TextField(
              controller:
              searchController,
              decoration:
              InputDecoration(
                hintText:
                'Search records...',
                prefixIcon:
                const Icon(
                  Icons.search,
                ),
                suffixIcon:
                searchController
                    .text
                    .isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController
                        .clear();
                  },
                  icon:
                  const Icon(
                    Icons.clear,
                  ),
                )
                    : null,
                border:
                const OutlineInputBorder(),
              ),
            ),
          ),

          // =====================================================
          // RECORD LIST
          // =====================================================

          Expanded(
            child:
            filteredRecords.isEmpty
                ? const Center(
              child: Text(
                'No records found',
                style: TextStyle(
                  fontSize: 16,
                  color:
                  Colors.grey,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh:
              loadRecords,
              child: ListView
                  .builder(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  0,
                  16,
                  100,
                ),
                itemCount:
                filteredRecords
                    .length,
                itemBuilder:
                    (context, index) {
                  final Map<
                      String,
                      dynamic>
                  record =
                  filteredRecords[
                  index];

                  return buildRecordCard(
                    record,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RECORD CARD
  // =========================================================

  Widget buildRecordCard(
      Map<String, dynamic> record,
      ) {
    final String name =
        record['name']?.toString() ??
            'No Name';

    final String profession =
        record['profession']
            ?.toString() ??
            '';

    final String age =
        record['age']?.toString() ??
            '';

    final String gender =
        record['gender']?.toString() ??
            '';

    final String language =
        record['language']
            ?.toString() ??
            '';

    final String imagePath =
        record['imagePath']
            ?.toString() ??
            '';

    final dynamic qualificationData =
    record['qualifications'];

    int qualificationCount = 0;

    if (qualificationData is List) {
      qualificationCount =
          qualificationData.length;
    }

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),
      elevation: 3,
      child: Padding(
        padding:
        const EdgeInsets.all(14),
        child: Column(
          children: [
            // =================================================
            // TOP
            // =================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                // IMAGE
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color:
                    Colors.grey.shade200,
                    child: imagePath
                        .isNotEmpty &&
                        File(imagePath)
                            .existsSync()
                        ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 35,
                      color:
                      Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        name,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      if (profession
                          .isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 4,
                          ),
                          child: Text(
                            profession,
                            style:
                            const TextStyle(
                              color:
                              Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 6,
                      ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 5,
                        children: [
                          if (age
                              .isNotEmpty)
                            Text(
                              'Age: $age',
                            ),
                          if (gender
                              .isNotEmpty)
                            Text(
                              'Gender: $gender',
                            ),
                        ],
                      ),

                      if (language
                          .isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 4,
                          ),
                          child: Text(
                            'Language: $language',
                          ),
                        ),

                      if (qualificationCount >
                          0)
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 4,
                          ),
                          child: Text(
                            'Qualifications: $qualificationCount',
                            style:
                            const TextStyle(
                              color:
                              Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // =================================================
                // EDIT
                // =================================================

                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: () {
                    editRecord(record);
                  },
                ),

                // =================================================
                // DELETE
                // =================================================

                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    confirmDelete(
                      record,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}