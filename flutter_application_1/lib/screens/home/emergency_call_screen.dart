// *Emergency Call*
import 'package:flutter/material.dart';

class EmergencyCallScreen extends StatelessWidget {
  const EmergencyCallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
              // Enclosing the content in a scroll view inside the card prevents any pixel overflows
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Call State Header
                    Column(
                      children: const [
                        Text(
                          '911',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w300,
                            color: Colors.black87,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'land line',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'calling...',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Concentric Radar Circle Graphics
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFB9E5E8).withOpacity(0.4),
                        ),
                        child: Center(
                          child: Container(
                            width: 105,
                            height: 105,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF90CAF9),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Emergency Details Sub-Card Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Describe your emergency...',
                              style: TextStyle(
                                color: Colors.black54,
                                height: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Call Hang Up Trigger Action
                    Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.redAccent,
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}