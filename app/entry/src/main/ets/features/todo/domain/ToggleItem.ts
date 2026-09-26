import { ErrorCode, Result } from './Result';
import { TodoItem } from './TodoItem';
import { TodoRepository, TodoStoreState } from './TodoRepository';

export class ToggleItem {
  private repository: TodoRepository;
  private store: TodoStoreState;

  constructor(repository: TodoRepository, store: TodoStoreState) {
    this.repository = repository;
    this.store = store;
  }

  execute(itemId: string): Result<TodoItem> {
    const found: TodoItem | undefined = this.store.items.find((i: TodoItem): boolean => i.id === itemId);
    if (found === undefined) {
      return Result.failure<TodoItem>(ErrorCode.ITEM_NOT_FOUND);
    }
    return this.repository.setDone(itemId, !found.done);
  }
}
