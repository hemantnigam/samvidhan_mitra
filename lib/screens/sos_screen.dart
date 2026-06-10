import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.emergencyRed.withValues(alpha: 0.02),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Emergency Helplines",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Newsreader',
                  color: AppConstants.emergencyRed,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap any card to dial immediately. Stay safe.",
                style: TextStyle(color: AppConstants.secondaryGray),
              ),
              const SizedBox(height: 32),
              
              // Primary Full-Width Card - Only 112 at the top
              _buildSOSCard(context, "112", "National Emergency", Icons.emergency, isFullWidth: true),
              
              const SizedBox(height: 32),
              const Text(
                "Specialized Helplines",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12),
              ),
              const SizedBox(height: 16),
              
              // Secondary Grid - Police moved here
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Increased height relative to width (from 1.3)
                children: [
                  _buildSOSCard(context, "100", "Police", Icons.local_police),
                  _buildSOSCard(context, "1098", "Child Helpline", Icons.child_care),
                  _buildSOSCard(context, "1930", "Cyber Crime", Icons.security),
                  _buildSOSCard(context, "1091", "Women Helpline", Icons.woman),
                  _buildSOSCard(context, "108", "Ambulance", Icons.medical_services),
                  _buildSOSCard(context, "1077", "Disaster Mgmt", Icons.flood),
                ],
              ),
              
              const SizedBox(height: 48),
              _buildRightsNotice(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightsNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.accentWheat.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.accentWheat.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.gavel, color: AppConstants.accentWheat, size: 20),
              SizedBox(width: 8),
              Text(
                "KNOW YOUR RIGHT",
                style: TextStyle(
                  color: AppConstants.accentWheat,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "You have the right to legal counsel within 24 hours of any detention. Never sign documents you have not read.",
            style: TextStyle(
              color: AppConstants.primaryNavy,
              height: 1.5,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSCard(BuildContext context, String number, String label, IconData icon, {bool isFullWidth = false}) {
    return InkWell(
      onTap: () => _makeCall(number),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isFullWidth ? 24 : 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstants.emergencyRed.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppConstants.emergencyRed.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isFullWidth 
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.emergencyRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppConstants.emergencyRed, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppConstants.secondaryGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.emergencyRed,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.call, color: AppConstants.emergencyRed, size: 28),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppConstants.emergencyRed, size: 28),
                const SizedBox(height: 8),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.emergencyRed,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.secondaryGray,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
      ),
    );
  }
}
