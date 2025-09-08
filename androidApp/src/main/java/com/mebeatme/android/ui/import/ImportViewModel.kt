package com.mebeatme.android.ui.import

import android.content.ContentResolver
import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mebeatme.android.data.import.FileImportCoordinator
import com.mebeatme.android.data.persistence.RunStore
import com.mebeatme.android.domain.AnalysisService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ImportViewModel(
    private val coordinator: FileImportCoordinator,
    private val analysis: AnalysisService,
    private val store: RunStore
) : ViewModel() {
    private val _importing = MutableStateFlow(false)
    val importing: StateFlow<Boolean> = _importing

    fun onPickGpx(uri: Uri, resolver: ContentResolver) {
        viewModelScope.launch {
            _importing.value = true
            val run = coordinator.import(uri, resolver)
            val (analyzed, _) = analysis.analyze(run)
            store.save(analyzed)
            _importing.value = false
        }
    }
}
