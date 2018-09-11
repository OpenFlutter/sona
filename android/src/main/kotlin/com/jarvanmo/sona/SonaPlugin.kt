package com.jarvanmo.sona

import android.app.Service
import com.igexin.sdk.PushManager
import com.jarvanmo.sona.constants.ANDROID
import com.jarvanmo.sona.constants.PLATFORM
import com.jarvanmo.sona.constants.RESULT
import com.jarvanmo.sona.handler.RegisterHandler
import com.jarvanmo.sona.service.SonaPushService
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
            channel.setMethodCallHandler(SonaPlugin(registrar))

        }
    }

    private val registerHandler:RegisterHandler = RegisterHandler( registrar)

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        if (call.method == "register") {
            registerHandler.register(call, result)
        } else {
            result.notImplemented()
        }
    }


}
