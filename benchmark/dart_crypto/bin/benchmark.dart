import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:at_chops/at_chops.dart';
import 'package:chalk/chalk.dart';
import 'package:dart_crypto/algorithms.dart';

Future<void> main(args) async {
  int? nBytes;
  if (args.length > 0) {
    nBytes = int.tryParse(args[0]);
  }
  print("");
  print("AtChops benchmark");
  print(
      "================================================================================");
  print("Arguments: ${args.toString()}");
  int byteSize = pow(2, 8).toInt() - 1;
  Uint8List plainText = Uint8List(0);
  if (nBytes == null) {
    if (args.length > 0) {
      plainText = Uint8List.fromList(args[0].codeUnits);
    } else {
      nBytes = defaultNBytes;
    }
  } else {
    print("Generating $nBytes bytes...");
    var random = Random.secure();
    final randBytes = List.generate(nBytes, (_) => random.nextInt(byteSize));
    final randString = base64Encode(randBytes);
    plainText = Uint8List.fromList(randString.codeUnits);
    print("Generated $nBytes bytes");
  }
  int sum = 0;
  for (var i = 0; i < plainText.length; i++) {
    if (plainText[i] > byteSize || plainText[i] < 0) {
      sum++;
    }
  }
  print("$sum total bytes exceed byte range");
  final iv = AtChopsUtil.generateRandomIV(16);

  late DateTime start;
  late DateTime middle;
  late DateTime end;
  late Uint8List cipherText;
  late Uint8List decryptedText;

  var key =
      AtChopsUtil.generateSymmetricKey(EncryptionKeyType.aes256) as AESKey;
  final algorithms = Algorithms(key);

  Map<String, Uint8List> cipherResults = {};
  Map<String, Uint8List> decryptedResults = {};

  bool skipBoring = false;
  if (plainText.lengthInBytes > 3072) {
    print("Number of bytes exceeds boring limit, it will be skipped");
    skipBoring = true;
  }

  print("");
  print("Time checks (ms)");
  print(
      "================================================================================");
  print("algo   \t: enc\tdec\ttotal");
  for (var algo in algorithms.asMap.entries) {
    if (skipBoring && algo.key == "boring") continue;
    var plainTextClone = Uint8List.fromList(plainText);

    // Deep clone - webcrypto uses the same memory
    var iv1 = InitialisationVector(Uint8List.fromList(iv.ivBytes));
    var iv2 = InitialisationVector(Uint8List.fromList(iv.ivBytes));

    start = DateTime.now();
    cipherText = await algo.value.encrypt(plainTextClone, iv: iv1);
    middle = DateTime.now();
    decryptedText = await algo.value.decrypt(cipherText, iv: iv2);
    end = DateTime.now();

    print(
        "${algo.key}\t: ${middle.millisecondsSinceEpoch - start.millisecondsSinceEpoch}\t${end.millisecondsSinceEpoch - middle.millisecondsSinceEpoch}\t${end.millisecondsSinceEpoch - start.millisecondsSinceEpoch}");

    cipherResults[algo.key] = Uint8List.fromList(cipherText);
    decryptedResults[algo.key] = Uint8List.fromList(decryptedText);
  }

  print("");
  print("Encryption sanity checks");
  print(
      "================================================================================");
  for (var result in decryptedResults.entries) {
    bool same = compare(plainText, result.value);
    print("${result.key}\t: ${coloredBool(same)} ");
    // try {
    //   print("decryptedText: ${String.fromCharCodes(decryptedText)}");
    // } catch (_) {}
  }

  print("");
  print("Ciphertext size checks (bytes)");
  print(
      "================================================================================");
  for (var cipherResult in cipherResults.entries) {
    print("${cipherResult.key}\t: ${cipherResult.value.length}");
  }

  print("");
  print("Compatibility checks");
  print(
      "================================================================================");
  for (var cipherResult in cipherResults.entries) {
    for (var algo in cipherResults.keys) {
      if (algo == cipherResult.key) continue;
      try {
        decryptedText =
            await algorithms.asMap[algo]!.decrypt(cipherResult.value, iv: iv);
        bool same = compare(plainText, decryptedText);
        print("${cipherResult.key} -> $algo\t: ${coloredBool(same)}");
      } catch (_) {
        print("${cipherResult.key} -> $algo\t: ${chalk.red("FAILED DECRYPT")}");
      }
    }
    print("");
  }

  print("");
}

// Boring has a limit of 3072 bytes (4096 after base64Encode is applied)
const int defaultNBytes = 3072;

String coloredBool(bool same) {
  return (same) ? chalk.green("true") : chalk.red("false");
}

bool compare(Uint8List a, Uint8List b) {
  bool same = a.length == b.length;
  if (same) {
    try {
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) {
          same = false;
          break;
        }
      }
    } catch (_) {
      same = false;
    }
  }
  return same;
}
