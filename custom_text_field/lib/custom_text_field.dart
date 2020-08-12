library custom_text_field;

import 'package:custom_text_field/utils/decimal_text_sub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final double contentFontSize;
  final String content;
  final Color contentColor;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final VoidCallback onTap;
  final String hintText;
  final Color hintColor;
  final double hintTextFontSize;
  final Color bgColor;
  final bool enabled;
  final FocusNode focusNode;
  final int keepDecimalLength;
  final Widget clearIcon;

  CustomTextField(this.content,
      {Key key,
      this.contentColor = const Color(0xff000000),
      this.contentFontSize,
      this.onChanged,
      this.inputFormatters,
      this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
      this.onTap,
      this.hintText,
      this.hintColor = const Color(0x4C000000),
      this.hintTextFontSize,
      this.bgColor,
      this.enabled = true,
      this.focusNode,
      this.keepDecimalLength,this.clearIcon})
      : super(key: key);

  @override
  _CustomTextFieldState createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String _content;
  GlobalKey<_MyOffstageState> _clearKey = GlobalKey();
  FocusNode _focusNode;
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.content);
    _focusNode = widget?.focusNode ?? FocusNode();
    _focusNode?.addListener(() {
      _clearKey.currentState.update(
          (!((_content?.isNotEmpty ?? false) && _focusNode.hasFocus)) ?? true);
    });
    _content = widget.content;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _content = widget?.content;
  }

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = _content ?? '';

    ///设置光标在末尾
    _textEditingController.selection = TextSelection.fromPosition(TextPosition(
        affinity: TextAffinity.downstream, offset: _content?.length ?? 0));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextField(
            focusNode: _focusNode,
            enabled: widget?.enabled,
            style: TextStyle(
                fontSize: widget.contentFontSize ?? 15,
                color: widget.contentColor),
            controller: _textEditingController,
            keyboardType: widget?.keyboardType,
            onTap: () {
              widget?.onTap?.call();
            },
            onChanged: (val) {
              ///这里再次截取是为了处理flutter TextField 本身设置正则后
              ///在Android端 仍然会多走一次onChanged方法多输入一位数字的问题
              if (widget?.keyboardType ==
                      TextInputType.numberWithOptions(decimal: true) ||
                  widget?.keyboardType == TextInputType.number) {
                val = DecimalTextSub.subString(val,
                    keepDecimalLength: widget.keepDecimalLength);
              }
              _content = val;
              widget.onChanged?.call(_content);
              _clearKey.currentState.update(
                  (!((_content?.isNotEmpty ?? false) && _focusNode.hasFocus)) ??
                      true);
            },
            inputFormatters: widget?.inputFormatters,
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                hintText: widget?.hintText ?? '请输入',
                hintStyle: TextStyle(
                  fontSize: widget.hintTextFontSize ?? 15,
                  color: widget.hintColor,
                ),
                border: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: widget?.bgColor ?? Colors.white),
          ),
        ),
        _MyOffstage(
          _clearKey,
          clearIcon: widget.clearIcon,
          onChanged: (val) {
            setState(() {
              _content = '';
            });
            widget.onChanged?.call(_content);
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    _focusNode?.unfocus();
    super.dispose();
  }
}

class _MyOffstage extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Widget clearIcon;
  const _MyOffstage(Key key, {this.onChanged,this.clearIcon}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyOffstageState();
}

class _MyOffstageState extends State<_MyOffstage> {
  bool _offstage = true;

  update(bool val) {
    setState(() {
      _offstage = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
        child: GestureDetector(
          child: widget.clearIcon??Icon(
            Icons.clear,
            size: 16,
          ),
          onTap: () {
            _offstage = true;
            widget.onChanged?.call('');
          },
        ),
        offstage: _offstage);
  }
}
