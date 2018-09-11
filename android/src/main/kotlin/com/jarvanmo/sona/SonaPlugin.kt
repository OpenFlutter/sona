package com.jarvanmo.sona

import com.igexin.sdk.PushManager
import com.jarvanmo.sona.handler.ReceiverHandler
import com.jarvanmo.sona.handler.RegisterHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class SonaPlugin(private val registrar: Registrar) : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "com.jarvanmo/sona")
            ReceiverHandler.methodChannel = channel
            channel.setMethodCallHandler(SonaPlugin(registrar))
        }
    }

    private val registerHandler: RegisterHandler = RegisterHandler(registrar)

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when {
            call.method == "register" -> registerHandler.register(call, result)
            "clientID" == call.method -> {
                val clientID = PushManager.getInstance().getClientid(registrar.context().applicationContext)
                result.success(clientID)
            }
            else -> result.notImplemented()
        }
    }


}
