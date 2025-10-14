import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:simple_app/services/github_service.dart';
import 'package:archive/archive_io.dart';

class SideTab extends StatefulWidget {
  final CodeController codeController;

  const SideTab({super.key, required this.codeController});

  @override
  State<SideTab> createState() => _SideTabState();
}

class _SideTabState extends State<SideTab> {
  Directory? _currentDirectory;
  List<FileSystemEntity> _files = [];
  FileSystemEntity? _selectedEntity;
  FileSystemEntity? _copiedEntity;
  final GitHubService _gitHubService = GitHubService();
  bool _isPushing = false;
  bool _isLoadingDirectory = true;

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  Future<void> _initDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      setState(() {
        _currentDirectory = directory;
        _isLoadingDirectory = false;
      });
      _loadFiles();
    } catch (e) {
      setState(() {
        _isLoadingDirectory = false;
      });
      _showSnackbar("Error getting documents directory: $e");
    }
  }

  void _loadFiles() async {
    if (_currentDirectory == null) return;
    final files = await _currentDirectory!.list().toList();
    setState(() {
      _files = files;
    });
  }

  void _navigateToDirectory(Directory directory) {
    setState(() {
      _currentDirectory = directory;
      _loadFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDirectory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentDirectory == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Error: Could not access project directory.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      width: 250,
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _files.isEmpty
                ? const Center(
                    child: Text('Empty directory', style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final entity = _files[index];
                      final isDirectory = entity is Directory;
                      final isSelected = _selectedEntity == entity;
                      return ListTile(
                        leading: Icon(
                          isDirectory ? Icons.folder : Icons.description,
                          color: Colors.white,
                        ),
                        title: Text(
                          p.basename(entity.path),
                          style: const TextStyle(color: Colors.white),
                        ),
                        tileColor: isSelected ? Colors.blue.withAlpha(128) : null,
                        onTap: () {
                          if (isDirectory) {
                            _navigateToDirectory(entity);
                          } else {
                            setState(() {
                              _selectedEntity = entity;
                            });
                            // Handle file selection logic later
                          }
                        },
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.grey),
          _buildFeatureButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Determine if the "up" button should be enabled
    final parent = _currentDirectory?.parent;
    final canGoUp = parent != null && p.canonicalize(parent.path) != p.canonicalize(_currentDirectory!.path);

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[850],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
            onPressed: canGoUp ? () => _navigateToDirectory(parent) : null,
          ),
          Expanded(
            child: Text(
              p.basename(_currentDirectory?.path ?? '...'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ... (buildHeader and other methods remain the same)

  Widget _buildFeatureButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildButton(Icons.note_add, 'New File', () => _createNew(isDirectory: false)),
          _buildButton(Icons.create_new_folder, 'New Folder', () => _createNew(isDirectory: true)),
          _buildButton(Icons.delete, 'Delete', _deleteSelected),
          _buildButton(Icons.copy, 'Copy', _copySelected),
          _buildButton(Icons.paste, 'Paste', _paste),
          _buildButton(Icons.share, 'Share', _shareSelectedFile),
          _buildButton(Icons.undo, 'Undo', () => widget.codeController.undo()),
          _buildButton(Icons.redo, 'Redo', () => widget.codeController.redo()),
          _buildButton(Icons.download, 'Download', _downloadSelectedFile),
          _buildGitHubButton(),
          _buildButton(Icons.bug_report, 'Debug', () => _showSnackbar('Debug feature is not yet implemented.')),
          _buildButton(Icons.archive, 'Zip', _zipProject),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteSelected() async {
    final entity = _selectedEntity;
    if (entity == null) {
      _showSnackbar('No file or folder selected.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${p.basename(entity.path)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _selectedEntity!.delete(recursive: true);
        _showSnackbar('Deleted successfully.');
        setState(() {
          _selectedEntity = null;
        });
        _loadFiles();
      } catch (e) {
        _showSnackbar('Error deleting: $e');
      }
    }
  }

  void _copySelected() {
    final entity = _selectedEntity;
    if (entity == null) {
      _showSnackbar('No file or folder selected.');
      return;
    }
    setState(() {
      _copiedEntity = entity;
    });
    _showSnackbar('Copied ${p.basename(entity.path)}');
  }

  Future<void> _paste() async {
    final entityToPaste = _copiedEntity;
    if (entityToPaste == null) {
      _showSnackbar('Nothing to paste.');
      return;
    }
    final directory = _currentDirectory;
    if (directory == null) {
      _showSnackbar('Cannot paste: directory not available.');
      return;
    }

    final newPath = p.join(directory.path, p.basename(entityToPaste.path));

    try {
      if (entityToPaste is File) {
        await (_copiedEntity as File).copy(newPath);
      } else if (_copiedEntity is Directory) {
        await _copyDirectory(_copiedEntity as Directory, Directory(newPath));
      }
      _loadFiles();
      _showSnackbar('Pasted successfully.');
    } catch (e) {
      _showSnackbar('Error pasting: $e');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      }
    }
  }

  Future<void> _createNew({required bool isDirectory}) async {
    final directory = _currentDirectory;
    if (directory == null) {
      _showSnackbar('Cannot create: directory not available.');
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDirectory ? 'New Folder' : 'New File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final newPath = p.join(directory.path, name);
      try {
        if (isDirectory) {
          await Directory(newPath).create();
        } else {
          await File(newPath).create();
        }
        _loadFiles();
        _showSnackbar('${isDirectory ? "Folder" : "File"} created.');
      } catch (e) {
        _showSnackbar('Error creating: $e');
      }
    }
  }

  Future<void> _shareSelectedFile() async {
    if (_selectedEntity == null) {
      _showSnackbar('No file selected.');
      return;
    }
    if (_selectedEntity is Directory) {
      _showSnackbar('Cannot share a directory.');
      return;
    }
    try {
      final file = XFile(_selectedEntity!.path);
      await Share.shareXFiles([file]);
    } catch (e) {
      _showSnackbar('Error sharing file: $e');
    }
  }

  Future<void> _downloadSelectedFile() async {
    if (_selectedEntity == null) {
      _showSnackbar('No file selected.');
      return;
    }
    if (_selectedEntity is Directory) {
      _showSnackbar('Cannot download a directory.');
      return;
    }

    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        _showSnackbar('Could not find downloads directory.');
        return;
      }

      final file = _selectedEntity as File;
      final fileName = p.basename(file.path);
      final newPath = p.join(downloadsDirectory.path, fileName);

      await file.copy(newPath);
      _showSnackbar('File downloaded to $newPath');
    } catch (e) {
      _showSnackbar('Error downloading file: $e');
    }
  }

  Widget _buildGitHubButton() {
    if (_isPushing) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildButton(
      Icons.upload,
      _gitHubService.isAuthenticated ? 'Push to GitHub' : 'Login to GitHub',
      _githubPush,
    );
  }

  Future<void> _githubPush() async {
    setState(() {
      _isPushing = true;
    });

    try {
      if (!_gitHubService.isAuthenticated) {
        await _gitHubService.authenticate();
        // The service now prints to the console. We can show a generic message.
        _showSnackbar('Check the console for the auth code. A backend is needed to complete the login.');
        // Since auth is not complete, we don't proceed to the commit part.
      } else {
        // This part will not be reached until the service can fully authenticate.
        // The logic for commit and push remains as a future implementation.
        _showSnackbar('Ready to push. Git logic is not yet implemented.');
      }
    } catch (e) {
      _showSnackbar('An error occurred during authentication: $e');
    } finally {
      setState(() {
        _isPushing = false;
      });
    }
  }

  Future<void> _zipProject() async {
    if (_currentDirectory == null) {
      _showSnackbar('Project directory not available.');
      return;
    }
    _showSnackbar('Zipping project...');
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        _showSnackbar('Could not find downloads directory.');
        return;
      }

      final projectName = p.basename(_currentDirectory!.path);
      final zipFilePath = p.join(downloadsDirectory.path, '$projectName.zip');

      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);

      final projectDir = _currentDirectory!;
      await for (final entity in projectDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: projectDir.path);
          // Simple check to avoid zipping the zip file itself or .git folder
          if (p.extension(relativePath) == '.zip' || p.split(relativePath).contains('.git')) {
            continue;
          }
          encoder.addFile(entity, relativePath);
        }
      }

      encoder.close();
      _showSnackbar('Project zipped successfully to $zipFilePath');

    } catch (e) {
      _showSnackbar('Error zipping project: $e');
    }
  }
}
