.class public abstract Lcom/kousei/framework/e6;
.super Ljava/io/InputStream;


# instance fields
.field public final a:Ljava/io/InputStream;

.field public final b:I


# direct methods
.method public constructor <init>(Ljava/io/InputStream;I)V
    .registers 3

    .line 1
    invoke-direct {p0}, Ljava/io/InputStream;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-object p1, p0, Lcom/kousei/framework/e6;->a:Ljava/io/InputStream;

    .line 5
    .line 6
    iput p2, p0, Lcom/kousei/framework/e6;->b:I

    .line 7
    .line 8
    return-void
.end method


# virtual methods
.method public final a()V
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/e6;->a:Ljava/io/InputStream;

    .line 2
    .line 3
    instance-of v0, p0, Lcom/kousei/framework/i5;

    .line 4
    .line 5
    if-eqz v0, :cond_e

    .line 6
    .line 7
    check-cast p0, Lcom/kousei/framework/i5;

    .line 8
    .line 9
    const/4 v0, 0x1

    .line 10
    iput-boolean v0, p0, Lcom/kousei/framework/i5;->f:Z

    .line 11
    .line 12
    invoke-virtual {p0}, Lcom/kousei/framework/i5;->b()Z

    .line 13
    .line 14
    .line 15
    :cond_e
    return-void
.end method
