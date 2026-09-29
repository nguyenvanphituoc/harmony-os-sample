import { describe, it, expect } from '@ohos/hypium';
import { SequenceIdGen } from '../main/ets/shared/kernel/IdGen';
import { Clock } from '../main/ets/shared/kernel/Clock';
import { NavPort } from '../main/ets/shared/kernel/NavPort';
import { InMemoryTodoRepository } from '../main/ets/features/todo/domain/InMemoryTodoRepository';
import { TodoStore } from '../main/ets/features/todo/domain/TodoStore';
import { TodoList } from '../main/ets/features/todo/domain/TodoList';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ToggleItem } from '../main/ets/features/todo/domain/ToggleItem';
import { SettleWindow } from '../main/ets/features/todo/domain/SettleWindow';
import { ListViewModel, ItemDeleteOpener } from '../main/ets/features/todo/screens/list/ListViewModel';

class SettableClock implements Clock {
  private current: number = 0;

  now(): number {
    return this.current;
  }

  advanceTo(value: number): void {
    this.current = value;
  }
}

class NoopNav implements NavPort {
  push(name: string, param: string): void {
  }

  pop(): void {
  }
}

class SpyDeleteOpener implements ItemDeleteOpener {
  callCount: number = 0;
  lastItemId: string = '';
  lastTitle: string = '';

  openDelete(itemId: string, title: string): void {
    this.callCount = this.callCount + 1;
    this.lastItemId = itemId;
    this.lastTitle = title;
  }
}

function seeded(clock: Clock): TodoStore {
  const store: TodoStore = new TodoStore();
  new InMemoryTodoRepository(store, clock, new SequenceIdGen()).seed();
  return store;
}

function groceriesId(store: TodoStore): string {
  return (store.lists.find((l: TodoList): boolean => l.name === 'Groceries') as TodoList).id;
}

function doneMap(store: TodoStore, listId: string): string {
  return store.items.filter((i: TodoItem): boolean => i.listId === listId)
    .map((i: TodoItem): string => i.id + ':' + i.done.toString()).join(',');
}

export default function listViewModelTest() {
  describe('ListViewModel', () => {
    it('TS-01-01 a second onToggle within windowMs of the first does not call ToggleItem again', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);
      const afterFirst: string = doneMap(store, listId);

      clock.advanceTo(1100);
      vm.onToggle(bread.id);

      expect(doneMap(store, listId)).assertEqual(afterFirst);
    });

    it('TS-01-02 an onToggle at or after windowMs since the first calls ToggleItem again', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);
      const afterFirst: boolean = (store.items.find((i: TodoItem): boolean => i.id === bread.id) as TodoItem).done;

      clock.advanceTo(1400);
      vm.onToggle(bread.id);
      const afterSecond: boolean = (store.items.find((i: TodoItem): boolean => i.id === bread.id) as TodoItem).done;

      expect(afterSecond).assertEqual(!afterFirst);
    });

    it('TS-01-03 the window guards a call for a different itemId inside the same window', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const eggs: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Buy eggs') as TodoItem;
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);
      const afterFirst: string = doneMap(store, listId);

      clock.advanceTo(1100);
      vm.onToggle(eggs.id);

      expect(doneMap(store, listId)).assertEqual(afterFirst);
    });

    it('delete TS-01-01 a delete tap within the settle window of a toggle opens no dialog', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const opener: SpyDeleteOpener = new SpyDeleteOpener();
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, opener, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);

      clock.advanceTo(1100);
      vm.onDeleteItem(bread.id);

      expect(opener.callCount).assertEqual(0);
    });

    it('delete TS-01-02 a delete tap at or after the settle window of a toggle opens the dialog', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const opener: SpyDeleteOpener = new SpyDeleteOpener();
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, opener, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);

      clock.advanceTo(1400);
      vm.onDeleteItem(bread.id);

      expect(opener.callCount).assertEqual(1);
      expect(opener.lastItemId).assertEqual(bread.id);
      expect(opener.lastTitle).assertEqual(bread.title);
    });

    it('delete TS-01-03 a delete tap inside the settle window does not extend it', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const opener: SpyDeleteOpener = new SpyDeleteOpener();
      const vm: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, opener, clock);

      clock.advanceTo(1000);
      vm.onToggle(bread.id);

      clock.advanceTo(1100);
      vm.onDeleteItem(bread.id);

      clock.advanceTo(1399);
      vm.onDeleteItem(bread.id);

      expect(opener.callCount).assertEqual(0);

      clock.advanceTo(1400);
      vm.onDeleteItem(bread.id);

      expect(opener.callCount).assertEqual(1);
    });

    it('shared window TS-01-01 a toggle on the first VM then a delete tap on the second VM inside the window opens no dialog', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const eggs: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Buy eggs') as TodoItem;
      const window: SettleWindow = new SettleWindow();
      const opener: SpyDeleteOpener = new SpyDeleteOpener();
      const vm1: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);
      const vm2: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, opener, clock, window);

      clock.advanceTo(1000);
      vm1.onToggle(bread.id);

      clock.advanceTo(1100);
      vm2.onDeleteItem(eggs.id);

      expect(opener.callCount).assertEqual(0);
    });

    it('shared window TS-01-02 a toggle on the first VM then a toggle tap on the second VM inside the window does not call ToggleItem', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const eggs: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Buy eggs') as TodoItem;
      const window: SettleWindow = new SettleWindow();
      const vm1: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);
      const vm2: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);

      clock.advanceTo(1000);
      vm1.onToggle(bread.id);
      const afterFirst: string = doneMap(store, listId);

      clock.advanceTo(1100);
      vm2.onToggle(eggs.id);

      expect(doneMap(store, listId)).assertEqual(afterFirst);
    });

    it('shared window TS-01-03 a toggle on the first VM then, past the window, a delete tap on the second VM opens the dialog naming that row\'s item', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const eggs: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Buy eggs') as TodoItem;
      const window: SettleWindow = new SettleWindow();
      const opener: SpyDeleteOpener = new SpyDeleteOpener();
      const vm1: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);
      const vm2: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, opener, clock, window);

      clock.advanceTo(1000);
      vm1.onToggle(bread.id);

      clock.advanceTo(1400);
      vm2.onDeleteItem(eggs.id);

      expect(opener.callCount).assertEqual(1);
      expect(opener.lastItemId).assertEqual(eggs.id);
      expect(opener.lastTitle).assertEqual(eggs.title);
    });

    it('shared window TS-01-04 a toggle on the first VM then, past the window, a toggle tap on the second VM calls ToggleItem', 0, () => {
      const clock: SettableClock = new SettableClock();
      const store: TodoStore = seeded(clock);
      const repo: InMemoryTodoRepository = new InMemoryTodoRepository(store, clock, new SequenceIdGen());
      const listId: string = groceriesId(store);
      const bread: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Bread') as TodoItem;
      const eggs: TodoItem = store.items.find((i: TodoItem): boolean => i.title === 'Buy eggs') as TodoItem;
      const window: SettleWindow = new SettleWindow();
      const vm1: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);
      const vm2: ListViewModel = new ListViewModel(store, new NoopNav(), listId,
        new ToggleItem(repo, store), undefined, undefined, clock, window);

      clock.advanceTo(1000);
      vm1.onToggle(bread.id);
      const eggsBefore: boolean = (store.items.find((i: TodoItem): boolean => i.id === eggs.id) as TodoItem).done;

      clock.advanceTo(1400);
      vm2.onToggle(eggs.id);
      const eggsAfter: boolean = (store.items.find((i: TodoItem): boolean => i.id === eggs.id) as TodoItem).done;

      expect(eggsAfter).assertEqual(!eggsBefore);
    });
  });
}
