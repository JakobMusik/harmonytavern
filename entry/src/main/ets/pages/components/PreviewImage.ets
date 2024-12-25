
@CustomDialog
struct PreviewImage {
  controller: CustomDialogController
  url: ResourceStr = ''
  build() {
    Column(){
      Image(this.url)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.black'))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
        this.controller.close()
    })
  }
}
export default PreviewImage