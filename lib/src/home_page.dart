import 'package:flutter/material.dart';

import 'models.dart';
import 'schedule_service.dart';
import 'settings_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.store, super.key});
  final SettingsStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageController = TextEditingController();
  MorningSettings _settings = const MorningSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await widget.store.load();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _messageController.text = settings.message;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _persist({bool showConfirmation = false}) async {
    _settings = _settings.copyWith(message: _messageController.text.trim());
    await widget.store.save(_settings);
    await ScheduleService.instance.schedule(_settings);
    if (showConfirmation && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Morning routine saved.')),
      );
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.hour, minute: _settings.minute),
    );
    if (result == null) return;
    setState(() => _settings = _settings.copyWith(
          hour: result.hour,
          minute: result.minute,
        ));
    await _persist();
  }

  Future<void> _setEnabled(bool enabled) async {
    if (enabled) {
      if (_settings.contacts.isEmpty || _messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a contact and message first.')),
        );
        return;
      }
      final allowed = await ScheduleService.instance.requestPermission();
      if (!allowed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications are needed for reminders.')),
        );
        return;
      }
    }
    setState(() => _settings = _settings.copyWith(enabled: enabled));
    await _persist();
  }

  Future<void> _addContact() async {
    final contact = await showDialog<MorningContact>(
      context: context,
      builder: (_) => const _ContactDialog(),
    );
    if (contact == null) return;
    setState(() => _settings = _settings.copyWith(
          contacts: [..._settings.contacts, contact],
        ));
    await _persist();
  }

  Future<void> _sendNow() async {
    await _persist();
    final opened = await ScheduleService.instance.openMessageComposer(_settings);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the messaging app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final time = TimeOfDay(hour: _settings.hour, minute: _settings.minute)
        .format(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const Text('Good morning ☀️',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('A little warmth, right on time.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 28),
            _SectionCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your message', style: _titleStyle),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  maxLength: 320,
                  decoration: const InputDecoration(
                    hintText: 'Write something kind…',
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(children: [
                Row(children: [
                  const Expanded(child: Text('Send to', style: _titleStyle)),
                  TextButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add'),
                  ),
                ]),
                if (_settings.contacts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Text('No one selected yet.'),
                  )
                else
                  ..._settings.contacts.asMap().entries.map((entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(entry.value.name.isEmpty
                              ? '?'
                              : entry.value.name[0].toUpperCase()),
                        ),
                        title: Text(entry.value.name),
                        subtitle: Text(entry.value.phone),
                        trailing: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            final contacts = [..._settings.contacts]..removeAt(entry.key);
                            setState(() => _settings = _settings.copyWith(contacts: contacts));
                            await _persist();
                          },
                        ),
                      )),
              ]),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Every day at'),
                  trailing: FilledButton.tonal(
                    onPressed: _pickTime,
                    child: Text(time),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily reminder'),
                  subtitle: const Text('Tap the reminder to review and send.'),
                  value: _settings.enabled,
                  onChanged: _setEnabled,
                ),
              ]),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _settings.contacts.isEmpty ? null : _sendNow,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Preview & send now'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _persist(showConfirmation: true),
              child: const Text('Save changes'),
            ),
            const SizedBox(height: 18),
            Text(
              'For your privacy, your phone asks you to confirm each message before it is sent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

const _titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      );
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add a person'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) return;
              Navigator.pop(context, MorningContact(name: _name.text.trim(), phone: _phone.text.trim()));
            },
            child: const Text('Add'),
          ),
        ],
      );
}
