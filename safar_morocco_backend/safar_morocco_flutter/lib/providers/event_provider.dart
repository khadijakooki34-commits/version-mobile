import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class EventProvider extends ChangeNotifier {
  final EventService eventService;

  List<Event> _events = [];
  List<Event> _upcomingEvents = [];
  bool _isLoading = false;
  String? _error;

  EventProvider({required this.eventService});

  List<Event> get events => _events;
  List<Event> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents({int page = 0, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await eventService.getEvents(page: page, size: size);
      _upcomingEvents = eventService.filterUpcomingEvents(_events);
      _upcomingEvents = eventService.sortEventsByDate(_upcomingEvents);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event?> getEventById(int id) async {
    try {
      return await eventService.getEventById(id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
