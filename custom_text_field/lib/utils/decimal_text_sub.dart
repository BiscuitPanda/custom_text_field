class DecimalTextSub{
  static String subString(String value,{int keepDecimalLength}) {
    if (value != null && value.isNotEmpty) {
      if (value == ".") {
        //第一个数为.
        value = "0.";
      } else if (value.contains(".")) {
        if (value.lastIndexOf(".") != value.indexOf(".")) {
          //输入了2个小数点
          value =
              value.substring(0, value.lastIndexOf('.'));
        } else if (value.length - 1 - value.indexOf(".") > (keepDecimalLength??2)) {
          //输入了1个小数点 小数点后两位
          value =
              value.substring(0, value.indexOf(".") + (keepDecimalLength??2)+1);
        }
      }

      return value;
    }
    return value;
  }
}