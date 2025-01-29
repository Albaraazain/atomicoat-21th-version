import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Licenses'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Open Source Licenses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildLicenseSection(
            'Flutter',
            'Copyright 2014 The Flutter Authors. All rights reserved.\n\n'
                'Redistribution and use in source and binary forms, with or without modification, '
                'are permitted provided that the following conditions are met:\n\n'
                '* Redistributions of source code must retain the above copyright '
                'notice, this list of conditions and the following disclaimer.',
          ),
          _buildLicenseSection(
            'Provider',
            'MIT License\n\n'
                'Copyright (c) 2019 Remi Rousselet\n\n'
                'Permission is hereby granted, free of charge, to any person obtaining a copy '
                'of this software and associated documentation files.',
          ),
          _buildLicenseSection(
            'http',
            'Copyright 2014, the Dart project authors. All rights reserved.\n\n'
                'Redistribution and use in source and binary forms, with or without '
                'modification, are permitted provided that the following conditions are '
                'met.',
          ),
          _buildLicenseSection(
            'shared_preferences',
            'Copyright 2017 The Chromium Authors. All rights reserved.\n\n'
                'Redistribution and use in source and binary forms, with or without '
                'modification, are permitted provided that the following conditions are '
                'met.',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              showLicensePage(
                context: context,
                applicationName: 'AtomiCoat',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/atomicoat_app_icon.png',
                  width: 48,
                  height: 48,
                ),
              );
            },
            child: const Text('View All Licenses'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(String packageName, String licenseText) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(packageName),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              licenseText,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
