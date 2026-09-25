.class public final Lcom/kousei/framework/ta;
.super Lcom/kousei/framework/r;


# instance fields
.field public final a:Lcom/kousei/framework/qa;

.field public final b:Lcom/kousei/framework/qa;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/c0;)V
    .registers 4

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->size()I

    .line 5
    .line 6
    .line 7
    move-result v0

    .line 8
    const/4 v1, 0x2

    .line 9
    if-ne v0, v1, :cond_21

    .line 10
    .line 11
    const/4 v0, 0x0

    .line 12
    invoke-virtual {p1, v0}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 13
    .line 14
    .line 15
    move-result-object v0

    .line 16
    invoke-static {v0}, Lcom/kousei/framework/qa;->j(Lcom/kousei/framework/j;)Lcom/kousei/framework/qa;

    .line 17
    .line 18
    .line 19
    move-result-object v0

    .line 20
    iput-object v0, p0, Lcom/kousei/framework/ta;->a:Lcom/kousei/framework/qa;

    .line 21
    .line 22
    const/4 v0, 0x1

    .line 23
    invoke-virtual {p1, v0}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 24
    .line 25
    .line 26
    move-result-object p1

    .line 27
    invoke-static {p1}, Lcom/kousei/framework/qa;->j(Lcom/kousei/framework/j;)Lcom/kousei/framework/qa;

    .line 28
    .line 29
    .line 30
    move-result-object p1

    .line 31
    iput-object p1, p0, Lcom/kousei/framework/ta;->b:Lcom/kousei/framework/qa;

    .line 32
    .line 33
    return-void

    .line 34
    :cond_21
    const-string p0, "Bad sequence size: "

    .line 35
    .line 36
    invoke-static {v0, p0}, Lcom/kousei/framework/e;->c(ILjava/lang/String;)V

    .line 37
    .line 38
    .line 39
    const/4 p0, 0x0

    .line 40
    throw p0
.end method

.method public constructor <init>(Lcom/kousei/framework/qa;Lcom/kousei/framework/qa;)V
    .registers 4

    .line 41
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    if-eqz p1, :cond_13

    if-eqz p2, :cond_d

    .line 42
    iput-object p1, p0, Lcom/kousei/framework/ta;->a:Lcom/kousei/framework/qa;

    iput-object p2, p0, Lcom/kousei/framework/ta;->b:Lcom/kousei/framework/qa;

    return-void

    :cond_d
    const-string p0, "\'notAfter\' cannot be null"

    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    throw v0

    :cond_13
    const-string p0, "\'notBefore\' cannot be null"

    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    throw v0
.end method


# virtual methods
.method public final b()Lcom/kousei/framework/z;
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/q2;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/ta;->a:Lcom/kousei/framework/qa;

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ta;->b:Lcom/kousei/framework/qa;

    .line 6
    .line 7
    invoke-direct {v0, v1, p0}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/j;Lcom/kousei/framework/j;)V

    .line 8
    .line 9
    .line 10
    return-object v0
.end method
