import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_rate_provider.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _saudiController = TextEditingController();
  final _dollarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ExchangeRateProvider>();
      await provider.loadRates();
      if (!mounted) return;
      _saudiController.text = provider.getRate('saudi').toStringAsFixed(1);
      _dollarController.text = provider.getRate('dollar').toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    _saudiController.dispose();
    _dollarController.dispose();
    super.dispose();
  }

  void _saveRates() async {
    final saudiRate = double.tryParse(_saudiController.text) ?? 0;
    final dollarRate = double.tryParse(_dollarController.text) ?? 0;

    if (saudiRate <= 0 || dollarRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال أسعار صرف صحيحة أكبر من صفر')),
      );
      return;
    }

    final provider = context.read<ExchangeRateProvider>();
    await provider.updateRate('saudi', saudiRate);
    await provider.updateRate('dollar', dollarRate);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ أسعار الصرف بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rateProvider = context.watch<ExchangeRateProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة أسعار الصرف اليومية', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تُستخدم هذه الأسعار لتحويل وتقييم المنتجات المسعرة بالريال السعودي أو الدولار إلى العملة المحلية تلقائياً.',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سعر صرف الريال السعودي (مقابل الريال المحلي)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _saudiController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'مثال: 530.0',
                  suffixText: 'ر.ي / ر.س',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_exchange, color: Colors.green),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سعر صرف الدولار (مقابل الريال المحلي)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dollarController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'مثال: 2000.0',
                  suffixText: 'ر.ي / \$',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveRates,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('حفظ أسعار الصرف', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 42, 150, 177),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const Divider(height: 40),
              SwitchListTile(
                title: const Text(
                  'عرض الأسعار بالعملة المحلية دائماً في الشاشات الرئيسية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('تحويل وتثبيت العرض حسب سعر الصرف المحفوظ أعلاه'),
                value: rateProvider.showPricesInLocalCurrency,
                onChanged: (val) {
                  rateProvider.toggleShowLocalCurrency(val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
