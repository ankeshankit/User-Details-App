import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:userinformations/views/saved_records_screen.dart';

import '../controllers/data_entry_controller.dart';
import '../widgets/qualification_card.dart';

class DataEntryScreen extends StatelessWidget {
  DataEntryScreen({super.key});

  final DataEntryController controller = Get.put(DataEntryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        title: const Text(
          'User Details',
        ),

        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
            onPressed: () {
              Get.to(
                    () => const SavedRecordsScreen(),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Form(
          key: controller.formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  IMAGE
                const Text(
                  'Upload Profile Image',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Upload your recent photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Obx(() {
                      if (controller.selectedImagePath.value.isNotEmpty) {
                        return Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(controller.selectedImagePath.value),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.grey,
                        ),
                      );
                    }),

                    const SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            controller.pickImage();
                          },
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Choose Image'),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'JPG, PNG up to 5MB',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // NAME
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // PROFESSION
                const Text(
                  'Profession',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: controller.professionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter profession',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter profession';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // AGE
                const Text(
                  'Age',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedAge.value.isEmpty
                        ? null
                        : controller.selectedAge.value,
                    decoration: const InputDecoration(
                      hintText: 'Enter age',
                      border: UnderlineInputBorder(),
                    ),
                    items: controller.ageList
                        .map(
                          (age) =>
                              DropdownMenuItem(value: age, child: Text(age)),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedAge.value = value ?? '';
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // GENDER
                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedGender.value.isEmpty
                        ? null
                        : controller.selectedGender.value,
                    decoration: const InputDecoration(
                      hintText: 'Select',
                      border: UnderlineInputBorder(),
                    ),
                    items: controller.genderList
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedGender.value = value ?? '';
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // LANGUAGE
                const Text(
                  'Language *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedLanguage.value.isEmpty
                        ? null
                        : controller.selectedLanguage.value,
                    decoration: const InputDecoration(
                      hintText: 'Select',
                      border: UnderlineInputBorder(),
                    ),
                    items: controller.languageList
                        .map(
                          (language) => DropdownMenuItem(
                            value: language,
                            child: Text(language),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedLanguage.value = value ?? '';
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // QUALIFICATIONS
                const Text(
                  'Qualifications',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Obx(
                  () => Column(
                    children: List.generate(controller.qualifications.length, (
                      index,
                    ) {
                      return QualificationCard(index: index);
                    }),
                  ),
                ),

                // ADD QUALIFICATION
                GestureDetector(
                  onTap: () {
                    controller.addQualification();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Another Qualification',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // SUBMIT
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                        controller.submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                // const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


