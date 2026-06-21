import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart' as pdflib;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart';

const int _kCols = 3;
const double _kA4LW = 841.890;
const double _kA4LH = 595.276;
const double _kMargin = 14.0;
const double _kGap = 12.0;
const double _kPad = 5.0;

const double _kDpi = 150.0;
const double _kDpiScale = _kDpi / 72.0;

Uint8List _bgraToRgba(Uint8List bgra, int w, int h) {
  final rgba = Uint8List(bgra.length);
  for (int i = 0; i < w * h; i++) {
    final o = i * 4;
    rgba[o] = bgra[o + 2];     // R ← B
    rgba[o + 1] = bgra[o + 1]; // G
    rgba[o + 2] = bgra[o];     // B ← R
    rgba[o + 3] = bgra[o + 3]; // A
  }
  return rgba;
}

class _Bbox {
  final double left, top, right, bottom;
  const _Bbox(this.left, this.top, this.right, this.bottom);
  double get w => right - left;
  double get h => bottom - top;
}

typedef _RenderResult = ({Uint8List rgba, int imgW, int imgH});

Future<_RenderResult> _renderPage(String path) async {
  final doc = await PdfDocument.openFile(path);
  try {
    final page = doc.pages[0];
    final imgW = (page.width * _kDpiScale).round();
    final imgH = (page.height * _kDpiScale).round();

    final rendered = await page.render(
      fullWidth: imgW.toDouble(),
      fullHeight: imgH.toDouble(),
      backgroundColor: const Color(0xFFFFFFFF),
    );
    if (rendered == null) throw Exception('No se pudo renderizar: $path');

    // PdfImage.pixels is raw RGBA/BGRA — normalize to RGBA if needed
    final Uint8List rgba;
    if (rendered.format == ui.PixelFormat.bgra8888) {
      rgba = _bgraToRgba(rendered.pixels, rendered.width, rendered.height);
    } else {
      rgba = Uint8List.fromList(rendered.pixels);
    }
    rendered.dispose();
    return (rgba: rgba, imgW: imgW, imgH: imgH);
  } finally {
    await doc.dispose();
  }
}

_Bbox _detectBbox(Uint8List rgba, int imgW, int imgH) {
  int minX = imgW, minY = imgH, maxX = 0, maxY = 0;
  bool found = false;

  for (int y = 0; y < imgH; y++) {
    for (int x = 0; x < imgW; x++) {
      final i = (y * imgW + x) * 4;
      if (rgba[i] < 240 || rgba[i + 1] < 240 || rgba[i + 2] < 240) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        found = true;
      }
    }
  }

  if (!found) return _Bbox(0, 0, imgW.toDouble(), imgH.toDouble());

  final padPx = _kPad * _kDpiScale;
  return _Bbox(
    (minX - padPx).clamp(0.0, imgW.toDouble()),
    (minY - padPx).clamp(0.0, imgH.toDouble()),
    (maxX + padPx).clamp(0.0, imgW.toDouble()),
    (maxY + padPx).clamp(0.0, imgH.toDouble()),
  );
}

Uint8List _cropToPng(Uint8List rgba, int imgW, int imgH, _Bbox bbox) {
  final src = img.Image.fromBytes(
    width: imgW,
    height: imgH,
    bytes: rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  final cropped = img.copyCrop(
    src,
    x: bbox.left.round(),
    y: bbox.top.round(),
    width: bbox.w.round(),
    height: bbox.h.round(),
  );
  return Uint8List.fromList(img.encodePng(cropped));
}

/// Combina los PDF de [inputPaths] en [outputPath] (A4 apaisado, 3 por hoja).
/// Devuelve la cantidad de hojas generadas.
Future<int> processPdfs(List<String> inputPaths, String outputPath) async {
  if (inputPaths.isEmpty) throw Exception('No seleccionaste ninguna etiqueta.');

  final n = inputPaths.length;
  final totalPages = (n + _kCols - 1) ~/ _kCols;
  final cellW = (_kA4LW - 2 * _kMargin - (_kCols - 1) * _kGap) / _kCols;
  final cellH = _kA4LH - 2 * _kMargin;

  final pdfDoc = pw.Document();

  for (int pageIdx = 0; pageIdx < totalPages; pageIdx++) {
    final startIdx = pageIdx * _kCols;
    final endIdx = min(startIdx + _kCols, n);
    final countOnPage = endIdx - startIdx;
    final widgets = <pw.Widget>[];

    for (int localCol = 0; localCol < countOnPage; localCol++) {
      final globalIdx = startIdx + localCol;
      final (:rgba, :imgW, :imgH) = await _renderPage(inputPaths[globalIdx]);

      final bbox = _detectBbox(rgba, imgW, imgH);
      final pngBytes = _cropToPng(rgba, imgW, imgH, bbox);

      final bboxWPts = bbox.w / _kDpiScale;
      final bboxHPts = bbox.h / _kDpiScale;
      final scale = min(cellW / bboxWPts, cellH / bboxHPts);
      final nw = bboxWPts * scale;
      final nh = bboxHPts * scale;

      int colReal = localCol;
      if (pageIdx == totalPages - 1 && countOnPage < _kCols) {
        colReal = localCol + (_kCols - countOnPage);
      }

      final cellX = _kMargin + colReal * (cellW + _kGap);
      final tx = cellX + (cellW - nw) / 2;
      final ty = _kMargin + (cellH - nh) / 2;

      widgets.add(
        pw.Positioned(
          left: tx,
          bottom: ty,
          child: pw.Image(pw.MemoryImage(pngBytes), width: nw, height: nh),
        ),
      );
    }

    pdfDoc.addPage(
      pw.Page(
        pageFormat: const pdflib.PdfPageFormat(
          _kA4LW * pdflib.PdfPageFormat.point,
          _kA4LH * pdflib.PdfPageFormat.point,
        ),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Stack(children: widgets),
      ),
    );
  }

  final file = File(outputPath);
  await file.writeAsBytes(await pdfDoc.save());
  return totalPages;
}
