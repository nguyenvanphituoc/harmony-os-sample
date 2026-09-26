import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { DeleteList } from '../main/ets/features/todo/domain/DeleteList';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

export default function deleteListTest() {
  describe('DeleteList', () => {
    it('TS-03-01 items of A are gone, items of B remain', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const a: TodoList = repo.createList('A').value as TodoList;
      const b: TodoList = repo.createList('B').value as TodoList;
      repo.addItem(a.id, 'a1');
      repo.addItem(a.id, 'a2');
      repo.addItem(b.id, 'b1');
      const result: Result<void> = new DeleteList(repo).execute(a.id);
      expect(result.isOk).assertEqual(true);
      expect(store.lists.length).assertEqual(1);
      expect(store.lists[0].id).assertEqual(b.id);
      expect(store.items.length).assertEqual(1);
      expect(store.items.map((i: TodoItem): string => i.listId).join(',')).assertEqual(b.id);
    });

    it('TS-03-02 an unknown id returns LIST_NOT_FOUND', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      repo.createList('A');
      const result: Result<void> = new DeleteList(repo).execute('missing');
      expect(result.isOk).assertEqual(false);
      expect(result.error === ErrorCode.LIST_NOT_FOUND).assertEqual(true);
      expect(store.lists.length).assertEqual(1);
    });
  });
}
