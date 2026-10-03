package com.android.trinhngocminh

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import top.yukonga.miuix.kmp.basic.BasicComponent
import top.yukonga.miuix.kmp.basic.Button
import top.yukonga.miuix.kmp.basic.Card
import top.yukonga.miuix.kmp.basic.Icon
import top.yukonga.miuix.kmp.basic.IconButton
import top.yukonga.miuix.kmp.basic.MiuixScrollBehavior
import top.yukonga.miuix.kmp.basic.Scaffold
import top.yukonga.miuix.kmp.basic.SmallTitle
import top.yukonga.miuix.kmp.basic.Text
import top.yukonga.miuix.kmp.basic.TopAppBar
import top.yukonga.miuix.kmp.icon.MiuixIcons
import top.yukonga.miuix.kmp.icon.extended.Info
import top.yukonga.miuix.kmp.icon.extended.Lock
import top.yukonga.miuix.kmp.icon.extended.Refresh
import top.yukonga.miuix.kmp.icon.extended.Settings
import top.yukonga.miuix.kmp.icon.extended.Theme
import top.yukonga.miuix.kmp.icon.extended.Tune
import top.yukonga.miuix.kmp.overlay.OverlayDialog
import top.yukonga.miuix.kmp.preference.ArrowPreference
import top.yukonga.miuix.kmp.preference.RadioButtonPreference
import top.yukonga.miuix.kmp.theme.ColorSchemeMode
import top.yukonga.miuix.kmp.theme.MiuixTheme
import top.yukonga.miuix.kmp.theme.ThemeController

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val controller = remember { ThemeController(ColorSchemeMode.System) }
            MiuixTheme(controller = controller) { Home() }
        }
    }

    @Composable
    private fun Home() {
        var info by remember { mutableStateOf<DeviceInfo?>(null) }
        var integrity by remember { mutableStateOf<IntegrityDiagnostics?>(null) }
        var playIntegrity by remember { mutableStateOf("Chưa kiểm tra") }
        var checkingIntegrity by remember { mutableStateOf(false) }

        var fontDialog by remember { mutableStateOf(false) }
        var thermalDialog by remember { mutableStateOf(false) }
        var systemDialog by remember { mutableStateOf(false) }
        var integrityDialog by remember { mutableStateOf(false) }
        var message by remember { mutableStateOf("") }
        var lastThermalNotice by remember { mutableStateOf<String?>(null) }
        var selectedThermal by remember { mutableStateOf(ThermalManager.selected(this)) }
        var appVisible by remember {
            mutableStateOf(lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED))
        }

        val scope = rememberCoroutineScope()
        val listState = rememberLazyListState()
        val scrollBehavior = MiuixScrollBehavior()

        fun readStaticOnce() {
            scope.launch {
                val pair = withContext(Dispatchers.IO) {
                    SystemInfo.readStatic(this@MainActivity) to IntegrityChecker.local()
                }
                info = pair.first
                integrity = pair.second
            }
        }

        fun refreshRealtimeNow() {
            val current = info ?: return
            scope.launch {
                val next = withContext(Dispatchers.IO) {
                    SystemInfo.readRealtime(this@MainActivity, current)
                }
                info = next
                val notice = next.thermalNotice
                if (notice != null && notice != lastThermalNotice) {
                    message = notice
                    lastThermalNotice = notice
                } else if (notice == null) {
                    lastThermalNotice = null
                }
            }
        }

        DisposableEffect(Unit) {
            val observer = LifecycleEventObserver { _, _ ->
                appVisible = lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)
            }
            lifecycle.addObserver(observer)
            onDispose { lifecycle.removeObserver(observer) }
        }

        LaunchedEffect(Unit) {
            val pair = withContext(Dispatchers.IO) {
                SystemInfo.readStatic(this@MainActivity) to IntegrityChecker.local()
            }
            info = pair.first
            integrity = pair.second
        }

        LaunchedEffect(appVisible) {
            while (appVisible) {
                val current = info
                if (current != null) {
                    val next = withContext(Dispatchers.IO) {
                        SystemInfo.readRealtime(this@MainActivity, current)
                    }
                    info = next

                    val notice = next.thermalNotice
                    if (notice != null && notice != lastThermalNotice) {
                        message = notice
                        lastThermalNotice = notice
                    } else if (notice == null) {
                        lastThermalNotice = null
                    }
                }
                delay(1000)
            }
        }

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

        Scaffold(
            topBar = {
                TopAppBar(
                    title = "TNM",
                    largeTitle = "TNM",
                    subtitle = "HyperMOS Control",
                    scrollBehavior = scrollBehavior,
                    actions = {
                        IconButton(onClick = { readStaticOnce() }) {
                            Icon(
                                imageVector = MiuixIcons.Refresh,
                                contentDescription = "Đọc lại toàn bộ",
                                tint = MiuixTheme.colorScheme.onBackground,
                            )
                        }
                    },
                )
            },
        ) { padding ->
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .fillMaxSize()
                    .nestedScroll(scrollBehavior.nestedScrollConnection),
                contentPadding = PaddingValues(
                    top = padding.calculateTopPadding() + 4.dp,
                    bottom = 28.dp,
                ),
            ) {
                item(key = "hero") { DeviceHero(info) }

                item(key = "customTitle") { SmallTitle("Tùy chỉnh") }

                item(key = "custom") {
                    Card(
                        modifier = Modifier
                            .padding(horizontal = 12.dp)
                            .fillMaxWidth(),
                    ) {
                        ArrowPreference(
                            title = "Font",
                            summary = "Đổi font hệ thống",
                            startAction = {
                                FeatureIcon(MiuixIcons.Theme, Color(0xFF6C63FF))
                            },
                            onClick = { fontDialog = true },
                            holdDownState = fontDialog,
                        )
                        ArrowPreference(
                            title = "Thermal",
                            summary = info?.thermal ?: if (selectedThermal == "eco") "Eco" else "Stock Xiaomi",
                            startAction = {
                                FeatureIcon(MiuixIcons.Tune, Color(0xFFFF9500))
                            },
                            onClick = { thermalDialog = true },
                            holdDownState = thermalDialog,
                        )
                    }
                }

                if (message.isNotBlank()) {
                    item(key = "message") {
                        Spacer(Modifier.height(10.dp))
                        Card(
                            modifier = Modifier
                                .padding(horizontal = 12.dp)
                                .fillMaxWidth(),
                        ) {
                            BasicComponent(
                                title = "Trạng thái",
                                summary = message,
                                startAction = {
                                    FeatureIcon(MiuixIcons.Info, Color(0xFF34C759))
                                },
                            )
                        }
                    }
                }

                item(key = "systemTitle") { SmallTitle("Realtime") }

                item(key = "stats1") {
                    Row(
                        modifier = Modifier
                            .padding(horizontal = 12.dp)
                            .fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        StatCard(
                            modifier = Modifier.weight(1f),
                            title = "CPU",
                            value = info?.cpuCurrent ?: "—",
                            imageVector = MiuixIcons.Settings,
                            accent = Color(0xFF3482FF),
                        )
                        StatCard(
                            modifier = Modifier.weight(1f),
                            title = "RAM dùng",
                            value = info?.ram ?: "—",
                            imageVector = MiuixIcons.Info,
                            accent = Color(0xFF34C759),
                        )
                    }
                }

                item(key = "stats2") {
                    Spacer(Modifier.height(10.dp))
                    Row(
                        modifier = Modifier
                            .padding(horizontal = 12.dp)
                            .fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        StatCard(
                            modifier = Modifier.weight(1f),
                            title = "Nhiệt SoC",
                            value = info?.socTemp ?: "—",
                            imageVector = MiuixIcons.Tune,
                            accent = Color(0xFFFF3B30),
                        )
                        StatCard(
                            modifier = Modifier.weight(1f),
                            title = "Nhiệt pin",
                            value = info?.batteryTemp ?: "—",
                            imageVector = MiuixIcons.Settings,
                            accent = Color(0xFFFF9500),
                        )
                    }
                }

                item(key = "detailsTitle") { SmallTitle("Thiết bị") }

                item(key = "details") {
                    Card(
                        modifier = Modifier
                            .padding(horizontal = 12.dp)
                            .fillMaxWidth(),
                    ) {
                        ArrowPreference(
                            title = "Thông tin hệ thống",
                            summary = "${info?.storage ?: "—"} · ${info?.soc ?: "—"}",
                            startAction = {
                                FeatureIcon(MiuixIcons.Info, Color(0xFF5AC8FA))
                            },
                            onClick = { systemDialog = true },
                            holdDownState = systemDialog,
                        )
                        ArrowPreference(
                            title = "Integrity",
                            summary = integrity?.summary ?: "Đang kiểm tra…",
                            startAction = {
                                FeatureIcon(MiuixIcons.Lock, Color(0xFFAF52DE))
                            },
                            onClick = { integrityDialog = true },
                            holdDownState = integrityDialog,
                        )
                    }
                }
            }

            OverlayDialog(
                title = "Font",
                summary = "Chọn font trên máy hoặc khôi phục font trước đó.",
                show = fontDialog,
                onDismissRequest = { fontDialog = false },
            ) {
                Card {
                    BasicComponent(
                        title = "Chọn file font",
                        summary = ".ttf hoặc .otf",
                        startAction = { FeatureIcon(MiuixIcons.Theme, Color(0xFF6C63FF)) },
                        onClick = {
                            fontPicker.launch(arrayOf("font/ttf", "font/otf", "application/octet-stream"))
                        },
                    )
                    BasicComponent(
                        title = "Khôi phục font",
                        summary = "Trở về font đã dùng trước khi TNM thay đổi",
                        startAction = { FeatureIcon(MiuixIcons.Refresh, Color(0xFF34C759)) },
                        onClick = {
                            Thread {
                                val result = FontManager.restore()
                                runOnUiThread {
                                    message = result
                                    fontDialog = false
                                }
                            }.start()
                        },
                    )
                }
            }

            OverlayDialog(
                title = "Thermal",
                summary = "Chọn profile thermal dùng ngay trong ROM.",
                show = thermalDialog,
                onDismissRequest = { thermalDialog = false },
            ) {
                Card {
                    RadioButtonPreference(
                        title = "Eco",
                        summary = "Ưu tiên pin và nhiệt độ, vẫn giữ bảo vệ thermal stock",
                        selected = selectedThermal == "eco",
                        onClick = {
                            Thread {
                                val result = ThermalManager.applyEco(this@MainActivity)
                                runOnUiThread {
                                    message = result
                                    if (result.startsWith("Đã bật")) selectedThermal = "eco"
                                    thermalDialog = false
                                    refreshRealtimeNow()
                                }
                            }.start()
                        },
                    )
                    RadioButtonPreference(
                        title = "Stock Xiaomi",
                        summary = "Khôi phục thermal nguyên bản Xiaomi",
                        selected = selectedThermal == "stock",
                        onClick = {
                            Thread {
                                val result = ThermalManager.applyStock(this@MainActivity)
                                runOnUiThread {
                                    message = result
                                    if (result.startsWith("Đã khôi phục")) selectedThermal = "stock"
                                    thermalDialog = false
                                    refreshRealtimeNow()
                                }
                            }.start()
                        },
                    )
                }
            }

            OverlayDialog(
                title = "Thông tin hệ thống",
                summary = info?.device ?: "Đang đọc thông tin thiết bị…",
                show = systemDialog,
                onDismissRequest = { systemDialog = false },
            ) {
                Card {
                    DetailRow("SoC", info?.soc ?: "—")
                    DetailRow("CPU hiện tại", info?.cpuCurrent ?: "—")
                    DetailRow("CPU tối đa", info?.cpuMax ?: "—")
                    DetailRow("RAM đang dùng / tổng", info?.ram ?: "—")
                    DetailRow("Bộ nhớ", info?.storage ?: "—")
                    DetailRow("Android", info?.android ?: "—")
                    DetailRow("HyperOS", info?.hyperos ?: "—")
                    DetailRow("Nhiệt pin", info?.batteryTemp ?: "—")
                    DetailRow("Nhiệt SoC / CPU", info?.socTemp ?: "—")
                    DetailRow("Nhiệt GPU", info?.gpuTemp ?: "—")
                    DetailRow("Thermal", info?.thermal ?: "—")
                    DetailRow("Root", info?.root ?: "—")
                }
            }

            OverlayDialog(
                title = "Integrity",
                summary = "Chẩn đoán cục bộ + Play Integrity chính thức khi đã cấu hình backend.",
                show = integrityDialog,
                onDismissRequest = { integrityDialog = false },
            ) {
                Card {
                    DetailRow("Chẩn đoán", integrity?.summary ?: "—")
                    DetailRow("Verified Boot", integrity?.verifiedBoot ?: "—")
                    DetailRow("Bootloader", integrity?.bootloader ?: "—")
                    DetailRow("VBMeta", integrity?.vbmeta ?: "—")
                    DetailRow("SELinux", integrity?.selinux ?: "—")
                    DetailRow("Build tags", integrity?.buildTags ?: "—")
                    DetailRow("Root", integrity?.root ?: "—")
                    DetailRow("Play Integrity", playIntegrity)
                }
                Spacer(Modifier.height(12.dp))
                Button(
                    enabled = !checkingIntegrity,
                    onClick = {
                        checkingIntegrity = true
                        playIntegrity = "Đang kiểm tra…"
                        scope.launch {
                            playIntegrity = withContext(Dispatchers.IO) {
                                IntegrityChecker.official(this@MainActivity)
                            }
                            checkingIntegrity = false
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(if (checkingIntegrity) "Đang kiểm tra…" else "Check Play Integrity")
                }
            }
        }
    }

    @Composable
    private fun DeviceHero(info: DeviceInfo?) {
        Card(
            modifier = Modifier
                .padding(horizontal = 12.dp)
                .fillMaxWidth(),
            insideMargin = PaddingValues(18.dp),
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Box(
                    modifier = Modifier
                        .size(68.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(Color(0xFF3482FF)),
                    contentAlignment = Alignment.Center,
                ) {
                    Image(
                        painter = painterResource(R.drawable.ic_tnm_foreground),
                        contentDescription = "TNM",
                        modifier = Modifier.size(54.dp),
                    )
                }
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    Text(
                        text = info?.device ?: "Đang đọc thiết bị…",
                        style = MiuixTheme.textStyles.title3,
                    )
                    Text(
                        text = buildString {
                            append(info?.hyperos ?: "HyperOS")
                            append(" · ")
                            append(info?.android ?: "Android")
                        },
                        style = MiuixTheme.textStyles.body2,
                        color = MiuixTheme.colorScheme.onSurfaceVariantSummary,
                    )
                }
            }
        }
    }

    @Composable
    private fun FeatureIcon(imageVector: ImageVector, accent: Color) {
        Box(
            modifier = Modifier
                .padding(end = 14.dp)
                .size(40.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(accent),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = imageVector,
                contentDescription = null,
                modifier = Modifier.size(22.dp),
                tint = Color.White,
            )
        }
    }

    @Composable
    private fun StatCard(
        modifier: Modifier,
        title: String,
        value: String,
        imageVector: ImageVector,
        accent: Color,
    ) {
        Card(
            modifier = modifier,
            insideMargin = PaddingValues(14.dp),
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                Box(
                    modifier = Modifier
                        .size(34.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(accent),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = imageVector,
                        contentDescription = null,
                        modifier = Modifier.size(19.dp),
                        tint = Color.White,
                    )
                }
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(2.dp),
                ) {
                    Text(
                        text = title,
                        style = MiuixTheme.textStyles.body2,
                        color = MiuixTheme.colorScheme.onSurfaceVariantSummary,
                    )
                    Text(
                        text = value,
                        style = MiuixTheme.textStyles.headline2,
                    )
                }
            }
        }
    }

    @Composable
    private fun DetailRow(title: String, value: String) {
        BasicComponent(title = title, summary = value)
    }
}
