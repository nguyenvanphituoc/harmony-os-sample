@ComponentV2
export struct RetroField {
  @Param placeholderText: ResourceStr = '';
  @Param value: string = '';
  @Param errorText: ResourceStr | undefined = undefined;
  @Param testId: string = '';
  @Event onChange: (value: string) => void = (value: string) => {
  };
  @Event onSubmit: () => void = () => {
  };

  build() {
    Column({ space: 4 }) {
      TextInput({ text: this.value, placeholder: this.placeholderText })
        .id(this.testId)
        .height($r('app.float.minTouch'))
        .fontSize($r('app.float.fontBody'))
        .fontColor($r('app.color.ink'))
        .backgroundColor($r('app.color.surface'))
        .border({ width: $r('app.float.borderWidth'), color: $r('app.color.ink'), radius: $r('app.float.radius') })
        .onChange((text: string) => {
          this.onChange(text);
        })
        .onSubmit(() => {
          this.onSubmit();
        })
      if (this.errorText !== undefined) {
        Text(this.errorText)
          .fontSize($r('app.float.fontSmall'))
          .fontColor($r('app.color.danger'))
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}
