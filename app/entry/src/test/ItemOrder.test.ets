import { describe, it, expect } from '@ohos/hypium';
import { TodoItem } from '../main/ets/features/todo/domain/TodoItem';
import { ItemOrder } from '../main/ets/features/todo/domain/ItemOrder';

function titles(items: TodoItem[]): string {
  return items.map((i: TodoItem): string => i.title).join(',');
}

export default function itemOrderTest() {
  describe('ItemOrder', () => {
    it('TS-05-01 done items come after every open item', 0, () => {
      const items: TodoItem[] = [
        new TodoItem('1', 'l', 'a', true, 30),
        new TodoItem('2', 'l', 'b', false, 10),
        new TodoItem('3', 'l', 'c', false, 20)
      ];
      expect(titles(ItemOrder.sort(items))).assertEqual('c,b,a');
    });
    it('TS-05-02 each group is newest-created first', 0, () => {
      const items: TodoItem[] = [
        new TodoItem('1', 'l', 'old-open', false, 1),
        new TodoItem('2', 'l', 'new-open', false, 5),
        new TodoItem('3', 'l', 'old-done', true, 2),
        new TodoItem('4', 'l', 'new-done', true, 6)
      ];
      expect(titles(ItemOrder.sort(items))).assertEqual('new-open,old-open,new-done,old-done');
    });
  });
}
