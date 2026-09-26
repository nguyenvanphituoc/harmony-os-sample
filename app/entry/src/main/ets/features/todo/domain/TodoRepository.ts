import { Result } from './Result';
import { TodoList } from './TodoList';
import { TodoItem } from './TodoItem';

export interface TodoStoreState {
  lists: TodoList[];
  items: TodoItem[];
}

export interface TodoRepository {
  createList(name: string): Result<TodoList>;
  renameList(listId: string, name: string): Result<TodoList>;
  deleteList(listId: string): Result<void>;
  addItem(listId: string, title: string): Result<TodoItem>;
  setDone(itemId: string, done: boolean): Result<TodoItem>;
  deleteItem(itemId: string): Result<void>;
}
