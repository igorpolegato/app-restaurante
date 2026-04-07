import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../providers/session_provider.dart';

class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mesaController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _mesaController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEnter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mesa = int.parse(_mesaController.text);
      final rawName = _nameController.text.trim();
      final name = rawName.isEmpty ? 'Mesa $mesa' : rawName;

      final repo = CustomerRepository(ApiClient());
      final customer = await repo.createCustomer(name);

      if (!mounted) return;

      await context.read<SessionProvider>().startSession(
            customerId: customer.id,
            mesa: mesa,
            name: name,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/customer');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro de conexão. Verifique a rede e tente novamente.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildLogo(),
              const SizedBox(height: 52),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 140,
          height: 140,
        ),
        const SizedBox(height: 8),
        Text(
          'Pé na Areia',
          style: GoogleFonts.lobster(
            fontSize: 44,
            color: AppColors.brandYellow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'O melhor da sua mesa!',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Identificação',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.brandWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe o número da sua mesa para começar a pedir.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _mesaController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                color: AppColors.brandBlack, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'Número da Mesa *',
              hintText: 'Ex: 5',
              prefixIcon: Icon(Icons.table_restaurant_outlined,
                  color: AppColors.brandYellow),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe o número da mesa';
              final n = int.tryParse(v);
              if (n == null || n < 1 || n > 50) {
                return 'Mesa deve ser entre 1 e 50';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.brandBlack),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Seu nome (opcional)',
              hintText: 'Ex: João',
              prefixIcon: Icon(Icons.person_outline,
                  color: AppColors.brandYellow),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEnter,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brandBlack,
                    ),
                  )
                : Text(
                    'Entrar',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlack,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
