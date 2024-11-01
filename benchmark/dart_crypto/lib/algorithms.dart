import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';
import 'package:dart_crypto/atchops_better.dart';
import 'package:dart_crypto/atchops_boring.dart';
import 'package:dart_crypto/atchops_current.dart';
import 'package:dart_crypto/atchops_ffi.dart';

abstract class AsyncAtEncryptionAlgorithm {
  FutureOr<Uint8List> encrypt(Uint8List plainData);
  FutureOr<Uint8List> decrypt(Uint8List encryptedData);
}

abstract class AsyncSymmetricEncryptionAlgorithm
    extends AsyncAtEncryptionAlgorithm {
  @override
  FutureOr<Uint8List> encrypt(Uint8List plainData, {InitialisationVector iv});
  @override
  FutureOr<Uint8List> decrypt(Uint8List encryptedData,
      {InitialisationVector iv});
}

class Algorithms {
  final AsyncSymmetricEncryptionAlgorithm atChopsCurrent;
  final AsyncSymmetricEncryptionAlgorithm atChopsFfi;
  final AsyncSymmetricEncryptionAlgorithm atChopsBoring;
  final AsyncSymmetricEncryptionAlgorithm atChopsBetter;

  Algorithms(AESKey key)
      : atChopsCurrent = AtChopsCurrent(key),
        atChopsFfi = AtChopsFfi(base64.decode(key.key)),
        atChopsBoring = AtChopsBoring(base64.decode(key.key)),
        atChopsBetter = AtChopsBetter(base64.decode(key.key));

  Map<String, AsyncSymmetricEncryptionAlgorithm> get asMap => {
        "current": atChopsCurrent,
        "better": atChopsBetter,
        "boring": atChopsBoring,
        "mbedtls": atChopsFfi,
      };
}
