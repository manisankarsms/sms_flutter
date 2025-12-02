import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/models/client.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ClientSelectionScreen extends StatefulWidget {
  const ClientSelectionScreen({Key? key}) : super(key: key);

  @override
  _ClientSelectionScreenState createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> with TickerProviderStateMixin {
  // Controllers
  final _schoolIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  int _selectedMethod = 0; // 0: Browse, 1: School ID, 2: QR Code
  bool _isLoading = false;
  List<Client> _clients = [];
  Client? _selectedClient;

  // QR Scanner
  MobileScannerController? _scannerController;
  bool _isQRScanning = false;
  String? _qrResult;
  bool _scannerReady = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkExistingClient();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _schoolIdController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _checkExistingClient() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedClientId = prefs.getString('selectedClientId');
    final skipClientSelection = prefs.getBool('skipClientSelection') ?? false;

    if (selectedClientId != null && skipClientSelection) {
      // Load saved client data
      final clientsJson = prefs.getString('clients');
      if (clientsJson != null) {
        final clients = Client.fromJsonList(clientsJson);
        final client = clients.firstWhere(
              (c) => c.id == selectedClientId,
          orElse: () => clients.first,
        );

        Constants.tenantId = client.id;
        _navigateToLogin();
        return;
      }
    }

    // Load clients for browsing
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = prefs.getString('clients');

      if (clientsJson != null && clientsJson.isNotEmpty) {
        setState(() {
          _clients = Client.fromJsonList(clientsJson);
        });
      } else {
        await _fetchClients();
      }
    } catch (e) {
      _showSnackbar('Failed to load schools', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchClients() async {
    try {
      final authRepository = AuthRepository(
        webService: WebService(baseUrl: Constants.baseUrl),
      );

      final clients = await authRepository.fetchClients();

      if (clients.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('clients', Client.toJsonList(clients));

        setState(() => _clients = clients);
      }
    } catch (e) {
      _showSnackbar('Failed to fetch schools', isError: true);
    }
  }

  Future<void> _selectClient(Client client) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedClientId', client.id);
    await prefs.setBool('skipClientSelection', true);

    Constants.tenantId = client.id;
    _navigateToLogin();
  }

  Future<void> _selectClientById(String clientId) async {
    setState(() => _isLoading = true);

    try {
      // Here you would typically validate the client ID with your backend
      // For now, we'll simulate this with a delay
      await Future.delayed(const Duration(seconds: 1));

      // Create a temporary client object
      final client = Client(
        id: clientId,
        name: 'School $clientId',
        schemaName: 'schema_$clientId',
      );

      await _selectClient(client);
    } catch (e) {
      _showSnackbar('Invalid school ID', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildSelectionCard(),
                      const SizedBox(height: 16),
                      _buildSkipButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your school to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildMethodSelector(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildMethodContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildMethodTab(
            index: 0,
            icon: Icons.list,
            label: 'Browse',
          ),
          _buildMethodTab(
            index: 1,
            icon: Icons.numbers,
            label: 'School ID',
          ),
          _buildMethodTab(
            index: 2,
            icon: Icons.qr_code_scanner,
            label: 'QR Code',
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedMethod == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodContent() {
    switch (_selectedMethod) {
      case 0:
        return _buildBrowseMethod();
      case 1:
        return _buildSchoolIdMethod();
      case 2:
        return _buildQRMethod();
      default:
        return _buildBrowseMethod();
    }
  }

  Widget _buildBrowseMethod() {
    return Column(
      key: const ValueKey('browse'),
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          )
        else if (_clients.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No schools found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _fetchClients,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectClient(client),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  client.name.substring(0, 2).toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${client.id}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSchoolIdMethod() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('schoolId'),
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: _schoolIdController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            ],
            decoration: InputDecoration(
              labelText: 'School ID',
              hintText: 'Enter your school ID',
              prefixIcon: const Icon(Icons.tag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter school ID';
              }
              if (value!.length < 4) {
                return 'School ID must be at least 4 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Ask your school administrator for the school ID',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                if (_formKey.currentState!.validate()) {
                  _selectClientById(_schoolIdController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRMethod() {
    return Column(
      key: const ValueKey('qr'),
      children: [
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isQRScanning ? _buildQRScanner() : _buildQRPlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
        if (_qrResult != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'QR Code detected: $_qrResult',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (!_isQRScanning)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _startQRScanning,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _stopQRScanning,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleFlash,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Flash'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Text(
          'Point your camera at the QR code provided by your school',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQRPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'QR Code Scanner',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Start Scanning" to begin',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onQRDetected,
        ),
        // Custom overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner decorations
                Positioned(
                  top: -2,
                  left: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                        right: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                        right: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Align QR code within the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _startQRScanning() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    setState(() {
      _isQRScanning = true;
      _qrResult = null;
      _scannerReady = false;
    });
  }

  void _stopQRScanning() async {
    await _scannerController?.stop();
    _scannerController?.dispose();
    _scannerController = null;

    setState(() {
      _isQRScanning = false;
      _scannerReady = false;
    });
  }

  void _toggleFlash() async {
    await _scannerController?.toggleTorch();
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;

    if (code != null && code.isNotEmpty && _scannerReady == false) {
      // Prevent multiple scans
      setState(() {
        _qrResult = code;
        _scannerReady = true;
      });

      // Stop scanning
      _stopQRScanning();

      // Provide haptic feedback
      HapticFeedback.mediumImpact();

      // Show success message
      _showSnackbar('QR Code scanned successfully!');

      // Process the scanned data
      _processQRResult(code);
    }
  }

  void _processQRResult(String qrData) {
    // You can customize this based on your QR code format
    // For example, if the QR code contains JSON data:
    try {
      // If it's a simple school ID
      if (qrData.length >= 4) {
        _selectClientById(qrData);
      } else {
        _showSnackbar('Invalid QR code format', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error processing QR code', isError: true);
    }
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('skipClientSelection', false);
        _navigateToLogin();
      },
      child: Text(
        'Skip for now',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}