import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

final Dio _dio = Dio();

Future<String> uploadFile(String url, String file_path) async {
  try {
    String fileName = file_path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file_path, filename: fileName),
    });

    Response response = await _dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      log(response.data.toString());
      log('File upload successful');
      return response.data["transcription"];
    } else {
      log('File upload failed with status: ${response.statusCode}');
      return "error";
    }
  } catch (e) {
    log('File upload failed: $e');
    return "error";
  }
}
