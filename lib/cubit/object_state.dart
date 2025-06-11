import '../object_model.dart';

abstract class ObjectPredictionState {}

class ObjectInitial extends ObjectPredictionState {}

class ObjectLoading extends ObjectPredictionState {}

class ObjectSuccess extends ObjectPredictionState {
  final ObjectPrediction prediction;
  ObjectSuccess(this.prediction);
}

class ObjectError extends ObjectPredictionState {
  final String message;
  ObjectError(this.message);
}
