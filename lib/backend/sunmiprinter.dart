import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

class Sunmi {
  // initialize sunmi printer
  Future<void> initialize() async {
    await SunmiPrinter.bindingPrinter();
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  }

  // print image
  Future<void> printLogoImage() async {
    await SunmiPrinter.lineWrap(1);
    Uint8List byte = await _getImageFromAsset('assets/images/freshice.png');
    await SunmiPrinter.printImage(byte);
    await SunmiPrinter.lineWrap(1);
  }

  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }

  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

  Future<void> printHeadingText(String text) async {
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText(text,
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.lineWrap(1);
  }

  Future<void> printSubHeadingText(String text) async {
    await SunmiPrinter.printText(text,
        style: SunmiStyle(
          fontSize: SunmiFontSize.SM,
          bold: false,
          align: SunmiPrintAlign.CENTER,
        ));
  }

  Future<void> printTitleText(String text) async {
    await SunmiPrinter.printText(text,
        style: SunmiStyle(
          fontSize: SunmiFontSize.SM,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.lineWrap(1);
  }

  Future<void> headingText(String invoiceid, String invoicedate,
      String customer, String customertrn, String emirate) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.setCustomFontSize(18);
    await _printLabeledRow('Inv Id    :', invoiceid);
    await _printLabeledRow('Inv Date  :', invoicedate);
    await _printLabeledRow('Customer  :', customer);
    await _printLabeledRow('Emirate   :', emirate);
    await _printLabeledRow('TRN       :', customertrn);
  }

  // Prints a label/value row, wrapping [value] onto multiple lines when it is
  // longer than [valueWidth]. The label only appears on the first line; the
  // label column stays blank on the wrapped continuation lines.
  Future<void> _printLabeledRow(String label, String value,
      {int labelWidth = 13, int valueWidth = 26}) async {
    final lines = _wrapText(value, valueWidth);
    if (lines.isEmpty) lines.add('');
    for (var i = 0; i < lines.length; i++) {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: i == 0 ? label : '',
          width: labelWidth,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          text: lines[i],
          width: valueWidth,
          align: SunmiPrintAlign.LEFT,
        ),
      ]);
    }
  }

  // Splits [text] into chunks no longer than [width], breaking on word
  // boundaries where possible and hard-splitting words longer than [width].
  List<String> _wrapText(String text, int width) {
    final words = text.trim().split(RegExp(r'\s+'));
    final lines = <String>[];
    var current = '';
    for (final word in words) {
      if (word.isEmpty) continue;
      var w = word;
      while (w.length > width) {
        if (current.isNotEmpty) {
          lines.add(current);
          current = '';
        }
        lines.add(w.substring(0, width));
        w = w.substring(width);
      }
      if (current.isEmpty) {
        current = w;
      } else if (current.length + 1 + w.length <= width) {
        current = '$current $w';
      } else {
        lines.add(current);
        current = w;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }

  Future<void> printQRCode(String text) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printQRCode(text);
    await SunmiPrinter.lineWrap(4);
  }

  Future<void> printRowAndColumns(column1, column2, column3, column4) async {
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.setCustomFontSize(18);
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$column1",
        width: 8,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: "$column2",
        width: 8,
        align: SunmiPrintAlign.RIGHT,
      ),
      ColumnMaker(
        text: "$column3",
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
      ColumnMaker(
        text: "$column4",
        width: 13,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);
    await SunmiPrinter.line();
  }

  Future<void> printItemRowAndColumns(
      column1, column2, column3, column4) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.setCustomFontSize(18);
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$column1",
        width: 41,
        align: SunmiPrintAlign.LEFT,
      ),
    ]);
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$column2",
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
      ColumnMaker(
        text: "$column3",
        width: 14,
        align: SunmiPrintAlign.RIGHT,
      ),
      ColumnMaker(
        text: "$column4",
        width: 14,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);
  }

  Future<void> closePrinter() async {
    await SunmiPrinter.unbindingPrinter();
  }

  Future<Map<String, dynamic>> printReceipt(
      String companyname,
      String address,
      String phone,
      String trn,
      List<dynamic> items,
      String invoiceid,
      String invoicedate,
      String customer,
      String emirate,
      String customertrn,
      String subtotal,
      String vat,
      String grandtotal) async {
    try {
      print("this is the customer");
      print(customer);
      print(emirate);
      print(customertrn);
      await initialize();
      await printLogoImage();
      await printHeadingText(companyname);
      await printSubHeadingText(address);
      await printSubHeadingText(phone);
      await printSubHeadingText(trn);
      await SunmiPrinter.lineWrap(1);
      await printTitleText("TAX INVOICE");
      await headingText(invoiceid, invoicedate, customer, customertrn, emirate);
      await printRowAndColumns("Item", "Qty", "Rate", "Total");
      for (int i = 0; i < items.length; i++) {
        await printItemRowAndColumns(
            "${items[i].partnumber.toString()} / ${items[i].description.toString()}",
            items[i].quantity.toString(),
            num.parse(items[i].rate.toString()).toStringAsFixed(2),
            num.parse(items[i].subnet.toString()).toStringAsFixed(2));
      }
      await SunmiPrinter.line();
      await SunmiPrinter.bold();
      await SunmiPrinter.setCustomFontSize(18);
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: 'Sub Total',
          width: 25,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          text: num.parse(subtotal).toStringAsFixed(2),
          width: 14,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: 'VAT',
          width: 25,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          text: num.parse(vat).toStringAsFixed(2),
          width: 14,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
      await SunmiPrinter.line();
      await SunmiPrinter.bold();
      await SunmiPrinter.setCustomFontSize(18);
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: 'Grand Total',
          width: 25,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          text: num.parse(grandtotal).toStringAsFixed(2),
          width: 14,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
      await SunmiPrinter.lineWrap(4);
      await SunmiPrinter.cut();
      await closePrinter();
      return {"status": "success", "message": "Successfull"};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }
}
