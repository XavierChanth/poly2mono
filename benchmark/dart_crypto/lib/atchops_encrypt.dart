import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';
import 'package:at_chops/types.dart';
import 'package:dart_crypto/algorithms.dart';
import 'package:encrypt/encrypt.dart';

class AtChopsEncrypt extends AsyncSymmetricEncryptionAlgorithm {
  final _AESEncryptionAlgo _algo;
  AtChopsEncrypt(AESKey key) : _algo = _AESEncryptionAlgo(key);
  @override
  Uint8List decrypt(Uint8List encryptedData, {InitialisationVector? iv}) {
    return _algo.decrypt(encryptedData, iv: iv);
  }

  @override
  Uint8List encrypt(Uint8List plainData, {InitialisationVector? iv}) {
    return _algo.encrypt(plainData, iv: iv);
  }
}

class _AESEncryptionAlgo implements SymmetricEncryptionAlgorithm {
  final AESKey _aesKey;
  _AESEncryptionAlgo(this._aesKey);

  @override
  Uint8List encrypt(Uint8List plainData, {InitialisationVector? iv}) {
    var aesEncrypter =
        Encrypter(AES(Key.fromBase64(_aesKey.key), padding: null));
    final encrypted =
        aesEncrypter.encryptBytes(plainData, iv: _getIVFromBytes(iv?.ivBytes));
    return encrypted.bytes;
  }

  @override
  Uint8List decrypt(Uint8List encryptedData, {InitialisationVector? iv}) {
    var aesKey = AES(Key.fromBase64(_aesKey.toString()), padding: null);
    var decrypter = Encrypter(aesKey);
    return Uint8List.fromList(decrypter.decryptBytes(Encrypted(encryptedData),
        iv: _getIVFromBytes(iv?.ivBytes)));
  }

  IV? _getIVFromBytes(Uint8List? ivBytes) {
    if (ivBytes != null) {
      return IV(ivBytes);
    }
    // From the bad old days when we weren't setting IVs
    return IV(Uint8List(16));
  }
}
