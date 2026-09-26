import { ViewStatus } from '../kernel/ViewStatus';
import { AppText } from './AppText';

@Builder
function noBranch() {
}

@ComponentV2
export struct AsyncBoundary {
  @Param @Require status: ViewStatus;
  @BuilderParam ready: () => void = noBranch;
  @BuilderParam empty: () => void = noBranch;

  build() {
    Column() {
      if (this.status === ViewStatus.Ready) {
        this.ready()
      } else if (this.status === ViewStatus.Empty) {
        this.empty()
      } else if (this.status === ViewStatus.Error) {
        AppText({ text: $r('app.string.error_generic') })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
