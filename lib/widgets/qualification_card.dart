

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_entry_controller.dart';

class QualificationCard extends StatelessWidget {
  final int index;

  const QualificationCard({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataEntryController>();

    // IMPORTANT:
    // Yahan Obx nahi lagana hai.
    // Parent DataEntryScreen already qualifications ko observe kar raha hai.

    if (index >= controller.qualifications.length) {
      return const SizedBox();
    }

    final qualification =
    controller.qualifications[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // Heading
          // --------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qualification ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              IconButton(
                onPressed: () {
                  controller.removeQualification(index);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // --------------------------------------------------
          // Labels
          // --------------------------------------------------

          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Qualification',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Text(
                  'Passing Year',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(
                width: 100,
                child: Text(
                  'Marks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // --------------------------------------------------
          // Fields
          // --------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // Qualification
              // ==================================================

              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: qualification.qualification.isEmpty
                      ? null
                      : qualification.qualification,

                  decoration: const InputDecoration(
                    hintText: 'Select',
                    border: UnderlineInputBorder(),
                  ),

                  items: controller.qualificationList
                      .map(
                        (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                      .toList(),

                  onChanged: (value) {
                    controller.updateQualification(
                      index,
                      qualification: value,
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // Passing Year
              // ==================================================

              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: qualification.passingYear.isEmpty
                      ? null
                      : qualification.passingYear,

                  decoration: const InputDecoration(
                    hintText: 'Select',
                    border: UnderlineInputBorder(),
                  ),

                  items: controller.yearList
                      .map(
                        (year) => DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    ),
                  )
                      .toList(),

                  onChanged: (value) {
                    controller.updateQualification(
                      index,
                      passingYear: value,
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // Marks
              // ==================================================

              SizedBox(
                width: 100,
                child: TextFormField(
                  key: ValueKey(
                    'marks_${index}_${qualification.marks}',
                  ),

                  initialValue: qualification.marks,

                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    hintText: 'Enter marks',
                    border: UnderlineInputBorder(),
                  ),

                  onChanged: (value) {
                    controller.updateQualification(
                      index,
                      marks: value,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}