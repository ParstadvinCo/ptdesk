import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../common.dart';
import '../../consts.dart';
import '../../models/platform_model.dart';
import '../../models/server_model.dart';
import 'package:get/get.dart';

import 'connection_page.dart';
import 'desktop_setting_page.dart';

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
  final _perm = <String, RxBool>{};

  @override
  void initState() {
    super.initState();
    for (final key in [
      kOptionEnableKeyboard,
      kOptionEnableClipboard,
      kOptionEnableFileTransfer,
      kOptionEnableAudio,
    ]) {
      _perm[key] = RxBool(option2bool(key, bind.mainGetOptionSync(key: key)));
    }
    // Set the shared incoming-only home size so returning from the settings
    // tab restores this window size too.
    imcomingOnlyHomeSize = const Size(369, 400);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isInHomePage()) {
        windowManager.setSize(getIncomingOnlyHomeSize());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fa = _isFa();
    return Container(
      color: _kBg,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: ChangeNotifierProvider.value(
                value: gFFI.serverModel,
                child: Consumer<ServerModel>(
                  builder: (context, model, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Tooltip(
                          message: translate('Settings'),
                          child: _iconButton(
                              Icons.settings_outlined, () => _showSettings(fa)),
                        ),
                      ),
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
                            ? 'این شناسه را به کارشناس پشتیبانی اعلام کنید و سپس درخواست اتصال را تأیید کنید'
                            : 'Give this ID to your support technician, then approve the connection request',
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
                      Container(
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined,
                                size: 20, color: _kCyan),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fa
                                    ? 'بدون تأیید شما هیچ اتصالی برقرار نمی‌شود'
                                    : 'No one can connect until you approve the request',
                                style: const TextStyle(
                                    color: _kLabel, fontSize: 12, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Theme(
                        data: ThemeData.dark(),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OnlineStatusWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact settings popup: language, proxy and the permissions the
  // technician gets. Everything else stays out of the customer's way.
  void _showSettings(bool fa) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
      void close() => Navigator.of(context).pop();
      Widget permission(String label, String key) {
        return Obx(() {
          final on = _perm[key]?.value ?? false;
          return SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(label, style: const TextStyle(fontSize: 13)),
            value: on,
            onChanged: (v) async {
              await bind.mainSetOption(key: key, value: v ? 'Y' : 'N');
              _perm[key]?.value = v;
            },
          );
        });
      }

      return CustomAlertDialog(
        title: Text(fa ? 'تنظیمات' : 'Settings'),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fa ? 'زبان' : 'Language',
                  style: const TextStyle(fontSize: 12, color: _kLabel)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await bind.mainSetLocalOption(
                            key: kCommConfKeyLang, value: 'fa');
                        await reloadAllWindows();
                        await bind.mainChangeLanguage(lang: 'fa');
                        close();
                      },
                      child: const Text('فارسی'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await bind.mainSetLocalOption(
                            key: kCommConfKeyLang, value: 'en');
                        await reloadAllWindows();
                        await bind.mainChangeLanguage(lang: 'en');
                        close();
                      },
                      child: const Text('English'),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Text(fa ? 'شبکه' : 'Network',
                  style: const TextStyle(fontSize: 12, color: _kLabel)),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                icon: const Icon(Icons.lan_outlined, size: 18),
                label: Text(fa ? 'تنظیم پروکسی' : 'Proxy settings'),
                onPressed: () {
                  close();
                  changeSocks5Proxy();
                },
              ),
              const Divider(),
              Text(fa ? 'دسترسی کارشناس' : 'Technician permissions',
                  style: const TextStyle(fontSize: 12, color: _kLabel)),
              permission(fa ? 'کنترل کیبورد و ماوس' : 'Keyboard and mouse',
                  kOptionEnableKeyboard),
              permission(fa ? 'کلیپ‌بورد' : 'Clipboard', kOptionEnableClipboard),
              permission(fa ? 'انتقال فایل' : 'File transfer',
                  kOptionEnableFileTransfer),
              permission(fa ? 'صدا' : 'Audio', kOptionEnableAudio),
            ],
          ),
          ),
        ),
        actions: [
          dialogButton(fa ? 'بستن' : 'Close', onPressed: close),
        ],
        onCancel: close,
      );
    });
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
