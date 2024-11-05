import 'dart:typed_data';

import 'package:at_chops/types.dart';
import 'package:better_cryptography/better_cryptography.dart' as better;
import 'package:dart_crypto/algorithms.dart';

class AtChopsBetter extends AsyncSymmetricEncryptionAlgorithm {
  final _algo =
      better.AesCtr.with256bits(macAlgorithm: better.MacAlgorithm.empty);
  final Uint8List _key;
  AtChopsBetter(this._key);

  @override
  Future<Uint8List> decrypt(Uint8List encryptedData,
      {InitialisationVector? iv}) async {
    var secretKey = await _algo.newSecretKeyFromBytes(_key);
    var secretBox = better.SecretBox(
      encryptedData,
      nonce: iv!.ivBytes,
      mac: better.Mac.empty,
    );
    return Uint8List.fromList(
        await _algo.decrypt(secretBox, secretKey: secretKey));
  }

  @override
  Future<Uint8List> encrypt(Uint8List plainData,
      {InitialisationVector? iv}) async {
    var secretKey = await _algo.newSecretKeyFromBytes(_key);
    var secretBox = await _algo.encrypt(plainData,
        nonce: iv!.ivBytes, secretKey: secretKey);
    return Uint8List.fromList(secretBox.cipherText);
  }
}
