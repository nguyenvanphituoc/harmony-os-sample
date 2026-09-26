import { TodoList } from './TodoList';
import { TodoItem } from './TodoItem';
import { TodoStoreState } from './TodoRepository';

@ObservedV2
export class TodoStore implements TodoStoreState {
  @Trace lists: TodoList[] = [];
  @Trace items: TodoItem[] = [];
}
