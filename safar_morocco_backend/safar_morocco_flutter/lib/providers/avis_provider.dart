import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/avis_service.dart';

class AvisProvider extends ChangeNotifier {
  final AvisService _avisService;
  
  List<Avis> _pendingAvis = [];
  List<Avis> _allAvis = [];
  bool _isLoading = false;
  String? _error;

  AvisProvider({required AvisService avisService})
      : _avisService = avisService;

  // Getters
  List<Avis> get pendingAvis => _pendingAvis;
  List<Avis> get allAvis => _allAvis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _pendingAvis.length;

  // Charger les avis en attente
  Future<void> fetchPendingAvis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingAvis = await _avisService.getPendingAvis();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger tous les avis
  Future<void> fetchAllAvis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAvis = await _avisService.getAllAvis();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approuver un avis
  Future<bool> approveAvis(int avisId) async {
    try {
      await _avisService.approveAvis(avisId);
      
      // Retirer de la liste des avis en attente
      _pendingAvis.removeWhere((avis) => avis.id == avisId);
      
      // Mettre à jour dans la liste de tous les avis
      final index = _allAvis.indexWhere((avis) => avis.id == avisId);
      if (index != -1) {
        _allAvis[index] = _allAvis[index].copyWith(status: 'APPROVED');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Supprimer un avis
  Future<bool> deleteAvis(int avisId) async {
    try {
      await _avisService.deleteAvis(avisId);
      
      // Retirer des deux listes
      _pendingAvis.removeWhere((avis) => avis.id == avisId);
      _allAvis.removeWhere((avis) => avis.id == avisId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    await Future.wait([
      fetchPendingAvis(),
      fetchAllAvis(),
    ]);
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Extension pour copier avec modification
extension AvisCopyWith on Avis {
  Avis copyWith({
    int? id,
    int? destinationId,
    int? userId,
    String? userName,
    String? userEmail,
    String? userProfileImage,
    double? rating,
    String? comment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Avis(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
