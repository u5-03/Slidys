import 'dart:math';

enum SortOrder {
  ascending,
  descending,
}

extension ListExt<T> on List<T> {
  T get randomListItem => this[Random().nextInt(length)];

  // List<T> sorted<R extends Comparable<R>>(
  //   R Function(T) keySelector,
  //   SortOrder order, {
  //   R Function(T)? secondKeySelector,
  //   SortOrder? secondOrder,
  // }) {
  //   return List<T>.from(this)
  //     ..sort((a, b) {
  //       final aValue = keySelector(a);
  //       final bValue = keySelector(b);
  //       var compare = Comparable.compare(aValue, bValue);
  //       if (compare == 0 && secondKeySelector != null) {
  //         final aSecondValue = secondKeySelector(a);
  //         final bSecondValue = secondKeySelector(b);
  //         compare = Comparable.compare(aSecondValue, bSecondValue) *
  //             (secondOrder == SortOrder.descending ? -1 : 1);
  //       }
  //       return compare * (order == SortOrder.descending ? -1 : 1);
  //     });
  // }

  List<T> sorted(
    Comparable<Object> Function(T) key, {
    SortOrder order = SortOrder.ascending,
  }) {
    final newList = List<T>.from(this)
      ..sort((a, b) {
        final result = key(a).compareTo(key(b));
        // ソート順が降順の場合は結果を反転
        return order == SortOrder.ascending ? result : -result;
      });
    return newList;
  }
}
