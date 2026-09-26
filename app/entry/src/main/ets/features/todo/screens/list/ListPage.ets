import { AppText } from '../../../../shared/uikit/AppText';
import { AsyncBoundary } from '../../../../shared/uikit/AsyncBoundary';
import { ButtonVariant, RetroButton } from '../../../../shared/uikit/RetroButton';
import { RetroField } from '../../../../shared/uikit/RetroField';
import { EmptyState } from '../../../../shared/uikit/EmptyState';
import { TodoItem } from '../../domain/TodoItem';
import { ItemCard } from './ItemCard';
import { ListViewModel } from './ListViewModel';

@ComponentV2
export struct ListPage {
  @Param @Require vm: ListViewModel;

  @Builder
  readyBuilder() {
    List({ space: 12 }) {
      Repeat<TodoItem>(this.vm.items)
        .each((r: RepeatItem<TodoItem>) => {
          ListItem() {
            ItemCard({
              item: r.item,
              onToggle: () => {
                this.vm.onToggle(r.item.id);
              },
              onDelete: () => {
                this.vm.onDeleteItem(r.item.id);
              }
            })
          }
        })
        .key((item: TodoItem, index: number): string => item.id + '|' + item.title + '|' + item.done)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  emptyBuilder() {
    EmptyState({
      message: $r('app.string.list_empty_title'),
      hint: $r('app.string.list_empty_hint'),
      testId: 'list.emptyInvite'
    })
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Row({ space: 12 }) {
          RetroButton({
            label: $r('app.string.icon_back'),
            variant: ButtonVariant.Icon,
            testId: 'list.backButton',
            onTap: () => {
              this.vm.onBack();
            }
          })
          Text(this.vm.title)
            .id('list.title')
            .fontSize($r('app.float.fontTitle'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink'))
            .layoutWeight(1)
        }
        .width('100%')
        Row({ space: 12 }) {
          RetroField({
            placeholderText: $r('app.string.item_new_placeholder'),
            value: this.vm.newTitle,
            testId: 'list.newItemField',
            onChange: (value: string) => {
              this.vm.onTitleChange(value);
            },
            onSubmit: () => {
              this.vm.onAdd();
            }
          })
            .layoutWeight(1)
          RetroButton({
            label: $r('app.string.action_add'),
            variant: ButtonVariant.Primary,
            testId: 'list.addButton',
            onTap: () => {
              this.vm.onAdd();
            }
          })
        }
        .width('100%')
        if (this.vm.hasTitleError) {
          Text($r('app.string.item_title_empty'))
            .id('list.newItemError')
            .fontSize($r('app.float.fontSmall'))
            .fontColor($r('app.color.danger'))
        }
        AsyncBoundary({
          status: this.vm.status,
          ready: () => {
            this.readyBuilder();
          },
          empty: () => {
            this.emptyBuilder();
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding($r('app.float.spacingM'))
      .backgroundColor($r('app.color.background'))
      .onAppear(() => {
        this.vm.load();
      })
    }
    .hideTitleBar(true)
  }
}
