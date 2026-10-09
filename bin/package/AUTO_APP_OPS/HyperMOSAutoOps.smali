.class public final Lcom/android/server/pm/HyperMOSAutoOps;
.super Ljava/lang/Object;
.source "HyperMOSAutoOps.java"

# Only invoked from BroadcastHelper's NEW-user install callback.
# MIUI 10020, 10021 and 10017 are 0x2724, 0x2725 and 0x2721.

.method public static apply(Landroid/content/Context;Ljava/lang/String;I[I)V
    .locals 4

    if-eqz p0, :done
    if-eqz p1, :done
    if-eqz p3, :done

    const-string v0, "appops"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    instance-of v1, v0, Landroid/app/AppOpsManager;
    if-eqz v1, :done
    check-cast v0, Landroid/app/AppOpsManager;

    const/4 v1, 0x0
    :loop
    array-length v2, p3
    if-ge v1, v2, :done
    aget v2, p3, v1
    invoke-static {v2, p2}, Landroid/os/UserHandle;->getUid(II)I
    move-result v2

    const/16 v3, 0x2724
    invoke-static {v0, v3, v2, p1}, Lcom/android/server/pm/HyperMOSAutoOps;->trySet(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v3, 0x2725
    invoke-static {v0, v3, v2, p1}, Lcom/android/server/pm/HyperMOSAutoOps;->trySet(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v3, 0x2721
    invoke-static {v0, v3, v2, p1}, Lcom/android/server/pm/HyperMOSAutoOps;->trySet(Landroid/app/AppOpsManager;IILjava/lang/String;)V

    add-int/lit8 v1, v1, 0x1
    goto :loop
    :done
    return-void
.end method

.method private static trySet(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    .locals 3

    :try_start
    const/4 v0, 0x0
    invoke-virtual {p0, p1, p2, p3, v0}, Landroid/app/AppOpsManager;->setMode(IILjava/lang/String;I)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :failed
    return-void

    :failed
    move-exception v0
    const-string v1, "HyperMOSAutoOps"
    const-string v2, "Xiaomi AppOp rejected; leaving stock policy"
    invoke-static {v1, v2, v0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method
