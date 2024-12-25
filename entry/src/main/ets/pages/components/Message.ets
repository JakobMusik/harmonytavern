import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../models/message'
import { PopupItem } from '../../models/popup'
import { UserInfo } from '../../models/users'
import { FileOperate } from '../../utils/FileOperate'
import { StoreClass } from '../../utils/StoreClass'
import { emitter } from '@kit.BasicServicesKit'

@Component
struct Message {

  item: MessageInfoModel = new MessageInfoModel({} as MessageInfo)
  // 预览图片
  previewImage: () => void = () => {}
  // 删除消息
  delMessageCB: (id: string) => void = () => {}

  @State
  showPopup: boolean = false
  @State
  transferResult: string = ''
  @State
  rootInfo: UserInfo = {} as UserInfo
  @State
  popupList: PopupItem[] = [
    {
      title: '删除',
      icon: $r("app.media.delete_forever_24dp"),
      itemClick: () => {
        //   有资源也删了
        if(this.item.sourceFilePath){
            FileOperate.delFilePath(this.item.sourceFilePath)
        }
        //   删除的首选项
        StoreClass.removeChatMessage(this.item.chatOwnerId, this.item.id)
        //   删除UI列表
        this.delMessageCB(this.item.id)
      }
    }
  ]

  aboutToAppear(): void {
    this.rootInfo = JSON.parse(StoreClass.getGlobalStr('rootUser')) as UserInfo
    emitter.on(StoreClass.key, () => {
      this.rootInfo = JSON.parse(StoreClass.getGlobalStr('rootUser')) as UserInfo
    })
  }

  @Builder
  getContent() {
    GridRow({ columns: 1 }) {
      ForEach(this.popupList, (item: PopupItem) => {
        GridCol() {
          Column({ space: 1 }) {
            Image(item.icon)
              .width(25)
              .height(25)
              .margin({
                bottom: 5
              })
            Text(item.title)
              .fontColor($r('app.color.black'))
              .fontSize(14)
          }
          .margin({
            bottom: 6
          })
        }
        .onClick(() => {
          item.itemClick && item.itemClick()
        })
      })
    }
    .width(80)
    .padding(10)
  }

  // 文字消息
  @Builder
  getTextContent() {
    Text(this.item.messageContent)
      .backgroundColor(this.item.senderUserId ?
        (this.item.senderUserId === this.rootInfo.user_id ? $r("app.color.chat_primary") : $r('app.color.chat_secondary'))
        : $r('app.color.white'))
      .fontColor($r('app.color.text_primary'))
      .padding(10)
      .lineHeight(24)
      .margin({
        left: 10,
        right: 10
      })
      .borderRadius(4)
  }

  // 图片消息
  @Builder
  getImageContent() {
    Column(){
      Image("file://" + this.item.sourceFilePath)
        .margin(15)
    }
    .backgroundColor($r('app.color.chat_primary'))
    .width('60%')
    .margin({
      left:10,
      right:10
    })
    .onClick(() => {
      this.previewImage()
    })
  }


  build() {
    Row() {
      if (this.item.senderUserId && this.item.senderUserId !== this.rootInfo.user_id) {
        Image(StoreClass.getUser(this.item.senderUserId).avatar_url)
          // TODO feature: local avatars
          // || ("file://"+StoreClass.getUser(this.item.senderUserId).sourceAvatarPath))
          .width(50)
          .height(50)
          .layoutWeight(1)
          .borderRadius(6)
      }

      Row() {
        Column() {
          // 消息类型渲染
          if (this.item.messageType === MessageTypeEnum.TEXT) {
            this.getTextContent()
          } else if (this.item.messageType === MessageTypeEnum.IMAGE) {
            this.getImageContent()
          }
        }
        .bindPopup(this.showPopup, {
          builder: this.getContent(),
          popupColor: $r("app.color.special_background"),
          backgroundBlurStyle: BlurStyle.NONE,
          onStateChange: (event) => {
            // 手指点击其他位置进行关闭
            this.showPopup = event.isVisible
          }
        })
      }
      .layoutWeight(6)
      // .justifyContent(FlexAlign.Center)
      .justifyContent(this.item.senderUserId ?
        (this.item.senderUserId === this.rootInfo.user_id ? FlexAlign.End : FlexAlign.Start)
        : FlexAlign.Center)
      // Text().layoutWeight(this.item.senderUser === emptyUser.user_id ? 1 : 0)
      if (this.item.senderUserId === this.rootInfo.user_id) {
        Image(this.rootInfo.avatar_url)
          .width(50)
          .height(50)
          .layoutWeight(1)
          .borderRadius(6)
      }
    }
    .width('100%')
    .padding({
      left: 10,
      right: 10
    })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          this.showPopup = true
        })
    )
  }
}

export default Message