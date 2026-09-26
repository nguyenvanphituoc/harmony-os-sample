import { RetroCard } from '../../../../shared/uikit/RetroCard';
import { ButtonVariant, RetroButton } from '../../../../shared/uikit/RetroButton';
import { RetroField } from '../../../../shared/uikit/RetroField';
import { ListNameForm } from './ListNameForm';

@ComponentV2
export struct ListNameDialog {
  @Param @Require form: ListNameForm;
  @Event onClose: () => void = () => {
  };

  build() {
    RetroCard() {
      Column({ space: 12 }) {
        Text(this.form.title)
          .id('listName.title')
          .fontSize($r('app.float.fontTitle'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink'))
        RetroField({
          value: this.form.name,
          testId: 'listName.field',
          onChange: (value: string) => {
            this.form.onChange(value);
          },
          onSubmit: () => {
            if (this.form.submit()) {
              this.onClose();
            }
          }
        })
        if (this.form.hasError) {
          Text($r('app.string.list_name_empty'))
            .id('listName.error')
            .fontSize($r('app.float.fontSmall'))
            .fontColor($r('app.color.danger'))
        }
        Row({ space: 12 }) {
          RetroButton({
            label: $r('app.string.action_save'),
            variant: ButtonVariant.Primary,
            testId: 'listName.saveButton',
            onTap: () => {
              if (this.form.submit()) {
                this.onClose();
              }
            }
          })
          RetroButton({
            label: $r('app.string.action_cancel'),
            testId: 'listName.cancelButton',
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
