import { AppText } from './AppText';
import { ButtonVariant, RetroButton } from './RetroButton';

@ComponentV2
export struct EmptyState {
  @Param @Require message: ResourceStr;
  @Param hint: ResourceStr | undefined = undefined;
  @Param actionLabel: ResourceStr | undefined = undefined;
  @Param testId: string = '';
  @Param actionTestId: string = '';
  @Event onAction: () => void = () => {
  };

  build() {
    Column({ space: 12 }) {
      AppText({ text: this.message, textSize: $r('app.float.fontTitle'), bold: true })
      if (this.hint !== undefined) {
        AppText({ text: this.hint, color: $r('app.color.inkMuted') })
      }
      if (this.actionLabel !== undefined) {
        RetroButton({
          label: this.actionLabel,
          variant: ButtonVariant.Primary,
          testId: this.actionTestId,
          onTap: () => {
            this.onAction();
          }
        })
      }
    }
    .id(this.testId)
    .width('100%')
    .padding($r('app.float.spacingL'))
  }
}
