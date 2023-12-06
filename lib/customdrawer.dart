import 'dart:developer';

import 'package:checkusbandsms/main.dart';
import 'package:checkusbandsms/usb_serial.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'usb.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('SMS'),
            onTap: () {
              Get.offNamedUntil("/", (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('USB Serial COM.'),
            onTap: () {
              Get.to(() => const USBTest());
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('USB'),
            onTap: () {
              Get.to(() => const USBserial());
            },
          )
        ],
      ),
    );
  }
}
