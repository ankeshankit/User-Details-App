

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qualification_model.dart';
import '../views/saved_records_screen.dart';

class DataEntryController extends GetxController {
  // =========================================================
  // STORAGE KEY
  // =========================================================

  static const String storageKey = 'user_records';

  // =========================================================
  // TEXT CONTROLLERS
  // =========================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController professionController =
  TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // =========================================================
  // EDIT MODE
  // =========================================================

  final RxBool isEditMode = false.obs;

  String? editingRecordId;

  // =========================================================
  // SELECTED VALUES
  // =========================================================

  final RxString selectedAge = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedLanguage = ''.obs;
  final RxString selectedImagePath = ''.obs;

  // =========================================================
  // IMAGE PICKER
  // =========================================================

  final ImagePicker imagePicker = ImagePicker();

  // =========================================================
  // QUALIFICATIONS
  // =========================================================

  final RxList<QualificationModel> qualifications =
      <QualificationModel>[
        QualificationModel(),
        QualificationModel(),
        QualificationModel(),
      ].obs;

  // =========================================================
  // LOADING
  // =========================================================

  final RxBool isLoading = false.obs;

  // =========================================================
  // DROPDOWN LISTS
  // =========================================================

  final List<String> genderList = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> languageList = [
    'Hindi',
    'English',
    'Hindi & English',
    'Other',
  ];

  final List<String> qualificationList = [
    '10th',
    '12th',
    'Diploma',
    'Graduation',
    'Post Graduation',
    'Other',
  ];

  final List<String> yearList = List.generate(
    40,
        (index) => (2026 - index).toString(),
  );

  final List<String> ageList = List.generate(
    63,
        (index) => (18 + index).toString(),
  );

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    // IMPORTANT:
    // Yaha loadSavedData() call nahi karna hai.
    //
    // Edit ke time SavedRecordsScreen se selected record
    // loadRecordForEdit() ke through load hoga.
  }

  // =========================================================
  // IMAGE PICKER
  // =========================================================

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final File file = File(image.path);

      final int fileSize = await file.length();

      // 5 MB limit
      if (fileSize > 5 * 1024 * 1024) {
        Get.snackbar(
          'Image Too Large',
          'Please select an image smaller than 5 MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return;
      }

      selectedImagePath.value = image.path;
    } catch (e) {
      debugPrint('IMAGE PICK ERROR: $e');

      Get.snackbar(
        'Error',
        'Unable to select image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // ADD QUALIFICATION
  // =========================================================

  void addQualification() {
    qualifications.add(
      QualificationModel(),
    );
  }

  // =========================================================
  // REMOVE QUALIFICATION
  // =========================================================

  void removeQualification(int index) {
    if (qualifications.length <= 1) {
      Get.snackbar(
        'Required',
        'At least one qualification is required',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    qualifications.removeAt(index);
  }

  // =========================================================
  // UPDATE QUALIFICATION
  // =========================================================

  void updateQualification(
      int index, {
        String? qualification,
        String? passingYear,
        String? marks,
      }) {
    if (index < 0 || index >= qualifications.length) {
      return;
    }

    final item = qualifications[index];

    if (qualification != null) {
      item.qualification = qualification;
    }

    if (passingYear != null) {
      item.passingYear = passingYear;
    }

    if (marks != null) {
      item.marks = marks;
    }

    qualifications.refresh();
  }

  // =========================================================
  // LOAD RECORD FOR EDIT
  // =========================================================

  void loadRecordForEdit(
      Map<String, dynamic> record,
      ) {
    try {
      isEditMode.value = true;

      editingRecordId = record['id']?.toString();

      nameController.text =
          record['name']?.toString() ?? '';

      professionController.text =
          record['profession']?.toString() ?? '';

      selectedAge.value =
          record['age']?.toString() ?? '';

      selectedGender.value =
          record['gender']?.toString() ?? '';

      selectedLanguage.value =
          record['language']?.toString() ?? '';

      selectedImagePath.value =
          record['imagePath']?.toString() ?? '';

      // Clear old qualifications
      qualifications.clear();

      final dynamic qualificationData =
      record['qualifications'];

      if (qualificationData is List &&
          qualificationData.isNotEmpty) {
        for (final item in qualificationData) {
          if (item is Map) {
            qualifications.add(
              QualificationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }

      // Agar qualification nahi mili
      if (qualifications.isEmpty) {
        qualifications.add(
          QualificationModel(),
        );
      }

      debugPrint(
        'EDIT MODE: ${isEditMode.value}',
      );

      debugPrint(
        'EDIT RECORD ID: $editingRecordId',
      );
    } catch (e) {
      debugPrint(
        'LOAD EDIT RECORD ERROR: $e',
      );
    }
  }

  // =========================================================
  // SUBMIT FORM
  // ADD + UPDATE
  // =========================================================

  Future<void> submitForm() async {
    if (isLoading.value) {
      return;
    }

    try {
      // =====================================================
      // FORM VALIDATION
      // =====================================================

      final FormState? formState =
          formKey.currentState;

      if (formState == null) {
        return;
      }

      if (!formState.validate()) {
        return;
      }

      // =====================================================
      // DROPDOWN VALIDATION
      // =====================================================

      if (selectedAge.value.isEmpty) {
        Get.snackbar(
          'Required',
          'Please select age',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      if (selectedGender.value.isEmpty) {
        Get.snackbar(
          'Required',
          'Please select gender',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      if (selectedLanguage.value.isEmpty) {
        Get.snackbar(
          'Required',
          'Please select language',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      // =====================================================
      // QUALIFICATION VALIDATION
      // =====================================================

      for (int i = 0; i < qualifications.length; i++) {
        final item = qualifications[i];

        if (item.qualification.trim().isEmpty) {
          Get.snackbar(
            'Qualification Required',
            'Please select qualification ${i + 1}',
            snackPosition: SnackPosition.BOTTOM,
          );

          return;
        }

        if (item.passingYear.trim().isEmpty) {
          Get.snackbar(
            'Passing Year Required',
            'Please select passing year ${i + 1}',
            snackPosition: SnackPosition.BOTTOM,
          );

          return;
        }

        if (item.marks.trim().isEmpty) {
          Get.snackbar(
            'Marks Required',
            'Please enter marks ${i + 1}',
            snackPosition: SnackPosition.BOTTOM,
          );

          return;
        }
      }

      // =====================================================
      // START LOADING
      // =====================================================

      isLoading.value = true;

      // =====================================================
      // SHARED PREFERENCES
      // =====================================================

      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? savedData =
      prefs.getString(storageKey);

      List<dynamic> records = [];

      if (savedData != null &&
          savedData.isNotEmpty) {
        try {
          final dynamic decoded =
          jsonDecode(savedData);

          if (decoded is List) {
            records = decoded;
          }
        } catch (e) {
          debugPrint(
            'JSON DECODE ERROR: $e',
          );

          records = [];
        }
      }

      // =====================================================
      // QUALIFICATION JSON
      // =====================================================

      final List<Map<String, dynamic>>
      qualificationJson =
      qualifications
          .map(
            (item) => item.toJson(),
      )
          .toList();

      // =====================================================
      // UPDATE EXISTING RECORD
      // =====================================================

      if (isEditMode.value &&
          editingRecordId != null) {
        final int index =
        records.indexWhere(
              (record) =>
          record is Map &&
              record['id']?.toString() ==
                  editingRecordId,
        );

        if (index == -1) {
          Get.snackbar(
            'Error',
            'Record not found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );

          return;
        }

        final Map<String, dynamic>
        updatedRecord =
        Map<String, dynamic>.from(
          records[index],
        );

        updatedRecord['name'] =
            nameController.text.trim();

        updatedRecord['profession'] =
            professionController.text.trim();

        updatedRecord['age'] =
            selectedAge.value;

        updatedRecord['gender'] =
            selectedGender.value;

        updatedRecord['language'] =
            selectedLanguage.value;

        updatedRecord['imagePath'] =
            selectedImagePath.value;

        updatedRecord['qualifications'] =
            qualificationJson;

        records[index] = updatedRecord;

        // ===================================================
        // SAVE UPDATED RECORDS
        // ===================================================

        final bool saved =
        await prefs.setString(
          storageKey,
          jsonEncode(records),
        );

        if (saved) {
          Get.snackbar(
            'Success',
            'Record updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          clearForm();

          // Edit ke time previous SavedRecordsScreen
          // par wapas jayega.
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            'Unable to update record',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        return;
      }

      // =====================================================
      // ADD NEW RECORD
      // =====================================================

      final Map<String, dynamic> newRecord = {
        'id': DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        'name':
        nameController.text.trim(),

        'profession':
        professionController.text.trim(),

        'age':
        selectedAge.value,

        'gender':
        selectedGender.value,

        'language':
        selectedLanguage.value,

        'imagePath':
        selectedImagePath.value,

        'qualifications':
        qualificationJson,
      };

      records.add(newRecord);

      // =====================================================
      // SAVE NEW RECORD
      // =====================================================

      final bool saved =
      await prefs.setString(
        storageKey,
        jsonEncode(records),
      );

      if (saved) {
        Get.snackbar(
          'Success',
          'Record saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        clearForm();

        // New record save hone ke baad
        // saved records screen open hoga.
        Get.off(
              () => const SavedRecordsScreen(),
        );
      } else {
        Get.snackbar(
          'Error',
          'Unable to save record',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint(
        'SUBMIT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // LOAD ALL RECORDS
  // =========================================================

  Future<List<Map<String, dynamic>>>
  getAllRecords() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? data =
      prefs.getString(storageKey);

      if (data == null ||
          data.isEmpty) {
        return [];
      }

      final dynamic decoded =
      jsonDecode(data);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map<Map<String, dynamic>>(
            (item) =>
        Map<String, dynamic>.from(item),
      )
          .toList();
    } catch (e) {
      debugPrint(
        'GET ALL RECORDS ERROR: $e',
      );

      return [];
    }
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
      prefs.getString(storageKey);

      if (data == null ||
          data.isEmpty) {
        return;
      }

      final dynamic decoded =
      jsonDecode(data);

      if (decoded is! List) {
        return;
      }

      final List<dynamic> records =
      List<dynamic>.from(decoded);

      records.removeWhere(
            (record) =>
        record is Map &&
            record['id']?.toString() ==
                recordId,
      );

      await prefs.setString(
        storageKey,
        jsonEncode(records),
      );

      Get.snackbar(
        'Deleted',
        'Record deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // GET RECORD BY ID
  // =========================================================

  Future<Map<String, dynamic>?>
  getRecordById(
      String recordId,
      ) async {
    try {
      final List<Map<String, dynamic>>
      records =
      await getAllRecords();

      for (final record in records) {
        if (record['id']?.toString() ==
            recordId) {
          return record;
        }
      }

      return null;
    } catch (e) {
      debugPrint(
        'GET RECORD ERROR: $e',
      );

      return null;
    }
  }

  // =========================================================
  // CLEAR ALL DATA
  // =========================================================

  Future<void> clearData() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(storageKey);

    Get.snackbar(
      'Success',
      'All records deleted',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // =========================================================
  // LOAD LATEST RECORD
  // =========================================================
  //
  // Ye method manually use kar sakte ho.
  // onInit() me call nahi karna hai.
  //

  Future<void> loadSavedData() async {
    try {
      final List<Map<String, dynamic>>
      records =
      await getAllRecords();

      if (records.isEmpty) {
        return;
      }

      final Map<String, dynamic>
      record = records.last;

      loadRecordForEdit(record);

      // Manual loading ke case me edit mode nahi chahiye
      resetEditMode();
    } catch (e) {
      debugPrint(
        'LOAD SAVED DATA ERROR: $e',
      );
    }
  }

  // =========================================================
  // RESET EDIT MODE
  // =========================================================

  void resetEditMode() {
    isEditMode.value = false;
    editingRecordId = null;
  }

  // =========================================================
  // CLEAR FORM
  // =========================================================

  void clearForm() {
    nameController.clear();

    professionController.clear();

    ageController.clear();

    selectedAge.value = '';

    selectedGender.value = '';

    selectedLanguage.value = '';

    selectedImagePath.value = '';

    // IMPORTANT:
    // New record ke liye edit mode reset
    isEditMode.value = false;

    editingRecordId = null;

    qualifications.clear();

    qualifications.addAll([
      QualificationModel(),
      QualificationModel(),
      QualificationModel(),
    ]);
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void onClose() {
    nameController.dispose();
    professionController.dispose();
    ageController.dispose();

    super.onClose();
  }
}