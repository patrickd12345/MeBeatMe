package com.mebeatme.android.ui.settings

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class SettingsViewModel : ViewModel() {
    private val _windowSec = MutableStateFlow(60 * 60 * 24 * 7 * 8)
    val windowSec: StateFlow<Int> = _windowSec
}
