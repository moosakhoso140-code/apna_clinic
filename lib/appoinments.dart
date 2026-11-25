import 'package:flutter/material.dart';

// ───────────────────────── Shared store (one for the whole app) ─────────────────────────

final clinicStore = Store();

// ───────────────────────── Screens used by the home screen ─────────────────────────

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clinicStore, // rebuilds on book, check in, cancel
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('My appointments'),
          actions: [
            IconButton(
              tooltip: 'Doctors',
              icon: const Icon(Icons.medical_services_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorsScreen()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: AppointmentsPage(
            store: clinicStore,
            onBook: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookScreen()),
            ),
          ),
        ),
      ),
    );
  }
}

class BookScreen extends StatelessWidget {
  final Doctor? doctor;
  const BookScreen({super.key, this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: SafeArea(
        child: BookingPage(
          store: clinicStore,
          initialDoctor: doctor,
          onDone: () => Navigator.pop(context), // back to My appointments
        ),
      ),
    );
  }
}

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clinicStore,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Doctors')),
        body: SafeArea(
          child: DoctorsPage(
            store: clinicStore,
            onBook: (d) => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookScreen(doctor: d)),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Models ─────────────────────────

class Doctor {
  final int id, years;
  final String name, dept, degree;
  const Doctor(this.id, this.name, this.dept, this.years, this.degree);
  String get initials =>
      name.replaceFirst('Dr. ', '').split(' ').map((w) => w[0]).join();
}

enum Status { booked, waiting, done, cancelled }

class Appt {
  final int id, age, doctorId, day;
  final String name, phone, gender, dept, reason, time;
  Status status;
  int? ticket;
  Appt({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.dept,
    required this.doctorId,
    required this.day,
    required this.time,
    this.gender = 'Female',
    this.reason = '',
    this.status = Status.booked,
    this.ticket,
  });
}

const departments = <(String, String)>[
  ('Cardiology', 'Heart and blood pressure'),
  ('Neurology', 'Brain and nerves'),
  ('Pediatrics', 'Children’s health'),
  ('Orthopedics', 'Bones and joints'),
  ('Dermatology', 'Skin, hair and nails'),
  ('General medicine', 'Check-ups and common illness'),
];

const doctors = <Doctor>[
  Doctor(1, 'Dr. Ayesha Khan', 'Cardiology', 18, 'MBBS, FCPS'),
  Doctor(2, 'Dr. Imran Shah', 'Cardiology', 12, 'MBBS, MRCP'),
  Doctor(3, 'Dr. Sana Memon', 'Neurology', 15, 'MBBS, FCPS'),
  Doctor(4, 'Dr. Bilal Ahmed', 'Pediatrics', 9, 'MBBS, DCH'),
  Doctor(5, 'Dr. Farah Naz', 'Pediatrics', 14, 'MBBS, FCPS'),
  Doctor(6, 'Dr. Kamran Ali', 'Orthopedics', 20, 'MBBS, MS Ortho'),
  Doctor(7, 'Dr. Hina Soomro', 'Dermatology', 8, 'MBBS, FCPS'),
  Doctor(8, 'Dr. Usman Raza', 'General medicine', 11, 'MBBS'),
  Doctor(9, 'Dr. Zara Qureshi', 'General medicine', 6, 'MBBS'),
];

Doctor doctorById(int id) => doctors.firstWhere((d) => d.id == id);

// ───────────────────────── Store ─────────────────────────

class Store extends ChangeNotifier {
  static final List<String> times = [
    for (var h = 9; h < 17; h++) ...['$h:00', '$h:30'],
  ];

  int _nextId = 10, _nextTicket = 3;

  final List<Appt> appts = [
    Appt(id: 1, name: 'Nadia Hussain', age: 34, phone: '0300-1234567', dept: 'Cardiology', doctorId: 1, day: 0, time: '9:30', reason: 'Chest pain', status: Status.waiting, ticket: 1),
    Appt(id: 2, name: 'Hamza Ali', age: 58, phone: '0321-7654321', dept: 'Cardiology', doctorId: 2, day: 0, time: '10:00', reason: 'Follow-up', status: Status.waiting, ticket: 2),
    Appt(id: 3, name: 'Sara Baloch', age: 6, phone: '0333-9988776', dept: 'Pediatrics', doctorId: 4, day: 0, time: '11:00', reason: 'Fever'),
    Appt(id: 4, name: 'Ahmed Leghari', age: 45, phone: '0345-1122334', dept: 'Orthopedics', doctorId: 6, day: 0, time: '14:30', reason: 'Knee pain'),
    Appt(id: 5, name: 'Mariam Jatoi', age: 29, phone: '0312-5566778', dept: 'Dermatology', doctorId: 7, day: 1, time: '10:30', reason: 'Skin rash'),
    Appt(id: 6, name: 'Zubair Khoso', age: 41, phone: '0301-4455667', dept: 'Neurology', doctorId: 3, day: 1, time: '12:00', reason: 'Migraine'),
  ];

  static int minutes(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  bool _taken(int doc, int day, String t) => appts.any((a) =>
      a.doctorId == doc &&
      a.day == day &&
      a.time == t &&
      a.status != Status.cancelled);

  bool slotOk(int doc, int day, String t) {
    if (_taken(doc, day, t)) return false;
    if (day == 0) {
      final n = DateTime.now();
      if (minutes(t) <= n.hour * 60 + n.minute) return false;
    }
    return true;
  }

  int free(int doc, int day) =>
      times.where((t) => slotOk(doc, day, t)).length;

  List<Appt> get waiting =>
      appts.where((a) => a.status == Status.waiting).toList();

  List<Appt> get upcoming =>
      appts.where((a) => a.status == Status.booked).toList()
        ..sort((a, b) => a.day != b.day
            ? a.day.compareTo(b.day)
            : minutes(a.time).compareTo(minutes(b.time)));

  int get seen => appts.where((a) => a.status == Status.done).length;

  Appt book({
    required String name,
    required int age,
    required String phone,
    required String gender,
    required String reason,
    required Doctor doctor,
    required int day,
    required String time,
  }) {
    final a = Appt(
      id: _nextId++,
      name: name,
      age: age,
      phone: phone,
      gender: gender,
      reason: reason,
      dept: doctor.dept,
      doctorId: doctor.id,
      day: day,
      time: time,
    );
    appts.add(a);
    notifyListeners();
    return a;
  }

  void checkIn(Appt a) {
    a.status = Status.waiting;
    a.ticket = _nextTicket++;
    notifyListeners();
  }

  void finish(Appt a) {
    a.status = Status.done;
    notifyListeners();
  }

  void cancel(Appt a) {
    a.status = Status.cancelled;
    notifyListeners();
  }
}

// ───────────────────────── Helpers ─────────────────────────

String fmtTime(String t) {
  final p = t.split(':');
  final h = int.parse(p[0]);
  return '${h % 12 == 0 ? 12 : h % 12}:${p[1]} ${h < 12 ? 'AM' : 'PM'}';
}

String dayLabel(int n) {
  if (n == 0) return 'Today';
  if (n == 1) return 'Tomorrow';
  final d = DateTime.now().add(Duration(days: n));
  const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${w[d.weekday - 1]}, ${d.day} ${m[d.month - 1]}';
}

void snack(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

// ───────────────────────── Appointments page ─────────────────────────

class AppointmentsPage extends StatelessWidget {
  final Store store;
  final VoidCallback onBook;
  const AppointmentsPage({super.key, required this.store, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final waiting = store.waiting, upcoming = store.upcoming;
    final today = upcoming.where((a) => a.day == 0).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          _Stat('${waiting.length}', 'Waiting now'),
          _Stat('$today', 'Coming today'),
          _Stat('${upcoming.length}', 'Upcoming'),
          _Stat('${store.seen}', 'Seen'),
        ]),
        const SizedBox(height: 16),
        _Heading('Waiting now', Colors.deepOrange),
        if (waiting.isEmpty) const _Empty('No patients are waiting.'),
        for (final a in waiting) ApptCard(a: a, store: store),
        const SizedBox(height: 8),
        _Heading('Coming soon', Theme.of(context).colorScheme.primary),
        if (upcoming.isEmpty) const _Empty('No upcoming appointments. Tap Book new to add one.'),
        for (final a in upcoming) ApptCard(a: a, store: store),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: onBook, icon: const Icon(Icons.add), label: const Text('Book new appointment')),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
}

class _Heading extends StatelessWidget {
  final String text;
  final Color color;
  const _Heading(this.text, this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
}

class ApptCard extends StatelessWidget {
  final Appt a;
  final Store store;
  const ApptCard({super.key, required this.a, required this.store});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final waiting = a.status == Status.waiting;
    final d = doctorById(a.doctorId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (waiting)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('#${a.ticket}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.deepOrange)),
                ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${a.name} · ${a.age} yrs', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${a.dept} with ${d.name}', style: Theme.of(context).textTheme.bodySmall),
                  Text('${dayLabel(a.day)} at ${fmtTime(a.time)} · ${a.reason.isEmpty ? 'No reason given' : a.reason}',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(waiting ? 'Waiting' : 'Booked'),
                backgroundColor: waiting ? Colors.orange.withOpacity(.2) : cs.primaryContainer,
                side: BorderSide.none,
              ),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              if (!waiting)
                FilledButton.tonal(
                  onPressed: () {
                    store.checkIn(a);
                    snack(context, 'Checked in. Ticket #${a.ticket}');
                  },
                  child: const Text('Check in'),
                ),
              if (waiting)
                FilledButton(
                  onPressed: () {
                    store.finish(a);
                    snack(context, 'Visit finished');
                  },
                  child: const Text('Call in and finish'),
                ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: cs.error),
                onPressed: () {
                  store.cancel(a);
                  snack(context, 'Appointment cancelled');
                },
                child: const Text('Cancel'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Doctors page ─────────────────────────

class DoctorsPage extends StatelessWidget {
  final Store store;
  final void Function(Doctor) onBook;
  const DoctorsPage({super.key, required this.store, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('All doctors and today’s availability',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final d in doctors)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DoctorCard(d: d, store: store, onBook: () => onBook(d)),
          ),
      ],
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor d;
  final Store store;
  final VoidCallback? onBook, onTap;
  const DoctorCard({super.key, required this.d, required this.store, this.onBook, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f0 = store.free(d.id, 0), f1 = store.free(d.id, 1);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: cs.primaryContainer, foregroundColor: cs.onPrimaryContainer, child: Text(d.initials)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${d.dept} · ${d.years} yrs · ${d.degree}', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: f0 / Store.times.length, minHeight: 6),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(f0 > 0 ? '$f0 slots free today' : 'Full today',
                  style: TextStyle(fontWeight: FontWeight.w600, color: f0 > 0 ? cs.primary : Colors.deepOrange)),
              Text('$f1 tomorrow', style: Theme.of(context).textTheme.bodySmall),
            ]),
            if (onBook != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(onPressed: onBook, child: const Text('Book this doctor')),
            ],
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Booking page ─────────────────────────

class BookingPage extends StatefulWidget {
  final Store store;
  final Doctor? initialDoctor;
  final VoidCallback onDone;
  const BookingPage({super.key, required this.store, this.initialDoctor, required this.onDone});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int step = 1, day = 0;
  String? dept, time;
  Doctor? doctor;
  String gender = 'Female';
  final formKey = GlobalKey<FormState>();
  final nameC = TextEditingController(),
      ageC = TextEditingController(),
      phoneC = TextEditingController(),
      reasonC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = widget.initialDoctor;
    if (d != null) {
      doctor = d;
      dept = d.dept;
      step = 3;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    ageC.dispose();
    phoneC.dispose();
    reasonC.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    if (!widget.store.slotOk(doctor!.id, day, time!)) {
      snack(context, 'That time was just taken. Pick another.');
      setState(() {
        step = 3;
        time = null;
      });
      return;
    }
    widget.store.book(
      name: nameC.text.trim(),
      age: int.parse(ageC.text),
      phone: phoneC.text.trim(),
      gender: gender,
      reason: reasonC.text.trim(),
      doctor: doctor!,
      day: day,
      time: time!,
    );
    snack(context, 'Appointment booked for ${nameC.text.trim()}');
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    const names = ['Department', 'Doctor', 'Time', 'Patient'];
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < 4; i++)
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text('${i + 1 < step ? '✓ ' : ''}${names[i]}'),
              backgroundColor: i + 1 == step ? cs.primary : null,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: i + 1 == step ? cs.onPrimary : null,
              ),
            ),
        ]),
        const SizedBox(height: 14),
        if (step == 1) _deptStep(),
        if (step == 2) _doctorStep(),
        if (step == 3) _timeStep(),
        if (step == 4) _patientStep(),
      ],
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      );

  Widget _back() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => step--),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ),
      );

  Widget _deptStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Which department?'),
        for (final d in departments)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                title: Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${d.$2} · ${doctors.where((x) => x.dept == d.$1).length} doctors'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() {
                  dept = d.$1;
                  step = 2;
                }),
              ),
            ),
          ),
      ]);

  Widget _doctorStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Choose a doctor in $dept'),
        for (final d in doctors.where((x) => x.dept == dept))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DoctorCard(
              d: d,
              store: widget.store,
              onTap: () => setState(() {
                doctor = d;
                time = null;
                step = 3;
              }),
            ),
          ),
        _back(),
      ]);

  Widget _timeStep() {
    final d = doctor!, cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Pick a time with ${d.name}'),
      Wrap(spacing: 8, children: [
        for (var n = 0; n < 4; n++)
          ChoiceChip(
            label: Text('${dayLabel(n)} (${widget.store.free(d.id, n)})'),
            selected: day == n,
            onSelected: (_) => setState(() {
              day = n;
              time = null;
            }),
          ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final t in Store.times)
          ChoiceChip(
            label: Text(fmtTime(t)),
            selected: time == t,
            selectedColor: cs.primary,
            labelStyle: TextStyle(
              color: time == t ? cs.onPrimary : null,
              decoration: widget.store.slotOk(d.id, day, t) ? null : TextDecoration.lineThrough,
            ),
            onSelected: widget.store.slotOk(d.id, day, t) ? (_) => setState(() => time = t) : null,
          ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        TextButton.icon(
          onPressed: () => setState(() => step = 2),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: time == null ? null : () => setState(() => step = 4),
          child: const Text('Continue'),
        ),
      ]),
    ]);
  }

  Widget _patientStep() {
    final d = doctor!;
    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('${d.name} · ${d.dept}\n${dayLabel(day)} at ${fmtTime(time!)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: nameC,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Patient name', border: OutlineInputBorder()),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the patient’s name' : null,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: ageC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n < 0 || n > 120) ? 'Enter a valid age' : null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: const ['Female', 'Male', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => gender = v!),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneC,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
          validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a phone number' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: reasonC,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Reason for visit', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(children: [
          TextButton.icon(
            onPressed: () => setState(() => step = 3),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
          const Spacer(),
          FilledButton(onPressed: save, child: const Text('Confirm appointment')),
        ]),
      ]),
    );
  }
}