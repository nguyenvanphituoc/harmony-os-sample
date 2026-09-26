export class TodoList {
  readonly id: string;
  readonly name: string;
  readonly createdAt: number;

  constructor(id: string, name: string, createdAt: number) {
    this.id = id;
    this.name = name;
    this.createdAt = createdAt;
  }
}
