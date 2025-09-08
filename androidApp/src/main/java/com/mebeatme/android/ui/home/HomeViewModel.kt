package com.mebeatme.android.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mebeatme.android.data.persistence.RunStore
import com.mebeatme.android.models.RunRecord
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class HomeViewModel(private val store: RunStore) : ViewModel() {
    private val _runs = MutableStateFlow<List<RunRecord>>(emptyList())
    val runs: StateFlow<List<RunRecord>> = _runs
    private val _highest = MutableStateFlow<Double?>(null)
    val highestPPILast90Days: StateFlow<Double?> = _highest

    fun load() {
        viewModelScope.launch {
            _runs.value = store.list(20)
            _highest.value = store.bests().highestPPILast90Days
        }
    }
}
