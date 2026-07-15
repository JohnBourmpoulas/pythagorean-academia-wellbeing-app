import 'dart:io';

import '../services/api_service.dart';

class LibraryRepository {
  String? lastError;

  Future<List<Map<String, dynamic>>> getAdminLibraryItems({
    String type = 'all',
  }) async {
    final endpoint = type == 'all'
        ? '/admin/library/list.php'
        : '/admin/library/list.php?type=$type';

    final response = await ApiService.get(endpoint, auth: true);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load library items');
    }

    return List<Map<String, dynamic>>.from(response['items'] ?? []);
  }

  Future<bool> createLibraryItem(Map<String, dynamic> payload) async {
    final response = await ApiService.post(
      '/admin/library/create.php',
      payload,
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not create item');
    }

    return true;
  }

  Future<bool> updateLibraryItem(Map<String, dynamic> payload) async {
    final response = await ApiService.post(
      '/admin/library/update.php',
      payload,
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not update item');
    }

    return true;
  }

  Future<bool> deleteLibraryItem(int id) async {
    final response = await ApiService.post(
      '/admin/library/delete.php',
      {'id': id},
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not delete item');
    }

    return true;
  }

  Future<bool> toggleLibraryItem({
    required int id,
    required bool isActive,
  }) async {
    final response = await ApiService.post(
      '/admin/library/update.php',
      {
        'id': id,
        'is_active': isActive ? 1 : 0,
      },
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not update item');
    }

    return true;
  }

  Future<String> uploadLibraryFile({
    required File file,
    required String type,
  }) async {
    final response = await ApiService.uploadFile(
      '/admin/library/upload.php',
      file: file,
      fieldName: 'file',
      fields: {
        'type': type,
      },
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not upload file');
    }

    return response['file_path']?.toString() ?? '';
  }
}