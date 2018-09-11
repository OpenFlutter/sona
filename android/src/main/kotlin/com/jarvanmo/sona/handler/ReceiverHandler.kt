package com.jarvanmo.sona.handler

import android.content.Context
import com.igexin.sdk.message.GTTransmitMessage
import com.jarvanmo.sona.constants.*
import io.flutter.plugin.common.MethodChannel

internal object ReceiverHandler {

    var methodChannel: MethodChannel? = null

    fun handleReceivedMessageData(msg: GTTransmitMessage) {

        val result = hashMapOf(
                APP_ID to msg.appid,
                MESSAGE_ID to msg.messageId,
                TASK_ID to msg.taskId,
                PKG_NAME to msg.pkgName,
                CLIENT_ID to msg.clientId
        )

        val payload = msg.payload
        if (payload != null) {
            result[PAYLOAD] = String(payload)
        }
        methodChannel?.invokeMethod("onReceiveMessageData", result)

    }


     fun onReceiveClientId(clientID: String) {
        methodChannel?.invokeMethod("onReceiveClientId",clientID)
    }

    fun  onReceiveOnlineState(isOnline:Boolean){
        methodChannel?.invokeMethod("onReceiveOnlineState",isOnline)
    }

}