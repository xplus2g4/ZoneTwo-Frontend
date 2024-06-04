package com.orbital.zonetwo.ui.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

data class DashboardUiState (
    val currentSongBPM: Int? = null,
    val adjustedBPM: Int = 155,
    val response: String? = null
)
class DashboardViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = ""
    }
    val text: LiveData<String> = _text

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    fun incrementBPM() {
        _uiState.update { it.copy(adjustedBPM = if (it.adjustedBPM < 240) it.adjustedBPM + 1
                                                else it.adjustedBPM) }
    }

    fun decrementBPM() {
        _uiState.update { it.copy(adjustedBPM = if (it.adjustedBPM > 120) it.adjustedBPM - 1
                                                else it.adjustedBPM) }
    }

    fun setCurrentSongBPM(bpm: Int) {
        var normalizedBPM = bpm
        while (normalizedBPM > 240) normalizedBPM /= 2
        while (normalizedBPM < 120) normalizedBPM *= 2
        _uiState.update { it.copy(currentSongBPM = normalizedBPM) }
    }

    fun setResponse(response: String) {
        _uiState.update { it.copy(response = response) }
    }

}