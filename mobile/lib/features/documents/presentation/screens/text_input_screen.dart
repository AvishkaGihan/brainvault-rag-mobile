import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/upload_provider.dart';

/// Screen for pasting or typing text content to create a document
class TextInputScreen extends ConsumerStatefulWidget {
  const TextInputScreen({super.key});

  @override
  ConsumerState<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends ConsumerState<TextInputScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  int _characterCount = 0;
  bool _titleError = false;
  static const int maxCharacters = 50000;
  static const int minTextLength = 10;
  static const int maxTitleLength = 100;
  static const int warningThreshold = 45000;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();

    // Listen to text changes for character count and enforcement
    _textController.addListener(_onTextChanged);
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final count = text.length;

    setState(() {
      _characterCount = count;
    });

    // Enforce 50k limit
    if (count > maxCharacters) {
      _textController.text = text.substring(0, maxCharacters);
      _textController.selection = TextSelection.fromPosition(
        const TextPosition(offset: maxCharacters),
      );
      _showError('Text too long. Maximum 50,000 characters.');
    }
  }

  void _onTitleChanged() {
    // Clear error when user starts typing
    if (_titleError && _titleController.text.isNotEmpty) {
      setState(() {
        _titleError = false;
      });
    }
  }

  bool get _hasUnsavedChanges {
    return _titleController.text.isNotEmpty || _textController.text.isNotEmpty;
  }

  Color _getCharacterCountColor() {
    if (_characterCount >= maxCharacters) {
      return Theme.of(context).colorScheme.error;
    } else if (_characterCount > warningThreshold) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleClear() async {
    if (!_hasUnsavedChanges) return;

    final shouldClear = await _showDiscardDialog();
    if (shouldClear && mounted) {
      setState(() {
        _titleController.clear();
        _textController.clear();
        _characterCount = 0;
        _titleError = false;
      });
    }
  }

  void _showPopDialog() async {
    final shouldPop = await _showDiscardDialog();
    if (shouldPop && mounted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    // Validate title
    if (title.isEmpty) {
      setState(() {
        _titleError = true;
      });
      _showError('Please enter a document title');
      return;
    }

    if (title.length > maxTitleLength) {
      setState(() {
        _titleError = true;
      });
      _showError('Title too long. Maximum 100 characters.');
      return;
    }

    // Validate text
    if (text.length < minTextLength) {
      _showError('Please enter at least 10 characters of text');
      return;
    }

    // Proceed with upload
    ref.read(uploadTextProvider.notifier).uploadText(title, text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadTextProvider);
    final isLoading = uploadState.isLoading;

    // Listen to upload state changes
    ref.listen<AsyncValue<void>>(uploadTextProvider, (previous, next) {
      next.when(
        data: (_) {
          // Success - navigate back
          _showSuccess('Document created successfully');
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        error: (error, _) {
          // Show error
          _showError(error.toString());
        },
        loading: () {
          // Loading state is handled by UI
        },
      );
    });

    return PopScope(
      canPop: !_hasUnsavedChanges || isLoading,
      onPopInvokedWithResult: (didPop, result) {
        // If pop was allowed (canPop=true), didPop will be true
        // If pop was prevented (canPop=false), didPop will be false
        // In that case, we should show the discard dialog
        if (didPop || isLoading) return;

        _showPopDialog();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'New Document',
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: isLoading ? null : _handleClear,
              tooltip: 'Clear all',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextField(
                controller: _titleController,
                enabled: !isLoading,
                maxLength: maxTitleLength,
                decoration: InputDecoration(
                  labelText: 'Document Title',
                  hintText: 'e.g., My Notes, Research Summary',
                  counterText:
                      '${_titleController.text.length}/$maxTitleLength',
                  errorText: _titleError ? 'Please enter a title' : null,
                  border: const OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Text area
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !isLoading,
                  maxLines: null,
                  minLines: 10,
                  maxLength: maxCharacters,
                  decoration: const InputDecoration(
                    hintText: 'Paste or type your text here...',
                    border: OutlineInputBorder(),
                    counterText: '', // Hide default counter
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 8),

              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_characterCount / $maxCharacters characters',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getCharacterCountColor(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Processing message
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Creating document...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),

              // Save button
              ElevatedButton(
                onPressed:
                    isLoading ||
                        _textController.text.trim().length < minTextLength ||
                        _titleController.text.trim().isEmpty
                    ? null
                    : _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                child: isLoading
                    ? const LoadingIndicator(size: 20, strokeWidth: 2)
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
