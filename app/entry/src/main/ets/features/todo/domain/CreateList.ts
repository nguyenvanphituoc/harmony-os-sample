import { ErrorCode, Result } from './Result';
import { TodoList } from './TodoList';
import { TodoRepository } from './TodoRepository';
import { TodoRules } from './TodoRules';

export class CreateList {
  private repository: TodoRepository;

  constructor(repository: TodoRepository) {
    this.repository = repository;
  }

  execute(name: string): Result<TodoList> {
    const checked: Result<string> = TodoRules.checkListName(name);
    if (!checked.isOk) {
      return Result.failure<TodoList>(checked.error as ErrorCode);
    }
    return this.repository.createList(checked.value as string);
  }
}
