import 'package:web3modal_flutter/services/ledger_service/i_ledger_service.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service.dart';

class LedgerServiceSingleton {
  ILedgerService instance;

  LedgerServiceSingleton() : instance = LedgerService();
}

final ledgerService = LedgerServiceSingleton();
