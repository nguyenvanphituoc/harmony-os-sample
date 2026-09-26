import { RetroCard } from '../../../../shared/uikit/RetroCard';
import { ButtonVariant, RetroButton } from '../../../../shared/uikit/RetroButton';

@ComponentV2
export struct ConfirmDialog {
  @Param @Require message: Resource;
  @Event onConfirm: () => void = () => {
  };
  @Event onClose: () => void = () => {
  };

  build() {
    RetroCard() {
      Column({ space: 12 }) {
        Text(this.message)
          .id('confirm.message')
          .fontSize($r('app.float.fontBody'))
          .fontColor($r('app.color.ink'))
        Row({ space: 12 }) {
          RetroButton({
            label: $r('app.string.action_delete'),
            variant: ButtonVariant.Danger,
            testId: 'confirm.deleteButton',
            onTap: () => {
              this.onConfirm();
              this.onClose();
            }
          })
          RetroButton({
            label: $r('app.string.action_cancel'),
            testId: 'confirm.cancelButton',
            onTap: () => {
              this.onClose();
            }
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.spacingM'))
    }
  }
}
