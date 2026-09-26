import { NavPort } from '../../../../shared/kernel/NavPort';
import { ViewStatus } from '../../../../shared/kernel/ViewStatus';
import { TodoStore } from '../../domain/TodoStore';
import { TodoList } from '../../domain/TodoList';
import { TodoItem } from '../../domain/TodoItem';

export interface ListNameOpener {
  openCreate(): void;
  openRename(listId: string, currentName: string): void;
  openDelete(listId: string, name: string, itemCount: number): void;
}

export class ListCard {
  readonly id: string = '';
  readonly name: string = '';
  readonly done: number = 0;
  readonly total: number = 0;

  constructor(id: string, name: string, done: number, total: number) {
    this.id = id;
    this.name = name;
    this.done = done;
    this.total = total;
  }
}

@ObservedV2
export class ListsViewModel {
  private store: TodoStore;
  private nav: NavPort;
  private dialogs: ListNameOpener | undefined;
  @Trace loaded: boolean = false;

  constructor(store: TodoStore, nav: NavPort, dialogs: ListNameOpener | undefined = undefined) {
    this.store = store;
    this.nav = nav;
    this.dialogs = dialogs;
  }

  @Computed
  get cards(): ListCard[] {
    const sorted: TodoList[] = this.store.lists.slice().sort((a: TodoList, b: TodoList): number => b.createdAt - a.createdAt);
    return sorted.map((list: TodoList): ListCard => {
      const own: TodoItem[] = this.store.items.filter((item: TodoItem): boolean => item.listId === list.id);
      const done: number = own.filter((item: TodoItem): boolean => item.done).length;
      return new ListCard(list.id, list.name, done, own.length);
    });
  }

  @Computed
  get status(): ViewStatus {
    if (!this.loaded) {
      return ViewStatus.Loading;
    }
    return this.store.lists.length === 0 ? ViewStatus.Empty : ViewStatus.Ready;
  }

  load(): void {
    this.loaded = true;
  }

  onOpen(listId: string): void {
    this.nav.push('List', listId);
  }

  onNew(): void {
    if (this.dialogs !== undefined) {
      this.dialogs.openCreate();
    }
  }

  onRename(listId: string): void {
    const found: TodoList | undefined = this.store.lists.find((l: TodoList): boolean => l.id === listId);
    if (found !== undefined && this.dialogs !== undefined) {
      this.dialogs.openRename(listId, found.name);
    }
  }

  onDelete(listId: string): void {
    const found: TodoList | undefined = this.store.lists.find((l: TodoList): boolean => l.id === listId);
    if (found !== undefined && this.dialogs !== undefined) {
      const count: number = this.store.items.filter((i: TodoItem): boolean => i.listId === listId).length;
      this.dialogs.openDelete(listId, found.name, count);
    }
  }
}
