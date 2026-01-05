package com.interviewbuddy.interview_buddy

import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "interview_buddy/tts"
    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    if (tts == null) {
                        pendingResult = result
                        tts = TextToSpeech(this, this)
                    } else {
                        result.success(isInitialized)
                    }
                }
                "speak" -> {
                    val text = call.argument<String>("text")
                    if (text != null && isInitialized) {
                        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tts_utterance")
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                "setSpeechRate" -> {
                    val rate = call.argument<Double>("rate")?.toFloat() ?: 1.0f
                    tts?.setSpeechRate(rate)
                    result.success(true)
                }
                "setPitch" -> {
                    val pitch = call.argument<Double>("pitch")?.toFloat() ?: 1.0f
                    tts?.setPitch(pitch)
                    result.success(true)
                }
                "shutdown" -> {
                    tts?.stop()
                    tts?.shutdown()
                    tts = null
                    isInitialized = false
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val result = tts?.setLanguage(Locale.US)
            isInitialized = result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED

            // Set default speech rate
            tts?.setSpeechRate(0.9f)

            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {}
                override fun onDone(utteranceId: String?) {}
                override fun onError(utteranceId: String?) {}
            })
        } else {
            isInitialized = false
        }

        pendingResult?.success(isInitialized)
        pendingResult = null
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
