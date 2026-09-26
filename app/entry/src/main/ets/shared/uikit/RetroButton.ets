import { RetroCard } from './RetroCard';

export enum ButtonVariant {
  Primary,
  Danger,
  Plain,
  Icon
}

@ComponentV2
export struct RetroButton {
  @Param @Require label: ResourceStr;
  @Param variant: ButtonVariant = ButtonVariant.Plain;
  @Param testId: string = '';
  @Event onTap: () => void = () => {
  };

  private faceColor(): Resource {
    if (this.variant === ButtonVariant.Primary) {
      return $r('app.color.brand');
    }
    if (this.variant === ButtonVariant.Danger) {
      return $r('app.color.danger');
    }
    return $r('app.color.surface');
  }

  private labelColor(): Resource {
    return this.variant === ButtonVariant.Danger ? $r('app.color.onDanger') : $r('app.color.ink');
  }

  build() {
    RetroCard({
      stretch: false,
      testId: this.testId,
      face: this.faceColor(),
      onTap: () => {
        this.onTap();
      }
    }) {
      Text(this.label)
        .fontSize($r('app.float.fontBody'))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.labelColor())
        .textAlign(TextAlign.Center)
        .constraintSize({ minWidth: $r('app.float.minTouch'), minHeight: $r('app.float.minTouch') })
        .padding({ left: $r('app.float.spacingS'), right: $r('app.float.spacingS') })
    }
  }
}
