import { ErrorCode, Result } from './Result';

export class TodoRules {
  static checkListName(name: string): Result<string> {
    const trimmed: string = name.trim();
    if (trimmed.length === 0) {
      return Result.failure<string>(ErrorCode.LIST_NAME_EMPTY);
    }
    return Result.success<string>(trimmed);
  }

  static checkItemTitle(title: string): Result<string> {
    const trimmed: string = title.trim();
    if (trimmed.length === 0) {
      return Result.failure<string>(ErrorCode.ITEM_TITLE_EMPTY);
    }
    return Result.success<string>(trimmed);
  }
}
