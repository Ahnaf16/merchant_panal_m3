import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/models/models.dart';

class FlashSaleState {
  FlashSaleState({
    required this.editingFlash,
    required this.flashList,
  });

  final FlashModel? editingFlash;
  final AsyncValue<List<FlashModel>> flashList;

  static FlashSaleState empty = FlashSaleState(
    editingFlash: null,
    flashList: const AsyncValue.loading(),
  );

  FlashSaleState copyWith({
    FlashModel? editingFlash,
    AsyncValue<List<FlashModel>>? flashList,
  }) {
    return FlashSaleState(
      editingFlash: editingFlash ?? this.editingFlash,
      flashList: flashList ?? this.flashList,
    );
  }
}
