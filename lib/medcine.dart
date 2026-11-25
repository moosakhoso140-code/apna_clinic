import 'package:flutter/material.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Medicines List with Details
var medicines = [
      {
        "name": "Paracetamol (Panadol)",
        "category": "Pain Relief & Fever",
        "dosage": "500mg - Every 6 hours as needed",
        "uses": "Used to treat mild to moderate pain and reduce fever.",
        "sideEffects": "Nausea, stomach pain, or headache in rare cases."
      },
      {
        "name": "Amoxicillin",
        "category": "Antibiotic",
        "dosage": "250mg - 3 times a day",
        "uses": "Treats bacterial infections such as chest infections and dental abscesses.",
        "sideEffects": "Diarrhea, mild skin rash, or nausea."
      },
      {
        "name": "Ibuprofen",
        "category": "Anti-inflammatory",
        "dosage": "400mg - Twice a day after meals",
        "uses": "Reduces inflammation, swelling, stiffness, and joint pain.",
        "sideEffects": "Stomach upset, heartburn, or dizziness."
      },
      {
        "name": "Omeprazole",
        "category": "Acid Reflux",
        "dosage": "20mg - Once daily before breakfast",
        "uses": "Treats gastroesophageal reflux disease (GERD) and stomach ulcers.",
        "sideEffects": "Headache, abdominal pain, or gas."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medication_outlined, size: 20, color: Color(0xFF0D9488)),
            const SizedBox(width: 8),
            Text(
              'Medicine Guide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Medicines & Prescriptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final med = medicines[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[800]! : const Color(0xFFF0F2F5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFCCFBF1),
                        ),
                        child: const Icon(Icons.medication, color: Color(0xFF0D9488), size: 24),
                      ),
                      title: Text(
                        med['name']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          med['category']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Detail Screen open karne ke liye navigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineDetailScreen(medicine: med),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Medicine Detail Screen
class MedicineDetailScreen extends StatelessWidget {
  final Map<String, String> medicine;

  const MedicineDetailScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          medicine['name']!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine['category']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medicine['name']!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailSection('Recommended Dosage', medicine['dosage']!, isDarkMode),
            const SizedBox(height: 16),
            _buildDetailSection('Primary Uses', medicine['uses']!, isDarkMode),
            const SizedBox(height: 16),
            _buildDetailSection('Possible Side Effects', medicine['sideEffects']!, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : const Color(0xFFF0F2F5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}