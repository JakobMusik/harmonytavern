import { UserInfo } from "../models/users"
import { StoreClass } from "../utils/StoreClass"
import { InitConstants } from "../utils/InitConstants"
import customToast from "../utils/CustomToast"
import { emitter } from "@kit.BasicServicesKit"
import { util } from "@kit.ArkTS"
import { requestModels } from "../utils/ApiHelper"


@Component
struct Settings {

  @State consts: InitConstants = {
    avatarApiUrl: StoreClass.getGlobalStr('avatarApiUrl'),
    apiKey: StoreClass.getGlobalStr('apiKey'),
    apiUrl: StoreClass.getGlobalStr('apiUrl')
  } as InitConstants

  @State pendingUser: UserInfo = {} as UserInfo

  aboutToAppear(): void {
    this.pendingUser = JSON.parse(StoreClass.getGlobalStr('rootUser')) as UserInfo
    emitter.on(StoreClass.key, () => {
      this.pendingUser = JSON.parse(StoreClass.getGlobalStr('rootUser')) as UserInfo
    })
  }

  async updateModelList() {
    let modelList: string[] = await requestModels()

    StoreClass.modifyGlobalStr('modelList', modelList.join(','))
    customToast('已更新模型列表!')
  }

  build() {
    Column() {
      // 顶部
      Row () {
        Row({ space: 10 }) {
          Image(this.pendingUser.avatar_url)
            .width(60)
            .height(60)
            .borderRadius(6)
          Column({ space: 10 }) {
            Text(this.pendingUser.username)
              .fontSize(18)
              .fontColor($r("app.color.text_primary"))
              
          }.alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(30)
      .width('100%')
      .backgroundColor($r("app.color.background_secondary"))
      // Row().height(10)

      List() {
        ListItem() {
          Column() {
            Text('修改名字')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.pendingUser.username,
              placeholder: 'Zoomer123'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.pendingUser.username = value
              })

            Text('修改头像')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.pendingUser.avatar_url ?
                this.pendingUser.avatar_url : StoreClass.getGlobalStr('avatarApiUrl') + `/${util.generateRandomUUID()}.svg`,
              placeholder: '(avatarApiUrl)'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.pendingUser.avatar_url = value
              })

            Text('头像API')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.consts.avatarApiUrl,
              placeholder: 'image.com/api?'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.consts.avatarApiUrl = value
              })

            Text('模型推断API (类openai均可)')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.consts.apiUrl,
              placeholder: 'https://api.openai.com/v1 (or similar)'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.consts.apiUrl = value
              })

            Text('apiKey (Bearer)')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.consts.apiKey,
              placeholder: '(i.e. sk-xxxxx)'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.consts.apiKey = value
              })

          }
          .margin({
            left: 12,
            right: 12,
            bottom: 80
          })
          .padding({
            left: 18,
            right: 18
          })
        }
      }
      .height('75%')
      .width('100%')


      Button('保存并更新模型列表', { type: ButtonType.Capsule, stateEffect: true })
        .height('5%')
        .width('85%')
        .backgroundColor($r('app.color.primary'))
        .onClick(() => {
          try {
            StoreClass.modifyGlobalStr('rootUser', JSON.stringify(this.pendingUser))
            StoreClass.modifyGlobalStr('apiUrl', this.consts.apiUrl)
            StoreClass.modifyGlobalStr('apiKey', this.consts.apiKey)
            StoreClass.modifyGlobalStr('avatarApiUrl', this.consts.avatarApiUrl)
            this.updateModelList()
            customToast('已保存')
          } catch (e) {
            customToast('error encountered!')
          }

        })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))


  }
}

export default Settings