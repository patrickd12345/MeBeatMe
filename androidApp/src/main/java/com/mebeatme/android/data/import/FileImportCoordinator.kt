package com.mebeatme.android.data.import

import android.content.ContentResolver
import android.net.Uri
import com.mebeatme.android.data.import.parsers.GPXParser
import com.mebeatme.android.models.RunRecord

class FileImportCoordinator(
    private val gpxParser: GPXParser = GPXParser()
) {
    suspend fun import(uri: Uri, resolver: ContentResolver): RunRecord {
        val ext = uri.lastPathSegment?.substringAfterLast('.')?.lowercase()
        resolver.openInputStream(uri)?.use { input ->
            return when (ext) {
                "gpx" -> gpxParser.parse(input)
                else -> error("Unsupported file type: $ext")
            }
        }
        error("Unable to open input stream for $uri")
    }
}
