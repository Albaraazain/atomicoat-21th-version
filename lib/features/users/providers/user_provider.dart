import 'package:flutter/foundation.dart';
import '../../../core/auth/models/user_model.dart';
import '../../../core/auth/enums/user_role.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  List<UserModel>? _users;
  bool _isLoading = false;
  String? _error;
  String? _currentMachineSerial;

  UserProvider(this._userRepository);

  List<UserModel> get users => _users ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentMachine(String? machineSerial) {
    _currentMachineSerial = machineSerial;
    notifyListeners();
  }

  Future<void> loadUsers({bool isSuperAdmin = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Only pass machineSerial if not super admin
      _users = await _userRepository.getUsers(
        machineSerial: isSuperAdmin ? null : _currentMachineSerial,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, UserRole role, {bool isSuperAdmin = false}) async {
    try {
      await _userRepository.updateUserRole(
        userId,
        role,
        machineSerial: isSuperAdmin ? null : _currentMachineSerial,
      );
      await loadUsers(isSuperAdmin: isSuperAdmin); // Reload the list after update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUserStatus(String userId, String status, {bool isSuperAdmin = false}) async {
    try {
      await _userRepository.updateUserStatus(
        userId,
        status,
        machineSerial: isSuperAdmin ? null : _currentMachineSerial,
      );
      await loadUsers(isSuperAdmin: isSuperAdmin); // Reload the list after update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}