import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/provider/notification_provider.dart';
import 'notification_dialog.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _showNotificationPanel = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _notificationIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load notifications khi header được khởi tạo
    Future.microtask(() {
      context.read<NotificationProvider>().loadAll();
    });
    // Polling mỗi 30 giây để tự động refresh notifications
    _startPolling();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        context.read<NotificationProvider>().loadAll();
        _startPolling(); // Tiếp tục polling
      }
    });
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox =
        _notificationIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    const panelWidth = 420.0;

    // Tính toán vị trí: panel căn phải với icon, nhưng không vượt quá màn hình
    final rightPosition =
        screenWidth - offset.dx - size.width / 2 - panelWidth / 2;
    final adjustedRight =
        rightPosition < 16
            ? 16.0
            : rightPosition; // Tối thiểu 16px từ cạnh phải

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Backdrop để đóng panel khi click bên ngoài
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleNotificationPanel,
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Notification panel
              Positioned(
                right: adjustedRight,
                top: offset.dy + size.height + 4,
                child: GestureDetector(
                  onTap: () {}, // Ngăn event propagation
                  child: Material(
                    color: Colors.transparent,
                    child: NotificationPanel(
                      onDismiss: _toggleNotificationPanel,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleNotificationPanel() {
    if (_showNotificationPanel) {
      // Đóng panel và đánh dấu đã đọc
      context.read<NotificationProvider>().markAllAsRead();
      _removeOverlay();
    } else {
      // Mở panel (không load lại, chỉ hiển thị)
      _showOverlay();
    }
    setState(() {
      _showNotificationPanel = !_showNotificationPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Notification icon with badge
          Stack(
            clipBehavior: Clip.none,
            key: _notificationIconKey,
            children: [
              IconButton(
                icon: Icon(
                  _showNotificationPanel
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  size: 28,
                  color:
                      _showNotificationPanel
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF334155),
                ),
                onPressed: _toggleNotificationPanel,
                tooltip: 'Thông báo',
              ),
              if (notificationProvider.unreadCount > 0 &&
                  !_showNotificationPanel)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        notificationProvider.unreadCount > 99
                            ? '99+'
                            : notificationProvider.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Có thể thêm các icon khác ở đây sau này
        ],
      ),
    );
  }
}
