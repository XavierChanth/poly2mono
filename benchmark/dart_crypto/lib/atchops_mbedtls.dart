import 'dart:async';
import 'dart:io';

import 'package:atsdk_ffi/atsdk_ffi.dart';
import 'package:dart_crypto/algorithms.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:at_chops/at_chops.dart';

final _libExtension = {
  'linux': 'so',
  'macos': 'dylib',
  'windows': 'dll',
}[Platform.operatingSystem];
final _libPath = path.join(Directory.current.path, "../../ffi/dart/build",
    'libatchops.$_libExtension');
final _dylib = DynamicLibrary.open(_libPath);

extension on Uint8List {
  Pointer<T> toPointer<T extends NativeType>() {
    final Pointer<Uint8> pointer = malloc(length * sizeOf<Uint8>());
    for (var i = 0; i < length; i++) {
      (pointer + i).value = this[i];
    }
    return Pointer.fromAddress(pointer.address);
  }
}

class AtChopsMbedtls extends AsyncSymmetricEncryptionAlgorithm {
  final Uint8List _key;
  final AtSdkFfi ffi = AtSdkFfi(_dylib);
  AtChopsMbedtls(this._key);

  @override
  FutureOr<Uint8List> decrypt(Uint8List encryptedData,
      {InitialisationVector? iv}) {
    return _crypt(encryptedData, iv: iv!, encrypt: false);
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List plainData,
      {InitialisationVector? iv}) async {
    return await _crypt(Uint8List.fromList(plainData), iv: iv!, encrypt: true);
  }

  FutureOr<Uint8List> _crypt(Uint8List plainData,
      {required InitialisationVector iv, required bool encrypt}) {
    final nativeIv = iv.ivBytes.toPointer<UnsignedChar>(); // allocated
    final key = _key.toPointer<UnsignedChar>(); // allocated
    final keyLength = atchops_aes_size.ATCHOPS_AES_256;

    final bufferLength1 = plainData.length;
    final buffer1 = plainData.toPointer<UnsignedChar>();
    late int bufferSize2;
    if (encrypt) {
      bufferSize2 = ffi.atchops_aes_ctr_ciphertext_size(bufferLength1);
    } else {
      bufferSize2 = ffi.atchops_aes_ctr_plaintext_size(bufferLength1);
    }
    Pointer<UnsignedChar> buffer2 =
        malloc.allocate(bufferSize2 * sizeOf<UnsignedChar>()); // allocated
    Pointer<Size> outLen = malloc.allocate(sizeOf<UnsignedLong>()); // allocated
    late int res;
    if (encrypt) {
      res = ffi.atchops_aes_ctr_encrypt(
        key,
        keyLength,
        nativeIv,
        buffer1,
        bufferLength1,
        buffer2,
        bufferSize2,
        outLen,
      );
    } else {
      res = ffi.atchops_aes_ctr_decrypt(
        key,
        keyLength,
        nativeIv,
        buffer1,
        bufferLength1,
        buffer2,
        bufferSize2,
        outLen,
      );
    }
    malloc.free(nativeIv);
    malloc.free(key);
    malloc.free(buffer1);
    if (res != 0) {
      malloc.free(buffer2);
      malloc.free(outLen);

      // String prefix = (encrypt) ? "en" : "de";
      // print("atchops failed ${prefix}crypt: $res");
      return Uint8List(0);
    }
    final output =
        Pointer<Uint8>.fromAddress(buffer2.address).asTypedList(outLen.value);
    malloc.free(buffer2);
    malloc.free(outLen);

    return output;
  }
}
