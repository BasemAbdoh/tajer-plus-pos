import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _showAddEditCategoryDialog([Category? category]) {
    final controller = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          category == null ? 'إضافة قسم جديد' : 'تعديل اسم القسم',
          textAlign: TextAlign.right,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم القسم',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final provider = context.read<CategoryProvider>();
              bool success;
              if (category == null) {
                success = await provider.addCategory(name);
              } else {
                success = await provider.updateCategory(category.copyWith(name: name));
              }

              if (!mounted) return;
              if (success) {
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('اسم القسم موجود بالفعل أو حدث خطأ')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) async {
    final provider = context.read<CategoryProvider>();
    final success = await provider.deleteCategory(category.id!, category.name);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف القسم بنجاح')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تعذر الحذف', textAlign: TextAlign.right),
          content: const Text('لا يمكن حذف قسم يحتوي على منتجات مسجلة فيه. قم بنقل المنتجات إلى قسم آخر أولاً.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الأقسام والتصنيفات', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.categories.isEmpty) {
              return const Center(child: Text('لا توجد أقسام مسجلة'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final cat = provider.categories[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.category, color: Colors.teal),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('تاريخ الإنشاء: ${cat.createdAt.toLocal().toString().split(' ')[0]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditCategoryDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(cat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
          onPressed: () => _showAddEditCategoryDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
