import 'package:flutter/material.dart';
import 'package:relax_mindfulness/services/cms_service.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CmsService _cms = CmsService();
  String _activeTab = 'Ambient Sounds';

  void _showAddSoundModal() {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Nature');
    final urlCtrl = TextEditingController(text: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_8b211a7c5b.mp3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_rounded, color: tealPrimary),
            SizedBox(width: 10),
            Text('Publish New Sound to Cloud', style: TextStyle(color: textPrimary, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: textPrimary),
                decoration: const InputDecoration(labelText: 'Sound Title (e.g. Soft Waterfall)', labelStyle: TextStyle(color: textSecondary)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryCtrl,
                style: const TextStyle(color: textPrimary),
                decoration: const InputDecoration(labelText: 'Category (Nature, Healing, Focus)', labelStyle: TextStyle(color: textSecondary)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: textPrimary),
                decoration: const InputDecoration(labelText: 'Supabase / Cloud Storage Audio URL', labelStyle: TextStyle(color: textSecondary)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tealPrimary),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                _cms.publishNewItem(AudioMetadata(
                  id: titleCtrl.text.toLowerCase().replaceAll(' ', '-'),
                  title: titleCtrl.text.trim(),
                  category: categoryCtrl.text.trim(),
                  audioUrl: urlCtrl.text.trim(),
                  imageUrl: '',
                  type: 'sound',
                  isFeatured: true,
                  isPublished: true,
                  version: 1,
                ));
                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Published to Cloud Database! Mobile app updated instantly ✓')),
                );
              }
            },
            child: const Text('Publish Instantly', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: tealPrimary),
            SizedBox(width: 10),
            Text('Relax & Mindfulness — Cloud Admin CMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                SizedBox(width: 6),
                Text('Admin RLS Online', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Analytics Overview Cards ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLOUD AUDIO TRACKS', style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                        const SizedBox(height: 6),
                        const Text('39', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary)),
                        const SizedBox(height: 2),
                        const Text('100% Dynamic CDN', style: TextStyle(fontSize: 11, color: tealPrimary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLOUD STORAGE USAGE', style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                        const SizedBox(height: 6),
                        const Text('1.2 GB', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary)),
                        const SizedBox(height: 2),
                        const Text('Supabase R2 Storage', style: TextStyle(fontSize: 11, color: mintAccent)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PUBLIC APP USER ACCESS', style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                        const SizedBox(height: 6),
                        const Text('No Login Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: coralAccent)),
                        const SizedBox(height: 2),
                        const Text('Anonymous Guest RLS', style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── CMS Section Selector ──────────────────────────────────────
            Row(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Ambient Sounds', 'Meditations', 'Sleep Stories', 'Categories', 'Version History'].map((tab) {
                      final isSelected = _activeTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GlassChip(
                          label: tab,
                          isSelected: isSelected,
                          selectedColor: tealPrimary,
                          onTap: () => setState(() => _activeTab = tab),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                GlassPillButton(
                  text: '+ Add New Sound Track',
                  icon: Icons.add_rounded,
                  containerColor: tealPrimary,
                  contentColor: Colors.black,
                  onTap: _showAddSoundModal,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Dynamic Audio Metadata Management Table ──────────────────
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CMS DATABASE — $_activeTab Catalog',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: 1.2),
                      ),
                      Text(
                        'Changes push instantly without mobile app release',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),

                  // Metadata Items List
                  ..._cms.items.map((item) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white10)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: tealPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.audiotrack_rounded, color: tealPrimary, size: 18),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 14)),
                                  Text('ID: ${item.id} • Version ${item.version}.0', style: TextStyle(fontSize: 11, color: textSecondary)),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(item.category, style: const TextStyle(fontSize: 11, color: textPrimary), textAlign: TextAlign.center),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(item.audioUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: textSecondary)),
                            ),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isPublished ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isPublished ? 'PUBLISHED ✓' : 'DRAFT',
                                    style: TextStyle(fontSize: 10, color: item.isPublished ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: textSecondary, size: 18),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _cms.deleteItem(item.id);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
