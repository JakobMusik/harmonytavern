import { TabBarClass } from '../models/tab'
import Settings from './Settings'
import Chats from './Chats'

@Entry
@Component
struct Index {
  @State
  tabList: TabBarClass[] = [{
    icon: $r('app.media.mark_unread_chat_alt_24dp'),
    name: 'chats',
    title: 'Chats',
    selectIcon: $r('app.media.mark_unread_chat_alt_24dp_fill')
  }, {
    icon: $r('app.media.settings_24dp'),
    name: 'settings',
    title: 'Settings',
    selectIcon: $r('app.media.settings_24dp_fill')
  }]
  @State
  currentIndex: number = 0

  @Builder
  CommonTabBar(item: TabBarClass) {
    Column() {
      Image(this.tabList[this.currentIndex].name === item.name ? item.selectIcon : item.icon)
        .width(30)
        .height(30)
      Text(item.title)
        .fontSize(12)
        .fontColor(item.name === this.tabList[this.currentIndex].name ?
          $r('app.color.text_primary') : $r("app.color.text_secondary"))
        .margin({
          top: 2
        })
    }
  }


  build() {
    Tabs({ index: $$this.currentIndex }) {
      ForEach(this.tabList, (item: TabBarClass) => {
        TabContent() {
          if (item.name === 'chats') {
            Chats()
          }
          else if (item.name === 'settings') {
            Settings()
          }
        }.tabBar(this.CommonTabBar(item))

      }, (item: TabBarClass) => item.name)
    }
    .barPosition(BarPosition.End)
    .animationDuration(300)
    .barBackgroundColor($r('app.color.light_gray'))
    //.onChange((index: number) => { this.currentIndex = index })
  }
}