import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';
import 'package:dart_crypto/atchops_better.dart';
import 'package:dart_crypto/atchops_boring.dart';
import 'package:dart_crypto/atchops_crypto.dart';
import 'package:dart_crypto/atchops_encrypt.dart';
import 'package:dart_crypto/atchops_mbedtls.dart';

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
  final AsyncSymmetricEncryptionAlgorithm atChopsEncrypt;
  final AsyncSymmetricEncryptionAlgorithm atChopsBetter;
  final AsyncSymmetricEncryptionAlgorithm atChopsBoring;
  final AsyncSymmetricEncryptionAlgorithm atChopsCrypto;
  final AsyncSymmetricEncryptionAlgorithm atChopsMbedtls;

  Algorithms(AESKey key)
      : atChopsBetter = AtChopsBetter(base64.decode(key.key)),
        atChopsBoring = AtChopsBoring(base64.decode(key.key)),
        atChopsCrypto = AtChopsCrypto(base64.decode(key.key)),
        atChopsEncrypt = AtChopsEncrypt(key),
        atChopsMbedtls = AtChopsMbedtls(base64.decode(key.key));

  Map<String, AsyncSymmetricEncryptionAlgorithm> get asMap => {
        "better": atChopsBetter,
        "boring": atChopsBoring,
        "crypto": atChopsCrypto,
        "encrypt": atChopsEncrypt,
        // "mbedtls": atChopsMbedtls, // ffi stability requires more work, hence disabled
      };
}
