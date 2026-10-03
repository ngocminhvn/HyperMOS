package com.android.trinhngocminh

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
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
import top.yukonga.miuix.kmp.blur.BlendColorEntry
import top.yukonga.miuix.kmp.blur.BlurBlendMode
import top.yukonga.miuix.kmp.blur.BlurDefaults
import top.yukonga.miuix.kmp.blur.isRuntimeShaderSupported
import top.yukonga.miuix.kmp.blur.layerBackdrop
import top.yukonga.miuix.kmp.blur.rememberLayerBackdrop
import top.yukonga.miuix.kmp.blur.textureBlur
import top.yukonga.miuix.kmp.blur.highlight.Highlight
import top.yukonga.miuix.kmp.icon.MiuixIcons
import top.yukonga.miuix.kmp.icon.extended.Info
import top.yukonga.miuix.kmp.icon.extended.Link
import top.yukonga.miuix.kmp.icon.extended.More
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
        var fontDialog by remember { mutableStateOf(false) }
        var thermalDialog by remember { mutableStateOf(false) }
        var systemDialog by remember { mutableStateOf(false) }
        var powerDialog by remember { mutableStateOf(false) }
        var confirmRebootDialog by remember { mutableStateOf(false) }
        var pendingReboot by remember { mutableStateOf<RebootTarget?>(null) }
        var message by remember { mutableStateOf("") }
        var lastThermalNotice by remember { mutableStateOf<String?>(null) }
        var selectedThermal by remember { mutableStateOf(ThermalManager.selected(this)) }
        var appVisible by remember {
            mutableStateOf(lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED))
        }
        var cpuHistory by remember { mutableStateOf<List<Float>>(emptyList()) }

        val scope = rememberCoroutineScope()
        val listState = rememberLazyListState()
        val scrollBehavior = MiuixScrollBehavior()

        fun readStaticOnce() {
            scope.launch {
                info = withContext(Dispatchers.IO) {
                    SystemInfo.readStatic(this@MainActivity)
                }
            }
        }

        fun refreshRealtimeNow() {
            val current = info ?: return
            scope.launch {
                info = withContext(Dispatchers.IO) {
                    SystemInfo.readRealtime(this@MainActivity, current)
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
            info = withContext(Dispatchers.IO) {
                SystemInfo.readStatic(this@MainActivity)
            }
        }

        LaunchedEffect(appVisible) {
            while (appVisible) {
                val current = info
                if (current != null) {
                    val next = withContext(Dispatchers.IO) {
                        SystemInfo.readRealtime(this@MainActivity, current)
                    }
                    info = next
                    next.cpuCurrent
                        .substringBefore(" ")
                        .replace(',', '.')
                        .toFloatOrNull()
                        ?.let { ghz ->
                            cpuHistory = (cpuHistory + ghz).takeLast(60)
                        }

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
                        IconButton(
                            onClick = {
                                startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("https://github.com/ngocminhvn/HyperMOS")
                                    )
                                )
                            }
                        ) {
                            Icon(
                                imageVector = MiuixIcons.Link,
                                contentDescription = "GitHub",
                                tint = MiuixTheme.colorScheme.onBackground,
                            )
                        }
                        IconButton(onClick = { powerDialog = true }) {
                            Icon(
                                imageVector = MiuixIcons.More,
                                contentDescription = "Nguồn",
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
                item(key = "hero") {
                    GlossyDeviceHero(info)
                }

                item(key = "customTitle") {
                    SmallTitle("Tùy chỉnh")
                }

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

                item(key = "realtimeTitle") {
                    SmallTitle("Realtime")
                }

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

                item(key = "cpuChart") {
                    Spacer(Modifier.height(10.dp))
                    CpuChart(
                        values = cpuHistory,
                        current = info?.cpuCurrent ?: "—",
                        max = info?.cpuMax ?: "—",
                    )
                }

                item(key = "deviceTitle") {
                    SmallTitle("Thiết bị")
                }

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
                title = "Nguồn",
                summary = "Chọn chế độ khởi động. TNM cần quyền root.",
                show = powerDialog,
                onDismissRequest = { powerDialog = false },
            ) {
                Card {
                    RebootChoice("Khởi động lại", "Android bình thường", RebootTarget.SYSTEM) {
                        pendingReboot = it
                        powerDialog = false
                        confirmRebootDialog = true
                    }
                    RebootChoice("Fastboot", "Bootloader fastboot", RebootTarget.BOOTLOADER) {
                        pendingReboot = it
                        powerDialog = false
                        confirmRebootDialog = true
                    }
                    RebootChoice("Fastbootd", "Userspace fastbootd", RebootTarget.FASTBOOTD) {
                        pendingReboot = it
                        powerDialog = false
                        confirmRebootDialog = true
                    }
                    RebootChoice("Recovery", "Khởi động vào recovery", RebootTarget.RECOVERY) {
                        pendingReboot = it
                        powerDialog = false
                        confirmRebootDialog = true
                    }
                }
            }

            OverlayDialog(
                title = "Xác nhận khởi động",
                summary = pendingReboot?.description ?: "",
                show = confirmRebootDialog,
                onDismissRequest = { confirmRebootDialog = false },
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    Button(
                        onClick = { confirmRebootDialog = false },
                        modifier = Modifier.weight(1f),
                    ) {
                        Text("Hủy")
                    }
                    Button(
                        onClick = {
                            val target = pendingReboot
                            confirmRebootDialog = false
                            if (target != null) {
                                Thread {
                                    val result = RebootManager.reboot(target)
                                    if (!result.ok) {
                                        runOnUiThread { message = result.message }
                                    }
                                }.start()
                            }
                        },
                        modifier = Modifier.weight(1f),
                    ) {
                        Text("Thực hiện")
                    }
                }
            }
        }
    }

    @Composable
    private fun GlossyDeviceHero(info: DeviceInfo?) {
        val transition = rememberInfiniteTransition(label = "hero")
        val drift by transition.animateFloat(
            initialValue = -22f,
            targetValue = 34f,
            animationSpec = infiniteRepeatable(
                animation = tween(durationMillis = 5600),
                repeatMode = RepeatMode.Reverse,
            ),
            label = "drift",
        )
        val glow by transition.animateFloat(
            initialValue = 0.28f,
            targetValue = 0.46f,
            animationSpec = infiniteRepeatable(
                animation = tween(durationMillis = 3600),
                repeatMode = RepeatMode.Reverse,
            ),
            label = "glow",
        )

        val isDark = isSystemInDarkTheme()
        val shape = RoundedCornerShape(30.dp)
        val backdrop = rememberLayerBackdrop()
        val blurSupported = isRuntimeShaderSupported()
        val glassColors = BlurDefaults.blurColors(
            blendColors = if (isDark) {
                listOf(
                    BlendColorEntry(Color(0x261A1A1A), BlurBlendMode.Overlay),
                    BlendColorEntry(Color(0x18FFFFFF), BlurBlendMode.Screen),
                )
            } else {
                listOf(
                    BlendColorEntry(Color(0x24FFFFFF), BlurBlendMode.Screen),
                    BlendColorEntry(Color(0x100B5CFF), BlurBlendMode.SoftLight),
                )
            },
            brightness = if (isDark) -0.02f else 0.03f,
            contrast = 1.06f,
            saturation = 1.28f,
        )
        val glassHighlight = if (isDark) {
            Highlight.GlassStrokeBigDark
        } else {
            Highlight.GlassStrokeBigLight
        }

        Box(
            modifier = Modifier
                .padding(horizontal = 12.dp)
                .fillMaxWidth()
                .height(218.dp)
                .clip(shape),
        ) {
            // Real backdrop layer: this is what Miuix textureBlur samples.
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .layerBackdrop(backdrop)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                Color(0xFF061B50),
                                Color(0xFF0B4FD8),
                                Color(0xFF3C2BAA),
                                Color(0xFF220D3C),
                            )
                        )
                    ),
            ) {
                Box(
                    modifier = Modifier
                        .offset(x = drift.dp, y = (-50).dp)
                        .size(230.dp)
                        .blur(68.dp)
                        .background(Color(0xFF367CFF).copy(alpha = glow), CircleShape),
                )
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .offset(x = 56.dp, y = (-18).dp)
                        .size(210.dp)
                        .blur(72.dp)
                        .background(Color(0xFF7A3CFF).copy(alpha = glow * 0.92f), CircleShape),
                )
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .offset(y = 58.dp)
                        .size(250.dp)
                        .blur(82.dp)
                        .background(Color(0xFF003B9E).copy(alpha = 0.42f), CircleShape),
                )
            }

            val glassModifier = if (blurSupported) {
                Modifier
                    .fillMaxSize()
                    .textureBlur(
                        backdrop = backdrop,
                        shape = shape,
                        blurRadiusX = 150f,
                        blurRadiusY = 150f,
                        noiseCoefficient = 0.0044f,
                        colors = glassColors,
                        highlight = glassHighlight,
                    )
            } else {
                Modifier
                    .fillMaxSize()
                    .background(
                        if (isDark) Color.Black.copy(alpha = 0.18f)
                        else Color.White.copy(alpha = 0.12f)
                    )
                    .border(1.dp, Color.White.copy(alpha = 0.14f), shape)
            }

            Box(modifier = glassModifier) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(20.dp),
                    verticalArrangement = Arrangement.SpaceBetween,
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(14.dp),
                    ) {
                        Box(
                            modifier = Modifier
                                .size(60.dp)
                                .clip(RoundedCornerShape(19.dp))
                                .background(Color.White.copy(alpha = 0.13f))
                                .border(
                                    1.dp,
                                    Color.White.copy(alpha = 0.20f),
                                    RoundedCornerShape(19.dp),
                                ),
                            contentAlignment = Alignment.Center,
                        ) {
                            Image(
                                painter = painterResource(R.drawable.ic_tnm_foreground),
                                contentDescription = "TNM",
                                modifier = Modifier.size(48.dp),
                            )
                        }
                        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                            Text(
                                text = info?.device ?: "Đang đọc thiết bị…",
                                style = MiuixTheme.textStyles.title3,
                                color = Color.White,
                            )
                            Text(
                                text = "${info?.hyperos ?: "HyperOS"} · ${info?.android ?: "Android"}",
                                style = MiuixTheme.textStyles.body2,
                                color = Color.White.copy(alpha = 0.76f),
                            )
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        HeroMetric(
                            modifier = Modifier.weight(1f),
                            title = "SoC",
                            value = info?.soc ?: "—",
                        )
                        HeroMetric(
                            modifier = Modifier.weight(1f),
                            title = "CPU",
                            value = info?.cpuCurrent ?: "—",
                        )
                        HeroMetric(
                            modifier = Modifier.weight(1f),
                            title = "Nhiệt",
                            value = info?.socTemp ?: "—",
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun HeroMetric(
        modifier: Modifier,
        title: String,
        value: String,
    ) {
        Column(
            modifier = modifier
                .clip(RoundedCornerShape(14.dp))
                .background(Color.Black.copy(alpha = 0.16f))
                .padding(horizontal = 10.dp, vertical = 9.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text(
                text = title,
                style = MiuixTheme.textStyles.footnote1,
                color = Color.White.copy(alpha = 0.66f),
            )
            Text(
                text = value,
                style = MiuixTheme.textStyles.body2,
                color = Color.White,
                maxLines = 1,
            )
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
                        maxLines = 1,
                    )
                }
            }
        }
    }

    @Composable
    private fun CpuChart(
        values: List<Float>,
        current: String,
        max: String,
    ) {
        Card(
            modifier = Modifier
                .padding(horizontal = 12.dp)
                .fillMaxWidth(),
            insideMargin = PaddingValues(16.dp),
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column {
                        Text(text = "Biểu đồ CPU", style = MiuixTheme.textStyles.title4)
                        Text(
                            text = "60 giây gần nhất · cập nhật mỗi 1 giây",
                            style = MiuixTheme.textStyles.footnote1,
                            color = MiuixTheme.colorScheme.onSurfaceVariantSummary,
                        )
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text(text = current, style = MiuixTheme.textStyles.headline2)
                        Text(
                            text = "Max $max",
                            style = MiuixTheme.textStyles.footnote1,
                            color = MiuixTheme.colorScheme.onSurfaceVariantSummary,
                        )
                    }
                }
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(132.dp)
                ) {
                    val grid = Color.Gray.copy(alpha = 0.16f)
                    repeat(4) { i ->
                        val y = size.height * i / 3f
                        drawLine(
                            color = grid,
                            start = androidx.compose.ui.geometry.Offset(0f, y),
                            end = androidx.compose.ui.geometry.Offset(size.width, y),
                        )
                    }
                    repeat(5) { i ->
                        val x = size.width * i / 4f
                        drawLine(
                            color = grid.copy(alpha = 0.10f),
                            start = androidx.compose.ui.geometry.Offset(x, 0f),
                            end = androidx.compose.ui.geometry.Offset(x, size.height),
                        )
                    }

                    if (values.isNotEmpty()) {
                        val maxGHz = max
                            .substringBefore(" ")
                            .replace(',', '.')
                            .toFloatOrNull()
                            ?: 1f
                        val ceiling = maxOf(values.maxOrNull() ?: 1f, maxGHz, 1f)
                        val startSlot = (60 - values.size).coerceAtLeast(0)
                        val points = values.mapIndexed { index, value ->
                            val slot = startSlot + index
                            val x = size.width * slot / 59f
                            val y = size.height - (value / ceiling).coerceIn(0f, 1f) * size.height
                            androidx.compose.ui.geometry.Offset(x, y)
                        }

                        if (points.size >= 2) {
                            val fillPath = Path().apply {
                                moveTo(points.first().x, size.height)
                                lineTo(points.first().x, points.first().y)
                                points.drop(1).forEach { lineTo(it.x, it.y) }
                                lineTo(points.last().x, size.height)
                                close()
                            }
                            drawPath(
                                path = fillPath,
                                color = Color(0xFF3482FF).copy(alpha = 0.13f),
                            )

                            val linePath = Path().apply {
                                moveTo(points.first().x, points.first().y)
                                points.drop(1).forEach { lineTo(it.x, it.y) }
                            }
                            drawPath(
                                path = linePath,
                                color = Color(0xFF3482FF),
                                style = Stroke(width = 4.dp.toPx()),
                            )
                        }

                        points.forEachIndexed { index, point ->
                            if (index == points.lastIndex || index % 5 == 0) {
                                drawCircle(
                                    color = Color(0xFF3482FF),
                                    radius = if (index == points.lastIndex) 4.5.dp.toPx() else 2.4.dp.toPx(),
                                    center = point,
                                )
                            }
                        }
                    }
                }
                }
            }
        }
    }

    @Composable
    private fun RebootChoice(
        title: String,
        summary: String,
        target: RebootTarget,
        onClick: (RebootTarget) -> Unit,
    ) {
        BasicComponent(
            title = title,
            summary = summary,
            onClick = { onClick(target) },
        )
    }

    @Composable
    private fun DetailRow(title: String, value: String) {
        BasicComponent(title = title, summary = value)
    }
}
