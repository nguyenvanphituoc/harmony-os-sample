import { describe, it, expect } from '@ohos/hypium';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { NavPort } from '../main/ets/shared/kernel/NavPort';
import { ListsViewModel, ListCard } from '../main/ets/features/todo/screens/lists/ListsViewModel';

class NoopNav implements NavPort {
  push(name: string, param: string): void {
  }

  pop(): void {
  }
}

function cardFor(cards: ListCard[], listId: string): ListCard {
  return cards.find((c: ListCard): boolean => c.id === listId) as ListCard;
}

export default function listsViewModelTest() {
  describe('ListsViewModel', () => {
    it('TS-01-01 cards recomputes done/total correctly from a mutated store.items', 0, () => {
      const store: TodoStore = new TodoStore();
      store.lists = [new TodoList('list-1', 'Groceries', 100)];
      store.items = [
        new TodoItem('item-1', 'list-1', 'Bread', false, 100),
        new TodoItem('item-2', 'list-1', 'Buy eggs', false, 101)
      ];
      const vm: ListsViewModel = new ListsViewModel(store, new NoopNav());

      const before: ListCard = cardFor(vm.cards, 'list-1');
      expect(before.done).assertEqual(0);
      expect(before.total).assertEqual(2);

      store.items = [
        new TodoItem('item-1', 'list-1', 'Bread', true, 100),
        new TodoItem('item-2', 'list-1', 'Buy eggs', false, 101)
      ];

      const after: ListCard = cardFor(vm.cards, 'list-1');
      expect(after.done).assertEqual(1);
      expect(after.total).assertEqual(2);
    });

    it('TS-01-01 cards recomputes done/total correctly from a mutated store.lists', 0, () => {
      const store: TodoStore = new TodoStore();
      store.lists = [new TodoList('list-1', 'Groceries', 100)];
      store.items = [new TodoItem('item-1', 'list-1', 'Bread', true, 100)];
      const vm: ListsViewModel = new ListsViewModel(store, new NoopNav());

      expect(vm.cards.length).assertEqual(1);

      store.lists = [
        new TodoList('list-1', 'Groceries', 100),
        new TodoList('list-2', 'Chores', 101)
      ];
      store.items = [
        new TodoItem('item-1', 'list-1', 'Bread', true, 100),
        new TodoItem('item-2', 'list-2', 'Dishes', false, 101)
      ];

      const chores: ListCard = cardFor(vm.cards, 'list-2');
      expect(vm.cards.length).assertEqual(2);
      expect(chores.done).assertEqual(0);
      expect(chores.total).assertEqual(1);
    });
  });
}
