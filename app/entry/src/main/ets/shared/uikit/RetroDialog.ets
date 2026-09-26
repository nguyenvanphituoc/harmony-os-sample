import { AppText } from './AppText';
import { RetroCard } from './RetroCard';

@ComponentV2
export struct RetroDialog {
  @Param @Require title: ResourceStr;
  @BuilderParam content: () => void = noDialogContent;

  build() {
    RetroCard() {
      Column({ space: 12 }) {
        AppText({ text: this.title, textSize: $r('app.float.fontTitle'), bold: true })
        this.content()
      }
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.spacingM'))
    }
  }
}

@Builder
function noDialogContent() {
}
