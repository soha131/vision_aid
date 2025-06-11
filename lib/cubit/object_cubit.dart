
import 'dart:io';

import 'package:bloc/bloc.dart';
import '../object_model.dart';
import '../service.dart';
import 'object_state.dart';

class ObjectCubit extends Cubit<ObjectPredictionState> {
  ObjectCubit() : super(ObjectInitial());

  Future<void> objects(File file, String endpoint) async {
    try {
      emit(ObjectLoading());

      ObjectPrediction? result = await ApiService().fetchDataFromApi(file, endpoint);

      if (result != null) {
        emit(ObjectSuccess(result));
      } else {
        emit(ObjectError("No data returned from API."));
      }
    } catch (e) {
      emit(ObjectError("Error: $e"));
    }
  }
}
