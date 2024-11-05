import 'dart:typed_data';

import 'package:dart_crypto/algorithms.dart';

import 'package:at_chops/types.dart';
import 'package:webcrypto/webcrypto.dart' as webcrypto;

class AtChopsBoring extends AsyncSymmetricEncryptionAlgorithm {
  final Uint8List _key;
  AtChopsBoring(this._key);

  final int _counterLength =
      4 * 8; // portion of iv which represents counter, we use 4 bytes

  @override
  Future<Uint8List> decrypt(Uint8List encryptedData,
      {InitialisationVector? iv}) async {
    final key = await webcrypto.AesCtrSecretKey.importRawKey(_key);
    return key.decryptBytes(encryptedData, iv!.ivBytes, _counterLength);
  }

  @override
  Future<Uint8List> encrypt(Uint8List plainData,
      {InitialisationVector? iv}) async {
    final key = await webcrypto.AesCtrSecretKey.importRawKey(_key);
    return key.encryptBytes(plainData, iv!.ivBytes, _counterLength);
  }
}
