import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../common.dart';
import '../../consts.dart';
import '../../models/platform_model.dart';
import '../../models/server_model.dart';
import 'connection_page.dart';

const _kBg = Color(0xFF0E1A22);
const _kCard = Color(0xFF122430);
const _kBorder = Color(0xFF1D3A47);
const _kText = Color(0xFFE6F2F6);
const _kLabel = Color(0xFF7D99A5);
const _kCyan = Color(0xFF7FDCEC);
const _kIcon = Color(0xFF5D7A87);
const _kAccent = Color(0xFF35C3DD);

bool _isFa() {
  var lang = bind.mainGetLocalOption(key: kCommConfKeyLang).toLowerCase();
  if (lang.isEmpty || lang == 'default') {
    try {
      lang = Platform.localeName.toLowerCase();
    } catch (_) {}
  }
  return lang.startsWith('fa');
}

class PtdeskQsHome extends StatefulWidget {
  const PtdeskQsHome({Key? key}) : super(key: key);

  @override
  State<PtdeskQsHome> createState() => _PtdeskQsHomeState();
}

class _PtdeskQsHomeState extends State<PtdeskQsHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isInHomePage()) {
        windowManager.setSize(const Size(380, 560));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fa = _isFa();
    return Container(
      color: _kBg,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: ChangeNotifierProvider.value(
                value: gFFI.serverModel,
                child: Consumer<ServerModel>(
                  builder: (context, model, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _logo(),
                      const SizedBox(height: 10),
                      Text(
                        fa
                            ? 'پشتیبانی از راه دور پارس تدوین'
                            : 'Pars Tadvin remote support',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: _kText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fa
                            ? 'این شناسه و رمز را به کارشناس پشتیبانی اعلام کنید'
                            : 'Read this ID and password to your support technician',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: _kLabel, fontSize: 12, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      _valueCard(
                        label: fa ? 'شناسه شما' : 'Your ID',
                        listenable: model.serverId,
                        valueColor: _kText,
                        letterSpacing: 2,
                        actions: [
                          _iconButton(Icons.copy_rounded, () {
                            Clipboard.setData(
                                ClipboardData(text: model.serverId.text));
                            showToast(translate('Copied'));
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _valueCard(
                        label: fa ? 'رمز یکبار مصرف' : 'One-time password',
                        listenable: model.serverPasswd,
                        valueColor: _kCyan,
                        letterSpacing: 3,
                        actions: [
                          _iconButton(Icons.copy_rounded, () {
                            Clipboard.setData(
                                ClipboardData(text: model.serverPasswd.text));
                            showToast(translate('Copied'));
                          }),
                          const SizedBox(width: 10),
                          _iconButton(Icons.refresh_rounded,
                              () => bind.mainUpdateTemporaryPassword()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: _kBorder, height: 1, thickness: 1),
          Theme(
            data: ThemeData.dark(),
            child: Container(
              color: const Color(0xFF0A141B),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: OnlineStatusWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Image.asset(
        'assets/ptdesk_logo.png',
        width: 56,
        height: 56,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E2530),
            border: Border.all(color: _kAccent, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text('PT',
              style: TextStyle(
                  color: _kCyan, fontSize: 17, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _valueCard({
    required String label,
    required TextEditingController listenable,
    required Color valueColor,
    required double letterSpacing,
    required List<Widget> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _kLabel, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: listenable,
                    builder: (context, value, _) => Text(
                      value.text,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: letterSpacing,
                      ),
                    ),
                  ),
                ),
              ),
              ...actions,
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: _kIcon),
      ),
    );
  }
}
