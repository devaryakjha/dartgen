import 'dart:io';
import 'package:glob/glob.dart';
import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p show basename, dirname, separator;
import 'package:pub_semver/pub_semver.dart' show Version;

export 'package:analyzer/dart/ast/ast.dart';

List<String?> listFiles(String path,
    [bool recursive = false, bool allFiles = false]) {
  final files = <String?>[];
  try {
    var dir = Directory(path);

    final dartFile = allFiles ? Glob('**') : Glob('**.dart');

    List contents = dir.listSync(recursive: recursive);

    for (var fileOrDir in contents) {
      if (dartFile.matches(fileOrDir.path)) {
        files.add(fileOrDir.path);
      }
    }
  } catch (e) {
    print('Exception while listing files: $e');
  }
  files.sort();
  return files;
}

String fileReadString(String path) => File(path).readAsStringSync();

bool fileWriteString(String path, String data) {
  if (fileReadString(path) != data) {
    File(path).writeAsStringSync(data);
    return true;
  } else {
    return false;
  }
}

void log(String content) {
  stdout.write(content);
}

void logDone() => logln('\x1b[92mDONE\x1b[0m');
void logNoChange() => logln('\x1b[36mNO CHANGE\x1b[0m');

void logln(String content) {
  stdout.write(content + '\n');
}

CompilationUnit? parseDartFile(String path) {
  try {
    return parseString(content: fileReadString(path)).unit;
  } catch (e) {
    return null;
  }
}

List<ClassDeclaration> getClasses(CompilationUnit code) {
  return code.childEntities
      .whereType<ClassDeclaration>()
      .toList()
      .cast<ClassDeclaration>();
}

List<FunctionDeclaration> getMethods(CompilationUnit code) {
  return code.childEntities
      .whereType<FunctionDeclaration>()
      .toList()
      .cast<FunctionDeclaration>();
}

String getClassName(ClassDeclaration classdec) {
  return classdec.name.lexeme;
}

bool isStatic(MethodDeclaration field) {
  return field.isStatic;
}

String getMethodName(MethodDeclaration field) {
  return field.name.lexeme;
}

String getFieldName(FieldDeclaration field) {
  return field.fields.variables.first.name.lexeme;
}

String getFieldType(FieldDeclaration field) {
  return field.fields.type.toString();
}

String getFieldValue(FieldDeclaration field) {
  return field.fields.variables.first.initializer.toString();
}

String? getConstructorInput(FieldDeclaration field) {
  var mi = field.fields.variables.first.initializer as MethodInvocation;
  var val = mi.argumentList.arguments.first as SimpleStringLiteral;
  return val.stringValue;
}

String formatCode(String code, String version) {
  return DartFormatter(
    languageVersion: switch (version) {
      '3.7.0' => Version(3, 7, 0),
      '3.6.0' => Version(3, 6, 0),
      _ => Version(3, 0, 0),
    },
  ).format(code);
}

String getTag(Declaration i) {
  if (i.metadata.isEmpty) return '';

  final annotation = i.metadata[0];
  if (annotation.name.toString() != 'pragma') return '';
  final val = annotation.arguments!.arguments[0] as SimpleStringLiteral;

  return val.value;
}

List<String> getTagArgs(Declaration i) {
  if (i.metadata.isEmpty) return [];

  final annotation = i.metadata[0];
  if (annotation.name.toString() != 'pragma') return [];
  if (annotation.arguments!.arguments.length < 2) return [];
  final val = annotation.arguments!.arguments[1] as SimpleStringLiteral;

  return val.value.split(',');
}

/// Checks if a file path should be excluded based on exclusion patterns
bool shouldExcludeFile(String filePath, List<String> excludePatterns) {
  if (excludePatterns.isEmpty) return false;

  final fileName = p.basename(filePath);
  final relativePath = p.dirname(filePath);

  return excludePatterns.any((pattern) => switch (pattern) {
        // Exact file name match
        String s when s == fileName => true,

        // Glob patterns (most complex, check first)
        String s when s.contains('*') =>
          _matchesGlobPattern(s, filePath, relativePath),

        // Path patterns (containing directory separators)
        String s when s.contains(p.separator) => filePath.contains(s),

        // Wildcard patterns: "*text*"
        String s when s.startsWith('*') && s.endsWith('*') =>
          fileName.contains(s.substring(1, s.length - 1)),

        // Suffix patterns: "*.dart"
        String s when s.startsWith('*') => fileName.endsWith(s.substring(1)),

        // Prefix patterns: "test*"
        String s when s.endsWith('*') =>
          fileName.startsWith(s.substring(0, s.length - 1)),

        // Simple string matching (fallback)
        _ => filePath.contains(pattern),
      });
}

/// Helper function to handle glob pattern matching
bool _matchesGlobPattern(String pattern, String filePath, String relativePath) {
  try {
    final glob = Glob(pattern);
    return glob.matches(filePath) || glob.matches(relativePath);
  } catch (e) {
    // If pattern is not a valid glob, treat as simple string match
    return filePath.contains(pattern);
  }
}

/// Lists Dart files excluding those that match exclusion patterns
List<String?> listDartFilesWithExclusions(
    String path, List<String> excludePatterns,
    [bool recursive = false]) {
  final allFiles = listFiles(path, recursive, false);
  return allFiles
      .where(
          (file) => file != null && !shouldExcludeFile(file, excludePatterns))
      .toList();
}
