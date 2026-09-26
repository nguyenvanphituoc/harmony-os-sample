import { ComponentContent, UIContext } from '@kit.ArkUI';
import { UiContextHolder } from '../../../../shared/kernel/UiContextHolder';
import { ConfirmDialog } from './ConfirmDialog';

export class ConfirmDialogArgs {
  message: Resource;
  onConfirm: () => void;
  onClose: () => void;

  constructor(message: Resource, onConfirm: () => void, onClose: () => void) {
    this.message = message;
    this.onConfirm = onConfirm;
    this.onClose = onClose;
  }
}

@Builder
function confirmDialogBuilder(args: ConfirmDialogArgs) {
  ConfirmDialog({ message: args.message, onConfirm: args.onConfirm, onClose: args.onClose })
}

export class ConfirmDialogHost {
  static show(message: Resource, onConfirm: () => void): void {
    const ui: UIContext | undefined = UiContextHolder.get();
    if (ui === undefined) {
      return;
    }
    const holder: ComponentContent<ConfirmDialogArgs>[] = [];
    const args: ConfirmDialogArgs = new ConfirmDialogArgs(message, onConfirm, (): void => {
      ui.getPromptAction().closeCustomDialog(holder[0]);
    });
    holder.push(new ComponentContent<ConfirmDialogArgs>(ui, wrapBuilder<[ConfirmDialogArgs]>(confirmDialogBuilder), args));
    ui.getPromptAction().openCustomDialog(holder[0], { alignment: DialogAlignment.Center });
  }
}
