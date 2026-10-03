package com.android.trinhngocminh

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import top.yukonga.miuix.kmp.basic.Button
import top.yukonga.miuix.kmp.basic.Card
import top.yukonga.miuix.kmp.basic.Scaffold
import top.yukonga.miuix.kmp.basic.SmallTitle
import top.yukonga.miuix.kmp.basic.SmallTopAppBar
import top.yukonga.miuix.kmp.basic.Text
import top.yukonga.miuix.kmp.overlay.OverlayDialog
import top.yukonga.miuix.kmp.preference.ArrowPreference
import top.yukonga.miuix.kmp.preference.RadioButtonPreference
import top.yukonga.miuix.kmp.theme.ColorSchemeMode
import top.yukonga.miuix.kmp.theme.MiuixTheme
import top.yukonga.miuix.kmp.theme.ThemeController

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val controller = remember { ThemeController(ColorSchemeMode.System) }
            MiuixTheme(controller = controller) { Home() }
        }
    }

    @Composable
    private fun Home() {
        var info by remember { mutableStateOf<DeviceInfo?>(null) }
        var fontDialog by remember { mutableStateOf(false) }
        var thermalDialog by remember { mutableStateOf(false) }
        var message by remember { mutableStateOf("") }
        var selectedThermal by remember { mutableStateOf(ThermalManager.selected(this)) }

        suspend fun refresh() {
            info = withContext(Dispatchers.IO) { SystemInfo.read(this@MainActivity) }
        }
        LaunchedEffect(Unit) { refresh() }

        val fontPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
            if (uri != null) {
                Thread {
                    val result = FontManager.apply(this@MainActivity, uri)
                    runOnUiThread {
                        message = result
                        fontDialog = false
                    }
                }.start()
            }
        }

        Scaffold(topBar = { SmallTopAppBar(title = "TNM") }) { padding ->
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(
                    start = 12.dp,
                    end = 12.dp,
                    top = padding.calculateTopPadding() + 8.dp,
                    bottom = 24.dp,
                ),
            ) {
                item {
                    SmallTitle("Tùy chỉnh")
                    Card(modifier = Modifier.fillMaxWidth()) {
                        ArrowPreference(
                            title = "Font",
                            summary = "Đổi font hệ thống hoặc khôi phục font trước đó",
                            onClick = { fontDialog = true },
                            holdDownState = fontDialog,
                        )
                        ArrowPreference(
                            title = "Thermal",
                            summary = if (selectedThermal == "eco") "Eco" else "Stock Xiaomi",
                            onClick = { thermalDialog = true },
                            holdDownState = thermalDialog,
                        )
                    }
                }

                item {
                    Spacer(Modifier.height(12.dp))
                    SmallTitle("Thông tin hệ thống")
                    Card(modifier = Modifier.fillMaxWidth()) {
                        InfoRow("Thiết bị", info?.device ?: "Đang đọc…")
                        InfoRow("SoC", info?.soc ?: "—")
                        InfoRow("CPU", info?.cpu ?: "—")
                        InfoRow("RAM", info?.ram ?: "—")
                        InfoRow("Bộ nhớ", info?.storage ?: "—")
                        InfoRow("Hệ điều hành", info?.android ?: "—")
                        InfoRow("HyperOS", info?.hyperos ?: "—")
                        InfoRow("Nhiệt pin", info?.batteryTemp ?: "—")
                        InfoRow("Nhiệt SoC / CPU", info?.socTemp ?: "—")
                        InfoRow("Nhiệt GPU", info?.gpuTemp ?: "—")
                        InfoRow("Thermal hiện tại", info?.thermal ?: "—")
                        InfoRow("Root", info?.root ?: "—")
                    }
                }

                item {
                    Spacer(Modifier.height(12.dp))
                    Button(
                        onClick = {
                            Thread {
                                val current = SystemInfo.read(this@MainActivity)
                                runOnUiThread { info = current }
                            }.start()
                        },
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Làm mới thông tin")
                    }
                    if (message.isNotBlank()) {
                        Spacer(Modifier.height(10.dp))
                        Text(message, modifier = Modifier.padding(horizontal = 8.dp))
                    }
                }
            }

            OverlayDialog(
                title = "Font",
                summary = "Chọn file .ttf hoặc .otf trên máy. TNM không nhúng font vào APK.",
                show = fontDialog,
                onDismissRequest = { fontDialog = false },
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Button(
                        onClick = {
                            fontPicker.launch(arrayOf("font/ttf", "font/otf", "application/octet-stream"))
                        },
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Chọn file font")
                    }
                    Button(
                        onClick = {
                            Thread {
                                val result = FontManager.restore()
                                runOnUiThread {
                                    message = result
                                    fontDialog = false
                                }
                            }.start()
                        },
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Khôi phục font")
                    }
                }
            }

            OverlayDialog(
                title = "Thermal",
                summary = "Chuyển runtime giữa thermal stock Xiaomi và Eco TNM.",
                show = thermalDialog,
                onDismissRequest = { thermalDialog = false },
            ) {
                Card {
                    RadioButtonPreference(
                        title = "Eco",
                        summary = "Ưu tiên pin và nhiệt độ nhưng vẫn giữ các bảo vệ thermal stock",
                        selected = selectedThermal == "eco",
                        onClick = {
                            Thread {
                                val result = ThermalManager.applyEco(this@MainActivity)
                                runOnUiThread {
                                    message = result
                                    if (result.startsWith("Đã bật")) selectedThermal = "eco"
                                    thermalDialog = false
                                }
                            }.start()
                        },
                    )
                    RadioButtonPreference(
                        title = "Stock Xiaomi",
                        summary = "Bỏ profile Eco và trở về thermal nguyên bản",
                        selected = selectedThermal == "stock",
                        onClick = {
                            Thread {
                                val result = ThermalManager.applyStock(this@MainActivity)
                                runOnUiThread {
                                    message = result
                                    if (result.startsWith("Đã khôi phục")) selectedThermal = "stock"
                                    thermalDialog = false
                                }
                            }.start()
                        },
                    )
                }
            }
        }
    }

    @Composable
    private fun InfoRow(title: String, value: String) {
        ArrowPreference(
            title = title,
            summary = value,
            enabled = false,
            onClick = null,
        )
    }
}
