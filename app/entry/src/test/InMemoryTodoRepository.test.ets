import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { NavPort } from '../main/ets/shared/kernel/NavPort';
import { ViewStatus } from '../main/ets/shared/kernel/ViewStatus';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { ListCard, ListsViewModel } from '../main/ets/features/todo/screens/lists/ListsViewModel';
import { ListViewModel } from '../main/ets/features/todo/screens/list/ListViewModel';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

class NoNav implements NavPort {
  push(name: string, param: string): void {
  }

  pop(): void {
  }
}

function freshStore(): TodoStore {
  const store: TodoStore = new TodoStore();
  new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen()).seed();
  return store;
}

function seedSummary(store: TodoStore): string {
  const lists: string = store.lists.map((l: TodoList): string => l.name).join(',');
  const items: string = store.items.map((i: TodoItem): string => i.title + (i.done ? '*' : '')).join(',');
  return lists + '|' + items;
}

export default function inMemoryTodoRepositoryTest() {
  describe('InMemoryTodoRepository', () => {
    it('TS-07-01 seed produces the documented lists and items on every fresh store', 0, () => {
      const expected: string = 'Weekend,Work,Groceries|Buy milk*,Buy eggs,Bread,Book meeting room*,Send weekly report';
      expect(seedSummary(freshStore())).assertEqual(expected);
      expect(seedSummary(freshStore())).assertEqual(expected);
    });
    it('TS-07-02 progress reads 1/3 for Groceries and no items for Weekend', 0, () => {
      const vm: ListsViewModel = new ListsViewModel(freshStore(), new NoNav());
      const cards: ListCard[] = vm.cards;
      expect(cards.map((c: ListCard): string => c.name).join(',')).assertEqual('Groceries,Work,Weekend');
      expect(cards[0].done).assertEqual(1);
      expect(cards[0].total).assertEqual(3);
      expect(cards[2].total).assertEqual(0);
    });
    it('TS-07-03 deleting every list leaves the store empty and status Empty', 0, () => {
      const store: TodoStore = freshStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const vm: ListsViewModel = new ListsViewModel(store, new NoNav());
      vm.load();
      const ids: string[] = store.lists.map((l: TodoList): string => l.id);
      ids.forEach((id: string) => {
        repo.deleteList(id);
      });
      expect(store.lists.length).assertEqual(0);
      expect(vm.status === ViewStatus.Empty).assertTrue();
    });
    it('ListsViewModel status is Loading before load and Ready after', 0, () => {
      const vm: ListsViewModel = new ListsViewModel(freshStore(), new NoNav());
      expect(vm.status === ViewStatus.Loading).assertTrue();
      vm.load();
      expect(vm.status === ViewStatus.Ready).assertTrue();
    });
    it('TS-08-01 Groceries orders to Bread, Buy eggs, Buy milk', 0, () => {
      const store: TodoStore = freshStore();
      const groceries: TodoList = store.lists.find((l: TodoList): boolean => l.name === 'Groceries') as TodoList;
      const vm: ListViewModel = new ListViewModel(store, new NoNav(), groceries.id);
      expect(vm.items.map((i: TodoItem): string => i.title).join(',')).assertEqual('Bread,Buy eggs,Buy milk');
    });
    it('TS-08-02 Work orders to Send weekly report, Book meeting room', 0, () => {
      const store: TodoStore = freshStore();
      const work: TodoList = store.lists.find((l: TodoList): boolean => l.name === 'Work') as TodoList;
      const vm: ListViewModel = new ListViewModel(store, new NoNav(), work.id);
      expect(vm.items.map((i: TodoItem): string => i.title).join(',')).assertEqual('Send weekly report,Book meeting room');
    });
    it('TS-08-03 Work items never appear under Groceries', 0, () => {
      const store: TodoStore = freshStore();
      const groceries: TodoList = store.lists.find((l: TodoList): boolean => l.name === 'Groceries') as TodoList;
      const vm: ListViewModel = new ListViewModel(store, new NoNav(), groceries.id);
      expect(vm.items.every((i: TodoItem): boolean => i.listId === groceries.id)).assertTrue();
      expect(vm.items.length).assertEqual(3);
      expect(vm.title).assertEqual('Groceries');
    });
  });
}
