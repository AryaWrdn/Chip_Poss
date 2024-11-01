import 'package:chip_pos/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.controller,
    required this.textInputType,
    required this.textInputAction,
    required this.hint,
    this.isObscure = false,
    this.haSuffix = false,
    this.onPressed,
    this.icon,
    this.readOnly = false,
    this.inputFormatters,
    this.prefixIcon,
    this.textCapitalization = TextCapitalization.none,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final String hint;
  final bool isObscure;
  final bool haSuffix;
  final VoidCallback? onPressed;
  final IconData? icon; // Pastikan ini ada
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure =
        widget.isObscure; // Inisialisasi _isObscure dengan nilai dari widget
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure; // Ubah status _isObscure
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(82, 190, 170, 103),
        borderRadius: BorderRadius.circular(99),
      ),
      child: TextField(
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        readOnly: widget.readOnly,
        controller: widget.controller,
        style: TextStyles.warna,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        obscureText: _isObscure,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon ??
              (widget.icon != null
                  ? Icon(widget.icon) // Menampilkan ikon jika ada
                  : null) ??
              (widget.haSuffix
                  ? IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    )
                  : null),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.0,
              color: Color.fromARGB(255, 130, 131, 114),
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2.0,
              color: Color.fromARGB(112, 0, 0, 0),
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          hintText: widget.hint,
          hintStyle: TextStyles.warna,
        ),
      ),
    );
  }
}
