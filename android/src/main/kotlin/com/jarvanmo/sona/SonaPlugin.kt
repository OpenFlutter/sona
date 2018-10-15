package com.jarvanmo.sona

import com.igexin.sdk.PushManager
import com.jarvanmo.sona.constants.ALIAS
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

            "turnOnPush" == call.method -> {
                val isOn:Boolean = call.arguments()
                if (isOn) {
                    PushManager.getInstance().turnOnPush(registrar.context().applicationContext)
                }else {
                    PushManager.getInstance().turnOffPush(registrar.context().applicationContext)
                }

                result.success(true)
            }


            "bindAlias" == call.method ->bindAlias(call,result)
            "unBindAlias"  == call.method -> unBindAlias(call,result)
            else -> result.notImplemented()
        }
    }

    private fun bindAlias(call: MethodCall, result: Result){
        val sn:String? = call.argument("sequenceNum")
        if(sn.isNullOrBlank()){
           val ok = PushManager.getInstance().bindAlias(registrar.context().applicationContext,call.argument(ALIAS))
            result.success(ok)
        }else{
            val ok =PushManager.getInstance().bindAlias(registrar.context().applicationContext,call.argument(ALIAS),sn)
            result.success(ok)
        }

    }

    private fun unBindAlias(call: MethodCall, result: Result){
        val context = registrar.context().applicationContext
        val alias = call.argument<String>(ALIAS)
        val sn:String? = call.argument("sequenceNum")
        if(sn.isNullOrBlank()) {
            val ok = PushManager.getInstance().unBindAlias(context,alias,call.argument<Boolean>("isSelf")?:false)
            result.success(ok)
        }else{
            val ok =  PushManager.getInstance().unBindAlias(context,alias,call.argument<Boolean>("isSelf")?:false,sn)
            result.success(ok)
        }
    }

}
