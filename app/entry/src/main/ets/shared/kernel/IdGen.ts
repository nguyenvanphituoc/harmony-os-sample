export interface IdGen {
  next(prefix: string): string;
}

export class SequenceIdGen implements IdGen {
  private counter: number = 0;

  next(prefix: string): string {
    this.counter = this.counter + 1;
    return prefix + '-' + this.counter.toString();
  }
}
