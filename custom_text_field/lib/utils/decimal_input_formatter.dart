import 'package:flutter/services.dart';

///description 小数点后限制两位 需要配合以下限制:
/// WhitelistingTextInputFormatter(RegExp("[0-9.]")),
/// LengthLimitingTextInputFormatter(9),

class DecimalTextInputFormatter extends TextInputFormatter {
  /// 保留小数点后位数,默认两位
  final int keepDecimalLength;

  DecimalTextInputFormatter({this.keepDecimalLength});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String newValueText = newValue.text;

    if (newValueText == ".") {
      //第一个数为.
      newValueText = "0.";
    } else if (newValueText.contains(".")) {
      if (newValueText.lastIndexOf(".") != newValueText.indexOf(".")) {
        //输入了2个小数点
        newValueText = newValueText.substring(0, newValueText.lastIndexOf('.'));
      } else if (newValueText.length - 1 - newValueText.indexOf(".") > (keepDecimalLength??2)) {
        //输入了1个小数点 小数点后两位
        newValueText = newValueText.substring(
            0, newValueText.indexOf(".") + (keepDecimalLength ?? 2) + 1);
      }
    }

    return TextEditingValue(
      text: newValueText,
      selection: new TextSelection.collapsed(offset: newValueText.length),
    );
  }
}
