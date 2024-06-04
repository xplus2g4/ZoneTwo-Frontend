package com.orbital.zonetwo.ui.dashboard

import android.annotation.SuppressLint
import android.graphics.Color
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore.Audio.Media
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.TextView
import androidx.core.net.toUri
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.media3.extractor.metadata.MetadataDecoder
import androidx.media3.extractor.metadata.id3.Id3Decoder
import com.orbital.zonetwo.databinding.FragmentDashboardBinding
import kotlinx.coroutines.launch
import okhttp3.Call
import okhttp3.Callback
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.io.File
import java.io.IOException
import java.util.concurrent.TimeUnit
import kotlin.math.abs


val client = OkHttpClient.Builder()
                .connectTimeout(100, TimeUnit.SECONDS)
                .writeTimeout(100, TimeUnit.SECONDS)
                .readTimeout(100, TimeUnit.SECONDS)
                .build()

class DashboardFragment : Fragment() {

    private var _binding: FragmentDashboardBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    private var mediaPlayer: MediaPlayer? = null

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View {

        _binding = FragmentDashboardBinding.inflate(inflater, container, false)
        val root: View = binding.root

//        val textView: TextView = binding.textDashboard
//        dashboardViewModel.text.observe(viewLifecycleOwner) {
//            textView.text = it
//        }

        val dashboardViewModel: DashboardViewModel by viewModels()
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                dashboardViewModel.uiState.collect { uiState ->
                    // Update UI elements
                    binding.adjustedBPMEditText.setText(uiState.adjustedBPM.toString(),
                                                        TextView.BufferType.EDITABLE)
                    binding.adjustedBPMEditText.setTextColor(
                        Color.rgb(
                            255.coerceAtMost((uiState.adjustedBPM - 120) * 3),
                            0.coerceAtLeast(200 - abs(155 - uiState.adjustedBPM) * 2),
                            255.coerceAtMost((240 - uiState.adjustedBPM) * 3)
                        )
                    )
                    binding.textDashboard.text = uiState.currentSongBPM?.toString()
                    binding.getBPMButton.setOnTouchListener {_, e ->
                        when (e.action) {
                            MotionEvent.ACTION_DOWN -> {
                                Log.d("ZoneTwo", "Mouse Down")
                                Log.d("ZoneTwo", String.format("http://zonetwo-backend-env-ms1.eba-5cybfzhj.ap-southeast-2.elasticbeanstalk.com/api/musics/download?json_data={\"url\":\"%s\"}", getUrl()))
                                val request = Request.Builder()
                                    .url(String.format("http://zonetwo-backend-env-ms1.eba-5cybfzhj.ap-southeast-2.elasticbeanstalk.com/api/musics/download?json_data={\"url\":\"%s\"}", getUrl()))
                                    .build()

                                client.newCall(request).enqueue(object : Callback {
                                    override fun onFailure(call: Call, e: IOException) {
                                        e.printStackTrace()
                                    }

                                    override fun onResponse(call: Call, response: Response) {
                                        response.body?.let {
//                                            dashboardViewModel.setResponse(it.string())
                                            val bytes = it.bytes()
                                            val currentBPM = audioTest(bytes)
                                            dashboardViewModel.setCurrentSongBPM(currentBPM)
                                            //Log.d("response", it.string())
                                        }
                                    }
                                })

                            }
                        }
                        true
                    }
                    binding.incrementBPMButton.setOnTouchListener { _, e ->
                        when (e.action) {
                            MotionEvent.ACTION_DOWN -> {
                                dashboardViewModel.incrementBPM()
                            }
                        }
                        true
                    }
                    binding.decrementBPMButton.setOnTouchListener { _, e ->
                        when (e.action) {
                            MotionEvent.ACTION_DOWN -> {
                                dashboardViewModel.decrementBPM()
                            }
                        }
                        true
                    }
                    binding.adjustBPMButton.setOnTouchListener { _, e ->
                        when (e.action) {
                            MotionEvent.ACTION_DOWN -> {
                                Log.d("ZoneTwo", (uiState.adjustedBPM * 1.0f / uiState.currentSongBPM!!).toString())
                                mediaPlayer?.playbackParams
                                    ?.let { mediaPlayer?.setPlaybackParams(it.setSpeed(uiState.adjustedBPM * 1.0f / uiState.currentSongBPM)) }
                            }
                        }
                        true
                    }
                }
            }
        }

        val urlEditTextView: EditText = binding.urlEditText

//      audioTest()

        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    fun getUrl(): String? {
        return binding.urlEditText.text?.toString()
    }

    fun audioTest(bytes: ByteArray): Int {

        val externalStorage = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
//        Log.d("Files", "Path: " + externalStorage.absolutePath)
//        val f: File = File(externalStorage.absolutePath)
//        val file = f.listFiles()
//        Log.d("Files", "Size: " + file.size)
//        for (i in file.indices) {
//            Log.d("Files", "FileName:" + file[i].name)
//        }

//        val mmr = MediaMetadataRetriever()
//        mmr.set
        val temp = File(externalStorage.absolutePath, "test.mp3")
        if (temp.exists()) temp.delete()
        val mp3 = File(externalStorage.absolutePath, "test.mp3")
        mp3.writeBytes(bytes)

        val sb = StringBuilder()
        sb.append(Char(bytes[21].toInt()).toString())
        if (bytes[22].toInt() in 48..57) sb.append(Char(bytes[22].toInt()).toString())
        if (bytes[23].toInt() in 48..57) sb.append(Char(bytes[23].toInt()).toString())

        Log.d("BPM",  Char(bytes[21].toInt()).toString() + Char(bytes[22].toInt()).toString() + Char(bytes[23].toInt()).toString())
        Log.d("BPM",  bytes[21].toInt().toString() + "," + bytes[22].toInt().toString() + "," + bytes[23].toInt().toString())
//        mmr.setDataSource(mp3.path)
//        for (i in -100..100) {
//            Log.d("Metadata", mmr.extractMetadata(i).toString())
//        }
        mediaPlayer = MediaPlayer.create(activity, mp3.toUri())
        mediaPlayer?.setOnPreparedListener { mediaPlayer?.start() }

        return sb.toString().toInt()

    }
}