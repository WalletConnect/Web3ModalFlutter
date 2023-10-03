import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3modal_flutter/theme/w3m_colors.dart';
import 'package:web3modal_flutter/theme/w3m_radiuses.dart';
import 'package:web3modal_flutter/theme/w3m_text_styles.dart';

part 'w3m_theme_data.freezed.dart';

@freezed
class Web3ModalThemeData with _$Web3ModalThemeData {
  const factory Web3ModalThemeData({
    @Default(Web3ModalColors.lightMode) Web3ModalColors lightColors,
    @Default(Web3ModalColors.darkMode) Web3ModalColors darkColors,
    @Default(Web3ModalTextStyles.textStyle) Web3ModalTextStyles textStyles,
    @Default(Web3ModalRadiuses()) Web3ModalRadiuses radiuses,
  }) = _Web3ModalThemeData;
}
