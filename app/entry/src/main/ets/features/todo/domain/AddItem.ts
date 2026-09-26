import { ErrorCode, Result } from './Result';
import { TodoItem } from './TodoItem';
import { TodoRepository } from './TodoRepository';
import { TodoRules } from './TodoRules';

export class AddItem {
  private repository: TodoRepository;

  constructor(repository: TodoRepository) {
    this.repository = repository;
  }

  execute(listId: string, title: string): Result<TodoItem> {
    const checked: Result<string> = TodoRules.checkItemTitle(title);
    if (!checked.isOk) {
      return Result.failure<TodoItem>(checked.error as ErrorCode);
    }
    return this.repository.addItem(listId, checked.value as string);
  }
}
