import { router } from '@kit.ArkUI'
import { ExtraData, MessageInfo, MessageInfoModel,
  MessageTypeEnum, ApiMessageModel} from '../models/message'
import { rootUser, UserInfo } from '../models/users'
import { requestMessage, getApiMessages, convert2ApiMsg } from '../utils/ApiHelper'
import { StoreClass } from '../utils/StoreClass'
import BottomInput from './components/BottomInput'
import Message from './components/Message'
import PreviewImage from './components/PreviewImage'

@Entry
@Component
struct ChatPage {
  @State
  chatOwner: UserInfo = {} as UserInfo
  @State
  messageList: MessageInfoModel[] = []
  @State
  apiMsgList: ApiMessageModel[] = []
  @State
  receiverTyping: boolean = false

  scroller: Scroller = new Scroller()

  // 记录要预览的图片
  previewType: MessageTypeEnum = MessageTypeEnum.IMAGE
  previewUrl: ResourceStr = ''
  previewController: CustomDialogController = new CustomDialogController({
    builder: PreviewImage({
      url: this.previewUrl
    }),
    autoCancel: false,
    customStyle: true
  })

  // 删除member list的消息 (非store)
  delMessage(messageId: string) {
    let index = this.messageList.findIndex(message => message.id === messageId)
    this.messageList.splice(index, 1)
    this.apiMsgList = getApiMessages(this.messageList)
  }

  updateLists(message: MessageInfoModel) {
    this.messageList.push(message)
    this.apiMsgList.push(convert2ApiMsg(message))
  }

  aboutToAppear(): void {
    this.chatOwner = router.getParams() as UserInfo
    this.messageList = StoreClass.getChatMessage(this.chatOwner.user_id)
    this.apiMsgList = getApiMessages(this.messageList)

    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 100)
  }

  // 发送文字消息
  async sendTextMessage(content: string) {
    const message = new MessageInfoModel({
      chatOwnerId: this.chatOwner.user_id,
      senderUserId: rootUser.user_id,
      receiverUserId: this.chatOwner.user_id,
      messageContent: content,
      messageType: MessageTypeEnum.TEXT
    } as MessageInfo)
    this.updateLists(message)
    await StoreClass.addChatMessage(message)
    this.scroller.scrollEdge(Edge.Bottom)
    this.startInference()
  }

  // 发送图片消息
  async sendImageMessage(message: MessageInfoModel) {
    this.updateLists(message)
    await StoreClass.addChatMessage(message)
    this.scroller.scrollEdge(Edge.Bottom)
    this.startInference()
  }

  // 同时发送文字和图片
  // async sendMessage(message: MessageInfoModel) {
  //   this.messageList.push(message)
  //   await StoreClass.addChatMessage(this.sender.user_id, message)
  //   this.scroller.scrollEdge(Edge.Bottom)
  //   StoreClass.getAllChatLastMessage()
  //   // this.sendMessage(message.messageContent)
  // }

  // 获取llm消息
  async startInference() {
    // 对方正在输入
    this.receiverTyping = true
    let extra_data = {} as ExtraData

    // TODO add context length limit
    extra_data = {
      model: this.chatOwner.langModel,
      messages: [
        {
          role: "system",
          content: [
            {
              type: "text",
              text: this.chatOwner.systemPrompt
            }
          ]
        },
        ...this.apiMsgList
      ]
    } as ExtraData

    const result = await requestMessage(extra_data)
    // const result = await requestMessage(content)

    const resultMessage = new MessageInfoModel({
      chatOwnerId: this.chatOwner.user_id,
      senderUserId: this.chatOwner.user_id,
      receiverUserId: rootUser.user_id,
      // messageContent: result.data.info.text
      messageType: MessageTypeEnum.TEXT, // 仅支持Text, for now...
      messageContent: result
    } as MessageInfo)

    this.updateLists(resultMessage)
    await StoreClass.addChatMessage(resultMessage)
    this.scroller.scrollEdge(Edge.Bottom)
    this.receiverTyping = false
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text(this.receiverTyping ? '对方正在输入' : this.chatOwner.username)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
          Image($r('app.media.arrow_back_ios_new_24dp'))
            .width(30)
            .height(30)
            .onClick(() => {
              router.back()
            })
        }
        .backgroundColor($r('app.color.background_primary'))

        .height(50)
      }

      //聊天内容
      List({ space: 20, scroller: this.scroller }) {
        ListItem().margin(1)
        ForEach(this.messageList, (item: MessageInfoModel) => {
          ListItem() {
            Message({
              item,
              delMessageCB: (id) => {
                this.delMessage(id)
              },
              previewImage: () => {
                this.previewUrl = 'file://' + item.sourceFilePath
                this.previewType = item.messageType
                this.previewController.open()
              }
            })
          }
        })
        ListItem().margin(1)
      }
      .layoutWeight(1)
      .height('100%')
      .width('100%')
      .backgroundColor($r("app.color.background_primary"))

      BottomInput({
        chatOwner: this.chatOwner,
        sendTextMessage: (content) => {
          this.sendTextMessage(content)
        },
        sendImageMessage: (message) => {
          this.sendImageMessage(message)
        }
      })
    }
    .width('100%')
    .height('100%')


  }
}