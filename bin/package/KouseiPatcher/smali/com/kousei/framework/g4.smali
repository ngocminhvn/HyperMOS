.class public final Lcom/kousei/framework/g4;
.super Lcom/kousei/framework/l0;


# instance fields
.field public final a:Lcom/kousei/framework/w3;

.field public final b:Ljava/math/BigInteger;


# direct methods
.method public constructor <init>(Ljava/math/BigInteger;Lcom/kousei/framework/w3;)V
    .registers 5

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-object p2, p0, Lcom/kousei/framework/g4;->a:Lcom/kousei/framework/w3;

    .line 5
    .line 6
    const/4 v0, 0x0

    .line 7
    if-eqz p1, :cond_21

    .line 8
    .line 9
    sget-object v1, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 10
    .line 11
    invoke-virtual {p1, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 12
    .line 13
    .line 14
    move-result v1

    .line 15
    if-ltz v1, :cond_1b

    .line 16
    .line 17
    iget-object p2, p2, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 18
    .line 19
    invoke-virtual {p1, p2}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 20
    .line 21
    .line 22
    move-result p2

    .line 23
    if-gez p2, :cond_1b

    .line 24
    .line 25
    iput-object p1, p0, Lcom/kousei/framework/g4;->b:Ljava/math/BigInteger;

    .line 26
    .line 27
    return-void

    .line 28
    :cond_1b
    const-string p0, "Scalar is not in the interval [1, n - 1]"

    .line 29
    .line 30
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 31
    .line 32
    .line 33
    throw v0

    .line 34
    :cond_21
    const-string p0, "Scalar cannot be null"

    .line 35
    .line 36
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 37
    .line 38
    .line 39
    throw v0
.end method
