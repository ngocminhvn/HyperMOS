.class public final Lcom/kousei/framework/j0;
.super Lcom/kousei/framework/r;


# instance fields
.field public final a:Lcom/kousei/framework/u;

.field public final b:Lcom/kousei/framework/j;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/c0;)V
    .registers 6

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
    const/4 v1, 0x0

    .line 9
    const/4 v2, 0x1

    .line 10
    if-lt v0, v2, :cond_2d

    .line 11
    .line 12
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->size()I

    .line 13
    .line 14
    .line 15
    move-result v0

    .line 16
    const/4 v3, 0x2

    .line 17
    if-gt v0, v3, :cond_2d

    .line 18
    .line 19
    const/4 v0, 0x0

    .line 20
    invoke-virtual {p1, v0}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 21
    .line 22
    .line 23
    move-result-object v0

    .line 24
    invoke-static {v0}, Lcom/kousei/framework/u;->v(Lcom/kousei/framework/j;)Lcom/kousei/framework/u;

    .line 25
    .line 26
    .line 27
    move-result-object v0

    .line 28
    iput-object v0, p0, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 29
    .line 30
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->size()I

    .line 31
    .line 32
    .line 33
    move-result v0

    .line 34
    if-ne v0, v3, :cond_2a

    .line 35
    .line 36
    invoke-virtual {p1, v2}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 37
    .line 38
    .line 39
    move-result-object p1

    .line 40
    iput-object p1, p0, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 41
    .line 42
    return-void

    .line 43
    :cond_2a
    iput-object v1, p0, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 44
    .line 45
    return-void

    .line 46
    :cond_2d
    const-string p0, "Bad sequence size: "

    .line 47
    .line 48
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->size()I

    .line 49
    .line 50
    .line 51
    move-result p1

    .line 52
    invoke-static {p1, p0}, Lcom/kousei/framework/e;->h(ILjava/lang/String;)V

    .line 53
    .line 54
    .line 55
    throw v1
.end method

.method public constructor <init>(Lcom/kousei/framework/u;)V
    .registers 2

    .line 58
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 59
    iput-object p1, p0, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V
    .registers 3

    .line 56
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 57
    iput-object p1, p0, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    iput-object p2, p0, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    return-void
.end method

.method public static i(Ljava/lang/Object;)Lcom/kousei/framework/j0;
    .registers 2

    .line 1
    instance-of v0, p0, Lcom/kousei/framework/j0;

    .line 2
    .line 3
    if-eqz v0, :cond_7

    .line 4
    .line 5
    check-cast p0, Lcom/kousei/framework/j0;

    .line 6
    .line 7
    return-object p0

    .line 8
    :cond_7
    if-eqz p0, :cond_13

    .line 9
    .line 10
    new-instance v0, Lcom/kousei/framework/j0;

    .line 11
    .line 12
    invoke-static {p0}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 13
    .line 14
    .line 15
    move-result-object p0

    .line 16
    invoke-direct {v0, p0}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/c0;)V

    .line 17
    .line 18
    .line 19
    return-object v0

    .line 20
    :cond_13
    const/4 p0, 0x0

    .line 21
    return-object p0
.end method


# virtual methods
.method public final b()Lcom/kousei/framework/z;
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/k;

    .line 2
    .line 3
    const/4 v1, 0x2

    .line 4
    invoke-direct {v0, v1}, Lcom/kousei/framework/k;-><init>(I)V

    .line 5
    .line 6
    .line 7
    iget-object v1, p0, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 8
    .line 9
    invoke-virtual {v0, v1}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 10
    .line 11
    .line 12
    iget-object p0, p0, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 13
    .line 14
    if-eqz p0, :cond_12

    .line 15
    .line 16
    invoke-virtual {v0, p0}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 17
    .line 18
    .line 19
    :cond_12
    new-instance p0, Lcom/kousei/framework/q2;

    .line 20
    .line 21
    const/4 v1, 0x0

    .line 22
    invoke-direct {p0, v0, v1}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/k;I)V

    .line 23
    .line 24
    .line 25
    const/4 v0, -0x1

    .line 26
    iput v0, p0, Lcom/kousei/framework/q2;->d:I

    .line 27
    .line 28
    return-object p0
.end method
