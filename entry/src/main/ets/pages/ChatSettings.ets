import { router } from '@kit.ArkUI'
import { UserInfo } from '../models/users';
import customToast from '../utils/CustomToast';
import { StoreClass } from '../utils/StoreClass';
import { emitter } from '@kit.BasicServicesKit';
import { JSON, util } from '@kit.ArkTS';

@Entry
@Component
struct ChatSettings {
  @State pendingUser: UserInfo = {} as UserInfo
  @State modelList: string[] = []
  newUserFlag: boolean = false
  select: number = 1

  updates() {
    if (this.pendingUser.user_id) {
      this.pendingUser = StoreClass.getUser(this.pendingUser.user_id)
    } else {
      this.newUserFlag = true
      this.pendingUser.avatar_url = StoreClass.getGlobalStr('avatarApiUrl') + `/${util.generateRandomUUID()}.svg`
      this.pendingUser.langModel = this.modelList[0]
      this.pendingUser.systemPrompt = '' // !!! 不然 undefined 因为 '{} as UserInfo'
    }
  }

  aboutToAppear() {
    this.pendingUser = router.getParams() as UserInfo
    let modelListStr = StoreClass.getGlobalStr('modelList')
    if (modelListStr) {
      this.modelList = modelListStr.split(',')
    } else {
      customToast('模型列表为空, 请检查设置')
    }
    this.updates()
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text('Character Settings')
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
        .height(50)
      }
      .padding({
        left: 10,
        right: 10
      })
      .backgroundColor($r('app.color.background_primary'))


      List() {
        ListItem() {
          Column() {
            Image(this.pendingUser.avatar_url)
              .width(200)
              .height(200)
            Text('角色头像')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))

            Row() {
              TextInput({
                text: this.pendingUser.avatar_url,
                placeholder: `头像url`
              })
                .placeholderColor($r('app.color.gray'))
                .fontColor($r('app.color.text_primary'))
                .textAlign(TextAlign.Start)
                .width('75%')
                .margin({
                  right: 15
                })
                .onChange((value: string) => {
                  this.pendingUser.avatar_url = value
                })
                
              Button('随机', { type: ButtonType.Capsule, stateEffect: true })
                .backgroundColor($r('app.color.primary'))
                .fontColor($r('app.color.black'))
                .onClick(() => {
                  this.pendingUser.avatar_url = StoreClass.getGlobalStr('avatarApiUrl') + `/${util.generateRandomUUID()}.svg`
                })
                
            }
            .alignSelf(ItemAlign.Start)

            Text('角色名字')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextInput({
              text: this.pendingUser.username,
              placeholder: '小V🏎️'
            })
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.pendingUser.username = value
              })
              

            Text('语言模型')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextPicker({ range: this.modelList, selected: this.modelList.indexOf(this.pendingUser.langModel) })
              .onChange((value: string | string[], index: number | number[]) => {
                this.pendingUser.langModel = value as string
              })
              // .backgroundColor($r('app.color.gray'))
              .width('100%')
              .height('20%')
              .defaultPickerItemHeight('80%')
              .disappearTextStyle({color: $r('app.color.gray'), font: {size: 10, weight: FontWeight.Lighter}})
              .textStyle({color: $r('app.color.gray'), font: {size: 15, weight: FontWeight.Normal}})
              .selectedTextStyle({color: $r('app.color.text_primary'), font: {size: 20, weight: FontWeight.Bolder}})
              .onClick(() => {
                customToast('完整名: ' + this.pendingUser.langModel)
              })


            Text('角色详情')
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .lineHeight(50)
              .fontColor($r('app.color.black'))
            TextArea({
              text: this.pendingUser.systemPrompt,
              placeholder: '你是蓝厂小V，喜欢蓝色，是Zeiss的朋友，回答问题很简练很清楚。'
            })
              .height(100)
              .placeholderColor($r('app.color.gray'))
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.pendingUser.systemPrompt = value
              })
              

            Button(this.newUserFlag ? '添加角色' : '保存修改', { type: ButtonType.Capsule, stateEffect: true })
              .margin(20)
              .width('85%')
              .backgroundColor($r('app.color.primary'))
              .onClick(() => {
                try {
                  // !!! textPicker onChange 才更新
                  // customToast('1' + this.pendingUser.langModel) -> 1undefined
                  if (this.pendingUser.username && this.pendingUser.systemPrompt && this.pendingUser.langModel) {
                    if (this.newUserFlag) {
                      StoreClass.addUser(this.pendingUser)
                      customToast('已添加')
                    } else {
                      StoreClass.modifyUser(this.pendingUser)
                      customToast('已保存')
                    }
                  }
                  else {
                      customToast('请检查留空部分')
                  }
                } catch (e) {
                  customToast('error encountered!')
                }
              })
              
          }
          .margin({
            left: 12,
            right: 12,
            bottom: 60
          })
          .padding({
            left: 18,
            right: 18
          })
        }
      }
      .height('100%')
      .width('100%')
      // .margin({bottom: 50})


    }
    .height('100%')
    .backgroundColor($r("app.color.background_primary"))
  }
}

