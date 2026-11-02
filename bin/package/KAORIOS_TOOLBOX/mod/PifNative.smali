.class public final Landroid/security/ntmanager/PifNative;
.super Ljava/lang/Object;

.field private static final KEYS:[Ljava/lang/String;
.field private static final PROPERTIES:[Ljava/lang/String;

.method static constructor <clinit>()V
    .registers 4

    const/16 v0, 0xd
    new-array v1, v0, [Ljava/lang/String;
    new-array v2, v0, [Ljava/lang/String;

    const/4 v0, 0x0
    const-string v3, "FINGERPRINT"
    aput-object v3, v1, v0
    const-string v3, "ro.build.fingerprint"
    aput-object v3, v2, v0

    const/4 v0, 0x1
    const-string v3, "FINGERPRINT"
    aput-object v3, v1, v0
    const-string v3, "ro.system.build.fingerprint"
    aput-object v3, v2, v0

    const/4 v0, 0x2
    const-string v3, "MANUFACTURER"
    aput-object v3, v1, v0
    const-string v3, "ro.product.manufacturer"
    aput-object v3, v2, v0

    const/4 v0, 0x3
    const-string v3, "MODEL"
    aput-object v3, v1, v0
    const-string v3, "ro.product.model"
    aput-object v3, v2, v0

    const/4 v0, 0x4
    const-string v3, "BRAND"
    aput-object v3, v1, v0
    const-string v3, "ro.product.brand"
    aput-object v3, v2, v0

    const/4 v0, 0x5
    const-string v3, "PRODUCT"
    aput-object v3, v1, v0
    const-string v3, "ro.product.name"
    aput-object v3, v2, v0

    const/4 v0, 0x6
    const-string v3, "DEVICE"
    aput-object v3, v1, v0
    const-string v3, "ro.product.device"
    aput-object v3, v2, v0

    const/4 v0, 0x7
    const-string v3, "RELEASE"
    aput-object v3, v1, v0
    const-string v3, "ro.build.version.release"
    aput-object v3, v2, v0

    const/16 v0, 0x8
    const-string v3, "ID"
    aput-object v3, v1, v0
    const-string v3, "ro.build.id"
    aput-object v3, v2, v0

    const/16 v0, 0x9
    const-string v3, "INCREMENTAL"
    aput-object v3, v1, v0
    const-string v3, "ro.build.version.incremental"
    aput-object v3, v2, v0

    const/16 v0, 0xa
    const-string v3, "TAGS"
    aput-object v3, v1, v0
    const-string v3, "ro.build.tags"
    aput-object v3, v2, v0

    const/16 v0, 0xb
    const-string v3, "SECURITY_PATCH"
    aput-object v3, v1, v0
    const-string v3, "ro.build.version.security_patch"
    aput-object v3, v2, v0

    const/16 v0, 0xc
    const-string v3, "DEVICE_INITIAL_SDK_INT"
    aput-object v3, v1, v0
    const-string v3, "ro.product.first_api_level"
    aput-object v3, v2, v0

    sput-object v1, Landroid/security/ntmanager/PifNative;->KEYS:[Ljava/lang/String;
    sput-object v2, Landroid/security/ntmanager/PifNative;->PROPERTIES:[Ljava/lang/String;
    return-void
.end method

.method private static native nativeInstall([Ljava/lang/String;[Ljava/lang/String;)Z
.end method

.method public static install(Landroid/content/Context;)V
    .registers 14

    if-eqz p0, :done
    :try_start
    invoke-static {}, Landroid/app/Application;->getProcessName()Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :done

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v1
    const-string v2, "com.google.android.gms"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :done

    const-string v1, "com.google.android.gms.unstable"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :target
    const-string v1, "com.google.android.gms:unstable"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :done

    :target
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    invoke-static {v0}, Lcom/kousei/framework/KaoriosFramework;->readPifConfigString(Landroid/content/ContentResolver;)Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :missing_config

    new-instance v3, Lorg/json/JSONObject;
    invoke-direct {v3, v0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    new-instance v7, Ljava/util/ArrayList;
    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V
    new-instance v8, Ljava/util/ArrayList;
    invoke-direct {v8}, Ljava/util/ArrayList;-><init>()V
    sget-object v4, Landroid/security/ntmanager/PifNative;->KEYS:[Ljava/lang/String;
    sget-object v5, Landroid/security/ntmanager/PifNative;->PROPERTIES:[Ljava/lang/String;
    const/4 v6, 0x0

    :loop
    array-length v11, v4
    if-ge v6, v11, :install
    aget-object v9, v4, v6
    invoke-virtual {v3, v9}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v9}, Ljava/lang/String;->isEmpty()Z
    move-result v11
    if-nez v11, :next
    aget-object v10, v5, v6
    invoke-virtual {v7, v10}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    invoke-virtual {v8, v9}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :next
    add-int/lit8 v6, v6, 0x1
    goto :loop

    :install
    invoke-virtual {v7}, Ljava/util/ArrayList;->isEmpty()Z
    move-result v11
    if-nez v11, :done
    invoke-static {}, Landroid/os/Process;->is64Bit()Z
    move-result v11
    if-eqz v11, :lib32
    const-string v11, "/system/lib64/libkaoripif.so"
    goto :load
    :lib32
    const-string v11, "/system/lib/libkaoripif.so"
    :load
    invoke-static {v11}, Ljava/lang/System;->load(Ljava/lang/String;)V

    const/4 v11, 0x0
    new-array v11, v11, [Ljava/lang/String;
    invoke-virtual {v7, v11}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v11
    check-cast v11, [Ljava/lang/String;
    const/4 v12, 0x0
    new-array v12, v12, [Ljava/lang/String;
    invoke-virtual {v8, v12}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v12
    check-cast v12, [Ljava/lang/String;
    invoke-static {v11, v12}, Landroid/security/ntmanager/PifNative;->nativeInstall([Ljava/lang/String;[Ljava/lang/String;)Z
    move-result v11
    if-eqz v11, :failed
    const-string v0, "KaoriosNativePIF"
    const-string v1, "DroidGuard property hook installed"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :done

    :failed
    const-string v0, "KaoriosNativePIF"
    const-string v1, "DroidGuard property hook returned false"
    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end
    goto :done

    :missing_config
    const-string v0, "KaoriosNativePIF"
    const-string v1, "PIF JSON unavailable in GMS unstable"
    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    goto :done

    :catchall
    move-exception v0
    const-string v1, "KaoriosNativePIF"
    const-string v2, "DroidGuard property hook failed"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :done
    return-void
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :catchall
.end method
