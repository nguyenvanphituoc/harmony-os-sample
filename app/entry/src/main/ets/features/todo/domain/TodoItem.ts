export class TodoItem {
  readonly id: string;
  readonly listId: string;
  readonly title: string;
  readonly done: boolean;
  readonly createdAt: number;

  constructor(id: string, listId: string, title: string, done: boolean, createdAt: number) {
    this.id = id;
    this.listId = listId;
    this.title = title;
    this.done = done;
    this.createdAt = createdAt;
  }
}
