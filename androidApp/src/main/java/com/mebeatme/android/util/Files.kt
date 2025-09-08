package com.mebeatme.android.util

import java.io.File

object Files {
    fun atomicWrite(target: File, content: String) {
        val tmp = File(target.parentFile, target.name + ".tmp")
        tmp.writeText(content)
        if (target.exists()) target.delete()
        tmp.renameTo(target)
    }
}
