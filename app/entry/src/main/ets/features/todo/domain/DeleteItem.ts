import { Result } from './Result';
import { TodoRepository } from './TodoRepository';

export class DeleteItem {
  private repository: TodoRepository;

  constructor(repository: TodoRepository) {
    this.repository = repository;
  }

  execute(itemId: string): Result<void> {
    return this.repository.deleteItem(itemId);
  }
}
