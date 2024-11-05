import 'dart:typed_data';

import 'package:at_chops/types.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:dart_crypto/algorithms.dart';

class AtChopsCrypto extends AsyncSymmetricEncryptionAlgorithm {
  final _algo =
      crypto.AesCtr.with256bits(macAlgorithm: crypto.MacAlgorithm.empty);
  final Uint8List _key;
  AtChopsCrypto(this._key);

  @override
  Future<Uint8List> decrypt(Uint8List encryptedData,
      {InitialisationVector? iv}) async {
    var secretKey = await _algo.newSecretKeyFromBytes(_key);
    var secretBox = crypto.SecretBox(
      encryptedData,
      nonce: iv!.ivBytes,
      mac: crypto.Mac.empty,
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
