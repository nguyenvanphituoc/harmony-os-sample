@ComponentV2
export struct RetroCheck {
  @Param checked: boolean = false;

  build() {
    Stack() {
      if (this.checked) {
        Text($r('app.string.icon_check'))
          .fontSize($r('app.float.fontBody'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink'))
      }
    }
    .width($r('app.float.checkSize'))
    .height($r('app.float.checkSize'))
    .backgroundColor(this.checked ? $r('app.color.brand') : $r('app.color.surface'))
    .border({ width: $r('app.float.borderWidth'), color: $r('app.color.ink'), radius: $r('app.float.radius') })
  }
}
