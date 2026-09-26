import { ButtonVariant, RetroButton } from '../../../../shared/uikit/RetroButton';
import { RetroCard } from '../../../../shared/uikit/RetroCard';
import { RetroCheck } from '../../../../shared/uikit/RetroCheck';
import { TodoItem } from '../../domain/TodoItem';

@ComponentV2
export struct ItemCard {
  @Param @Require item: TodoItem;
  @Event onToggle: () => void = () => {
  };
  @Event onDelete: () => void = () => {
  };

  build() {
    RetroCard({
      done: this.item.done,
      testId: 'list.itemCard'
    }) {
      Row({ space: 12 }) {
        Row({ space: 12 }) {
          RetroCheck({ checked: this.item.done })
          Text(this.item.title)
            .fontSize($r('app.float.fontBody'))
            .fontColor(this.item.done ? $r('app.color.inkMuted') : $r('app.color.ink'))
            .decoration({
              type: this.item.done ? TextDecorationType.LineThrough : TextDecorationType.None,
              color: $r('app.color.inkMuted')
            })
            .layoutWeight(1)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.onToggle();
        })
        RetroButton({
          label: $r('app.string.icon_delete'),
          variant: ButtonVariant.Icon,
          testId: 'list.deleteItemButton',
          onTap: () => {
            this.onDelete();
          }
        })
      }
      .id(this.item.done ? 'item.done' : 'item.open')
      .width('100%')
      .padding($r('app.float.spacingM'))
    }
  }
}
