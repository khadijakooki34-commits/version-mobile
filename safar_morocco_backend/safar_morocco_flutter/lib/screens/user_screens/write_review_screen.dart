import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class WriteReviewScreen extends StatefulWidget {
  final int destinationId;

  const WriteReviewScreen({
    super.key,
    required this.destinationId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() && _rating > 0) {
      final provider = context.read<ReviewProvider>();
      await provider.createReview(
        destinationId: widget.destinationId,
        rating: _rating,
        comment: _commentController.text,
      );

      if (mounted) {
        if (provider.error == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avis publié avec succès'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Échec de la publication de l\'avis'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rédiger un avis'),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment avez-vous trouvé votre expérience ?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Note',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  RatingBar(
                    rating: _rating,
                    onRatingChanged: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                    itemSize: 50,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  CustomTextField(
                    label: 'Votre avis',
                    hint: 'Partagez votre expérience...',
                    controller: _commentController,
                    maxLines: 5,
                    minLines: 3,
                    validator: ValidationUtil.validateComment,
                    maxLength: 500,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitReview,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Publier l\'avis'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
