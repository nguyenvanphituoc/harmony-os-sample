import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { DeleteItem } from '../main/ets/features/todo/domain/DeleteItem';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

export default function deleteItemTest() {
  describe('DeleteItem', () => {
    it('TS-06-01 removes only that item', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const list: TodoList = repo.createList('A').value as TodoList;
      const first: TodoItem = repo.addItem(list.id, 'one').value as TodoItem;
      const second: TodoItem = repo.addItem(list.id, 'two').value as TodoItem;
      const result: Result<void> = new DeleteItem(repo).execute(first.id);
      expect(result.isOk).assertEqual(true);
      expect(store.lists.length).assertEqual(1);
      expect(store.items.length).assertEqual(1);
      expect(store.items[0].id).assertEqual(second.id);
    });

    it('TS-06-02 an unknown id returns ITEM_NOT_FOUND', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const list: TodoList = repo.createList('A').value as TodoList;
      repo.addItem(list.id, 'one');
      const result: Result<void> = new DeleteItem(repo).execute('missing');
      expect(result.isOk).assertEqual(false);
      expect(result.error === ErrorCode.ITEM_NOT_FOUND).assertEqual(true);
      expect(store.items.length).assertEqual(1);
    });
  });
}
