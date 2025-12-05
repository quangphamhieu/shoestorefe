import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/token_handler.dart';
import '../../provider/staff_order_provider.dart';
import '../../../admin/provider/user_provider.dart';
import '../../../admin/provider/product_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/user/get_user_by_id.dart';
import '../../../../domain/usecases/user/sign_up.dart';
import '../../../../injection_container.dart' as di;

class StaffOrderFormDialog extends StatefulWidget {
  const StaffOrderFormDialog({super.key});

  @override
  State<StaffOrderFormDialog> createState() => _StaffOrderFormDialogState();
}

class _StaffOrderFormDialogState extends State<StaffOrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCustomerId;
  int _paymentMethod = 0; // 0: Cash, 1: Transfer
  final List<Map<String, dynamic>> _orderDetails = [];
  bool _loading = false;
  int? _storeId;
  bool _loadingStore = false;
  String _customerSearchText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<UserProvider>().loadAll();
      context.read<ProductProvider>().loadAll();
      await _loadCurrentUserStore();
    });
  }

  Future<void> _loadCurrentUserStore() async {
    final userId = TokenHandler().getUserId();
    if (userId == null) return;

    final userIdInt = int.tryParse(userId);
    if (userIdInt == null) return;

    setState(() {
      _loadingStore = true;
    });

    try {
      final getUserById = GetUserById(di.sl());
      final user = await getUserById.call(userIdInt);
      if (user != null && mounted) {
        setState(() {
          _storeId = user.storeId;
          _loadingStore = false;
        });
      } else if (mounted) {
        setState(() {
          _loadingStore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingStore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<StaffOrderProvider>();
    final userProvider = context.watch<UserProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tạo đơn hàng Offline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Customer Selection with Searchable Dropdown
                      _buildSearchableCustomerDropdownWithSearch(userProvider),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showAddCustomerDialog(context, userProvider),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm khách hàng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Payment Method
                      DropdownButtonFormField<int>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Phương thức thanh toán *',
                          filled: true,
                          fillColor: Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text('Tiền mặt'),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Text('Chuyển khoản'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Order Details Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sản phẩm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddProductDialog(
                              context,
                              productProvider,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm sản phẩm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_orderDetails.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Chưa có sản phẩm nào. Vui lòng thêm sản phẩm.',
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Sản phẩm',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Số lượng',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 60),
                                  ],
                                ),
                              ),
                              ...List.generate(_orderDetails.length, (index) {
                                final detail = _orderDetails[index];
                                final product = productProvider.products
                                    .firstWhere((p) => p.id == detail['productId']);
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: index == 0
                                            ? Colors.transparent
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(product.sku ?? product.name),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detail['quantity'].toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFDC2626),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _orderDetails.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _loading || _orderDetails.isEmpty
                                ? null
                                : () => _handleSubmit(context, orderProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Tạo đơn hàng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableCustomerDropdownWithSearch(UserProvider userProvider) {
    final allCustomers = userProvider.users
        .where((u) => u.roleName.toLowerCase().contains('customer'))
        .toList();
    
    final filteredCustomers = _customerSearchText.isEmpty
        ? allCustomers
        : allCustomers.where((u) {
            final searchLower = _customerSearchText.toLowerCase();
            return u.fullName.toLowerCase().contains(searchLower) ||
                u.phone.contains(_customerSearchText);
          }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextField(
          decoration: InputDecoration(
            labelText: 'Tìm kiếm khách hàng',
            hintText: 'Nhập tên hoặc số điện thoại...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _customerSearchText = value;
              // Reset selection if search changes and selected customer doesn't match
              if (_selectedCustomerId != null) {
                final selected = allCustomers.firstWhere(
                  (u) => u.id == _selectedCustomerId,
                  orElse: () => allCustomers.isNotEmpty ? allCustomers.first : allCustomers.first,
                );
                if (!selected.fullName.toLowerCase().contains(value.toLowerCase()) &&
                    !selected.phone.contains(value)) {
                  _selectedCustomerId = null;
                }
              }
            });
          },
        ),
        const SizedBox(height: 12),
        // Dropdown
        DropdownButtonFormField<int>(
          value: _selectedCustomerId,
          decoration: const InputDecoration(
            labelText: 'Khách hàng *',
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
          hint: Text(
            filteredCustomers.isEmpty
                ? 'Chưa có khách hàng nào'
                : 'Chọn khách hàng...',
          ),
          items: filteredCustomers.map((customer) {
            return DropdownMenuItem<int>(
              value: customer.id,
              child: Text('${customer.fullName} - ${customer.phone}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCustomerId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn khách hàng';
            }
            return null;
          },
          isExpanded: true,
        ),
      ],
    );
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _showAddCustomerDialog(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: _generateRandomPassword());
    int gender = 0;
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm khách hàng mới'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: gender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Nam')),
                      DropdownMenuItem(value: 1, child: Text('Nữ')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        gender = value ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu (tự động tạo) *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.lock),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() == true) {
                        setDialogState(() {
                          loading = true;
                        });

                        try {
                          final signupUseCase = SignupUser(di.sl());
                          final newCustomer = await signupUseCase.call(
                            fullName: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim().isEmpty
                                ? null
                                : emailController.text.trim(),
                            password: passwordController.text.trim(),
                            gender: gender,
                          );

                          if (context.mounted) {
                            await userProvider.loadAll();
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedCustomerId = newCustomer.id;
                              _customerSearchText = newCustomer.fullName;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm khách hàng: ${newCustomer.fullName}'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() {
                              loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${e.toString()}'),
                                backgroundColor: const Color(0xFFDC2626),
                              ),
                            );
                          }
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddProductDialog(
    BuildContext context,
    ProductProvider productProvider,
  ) async {
    int? selectedProductId;
    final quantityController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sản phẩm'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedProductId,
                decoration: const InputDecoration(
                  labelText: 'Sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                items: productProvider.products
                    .where((p) => p.statusId == 1)
                    .map((product) => DropdownMenuItem<int>(
                          value: product.id,
                          child: Text(
                            product.sku ?? product.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedProductId = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn sản phẩm';
                  }
                  // Check if product already added
                  if (_orderDetails.any((d) => d['productId'] == value)) {
                    return 'Sản phẩm đã được thêm vào đơn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true &&
                  selectedProductId != null) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true && selectedProductId != null) {
      setState(() {
        _orderDetails.add({
          'productId': selectedProductId!,
          'quantity': int.parse(quantityController.text),
        });
      });
    }
  }

  Future<void> _handleSubmit(
    BuildContext context,
    StaffOrderProvider provider,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    if (_orderDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một sản phẩm')),
      );
      return;
    }

    if (_storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định cửa hàng. Vui lòng liên hệ quản trị viên.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final success = await provider.createOrder(
      customerId: _selectedCustomerId!,
      paymentMethod: _paymentMethod,
      storeId: _storeId,
      details: _orderDetails,
    );

    setState(() {
      _loading = false;
    });

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo đơn hàng thành công'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo đơn hàng thất bại'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }
}

