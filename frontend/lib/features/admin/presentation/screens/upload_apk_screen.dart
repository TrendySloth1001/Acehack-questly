import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

// ─────────────────────────────────────────────────────────────
// Upload APK — pick .apk from device, upload to MinIO via backend
// ─────────────────────────────────────────────────────────────

class UploadApkScreen extends ConsumerStatefulWidget {
  const UploadApkScreen({super.key});

  @override
  ConsumerState<UploadApkScreen> createState() => _UploadApkScreenState();
}

class _UploadApkScreenState extends ConsumerState<UploadApkScreen> {
  File? _pickedFile;
  String? _fileName;
  int? _fileSize;
  bool _uploading = false;
  double _progress = 0.0;
  String? _error;
  String? _successUrl;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _pickedFile = file;
        _fileName = result.files.single.name;
        _fileSize = result.files.single.size;
        _error = null;
        _successUrl = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_pickedFile == null) return;
    setState(() {
      _uploading = true;
      _progress = 0.0;
      _error = null;
      _successUrl = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _pickedFile!.path,
          filename: _fileName ?? 'questly.apk',
        ),
      });

      final response = await dio.post(
        ApiEndpoints.uploadApk,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() => _progress = sent / total);
          }
        },
      );

      final data = response.data['data'];
      setState(() {
        _successUrl = data['url'] as String?;
        _uploading = false;
        _progress = 1.0;
      });
    } on DioException catch (e) {
      setState(() {
        _error =
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Upload failed';
        _uploading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _uploading = false;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Upload APK',
          style: TextStyle(
            color: AppColors.fore,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header info ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.muted.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.android,
                        color: AppColors.brand,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questly APK Release',
                            style: TextStyle(
                              color: AppColors.fore,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Upload .apk to MinIO storage',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── File picker area ─────────────────────────
              GestureDetector(
                onTap: _uploading ? null : _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: _pickedFile != null
                        ? AppColors.brand.withValues(alpha: 0.04)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pickedFile != null
                          ? AppColors.brand.withValues(alpha: 0.3)
                          : AppColors.muted.withValues(alpha: 0.15),
                      width: _pickedFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.check_circle_outline
                            : Icons.file_upload_outlined,
                        color: _pickedFile != null
                            ? AppColors.brand
                            : AppColors.muted,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pickedFile != null
                            ? _fileName ?? 'File selected'
                            : 'Tap to select .apk file',
                        style: TextStyle(
                          color: _pickedFile != null
                              ? AppColors.fore
                              : AppColors.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_fileSize != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatSize(_fileSize!),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_pickedFile == null) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Max 150 MB',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Progress bar ─────────────────────────────
              if (_uploading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brand,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}% uploaded',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontFamily: 'SF Mono',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Error ────────────────────────────────────
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Success ──────────────────────────────────
              if (_successUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'APK uploaded successfully!',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Spacer(),

              // ── Upload button ─────────────────────────────
              ElevatedButton(
                  onPressed: _pickedFile != null && !_uploading
                      ? _upload
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: AppColors.muted.withValues(
                      alpha: 0.2,
                    ),
                    disabledForegroundColor: AppColors.muted.withValues(
                      alpha: 0.5,
                    ),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Upload to MinIO',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),

              const SizedBox(height: 12),

              // ── Pick another file ────────────────────────
              if (_pickedFile != null && !_uploading)
                Center(
                  child: TextButton(
                    onPressed: _pickFile,
                    child: const Text(
                      'Choose different file',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
