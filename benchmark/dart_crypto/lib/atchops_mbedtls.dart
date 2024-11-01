import 'dart:convert';

import 'package:dart_crypto/algorithms.dart';
import 'package:dart_crypto/atchops_ffi_old.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';

class AtChopsMbedtls extends AsyncSymmetricEncryptionAlgorithm {
  final Uint8List _key;
  AtChopsMbedtls(AESKey key) : _key = base64.decode(key.key);
  // final AESKey _key;
  // AtChopsMbedtls(this._key);
  @override
  Uint8List decrypt(Uint8List encryptedData, {InitialisationVector? iv}) {
    assert(iv != null);

    final nativeIv =
        String.fromCharCodes(iv!.ivBytes).toNativeUtf8(); // allocated
    final key = String.fromCharCodes(_key).toNativeUtf8(); // allocated
    final keyLength = 256;

    Pointer<Utf8> cipherText =
        String.fromCharCodes(encryptedData).toNativeUtf8();
    final cipherTextLength = encryptedData.length;
    Pointer<UnsignedLong> outLen =
        malloc.allocate(sizeOf<UnsignedLong>()); // allocated

    int bufSize = cipherTextLength ~/ 3;
    Pointer<UnsignedChar> buffer =
        malloc.allocate(bufSize * sizeOf<UnsignedChar>()); // allocated

    int res = AtChopsFfi.decrypt(key, keyLength, nativeIv, cipherText,
        cipherTextLength, buffer, bufSize, outLen);

    malloc.free(nativeIv);
    malloc.free(key);
    malloc.free(cipherText);
    if (res != 0) {
      malloc.free(outLen);
      print("atchops failed encode: $res");
      return Uint8List(0);
    }

    bufSize = outLen.value;
    final decodedTextSize = bufSize;
    Pointer<Utf8> decodedText =
        malloc.allocate(decodedTextSize * sizeOf<UnsignedChar>()); // allocated
    res = AtChopsFfi.decode(
      buffer,
      bufSize,
      decodedText,
      decodedTextSize,
      outLen,
    );

    malloc.free(buffer);
    if (res != 0) {
      malloc.free(decodedText);
      malloc.free(outLen);
      print("atchops failed decode: $res");
      return Uint8List(0);
    }

    String output = decodedText.toDartString(length: outLen.value);

    malloc.free(decodedText);
    malloc.free(outLen);

    return base64Decode(output);
  }

  @override
  Uint8List encrypt(Uint8List plainData, {InitialisationVector? iv}) {
    assert(iv != null);
    final encoded = String.fromCharCodes(plainData);
    final inputText = encoded.toNativeUtf8(); // allocated
    final inputTextLength = plainData.length;
    final encodedTextSize = inputTextLength * 4 ~/ 3 + 4;
    Pointer<Utf8> encodedText =
        malloc.allocate(encodedTextSize * sizeOf<UnsignedChar>()); // allocated
    Pointer<UnsignedLong> outLen =
        malloc.allocate(sizeOf<UnsignedLong>()); // allocated
    int res = AtChopsFfi.encode(
      inputText,
      inputTextLength,
      encodedText,
      encodedTextSize,
      outLen,
    );

    malloc.free(inputText);
    if (res != 0) {
      malloc.free(encodedText);
      malloc.free(outLen);
      print("atchops failed encode: $res");
      return Uint8List(0);
    }

    final nativeIv =
        String.fromCharCodes(iv!.ivBytes).toNativeUtf8(); // allocated
    final key = String.fromCharCodes(_key).toNativeUtf8(); // allocated
    final keyLength = 256;
    int bufSize = outLen.value * 3;
    Pointer<UnsignedChar> buffer =
        malloc.allocate(bufSize * sizeOf<UnsignedChar>()); // allocated
    res = AtChopsFfi.encrypt(key, keyLength, nativeIv, encodedText,
        inputTextLength, buffer, bufSize, outLen);
    malloc.free(nativeIv);
    malloc.free(key);
    malloc.free(encodedText);

    if (res != 0) {
      malloc.free(buffer);
      malloc.free(outLen);
      print("atchops failed crypt: $res");
      return Uint8List(0);
    }

    Pointer<Uint8> p = Pointer.fromAddress(buffer.address);
    final output = Uint8List.fromList(p.asTypedList(outLen.value));

    malloc.free(buffer);
    malloc.free(outLen);
    return output;
  }
}
