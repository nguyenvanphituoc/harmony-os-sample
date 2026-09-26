import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { ItemOrder } from '../main/ets/features/todo/domain/ItemOrder';
import { AddItem } from '../main/ets/features/todo/domain/AddItem';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

export default function addItemTest() {
  describe('AddItem', () => {
    it('TS-04-01 an empty or blank title returns ITEM_TITLE_EMPTY and adds nothing', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const list: TodoList = repo.createList('A').value as TodoList;
      const add: AddItem = new AddItem(repo);
      const empty: Result<TodoItem> = add.execute(list.id, '');
      const blank: Result<TodoItem> = add.execute(list.id, '  ');
      expect(empty.isOk).assertEqual(false);
      expect(empty.error === ErrorCode.ITEM_TITLE_EMPTY).assertEqual(true);
      expect(blank.error === ErrorCode.ITEM_TITLE_EMPTY).assertEqual(true);
      expect(store.items.length).assertEqual(0);
    });

    it('TS-04-02 a new item is open and visible only under its list', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const a: TodoList = repo.createList('A').value as TodoList;
      const b: TodoList = repo.createList('B').value as TodoList;
      const result: Result<TodoItem> = new AddItem(repo).execute(a.id, 'Hike');
      expect(result.isOk).assertEqual(true);
      expect((result.value as TodoItem).done).assertEqual(false);
      expect(store.items.filter((i: TodoItem): boolean => i.listId === a.id).length).assertEqual(1);
      expect(store.items.filter((i: TodoItem): boolean => i.listId === b.id).length).assertEqual(0);
    });

    it('a new item is the first open card', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const a: TodoList = repo.createList('A').value as TodoList;
      const add: AddItem = new AddItem(repo);
      add.execute(a.id, 'First');
      add.execute(a.id, 'Hike');
      const sorted: TodoItem[] = ItemOrder.sort(store.items);
      expect(sorted[0].title).assertEqual('Hike');
    });
  });
}
