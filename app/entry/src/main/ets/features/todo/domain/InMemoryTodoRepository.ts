import { Clock } from '../../../shared/kernel/Clock';
import { IdGen } from '../../../shared/kernel/IdGen';
import { ErrorCode, Result } from './Result';
import { TodoList } from './TodoList';
import { TodoItem } from './TodoItem';
import { TodoRepository, TodoStoreState } from './TodoRepository';

export class InMemoryTodoRepository implements TodoRepository {
  private store: TodoStoreState;
  private clock: Clock;
  private idGen: IdGen;
  private lastStamp: number = 0;

  constructor(store: TodoStoreState, clock: Clock, idGen: IdGen) {
    this.store = store;
    this.clock = clock;
    this.idGen = idGen;
  }

  private stamp(): number {
    const now: number = this.clock.now();
    this.lastStamp = now > this.lastStamp ? now : this.lastStamp + 1;
    return this.lastStamp;
  }

  seed(): void {
    this.store.lists = [];
    this.store.items = [];
    this.createList('Weekend');
    const work: TodoList = this.createList('Work').value as TodoList;
    const groceries: TodoList = this.createList('Groceries').value as TodoList;
    const milk: TodoItem = this.addItem(groceries.id, 'Buy milk').value as TodoItem;
    this.setDone(milk.id, true);
    this.addItem(groceries.id, 'Buy eggs');
    this.addItem(groceries.id, 'Bread');
    const room: TodoItem = this.addItem(work.id, 'Book meeting room').value as TodoItem;
    this.setDone(room.id, true);
    this.addItem(work.id, 'Send weekly report');
  }

  createList(name: string): Result<TodoList> {
    const list: TodoList = new TodoList(this.idGen.next('list'), name, this.stamp());
    this.store.lists = this.store.lists.concat([list]);
    return Result.success<TodoList>(list);
  }

  renameList(listId: string, name: string): Result<TodoList> {
    const found: TodoList | undefined = this.store.lists.find((l: TodoList): boolean => l.id === listId);
    if (found === undefined) {
      return Result.failure<TodoList>(ErrorCode.LIST_NOT_FOUND);
    }
    const renamed: TodoList = new TodoList(found.id, name, found.createdAt);
    this.store.lists = this.store.lists.map((l: TodoList): TodoList => l.id === listId ? renamed : l);
    return Result.success<TodoList>(renamed);
  }

  deleteList(listId: string): Result<void> {
    if (!this.store.lists.some((l: TodoList): boolean => l.id === listId)) {
      return Result.failure<void>(ErrorCode.LIST_NOT_FOUND);
    }
    this.store.lists = this.store.lists.filter((l: TodoList): boolean => l.id !== listId);
    this.store.items = this.store.items.filter((i: TodoItem): boolean => i.listId !== listId);
    return Result.success<void>(undefined);
  }

  addItem(listId: string, title: string): Result<TodoItem> {
    if (!this.store.lists.some((l: TodoList): boolean => l.id === listId)) {
      return Result.failure<TodoItem>(ErrorCode.LIST_NOT_FOUND);
    }
    const item: TodoItem = new TodoItem(this.idGen.next('item'), listId, title, false, this.stamp());
    this.store.items = this.store.items.concat([item]);
    return Result.success<TodoItem>(item);
  }

  setDone(itemId: string, done: boolean): Result<TodoItem> {
    const found: TodoItem | undefined = this.store.items.find((i: TodoItem): boolean => i.id === itemId);
    if (found === undefined) {
      return Result.failure<TodoItem>(ErrorCode.ITEM_NOT_FOUND);
    }
    const updated: TodoItem = new TodoItem(found.id, found.listId, found.title, done, found.createdAt);
    this.store.items = this.store.items.map((i: TodoItem): TodoItem => i.id === itemId ? updated : i);
    return Result.success<TodoItem>(updated);
  }

  deleteItem(itemId: string): Result<void> {
    if (!this.store.items.some((i: TodoItem): boolean => i.id === itemId)) {
      return Result.failure<void>(ErrorCode.ITEM_NOT_FOUND);
    }
    this.store.items = this.store.items.filter((i: TodoItem): boolean => i.id !== itemId);
    return Result.success<void>(undefined);
  }
}
