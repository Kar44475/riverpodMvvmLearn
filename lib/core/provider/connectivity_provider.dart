import 'dart:async';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning/core/database/data_base_helper.dart';

import 'package:learning/features/update_screen/repository/update_meter_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'connectivity_provider.g.dart';

class ConnectivityState {
  final bool isConnected;
  final bool isSyncing;
  final int pendingCount;

  const ConnectivityState({
    required this.isConnected,
    this.isSyncing = false,
    this.pendingCount = 0,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isSyncing,
    int? pendingCount,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

@Riverpod(keepAlive: true)
class ConnectivityProvider extends _$ConnectivityProvider {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late DatabaseHelper _databaseHelper;
  late UpdateMeterRepository _updateRepository;

  @override
  ConnectivityState build() {
    _databaseHelper = DatabaseHelper();
    _updateRepository = ref.watch(updateMeterRepositoryProvider);

    _initConnectivityMonitoring();
    _loadPendingCount();
    
    return const ConnectivityState(isConnected: false);
  }

  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isConnected = results.any((result) => 
          result == ConnectivityResult.wifi || 
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);
      
      _updateConnectivityStatus(isConnected);
    });

    _checkInitialConnectivity();
  }

 _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
    
    _updateConnectivityStatus(isConnected);
  }

  void _updateConnectivityStatus(bool isConnected) {
    final wasConnected = state.isConnected;
    
    state = state.copyWith(isConnected: isConnected);
    
    // Show toast when connectivity changes
    if (!wasConnected && isConnected) {
      _showToast("Internet connected", Colors.green);
      
      // Auto-sync if there are pending updates
      if (state.pendingCount > 0) {
        _syncPendingUpdates();
      }
    } else if (wasConnected && !isConnected) {
      _showToast("No internet - updates will be saved offline", Colors.orange);
    }
  }

  Future<void> _loadPendingCount() async {
    try {
      final pendingUpdates = await _databaseHelper.getAllTempReadings();
      state = state.copyWith(pendingCount: pendingUpdates.length);
    } catch (e) {
      // Silently handle error
    }
  }

  // Store update data offline
  Future<bool> storeOfflineUpdate({
    required int productId,
    required double reading,
    required Uint8List? imageBytes,
    required double longitude,
    required double latitude,
  }) async {
    try {
      await _databaseHelper.insertTempReading(
        id: productId,
        reading: reading,
        imageBytes: imageBytes ?? Uint8List(0),
        longitude: longitude,
        latitude: latitude,
      );
      
      await _loadPendingCount();
      _showToast("Update saved offline (${state.pendingCount} pending)", Colors.blue);
      
      return true;
    } catch (e) {
      _showToast("Failed to save offline", Colors.red);
      return false;
    }
  }

  // Background sync when internet returns
  Future<void> _syncPendingUpdates() async {
    if (!state.isConnected || state.isSyncing || state.pendingCount == 0) return;

    state = state.copyWith(isSyncing: true);
    _showToast("Syncing ${state.pendingCount} offline updates...", Colors.blue);

    try {
      final pendingUpdates = await _databaseHelper.getAllTempReadings();
      int syncedCount = 0;
      int failedCount = 0;

      for (final update in pendingUpdates) {
        try {
          final productData = {
            'id': update['id'],
            'reading': update['reading'],
            'longitude': update['longitude'],
            'latitude': update['latitude'],
          };

          final result = await _updateRepository.postData(
            productId: update['id'],
            productData: null,
            imageBytes: null,
            longitude: null,
            latitude: null,
            // photoBytes: update['image'] != null && (update['image'] as Uint8List).isNotEmpty
            //     ? update['image'] as Uint8List
            //     : null,
          );

          result.fold(
            (failure) => failedCount++,
            (success) {
              _databaseHelper.deleteTempReading(update['id']);
              syncedCount++;
            },
          );
        } catch (e) {
          failedCount++;
        }
      }

      await _loadPendingCount();
      
      // Show sync result
      if (syncedCount > 0) {
        _showToast("✓ Synced $syncedCount updates successfully", Colors.green);
      }
      if (failedCount > 0) {
        _showToast("⚠ $failedCount updates failed to sync", Colors.orange);
      }

    } catch (e) {
      _showToast("Sync failed - will retry when connection improves", Colors.red);
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  // Check if we're online for immediate updates
  bool get isOnline => state.isConnected;

  // Get pending count for UI display
  int get pendingUpdatesCount => state.pendingCount;

  // Manual sync trigger
  Future<void> syncNow() async {
    if (state.isConnected) {
      await _syncPendingUpdates();
    } else {
      _showToast("No internet connection", Colors.red);
    }
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _databaseHelper.close();
  }
}