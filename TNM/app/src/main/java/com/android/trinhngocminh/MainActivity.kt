package com.android.trinhngocminh

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebView
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.heightIn
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
import androidx.compose.material.icons.rounded.TextFields
import androidx.compose.material.icons.rounded.Thermostat
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.FilledTonalIconButton
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.eltavine.duckdetector.core.evidence.DetectionSeverity
import com.eltavine.duckdetector.core.evidence.InfoKind
import com.eltavine.duckdetector.sdk.DuckDetector
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : ComponentActivity() {
    private var duckSampler: WebView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        DuckDetector.captureLaunchEvidence(intent)
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

        duckSampler = DuckDetector.createProcMountSampler(this)
        duckSampler?.let { sampler ->
            addContentView(
                sampler,
                ViewGroup.LayoutParams(1, 1),
            )
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        DuckDetector.captureLaunchEvidence(intent)
    }

    override fun onDestroy() {
        duckSampler?.let { sampler ->
            (sampler.parent as? ViewGroup)?.removeView(sampler)
            sampler.destroy()
        }
        duckSampler = null
        super.onDestroy()
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
        var pendingDownload by remember { mutableStateOf<DriveFile?>(null) }

        var fontDialog by remember { mutableStateOf(false) }
        var thermalDialog by remember { mutableStateOf(false) }
        var systemDialog by remember { mutableStateOf(false) }
        var integrityDialog by remember { mutableStateOf(false) }
        var powerDialog by remember { mutableStateOf(false) }
        var confirmRebootDialog by remember { mutableStateOf(false) }
        var pendingReboot by remember { mutableStateOf<RebootTarget?>(null) }

        var duckScan by remember { mutableStateOf<DuckScanSnapshot?>(null) }
        var duckScanning by remember { mutableStateOf(false) }
        var selectedDuckItem by remember { mutableStateOf<DuckDetectorItem?>(null) }

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

        fun runDuckScan() {
            if (duckScanning) return
            scope.launch {
                duckScanning = true
                duckScan = withContext(Dispatchers.IO) {
                    DuckDetectorBridge.scan(this@MainActivity)
                }
                duckScanning = false
            }
        }

        fun startDownload(file: DriveFile) {
            if (file.id in downloadingIds) return
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
                            Text(pageTitle, fontWeight = FontWeight.SemiBold)
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
                                        Uri.parse("https://github.com/ngocminhvn/HyperMOS"),
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
                    onDownload = { file -> pendingDownload = file },
                )

                else -> ToolsPage(
                    modifier = Modifier.padding(padding),
                    info = info,
                    message = message,
                    duckScan = duckScan,
                    duckScanning = duckScanning,
                    onFont = { fontDialog = true },
                    onThermal = { thermalDialog = true },
                    onSystemInfo = { systemDialog = true },
                    onIntegrity = {
                        integrityDialog = true
                        if (duckScan == null) runDuckScan()
                    },
                    onFcm = {
                        GmsFcmDiagnostics.open(this@MainActivity)?.let { message = it }
                    },
                )
            }
        }

        pendingDownload?.let { file ->
            val downloading = file.id in downloadingIds
            AlertDialog(
                onDismissRequest = {
                    if (!downloading) pendingDownload = null
                },
                icon = { Icon(Icons.Rounded.Download, contentDescription = null) },
                title = { Text("Tải file?") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(
                            file.name,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold,
                        )
                        Text(
                            DriveDownloads.formatSize(file.sizeBytes),
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Text(
                            "File sẽ được lưu vào Downloads/TNM.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                },
                dismissButton = {
                    OutlinedButton(
                        enabled = !downloading,
                        onClick = { pendingDownload = null },
                    ) {
                        Text("Hủy")
                    }
                },
                confirmButton = {
                    Button(
                        enabled = !downloading,
                        onClick = {
                            pendingDownload = null
                            startDownload(file)
                        },
                    ) {
                        Text("Tải xuống")
                    }
                },
            )
        }

        if (fontDialog) {
            AlertDialog(
                onDismissRequest = { fontDialog = false },
                title = { Text("Font") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Chọn file .ttf/.otf để áp dụng cho ROM.")
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
                icon = { Icon(Icons.Rounded.Info, null) },
                title = { Text("Thông tin hệ thống") },
                text = {
                    LazyColumn(
                        modifier = Modifier.heightIn(max = 520.dp),
                        verticalArrangement = Arrangement.spacedBy(9.dp),
                    ) {
                        item { InfoLine("Thiết bị", info?.device ?: "—") }
                        item { InfoLine("SoC", info?.soc ?: "—") }
                        item { InfoLine("Board", info?.board ?: "—") }
                        item { InfoLine("Hardware", info?.hardware ?: "—") }
                        item { InfoLine("ABI", info?.abi ?: "—") }
                        item { InfoLine("CPU cores", info?.cpuCores ?: "—") }
                        item { InfoLine("CPU hiện tại", info?.cpuCurrent ?: "—") }
                        item { InfoLine("CPU max", info?.cpuMax ?: "—") }
                        item { InfoLine("RAM", info?.ram ?: "—") }
                        item { InfoLine("Bộ nhớ", info?.storage ?: "—") }
                        item { InfoLine("Android", info?.android ?: "—") }
                        item { InfoLine("HyperOS", info?.hyperos ?: "—") }
                        item { InfoLine("Security patch", info?.securityPatch ?: "—") }
                        item { InfoLine("Kernel", info?.kernel ?: "—") }
                        item { InfoLine("Build", info?.buildType ?: "—") }
                        item { InfoLine("Uptime", info?.uptime ?: "—") }
                        item { InfoLine("Fingerprint", info?.fingerprint ?: "—") }
                        item { InfoLine("Pin", info?.batteryTemp ?: "—") }
                        item { InfoLine("Công suất", info?.batteryPower ?: "—") }
                        item { InfoLine("Nhiệt SoC", info?.socTemp ?: "—") }
                        item { InfoLine("Nhiệt GPU", info?.gpuTemp ?: "—") }
                        item { InfoLine("Thermal", info?.thermal ?: "—") }
                        item { InfoLine("Root", info?.root ?: "—") }
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
                onDismissRequest = {
                    if (!duckScanning) integrityDialog = false
                },
                icon = { Icon(Icons.Rounded.Security, null) },
                title = { Text("DuckDetector Integrity") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text(
                            "Quét Boot/AVB, Root, Mount, Zygisk, LSPosed, TEE, Custom ROM, Virtualization và các dấu hiệu hệ thống khác.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )

                        when {
                            duckScanning -> {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                                ) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(26.dp),
                                        strokeWidth = 3.dp,
                                    )
                                    Text("Đang chạy các detector…")
                                }
                            }

                            duckScan?.error != null -> {
                                Text(
                                    "Lỗi: ${duckScan?.error}",
                                    color = MaterialTheme.colorScheme.error,
                                )
                            }

                            duckScan != null -> {
                                val scan = duckScan!!
                                Text(
                                    "Packages: ${scan.visiblePackages} · ${scan.packageVisibility}" +
                                        if (scan.suspiciouslyLowPackages) " · suspiciously low" else "",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                ) {
                                    SummaryBadge(
                                        modifier = Modifier.weight(1f),
                                        label = "Danger",
                                        value = scan.dangerCount,
                                        color = MaterialTheme.colorScheme.errorContainer,
                                    )
                                    SummaryBadge(
                                        modifier = Modifier.weight(1f),
                                        label = "Warning",
                                        value = scan.warningCount,
                                        color = MaterialTheme.colorScheme.tertiaryContainer,
                                    )
                                    SummaryBadge(
                                        modifier = Modifier.weight(1f),
                                        label = "Clear",
                                        value = scan.clearCount,
                                        color = MaterialTheme.colorScheme.primaryContainer,
                                    )
                                }

                                LazyColumn(
                                    modifier = Modifier.heightIn(max = 390.dp),
                                    verticalArrangement = Arrangement.spacedBy(7.dp),
                                ) {
                                    items(scan.items, key = { it.id }) { item ->
                                        DuckDetectorRow(
                                            item = item,
                                            onClick = { selectedDuckItem = item },
                                        )
                                    }
                                }
                            }

                            else -> {
                                Text("Chưa có kết quả quét.")
                            }
                        }
                    }
                },
                dismissButton = {
                    OutlinedButton(
                        enabled = !duckScanning,
                        onClick = { integrityDialog = false },
                    ) {
                        Text("Đóng")
                    }
                },
                confirmButton = {
                    Button(
                        enabled = !duckScanning,
                        onClick = { runDuckScan() },
                    ) {
                        Text(if (duckScan == null) "Quét" else "Quét lại")
                    }
                },
            )
        }

        selectedDuckItem?.let { item ->
            AlertDialog(
                onDismissRequest = { selectedDuckItem = null },
                title = { Text(item.title) },
                text = {
                    LazyColumn(
                        modifier = Modifier.heightIn(max = 520.dp),
                        verticalArrangement = Arrangement.spacedBy(7.dp),
                    ) {
                        item {
                            DetectorStatusHeader(item)
                        }
                        if (item.details.isEmpty()) {
                            item {
                                Text(
                                    "Detector không trả thêm dòng chi tiết.",
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        } else {
                            items(item.details.take(120)) { line ->
                                Text(
                                    line,
                                    style = MaterialTheme.typography.bodySmall,
                                )
                            }
                        }
                    }
                },
                confirmButton = {
                    FilledTonalButton(onClick = { selectedDuckItem = null }) {
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
            item { DeviceHero(info) }

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

            item { SectionTitle("Realtime") }

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
                                color = if (dark) {
                                    Color.White.copy(alpha = 0.72f)
                                } else {
                                    Color(0xFF343840)
                                },
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
            contentPadding = PaddingValues(
                start = 14.dp,
                end = 14.dp,
                top = 12.dp,
                bottom = 22.dp,
            ),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(14.dp),
                    ) {
                        Box(
                            modifier = Modifier
                                .size(46.dp)
                                .clip(RoundedCornerShape(15.dp))
                                .background(MaterialTheme.colorScheme.primaryContainer),
                            contentAlignment = Alignment.Center,
                        ) {
                            Icon(
                                Icons.Rounded.Download,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onPrimaryContainer,
                            )
                        }

                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(2.dp),
                        ) {
                            Text(
                                text = "TNM Downloads",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.SemiBold,
                                maxLines = 1,
                            )
                            Text(
                                text = when {
                                    loading -> "Đang cập nhật danh sách…"
                                    files.isEmpty() -> "Google Drive · Chưa có file"
                                    else -> "Google Drive · ${files.size} file"
                                },
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }

                        FilledTonalIconButton(
                            enabled = !loading,
                            onClick = onRefresh,
                        ) {
                            if (loading) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(20.dp),
                                    strokeWidth = 2.dp,
                                )
                            } else {
                                Icon(Icons.Rounded.Refresh, contentDescription = "Làm mới")
                            }
                        }
                    }
                }
            }

            if (status.isNotBlank()) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(20.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.55f),
                        ),
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 14.dp, vertical = 11.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp),
                        ) {
                            Icon(Icons.Rounded.Info, contentDescription = null)
                            Text(
                                text = status,
                                modifier = Modifier.weight(1f),
                                style = MaterialTheme.typography.bodyMedium,
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }
                }
            }

            if (error != null) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(20.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.errorContainer,
                        ),
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Text(
                                "Không tải được danh sách",
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onErrorContainer,
                            )
                            Text(
                                error,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onErrorContainer,
                                maxLines = 3,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }
                }
            } else if (!loading && files.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 28.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            "Folder Drive hiện chưa có file",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            } else {
                items(files, key = { it.id }) { file ->
                    val downloading = file.id in downloadingIds
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(22.dp),
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 14.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp),
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(MaterialTheme.colorScheme.primaryContainer),
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(
                                    Icons.Rounded.Download,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                                )
                            }

                            Column(
                                modifier = Modifier.weight(1f),
                                verticalArrangement = Arrangement.spacedBy(3.dp),
                            ) {
                                Text(
                                    text = file.name,
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis,
                                )
                                Text(
                                    text = DriveDownloads.formatSize(file.sizeBytes),
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }

                            FilledTonalIconButton(
                                enabled = !downloading,
                                onClick = { onDownload(file) },
                            ) {
                                if (downloading) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(20.dp),
                                        strokeWidth = 2.dp,
                                    )
                                } else {
                                    Icon(
                                        Icons.Rounded.Download,
                                        contentDescription = "Tải ${file.name}",
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
    private fun ToolsPage(
        modifier: Modifier,
        info: DeviceInfo?,
        message: String,
        duckScan: DuckScanSnapshot?,
        duckScanning: Boolean,
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
                val summary = when {
                    duckScanning -> "Đang quét DuckDetector…"
                    duckScan?.error != null -> "DuckDetector lỗi · chạm để thử lại"
                    duckScan != null -> {
                        "Danger ${duckScan.dangerCount} · Warning ${duckScan.warningCount} · Clear ${duckScan.clearCount}"
                    }
                    else -> "DuckDetector SDK · Boot · Root · Mount · TEE · Zygisk"
                }
                ToolCard(
                    icon = Icons.Rounded.Security,
                    title = "Integrity Scan",
                    summary = summary,
                    onClick = onIntegrity,
                )
            }
            item {
                ToolCard(
                    icon = Icons.Rounded.Info,
                    title = "Thông tin hệ thống",
                    summary = "${info?.storage ?: "—"} · ${info?.soc ?: "—"} · ${info?.kernel ?: "—"}",
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
    private fun DuckDetectorRow(
        item: DuckDetectorItem,
        onClick: () -> Unit,
    ) {
        val container = when (item.severity) {
            DetectionSeverity.DANGER -> MaterialTheme.colorScheme.errorContainer
            DetectionSeverity.WARNING -> MaterialTheme.colorScheme.tertiaryContainer
            DetectionSeverity.ALL_CLEAR -> MaterialTheme.colorScheme.primaryContainer
            DetectionSeverity.INFO -> MaterialTheme.colorScheme.surfaceVariant
        }
        val content = when (item.severity) {
            DetectionSeverity.DANGER -> MaterialTheme.colorScheme.onErrorContainer
            DetectionSeverity.WARNING -> MaterialTheme.colorScheme.onTertiaryContainer
            DetectionSeverity.ALL_CLEAR -> MaterialTheme.colorScheme.onPrimaryContainer
            DetectionSeverity.INFO -> MaterialTheme.colorScheme.onSurfaceVariant
        }

        Card(
            onClick = onClick,
            colors = CardDefaults.cardColors(containerColor = container),
            shape = RoundedCornerShape(16.dp),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                Text(
                    item.title,
                    fontWeight = FontWeight.SemiBold,
                    color = content,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(
                    detectorStatusLabel(item),
                    style = MaterialTheme.typography.labelMedium,
                    color = content.copy(alpha = 0.78f),
                    maxLines = 1,
                )
                Text(
                    item.verdict,
                    style = MaterialTheme.typography.bodySmall,
                    color = content.copy(alpha = 0.88f),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }

    @Composable
    private fun DetectorStatusHeader(item: DuckDetectorItem) {
        val color = when (item.severity) {
            DetectionSeverity.DANGER -> MaterialTheme.colorScheme.error
            DetectionSeverity.WARNING -> MaterialTheme.colorScheme.tertiary
            DetectionSeverity.ALL_CLEAR -> MaterialTheme.colorScheme.primary
            DetectionSeverity.INFO -> MaterialTheme.colorScheme.onSurfaceVariant
        }
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                detectorStatusLabel(item),
                color = color,
                fontWeight = FontWeight.Bold,
            )
            Text(item.verdict)
            HorizontalDivider()
        }
    }

    private fun detectorStatusLabel(item: DuckDetectorItem): String {
        return when (item.severity) {
            DetectionSeverity.DANGER -> "DANGER"
            DetectionSeverity.WARNING -> "WARNING"
            DetectionSeverity.ALL_CLEAR -> "ALL CLEAR"
            DetectionSeverity.INFO -> when (item.infoKind) {
                InfoKind.ERROR -> "INFO · ERROR"
                InfoKind.SUPPORT -> "INFO · UNSUPPORTED"
                null -> "INFO"
            }
        }
    }

    @Composable
    private fun SummaryBadge(
        modifier: Modifier,
        label: String,
        value: Int,
        color: Color,
    ) {
        Column(
            modifier = modifier
                .clip(RoundedCornerShape(14.dp))
                .background(color)
                .padding(horizontal = 8.dp, vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                value.toString(),
                fontWeight = FontWeight.Bold,
            )
            Text(
                label,
                style = MaterialTheme.typography.labelSmall,
            )
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
                supportingContent = {
                    Text(
                        summary,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                    )
                },
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
    private fun InfoLine(
        title: String,
        value: String,
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text(
                title,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                value,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
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
