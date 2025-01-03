import 'package:flutter/material.dart';

class AppColors {
  static const darkGrey = Color.fromARGB(154, 113, 105, 80);
  static const menu = Color.fromARGB(190, 185, 175, 143);
  static const putihCerah = Color(0xFFFFFFFF);
  static const hitamgelap = Color.fromARGB(255, 0, 0, 0);
  static const birugelap = Color.fromARGB(255, 2, 20, 44);
  static const birugelapdiki = Color.fromARGB(226, 175, 190, 214);
  static const birugelapdikit = Color.fromARGB(255, 20, 67, 138);
  static const hijau = Color.fromARGB(255, 113, 183, 92);
  static const tbl = Color.fromARGB(181, 73, 89, 113);
  static const abubiru = Color.fromARGB(183, 27, 54, 94);
  static const abuabuabu = Color.fromARGB(255, 71, 71, 46);
  static const appbar = Color.fromARGB(255, 81, 81, 54);
  static const background = Color.fromARGB(154, 203, 200, 185);
  static const bg = Color.fromARGB(255, 245, 168, 15);
  static const table = Color.fromARGB(156, 167, 167, 108);
  static const kuning = Color.fromARGB(255, 242, 250, 2);
  static const merah = Color.fromARGB(255, 255, 0, 0);
  static const bgnav = Color.fromARGB(255, 95, 96, 78);
}

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  minimumSize: const Size(88, 54),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 27),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  backgroundColor: Colors.transparent,
  shadowColor: Colors.transparent,
);

class TextStyles {
  static TextStyle title = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.bold,
      fontSize: 18.0,
      color: AppColors.darkGrey);
  static TextStyle bodyy = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: AppColors.putihCerah);

  static TextStyle jabat = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: AppColors.putihCerah);

  static TextStyle body = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.normal,
      fontSize: 16.0,
      color: AppColors.darkGrey);
  static TextStyle deskriptom = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      color: AppColors.hitamgelap);
  static TextStyle judul = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 28.0,
      color: AppColors.abubiru);
  static TextStyle atas = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.normal,
      fontSize: 22.0,
      color: AppColors.putihCerah);
  static TextStyle judulBerita = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 28.0,
      color: AppColors.putihCerah);

  static TextStyle warna = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      color: AppColors.putihCerah);
  static TextStyle textfield = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      color: AppColors.birugelapdikit);
  static TextStyle textkecil = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w500,
      fontSize: 12.0,
      color: AppColors.hitamgelap);
  static TextStyle titleApp = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.bold,
      fontSize: 28.0,
      color: AppColors.putihCerah);

  static TextStyle heading = const TextStyle(
      fontFamily: 'Coffee',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.menu);
  static TextStyle judulTabel = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.w600,
      fontSize: 24.0,
      color: AppColors.putihCerah);
  static TextStyle deskripsi = const TextStyle(
      fontFamily: 'Schyler',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: AppColors.putihCerah);
}
