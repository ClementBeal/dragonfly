import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';

class BrowserInputTextField extends StatelessWidget {
  final RenderTreeInputText r;

  const BrowserInputTextField({super.key, required this.r});

  Size _textSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );

    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final size = _textSize("a" * r.size);

    return SizedBox(
      width: size.width,
      child: TextFormField(
        cursorHeight: size.height,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(
              width: 2,
              color: Colors.black,
            ),
          ),
          hintText: r.placeholder,
          contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        ),
        maxLength: r.maxLength,
        readOnly: r.isReadOnly ?? false,
      ),
    );
  }
}

class BrowserInputSubmit extends StatelessWidget {
  const BrowserInputSubmit({
    super.key,
    required this.r,
  });

  final RenderTreeInputSubmit r;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Colors.black,
          ),
          color: const Color(0xffe9e9ed),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          child: Text(r.value ?? ""),
        ),
      ),
    );
  }
}

class BrowserInputReset extends StatelessWidget {
  const BrowserInputReset({
    super.key,
    required this.r,
  });

  final RenderTreeInputReset r;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Colors.black,
          ),
          color: const Color(0xffe9e9ed),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          child: Text(r.value ?? ""),
        ),
      ),
    );
  }
}
