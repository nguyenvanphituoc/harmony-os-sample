import { NavPort } from '../../../../shared/kernel/NavPort';
import { ViewStatus } from '../../../../shared/kernel/ViewStatus';
import { TodoStore } from '../../domain/TodoStore';
import { TodoList } from '../../domain/TodoList';
import { TodoItem } from '../../domain/TodoItem';
import { ItemOrder } from '../../domain/ItemOrder';
import { ToggleItem } from '../../domain/ToggleItem';
import { AddItem } from '../../domain/AddItem';
import { ErrorCode, Result } from '../../domain/Result';

export interface ItemDeleteOpener {
  openDelete(itemId: string, title: string): void;
}

@ObservedV2
export class ListViewModel {
  private store: TodoStore;
  private nav: NavPort;
  private listId: string;
  private toggleItem: ToggleItem | undefined;
  private addItem: AddItem | undefined;
  private dialogs: ItemDeleteOpener | undefined;
  @Trace loaded: boolean = false;
  @Trace newTitle: string = '';
  @Trace hasTitleError: boolean = false;

  constructor(store: TodoStore, nav: NavPort, listId: string, toggleItem?: ToggleItem, addItem?: AddItem,
              dialogs?: ItemDeleteOpener) {
    this.store = store;
    this.nav = nav;
    this.listId = listId;
    this.toggleItem = toggleItem;
    this.addItem = addItem;
    this.dialogs = dialogs;
  }

  @Computed
  get title(): string {
    const found: TodoList | undefined = this.store.lists.find((l: TodoList): boolean => l.id === this.listId);
    return found === undefined ? '' : found.name;
  }

  @Computed
  get items(): TodoItem[] {
    return ItemOrder.sort(this.store.items.filter((i: TodoItem): boolean => i.listId === this.listId));
  }

  @Computed
  get status(): ViewStatus {
    if (!this.loaded) {
      return ViewStatus.Loading;
    }
    return this.items.length === 0 ? ViewStatus.Empty : ViewStatus.Ready;
  }

  load(): void {
    this.loaded = true;
  }

  onToggle(itemId: string): void {
    if (this.toggleItem !== undefined) {
      this.toggleItem.execute(itemId);
    }
  }

  onTitleChange(value: string): void {
    this.newTitle = value;
  }

  onAdd(): void {
    if (this.addItem === undefined) {
      return;
    }
    const result: Result<TodoItem> = this.addItem.execute(this.listId, this.newTitle);
    if (result.isOk) {
      this.newTitle = '';
      this.hasTitleError = false;
    } else {
      this.hasTitleError = result.error === ErrorCode.ITEM_TITLE_EMPTY;
    }
  }

  onDeleteItem(itemId: string): void {
    const found: TodoItem | undefined = this.store.items.find((i: TodoItem): boolean => i.id === itemId);
    if (found !== undefined && this.dialogs !== undefined) {
      this.dialogs.openDelete(itemId, found.title);
    }
  }

  onBack(): void {
    this.nav.pop();
  }
}
