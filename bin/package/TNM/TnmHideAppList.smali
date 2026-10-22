.class public final Landroid/app/TnmHideAppList;
.super Ljava/lang/Object;

# Client-side PackageManager list-visibility policy. Selected packages are VIEWERS.
# Preserve core package discovery and the caller's own package.
# Fail open on inaccessible SettingsProvider. Do not affect system UIDs.

.method private static isViewer(Landroid/content/Context;)Z
    .locals 8

    if-eqz p0, :not_selected
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v0
    const/16 v1, 0x2710
    if-lt v0, v1, :not_selected

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const-string v1, "tnm_hide_applist_enabled"
    invoke-static {v0, v1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "1"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :not_selected

    const-string v1, "projectryu_hide_applist"
    invoke-static {v0, v1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :not_selected

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v2
    if-eqz v2, :not_selected

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, ","
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v7
    :try_end_0
    return v7

    :catch_0
    move-exception v0
    goto :not_selected
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :not_selected
    const/4 v0, 0x0
    return v0
.end method

.method public static shouldHide(Landroid/content/Context;Ljava/lang/String;)Z
    .locals 3

    if-eqz p0, :visible
    if-eqz p1, :visible
    invoke-static {p0}, Landroid/app/TnmHideAppList;->isViewer(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :visible

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :visible

    # Core Android framework/services must remain discoverable to client apps.
    const-string v1, "android"
    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :visible
    const-string v1, "com.android."
    invoke-virtual {p1, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :visible

    const/4 v0, 0x1
    return v0

    :visible
    const/4 v0, 0x0
    return v0
.end method

.method public static filterApplicationInfoList(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;
    .locals 5

    if-eqz p1, :unchanged_apps
    invoke-static {p0}, Landroid/app/TnmHideAppList;->isViewer(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :unchanged_apps

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v1

    :app_loop
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    if-eqz v2, :apps_done
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/content/pm/ApplicationInfo;
    if-eqz v2, :app_loop
    iget-object v3, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;
    invoke-static {p0, v3}, Landroid/app/TnmHideAppList;->shouldHide(Landroid/content/Context;Ljava/lang/String;)Z
    move-result v4
    if-nez v4, :app_loop
    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    goto :app_loop

    :apps_done
    return-object v0
    :unchanged_apps
    return-object p1
.end method

.method public static filterPackageInfoList(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;
    .locals 5

    if-eqz p1, :unchanged_packages
    invoke-static {p0}, Landroid/app/TnmHideAppList;->isViewer(Landroid/content/Context;)Z
    move-result v0
    if-eqz v0, :unchanged_packages

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v1

    :package_loop
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    if-eqz v2, :packages_done
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/content/pm/PackageInfo;
    if-eqz v2, :package_loop
    iget-object v3, v2, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;
    invoke-static {p0, v3}, Landroid/app/TnmHideAppList;->shouldHide(Landroid/content/Context;Ljava/lang/String;)Z
    move-result v4
    if-nez v4, :package_loop
    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    goto :package_loop

    :packages_done
    return-object v0
    :unchanged_packages
    return-object p1
.end method
