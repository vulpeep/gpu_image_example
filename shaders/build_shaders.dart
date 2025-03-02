import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter_gpu_shaders/environment.dart';

Future<void> main() async {
  final inputManifestFilePath =
      Uri(path: 'shaders/image/image.shaderbundle.json');
  final manifest =
      await File(inputManifestFilePath.toFilePath()).readAsString();
  final decodedManifest = convert.json.decode(manifest);
  String reconstitutedManifest = convert.json.encode(decodedManifest);

  final impellercExec = await findImpellerC();

  final shaderLibPath = impellercExec.resolve('./shader_lib');
  final impellercArgs = [
    '--sl=../assets/image.shaderbundle',
    '--shader-bundle=$reconstitutedManifest',
    '--include=${inputManifestFilePath.resolve('./').toFilePath()}',
    '--include=${shaderLibPath.toFilePath()}',
  ];

  final impellerc = Process.runSync(
    impellercExec.toFilePath(),
    impellercArgs,
    workingDirectory: './shaders',
  );
  if (impellerc.exitCode != 0) {
    throw Exception(
      'Failed to build shader bundle: ${impellerc.stderr}\n${impellerc.stdout}',
    );
  }
}
