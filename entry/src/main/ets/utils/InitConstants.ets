export interface InitConstants {
  idCount: string
  avatarApiUrl: string
  apiKey: string
  apiUrl: string
}

export const initConstants = {
  idCount: '0',
  avatarApiUrl: 'https://api.multiavatar.com',
  // apiKey: string = 'sk-proj-xxxxxopenaixxxxx'
  apiKey: '',
  apiUrl: 'https://api.openai.com/v1'
  // apiUrl: 'http://172.25.198.227:8080/api'
} as InitConstants

// export default new initConstants();
