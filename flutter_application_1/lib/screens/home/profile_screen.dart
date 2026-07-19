// *Profile screen*
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // Local state tracking parameters
  final TextEditingController nameController = TextEditingController(
    text: '',
  );
  final TextEditingController weightController = TextEditingController(
    text: '50 kg',
  );
  final TextEditingController locationController = TextEditingController(
    text: 'Abbottabad, Pakistan',
  );

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Standard Back Navigation Anchor Arrow
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Perfectly Centered Premium Interface Bounded Card Frame
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Action Header Strip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Health Profile',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isEditing
                                    ? Icons.save_rounded
                                    : Icons.edit_note_outlined,
                                color: primaryColor,
                                size: 26,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_isEditing) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Profile Records Updated Natively!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                  _isEditing = !_isEditing;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Center User Avatar Presentation Node
                        Center(
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: const Color(0xFFE2E8F0),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 38,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Conditional State View Render Channel
                        _isEditing
                            ? Column(
                                children: [
                                  _buildModernTextField(
                                    nameController,
                                    'NAME',
                                    Icons.badge_outlined,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildModernTextField(
                                    weightController,
                                    'WEIGHT',
                                    Icons.scale_outlined,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildModernTextField(
                                    locationController,
                                    'LOCATION',
                                    Icons.map_outlined,
                                    primaryColor,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildStaticDisplayItem(
                                    Icons.badge_outlined,
                                    'Name',
                                    nameController.text,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStaticDisplayItem(
                                    Icons.scale_outlined,
                                    'Weight Metrics',
                                    weightController.text,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStaticDisplayItem(
                                    Icons.map_outlined,
                                    'Residency Location',
                                    locationController.text,
                                    primaryColor,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refined Dynamic Filled Input Textform Field Modifier Widget
  Widget _buildModernTextField(
    TextEditingController controller,
    String labelText,
    IconData prefixIcon,
    Color primaryColor,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: primaryColor, size: 18),
        labelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // Compact Clean Custom Dynamic Viewer Row Segment Node
  Widget _buildStaticDisplayItem(
    IconData icon,
    String label,
    String dataValue,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dataValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}