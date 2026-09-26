import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { CreateList } from '../main/ets/features/todo/domain/CreateList';

class FixedClock implements Clock {
  now(): number {
    return 1000;
  }
}

function fresh(): TodoStore {
  return new TodoStore();
}

export default function createListTest() {
  describe('CreateList', () => {
    it('TS-01-01 blank names return LIST_NAME_EMPTY and add no list', 0, () => {
      const store: TodoStore = fresh();
      const create: CreateList = new CreateList(new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen()));
      const empty: Result<TodoList> = create.execute('');
      const blank: Result<TodoList> = create.execute('   ');
      expect(empty.isOk).assertEqual(false);
      expect(empty.error === ErrorCode.LIST_NAME_EMPTY).assertEqual(true);
      expect(blank.error === ErrorCode.LIST_NAME_EMPTY).assertEqual(true);
      expect(store.lists.length).assertEqual(0);
    });

    it('TS-01-02 the same name twice yields two lists', 0, () => {
      const store: TodoStore = fresh();
      const create: CreateList = new CreateList(new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen()));
      create.execute('Travel');
      create.execute('Travel');
      expect(store.lists.length).assertEqual(2);
      expect(store.lists[0].name).assertEqual(store.lists[1].name);
      expect(store.lists[0].id === store.lists[1].id).assertEqual(false);
    });

    it('TS-01-03 the stored name is trimmed', 0, () => {
      const store: TodoStore = fresh();
      const create: CreateList = new CreateList(new InMemoryTodoRepository(store, new FixedClock(), new SequenceIdGen()));
      const made: Result<TodoList> = create.execute('  Trips ');
      expect(made.isOk).assertEqual(true);
      expect(store.lists[0].name).assertEqual('Trips');
    });
  });
}
