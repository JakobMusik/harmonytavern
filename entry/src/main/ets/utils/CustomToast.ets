import Logger from "./Logger";
import { promptAction } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";


export default function customToast(str: string) {
  Logger.info('show file contents:' + str);
  try {
    promptAction.showToast({
      message: str,
      duration: 2000,
      bottom: '80vp',
      backgroundColor: $r('app.color.white'),
      textColor: $r('app.color.black'),
      backgroundBlurStyle: BlurStyle.NONE
    })
  } catch (error) {
    let message = (error as BusinessError).message;
    let code = (error as BusinessError).code;
    Logger.error(`showToast args error code is ${code}, message is ${message}`);
  }
}
