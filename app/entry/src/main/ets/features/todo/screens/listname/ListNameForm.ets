import { ErrorCode, Result } from '../../domain/Result';
import { TodoList } from '../../domain/TodoList';
import { CreateList } from '../../domain/CreateList';
import { RenameList } from '../../domain/RenameList';

@ObservedV2
export class ListNameForm {
  private create: CreateList;
  private rename: RenameList;
  readonly title: Resource;
  private listId: string | undefined;
  @Trace name: string;
  @Trace hasError: boolean = false;

  constructor(create: CreateList, rename: RenameList, title: Resource, listId: string | undefined, initial: string) {
    this.create = create;
    this.rename = rename;
    this.title = title;
    this.listId = listId;
    this.name = initial;
  }

  onChange(value: string): void {
    this.name = value;
  }

  submit(): boolean {
    const id: string | undefined = this.listId;
    const result: Result<TodoList> = id === undefined ? this.create.execute(this.name) : this.rename.execute(id, this.name);
    this.hasError = !result.isOk && result.error === ErrorCode.LIST_NAME_EMPTY;
    return result.isOk;
  }
}
