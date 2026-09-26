import { AppText } from '../../../../shared/uikit/AppText';
import { AsyncBoundary } from '../../../../shared/uikit/AsyncBoundary';
import { EmptyState } from '../../../../shared/uikit/EmptyState';
import { ButtonVariant, RetroButton } from '../../../../shared/uikit/RetroButton';
import { RetroCard } from '../../../../shared/uikit/RetroCard';
import { ListCard, ListsViewModel } from './ListsViewModel';

@ComponentV2
export struct ListsPage {
  @Param @Require vm: ListsViewModel;

  @Builder
  cardBuilder(card: ListCard) {
    RetroCard({ testId: 'lists.card' }) {
      Row({ space: 8 }) {
        Column({ space: 4 }) {
          AppText({ text: card.name, textSize: $r('app.float.fontTitle'), bold: true })
          if (card.total === 0) {
            AppText({ text: $r('app.string.progress_none'), color: $r('app.color.inkMuted') })
          } else {
            AppText({ text: $r('app.string.progress_done', card.done, card.total), color: $r('app.color.inkMuted') })
          }
        }
        .id('lists.card.open')
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick(() => {
          this.vm.onOpen(card.id);
        })
        RetroButton({
          label: $r('app.string.icon_rename'),
          variant: ButtonVariant.Icon,
          testId: 'lists.renameButton',
          onTap: () => {
            this.vm.onRename(card.id);
          }
        })
        RetroButton({
          label: $r('app.string.icon_delete'),
          variant: ButtonVariant.Icon,
          testId: 'lists.deleteButton',
          onTap: () => {
            this.vm.onDelete(card.id);
          }
        })
      }
      .width('100%')
      .padding($r('app.float.spacingM'))
    }
  }

  @Builder
  readyBuilder() {
    Column({ space: 12 }) {
      this.newButtonBuilder()
      List({ space: 12 }) {
        Repeat<ListCard>(this.vm.cards)
          .each((r: RepeatItem<ListCard>) => {
            ListItem() {
              this.cardBuilder(r.item)
            }
          })
          .key((card: ListCard, index: number): string => card.id + '|' + card.name + '|' + card.done + '|' + card.total)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  newButtonBuilder() {
    RetroButton({
      label: $r('app.string.lists_new_action'),
      variant: ButtonVariant.Primary,
      testId: 'lists.newButton',
      onTap: () => {
        this.vm.onNew();
      }
    })
  }

  @Builder
  emptyBuilder() {
    EmptyState({
      message: $r('app.string.lists_empty_title'),
      actionLabel: $r('app.string.lists_empty_action'),
      actionTestId: 'lists.emptyInvite',
      onAction: () => {
        this.vm.onNew();
      }
    })
  }

  build() {
    Column({ space: 16 }) {
      AppText({ text: $r('app.string.lists_title'), textSize: $r('app.float.fontTitle'), bold: true })
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
    .alignItems(HorizontalAlign.Start)
    .onAppear(() => {
      this.vm.load();
    })
  }
}
