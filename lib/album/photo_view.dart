import 'package:flutter/material.dart';

class Photo_State {}

class PhotoEvent {}

class OnCloseDrawer extends PhotoEvent {}

class OnError extends PhotoEvent {
  final String errorMessage;

  OnError(this.errorMessage);
}

class PhotoEffect {}

class CloseDrawer extends PhotoEffect {}

class ShowSnackbar extends PhotoEffect {
  final String errorMessage;

  ShowSnackbar(this.errorMessage);
}

class AlbumViewModel extends ChangeNotifier {
  Photo_State _state = Photo_State();
  PhotoEffect? _effect;

  Photo_State get state => _state;
  PhotoEffect? get effect => _effect;

  AlbumViewModel() {
    _state = createInitialState();
  }

  Photo_State createInitialState() {
    return Photo_State();
  }

  void handleEvent(PhotoEvent newEvent) {
    if (newEvent is OnCloseDrawer) {
      _effect = CloseDrawer();
    } else if (newEvent is OnError) {
      _effect = ShowSnackbar(newEvent.errorMessage);
    }
    notifyListeners();
  }

  void setEffect(PhotoEffect Function() effect) {
    _effect = effect();
    notifyListeners();
  }
}
