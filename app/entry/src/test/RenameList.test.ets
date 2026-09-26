import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { RenameList } from '../main/ets/features/todo/domain/RenameList';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

export default function renameListTest() {
  describe('RenameList', () => {
    it('TS-02-01 a blank name returns LIST_NAME_EMPTY and keeps the old name', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const list: TodoList = repo.createList('Travel').value as TodoList;
      const result: Result<TodoList> = new RenameList(repo).execute(list.id, '  ');
      expect(result.isOk).assertEqual(false);
      expect(result.error === ErrorCode.LIST_NAME_EMPTY).assertEqual(true);
      expect(store.lists[0].name).assertEqual('Travel');
    });

    it('TS-02-02 rename keeps id, createdAt and items', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const list: TodoList = repo.createList('Travel').value as TodoList;
      repo.addItem(list.id, 'Passport');
      const result: Result<TodoList> = new RenameList(repo).execute(list.id, ' Trips ');
      expect(result.isOk).assertEqual(true);
      expect(store.lists.length).assertEqual(1);
      expect(store.lists[0].name).assertEqual('Trips');
      expect(store.lists[0].id).assertEqual(list.id);
      expect(store.lists[0].createdAt).assertEqual(list.createdAt);
      expect(store.items.length).assertEqual(1);
      expect(store.items.map((i: TodoItem): string => i.listId).join(',')).assertEqual(list.id);
    });

    it('TS-02-03 an unknown id returns LIST_NOT_FOUND', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen());
      const result: Result<TodoList> = new RenameList(repo).execute('missing', 'X');
      expect(result.isOk).assertEqual(false);
      expect(result.error === ErrorCode.LIST_NOT_FOUND).assertEqual(true);
    });
  });
}
