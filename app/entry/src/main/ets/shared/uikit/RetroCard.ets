@ComponentV2
export struct RetroCard {
  @Param done: boolean = false;
  @Param stretch: boolean = true;
  @Param testId: string = '';
  @Param face: Resource | undefined = undefined;
  @Event onTap: () => void = () => {
  };
  @BuilderParam content: () => void = noContent;
  @Local faceWidth: number = 0;
  @Local faceHeight: number = 0;
  @Local pressed: boolean = false;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width(this.faceWidth)
          .height(this.faceHeight)
          .backgroundColor($r('app.color.ink'))
          .position({ x: $r('app.float.shadowOffset'), y: $r('app.float.shadowOffset') })
        Column() {
          this.content()
        }
        .id(this.testId)
        .width(this.stretch ? '100%' : 'auto')
        .backgroundColor(this.face !== undefined ? this.face : (this.done ? $r('app.color.surfaceDone') : $r('app.color.surface')))
        .border({ width: $r('app.float.borderWidth'), color: $r('app.color.ink'), radius: $r('app.float.radius') })
        .offset({
          x: this.pressed ? $r('app.float.shadowOffset') : 0,
          y: this.pressed ? $r('app.float.shadowOffset') : 0
        })
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          this.faceWidth = Number(newValue.width);
          this.faceHeight = Number(newValue.height);
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.pressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressed = false;
          }
        })
        .onClick(() => {
          this.onTap();
        })
      }
      .width(this.stretch ? '100%' : 'auto')
    }
    .width(this.stretch ? '100%' : 'auto')
    .padding({ right: $r('app.float.shadowOffset'), bottom: $r('app.float.shadowOffset') })
  }
}

@Builder
function noContent() {
}
