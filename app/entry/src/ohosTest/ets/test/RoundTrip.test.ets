import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../../../main/ets/shared/kernel/IdGen';
import { Clock } from '../../../main/ets/shared/kernel/Clock';
import { InMemoryTodoRepository } from '../../../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../../../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../../../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../../../main/ets/features/todo/domain/TodoItem';
import { CreateList } from '../../../main/ets/features/todo/domain/CreateList';
import { AddItem } from '../../../main/ets/features/todo/domain/AddItem';
import { ToggleItem } from '../../../main/ets/features/todo/domain/ToggleItem';
import { RenameList } from '../../../main/ets/features/todo/domain/RenameList';
import { DeleteItem } from '../../../main/ets/features/todo/domain/DeleteItem';
import { DeleteList } from '../../../main/ets/features/todo/domain/DeleteList';

class RoundTripClock implements Clock {
  now(): number {
    return 1000;
  }
}

export default function roundTripTest() {
  describe('RoundTrip', () => {
    it('create list, add item, toggle, rename, delete item, delete list', 0, () => {
      const store: TodoStore = new TodoStore();
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, new RoundTripClock(), new SequenceIdGen());
      const list: TodoList = new CreateList(repo).execute('Trip').value as TodoList;
      expect(store.lists.length).assertEqual(1);
      const item: TodoItem = new AddItem(repo).execute(list.id, 'Passport').value as TodoItem;
      expect(store.items.length).assertEqual(1);
      const toggled: TodoItem = new ToggleItem(repo, store).execute(item.id).value as TodoItem;
      expect(toggled.done).assertEqual(true);
      const renamed: TodoList = new RenameList(repo).execute(list.id, 'Trip 2').value as TodoList;
      expect(renamed.name).assertEqual('Trip 2');
      expect(new DeleteItem(repo).execute(item.id).isOk).assertEqual(true);
      expect(store.items.length).assertEqual(0);
      expect(new DeleteList(repo).execute(list.id).isOk).assertEqual(true);
      expect(store.lists.length).assertEqual(0);
    })
  })
}
