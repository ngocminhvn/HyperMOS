.class public final Lcom/hypermos/hyperchanger/HyperChanger;
.super Ljava/lang/Object;

.field private static sBase:Ljava/lang/String;
.field private static sDisplayed:Ljava/lang/String;
.field private static sOnceMetrics:Ljava/lang/String;
.field private static sOnceValid:Z

.method public static setting(Landroid/content/Context;Ljava/lang/String;I)I
    .locals 1

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    invoke-static {v0, p1, p2}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v0
    return v0
.end method

.method public static enabled(Landroid/content/Context;)Z
    .locals 2

    const-string v0, "hyperchanger_enabled"
    const/4 v1, 0x0
    invoke-static {p0, v0, v1}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v0
    const/4 v1, 0x1
    if-ne v0, v1, :disabled
    return v1
    :disabled
    const/4 v0, 0x0
    return v0
.end method

.method public static awake(Landroid/content/Context;)Z
    .locals 2

    const-string v0, "power"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/os/PowerManager;
    if-eqz v0, :no
    invoke-virtual {v0}, Landroid/os/PowerManager;->isInteractive()Z
    move-result v0
    if-eqz v0, :no

    const-string v0, "keyguard"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/KeyguardManager;
    if-eqz v0, :no
    invoke-virtual {v0}, Landroid/app/KeyguardManager;->isKeyguardLocked()Z
    move-result v0
    return v0

    :no
    const/4 v0, 0x0
    return v0
.end method

.method private static battery(Landroid/content/Context;)Landroid/content/Intent;
    .locals 2

    new-instance v0, Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.BATTERY_CHANGED"
    invoke-direct {v0, v1}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V
    const/4 v1, 0x0
    invoke-virtual {p0, v1, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;
    move-result-object v0
    return-object v0
.end method

.method public static charging(Landroid/content/Context;)Z
    .locals 4

    invoke-static {p0}, Lcom/hypermos/hyperchanger/HyperChanger;->battery(Landroid/content/Context;)Landroid/content/Intent;
    move-result-object v0
    if-eqz v0, :no

    const-string v1, "plugged"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I
    move-result v1
    if-lez v1, :no

    const-string v1, "status"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I
    move-result v1
    const/4 v3, 0x2
    if-eq v1, v3, :yes
    const/4 v3, 0x5
    if-eq v1, v3, :yes

    :no
    const/4 v0, 0x0
    return v0
    :yes
    const/4 v0, 0x1
    return v0
.end method

.method private static one(D)Ljava/lang/String;
    .locals 4

    const-string v0, "%.1f"
    const/4 v1, 0x1
    new-array v1, v1, [Ljava/lang/Object;
    invoke-static {p0, p1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;
    move-result-object v2
    const/4 v3, 0x0
    aput-object v2, v1, v3
    sget-object v2, Ljava/util/Locale;->US:Ljava/util/Locale;
    invoke-static {v2, v0, v1}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static add(Ljava/lang/StringBuilder;DLjava/lang/String;)V
    .locals 2

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->length()I
    move-result v0
    if-lez v0, :first
    const-string v0, " · "
    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :first
    invoke-static {p1, p2}, Lcom/hypermos/hyperchanger/HyperChanger;->one(D)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    return-void
.end method

.method private static metrics(Landroid/content/Context;)Ljava/lang/String;
    .locals 16

    # p0 aliases v16 in this method; use a low register for invoke-35c.
    move-object/from16 v13, p0

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "batterymanager"
    invoke-virtual {v13, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/os/BatteryManager;
    const v14, -0x80000000
    if-eqz v1, :no_current
    const/4 v2, 0x2
    invoke-virtual {v1, v2}, Landroid/os/BatteryManager;->getIntProperty(I)I
    move-result v14
    :no_current

    invoke-static {v13}, Lcom/hypermos/hyperchanger/HyperChanger;->battery(Landroid/content/Context;)Landroid/content/Intent;
    move-result-object v2
    if-eqz v2, :done

    const-string v3, "voltage"
    const/4 v4, 0x0
    invoke-virtual {v2, v3, v4}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I
    move-result v3

    const-string v4, "temperature"
    const/4 v15, 0x0
    invoke-virtual {v2, v4, v15}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I
    move-result v4

    const v12, -0x80000000
    if-eq v14, v12, :voltage_check
    if-lez v3, :ampere_check

    const-string v9, "hyperchanger_show_power"
    const/4 v10, 0x1
    invoke-static {v13, v9, v10}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v9
    if-eqz v9, :ampere_check

    int-to-double v5, v14
    invoke-static {v5, v6}, Ljava/lang/Math;->abs(D)D
    move-result-wide v5
    int-to-double v7, v3
    mul-double/2addr v5, v7
    const v12, 0x3b9aca00
    int-to-double v7, v12
    div-double/2addr v5, v7
    const-string v11, " W"
    invoke-static {v0, v5, v6, v11}, Lcom/hypermos/hyperchanger/HyperChanger;->add(Ljava/lang/StringBuilder;DLjava/lang/String;)V

    :ampere_check
    const-string v9, "hyperchanger_show_ampere"
    const/4 v10, 0x1
    invoke-static {v13, v9, v10}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v9
    if-eqz v9, :voltage_check
    int-to-double v5, v14
    invoke-static {v5, v6}, Ljava/lang/Math;->abs(D)D
    move-result-wide v5
    const v12, 0xf4240
    int-to-double v7, v12
    div-double/2addr v5, v7
    const-string v11, " A"
    invoke-static {v0, v5, v6, v11}, Lcom/hypermos/hyperchanger/HyperChanger;->add(Ljava/lang/StringBuilder;DLjava/lang/String;)V

    :voltage_check
    if-lez v3, :temp_check
    const-string v9, "hyperchanger_show_voltage"
    const/4 v10, 0x0
    invoke-static {v13, v9, v10}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v9
    if-eqz v9, :temp_check
    int-to-double v5, v3
    const/16 v12, 0x3e8
    int-to-double v7, v12
    div-double/2addr v5, v7
    const-string v11, " V"
    invoke-static {v0, v5, v6, v11}, Lcom/hypermos/hyperchanger/HyperChanger;->add(Ljava/lang/StringBuilder;DLjava/lang/String;)V

    :temp_check
    if-lez v4, :done
    const-string v9, "hyperchanger_show_temp"
    const/4 v10, 0x1
    invoke-static {v13, v9, v10}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v9
    if-eqz v9, :done
    int-to-double v5, v4
    const/16 v12, 0xa
    int-to-double v7, v12
    div-double/2addr v5, v7
    const-string v11, " °C"
    invoke-static {v0, v5, v6, v11}, Lcom/hypermos/hyperchanger/HyperChanger;->add(Ljava/lang/StringBuilder;DLjava/lang/String;)V

    :done
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public static render(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
    .locals 4

    sput-object p1, Lcom/hypermos/hyperchanger/HyperChanger;->sBase:Ljava/lang/String;
    if-eqz p1, :original
    invoke-static {p0}, Lcom/hypermos/hyperchanger/HyperChanger;->enabled(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :original
    invoke-static {p0}, Lcom/hypermos/hyperchanger/HyperChanger;->awake(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :original
    invoke-static {p0}, Lcom/hypermos/hyperchanger/HyperChanger;->charging(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :original

    const-string v1, "hyperchanger_update_mode"
    const/4 v2, 0x1
    invoke-static {p0, v1, v2}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v1
    if-nez v1, :sample
    sget-boolean v2, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceValid:Z
    if-eqz v2, :sample
    sget-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceMetrics:Ljava/lang/String;
    if-eqz v0, :sample
    goto :metrics_ready

    :sample
    invoke-static {p0}, Lcom/hypermos/hyperchanger/HyperChanger;->metrics(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v0
    if-nez v1, :metrics_ready
    sput-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceMetrics:Ljava/lang/String;
    const/4 v2, 0x1
    sput-boolean v2, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceValid:Z

    :metrics_ready
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-lez v1, :original

    const-string v1, "hyperchanger_hide_original_text"
    const/4 v2, 0x0
    invoke-static {p0, v1, v2}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v1
    if-eqz v1, :include_original
    sput-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sDisplayed:Ljava/lang/String;
    return-object v0

    :include_original
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1, p1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    const-string v2, "\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sDisplayed:Ljava/lang/String;
    return-object v0

    :original
    invoke-static {}, Lcom/hypermos/hyperchanger/HyperChanger;->resetOnce()V
    sput-object p1, Lcom/hypermos/hyperchanger/HyperChanger;->sDisplayed:Ljava/lang/String;
    return-object p1
.end method

.method public static refresh(Landroid/widget/TextView;)V
    .locals 5

    sget-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sBase:Ljava/lang/String;
    if-eqz v0, :done
    invoke-virtual {p0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :match
    sget-object v2, Lcom/hypermos/hyperchanger/HyperChanger;->sDisplayed:Ljava/lang/String;
    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :done

    :match
    invoke-virtual {p0}, Landroid/widget/TextView;->getContext()Landroid/content/Context;
    move-result-object v2
    invoke-static {v2, v0}, Lcom/hypermos/hyperchanger/HyperChanger;->render(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :size
    invoke-virtual {p0, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :size
    invoke-static {v2}, Lcom/hypermos/hyperchanger/HyperChanger;->enabled(Landroid/content/Context;)Z
    move-result v4
    if-eqz v4, :done
    const-string v0, "hyperchanger_text_size"
    const/16 v1, 0xc
    invoke-static {v2, v0, v1}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v1
    const/16 v0, 0x8
    if-ge v1, v0, :min_ok
    move v1, v0
    :min_ok
    const/16 v0, 0x14
    if-le v1, v0, :max_ok
    move v1, v0
    :max_ok
    int-to-float v0, v1
    invoke-virtual {p0, v0}, Landroid/widget/TextView;->setTextSize(F)V

    :done
    return-void
.end method

.method public static bind(Landroid/widget/TextView;)V
    .locals 1

    new-instance v0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;
    invoke-direct {v0, p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;-><init>(Landroid/widget/TextView;)V
    return-void
.end method

.method public static resetOnce()V
    .locals 1

    const/4 v0, 0x0
    sput-boolean v0, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceValid:Z
    sput-object v0, Lcom/hypermos/hyperchanger/HyperChanger;->sOnceMetrics:Ljava/lang/String;
    return-void
.end method
