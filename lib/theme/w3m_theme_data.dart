import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3modal_flutter/theme/w3m_colors.dart';
import 'package:web3modal_flutter/theme/w3m_text_styles.dart';

part 'w3m_theme_data.freezed.dart';

@freezed
class Web3ModalThemeData with _$Web3ModalThemeData {
  const factory Web3ModalThemeData({
    required Web3ModalColors colors,
    required Web3ModalTextStyles textStyles,
  }) = _Web3ModalThemeData;

  static const darkMode = Web3ModalThemeData(
    colors: Web3ModalColors.darkMode,
    textStyles: Web3ModalTextStyles.textStyle,
  );

  static const lightMode = Web3ModalThemeData(
    colors: Web3ModalColors.lightMode,
    textStyles: Web3ModalTextStyles.textStyle,
  );
}
