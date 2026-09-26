.class public final Lcom/kousei/framework/z8;
.super Lcom/kousei/framework/y3;


# static fields
.field public static final T:Ljava/math/BigInteger;


# instance fields
.field public final S:[I


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Ljava/math/BigInteger;

    .line 2
    .line 3
    const-string v1, "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF"

    .line 4
    .line 5
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    const/4 v2, 0x1

    .line 10
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 11
    .line 12
    .line 13
    sput-object v0, Lcom/kousei/framework/z8;->T:Ljava/math/BigInteger;

    .line 14
    .line 15
    return-void
.end method

.method public constructor <init>(Ljava/math/BigInteger;)V
    .registers 4

    .line 1
    const/16 v0, 0x17

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    if-eqz p1, :cond_2d

    .line 7
    .line 8
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-ltz v0, :cond_2d

    .line 13
    .line 14
    sget-object v0, Lcom/kousei/framework/z8;->T:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 17
    .line 18
    .line 19
    move-result v0

    .line 20
    if-gez v0, :cond_2d

    .line 21
    .line 22
    invoke-static {p1}, Lcom/kousei/framework/n6;->K(Ljava/math/BigInteger;)[I

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    const/4 v0, 0x7

    .line 27
    aget v0, p1, v0

    .line 28
    .line 29
    const/4 v1, -0x1

    .line 30
    if-ne v0, v1, :cond_2a

    .line 31
    .line 32
    sget-object v0, Lcom/kousei/framework/h0;->I:[I

    .line 33
    .line 34
    invoke-static {p1, v0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 35
    .line 36
    .line 37
    move-result v1

    .line 38
    if-eqz v1, :cond_2a

    .line 39
    .line 40
    invoke-static {v0, p1}, Lcom/kousei/framework/n6;->h1([I[I)V

    .line 41
    .line 42
    .line 43
    :cond_2a
    iput-object p1, p0, Lcom/kousei/framework/z8;->S:[I

    .line 44
    .line 45
    return-void

    .line 46
    :cond_2d
    const-string p0, "x value invalid for SecP256R1FieldElement"

    .line 47
    .line 48
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 49
    .line 50
    .line 51
    const/4 p0, 0x0

    .line 52
    throw p0
.end method

.method public constructor <init>([I)V
    .registers 3

    const/16 v0, 0x17

    .line 53
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 54
    iput-object p1, p0, Lcom/kousei/framework/z8;->S:[I

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final E0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/z8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/z8;->S:[I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 12
    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/z8;

    .line 15
    .line 16
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 17
    .line 18
    .line 19
    return-object p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/z8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/z8;->S:[I

    .line 8
    .line 9
    const/16 v1, 0x10

    .line 10
    .line 11
    new-array v1, v1, [I

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 14
    .line 15
    invoke-static {p0, p1, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 16
    .line 17
    .line 18
    invoke-static {v1, v0}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 19
    .line 20
    .line 21
    new-instance p0, Lcom/kousei/framework/z8;

    .line 22
    .line 23
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 24
    .line 25
    .line 26
    return-object p0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/z8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/z8;->S:[I

    .line 8
    .line 9
    sget-object v1, Lcom/kousei/framework/h0;->I:[I

    .line 10
    .line 11
    invoke-static {v1, p1, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 12
    .line 13
    .line 14
    const/16 p1, 0x10

    .line 15
    .line 16
    new-array p1, p1, [I

    .line 17
    .line 18
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 19
    .line 20
    invoke-static {v0, p0, p1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 21
    .line 22
    .line 23
    invoke-static {p1, v0}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 24
    .line 25
    .line 26
    new-instance p0, Lcom/kousei/framework/z8;

    .line 27
    .line 28
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 29
    .line 30
    .line 31
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 7

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 2
    .line 3
    invoke-static {v0}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_79

    .line 8
    .line 9
    invoke-static {v0}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_f

    .line 14
    .line 15
    goto :goto_79

    .line 16
    :cond_f
    const/16 p0, 0x10

    .line 17
    .line 18
    new-array v1, p0, [I

    .line 19
    .line 20
    const/16 v2, 0x8

    .line 21
    .line 22
    new-array v3, v2, [I

    .line 23
    .line 24
    new-array v4, v2, [I

    .line 25
    .line 26
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 27
    .line 28
    .line 29
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 30
    .line 31
    .line 32
    invoke-static {v3, v0, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 33
    .line 34
    .line 35
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 36
    .line 37
    .line 38
    const/4 v5, 0x2

    .line 39
    invoke-static {v5, v3, v4, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 40
    .line 41
    .line 42
    invoke-static {v4, v3, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 43
    .line 44
    .line 45
    invoke-static {v1, v4}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 46
    .line 47
    .line 48
    const/4 v5, 0x4

    .line 49
    invoke-static {v5, v4, v3, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 50
    .line 51
    .line 52
    invoke-static {v3, v4, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 53
    .line 54
    .line 55
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 56
    .line 57
    .line 58
    invoke-static {v2, v3, v4, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 59
    .line 60
    .line 61
    invoke-static {v4, v3, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 62
    .line 63
    .line 64
    invoke-static {v1, v4}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 65
    .line 66
    .line 67
    invoke-static {p0, v4, v3, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 68
    .line 69
    .line 70
    invoke-static {v3, v4, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 71
    .line 72
    .line 73
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 74
    .line 75
    .line 76
    const/16 p0, 0x20

    .line 77
    .line 78
    invoke-static {p0, v3, v3, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 79
    .line 80
    .line 81
    invoke-static {v3, v0, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 82
    .line 83
    .line 84
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 85
    .line 86
    .line 87
    const/16 p0, 0x60

    .line 88
    .line 89
    invoke-static {p0, v3, v3, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 90
    .line 91
    .line 92
    invoke-static {v3, v0, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 93
    .line 94
    .line 95
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 96
    .line 97
    .line 98
    const/16 p0, 0x5e

    .line 99
    .line 100
    invoke-static {p0, v3, v3, v1}, Lcom/kousei/framework/h0;->q2(I[I[I[I)V

    .line 101
    .line 102
    .line 103
    invoke-static {v3, v1}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 104
    .line 105
    .line 106
    invoke-static {v1, v4}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 107
    .line 108
    .line 109
    invoke-static {v0, v4}, Lcom/kousei/framework/n6;->E([I[I)Z

    .line 110
    .line 111
    .line 112
    move-result p0

    .line 113
    if-eqz p0, :cond_78

    .line 114
    .line 115
    new-instance p0, Lcom/kousei/framework/z8;

    .line 116
    .line 117
    invoke-direct {p0, v3}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 118
    .line 119
    .line 120
    return-object p0

    .line 121
    :cond_78
    const/4 p0, 0x0

    .line 122
    :cond_79
    :goto_79
    return-object p0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    const/16 v1, 0x10

    .line 6
    .line 7
    new-array v1, v1, [I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, v1}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 12
    .line 13
    .line 14
    invoke-static {v1, v0}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 15
    .line 16
    .line 17
    new-instance p0, Lcom/kousei/framework/z8;

    .line 18
    .line 19
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 20
    .line 21
    .line 22
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->k1([I)Ljava/math/BigInteger;

    .line 4
    .line 5
    .line 6
    move-result-object p0

    .line 7
    return-object p0
.end method

.method public final a0()I
    .registers 1

    .line 1
    sget-object p0, Lcom/kousei/framework/z8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {p0}, Ljava/math/BigInteger;->bitLength()I

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/z8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/z8;->S:[I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/n6;->c([I[I[I)I

    .line 12
    .line 13
    .line 14
    move-result p0

    .line 15
    if-nez p0, :cond_1e

    .line 16
    .line 17
    const/4 p0, 0x7

    .line 18
    aget p0, v0, p0

    .line 19
    .line 20
    const/4 p1, -0x1

    .line 21
    if-ne p0, p1, :cond_21

    .line 22
    .line 23
    sget-object p0, Lcom/kousei/framework/h0;->I:[I

    .line 24
    .line 25
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 26
    .line 27
    .line 28
    move-result p0

    .line 29
    if-eqz p0, :cond_21

    .line 30
    .line 31
    :cond_1e
    invoke-static {v0}, Lcom/kousei/framework/h0;->w([I)V

    .line 32
    .line 33
    .line 34
    :cond_21
    new-instance p0, Lcom/kousei/framework/z8;

    .line 35
    .line 36
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 37
    .line 38
    .line 39
    return-object p0
.end method

.method public final equals(Ljava/lang/Object;)Z
    .registers 3

    .line 1
    if-ne p1, p0, :cond_4

    .line 2
    .line 3
    const/4 p0, 0x1

    .line 4
    return p0

    .line 5
    :cond_4
    instance-of v0, p1, Lcom/kousei/framework/z8;

    .line 6
    .line 7
    if-nez v0, :cond_a

    .line 8
    .line 9
    const/4 p0, 0x0

    .line 10
    return p0

    .line 11
    :cond_a
    check-cast p1, Lcom/kousei/framework/z8;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/z8;->S:[I

    .line 16
    .line 17
    invoke-static {p0, p1}, Lcom/kousei/framework/n6;->E([I[I)Z

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    return p0
.end method

.method public final hashCode()I
    .registers 3

    .line 1
    sget-object v0, Lcom/kousei/framework/z8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 8
    .line 9
    const/16 v1, 0x8

    .line 10
    .line 11
    invoke-static {v1, p0}, Lcom/kousei/framework/h0;->h0(I[I)I

    .line 12
    .line 13
    .line 14
    move-result p0

    .line 15
    xor-int/2addr p0, v0

    .line 16
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v1, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 6
    .line 7
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 8
    .line 9
    .line 10
    move-result v0

    .line 11
    sget-object v2, Lcom/kousei/framework/h0;->I:[I

    .line 12
    .line 13
    if-eqz v0, :cond_12

    .line 14
    .line 15
    invoke-static {v2, v2, v1}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 16
    .line 17
    .line 18
    goto :goto_15

    .line 19
    :cond_12
    invoke-static {v2, p0, v1}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 20
    .line 21
    .line 22
    :goto_15
    new-instance p0, Lcom/kousei/framework/z8;

    .line 23
    .line 24
    invoke-direct {p0, v1}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 25
    .line 26
    .line 27
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v1, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 6
    .line 7
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->f0(I[I[I)I

    .line 8
    .line 9
    .line 10
    move-result p0

    .line 11
    if-nez p0, :cond_1a

    .line 12
    .line 13
    const/4 p0, 0x7

    .line 14
    aget p0, v1, p0

    .line 15
    .line 16
    const/4 v0, -0x1

    .line 17
    if-ne p0, v0, :cond_1d

    .line 18
    .line 19
    sget-object p0, Lcom/kousei/framework/h0;->I:[I

    .line 20
    .line 21
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 22
    .line 23
    .line 24
    move-result p0

    .line 25
    if-eqz p0, :cond_1d

    .line 26
    .line 27
    :cond_1a
    invoke-static {v1}, Lcom/kousei/framework/h0;->w([I)V

    .line 28
    .line 29
    .line 30
    :cond_1d
    new-instance p0, Lcom/kousei/framework/z8;

    .line 31
    .line 32
    invoke-direct {p0, v1}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 33
    .line 34
    .line 35
    return-object p0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/z8;->S:[I

    .line 6
    .line 7
    sget-object v1, Lcom/kousei/framework/h0;->I:[I

    .line 8
    .line 9
    invoke-static {v1, p0, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 10
    .line 11
    .line 12
    new-instance p0, Lcom/kousei/framework/z8;

    .line 13
    .line 14
    invoke-direct {p0, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 15
    .line 16
    .line 17
    return-object p0
.end method
