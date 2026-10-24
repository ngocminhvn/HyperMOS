.class public final Landroid/app/TnmAppPrivacy;
.super Ljava/lang/Object;

# TNM package visibility policy for Android 16 ApplicationPackageManager.
# Configuration is fail-open, versioned and committed with an even generation.
# Per-process cache: generation changes invalidate settings; caller UID is fixed in-process.
.field private static volatile sHiddenGeneration:I = -0x1
.field private static volatile sHiddenList:Ljava/lang/String;
.field private static volatile sCallerUid:I = -0x1
.field private static volatile sCallerPackages:[Ljava/lang/String;

.method private static protectedPackage(Ljava/lang/String;)Z
    .locals 2
    if-eqz p0, :protected
    const-string v0, "android"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.systemui"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.providers.settings"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.trinhngocminh"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.packageinstaller"
    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.google.android.packageinstaller"
    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.permissioncontroller"
    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.google.android.permissioncontroller"
    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.miui.home"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.miui.securitycenter"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.android.launcher3"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const-string v0, "com.google.android.apps.nexuslauncher"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :protected
    const/4 v0, 0x0
    return v0
    :protected
    const/4 v0, 0x1
    return v0
.end method

.method private static callerPackages()[Ljava/lang/String;
    .locals 5
    const/4 v0, 0x0
    :try_start
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v4
    move v1, v4
    const v2, 0x186a0
    rem-int/2addr v1, v2
    const/16 v2, 0x2710
    if-lt v1, v2, :fail
    # No Binder call for a caller already validated in this process.
    sget v2, Landroid/app/TnmAppPrivacy;->sCallerUid:I
    if-ne v4, v2, :lookup
    sget-object v0, Landroid/app/TnmAppPrivacy;->sCallerPackages:[Ljava/lang/String;
    if-eqz v0, :lookup
    return-object v0
    :lookup
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;
    move-result-object v2
    if-eqz v2, :fail
    invoke-interface {v2, v4}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :fail
    array-length v1, v0
    if-eqz v1, :fail
    const/4 v1, 0x0
    :loop
    array-length v2, v0
    if-ge v1, v2, :ok
    aget-object v2, v0, v1
    invoke-static {v2}, Landroid/app/TnmAppPrivacy;->protectedPackage(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :fail
    add-int/lit8 v1, v1, 0x1
    goto :loop
    :ok
    sput-object v0, Landroid/app/TnmAppPrivacy;->sCallerPackages:[Ljava/lang/String;
    sput v4, Landroid/app/TnmAppPrivacy;->sCallerUid:I
    return-object v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :caught
    :caught
    move-exception v1
    :fail
    const/4 v0, 0x0
    return-object v0
.end method

.method private static hiddenList(Landroid/content/Context;)Ljava/lang/String;
    .locals 6
    const/4 v0, 0x0
    if-eqz p0, :fail
    :try_start
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    const-string v2, "tnm_privacy_generation"
    const/4 v3, -0x1
    invoke-static {v1, v2, v3}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v3
    if-ltz v3, :fail
    and-int/lit8 v4, v3, 0x1
    if-nez v4, :fail
    # One Settings generation read on cached active-policy calls.
    sget v4, Landroid/app/TnmAppPrivacy;->sHiddenGeneration:I
    if-ne v3, v4, :reload
    sget-object v0, Landroid/app/TnmAppPrivacy;->sHiddenList:Ljava/lang/String;
    return-object v0
    :reload
    const-string v4, "tnm_privacy_schema"
    const/4 v5, 0x0
    invoke-static {v1, v4, v5}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v4
    const/4 v5, 0x1
    if-ne v4, v5, :fail
    const-string v4, "tnm_privacy_enabled"
    const/4 v5, 0x0
    invoke-static {v1, v4, v5}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v4
    const/4 v5, 0x1
    if-ne v4, v5, :fail
    const-string v4, "tnm_privacy_hidden_packages"
    invoke-static {v1, v4}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    if-eqz v4, :fail
    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z
    move-result v5
    if-nez v5, :fail
    const/4 v5, -0x1
    invoke-static {v1, v2, v5}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v1
    if-ne v3, v1, :fail
    sput-object v4, Landroid/app/TnmAppPrivacy;->sHiddenList:Ljava/lang/String;
    sput v3, Landroid/app/TnmAppPrivacy;->sHiddenGeneration:I
    return-object v4
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :caught
    :caught
    move-exception v1
    :fail
    return-object v0
.end method

.method private static listed(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
    .locals 5
    const/4 v0, 0x0
    if-eqz p0, :visible
    if-eqz p1, :visible
    if-eqz p2, :visible
    invoke-static {p0}, Landroid/app/TnmAppPrivacy;->protectedPackage(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :visible
    const/4 v1, 0x0
    :self_loop
    array-length v2, p2
    if-ge v1, v2, :membership
    aget-object v2, p2, v1
    invoke-virtual {p0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :visible
    add-int/lit8 v1, v1, 0x1
    goto :self_loop
    :membership
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, ","
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v1, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v4
    return v4
    :visible
    return v0
.end method

.method public static shouldHide(Landroid/content/Context;Ljava/lang/String;)Z
    .locals 2
    invoke-static {p0}, Landroid/app/TnmAppPrivacy;->hiddenList(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :unchanged
    invoke-static {}, Landroid/app/TnmAppPrivacy;->callerPackages()[Ljava/lang/String;
    move-result-object v0
    invoke-static {p1, v1, v0}, Landroid/app/TnmAppPrivacy;->listed(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
    move-result v0
    return v0
    :unchanged
    const/4 v0, 0x0
    return v0
.end method

.method public static filterApplicationInfoList(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;
    .locals 6
    if-eqz p1, :unchanged
    invoke-static {p0}, Landroid/app/TnmAppPrivacy;->hiddenList(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :unchanged
    invoke-static {}, Landroid/app/TnmAppPrivacy;->callerPackages()[Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :unchanged
    new-instance v2, Ljava/util/ArrayList;
    invoke-interface {p1}, Ljava/util/List;->size()I
    move-result v3
    invoke-direct {v2, v3}, Ljava/util/ArrayList;-><init>(I)V
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v3
    :loop
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z
    move-result v4
    if-eqz v4, :done
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/content/pm/ApplicationInfo;
    if-eqz v4, :loop
    iget-object v5, v4, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;
    invoke-static {v5, v1, v0}, Landroid/app/TnmAppPrivacy;->listed(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
    move-result v5
    if-nez v5, :loop
    invoke-interface {v2, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    goto :loop
    :done
    return-object v2
    :unchanged
    return-object p1
.end method

.method public static filterPackageInfoList(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;
    .locals 6
    if-eqz p1, :unchanged
    invoke-static {p0}, Landroid/app/TnmAppPrivacy;->hiddenList(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :unchanged
    invoke-static {}, Landroid/app/TnmAppPrivacy;->callerPackages()[Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :unchanged
    new-instance v2, Ljava/util/ArrayList;
    invoke-interface {p1}, Ljava/util/List;->size()I
    move-result v3
    invoke-direct {v2, v3}, Ljava/util/ArrayList;-><init>(I)V
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v3
    :loop
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z
    move-result v4
    if-eqz v4, :done
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/content/pm/PackageInfo;
    if-eqz v4, :loop
    iget-object v5, v4, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;
    invoke-static {v5, v1, v0}, Landroid/app/TnmAppPrivacy;->listed(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
    move-result v5
    if-nez v5, :loop
    invoke-interface {v2, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    goto :loop
    :done
    return-object v2
    :unchanged
    return-object p1
.end method
