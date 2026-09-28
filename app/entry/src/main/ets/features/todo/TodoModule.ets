import { NavPort } from '../../shared/kernel/NavPort';
import { Clock, SystemClock } from '../../shared/kernel/Clock';
import { SequenceIdGen } from '../../shared/kernel/IdGen';
import { InMemoryTodoRepository } from './domain/InMemoryTodoRepository';
import { TodoStore } from './domain/TodoStore';
import { CreateList } from './domain/CreateList';
import { RenameList } from './domain/RenameList';
import { ToggleItem } from './domain/ToggleItem';
import { AddItem } from './domain/AddItem';
import { DeleteList } from './domain/DeleteList';
import { DeleteItem } from './domain/DeleteItem';
import { ConfirmDialogHost } from './screens/confirm/ConfirmDialogHost';
import { ListNameForm } from './screens/listname/ListNameForm';
import { ListNameDialogHost } from './screens/listname/ListNameDialogHost';
import { ListNameOpener, ListsViewModel } from './screens/lists/ListsViewModel';
import { ListViewModel, ItemDeleteOpener } from './screens/list/ListViewModel';

class TodoListNameOpener implements ListNameOpener {
  private create: CreateList;
  private rename: RenameList;
  private remove: DeleteList;

  constructor(create: CreateList, rename: RenameList, remove: DeleteList) {
    this.create = create;
    this.rename = rename;
    this.remove = remove;
  }

  openDelete(listId: string, name: string, itemCount: number): void {
    ConfirmDialogHost.show($r('app.string.confirm_list_message', name, itemCount), (): void => {
      this.remove.execute(listId);
    });
  }

  openCreate(): void {
    ListNameDialogHost.show(new ListNameForm(this.create, this.rename, $r('app.string.list_name_new_title'), undefined, ''));
  }

  openRename(listId: string, currentName: string): void {
    ListNameDialogHost.show(new ListNameForm(this.create, this.rename, $r('app.string.list_name_rename_title'), listId, currentName));
  }
}

class TodoItemDeleteOpener implements ItemDeleteOpener {
  private remove: DeleteItem;

  constructor(remove: DeleteItem) {
    this.remove = remove;
  }

  openDelete(itemId: string, title: string): void {
    ConfirmDialogHost.show($r('app.string.confirm_item_message', title), (): void => {
      this.remove.execute(itemId);
    });
  }
}

export class TodoModule {
  readonly store: TodoStore;
  readonly repository: InMemoryTodoRepository;
  private nav: NavPort;
  private lists: ListsViewModel;

  constructor(nav: NavPort) {
    this.nav = nav;
    this.store = new TodoStore();
    this.repository = new InMemoryTodoRepository(this.store, new SystemClock(), new SequenceIdGen());
    this.repository.seed();
    this.lists = new ListsViewModel(this.store, nav,
      new TodoListNameOpener(new CreateList(this.repository), new RenameList(this.repository),
        new DeleteList(this.repository)));
  }

  listsViewModel(): ListsViewModel {
    return this.lists;
  }

  listViewModel(listId: string, clock?: Clock): ListViewModel {
    return new ListViewModel(this.store, this.nav, listId, new ToggleItem(this.repository, this.store),
      new AddItem(this.repository), new TodoItemDeleteOpener(new DeleteItem(this.repository)),
      clock === undefined ? new SystemClock() : clock);
  }
}
