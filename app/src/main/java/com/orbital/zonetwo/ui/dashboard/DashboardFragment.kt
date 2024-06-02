package com.orbital.zonetwo.ui.dashboard

import android.media.MediaPlayer
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.net.toUri
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.orbital.zonetwo.databinding.FragmentDashboardBinding
import java.io.File


class DashboardFragment : Fragment() {

    private var _binding: FragmentDashboardBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    private var mediaPlayer: MediaPlayer? = null

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View {
        val dashboardViewModel =
                ViewModelProvider(this).get(DashboardViewModel::class.java)

        _binding = FragmentDashboardBinding.inflate(inflater, container, false)
        val root: View = binding.root

        val textView: TextView = binding.textDashboard
        dashboardViewModel.text.observe(viewLifecycleOwner) {
            textView.text = it
        }

        audioTest()

        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
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


        val mp3 = File(externalStorage.absolutePath, "tabako.mp3")
        mediaPlayer = MediaPlayer.create(activity, mp3.toUri())
        mediaPlayer?.setOnPreparedListener { mediaPlayer?.start() }

        binding.button.setOnTouchListener { _, e ->
            handleTouch(e)
            true
        }
    }

    private fun handleTouch(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                Log.d("ZoneTwo", "Mouse Down")
                mediaPlayer?.pause()
            }
        }
    }
}