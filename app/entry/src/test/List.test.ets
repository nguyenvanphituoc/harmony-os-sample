import localUnitTest from './LocalUnit.test';
import todoRulesTest from './TodoRules.test';
import itemOrderTest from './ItemOrder.test';
import inMemoryTodoRepositoryTest from './InMemoryTodoRepository.test';
import createListTest from './CreateList.test';
import renameListTest from './RenameList.test';
import toggleItemTest from './ToggleItem.test';
import addItemTest from './AddItem.test';
import deleteListTest from './DeleteList.test';
import deleteItemTest from './DeleteItem.test';

export default function testsuite() {
  localUnitTest();
  todoRulesTest();
  itemOrderTest();
  inMemoryTodoRepositoryTest();
  createListTest();
  renameListTest();
  toggleItemTest();
  addItemTest();
  deleteListTest();
  deleteItemTest();
}
