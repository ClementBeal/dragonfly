import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BrowserInputTextField extends StatelessWidget {
  final RenderTreeInputText r;

  const BrowserInputTextField({
    super.key,
    required this.r,
  });

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
        obscureText: r.isPassord,
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
      onTap: () {
        FormState? form = Form.maybeOf(context);

        form?.validate();
      },
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
          child: AbsorbPointer(child: Text(r.value ?? "")),
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
      onTap: () {
        Form.maybeOf(context)?.reset();
      },
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
          child: AbsorbPointer(child: Text(r.value ?? "")),
        ),
      ),
    );
  }
}

class BrowserInputFile extends StatefulWidget {
  final RenderTreeInputFile r;

  const BrowserInputFile({
    super.key,
    required this.r,
  });

  @override
  State<BrowserInputFile> createState() => _BrowserInputFileState();
}

class _BrowserInputFileState extends State<BrowserInputFile> {
  PlatformFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          PlatformFile file = result.files.first;
          setState(() {
            selectedFile = file;
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          DecoratedBox(
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
              child: AbsorbPointer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Browse..."),
                  ],
                ),
              ),
            ),
          ),
          AbsorbPointer(
            child: Text(
              selectedFile?.name ?? "No file selected.",
            ),
          ),
        ],
      ),
    );
  }
}

class BrowserInputCheckbox extends StatelessWidget {
  const BrowserInputCheckbox({super.key, required this.r});

  final RenderTreeInputCheckbox r;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(14),
      foregroundPainter: CustomCheckboxPainter(
        isChecked: r.isChecked ?? false,
        color: Colors.blue,
      ),
    );
  }
}

class CustomCheckboxPainter extends CustomPainter {
  final Color color;
  final bool isChecked;

  CustomCheckboxPainter({required this.color, required this.isChecked});

  @override
  void paint(Canvas canvas, Size size) {
    if (isChecked) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;

      // Draw the square
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );

      paint.color = Colors.white;

      // Draw the checkmark
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.3),
        Offset(size.width * 0.5, size.height * 0.7),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.7),
        Offset(size.width * 0.8, size.height * 0.2),
        paint,
      );
    } else {
      final paint = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw the square
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (oldDelegate as CustomCheckboxPainter).color != color ||
        (oldDelegate).isChecked != isChecked;
  }
}

class BrowserInputRadio extends StatelessWidget {
  const BrowserInputRadio({super.key, required this.r});

  final RenderTreeInputRadio r;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(14),
      foregroundPainter: CustomRadioPainter(
        isChecked: r.isChecked ?? false,
        color: Colors.blue,
      ),
    );
  }
}

class CustomRadioPainter extends CustomPainter {
  final Color color;
  final bool isChecked;

  CustomRadioPainter({required this.color, required this.isChecked});

  @override
  void paint(Canvas canvas, Size size) {
    if (isChecked) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        size.center(Offset.zero),
        size.width / 2,
        paint,
      );

      paint.style = PaintingStyle.fill;

      canvas.drawCircle(
        size.center(Offset.zero),
        size.width * 0.25,
        paint,
      );
    } else {
      final paint = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw the square
      canvas.drawCircle(
        size.center(Offset.zero),
        size.width / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (oldDelegate as CustomRadioPainter).color != color ||
        (oldDelegate).isChecked != isChecked;
  }
}
