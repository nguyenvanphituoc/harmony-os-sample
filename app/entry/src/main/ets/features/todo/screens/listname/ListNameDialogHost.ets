import { ComponentContent, UIContext } from '@kit.ArkUI';
import { UiContextHolder } from '../../../../shared/kernel/UiContextHolder';
import { ListNameDialog } from './ListNameDialog';
import { ListNameForm } from './ListNameForm';

export class ListNameDialogArgs {
  form: ListNameForm;
  onClose: () => void;

  constructor(form: ListNameForm, onClose: () => void) {
    this.form = form;
    this.onClose = onClose;
  }
}

@Builder
function listNameDialogBuilder(args: ListNameDialogArgs) {
  ListNameDialog({ form: args.form, onClose: args.onClose })
}

export class ListNameDialogHost {
  static show(form: ListNameForm): void {
    const ui: UIContext | undefined = UiContextHolder.get();
    if (ui === undefined) {
      return;
    }
    const holder: ComponentContent<ListNameDialogArgs>[] = [];
    const args: ListNameDialogArgs = new ListNameDialogArgs(form, (): void => {
      ui.getPromptAction().closeCustomDialog(holder[0]);
    });
    holder.push(new ComponentContent<ListNameDialogArgs>(ui, wrapBuilder<[ListNameDialogArgs]>(listNameDialogBuilder), args));
    ui.getPromptAction().openCustomDialog(holder[0], { alignment: DialogAlignment.Center });
  }
}
