export interface NavPort {
  push(name: string, param: string): void;
  pop(): void;
}
