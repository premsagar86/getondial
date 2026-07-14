class StatefulWidget {}
class State<T> {}
class Widget {}
class IconData {}
class VoidCallback {}
class BuildContext {}

class _HeroActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  _HeroActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  State<_HeroActionButton> createState() => _HeroActionButtonState();
}

class _HeroActionButtonState extends State<_HeroActionButton> {}
