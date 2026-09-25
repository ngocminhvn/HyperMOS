.class public final Lcom/kousei/framework/x6;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# instance fields
.field public final a:Ljava/util/Map;

.field public final b:Ljava/util/Set;

.field public final c:Lcom/kousei/framework/v6;

.field public final d:Ljava/util/Map;

.field public final e:Z

.field public final f:Z

.field public final g:Lcom/kousei/framework/ma;


# direct methods
.method public constructor <init>(Ljava/util/Map;Ljava/util/Set;Lcom/kousei/framework/v6;Ljava/util/Map;ZZLcom/kousei/framework/ma;)V
    .registers 8

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    if-eqz p1, :cond_6

    goto :goto_8

    .line 2
    :cond_6
    sget-object p1, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    :goto_8
    iput-object p1, p0, Lcom/kousei/framework/x6;->a:Ljava/util/Map;

    if-eqz p2, :cond_d

    goto :goto_f

    .line 3
    :cond_d
    sget-object p2, Ljava/util/Collections;->EMPTY_SET:Ljava/util/Set;

    :goto_f
    iput-object p2, p0, Lcom/kousei/framework/x6;->b:Ljava/util/Set;

    .line 4
    iput-object p3, p0, Lcom/kousei/framework/x6;->c:Lcom/kousei/framework/v6;

    if-eqz p4, :cond_16

    goto :goto_18

    .line 5
    :cond_16
    sget-object p4, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    :goto_18
    iput-object p4, p0, Lcom/kousei/framework/x6;->d:Ljava/util/Map;

    .line 6
    iput-boolean p5, p0, Lcom/kousei/framework/x6;->e:Z

    .line 7
    iput-boolean p6, p0, Lcom/kousei/framework/x6;->f:Z

    if-eqz p7, :cond_21

    goto :goto_23

    .line 8
    :cond_21
    sget-object p7, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    :goto_23
    iput-object p7, p0, Lcom/kousei/framework/x6;->g:Lcom/kousei/framework/ma;

    return-void
.end method
