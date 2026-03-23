import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class EventService {
  final ApiService apiService;

  EventService({required this.apiService});

  Future<List<Event>> getEvents({int page = 0, int size = 100}) async {
    try {
      final response = await apiService.getEvents(page: page, size: size);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data is List ? data : (data['content'] as List? ?? []);
        return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch events');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  List<Event> filterUpcomingEvents(List<Event> events) {
    return events.where((event) => event.isUpcoming).toList();
  }

  List<Event> sortEventsByDate(List<Event> events) {
    final sortedEvents = [...events];
    sortedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return sortedEvents;
  }

  Future<Event?> getEventById(int id) async {
    try {
      final response = await apiService.getEventById(id);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Event.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
