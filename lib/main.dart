import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isSubscribed = prefs.getBool('subscribed') ?? false;

  runApp(MyApp(isSubscribed: isSubscribed));
}

class MyApp extends StatelessWidget {
  final bool isSubscribed;
  const MyApp({super.key, required this.isSubscribed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Task',
      theme: ThemeData.dark(),
      home: isSubscribed ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<String> texts = [
    'Добро пожаловать в приложение',
    'Улучшай опыт с подпиской',
  ];

  void _next() {
    if (_index == texts.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: texts.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      texts[i],
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Продолжить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String selectedPlan = 'month';

  void _buy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('subscribed', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget _plan({
    required String id,
    required String title,
    required String price,
  }) {
    final bool isSelected = selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(price),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подписка')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _plan(id: 'month', title: 'Месяц', price: '\$4.99'),
            const SizedBox(height: 12),
            _plan(id: 'year', title: 'Год (скидка)', price: '\$ ̶60̶.0̶0̶  \$29.99'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _buy,
                child: const Text('Продолжить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              '🎉 You have premium access!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('• Unlimited content'),
            Text('• No ads'),
            Text('• Exclusive features'),
          ],
        ),
      ),
    );
  }
}