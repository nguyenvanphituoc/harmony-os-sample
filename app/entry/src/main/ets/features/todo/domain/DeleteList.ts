import { Result } from './Result';
import { TodoRepository } from './TodoRepository';

export class DeleteList {
  private repository: TodoRepository;

  constructor(repository: TodoRepository) {
    this.repository = repository;
  }

  execute(listId: string): Result<void> {
    return this.repository.deleteList(listId);
  }
}
