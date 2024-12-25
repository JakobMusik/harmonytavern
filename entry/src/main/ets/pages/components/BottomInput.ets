import { rootUser, UserInfo } from '../../models/users'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../models/message'
import { PopupItem } from '../../models/popup'
import { fileIo, picker } from '@kit.CoreFileKit'
import { buffer, util } from '@kit.ArkTS';


@Component
struct BottomInput {
  @State
  showVoice: boolean = false
  @State
  content: string = ''

  screenWidth: number = 0
  screenHeight: number = 0

  // 发送文字消息
  sendTextMessage: (content: string) => void = () => {}
  // 发送图片消息
  sendImageMessage: (messageList: MessageInfoModel) => void = () => {}
  @Prop
  chatOwner: UserInfo
  @State
  showLocation: boolean = false
  @State
  bottomList: PopupItem[] = [
    {
      icon: $r('app.media.photo_camera_24dp'),
      title: '照片',
      itemClick: () => {
        this.sendPicture()
      }
    }]
  @State
  showBottomCard: boolean = false // 显示底部
  @State
  currentAddress: string = ''
  @Provide
  transText: string = ''

  @Builder
  getBottomCard(item: PopupItem) {
    Column() {
      Column() {
        Image(item.icon)
          .width(30)
          .height(30)
      }
      .backgroundColor($r('app.color.white'))
      .width(56)
      .aspectRatio(1)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(item.title)
        .fontSize(12)
        .fontColor($r("app.color.text_primary"))
        .margin({
          top: 10
        })
        
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      item.itemClick && item.itemClick()
    })
  }

  // 发送图片
  async sendPicture() {
    let uri: string = '';
    let docPicker = new picker.DocumentViewPicker()
    docPicker.select().then(async (documentSelectResult: string[]) => {
      uri = documentSelectResult[0];
      if (uri.length) {
        // 拷贝到沙箱
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
        let newFileName = getContext().filesDir + '/' + Date.now()
        fileIo.copyFileSync(file.fd, newFileName)

        // 转换为Base64 string
        let data = new ArrayBuffer(fileIo.statSync(file.fd).size)
        fileIo.readSync(file.fd, data)
        let buf: buffer.Buffer = buffer.from(data);
        let base64 = 'data:image/jpg;base64,' + buf.toString('base64', 0, buf.length);

        const newMessage = new MessageInfoModel({
          chatOwnerId: this.chatOwner.user_id,
          senderUserId: rootUser.user_id,
          receiverUserId: this.chatOwner.user_id,
          messageContent: base64,
          messageType: MessageTypeEnum.IMAGE,
          sourceFilePath: newFileName
        } as MessageInfo)
        fileIo.closeSync(file.fd)

        this.sendImageMessage(newMessage)
        this.showBottomCard = false
      }

      // return res;
    })
    //
    // const result = await documentViewPicker.select({
    //   maxSelectNumber: 1,
    //   MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
    // })

  }

  build() {
    Column() {
      Row({ space: 10 }) {
        TextInput({ text: $$this.content })
          .height(35)
          .layoutWeight(1)
          .borderRadius(2)
          .backgroundColor($r('app.color.white'))
          .fontColor($r('app.color.text_primary'))
          .onSubmit(() => {
            this.sendTextMessage(this.content)
            this.content = ''
          })
          .onClick(() => {
            animateTo({ duration: 150 }, () => {
              this.showBottomCard = false
            })
          })
          

        Image(this.showBottomCard ? $r('app.media.remove_24dp') : $r('app.media.add_24dp'))
          .width(25)
          .aspectRatio(1)
          .onClick(() => {
            animateTo({ duration: 150 }, () => {
              this.showBottomCard = !this.showBottomCard
            })
          })
      }
      .width('100%')
      .height(60)
      .padding({
        left: 10,
        right: 10
      })

      if (this.showBottomCard) {
        // 底部结构
        GridRow({ columns: 1 }) {
          ForEach(this.bottomList, (item: PopupItem) => {
            GridCol() {
              this.getBottomCard(item)
            }
            .height(100)
          })
        }
        .width('100%')

      }
    }
    .backgroundColor($r("app.color.light_gray"))
  }
}


export default BottomInput