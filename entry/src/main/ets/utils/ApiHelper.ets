import { http } from '@kit.NetworkKit'
import { ChatCompletionResponse, ExtraData, ApiRootModel,
  MessageInfoModel, ApiContentItem,
  MessageTypeEnum, ApiMessageModel,
  ApiImageUrlContent, ApiTextContent} from '../models/message';
import { rootUser } from '../models/users';
import customToast from './CustomToast';
import { StoreClass } from './StoreClass';

const req = http.createHttp()

export async function requestMessage(extra_data: ExtraData) {
  let bearerAuth = StoreClass.getGlobalStr('apiKey')
  let url = StoreClass.getGlobalStr('apiUrl') + '/chat/completions'

  let options: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      "Authorization": 'Bearer ' + bearerAuth,
      'Content-Type': 'application/json'
    }
  }

  options.extraData = extra_data
  try{
    // customToast(JSON.stringify(options))
    const res = await req.request(url, options)
    const result = JSON.parse(res.result as string) as ChatCompletionResponse
    return result.choices[0].message.content
  }catch(error){
    return Promise.reject(error)
  }
}

export async function requestModels() {
  let bearerAuth = StoreClass.getGlobalStr('apiKey')
  let url = StoreClass.getGlobalStr('apiUrl') + '/models'
  let options: http.HttpRequestOptions = {
    method: http.RequestMethod.GET,
    header: {
      "Authorization": 'Bearer ' + bearerAuth,
      'Content-Type': 'application/json'
    }
  }

  try{
    const res = await req.request(url, options)

    // let result = JSON.parse(res.result as string) as string
    let result = JSON.parse(res.result as string) as ApiRootModel
    // item.id instead of item.name (1hr mistake lol)
    const modelNames: string[] = result.data.map((item) => item.id);
    return modelNames
  }catch(error){
    return Promise.reject(error)
  }
}

export function convert2ApiMsg(chatMessage: MessageInfoModel) {
  let con: ApiContentItem = {} as ApiContentItem
  if (chatMessage.messageType === MessageTypeEnum.TEXT) {
    con = {
      type: "text",
      text: chatMessage.messageContent
    } as ApiTextContent
  } else if (chatMessage.messageType === MessageTypeEnum.IMAGE) {
    con = {
      type: "image_url",
      image_url: {
        url: chatMessage.messageContent
      }
    } as ApiImageUrlContent
  }
  return {
    role: chatMessage.senderUserId === rootUser.user_id ? 'user' : 'assistant',
    content: [con]
  } as ApiMessageModel
}

export function getApiMessages(messageList: MessageInfoModel[]) {
  let apiMessages: ApiMessageModel[] = []
  messageList.forEach((item: MessageInfoModel) => {
    if (item.senderUserId) {
      let apiMsg = convert2ApiMsg(item)
      apiMessages.push(apiMsg)
    }
  });
  return apiMessages
}