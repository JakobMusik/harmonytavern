// Common in-app interfaces
//消息类型
import { util } from '@kit.ArkTS'

export enum MessageTypeEnum {
  TEXT, //文本消息
  IMAGE //图片消息
}

//消息数据结构
export interface MessageInfo {
  id: string
  chatOwnerId: string
  senderUserId: string
  receiverUserId: string
  messageContent: string
  sendTime: number //发送时间戳
  messageType: MessageTypeEnum
  sourceFilePath: string //资源文件的沙箱地址，存储地址
}

export class MessageInfoModel implements MessageInfo {
  id: string = ''
  chatOwnerId: string = ''
  senderUserId: string = ''
  receiverUserId: string = ''
  messageContent: string = ''
  sendTime: number = 0
  messageType: MessageTypeEnum = MessageTypeEnum.TEXT
  sourceFilePath: string = ''

  constructor(model: MessageInfo) {
    this.id = model.id || util.generateRandomUUID() //生成随机id
    this.chatOwnerId = model.chatOwnerId
    this.senderUserId = model.senderUserId
    this.receiverUserId = model.receiverUserId
    this.messageContent = model.messageContent
    this.sendTime = model.sendTime || Date.now() //获取当前时间戳
    this.messageType = model.messageType || MessageTypeEnum.TEXT //默认文本
    this.sourceFilePath = model.sourceFilePath
  }

}

// API related interfaces
// Interface for extraData
export interface ExtraData {
  model: string;
  messages: ApiMessageModel[];
}
//
// type Message = SystemMessage | UserMessage;

// export interface SystemMessage {
//   role: "system";
//   content: string;
// }

export interface ApiMessageModel {
  role: string;
  content: ApiContentItem[];
}

export type ApiContentItem = ApiTextContent | ApiImageUrlContent;

export interface ApiTextContent {
  type: "text";
  text: string;
}

export interface ApiImageUrlContent {
  type: "image_url";
  image_url: ImageUrl;
}

interface ImageUrl {
  url: string;
}

export interface ApiRootModel {
  data: DataItem[];
}

interface DataItem {
  id: string;
  object: string;
  created: number;
  owned_by: string;
  name: string;
  openai: OpenAI;
  urlIdx: number;
  info: Info;
  actions: string[];
}

interface OpenAI {
  id: string;
  object: string;
  created: number;
  owned_by: string;
}

interface Info {
  id: string;
  user_id: string;
  base_model_id: string | null;
  name: string;
  params: Record<string, string>;
  meta: Meta;
  access_control: string | null;
  is_active: boolean;
  updated_at: number;
  created_at: number;
}

interface Meta {
  profile_image_url: string;
  description: string;
  capabilities: Capabilities;
  suggestion_prompts: string | null;
  tags: string[];
}

interface Capabilities {
  vision: boolean;
  citations: boolean;
}


// API response interfaces
// Define the entire response interface
export interface ChatCompletionResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: Choice[];
  usage: Usage;
  system_fingerprint: string;
}

// Define the Choice interface
interface Choice {
  index: number;
  message: ApiResponseMessage;
  logprobs: string; // Replace 'any' with a more specific type if available
  finish_reason: string;
}

// Define the Message interface
export interface ApiResponseMessage {
  role: string;
  content: string;
  refusal: string | null;
}

// Define the Usage interface
interface Usage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  prompt_tokens_details: PromptTokensDetails;
  completion_tokens_details: CompletionTokensDetails;
}

// Define the PromptTokensDetails interface
interface PromptTokensDetails {
  cached_tokens: number;
  audio_tokens: number;
}

// Define the CompletionTokensDetails interface
interface CompletionTokensDetails {
  reasoning_tokens: number;
  audio_tokens: number;
  accepted_prediction_tokens: number;
  rejected_prediction_tokens: number;
}