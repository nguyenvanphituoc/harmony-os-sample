@ComponentV2
export struct AppText {
  @Param @Require text: ResourceStr;
  @Param textSize: Resource = $r('app.float.fontBody');
  @Param color: Resource = $r('app.color.ink');
  @Param bold: boolean = false;

  build() {
    Text(this.text)
      .fontSize(this.textSize)
      .fontColor(this.color)
      .fontWeight(this.bold ? FontWeight.Bold : FontWeight.Normal)
  }
}
