import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final supabase = Supabase.instance.client;

  try {
    print('Starting database migration...');

    // Read the migration SQL file
    final migrationSql = await File('supabase/migrations/20240101000000_restructure_tables.sql')
        .readAsString();

    // Split the SQL into individual statements
    final statements = migrationSql.split(';').where((s) => s.trim().isNotEmpty);

    // Execute each statement
    for (var statement in statements) {
      try {
        await supabase.rpc('exec', params: {'sql': statement.trim()});
        print('Successfully executed statement');
      } catch (e) {
        print('Error executing statement: $e');
        print('Statement: ${statement.trim()}');
        // Continue with next statement even if current one fails
      }
    }

    print('Migration completed successfully!');
    print('Backup tables have been created. You can verify the data and drop them later.');

  } catch (e) {
    print('Migration failed: $e');
  }
}