import { TodoItem } from './TodoItem';

export class ItemOrder {
  static sort(items: TodoItem[]): TodoItem[] {
    const copy: TodoItem[] = items.slice();
    copy.sort((a: TodoItem, b: TodoItem): number => {
      if (a.done !== b.done) {
        return a.done ? 1 : -1;
      }
      return b.createdAt - a.createdAt;
    });
    return copy;
  }
}
