.class public final Lcom/kousei/framework/l1;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# instance fields
.field public final a:Ljava/security/KeyPair;

.field public final b:Lcom/kousei/framework/va;

.field public final c:J


# direct methods
.method public constructor <init>(Ljava/security/KeyPair;Lcom/kousei/framework/va;)V
    .registers 3

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-object p1, p0, Lcom/kousei/framework/l1;->a:Ljava/security/KeyPair;

    .line 5
    .line 6
    iput-object p2, p0, Lcom/kousei/framework/l1;->b:Lcom/kousei/framework/va;

    .line 7
    .line 8
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 9
    .line 10
    .line 11
    move-result-wide p1

    .line 12
    iput-wide p1, p0, Lcom/kousei/framework/l1;->c:J

    .line 13
    .line 14
    return-void
.end method
