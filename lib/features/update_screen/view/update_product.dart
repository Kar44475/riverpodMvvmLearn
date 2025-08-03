import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning/core/provider/permission_provider.dart';
import 'package:learning/features/update_screen/update_viewmodel/update_viewmodel.dart';
// import 'package:learning/features/update_screen/viewmodel/update_viewmodel.dart';

class UpdateProductView extends ConsumerStatefulWidget {
  const UpdateProductView({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateProductView> createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends ConsumerState<UpdateProductView> {
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // Watch the viewmodel state
    final state = ref.watch(updateViewModelProvider);
    final viewModel = ref.read(updateViewModelProvider.notifier);

    // Listen for state changes to show snackbars
    ref.listen(updateViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        viewModel.clearError();
      }
      
      if (next.updateSuccess && !(previous?.updateSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        viewModel.clearSuccess();
      }
    });

    // Update text controller when extra details change
    if (_detailsController.text != (state.extraDetails ?? '')) {
      _detailsController.text = state.extraDetails ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
        actions: [
          if (state.isUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : () {
              viewModel.refreshProduct();
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.selectedProduct == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No product selected'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original product details
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text('ID: ${state.selectedProduct!.id ?? ''}'),
                              Text('Title: ${state.selectedProduct!.title ?? ''}'),
                              Text('Price: \$${state.selectedProduct!.price ?? ''}'),
                              Text('Description: ${state.selectedProduct!.description ?? ''}'),
                              Text('Category: ${state.selectedProduct!.category ?? ''}'),
                              if (state.selectedProduct!.rating != null)
                                Text(
                                  'Rating: ${state.selectedProduct!.rating!.rate} (${state.selectedProduct!.rating!.count} votes)',
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Extra details input
                      TextField(
                        controller: _detailsController,
                        decoration: const InputDecoration(
                          labelText: 'Extra Details',
                          border: OutlineInputBorder(),
                          helperText: 'Add additional information about the product',
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                //          viewModel.updateExtraDetails(value);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Photo capture section
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (state.isUpdating || state.isLoading) ? null : () {
                                viewModel.capturePhoto();
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Capture Photo'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Photo preview
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: state.photoBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  state.photoBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 48, color: Colors.grey),
                                    Text('No Photo Captured'),
                                  ],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Update button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (state.isUpdating || state.isLoading) ? null : () {
                            viewModel.updateProduct();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: state.isUpdating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Updating...'),
                                  ],
                                )
                              : const Text('Update Product'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}