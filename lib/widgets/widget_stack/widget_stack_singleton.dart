import 'package:web3modal_flutter/widgets/widget_stack/i_widget_stack.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack.dart';

class WidgetStackSingleton {
  IWidgetStack instance;
  WidgetStackSingleton() : instance = WidgetStack();
}

final widgetStack = WidgetStackSingleton();
