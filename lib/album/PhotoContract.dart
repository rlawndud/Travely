// file: lib/album/PhotoContract.dart

import 'package:flutter/material.dart';

abstract class UiState {}

abstract class UiEvent {}

abstract class UiEffect {}

@immutable
class PhotoState extends UiState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;

  PhotoState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
  });

  PhotoState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
  }) {
    return PhotoState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
    );
  }
}

abstract class Event extends UiEvent {}

class OnCloseDrawer extends Event {}

class OnError extends Event {
  final String errorMessage;

  OnError(this.errorMessage);
}

abstract class Effect extends UiEffect {}

class CloseDrawer extends Effect {}

class ShowSnackbar extends Effect {
  final String message;

  ShowSnackbar(this.message);
}
