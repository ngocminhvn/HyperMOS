.class public final Lcom/hypermos/hyperchanger/HyperChanger$Loop;
.super Landroid/content/BroadcastReceiver;
.implements Ljava/lang/Runnable;
.implements Landroid/view/View$OnAttachStateChangeListener;

.field private final mView:Landroid/widget/TextView;
.field private mRegistered:Z

.method public constructor <init>(Landroid/widget/TextView;)V
    .locals 1

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V
    iput-object p1, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {p1, p0}, Landroid/widget/TextView;->addOnAttachStateChangeListener(Landroid/view/View$OnAttachStateChangeListener;)V
    invoke-virtual {p1}, Landroid/widget/TextView;->isAttachedToWindow()Z
    move-result v0
    if-eqz v0, :done
    invoke-virtual {p0, p1}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->onViewAttachedToWindow(Landroid/view/View;)V
    :done
    return-void
.end method

.method private start()V
    .locals 1

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->isAttachedToWindow()Z
    move-result v0
    if-eqz v0, :done

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0, p0}, Landroid/widget/TextView;->removeCallbacks(Ljava/lang/Runnable;)Z
    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0, p0}, Landroid/widget/TextView;->post(Ljava/lang/Runnable;)Z
    :done
    return-void
.end method

.method private stop()V
    .locals 1

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0, p0}, Landroid/widget/TextView;->removeCallbacks(Ljava/lang/Runnable;)Z
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
    goto :done

    :restart
    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->start()V
    :done
    return-void
.end method

.method public onViewAttachedToWindow(Landroid/view/View;)V
    .locals 4

    iget-boolean v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mRegistered:Z
    if-nez v0, :resume

    :try_start_0
    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getContext()Landroid/content/Context;
    move-result-object v0
    new-instance v1, Landroid/content/IntentFilter;
    invoke-direct {v1}, Landroid/content/IntentFilter;-><init>()V
    const-string v2, "android.intent.action.SCREEN_ON"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const-string v2, "android.intent.action.SCREEN_OFF"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const-string v2, "android.intent.action.BATTERY_CHANGED"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const/4 v2, 0x4
    invoke-virtual {v0, p0, v1, v2}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;
    const/4 v2, 0x1
    iput-boolean v2, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mRegistered:Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    goto :resume

    :catch_0
    move-exception v0

    :resume
    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->start()V
    return-void
.end method

.method public onViewDetachedFromWindow(Landroid/view/View;)V
    .locals 2

    invoke-direct {p0}, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->stop()V
    iget-boolean v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mRegistered:Z
    if-eqz v0, :done
    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mRegistered:Z
    :try_start_0
    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0, p0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0
    goto :done

    :catch_0
    move-exception v0

    :done
    return-void
.end method

.method public run()V
    .locals 6

    iget-object v0, p0, Lcom/hypermos/hyperchanger/HyperChanger$Loop;->mView:Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->isShown()Z
    move-result v1
    if-eqz v1, :done

    invoke-virtual {v0}, Landroid/widget/TextView;->getContext()Landroid/content/Context;
    move-result-object v1
    invoke-static {v1}, Lcom/hypermos/hyperchanger/HyperChanger;->awake(Landroid/content/Context;)Z
    move-result v2
    if-eqz v2, :done
    invoke-static {v1}, Lcom/hypermos/hyperchanger/HyperChanger;->enabled(Landroid/content/Context;)Z
    move-result v2
    if-eqz v2, :done
    invoke-static {v1}, Lcom/hypermos/hyperchanger/HyperChanger;->charging(Landroid/content/Context;)Z
    move-result v2
    if-eqz v2, :done

    invoke-static {v0}, Lcom/hypermos/hyperchanger/HyperChanger;->refresh(Landroid/widget/TextView;)V

    const-string v2, "hyperchanger_update_mode"
    const/4 v3, 0x1
    invoke-static {v1, v2, v3}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v2
    if-ne v2, v3, :done

    const-string v2, "hyperchanger_update_interval"
    const/4 v3, 0x5
    invoke-static {v1, v2, v3}, Lcom/hypermos/hyperchanger/HyperChanger;->setting(Landroid/content/Context;Ljava/lang/String;I)I
    move-result v2
    if-lez v2, :default_interval
    const/16 v3, 0xa
    if-le v2, v3, :interval_ok
    :default_interval
    const/4 v2, 0x5
    :interval_ok

    const/16 v3, 0x3e8
    mul-int/2addr v2, v3
    int-to-long v2, v2
    invoke-virtual {v0, p0, v2, v3}, Landroid/widget/TextView;->postDelayed(Ljava/lang/Runnable;J)Z

    :done
    return-void
.end method
