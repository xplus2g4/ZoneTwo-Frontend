package com.orbital.zonetwo.ui.dashboard

import android.annotation.SuppressLint
import android.graphics.Color
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintSet.Motion
import androidx.core.net.toUri
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.orbital.zonetwo.databinding.FragmentDashboardBinding
import kotlinx.coroutines.launch
import okhttp3.Call
import okhttp3.Callback
import java.io.File
import java.io.IOException
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import kotlin.math.abs

val client = OkHttpClient()

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
//        val dashboardViewModel = ViewModelProvider(this).get(DashboardViewModel::class.java)

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
                            255.coerceAtMost((uiState.adjustedBPM - 125) * 3),
                            0.coerceAtLeast(200 - abs(155 - uiState.adjustedBPM) * 2),
                            255.coerceAtMost((230 - uiState.adjustedBPM) * 3)
                        )
                    )
                    binding.getBPMButton.setOnTouchListener {_, e ->
                        when (e.action) {
                            MotionEvent.ACTION_DOWN -> {
                                Log.d("ZoneTwo", "Mouse Down")
                                Log.d("ZoneTwo", String.format("http://116.15.28.198/get_music?json_data=\"{\"url\":\"%s\"}", getUrl()))
                                val request = Request.Builder()
                                    .url(String.format("http://116.15.28.198/get_music?json_data={\"url\":\"%s\"}", getUrl()))
                                    .build()

                                client.newCall(request).enqueue(object : Callback {
                                    override fun onFailure(call: Call, e: IOException) {
                                        e.printStackTrace()
                                    }

                                    override fun onResponse(call: Call, response: Response) {
                                        binding.textDashboard.text = response.body?.toString()
                                        Log.d("hello", "world")
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
                                mediaPlayer?.playbackParams?.setSpeed(uiState.adjustedBPM * 1.0f / uiState.currentSongBPM!!)
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

    fun audioTest() {

        val externalStorage = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        Log.d("Files", "Path: " + externalStorage.absolutePath)
        val f: File = File(externalStorage.absolutePath)
        val file = f.listFiles()
        Log.d("Files", "Size: " + file.size)
        for (i in file.indices) {
            Log.d("Files", "FileName:" + file[i].name)
        }


        val mp3 = File(externalStorage.absolutePath, "The Pretender.mp3")
        mediaPlayer = MediaPlayer.create(activity, mp3.toUri())
        mediaPlayer?.setOnPreparedListener { mediaPlayer?.start() }


    }

//    private fun handleGetBPM(event: MotionEvent) {
//        when (event.action) {
//            MotionEvent.ACTION_DOWN -> {
//                Log.d("ZoneTwo", "Mouse Down")
//                Log.d("ZoneTwo", String.format("http://116.15.28.198/get_music?json_data=\"{\"url\":\"%s\"}", getUrl()))
//                val request = Request.Builder()
//                    .url(String.format("http://116.15.28.198/get_music?json_data={\"url\":\"%s\"}", getUrl()))
//                    .build()
//
//                client.newCall(request).enqueue(object : Callback {
//                    override fun onFailure(call: Call, e: IOException) {
//                        e.printStackTrace()
//                    }
//
//                    override fun onResponse(call: Call, response: Response) {
//                        binding.textDashboard.text = response.body?.toString()
//                        Log.d("hello", "world")
//                    }
//                })
//
//            }
//        }
//    }
}