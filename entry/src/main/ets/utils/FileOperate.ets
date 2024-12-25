import { fileIo } from '@kit.CoreFileKit'

export class FileOperate {
  // 创建文件，返回文件路径
  static createAudioFile(userId: string) {
    let dirPath = getContext().filesDir + '/' + userId
    let flag = fileIo.accessSync(dirPath)
    if (!flag) {
      fileIo.mkdirSync(dirPath)
    }
    let filePath = dirPath + '/' + Date.now() + '.wav'
    const file = fileIo.openSync(filePath,fileIo.OpenMode.CREATE)
    fileIo.closeSync(file)
    return filePath
  }
  // 删除文件
  static delFilePath(filePath:string){
    if(filePath){
      fileIo.unlinkSync(filePath)
    }
  }
  // 删除目录
  static delUserPath(userId:string){
    if(userId){
      let dirPath = getContext().filesDir+'/'+userId
      let flag = fileIo.accessSync(dirPath)
      if(flag){
        fileIo.rmdirSync(dirPath)
      }
    }
  }
}