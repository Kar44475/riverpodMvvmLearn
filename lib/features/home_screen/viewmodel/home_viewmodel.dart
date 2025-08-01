
import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:learning/features/home_screen/repository/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

// Create a state class to hold both products and loading state
class HomeState {
  final List<Product> products;
  final bool isLoadingMore;
  final String? error;

  const HomeState({
    required this.products,
    this.isLoadingMore = false,
    this.error,
  });

  HomeState copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    String? error,
  }) {
    return HomeState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;
  int _currentPage = 1;

  @override
  AsyncValue<HomeState>? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    Future.microtask(
      () => ref.read(homeViewModelProvider.notifier).getData(),
    );
    return null;
  }

  Future<void> getData({bool forceRefresh = false}) async {
    final currentState = state?.value;
    
    // If we already have data, show loading more indicator
    if (currentState != null && currentState.products.isNotEmpty && !forceRefresh) {  
      if (currentState.isLoadingMore) return; // Prevent duplicate calls
      
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    } else {
      // First load or refresh - show main loading indicator
      state = const AsyncValue.loading();
      if (forceRefresh) {
        _currentPage = 1; // Reset page count on refresh
      }
    }

    try {
      final result = await _homeRepository.getData(
        pageCount: _currentPage,
        forceRefresh: forceRefresh,
      );

      result.fold(
        (failure) {
          if (currentState != null && currentState.products.isNotEmpty && !forceRefresh) {
            // If we have existing data, just remove the loading more indicator and show error
            state = AsyncValue.data(currentState.copyWith(
              isLoadingMore: false,
              error: failure.message,
            ));
          } else {
            // If no existing data, show error state
            state = AsyncValue.error(failure.message, StackTrace.current);
          }
        },
        (newProducts) {
          final existingProducts = forceRefresh ? <Product>[] : (currentState?.products ?? []);
          final allProducts = [...existingProducts, ...newProducts];
          
          state = AsyncValue.data(HomeState(
            products: allProducts,
            isLoadingMore: false,
          ));
          
          _currentPage++;
        },
      );
    } catch (e, stackTrace) {
      if (currentState != null && currentState.products.isNotEmpty && !forceRefresh) {
        // If we have existing data, just remove the loading more indicator
        state = AsyncValue.data(currentState.copyWith(
          isLoadingMore: false,
          error: e.toString(),
        ));
      } else {
        // If no existing data, show error state
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Method to refresh data (force network call)
  Future<void> refreshData() async {
    await getData(forceRefresh: true);
  }

  // Method to clear cache
  Future<void> clearCache() async {
    await _homeRepository.clearCache();
    _currentPage = 1;
    state = null;
    // Reload data after clearing cache
    getData(forceRefresh: true);
  }
}