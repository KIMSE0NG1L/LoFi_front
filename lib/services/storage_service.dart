import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

Future<String> uploadItemImage(File imageFile) async {
  final uid = currentUserId;
  if (uid == null) throw const AppException('로그인이 필요합니다.');

  final fileName = imageFile.path.split(Platform.pathSeparator).last;
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
  final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
  final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
  final bytes = await imageFile.readAsBytes();

  await supabase.storage.from('item-images').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );

  return supabase.storage.from('item-images').getPublicUrl(path);
}
