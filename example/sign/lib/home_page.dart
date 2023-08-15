import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sign/models/page_data.dart';
import 'package:sign/pages/auth_page.dart';
import 'package:sign/pages/sign_page.dart';
import 'package:sign/utils/constants.dart';
import 'package:sign/utils/dart_defines.dart';
import 'package:sign/utils/string_constants.dart';
import 'package:sign/widgets/event_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IWeb3App? _web3App;
  bool _initialized = false;

  List<PageData> _pageDatas = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Logger.level = Level.verbose;

    initialize();
  }

  Future<void> initialize() async {
    _web3App = Web3App(
      core: Core(
        projectId: DartDefines.projectId,
      ),
      metadata: const PairingMetadata(
        name: 'Flutter Dapp Example',
        description: 'Flutter Dapp Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    _web3App!.onSessionPing.subscribe(_onSessionPing);
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);

    setState(() {
      _pageDatas = [
        PageData(
          page: SignPage(web3App: _web3App!),
          title: StringConstants.signPageTitle,
          icon: Icons.home,
        ),
        // PageData(
        //   page: PairingsPage(web3App: _web3App!),
        //   title: StringConstants.pairingsPageTitle,
        //   icon: Icons.connect_without_contact_sharp,
        // ),
        // PageData(
        //   page: SessionsPage(web3App: _web3App!),
        //   title: StringConstants.sessionsPageTitle,
        //   icon: Icons.confirmation_number_outlined,
        // ),
        PageData(
          page: AuthPage(web3App: _web3App!),
          title: StringConstants.authPageTitle,
          icon: Icons.lock,
        ),
      ];

      _initialized = true;
    });
  }

  @override
  void dispose() {
    _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: WalletConnectModalTheme.getData(context).primary100,
        ),
      );
    }

    final List<Widget> navRail = [];
    if (MediaQuery.of(context).size.width >= Constants.smallScreen) {
      navRail.add(_buildNavigationRail());
    }
    navRail.add(
      Expanded(
        child: _pageDatas[_selectedIndex].page,
      ),
    );

    return Scaffold(
      bottomNavigationBar:
          MediaQuery.of(context).size.width < Constants.smallScreen
              ? _buildBottomNavBar()
              : null,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: navRail,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.indigoAccent,
      // called when one tab is selected
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      // bottom tab items
      items: _pageDatas
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.title,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      destinations: _pageDatas
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              label: Text(e.title),
            ),
          )
          .toList(),
    );
  }

  void _onSessionPing(SessionPing? args) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: StringConstants.receivedPing,
          content: 'Topic: ${args!.topic}',
        );
      },
    );
  }

  void _onSessionEvent(SessionEvent? args) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: StringConstants.receivedEvent,
          content:
              'Topic: ${args!.topic}\nEvent Name: ${args.name}\nEvent Data: ${args.data}',
        );
      },
    );
  }
}
