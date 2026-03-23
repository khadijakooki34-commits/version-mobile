import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventProvider>().fetchEvents();
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminEventProvider>().fetchEvents();
  }

  void _showAddEvent() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EventFormModal(
          isEdit: false,
          onSaved: _refresh,
        ),
      ),
    );
  }

  void _showEditEvent(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EventFormModal(
          isEdit: true,
          event: event,
          onSaved: _refresh,
        ),
      ),
    );
  }

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: Text(
          'Supprimer « ${event.title} » ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AdminEventProvider>();
      final ok = await provider.deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Événement supprimé' : provider.error ?? 'Erreur'),
            backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des événements'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/admin-dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<AdminEventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.events.isEmpty) {
            return const LoadingWidget(message: 'Chargement des événements...');
          }

          if (provider.error != null && provider.events.isEmpty) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _refresh,
            );
          }

          if (provider.events.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event,
              title: 'Aucun événement',
              subtitle: 'Ajoutez un événement culturel',
              onAction: _showAddEvent,
              actionLabel: 'Ajouter un événement',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: provider.events.length,
              itemBuilder: (context, index) {
                final event = provider.events[index];
                return _AdminEventCard(
                  event: event,
                  onEdit: () => _showEditEvent(event),
                  onDelete: () => _deleteEvent(event),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEvent,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.mainImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: resolveImageUrl(event.mainImage),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 140,
                color: Colors.grey[300],
              ),
              errorWidget: (_, __, ___) => Container(
                height: 140,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormatUtil.formatDate(event.eventDate)} • ${event.location}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLightColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.category != null && event.category!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.category!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFormModal extends StatefulWidget {
  final bool isEdit;
  final Event? event;
  final VoidCallback onSaved;

  const _EventFormModal({
    required this.isEdit,
    this.event,
    required this.onSaved,
  });

  @override
  State<_EventFormModal> createState() => _EventFormModalState();
}

class _EventFormModalState extends State<_EventFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _lieuController;
  late final TextEditingController _typeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  DateTime _dateDebut = DateTime.now().add(const Duration(days: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(days: 2));
  int? _selectedDestinationId;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.event?.title ?? '');
    _lieuController = TextEditingController(text: widget.event?.location ?? '');
    _typeController = TextEditingController(text: widget.event?.category ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _imageUrlController = TextEditingController(
      text: widget.event?.images.isNotEmpty == true ? widget.event!.images.first : '',
    );
    if (widget.event != null) {
      _dateDebut = widget.event!.eventDate;
      _dateFin = widget.event!.eventDate.add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _lieuController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDateDebut() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _dateDebut = date);
  }

  Future<void> _pickDateFin() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFin,
      firstDate: _dateDebut,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _dateFin = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isEdit && _selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final provider = context.read<AdminEventProvider>();
    bool ok = false;

    if (widget.isEdit && widget.event != null) {
      ok = await provider.updateEvent(
        id: widget.event!.id,
        nom: _nomController.text.trim(),
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        lieu: _lieuController.text.trim(),
        typeEvenement: _typeController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );
    } else {
      ok = await provider.createEvent(
        destinationId: _selectedDestinationId!,
        nom: _nomController.text.trim(),
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        lieu: _lieuController.text.trim(),
        typeEvenement: _typeController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );
    }

    if (!mounted) return;
    if (ok) {
      widget.onSaved();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement enregistré'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = context.watch<DestinationProvider>().destinations;
    if (!widget.isEdit && destinations.isNotEmpty && _selectedDestinationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedDestinationId = destinations.first.id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Modifier l\'événement' : 'Nouvel événement'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: context.watch<AdminEventProvider>().isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            if (!widget.isEdit) ...[
              const Text('Destination', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedDestinationId ?? (destinations.isNotEmpty ? destinations.first.id : null),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: [
                  if (destinations.isEmpty)
                    const DropdownMenuItem(value: null, child: Text('Chargement...')),
                  ...destinations.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                ],
                onChanged: destinations.isEmpty ? null : (v) => setState(() => _selectedDestinationId = v),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'événement',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateDebut,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormatUtil.formatDate(_dateDebut)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateFin,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormatUtil.formatDate(_dateFin)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _lieuController,
              decoration: const InputDecoration(
                labelText: 'Lieu',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type (ex: Festival, Concert)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de l\'image',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }
}
