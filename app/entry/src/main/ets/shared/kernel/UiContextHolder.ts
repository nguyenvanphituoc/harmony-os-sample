import { UIContext } from '@kit.ArkUI';

export class UiContextHolder {
  private static captured: UIContext | undefined = undefined;

  static capture(context: UIContext): void {
    UiContextHolder.captured = context;
  }

  static get(): UIContext | undefined {
    return UiContextHolder.captured;
  }
}
