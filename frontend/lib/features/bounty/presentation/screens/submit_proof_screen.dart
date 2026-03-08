import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/presentation/widgets/xp_reward_popup.dart';
import '../providers/bounty_provider.dart';

class SubmitProofScreen extends ConsumerStatefulWidget {
  final String bountyId;
  final String claimId;

  const SubmitProofScreen({
    super.key,
    required this.bountyId,
    required this.claimId,
  });

  @override
  ConsumerState<SubmitProofScreen> createState() => _SubmitProofScreenState();
}

class _SubmitProofScreenState extends ConsumerState<SubmitProofScreen> {
  final _noteController = TextEditingController();
  final List<File> _selectedFiles = [];
  bool _uploading = false;
  bool _submitting = false;
  final List<String> _uploadedUrls = [];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (images.isNotEmpty) {
      setState(() {
        for (final img in images) {
          if (_selectedFiles.length < 10) {
            _selectedFiles.add(File(img.path));
          }
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (photo != null && _selectedFiles.length < 10) {
      setState(() => _selectedFiles.add(File(photo.path)));
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  Future<void> _submit() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one attachment'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      // Step 1: Upload files
      final repo = ref.read(bountyRepositoryProvider);
      final urls = await repo.uploadImages(_selectedFiles);
      _uploadedUrls.addAll(urls);

      setState(() {
        _uploading = false;
        _submitting = true;
      });

      // Step 2: Submit proof
      final note = _noteController.text.trim();
      final response = await repo.submitProof(
        widget.claimId,
        proofUrls: _uploadedUrls,
        note: note.isNotEmpty ? note : null,
      );

      // Refresh claims
      ref.read(myClaimsProvider.notifier).load();

      if (mounted) {
        final xpAwarded =
            (response['data'] as Map<String, dynamic>?)?['xpAwarded'] as int? ??
            response['xpAwarded'] as int? ??
            0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work submitted successfully!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        if (xpAwarded > 0) {
          final prevLevel = ref.read(authProvider).user?.level ?? 0;
          ref.read(authProvider.notifier).fetchUser();
          showXpRewardPopup(
            context,
            xpGained: xpAwarded,
            reason: 'Proof Submitted',
            previousLevel: prevLevel,
            newLevel:
                (response['data'] as Map<String, dynamic>?)?['newLevel']
                    as int? ??
                response['newLevel'] as int? ??
                prevLevel,
            rankTier: ref.read(authProvider).user?.rankTier ?? 'WOOD',
          );
          await Future.delayed(const Duration(milliseconds: 2800));
        }
        if (mounted) context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _uploading || _submitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: isProcessing ? null : () => context.pop(),
        ),
        title: const Text(
          'Submit Work',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Upload images or screenshots of your completed work. The bounty creator will review your submission.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Attachments section ───────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Attachments',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedFiles.length}/10',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // File grid / empty state
            if (_selectedFiles.isEmpty)
              _EmptyAttachments(
                onPickImages: _pickImages,
                onTakePhoto: _takePhoto,
              )
            else
              _AttachmentGrid(
                files: _selectedFiles,
                onRemove: _removeFile,
                onAdd: _selectedFiles.length < 10 ? _pickImages : null,
                onCamera: _selectedFiles.length < 10 ? _takePhoto : null,
              ),

            const SizedBox(height: 28),

            // ── Note section ──────────────────────────────────
            const Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Note',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(optional)',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText:
                      'Add a note about your work, explain what you did...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.neonGreen.withValues(
                    alpha: 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _uploading ? 'Uploading files...' : 'Submitting...',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Submit Work',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'];
        if (msg != null) return msg.toString();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Upload timed out \u2014 try again';
      }
      return 'Something went wrong';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}

// ═════════════════════════════════════════════════════════════
//  Empty state for attachments
// ═════════════════════════════════════════════════════════════

class _EmptyAttachments extends StatelessWidget {
  final VoidCallback onPickImages;
  final VoidCallback onTakePhoto;

  const _EmptyAttachments({
    required this.onPickImages,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No attachments yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add images of your completed work',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionChip(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onPickImages,
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: onTakePhoto,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  Attachment grid
// ═════════════════════════════════════════════════════════════

class _AttachmentGrid extends StatelessWidget {
  final List<File> files;
  final void Function(int index) onRemove;
  final VoidCallback? onAdd;
  final VoidCallback? onCamera;

  const _AttachmentGrid({
    required this.files,
    required this.onRemove,
    this.onAdd,
    this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid of file thumbnails
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: files.length,
          itemBuilder: (_, i) {
            final file = files[i];
            final isPdf = file.path.toLowerCase().endsWith('.pdf');

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isPdf
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.surface,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_outlined,
                                color: AppColors.error,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PDF',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(
                          file,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(i),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Add more buttons
        if (onAdd != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  icon: Icons.add_photo_alternate_outlined,
                  label: 'Add more',
                  onTap: onAdd!,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionChip(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: onCamera ?? () {},
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  Action chip button
// ═════════════════════════════════════════════════════════════

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
