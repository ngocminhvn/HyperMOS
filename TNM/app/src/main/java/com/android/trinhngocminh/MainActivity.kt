package com.android.trinhngocminh

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.isSystemInDarkTheme
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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.BatteryFull
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.Download
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.Link
import androidx.compose.material.icons.rounded.Memory
import androidx.compose.material.icons.rounded.MoreVert
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.PowerSettingsNew
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material.icons.rounded.RestartAlt
import androidx.compose.material.icons.rounded.Security
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.Speed
import androidx.compose.material.icons.rounded.Storage
import androidx.compose.material.icons.rounded.TextFields
import androidx.compose.material.icons.rounded.Thermostat
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val dark = isSystemInDarkTheme()
            val scheme = if (Build.VERSION.SDK_INT >= 31) {
                if (dark) dynamicDarkColorScheme(this) else dynamicLightColorScheme(this)
            } else {
                if (dark) darkColorScheme() else lightColorScheme()
            }
            MaterialTheme(colorScheme = scheme) {
                AppContent()
            }
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun AppContent() {
        var selectedTab by remember { mutableStateOf(0) }
        var info by remember { mutableStateOf<DeviceInfo?>(null) }
        var cpuHistory by remember { mutableStateOf<List<Float>>(emptyList()) }
        var appVisible by remember {
            mutableStateOf(lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED))
        }

        var driveFiles by remember { mutableStateOf<List<DriveFile>>(emptyList()) }
        var driveLoading by remember { mutableStateOf(false) }
        var driveError by remember { mutableStateOf<String?>(null) }
        var downloadingIds by remember { mutableStateOf<Set<String>>(emptySet()) }
        var downloadStatus by remember { mutableStateOf("") }

        var fontDialog by remember { mutableStateOf(false) }
        var thermalDialog by remember { mutableStateOf(false) }
        var systemDialog by remember { mutableStateOf(false) }
        var integrityDialog by remember { mutableStateOf(false) }
        var powerDialog by remember { mutableStateOf(false) }
        var confirmRebootDialog by remember { mutableStateOf(false) }
        var pendingReboot by remember { mutableStateOf<RebootTarget?>(null) }
        var integrity by remember { mutableStateOf(IntegrityDiagnostics.read()) }

        var message by remember { mutableStateOf("") }
        var selectedThermal by remember { mutableStateOf(ThermalManager.selected(this)) }
        var lastThermalNotice by remember { mutableStateOf<String?>(null) }

        val scope = rememberCoroutineScope()

        fun refreshDrive() {
            scope.launch {
                driveLoading = true
                driveError = null
                val result = withContext(Dispatchers.IO) {
                    DriveDownloads.list(this@MainActivity)
                }
                driveFiles = result.files
                driveError = result.error
                driveLoading = false
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
                info?.let { current ->
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

        LaunchedEffect(selectedTab) {
            if (selectedTab == 1) refreshDrive()
        }

        val fontPicker = rememberLauncherForActivityResult(
            ActivityResultContracts.OpenDocument()
        ) { uri: Uri? ->
            if (uri != null) {
                scope.launch {
                    val result = withContext(Dispatchers.IO) {
                        FontManager.apply(this@MainActivity, uri)
                    }
                    message = result
                    fontDialog = false
                }
            }
        }

        val pageTitle = when (selectedTab) {
            0 -> "TNM"
            1 -> "Downloads"
            else -> "Tools"
        }

        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Column {
                            Text(
                                text = pageTitle,
                                fontWeight = FontWeight.SemiBold,
                            )
                            if (selectedTab != 0) {
                                Text(
                                    text = if (selectedTab == 1) "Google Drive" else "HyperMOS Control",
                                    style = MaterialTheme.typography.labelMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        }
                    },
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
                            Icon(Icons.Rounded.Link, contentDescription = "GitHub")
                        }
                        IconButton(onClick = { powerDialog = true }) {
                            Icon(Icons.Rounded.MoreVert, contentDescription = "Nguồn")
                        }
                    },
                )
            },
            bottomBar = {
                NavigationBar {
                    NavigationBarItem(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        icon = { Icon(Icons.Rounded.Home, null) },
                        label = { Text("Home") },
                    )
                    NavigationBarItem(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        icon = { Icon(Icons.Rounded.Download, null) },
                        label = { Text("Downloads") },
                    )
                    NavigationBarItem(
                        selected = selectedTab == 2,
                        onClick = { selectedTab = 2 },
                        icon = { Icon(Icons.Rounded.Settings, null) },
                        label = { Text("Tools") },
                    )
                }
            },
        ) { padding ->
            when (selectedTab) {
                0 -> HomePage(
                    modifier = Modifier.padding(padding),
                    info = info,
                    cpuHistory = cpuHistory,
                    message = message,
                )
                1 -> DownloadsPage(
                    modifier = Modifier.padding(padding),
                    files = driveFiles,
                    loading = driveLoading,
                    error = driveError,
                    status = downloadStatus,
                    downloadingIds = downloadingIds,
                    onRefresh = { refreshDrive() },
                    onDownload = { file ->
                        if (file.id !in downloadingIds) {
                            downloadingIds = downloadingIds + file.id
                            downloadStatus = "Đang tải ${file.name}…"
                            scope.launch {
                                val result = withContext(Dispatchers.IO) {
                                    DriveDownloads.download(this@MainActivity, file)
                                }
                                downloadStatus = result
                                downloadingIds = downloadingIds - file.id
                            }
                        }
                    },
                )
                else -> ToolsPage(
                    modifier = Modifier.padding(padding),
                    info = info,
                    message = message,
                    onFont = { fontDialog = true },
                    onThermal = { thermalDialog = true },
                    onSystemInfo = { systemDialog = true },
                    onIntegrity = {
                        integrity = IntegrityDiagnostics.read()
                        integrityDialog = true
                    },
                    onFcm = {
                        GmsFcmDiagnostics.open(this@MainActivity)?.let { message = it }
                    },
                )
            }
        }

        if (fontDialog) {
            AlertDialog(
                onDismissRequest = { fontDialog = false },
                title = { Text("Font") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Dùng font hệ thống mặc định của Material 3 hoặc chọn file .ttf/.otf để áp dụng cho ROM.")
                        Button(
                            onClick = {
                                fontPicker.launch(
                                    arrayOf("font/ttf", "font/otf", "application/octet-stream")
                                )
                            },
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text("Chọn file font")
                        }
                        OutlinedButton(
                            onClick = {
                                scope.launch {
                                    message = withContext(Dispatchers.IO) {
                                        FontManager.restore()
                                    }
                                    fontDialog = false
                                }
                            },
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text("Khôi phục font")
                        }
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { fontDialog = false }) {
                        Text("Đóng")
                    }
                },
            )
        }

        if (thermalDialog) {
            AlertDialog(
                onDismissRequest = { thermalDialog = false },
                title = { Text("Thermal") },
                text = {
                    Column {
                        ThermalChoice(
                            title = "Eco",
                            summary = "Ưu tiên pin và nhiệt độ",
                            selected = selectedThermal == "eco",
                            onClick = {
                                scope.launch {
                                    val result = withContext(Dispatchers.IO) {
                                        ThermalManager.applyEco(this@MainActivity)
                                    }
                                    message = result
                                    if (result.startsWith("Đã bật")) selectedThermal = "eco"
                                    thermalDialog = false
                                    refreshRealtimeNow()
                                }
                            },
                        )
                        ThermalChoice(
                            title = "Stock Xiaomi",
                            summary = "Khôi phục thermal nguyên bản",
                            selected = selectedThermal == "stock",
                            onClick = {
                                scope.launch {
                                    val result = withContext(Dispatchers.IO) {
                                        ThermalManager.applyStock(this@MainActivity)
                                    }
                                    message = result
                                    if (result.startsWith("Đã khôi phục")) selectedThermal = "stock"
                                    thermalDialog = false
                                    refreshRealtimeNow()
                                }
                            },
                        )
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { thermalDialog = false }) {
                        Text("Đóng")
                    }
                },
            )
        }

        if (systemDialog) {
            AlertDialog(
                onDismissRequest = { systemDialog = false },
                title = { Text("Thông tin hệ thống") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        InfoLine("Thiết bị", info?.device ?: "—")
                        InfoLine("SoC", info?.soc ?: "—")
                        InfoLine("CPU", info?.cpuCurrent ?: "—")
                        InfoLine("CPU max", info?.cpuMax ?: "—")
                        InfoLine("RAM", info?.ram ?: "—")
                        InfoLine("Bộ nhớ", info?.storage ?: "—")
                        InfoLine("Android", info?.android ?: "—")
                        InfoLine("HyperOS", info?.hyperos ?: "—")
                        InfoLine("Pin", info?.batteryTemp ?: "—")
                        InfoLine("Công suất", info?.batteryPower ?: "—")
                        InfoLine("Nhiệt SoC", info?.socTemp ?: "—")
                        InfoLine("Nhiệt GPU", info?.gpuTemp ?: "—")
                        InfoLine("Thermal", info?.thermal ?: "—")
                        InfoLine("Root", info?.root ?: "—")
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { systemDialog = false }) {
                        Text("Đóng")
                    }
                },
            )
        }

        if (integrityDialog) {
            AlertDialog(
                onDismissRequest = { integrityDialog = false },
                icon = { Icon(Icons.Rounded.Security, null) },
                title = { Text("Integrity") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(
                            integrity.summary,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        InfoLine("Verified Boot", integrity.verifiedBoot)
                        InfoLine("Bootloader", integrity.bootloader)
                        InfoLine("VBMeta", integrity.vbmeta)
                        InfoLine("Build tags", integrity.buildTags)
                        InfoLine("Root", integrity.root)
                        HorizontalDivider()
                        Text(
                            "Đây là kiểm tra cục bộ. Nó không phải verdict BASIC / DEVICE / STRONG của Google Play Integrity.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { integrityDialog = false }) {
                        Text("Đóng")
                    }
                },
            )
        }

        if (powerDialog) {
            AlertDialog(
                onDismissRequest = { powerDialog = false },
                icon = { Icon(Icons.Rounded.PowerSettingsNew, null) },
                title = { Text("Khởi động") },
                text = {
                    Column {
                        RebootChoice("Khởi động lại", RebootTarget.SYSTEM) {
                            pendingReboot = it
                            powerDialog = false
                            confirmRebootDialog = true
                        }
                        RebootChoice("Fastboot", RebootTarget.BOOTLOADER) {
                            pendingReboot = it
                            powerDialog = false
                            confirmRebootDialog = true
                        }
                        RebootChoice("Fastbootd", RebootTarget.FASTBOOTD) {
                            pendingReboot = it
                            powerDialog = false
                            confirmRebootDialog = true
                        }
                        RebootChoice("Recovery", RebootTarget.RECOVERY) {
                            pendingReboot = it
                            powerDialog = false
                            confirmRebootDialog = true
                        }
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { powerDialog = false }) {
                        Text("Hủy")
                    }
                },
            )
        }

        if (confirmRebootDialog) {
            AlertDialog(
                onDismissRequest = { confirmRebootDialog = false },
                title = { Text("Xác nhận") },
                text = { Text(pendingReboot?.description ?: "") },
                dismissButton = {
                    OutlinedButton(onClick = { confirmRebootDialog = false }) {
                        Text("Hủy")
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            val target = pendingReboot
                            confirmRebootDialog = false
                            if (target != null) {
                                scope.launch {
                                    val result = withContext(Dispatchers.IO) {
                                        RebootManager.reboot(target)
                                    }
                                    if (!result.ok) message = result.message
                                }
                            }
                        }
                    ) {
                        Text("Thực hiện")
                    }
                },
            )
        }
    }

    @Composable
    private fun HomePage(
        modifier: Modifier,
        info: DeviceInfo?,
        cpuHistory: List<Float>,
        message: String,
    ) {
        LazyColumn(
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item {
                DeviceHero(info)
            }

            if (message.isNotBlank()) {
                item {
                    Card {
                        ListItem(
                            headlineContent = { Text("Trạng thái", fontWeight = FontWeight.Medium) },
                            supportingContent = { Text(message) },
                            leadingContent = { Icon(Icons.Rounded.Info, null) },
                            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                        )
                    }
                }
            }

            item {
                SectionTitle("Realtime")
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.Speed,
                        title = "CPU",
                        value = info?.cpuCurrent ?: "—",
                    )
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.Memory,
                        title = "RAM",
                        value = info?.ram ?: "—",
                    )
                }
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.Thermostat,
                        title = "SoC",
                        value = info?.socTemp ?: "—",
                    )
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.BatteryFull,
                        title = "Pin",
                        value = info?.batteryTemp ?: "—",
                    )
                }
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.Bolt,
                        title = "Công suất",
                        value = info?.batteryPower ?: "—",
                    )
                    StatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Rounded.Thermostat,
                        title = "GPU",
                        value = info?.gpuTemp ?: "—",
                    )
                }
            }

            item {
                CpuChart(cpuHistory, info?.cpuCurrent ?: "—", info?.cpuMax ?: "—")
            }
        }
    }

    @Composable
    private fun DeviceHero(info: DeviceInfo?) {
        val dark = isSystemInDarkTheme()
        val shape = RoundedCornerShape(28.dp)
        Card(
            shape = shape,
            colors = CardDefaults.cardColors(containerColor = Color.Transparent),
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(190.dp)
                    .clip(shape)
                    .background(
                        Brush.linearGradient(
                            if (dark) {
                                listOf(
                                    Color(0xFF0A2A5B),
                                    Color(0xFF274EBE),
                                    Color(0xFF5A3BA8),
                                )
                            } else {
                                listOf(
                                    Color(0xFFD9E9FF),
                                    Color(0xFFAEC8FF),
                                    Color(0xFFD9C6FF),
                                )
                            }
                        )
                    ),
            ) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .size(120.dp)
                        .blur(42.dp)
                        .background(
                            Color.White.copy(alpha = if (dark) 0.10f else 0.28f),
                            CircleShape,
                        )
                )
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
                                .size(58.dp)
                                .clip(RoundedCornerShape(18.dp))
                                .background(Color.White.copy(alpha = 0.18f)),
                            contentAlignment = Alignment.Center,
                        ) {
                            androidx.compose.foundation.Image(
                                painter = painterResource(R.drawable.ic_tnm_foreground),
                                contentDescription = "TNM",
                                modifier = Modifier.size(46.dp),
                            )
                        }
                        Column {
                            Text(
                                text = info?.device ?: "Đang đọc thiết bị…",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.SemiBold,
                                color = if (dark) Color.White else Color(0xFF101318),
                            )
                            Text(
                                text = "${info?.hyperos ?: "HyperOS"} · ${info?.android ?: "Android"}",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (dark) Color.White.copy(alpha = 0.72f) else Color(0xFF343840),
                            )
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        HeroPill(
                            modifier = Modifier.weight(1f),
                            label = "Thermal",
                            value = info?.thermal ?: "—",
                            dark = dark,
                        )
                        HeroPill(
                            modifier = Modifier.weight(1f),
                            label = "Power",
                            value = info?.batteryPower ?: "—",
                            dark = dark,
                        )
                        HeroPill(
                            modifier = Modifier.weight(1f),
                            label = "CPU",
                            value = info?.cpuCurrent ?: "—",
                            dark = dark,
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun HeroPill(
        modifier: Modifier,
        label: String,
        value: String,
        dark: Boolean,
    ) {
        Column(
            modifier = modifier
                .clip(RoundedCornerShape(16.dp))
                .background(
                    if (dark) Color.Black.copy(alpha = 0.18f)
                    else Color.White.copy(alpha = 0.46f)
                )
                .padding(horizontal = 10.dp, vertical = 9.dp),
        ) {
            Text(
                label,
                style = MaterialTheme.typography.labelSmall,
                color = if (dark) Color.White.copy(alpha = 0.64f) else Color(0xFF575B64),
            )
            Text(
                value,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = if (dark) Color.White else Color(0xFF111318),
                maxLines = 1,
            )
        }
    }

    @Composable
    private fun StatCard(
        modifier: Modifier,
        icon: ImageVector,
        title: String,
        value: String,
    ) {
        Card(modifier = modifier) {
            Row(
                modifier = Modifier.padding(14.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        icon,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                        tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        title,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Text(
                        value,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
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
        Card {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column {
                        Text("Biểu đồ CPU", fontWeight = FontWeight.SemiBold)
                        Text(
                            "60 giây gần nhất",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text(current, fontWeight = FontWeight.SemiBold)
                        Text(
                            "Max $max",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                val lineColor = MaterialTheme.colorScheme.primary
                val gridColor = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.45f)
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(130.dp),
                ) {
                    repeat(4) { i ->
                        val y = size.height * i / 3f
                        drawLine(
                            color = gridColor,
                            start = androidx.compose.ui.geometry.Offset(0f, y),
                            end = androidx.compose.ui.geometry.Offset(size.width, y),
                        )
                    }

                    if (values.size >= 2) {
                        val maxGHz = max.substringBefore(" ").replace(',', '.').toFloatOrNull() ?: 1f
                        val ceiling = maxOf(values.maxOrNull() ?: 1f, maxGHz, 1f)
                        val startSlot = (60 - values.size).coerceAtLeast(0)
                        val points = values.mapIndexed { index, value ->
                            val slot = startSlot + index
                            val x = size.width * slot / 59f
                            val y = size.height - (value / ceiling).coerceIn(0f, 1f) * size.height
                            androidx.compose.ui.geometry.Offset(x, y)
                        }
                        val path = Path().apply {
                            moveTo(points.first().x, points.first().y)
                            points.drop(1).forEach { lineTo(it.x, it.y) }
                        }
                        drawPath(path, lineColor, style = Stroke(width = 3.dp.toPx()))
                    }
                }
            }
        }
    }

    @Composable
    private fun DownloadsPage(
        modifier: Modifier,
        files: List<DriveFile>,
        loading: Boolean,
        error: String?,
        status: String,
        downloadingIds: Set<String>,
        onRefresh: () -> Unit,
        onDownload: (DriveFile) -> Unit,
    ) {
        LazyColumn(
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                Card {
                    ListItem(
                        headlineContent = {
                            Text("TNM Downloads", fontWeight = FontWeight.SemiBold)
                        },
                        supportingContent = {
                            Text(if (loading) "Đang làm mới…" else "Google Drive folder")
                        },
                        leadingContent = {
                            Icon(Icons.Rounded.Download, contentDescription = null)
                        },
                        trailingContent = {
                            IconButton(onClick = onRefresh, enabled = !loading) {
                                if (loading) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(22.dp),
                                        strokeWidth = 2.dp,
                                    )
                                } else {
                                    Icon(Icons.Rounded.Refresh, contentDescription = "Làm mới")
                                }
                            }
                        },
                        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                    )
                }
            }

            if (status.isNotBlank()) {
                item {
                    Card {
                        ListItem(
                            headlineContent = { Text("Tải xuống") },
                            supportingContent = { Text(status) },
                            leadingContent = { Icon(Icons.Rounded.Info, null) },
                            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                        )
                    }
                }
            }

            if (error != null) {
                item {
                    Card {
                        ListItem(
                            headlineContent = { Text("Không tải được danh sách") },
                            supportingContent = { Text(error) },
                            leadingContent = { Icon(Icons.Rounded.Info, null) },
                            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                        )
                    }
                }
            } else if (!loading && files.isEmpty()) {
                item {
                    Text(
                        "Chưa có file trong folder Drive.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            } else {
                items(files, key = { it.id }) { file ->
                    Card {
                        ListItem(
                            headlineContent = {
                                Text(
                                    file.name,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = 2,
                                )
                            },
                            supportingContent = {
                                Text(DriveDownloads.formatSize(file.sizeBytes))
                            },
                            leadingContent = {
                                Icon(Icons.Rounded.Download, null)
                            },
                            trailingContent = {
                                FilledTonalButton(
                                    enabled = file.id !in downloadingIds,
                                    onClick = { onDownload(file) },
                                ) {
                                    Text(
                                        if (file.id in downloadingIds) "Đang tải" else "Tải"
                                    )
                                }
                            },
                            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun ToolsPage(
        modifier: Modifier,
        info: DeviceInfo?,
        message: String,
        onFont: () -> Unit,
        onThermal: () -> Unit,
        onSystemInfo: () -> Unit,
        onIntegrity: () -> Unit,
        onFcm: () -> Unit,
    ) {
        LazyColumn(
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item { SectionTitle("Tùy chỉnh") }
            item {
                ToolCard(
                    icon = Icons.Rounded.TextFields,
                    title = "Font",
                    summary = "Đổi font hệ thống",
                    onClick = onFont,
                )
            }
            item {
                ToolCard(
                    icon = Icons.Rounded.Thermostat,
                    title = "Thermal",
                    summary = info?.thermal ?: "Eco / Stock Xiaomi",
                    onClick = onThermal,
                )
            }

            item { SectionTitle("Chẩn đoán") }
            item {
                ToolCard(
                    icon = Icons.Rounded.Notifications,
                    title = "FCM Diagnostics",
                    summary = "Mở trang chẩn đoán gốc của Google Play services",
                    onClick = onFcm,
                )
            }
            item {
                ToolCard(
                    icon = Icons.Rounded.Security,
                    title = "Integrity",
                    summary = "Verified Boot · Bootloader · VBMeta · Root",
                    onClick = onIntegrity,
                )
            }
            item {
                ToolCard(
                    icon = Icons.Rounded.Info,
                    title = "Thông tin hệ thống",
                    summary = "${info?.storage ?: "—"} · ${info?.soc ?: "—"}",
                    onClick = onSystemInfo,
                )
            }

            if (message.isNotBlank()) {
                item {
                    Card {
                        ListItem(
                            headlineContent = { Text("Trạng thái") },
                            supportingContent = { Text(message) },
                            leadingContent = { Icon(Icons.Rounded.Info, null) },
                            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun ToolCard(
        icon: ImageVector,
        title: String,
        summary: String,
        onClick: () -> Unit,
    ) {
        Card(onClick = onClick) {
            ListItem(
                headlineContent = {
                    Text(title, fontWeight = FontWeight.Medium)
                },
                supportingContent = { Text(summary) },
                leadingContent = {
                    Box(
                        modifier = Modifier
                            .size(42.dp)
                            .clip(RoundedCornerShape(13.dp))
                            .background(MaterialTheme.colorScheme.primaryContainer),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            icon,
                            null,
                            tint = MaterialTheme.colorScheme.onPrimaryContainer,
                        )
                    }
                },
                colors = ListItemDefaults.colors(containerColor = Color.Transparent),
            )
        }
    }

    @Composable
    private fun ThermalChoice(
        title: String,
        summary: String,
        selected: Boolean,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            RadioButton(selected = selected, onClick = onClick)
            Column(modifier = Modifier.padding(start = 8.dp)) {
                Text(title, fontWeight = FontWeight.Medium)
                Text(
                    summary,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }

    @Composable
    private fun RebootChoice(
        title: String,
        target: RebootTarget,
        onClick: (RebootTarget) -> Unit,
    ) {
        FilledTonalButton(
            onClick = { onClick(target) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 4.dp),
        ) {
            Icon(Icons.Rounded.RestartAlt, null)
            Spacer(Modifier.size(8.dp))
            Text(title)
        }
    }

    @Composable
    private fun InfoLine(title: String, value: String) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                title,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.weight(0.44f),
            )
            Text(
                value,
                fontWeight = FontWeight.Medium,
                modifier = Modifier.weight(0.56f),
            )
        }
    }

    @Composable
    private fun SectionTitle(text: String) {
        Text(
            text,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
    }
}
