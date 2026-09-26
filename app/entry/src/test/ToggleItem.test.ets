import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { ItemOrder } from '../main/ets/features/todo/domain/ItemOrder';
import { ToggleItem } from '../main/ets/features/todo/domain/ToggleItem';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

function seeded(): TodoStore {
  const store: TodoStore = new TodoStore();
  new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen()).seed();
  return store;
}

function groceryTitles(store: TodoStore): string {
  const groceries: TodoList = store.lists.find((l: TodoList): boolean => l.name === 'Groceries') as TodoList;
  return ItemOrder.sort(store.items.filter((i: TodoItem): boolean => i.listId === groceries.id))
    .map((i: TodoItem): string => i.title + (i.done ? '*' : '')).join(',');
}

export default function toggleItemTest() {
  describe('ToggleItem', () => {
    it('TS-05-06 an unknown id returns ITEM_NOT_FOUND and changes nothing', 0, () => {
      const store: TodoStore = seeded();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const before: string = store.items.map((i: TodoItem): string => i.id + i.done.toString()).join(',');
      const result: Result<TodoItem> = new ToggleItem(repo, store).execute('missing');
      expect(result.isOk).assertEqual(false);
      expect(result.error === ErrorCode.ITEM_NOT_FOUND).assertEqual(true);
      expect(store.items.map((i: TodoItem): string => i.id + i.done.toString()).join(',')).assertEqual(before);
    });

    it('TS-05-04 marking Bread done puts it in the done group before Buy milk', 0, () => {
      const store: TodoStore = seeded();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const result: Result<TodoItem> = new ToggleItem(repo, store).execute(bread.id);
      expect(result.isOk).assertEqual(true);
      expect(groceryTitles(store)).assertEqual('Buy eggs,Bread*,Buy milk*');
    });

    it('TS-05-03 toggling Bread twice returns it above Buy eggs', 0, () => {
      const store: TodoStore = seeded();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const toggle: ToggleItem = new ToggleItem(repo, store);
      toggle.execute(bread.id);
      toggle.execute(bread.id);
      expect(groceryTitles(store)).assertEqual('Bread,Buy eggs,Buy milk*');
    });
  });
}
