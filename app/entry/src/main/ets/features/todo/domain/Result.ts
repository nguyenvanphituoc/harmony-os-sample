export enum ErrorCode {
  LIST_NAME_EMPTY = 'LIST_NAME_EMPTY',
  ITEM_TITLE_EMPTY = 'ITEM_TITLE_EMPTY',
  LIST_NOT_FOUND = 'LIST_NOT_FOUND',
  ITEM_NOT_FOUND = 'ITEM_NOT_FOUND'
}

export class Result<T> {
  readonly isOk: boolean;
  readonly value: T | null;
  readonly error: ErrorCode | null;

  private constructor(isOk: boolean, value: T | null, error: ErrorCode | null) {
    this.isOk = isOk;
    this.value = value;
    this.error = error;
  }

  static success<V>(value: V): Result<V> {
    return new Result<V>(true, value, null);
  }

  static failure<V>(error: ErrorCode): Result<V> {
    return new Result<V>(false, null, error);
  }
}
