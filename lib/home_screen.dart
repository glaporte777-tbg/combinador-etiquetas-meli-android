import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'pdf_processor.dart';

const Color _kBg = Color(0xFF0F1115);
const Color _kCard = Color(0xFF1A1D24);
const Color _kFg = Color(0xFFE8EAED);
const Color _kSub = Color(0xFF9AA0A6);
const Color _kAccent = Color(0xFFFFE600);
const Color _kAccentFg = Color(0xFF1A1D24);
const Color _kBorder = Color(0xFF2A2E37);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _files = [];
  bool _processing = false;
  String _status = 'Todavía no agregaste etiquetas.';

  int get _pageCount => _files.isEmpty ? 0 : (_files.length + 2) ~/ 3;

  void _refreshStatus() {
    _status = _files.isEmpty
        ? 'Todavía no agregaste etiquetas.'
        : '${_files.length} etiqueta(s)  →  $_pageCount hoja(s) A4';
  }

  Future<void> _agregar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        if (f.path != null && !_files.contains(f.path)) {
          _files.add(f.path!);
        }
      }
      _refreshStatus();
    });
  }

  void _quitar(int index) {
    setState(() {
      _files.removeAt(index);
      _refreshStatus();
    });
  }

  void _limpiar() {
    setState(() {
      _files.clear();
      _refreshStatus();
    });
  }

  Future<void> _generar() async {
    if (_files.isEmpty) return;
    setState(() {
      _processing = true;
      _status = 'Procesando...';
    });
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = '${dir.path}/etiquetas_combinadas.pdf';
      final pages = await processPdfs(_files, outputPath);
      setState(() => _status = 'Listo: ${_files.length} etiqueta(s) en $pages hoja(s).');
      await Share.shareXFiles(
        [XFile(outputPath, mimeType: 'application/pdf')],
        subject: 'etiquetas_combinadas.pdf',
      );
    } catch (e) {
      setState(() => _status = 'Error al generar.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo generar el PDF: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Combinar Etiquetas',
                style: TextStyle(color: _kFg, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Juntá tus etiquetas de Mercado Libre: 3 por hoja A4.',
                style: TextStyle(color: _kSub, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
                        child: Text(
                          'Etiquetas seleccionadas (en orden):',
                          style: TextStyle(color: _kSub, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: _files.isEmpty
                            ? const Center(
                                child: Text(
                                  'Ninguna etiqueta agregada',
                                  style: TextStyle(color: _kSub, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 8),
                                itemCount: _files.length,
                                itemBuilder: (_, i) {
                                  final name = _files[i].split(Platform.pathSeparator).last;
                                  return ListTile(
                                    dense: true,
                                    leading: Text(
                                      '${i + 1}.',
                                      style: const TextStyle(color: _kSub, fontSize: 13),
                                    ),
                                    title: Text(
                                      name,
                                      style: const TextStyle(color: _kFg, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      color: _kSub,
                                      onPressed: _processing ? null : () => _quitar(i),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      label: '+ Agregar',
                      onPressed: _processing ? null : _agregar,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Limpiar',
                      onPressed: _processing ? null : _limpiar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _status,
                style: const TextStyle(color: _kSub, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (_processing || _files.isEmpty) ? null : _generar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: _kAccentFg,
                  disabledBackgroundColor: const Color(0xFF3D3A1A),
                  disabledForegroundColor: const Color(0xFF7A7430),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: _processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _kAccentFg),
                      )
                    : const Text(
                        'Generar hoja A4',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset('assets/logo.png', height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBorder,
        foregroundColor: _kFg,
        disabledBackgroundColor: const Color(0xFF1E2029),
        disabledForegroundColor: const Color(0xFF555960),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
