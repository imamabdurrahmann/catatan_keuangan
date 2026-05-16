import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../services/biometric_service.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool requireBiometric;

  const PinLockScreen({
    super.key,
    required this.onUnlocked,
    this.requireBiometric = false,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinController = TextEditingController();
  bool _isSetupMode = false;
  String? _firstPin;
  String? _error;
  bool _biometricAvailable = false;
  bool _useBiometric = false;
  Pengaturan? _pengaturan;

  @override
  void initState() {
    super.initState();
    _checkSetupMode();
    _checkBiometric();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkSetupMode() async {
    final pengaturan = await DatabaseHelper.instance.getPengaturan();
    setState(() {
      _pengaturan = pengaturan;
      _isSetupMode = pengaturan.pin == null;
      _useBiometric = pengaturan.useBiometric;
    });
  }

  Future<void> _checkBiometric() async {
    final available = await BiometricService.instance.isAvailable();
    final enrolled = await BiometricService.instance.hasEnrolledBiometrics();
    setState(() => _biometricAvailable = available && enrolled);
  }

  Future<void> _tryBiometric() async {
    if (!_biometricAvailable || !_useBiometric) return;

    final success = await BiometricService.instance.authenticate(
      reason: 'Verifikasi sidik jari untuk membuka aplikasi',
    );
    if (success) {
      widget.onUnlocked();
    }
  }

  Future<void> _submit() async {
    final pin = _pinController.text;

    if (pin.length < 4) {
      setState(() => _error = 'PIN minimal 4 digit');
      return;
    }

    if (_isSetupMode) {
      if (_firstPin == null) {
        setState(() {
          _firstPin = pin;
          _pinController.clear();
          _error = null;
        });
      } else {
        if (_firstPin != pin) {
          setState(() {
            _error = 'PIN tidak cocok';
            _firstPin = null;
            _pinController.clear();
          });
        } else {
          await _savePin(pin);
        }
      }
    } else {
      if (pin == _pengaturan?.pin) {
        widget.onUnlocked();
      } else {
        setState(() {
          _error = 'PIN salah';
          _pinController.clear();
        });
      }
    }
  }

  Future<void> _savePin(String pin) async {
    final pengaturan = Pengaturan(
      id: 1,
      isDarkMode: _pengaturan?.isDarkMode ?? false,
      pin: pin,
      useBiometric: _useBiometric,
    );
    await DatabaseHelper.instance.updatePengaturan(pengaturan);
    if (mounted) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    // Try biometric on mount if available and configured
    if (_biometricAvailable &&
        _useBiometric &&
        !_isSetupMode &&
        _pengaturan != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }

    final title = _isSetupMode
        ? (_firstPin == null ? 'Buat PIN' : 'Konfirmasi PIN')
        : 'Masukkan PIN';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_firstPin != null && _isSetupMode)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Masukkan PIN yang sama untuk konfirmasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 32),
              Semantics(
                label: 'Input PIN',
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '****',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: Text(_isSetupMode ? 'Simpan PIN' : 'Buka'),
                ),
              ),

              // Biometric button
              if (_biometricAvailable && !_isSetupMode) ...[
                const SizedBox(height: 16),
                if (_useBiometric)
                  OutlinedButton.icon(
                    onPressed: _tryBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Gunakan Sidik Jari'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
              ],

              // Setup biometric option
              if (_isSetupMode && _biometricAvailable) ...[
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aktifkan sidik jari'),
                  subtitle: const Text(
                    'Buka dengan sidik jari',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _useBiometric,
                  onChanged: (v) => setState(() => _useBiometric = v ?? false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
