.class public abstract synthetic Lcom/kousei/framework/y4;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# direct methods
.method public static bridge synthetic a(I)I
    .registers 1

    .line 1
    invoke-static {p0}, Landroid/os/Process;->getAppUidForSdkSandboxUid(I)I

    .line 2
    .line 3
    .line 4
    move-result p0

    .line 5
    return p0
.end method

.method public static bridge synthetic b(I)Z
    .registers 1

    .line 1
    invoke-static {p0}, Landroid/os/Process;->isSdkSandboxUid(I)Z

    .line 2
    .line 3
    .line 4
    move-result p0

    .line 5
    return p0
.end method
