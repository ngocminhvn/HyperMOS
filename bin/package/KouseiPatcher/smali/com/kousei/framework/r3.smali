.class public abstract Lcom/kousei/framework/r3;
.super Lcom/kousei/framework/v3;


# direct methods
.method public constructor <init>(Ljava/math/BigInteger;)V
    .registers 6

    .line 1
    sget-object v0, Lcom/kousei/framework/m4;->a:Lcom/kousei/framework/j7;

    .line 2
    .line 3
    invoke-virtual {p1}, Ljava/math/BigInteger;->bitLength()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 8
    .line 9
    .line 10
    move-result v1

    .line 11
    if-lez v1, :cond_3d

    .line 12
    .line 13
    const/4 v1, 0x2

    .line 14
    if-lt v0, v1, :cond_3d

    .line 15
    .line 16
    const/4 v2, 0x3

    .line 17
    if-ge v0, v2, :cond_33

    .line 18
    .line 19
    sget-object v0, Lcom/kousei/framework/f1;->a:Ljava/math/BigInteger;

    .line 20
    .line 21
    invoke-virtual {p1}, Ljava/math/BigInteger;->bitLength()I

    .line 22
    .line 23
    .line 24
    move-result v0

    .line 25
    const/16 v3, 0x1f

    .line 26
    .line 27
    if-gt v0, v3, :cond_2b

    .line 28
    .line 29
    invoke-virtual {p1}, Ljava/math/BigInteger;->intValue()I

    .line 30
    .line 31
    .line 32
    move-result v0

    .line 33
    if-eq v0, v1, :cond_28

    .line 34
    .line 35
    if-eq v0, v2, :cond_25

    .line 36
    .line 37
    goto :goto_33

    .line 38
    :cond_25
    sget-object p1, Lcom/kousei/framework/m4;->b:Lcom/kousei/framework/j7;

    .line 39
    .line 40
    goto :goto_39

    .line 41
    :cond_28
    sget-object p1, Lcom/kousei/framework/m4;->a:Lcom/kousei/framework/j7;

    .line 42
    .line 43
    goto :goto_39

    .line 44
    :cond_2b
    new-instance p0, Ljava/lang/ArithmeticException;

    .line 45
    .line 46
    const-string p1, "BigInteger out of int range"

    .line 47
    .line 48
    invoke-direct {p0, p1}, Ljava/lang/ArithmeticException;-><init>(Ljava/lang/String;)V

    .line 49
    .line 50
    .line 51
    throw p0

    .line 52
    :cond_33
    :goto_33
    new-instance v0, Lcom/kousei/framework/j7;

    .line 53
    .line 54
    invoke-direct {v0, p1}, Lcom/kousei/framework/j7;-><init>(Ljava/math/BigInteger;)V

    .line 55
    .line 56
    .line 57
    move-object p1, v0

    .line 58
    :goto_39
    invoke-direct {p0, p1}, Lcom/kousei/framework/v3;-><init>(Lcom/kousei/framework/l4;)V

    .line 59
    .line 60
    .line 61
    return-void

    .line 62
    :cond_3d
    const-string p0, "\'characteristic\' must be >= 2"

    .line 63
    .line 64
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 65
    .line 66
    .line 67
    const/4 p0, 0x0

    .line 68
    throw p0
.end method


# virtual methods
.method public l(Ljava/security/SecureRandom;)Lcom/kousei/framework/h0;
    .registers 6

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/r3;->n()Ljava/math/BigInteger;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    :cond_4
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 6
    .line 7
    .line 8
    move-result v1

    .line 9
    invoke-static {v1, p1}, Lcom/kousei/framework/f1;->a(ILjava/security/SecureRandom;)Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    invoke-virtual {v1}, Ljava/math/BigInteger;->signum()I

    .line 14
    .line 15
    .line 16
    move-result v2

    .line 17
    if-lez v2, :cond_4

    .line 18
    .line 19
    invoke-virtual {v1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 20
    .line 21
    .line 22
    move-result v2

    .line 23
    if-gez v2, :cond_4

    .line 24
    .line 25
    invoke-virtual {p0, v1}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 26
    .line 27
    .line 28
    move-result-object v1

    .line 29
    :cond_1c
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 30
    .line 31
    .line 32
    move-result v2

    .line 33
    invoke-static {v2, p1}, Lcom/kousei/framework/f1;->a(ILjava/security/SecureRandom;)Ljava/math/BigInteger;

    .line 34
    .line 35
    .line 36
    move-result-object v2

    .line 37
    invoke-virtual {v2}, Ljava/math/BigInteger;->signum()I

    .line 38
    .line 39
    .line 40
    move-result v3

    .line 41
    if-lez v3, :cond_1c

    .line 42
    .line 43
    invoke-virtual {v2, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 44
    .line 45
    .line 46
    move-result v3

    .line 47
    if-gez v3, :cond_1c

    .line 48
    .line 49
    invoke-virtual {p0, v2}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 50
    .line 51
    .line 52
    move-result-object p0

    .line 53
    invoke-virtual {v1, p0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 54
    .line 55
    .line 56
    move-result-object p0

    .line 57
    return-object p0
.end method

.method public abstract n()Ljava/math/BigInteger;
.end method
