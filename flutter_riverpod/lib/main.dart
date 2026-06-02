import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ======== PROVIDER ========
final greetingProvider = Provider<String>((ref) {
  // Provider: giá trị đọc-only, chỉ tạo lại khi provider bị invalidate.
  return 'Riverpod Provider: giá trị cố định, không rebuild khi state thay đổi.';
});

// ======== STATE PROVIDER ========
final counterProvider = StateProvider<int>((ref) {
  // StateProvider lưu state mutable và thông báo rebuild cho các widget đang watch.
  return 0;
});

// ======== FUTURE PROVIDER ========
final randomNumberProvider = FutureProvider.autoDispose<int>((ref) async {
  // FutureProvider: trạng thái async. Nó có 3 bước chính:
  // - loading: chờ Future hoàn thành.
  // - data: trả về kết quả thành công.
  // - error: nếu future ném exception.
  // autoDispose: khi không còn listener, provider có thể bị dispose và sẽ
  // chạy lại nếu được watch lại sau đó.
  await Future.delayed(const Duration(seconds: 2));
  return Random().nextInt(100);
});

// ======== CHANGE NOTIFIER PROVIDER ========
class CounterNotifier extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  void increment() {
    _value++;
    notifyListeners();
  }

  void decrement() {
    _value--;
    notifyListeners();
  }

  void reset() {
    _value = 0;
    notifyListeners();
  }
}

final counterNotifierProvider = ChangeNotifierProvider<CounterNotifier>((ref) {
  // ChangeNotifierProvider: wrapper cho ValueNotifier hoặc ChangeNotifier.
  // Tự động lắng nghe thay đổi và rebuild khi notifyListeners() được gọi.
  // Phù hợp cho state logic phức tạp hơn (multiple actions).
  return CounterNotifier();
});

// ======== STREAM PROVIDER ========
final tickStreamProvider = StreamProvider.autoDispose<int>((ref) {
  // StreamProvider: quản lý async stream. Nó cập nhật UI mỗi lần stream phát một giá trị.
  // loading → chờ stream phát giá trị đầu tiên.
  // data → mỗi giá trị stream phát, UI rebuild.
  // error → nếu stream ném exception.
  // autoDispose: khi widget rời khỏi, stream sẽ hủy.
  return Stream.periodic(
    const Duration(seconds: 1),
    (count) => count,
  ).take(10); // phát 10 giá trị rồi dừng
});

// ======== NOTIFIER / STATENOTIFIER ========
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, this.completed = false});

  Todo copyWith({String? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

class TodoNotifier extends Notifier<List<Todo>> {
  // Notifier: state logic tập trung, thay thế cũ StateNotifier (giờ là recommended way).
  // async build() cho state ban đầu (có thể async).
  // Các methods thay đổi state và gọi state = ... để notify listeners.

  @override
  List<Todo> build() {
    // Khởi tạo state ban đầu.
    return [
      Todo(id: '1', title: 'Learn Riverpod', completed: true),
      Todo(id: '2', title: 'Build a todo app', completed: false),
    ];
  }

  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );
    state = [...state, newTodo];
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      return todo.id == id ? todo.copyWith(completed: !todo.completed) : todo;
    }).toList();
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  // NotifierProvider: wrapper cho Notifier class. Modern cách để quản lý complex state.
  return TodoNotifier();
});

// ======== ASYNC VALUE PATTERN ========
// AsyncValue là một sealed class có 3 state: loading, data, error.
// Bạn có thể match/when nó như FutureProvider kết quả, nhưng nó có thể dùng ở bất cứ provider nào.
final userDataProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  // Giả lập fetch user data từ API
  await Future.delayed(const Duration(seconds: 3));

  // Tính toán làm cho lỗi ngẫu nhiên 20% của lần gọi
  if (Random().nextDouble() < 0.2) {
    throw Exception('Failed to fetch user data');
  }

  return {
    'name': 'John Doe',
    'email': 'john@example.com',
    'role': 'Flutter Developer',
  };
});

// ======== REF.LISTEN FOR SIDE EFFECTS ========
// ref.listen() dùng để nghe thay đổi provider và thực hiện side effects (không rebuild).
// Ví dụ: show snackbar, navigate, gửi analytics, v.v.
final sideEffectCounterProvider = StateProvider<int>((ref) => 0);

// Không phải là một provider, nhưng demo ref.listen() trong widget.
// Hoặc tạo provider khác watch sideEffectCounterProvider và thực hiện side effect.
final sideEffectListenerProvider = Provider((ref) {
  // Khi sideEffectCounterProvider thay đổi, cái này sẽ chạy side effect.
  // Ví dụ: ghi log, trigger notification, etc.
  ref.listen(sideEffectCounterProvider, (previous, next) {
    // previous: giá trị cũ, next: giá trị mới
    // Chỉ chạy khi giá trị thay đổi, không phải rebuild widget.
    debugPrint('Side effect: counter changed from $previous to $next');
  });

  return null;
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RiverpodExamplePage(),
    );
  }
}

class RiverpodExamplePage extends ConsumerWidget {
  const RiverpodExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    final counter = ref.watch(counterProvider);
    final asyncRandom = ref.watch(randomNumberProvider);
    final counterNotifier = ref.watch(counterNotifierProvider);
    final tickStream = ref.watch(tickStreamProvider);
    final todos = ref.watch(todoProvider);
    final userData = ref.watch(userDataProvider);
    final sideEffectCounter = ref.watch(sideEffectCounterProvider);
    
    // Set up side effect listener
    ref.watch(sideEffectListenerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Advanced Patterns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _SectionCard(
              title: 'Provider',
              description:
                  'Provider là giá trị read-only. Nó bị tạo một lần và cache lại cho đến khi provider bị invalidate hoặc hot reload.',
              child: Text(
                greeting,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'StateProvider',
              description:
                  'StateProvider lưu giá trị có thể thay đổi. Khi state được cập nhật, các widget đang watch sẽ rebuild.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    counter.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  FilledButton(
                    onPressed: () {
                      ref.read(counterProvider.notifier).state++;
                    },
                    child: const Text('Tăng'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'FutureProvider',
              description:
                  'FutureProvider tự động quản lý lifecycle async. Một khi có listener, nó sẽ load dữ liệu, hiển thị loading/data/error. Với autoDispose, khi rời khỏi màn hình hoặc không còn listener, provider có thể bị dispose.',
              child: asyncRandom.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Lỗi: ${error.toString()}'),
                data: (value) => Text(
                  'Số random: $value',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: FilledButton.tonal(
                onPressed: () {
                  ref.invalidate(randomNumberProvider);
                },
                child: const Text('Tải lại số random'),
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'ChangeNotifierProvider',
              description:
                  'ChangeNotifierProvider quản lý state thông qua ChangeNotifier hoặc ValueNotifier. Phù hợp cho state logic phức tạp với nhiều methods. Nó tự động lắng nghe notifyListeners() và rebuild UI.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counter: ${counterNotifier.value}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FilledButton(
                        onPressed: () {
                          counterNotifier.increment();
                        },
                        child: const Text('Tăng'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          counterNotifier.decrement();
                        },
                        child: const Text('Giảm'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          counterNotifier.reset();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'StreamProvider',
              description:
                  'StreamProvider quản lý async stream. Mỗi lần stream phát một giá trị, UI sẽ rebuild. Thích hợp cho real-time data (WebSocket, periodic events, v.v.). Với autoDispose, stream tự động cancel khi không còn listener.',
              child: tickStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Lỗi: ${error.toString()}'),
                data: (value) => Column(
                  children: [
                    Text(
                      'Tick: $value/10',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (value + 1) / 10,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Notifier / StateNotifier',
              description:
                  'Notifier: modern cách quản lý complex state logic. Các methods thay đổi state rồi gọi state = ... để notify listeners. Thích hợp cho todo list, form management, v.v. (StateNotifier là cách cũ, Notifier là recommended)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách (${todos.length} items):',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (todos.isEmpty)
                    const Text('Không có todo'),
                  if (todos.isNotEmpty)
                    ...todos.map((todo) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: todo.completed,
                            onChanged: (_) {
                              ref.read(todoProvider.notifier).toggleTodo(todo.id);
                            },
                          ),
                          Expanded(
                            child: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () {
                              ref.read(todoProvider.notifier).removeTodo(todo.id);
                            },
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'AsyncValue Pattern',
              description:
                  'AsyncValue có 3 state: loading, data, error. Nó là cách chuẩn để handle async state. Bạn có thể dùng .when() để match 3 state và hiển thị UI thích hợp.',
              child: userData.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lỗi: ${error.toString()}',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                data: (userData) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...userData.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(entry.value),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'ref.listen() - Side Effects',
              description:
                  'ref.listen() nghe thay đổi provider mà không rebuild widget. Dùng cho side effects: snackbar, navigation, analytics, logging. Khi sideEffectCounter thay đổi, console sẽ in log.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Side Effect Counter:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        sideEffectCounter.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '(Kiểm tra console log)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FilledButton(
                        onPressed: () {
                          ref.read(sideEffectCounterProvider.notifier).state++;
                        },
                        child: const Text('Tăng'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          ref.read(sideEffectCounterProvider.notifier).state = 0;
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chú thích lifecycle & rebuild:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '''- Provider: chỉ rebuild khi provider bị invalidate hoặc khi phụ thuộc thay đổi.
- StateProvider: rebuild ngay khi state thay đổi.
- FutureProvider: rebuild từng lần load lại async, trạng thái giữ lại nếu vẫn có listener.
- ChangeNotifierProvider: rebuild khi notifyListeners() được gọi, phù hợp cho state phức tạp.
- StreamProvider: rebuild mỗi lần stream phát giá trị, lý tưởng cho real-time data.
- Notifier/NotifierProvider: modern cách quản lý complex state với methods. Rebuild khi state = ... được gọi.
- AsyncValue: chuẩn pattern cho async state (loading/data/error), dùng .when() để match.
- ref.listen(): nghe thay đổi provider mà không rebuild, dùng cho side effects (snackbar, log, etc).
- autoDispose: provider bị dispose khi không còn ai watch, giúp giải phóng bộ nhớ và chạy lại khi watch lại.''',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
