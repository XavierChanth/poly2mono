import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';
import 'package:dart_crypto/algorithms.dart';

class AtChopsCurrent extends AsyncSymmetricEncryptionAlgorithm {
  final AESEncryptionAlgo _algo;
  AtChopsCurrent(AESKey key) : _algo = AESEncryptionAlgo(key);
  @override
  Uint8List decrypt(Uint8List encryptedData, {InitialisationVector? iv}) {
    return _algo.decrypt(encryptedData, iv: iv);
  }

  @override
  Uint8List encrypt(Uint8List plainData, {InitialisationVector? iv}) {
    return _algo.encrypt(plainData, iv: iv);
  }
}
