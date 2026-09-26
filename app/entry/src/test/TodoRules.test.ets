import { describe, it, expect } from '@ohos/hypium';
import { ErrorCode, Result } from '../main/ets/features/todo/domain/Result';
import { TodoRules } from '../main/ets/features/todo/domain/TodoRules';

export default function todoRulesTest() {
  describe('TodoRules', () => {
    it('checkListName trims', 0, () => {
      const result: Result<string> = TodoRules.checkListName('  Trips  ');
      expect(result.isOk).assertTrue();
      expect(result.value as string).assertEqual('Trips');
    });
    it('checkListName rejects blank', 0, () => {
      const result: Result<string> = TodoRules.checkListName('   ');
      expect(result.isOk).assertFalse();
      expect(result.error === ErrorCode.LIST_NAME_EMPTY).assertTrue();
    });
    it('checkItemTitle rejects blank', 0, () => {
      const result: Result<string> = TodoRules.checkItemTitle('');
      expect(result.error === ErrorCode.ITEM_TITLE_EMPTY).assertTrue();
    });
  });
}
