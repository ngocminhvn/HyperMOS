.class public final Lcom/kousei/framework/y5;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# instance fields
.field public final a:J

.field public final b:J

.field public final c:Ljava/util/Map;


# direct methods
.method public constructor <init>(JJLjava/util/Map;)V
    .registers 6

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-wide p1, p0, Lcom/kousei/framework/y5;->a:J

    .line 5
    .line 6
    iput-wide p3, p0, Lcom/kousei/framework/y5;->b:J

    .line 7
    .line 8
    if-eqz p5, :cond_a

    .line 9
    .line 10
    goto :goto_c

    .line 11
    :cond_a
    sget-object p5, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 12
    .line 13
    :goto_c
    iput-object p5, p0, Lcom/kousei/framework/y5;->c:Ljava/util/Map;

    .line 14
    .line 15
    return-void
.end method
