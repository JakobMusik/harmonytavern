import { MessageInfoModel } from '../models/message'
import { StoreClass } from '../utils/StoreClass'
import { BusinessError, emitter } from '@kit.BasicServicesKit'
import { promptAction, router } from '@kit.ArkUI'
import { FileOperate } from '../utils/FileOperate'
import { UserInfo } from '../models/users'

interface userListItem {
  lastMsg: MessageInfoModel,
  user: UserInfo
}

@Component
struct Chats {
  @State
  chatList: userListItem[] = []
  @State
  filterList: userListItem[] = []

  @State
  @Watch('filterName')
  searchName: string = ''

  updates() {
    let tempList = StoreClass.getUsersList()
    this.chatList = []
    tempList.forEach(item => {
      this.chatList.push({
        lastMsg: StoreClass.getChatLastMessage(item.user_id),
        user: item
      })
    })
    this.chatList.sort((a, b) => {
      if (a.lastMsg.sendTime === b.lastMsg.sendTime) {
        return parseInt(b.user.user_id) - parseInt(a.user.user_id)
      }
      return b.lastMsg.sendTime - a.lastMsg.sendTime
    })
    this.filterList = this.chatList
  }

  filterName() {
    this.filterList = this.chatList.filter((item: userListItem) => {
      return item.user.username.includes(this.searchName)
    })
  }

  aboutToAppear(): void {
    this.updates()
    emitter.on(StoreClass.key, () => {
      this.updates()
    })
  }

  @Builder
  getListEnd(userId: string) {
    Row() {
      Text('设置')
        .width(80)
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.white'))
        .backgroundColor($r('app.color.gray'))
        .height(40)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ChatSettings',
            params: StoreClass.getUser(userId)
          })
        })
      Text('删除')
        .width(80)
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.white'))
        .backgroundColor($r('app.color.red'))
        .height(40)
        .onClick(() => {
          try {
            promptAction.showDialog({
              title: '确认删除?',
              message: '删除后对应设置和聊天内容将被删除',
              buttons: [
                {
                  text: '确定',
                  color: $r('app.color.red')
                },
                {
                  text: '取消',
                  color: $r('app.color.black')
                }
              ],
            })
            .then(data => {
              console.info('showDialog success, click button: ' + data.index);
              if (data.index === 0) {
                // 删除首选项
                StoreClass.removeChat(userId)
                // 当前这个人的沙箱中的文件
                FileOperate.delUserPath(userId)
              }
            })
            .catch((err:Error) => {
              console.info('showDialog error: ' + err);
            })
          } catch (error) {
            let message = (error as BusinessError).message
            let code = (error as BusinessError).code
            console.error(`showDialog args error code is ${code}, message is ${message}`);
          }


        })
    }.height(70)
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r("app.color.special_background"))
  }

  transTime(time: number) {
    const dateobj = new Date(time)
    const year = dateobj.getFullYear()
    const month = dateobj.getMonth()
    const date = dateobj.getDate()
    const hours = dateobj.getHours()
    const minutes = dateobj.getMinutes()
    if (year === new Date().getFullYear()) {
      //今年
      if (month === new Date().getMonth()) {
        //这个月
        if (date === new Date().getDate()) {
          //当天
          return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`
        } else {
          return `${new Date().getDate() - date}天前`
        }
      } else {
        return `${month}月${date}日`
      }
    } else {
      return `${year}年${month}月${date}日`
    }
  }


  build() {
    Column() {
      Row() {
        Text(`Chat (${this.chatList.length})`)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
        Image($r('app.media.group_add_24dp'))
          .width(30)
          .height(30)
          .position({
            x: '100%'
          })
          .translate({
            x: -40,
            y: 15
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ChatSettings',
              params: {} as UserInfo
              // params: {
              //   val: emptyUser.user_id
              // }
            })
          })

      }.width('100%')
      .justifyContent(FlexAlign.Center)
      .height(50)

      Row() {
        Search({ placeholder: '搜索', value: $$this.searchName })
          .height(30)
          .fontColor($r('app.color.black'))
          .placeholderColor($r('app.color.black'))
          .backgroundColor($r('app.color.light_gray'))
          .borderRadius(4)
      }
      .width('100%')
      .padding({
        left: 10,
        right: 10
      })

      List() {
        ForEach(this.filterList, (item: userListItem) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.user.avatar_url)
                .width(50)
                .height(50)
                .borderRadius(4)

              Column({ space: 10 }) {
                Row() {
                  Text(item.user.username)
                    .fontColor($r('app.color.text_primary'))
                    .fontSize(16)
                  Text(this.transTime(item.lastMsg.sendTime))
                    .fontSize(12)
                    .fontColor($r("app.color.text_secondary"))
                    .margin({
                      top: 10
                    })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width('100%')

                Text(item.lastMsg.messageContent)
                  .fontColor($r("app.color.text_secondary"))
                  .fontSize(14)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .height(50)
              .layoutWeight(1)
              .padding({
                top: 3,
                bottom: 3
              })
            }
            .stateStyles({
              normal: {
                .backgroundColor($r('app.color.background_primary'))
              },
              pressed: {
                .backgroundColor($r("app.color.background_secondary"))
              }
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ChatPage',
                params: item.user
              })
            })
          }
          .padding({
            top: 10,
            bottom: 10
          })
          .swipeAction({
            end: () => {
              this.getListEnd(item.user.user_id)
            }
          })
        })
      }
      .height('85%')
      .width('100%')
      // .divider({
      //   strokeWidth: 1,
      //   color: $r('app.color.border_color')
      // })
      .padding({
        left: 10,
        right: 20
      })
    }
    .padding({
      top: 30
    })
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))

  }
}

export default Chats