import { preferences } from '@kit.ArkData'
import { MessageInfo, MessageInfoModel, ApiMessageModel} from '../models/message'
import { rootUser, UserInfo, DefaultUserList } from '../models/users'
import { emitter } from '@kit.BasicServicesKit'
import { initConstants } from './InitConstants'
import { util } from '@kit.ArkTS'
import customToast from './CustomToast'

export class StoreClass {
  static context: Context
  static key: string = 'CHAT'

  // 初始化
  static async init(context: Context) {
    StoreClass.context = context
    const global = StoreClass.getGlobalStore()
    let flag = global.hasSync('FirstTimeDone')
    if (!flag) {
      // initialize variables
      global.putSync('idCount', initConstants.idCount)
      global.putSync('avatarApiUrl', initConstants.avatarApiUrl)
      global.putSync('apiKey', initConstants.apiKey)
      global.putSync('apiUrl', initConstants.apiUrl)
      global.putSync('rootUser', JSON.stringify(rootUser))


      // initialize default characters
      DefaultUserList.forEach(user => {
        user.avatar_url = initConstants.avatarApiUrl + `/${util.generateRandomUUID()}.svg`
        user.langModel = 'chatgpt-4o-latest'
        StoreClass.addUser(user)
      });
      global.putSync('FirstTimeDone', true)
    }
    // // initialize model lists
    // global.putSync('ModelList', requestModels())

    await global.flush()
    emitter.emit(StoreClass.key)
  }

  static getGlobalStr(key: string) {
    return StoreClass.getGlobalStore().getSync(key, '') as string
  }

  static async modifyGlobalStr(key: string, val: string) {
    const global = StoreClass.getGlobalStore()
    global.putSync(key, val)
    await global.flush()
    emitter.emit(StoreClass.key)
  }


  // n+2个storage: n个CHAT_userId: userId的所有聊天记录, 1个CHAT: 全局变量, 1个CHAT_UserList: UserList
  static getUserStore(userId: string) {
    return preferences.getPreferencesSync(StoreClass.context, { name: `${StoreClass.key}_${userId}` })
  }

  static getGlobalStore() {
    return preferences.getPreferencesSync(StoreClass.context, { name: `${StoreClass.key}` })
  }

  static getUserListStore() {
    return preferences.getPreferencesSync(StoreClass.context, { name: `${StoreClass.key}_UserList` })
  }

  static async addUser(user: UserInfo) {
    const userList = StoreClass.getUserListStore()
    const global = StoreClass.getGlobalStore()
    user.user_id = global.getSync('idCount', undefined) as string

    global.putSync('idCount', (parseInt(user.user_id) + 1).toString())
    //  !!!
    userList.putSync(user.user_id, JSON.stringify(user))

    await userList.flush()
    await global.flush()
    //   线程通信：发布者
    emitter.emit(StoreClass.key)
  }

  static async modifyUser(user: UserInfo) {
    const userList = StoreClass.getUserListStore()
    userList.putSync(user.user_id, JSON.stringify(user))

    await userList.flush()
    emitter.emit(StoreClass.key)
  }

  static async removeUser(userId: string) {
    const userList = StoreClass.getUserListStore()
    userList.deleteSync(userId)
    await userList.flush()
    emitter.emit(StoreClass.key)
  }

  static getUser(userId: string): UserInfo {
    const userList = StoreClass.getUserListStore()
    return JSON.parse(userList.getSync(userId, '') as string) as UserInfo
  }

  static getUsersList() {
    const userList = StoreClass.getUserListStore()
    const all = userList.getAllSync()
    if (all) {
      const list = Object.values(all).map((item: string) => {
        return JSON.parse(item) as UserInfo
      })
      // list.sort((a, b) => {
      //   return parseInt(a.user_id) - parseInt(b.user_id)
      // })
      return list
    }
    return []
  }

  //   添加某个人的一条记录
  static async addChatMessage(message: MessageInfoModel) {
    const store = StoreClass.getUserStore(message.chatOwnerId)
    store.putSync(message.id, JSON.stringify(message))
    await store.flush()
    //   线程通信：发布者
    emitter.emit(StoreClass.key)
  }

  //   获取某个人的所有记录
  static getChatMessage(userId: string) {
    const userStore = StoreClass.getUserStore(userId)
    const all = userStore.getAllSync()
    if (all) {
      const list = Object.values(all).map((item: string) => {
        return JSON.parse(item) as MessageInfoModel
      })
      list.sort((a, b) => {
        return a.sendTime - b.sendTime
      })
      return list
    }
    return [new MessageInfoModel({} as MessageInfo)]
  }

  //   删除某个人的一条记录
  static async removeChatMessage(userId: string, messageId: string) {
    const userStore = StoreClass.getUserStore(userId)
    userStore.deleteSync(messageId)
    await userStore.flush()
    //   线程通信：发布者
    emitter.emit(StoreClass.key)
  }

  //   删除某个角色
  static removeChat(userId: string) {
    preferences.deletePreferences(StoreClass.context, { name: `${StoreClass.key}_${userId}` })
    StoreClass.removeUser(userId)
    //   线程通信：发布者
    emitter.emit(StoreClass.key)
  }

  //   获取某个人的最后一条记录
  static getChatLastMessage(userId: string): MessageInfoModel {
    const chatList = StoreClass.getChatMessage(userId)
    if (chatList.length) {
      return chatList[chatList.length-1]
    }
    return new MessageInfoModel({sendTime: 1} as MessageInfo)
  }

}