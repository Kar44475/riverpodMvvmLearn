import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning/features/home_screen/viewmodel/home_viewmodel.dart';
import 'package:learning/features/home_screen/model/product_model.dart';

class ProductList extends ConsumerStatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final viewModel = ref.read(homeViewModelProvider.notifier);
        viewModel.getData(forceRefresh: false); // Trigger pagination
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: state == null
          ? const Center(child: CircularProgressIndicator())
          : state.when(
              data: (homeState) {
                final products = homeState.products;
                final isLoadingMore = homeState.isLoadingMore;

                return ListView.builder(
                  key: const PageStorageKey('product_list'),
                  controller: _scrollController,
                  itemCount: products.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the bottom
                    if (index == products.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final product = products[index];
                    return ListTile(
                      title: Text(product.title ?? 'No Title'),
                      subtitle: Text(product.description ?? 'No Description'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }
}