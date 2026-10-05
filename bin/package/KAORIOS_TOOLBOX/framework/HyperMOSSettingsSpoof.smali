.class public final Landroid/security/kaorios/HyperMOSSettingsSpoof;
.super Ljava/lang/Object;

# Caller-side bridge. Never modify the SettingsProvider APK for this backend.
# NameValueCache covers normal Settings.* getters; getOverrideForCall also
# covers direct ContentResolver.call("settings", ...) runtime probes.
.field private static final sActive:Ljava/lang/ThreadLocal;

.method public static getOverrideForCall(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
    .locals 2

    :call_start
    # Keep this shim limited to the Android Settings provider.
    const-string v0, "settings"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :stock

    # Reuse the same UID/Binder/recursion guards as ordinary Settings.* reads.
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v0
    const v1, 0x186a0
    div-int v0, v0, v1
    # SettingsProvider uses extras["_user"], defaulting to the Binder user.
    # Do not intercept cross-user requests before stock permission checks.
    if-eqz p3, :same_user
    const-string v1, "_user"
    invoke-virtual {p3, v1, v0}, Landroid/os/BaseBundle;->getInt(Ljava/lang/String;I)I
    move-result v1
    if-ne v1, v0, :stock
    :same_user
    invoke-static {p1, p2, v0}, Landroid/security/kaorios/HyperMOSSettingsSpoof;->getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;
    move-result-object v0
    :call_end
    .catchall {:call_start .. :call_end} :call_error
    return-object v0

    :call_error
    move-exception v0
    :stock
    const/4 v0, 0x0
    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 1
    new-instance v0, Ljava/lang/ThreadLocal;
    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V
    sput-object v0, Landroid/security/kaorios/HyperMOSSettingsSpoof;->sActive:Ljava/lang/ThreadLocal;
    return-void
.end method

.method public static getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;
    .locals 4

    :try_start
    # Restrict this hook to ordinary application UIDs reading their own user.
    # System processes and foreign Binder identities always read stock values.
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v0
    const v1, 0x186a0
    rem-int v2, v0, v1
    const/16 v3, 0x2710
    if-lt v2, v3, :stock
    const/16 v3, 0x4e1f
    if-gt v2, v3, :stock
    div-int v2, v0, v1
    if-ne p2, v2, :stock
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I
    move-result v1
    if-ne v0, v1, :stock

    sget-object v3, Landroid/security/kaorios/HyperMOSSettingsSpoof;->sActive:Ljava/lang/ThreadLocal;
    invoke-virtual {v3}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;
    move-result-object v0
    if-nez v0, :stock
    :try_end
    .catchall {:try_start .. :try_end} :unavailable

    :policy_start
    # Include activation in cleanup protection: ThreadLocal.set can throw.
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;
    invoke-virtual {v3, v0}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V
    invoke-static {p0, p1}, Landroid/security/kaorios/KaoriosHook;->filterSettingsCall(Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;
    move-result-object v0
    :policy_end
    .catchall {:policy_start .. :policy_end} :policy_error
    invoke-virtual {v3}, Ljava/lang/ThreadLocal;->remove()V
    return-object v0

    :policy_error
    move-exception v0
    invoke-virtual {v3}, Ljava/lang/ThreadLocal;->remove()V
    goto :stock

    :unavailable
    move-exception v0
    :stock
    const/4 v0, 0x0
    return-object v0
.end method
