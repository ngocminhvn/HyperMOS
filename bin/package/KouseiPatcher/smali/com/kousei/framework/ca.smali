.class public final Lcom/kousei/framework/ca;
.super Lcom/kousei/framework/x3;


# instance fields
.field public S:[J


# direct methods
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
    if-eqz p1, :cond_1c

    .line 7
    .line 8
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-ltz v0, :cond_1c

    .line 13
    .line 14
    invoke-virtual {p1}, Ljava/math/BigInteger;->bitLength()I

    .line 15
    .line 16
    .line 17
    move-result v0

    .line 18
    const/16 v1, 0x23b

    .line 19
    .line 20
    if-gt v0, v1, :cond_1c

    .line 21
    .line 22
    invoke-static {v1, p1}, Lcom/kousei/framework/n6;->L(ILjava/math/BigInteger;)[J

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    iput-object p1, p0, Lcom/kousei/framework/ca;->S:[J

    .line 27
    .line 28
    return-void

    .line 29
    :cond_1c
    const-string p0, "x value invalid for SecT571FieldElement"

    .line 30
    .line 31
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 32
    .line 33
    .line 34
    const/4 p0, 0x0

    .line 35
    throw p0
.end method

.method public constructor <init>([J)V
    .registers 3

    const/16 v0, 0x17

    .line 36
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 37
    iput-object p1, p0, Lcom/kousei/framework/ca;->S:[J

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 8

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    const/4 v0, 0x0

    .line 4
    aget-wide v1, p0, v0

    .line 5
    .line 6
    const-wide/16 v3, 0x1

    .line 7
    .line 8
    cmp-long v1, v1, v3

    .line 9
    .line 10
    if-eqz v1, :cond_c

    .line 11
    .line 12
    goto :goto_1a

    .line 13
    :cond_c
    const/4 v1, 0x1

    .line 14
    move v2, v1

    .line 15
    :goto_e
    const/16 v3, 0x9

    .line 16
    .line 17
    if-ge v2, v3, :cond_1e

    .line 18
    .line 19
    aget-wide v3, p0, v2

    .line 20
    .line 21
    const-wide/16 v5, 0x0

    .line 22
    .line 23
    cmp-long v3, v3, v5

    .line 24
    .line 25
    if-eqz v3, :cond_1b

    .line 26
    .line 27
    :goto_1a
    return v0

    .line 28
    :cond_1b
    add-int/lit8 v2, v2, 0x1

    .line 29
    .line 30
    goto :goto_e

    .line 31
    :cond_1e
    return v1
.end method

.method public final B2(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    check-cast p1, Lcom/kousei/framework/ca;

    .line 4
    .line 5
    iget-object p1, p1, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    check-cast p2, Lcom/kousei/framework/ca;

    .line 8
    .line 9
    iget-object p2, p2, Lcom/kousei/framework/ca;->S:[J

    .line 10
    .line 11
    const/16 v0, 0x12

    .line 12
    .line 13
    new-array v1, v0, [J

    .line 14
    .line 15
    new-array v0, v0, [J

    .line 16
    .line 17
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->y0([J[J)V

    .line 18
    .line 19
    .line 20
    invoke-static {v1, v0, v1}, Lcom/kousei/framework/h0;->q([J[J[J)V

    .line 21
    .line 22
    .line 23
    invoke-static {p1, p2, v1}, Lcom/kousei/framework/h0;->j1([J[J[J)V

    .line 24
    .line 25
    .line 26
    const/16 p0, 0x9

    .line 27
    .line 28
    new-array p0, p0, [J

    .line 29
    .line 30
    invoke-static {v1, p0}, Lcom/kousei/framework/h0;->C1([J[J)V

    .line 31
    .line 32
    .line 33
    new-instance p1, Lcom/kousei/framework/ca;

    .line 34
    .line 35
    invoke-direct {p1, p0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 36
    .line 37
    .line 38
    return-object p1
.end method

.method public final C2(I)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x1

    .line 2
    if-ge p1, v0, :cond_4

    .line 3
    .line 4
    return-object p0

    .line 5
    :cond_4
    const/16 v0, 0x9

    .line 6
    .line 7
    new-array v0, v0, [J

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 10
    .line 11
    invoke-static {p1, p0, v0}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 12
    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/ca;

    .line 15
    .line 16
    invoke-direct {p0, v0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 17
    .line 18
    .line 19
    return-object p0
.end method

.method public final E0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->s0([J)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v0, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    check-cast p1, Lcom/kousei/framework/ca;

    .line 8
    .line 9
    iget-object p1, p1, Lcom/kousei/framework/ca;->S:[J

    .line 10
    .line 11
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 12
    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/ca;

    .line 15
    .line 16
    invoke-direct {p0, v0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 17
    .line 18
    .line 19
    return-object p0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->z0()Lcom/kousei/framework/h0;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p0, p1}, Lcom/kousei/framework/ca;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 16

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v1, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    new-array v2, v0, [J

    .line 8
    .line 9
    new-array v0, v0, [J

    .line 10
    .line 11
    const/4 v3, 0x0

    .line 12
    move v4, v3

    .line 13
    :goto_c
    const-wide v5, 0xffffffffL

    .line 14
    .line 15
    .line 16
    .line 17
    .line 18
    const/16 v7, 0x20

    .line 19
    .line 20
    const/4 v8, 0x4

    .line 21
    if-ge v3, v8, :cond_3a

    .line 22
    .line 23
    add-int/lit8 v8, v4, 0x1

    .line 24
    .line 25
    aget-wide v9, p0, v4

    .line 26
    .line 27
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->h3(J)J

    .line 28
    .line 29
    .line 30
    move-result-wide v9

    .line 31
    add-int/lit8 v4, v4, 0x2

    .line 32
    .line 33
    aget-wide v11, p0, v8

    .line 34
    .line 35
    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->h3(J)J

    .line 36
    .line 37
    .line 38
    move-result-wide v11

    .line 39
    and-long/2addr v5, v9

    .line 40
    shl-long v13, v11, v7

    .line 41
    .line 42
    or-long/2addr v5, v13

    .line 43
    aput-wide v5, v2, v3

    .line 44
    .line 45
    ushr-long v5, v9, v7

    .line 46
    .line 47
    const-wide v7, -0x100000000L

    .line 48
    .line 49
    .line 50
    .line 51
    .line 52
    and-long/2addr v7, v11

    .line 53
    or-long/2addr v5, v7

    .line 54
    aput-wide v5, v0, v3

    .line 55
    .line 56
    add-int/lit8 v3, v3, 0x1

    .line 57
    .line 58
    goto :goto_c

    .line 59
    :cond_3a
    aget-wide v3, p0, v4

    .line 60
    .line 61
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->h3(J)J

    .line 62
    .line 63
    .line 64
    move-result-wide v3

    .line 65
    and-long/2addr v5, v3

    .line 66
    aput-wide v5, v2, v8

    .line 67
    .line 68
    ushr-long/2addr v3, v7

    .line 69
    aput-wide v3, v0, v8

    .line 70
    .line 71
    sget-object p0, Lcom/kousei/framework/h0;->R:[J

    .line 72
    .line 73
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 74
    .line 75
    .line 76
    invoke-static {v1, v2, v1}, Lcom/kousei/framework/h0;->d([J[J[J)V

    .line 77
    .line 78
    .line 79
    new-instance p0, Lcom/kousei/framework/ca;

    .line 80
    .line 81
    invoke-direct {p0, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 82
    .line 83
    .line 84
    return-object p0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v0, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->b2([J[J)V

    .line 8
    .line 9
    .line 10
    new-instance p0, Lcom/kousei/framework/ca;

    .line 11
    .line 12
    invoke-direct {p0, v0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 13
    .line 14
    .line 15
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 7

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    const/16 v0, 0x48

    .line 4
    .line 5
    new-array v0, v0, [B

    .line 6
    .line 7
    const/4 v1, 0x0

    .line 8
    :goto_7
    const/16 v2, 0x9

    .line 9
    .line 10
    if-ge v1, v2, :cond_1d

    .line 11
    .line 12
    aget-wide v2, p0, v1

    .line 13
    .line 14
    const-wide/16 v4, 0x0

    .line 15
    .line 16
    cmp-long v4, v2, v4

    .line 17
    .line 18
    if-eqz v4, :cond_1a

    .line 19
    .line 20
    rsub-int/lit8 v4, v1, 0x8

    .line 21
    .line 22
    shl-int/lit8 v4, v4, 0x3

    .line 23
    .line 24
    invoke-static {v2, v3, v0, v4}, Lcom/kousei/framework/n6;->v0(J[BI)V

    .line 25
    .line 26
    .line 27
    :cond_1a
    add-int/lit8 v1, v1, 0x1

    .line 28
    .line 29
    goto :goto_7

    .line 30
    :cond_1d
    new-instance p0, Ljava/math/BigInteger;

    .line 31
    .line 32
    const/4 v1, 0x1

    .line 33
    invoke-direct {p0, v1, v0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 34
    .line 35
    .line 36
    return-object p0
.end method

.method public final a0()I
    .registers 1

    .line 1
    const/16 p0, 0x23b

    .line 2
    .line 3
    return p0
.end method

.method public final b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v0, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    check-cast p1, Lcom/kousei/framework/ca;

    .line 8
    .line 9
    iget-object p1, p1, Lcom/kousei/framework/ca;->S:[J

    .line 10
    .line 11
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->d([J[J[J)V

    .line 12
    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/ca;

    .line 15
    .line 16
    invoke-direct {p0, v0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 17
    .line 18
    .line 19
    return-object p0
.end method

.method public final equals(Ljava/lang/Object;)Z
    .registers 9

    .line 1
    const/4 v0, 0x1

    .line 2
    if-ne p1, p0, :cond_4

    .line 3
    .line 4
    return v0

    .line 5
    :cond_4
    instance-of v1, p1, Lcom/kousei/framework/ca;

    .line 6
    .line 7
    const/4 v2, 0x0

    .line 8
    if-nez v1, :cond_a

    .line 9
    .line 10
    return v2

    .line 11
    :cond_a
    check-cast p1, Lcom/kousei/framework/ca;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/ca;->S:[J

    .line 16
    .line 17
    const/16 v1, 0x8

    .line 18
    .line 19
    :goto_12
    if-ltz v1, :cond_20

    .line 20
    .line 21
    aget-wide v3, p0, v1

    .line 22
    .line 23
    aget-wide v5, p1, v1

    .line 24
    .line 25
    cmp-long v3, v3, v5

    .line 26
    .line 27
    if-eqz v3, :cond_1d

    .line 28
    .line 29
    return v2

    .line 30
    :cond_1d
    add-int/lit8 v1, v1, -0x1

    .line 31
    .line 32
    goto :goto_12

    .line 33
    :cond_20
    return v0
.end method

.method public final hashCode()I
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    const/16 v0, 0x9

    .line 4
    .line 5
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->j0([JI)I

    .line 6
    .line 7
    .line 8
    move-result p0

    .line 9
    const v0, 0x5724cc

    .line 10
    .line 11
    .line 12
    xor-int/2addr p0, v0

    .line 13
    return p0
.end method

.method public final k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    invoke-virtual {p0, p1, p2, p3}, Lcom/kousei/framework/ca;->l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    return-object p0
.end method

.method public final k3()Lcom/kousei/framework/h0;
    .registers 11

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v1, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    const/16 v2, 0x12

    .line 8
    .line 9
    new-array v2, v2, [J

    .line 10
    .line 11
    const/4 v3, 0x0

    .line 12
    aget-wide v4, p0, v3

    .line 13
    .line 14
    aput-wide v4, v1, v3

    .line 15
    .line 16
    const/4 v4, 0x1

    .line 17
    aget-wide v5, p0, v4

    .line 18
    .line 19
    aput-wide v5, v1, v4

    .line 20
    .line 21
    const/4 v5, 0x2

    .line 22
    aget-wide v6, p0, v5

    .line 23
    .line 24
    aput-wide v6, v1, v5

    .line 25
    .line 26
    const/4 v5, 0x3

    .line 27
    aget-wide v6, p0, v5

    .line 28
    .line 29
    aput-wide v6, v1, v5

    .line 30
    .line 31
    const/4 v5, 0x4

    .line 32
    aget-wide v6, p0, v5

    .line 33
    .line 34
    aput-wide v6, v1, v5

    .line 35
    .line 36
    const/4 v5, 0x5

    .line 37
    aget-wide v6, p0, v5

    .line 38
    .line 39
    aput-wide v6, v1, v5

    .line 40
    .line 41
    const/4 v5, 0x6

    .line 42
    aget-wide v6, p0, v5

    .line 43
    .line 44
    aput-wide v6, v1, v5

    .line 45
    .line 46
    const/4 v5, 0x7

    .line 47
    aget-wide v6, p0, v5

    .line 48
    .line 49
    aput-wide v6, v1, v5

    .line 50
    .line 51
    const/16 v5, 0x8

    .line 52
    .line 53
    aget-wide v6, p0, v5

    .line 54
    .line 55
    aput-wide v6, v1, v5

    .line 56
    .line 57
    :goto_38
    const/16 v5, 0x23b

    .line 58
    .line 59
    if-ge v4, v5, :cond_58

    .line 60
    .line 61
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->y0([J[J)V

    .line 62
    .line 63
    .line 64
    invoke-static {v2, v1}, Lcom/kousei/framework/h0;->C1([J[J)V

    .line 65
    .line 66
    .line 67
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->y0([J[J)V

    .line 68
    .line 69
    .line 70
    invoke-static {v2, v1}, Lcom/kousei/framework/h0;->C1([J[J)V

    .line 71
    .line 72
    .line 73
    move v5, v3

    .line 74
    :goto_49
    if-ge v5, v0, :cond_55

    .line 75
    .line 76
    aget-wide v6, v1, v5

    .line 77
    .line 78
    aget-wide v8, p0, v5

    .line 79
    .line 80
    xor-long/2addr v6, v8

    .line 81
    aput-wide v6, v1, v5

    .line 82
    .line 83
    add-int/lit8 v5, v5, 0x1

    .line 84
    .line 85
    goto :goto_49

    .line 86
    :cond_55
    add-int/lit8 v4, v4, 0x2

    .line 87
    .line 88
    goto :goto_38

    .line 89
    :cond_58
    new-instance p0, Lcom/kousei/framework/ca;

    .line 90
    .line 91
    invoke-direct {p0, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 92
    .line 93
    .line 94
    return-object p0
.end method

.method public final l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    check-cast p1, Lcom/kousei/framework/ca;

    .line 4
    .line 5
    iget-object p1, p1, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    check-cast p2, Lcom/kousei/framework/ca;

    .line 8
    .line 9
    iget-object p2, p2, Lcom/kousei/framework/ca;->S:[J

    .line 10
    .line 11
    check-cast p3, Lcom/kousei/framework/ca;

    .line 12
    .line 13
    iget-object p3, p3, Lcom/kousei/framework/ca;->S:[J

    .line 14
    .line 15
    const/16 v0, 0x12

    .line 16
    .line 17
    new-array v0, v0, [J

    .line 18
    .line 19
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->j1([J[J[J)V

    .line 20
    .line 21
    .line 22
    invoke-static {p2, p3, v0}, Lcom/kousei/framework/h0;->j1([J[J[J)V

    .line 23
    .line 24
    .line 25
    const/16 p0, 0x9

    .line 26
    .line 27
    new-array p0, p0, [J

    .line 28
    .line 29
    invoke-static {v0, p0}, Lcom/kousei/framework/h0;->C1([J[J)V

    .line 30
    .line 31
    .line 32
    new-instance p1, Lcom/kousei/framework/ca;

    .line 33
    .line 34
    invoke-direct {p1, p0}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 35
    .line 36
    .line 37
    return-object p1
.end method

.method public final l3()Z
    .registers 1

    .line 1
    const/4 p0, 0x1

    .line 2
    return p0
.end method

.method public final m3()I
    .registers 7

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 2
    .line 3
    const/4 v0, 0x0

    .line 4
    aget-wide v0, p0, v0

    .line 5
    .line 6
    const/16 v2, 0x8

    .line 7
    .line 8
    aget-wide v2, p0, v2

    .line 9
    .line 10
    const/16 p0, 0x31

    .line 11
    .line 12
    ushr-long v4, v2, p0

    .line 13
    .line 14
    xor-long/2addr v0, v4

    .line 15
    const/16 p0, 0x39

    .line 16
    .line 17
    ushr-long/2addr v2, p0

    .line 18
    xor-long/2addr v0, v2

    .line 19
    long-to-int p0, v0

    .line 20
    and-int/lit8 p0, p0, 0x1

    .line 21
    .line 22
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 1

    .line 1
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 8

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v1, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    const/4 v2, 0x0

    .line 8
    aget-wide v3, p0, v2

    .line 9
    .line 10
    const-wide/16 v5, 0x1

    .line 11
    .line 12
    xor-long/2addr v3, v5

    .line 13
    aput-wide v3, v1, v2

    .line 14
    .line 15
    const/4 v2, 0x1

    .line 16
    :goto_f
    if-ge v2, v0, :cond_18

    .line 17
    .line 18
    aget-wide v3, p0, v2

    .line 19
    .line 20
    aput-wide v3, v1, v2

    .line 21
    .line 22
    add-int/lit8 v2, v2, 0x1

    .line 23
    .line 24
    goto :goto_f

    .line 25
    :cond_18
    new-instance p0, Lcom/kousei/framework/ca;

    .line 26
    .line 27
    invoke-direct {p0, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 28
    .line 29
    .line 30
    return-object p0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    const/16 v0, 0x9

    .line 2
    .line 3
    new-array v1, v0, [J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/ca;->S:[J

    .line 6
    .line 7
    invoke-static {p0}, Lcom/kousei/framework/n6;->s0([J)Z

    .line 8
    .line 9
    .line 10
    move-result v2

    .line 11
    if-nez v2, :cond_6d

    .line 12
    .line 13
    new-array v2, v0, [J

    .line 14
    .line 15
    new-array v3, v0, [J

    .line 16
    .line 17
    new-array v0, v0, [J

    .line 18
    .line 19
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->b2([J[J)V

    .line 20
    .line 21
    .line 22
    invoke-static {v0, v2}, Lcom/kousei/framework/h0;->b2([J[J)V

    .line 23
    .line 24
    .line 25
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->b2([J[J)V

    .line 26
    .line 27
    .line 28
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 29
    .line 30
    .line 31
    const/4 p0, 0x2

    .line 32
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 33
    .line 34
    .line 35
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 36
    .line 37
    .line 38
    invoke-static {v2, v0, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 39
    .line 40
    .line 41
    const/4 p0, 0x5

    .line 42
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 43
    .line 44
    .line 45
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 46
    .line 47
    .line 48
    invoke-static {p0, v3, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 49
    .line 50
    .line 51
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 52
    .line 53
    .line 54
    const/16 p0, 0xf

    .line 55
    .line 56
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 57
    .line 58
    .line 59
    invoke-static {v2, v3, v0}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 60
    .line 61
    .line 62
    const/16 p0, 0x1e

    .line 63
    .line 64
    invoke-static {p0, v0, v2}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 65
    .line 66
    .line 67
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 68
    .line 69
    .line 70
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 71
    .line 72
    .line 73
    const/16 p0, 0x3c

    .line 74
    .line 75
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 76
    .line 77
    .line 78
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 79
    .line 80
    .line 81
    invoke-static {p0, v3, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 82
    .line 83
    .line 84
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 85
    .line 86
    .line 87
    const/16 p0, 0xb4

    .line 88
    .line 89
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 90
    .line 91
    .line 92
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 93
    .line 94
    .line 95
    invoke-static {p0, v3, v3}, Lcom/kousei/framework/h0;->w2(I[J[J)V

    .line 96
    .line 97
    .line 98
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 99
    .line 100
    .line 101
    invoke-static {v2, v0, v1}, Lcom/kousei/framework/h0;->c1([J[J[J)V

    .line 102
    .line 103
    .line 104
    new-instance p0, Lcom/kousei/framework/ca;

    .line 105
    .line 106
    invoke-direct {p0, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 107
    .line 108
    .line 109
    return-object p0

    .line 110
    :cond_6d
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 111
    .line 112
    invoke-direct {p0}, Ljava/lang/IllegalStateException;-><init>()V

    .line 113
    .line 114
    .line 115
    throw p0
.end method
