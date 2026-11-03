.class public final Lcom/hypermos/hyperchanger/HyperChanger$Loop;
.super Landroid/content/BroadcastReceiver;
.implements Ljava/lang/Runnable;

.field private final mContext:Landroid/content/Context;
.field private final mController:Lcom/android/systemui/statusbar/KeyguardIndicationController;
.field private final mHandler:Landroid/os/Handler;
.field private mRegistered:Z

.method public constructor <init>(Landroid/content/Context;Lcom/android/systemui/statusbar/KeyguardIndicationController;)V
    .locals 4

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object v0
    if-eqz v0, :context_ready
    move-object p1, v0
    :context_ready
    iput-object p1, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mController:Lcom/android/systemui/statusbar/KeyguardIndicationController;

    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mHandler:Landroid/os/Handler;

    :try_start_0
    new-instance v1, Landroid/content/IntentFilter;
    invoke-direct {v1}, Landroid/content/IntentFilter;-><init>()V
    const-string v2, "android.intent.action.SCREEN_ON"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const-string v2, "android.intent.action.SCREEN_OFF"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const-string v2, "android.intent.action.BATTERY_CHANGED"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const/4 v2, 0x4
    invoke-virtual {p1, p0, v1, v2}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;
    const/4 v3, 0x1
    iput-boolean v3, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mRegistered:Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    goto :registered

    :catch_0
    move-exception v1

    :registered
    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->start()V
    return-void
.end method

.method private start()V
    .locals 1

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mHandler:Landroid/os/Handler;
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    return-void
.end method

.method private stop()V
    .locals 1

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mHandler:Landroid/os/Handler;
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 2

    if-eqz p2, :done
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "android.intent.action.SCREEN_OFF"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :restart
    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->stop()V
    invoke-static {}, Lcom/hypermos/hyperchanger/HyperChanger;->resetOnce()V
    goto :done

    :restart
    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->start()V
    :done
    return-void
.end method

.method public run()V
    .locals 7

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mController:Lcom/android/systemui/statusbar/KeyguardIndicationController;
    iget-object v0, v0, Lcom/android/systemui/statusbar/KeyguardIndicationController;->mLockScreenIndicationView:Lcom/android/systemui/statusbar/phone/KeyguardIndicationTextView;

    iget-object v1, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mContext:Landroid/content/Context;
    invoke-static {v1}, Lcom/hypermos/hyperchanger/HyperChanger;->awake(Landroid/content/Context;)Z
    move-result v2
    if-eqz v2, :schedule
    if-eqz v0, :schedule

    # Refresh also restores the stock text when TNM disables the feature or
    # charging ends. The renderer itself avoids battery sampling in that case.
    invoke-static {v0}, Lcom/hypermos/hyperchanger/HyperChanger;->refresh(Landroid/widget/TextView;)V

    :schedule
    const/4 v2, 0x5
    invoke-static {v1}, Lcom/hypermos/hyperchanger/HyperChanger;->enabled(Landroid/content/Context;)Z
    move-result v3
    if-eqz v3, :delay_ready

    const-string v3, "hyperchanger_update_mode"
    const/4 v4, 0x1
    invoke-static {v1, v3, v4}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v3
    if-ne v3, v4, :delay_ready

    const-string v3, "hyperchanger_update_interval"
    invoke-static {v1, v3, v2}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v2
    if-lez v2, :default_delay
    const/16 v3, 0xa
    if-le v2, v3, :delay_ready
    :default_delay
    const/4 v2, 0x5

    :delay_ready
    const/16 v3, 0x3e8
    mul-int/2addr v2, v3
    int-to-long v2, v2
    iget-object v4, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mHandler:Landroid/os/Handler;
    invoke-virtual {v4, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    return-void
.end method

