package com.jarvanmo.sona.service

import android.content.Context
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import com.jarvanmo.sona.handler.ReceiverHandler

class SonaReceiverService : GTIntentService() {
    override fun onReceiveMessageData(p0: Context, p1: GTTransmitMessage) {
       ReceiverHandler.handleReceivedMessageData(p1)
    }

    override fun onNotificationMessageArrived(p0: Context, p1: GTNotificationMessage) {
       ReceiverHandler.onNotificationMessageArrived(p1)
    }

    override fun onReceiveServicePid(p0: Context, p1: Int) {
    }

    override fun onNotificationMessageClicked(p0: Context, p1: GTNotificationMessage) {
       ReceiverHandler.onNotificationMessageClicked(p1)
    }

    override fun onReceiveCommandResult(p0: Context, p1: GTCmdMessage?) {
    }

    override fun onReceiveClientId(p0: Context, p1: String) {
      ReceiverHandler.onReceiveClientId(p1)
    }

    override fun onReceiveOnlineState(p0: Context, p1: Boolean) {
      ReceiverHandler.onReceiveOnlineState(p1)
    }
}