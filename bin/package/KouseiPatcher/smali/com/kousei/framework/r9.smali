.class public final Lcom/kousei/framework/r9;
.super Lcom/kousei/framework/x3;


# instance fields
.field public final S:[J


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
    const/16 v1, 0xe9

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
    iput-object p1, p0, Lcom/kousei/framework/r9;->S:[J

    .line 27
    .line 28
    return-void

    .line 29
    :cond_1c
    const-string p0, "x value invalid for SecT233FieldElement"

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
    iput-object p1, p0, Lcom/kousei/framework/r9;->S:[J

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->n0([J)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final B2(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 7

    .line 1
    check-cast p1, Lcom/kousei/framework/r9;

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/r9;->S:[J

    .line 4
    .line 5
    check-cast p2, Lcom/kousei/framework/r9;

    .line 6
    .line 7
    iget-object p2, p2, Lcom/kousei/framework/r9;->S:[J

    .line 8
    .line 9
    const/16 v0, 0x8

    .line 10
    .line 11
    new-array v1, v0, [J

    .line 12
    .line 13
    new-array v2, v0, [J

    .line 14
    .line 15
    const/4 v3, 0x4

    .line 16
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 17
    .line 18
    invoke-static {v3, p0, v2}, Lcom/kousei/framework/h0;->X(I[J[J)V

    .line 19
    .line 20
    .line 21
    invoke-static {v1, v2, v1}, Lcom/kousei/framework/n6;->j([J[J[J)V

    .line 22
    .line 23
    .line 24
    new-array p0, v0, [J

    .line 25
    .line 26
    invoke-static {p1, p2, p0}, Lcom/kousei/framework/n6;->V([J[J[J)V

    .line 27
    .line 28
    .line 29
    invoke-static {v1, p0, v1}, Lcom/kousei/framework/n6;->j([J[J[J)V

    .line 30
    .line 31
    .line 32
    new-array p0, v3, [J

    .line 33
    .line 34
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->K0([J[J)V

    .line 35
    .line 36
    .line 37
    new-instance p1, Lcom/kousei/framework/r9;

    .line 38
    .line 39
    invoke-direct {p1, p0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 40
    .line 41
    .line 42
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
    const/4 v0, 0x4

    .line 6
    new-array v0, v0, [J

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 9
    .line 10
    invoke-static {p1, p0, v0}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/r9;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 16
    .line 17
    .line 18
    return-object p0
.end method

.method public final E0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->r0([J)Z

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
    const/4 v0, 0x4

    .line 2
    new-array v0, v0, [J

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/r9;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/r9;->S:[J

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/r9;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 16
    .line 17
    .line 18
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
    invoke-virtual {p0, p1}, Lcom/kousei/framework/r9;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 27

    .line 1
    const/4 v0, 0x4

    .line 2
    new-array v0, v0, [J

    .line 3
    .line 4
    move-object/from16 v1, p0

    .line 5
    .line 6
    iget-object v1, v1, Lcom/kousei/framework/r9;->S:[J

    .line 7
    .line 8
    const/4 v2, 0x0

    .line 9
    aget-wide v3, v1, v2

    .line 10
    .line 11
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->h3(J)J

    .line 12
    .line 13
    .line 14
    move-result-wide v3

    .line 15
    const/4 v5, 0x1

    .line 16
    aget-wide v6, v1, v5

    .line 17
    .line 18
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->h3(J)J

    .line 19
    .line 20
    .line 21
    move-result-wide v6

    .line 22
    const-wide v8, 0xffffffffL

    .line 23
    .line 24
    .line 25
    .line 26
    .line 27
    and-long v10, v3, v8

    .line 28
    .line 29
    const/16 v12, 0x20

    .line 30
    .line 31
    shl-long v13, v6, v12

    .line 32
    .line 33
    or-long/2addr v10, v13

    .line 34
    ushr-long/2addr v3, v12

    .line 35
    const-wide v13, -0x100000000L

    .line 36
    .line 37
    .line 38
    .line 39
    .line 40
    and-long/2addr v6, v13

    .line 41
    or-long/2addr v3, v6

    .line 42
    const/4 v6, 0x2

    .line 43
    aget-wide v6, v1, v6

    .line 44
    .line 45
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->h3(J)J

    .line 46
    .line 47
    .line 48
    move-result-wide v6

    .line 49
    const/4 v15, 0x3

    .line 50
    aget-wide v16, v1, v15

    .line 51
    .line 52
    invoke-static/range {v16 .. v17}, Lcom/kousei/framework/h0;->h3(J)J

    .line 53
    .line 54
    .line 55
    move-result-wide v16

    .line 56
    and-long/2addr v8, v6

    .line 57
    shl-long v18, v16, v12

    .line 58
    .line 59
    or-long v8, v8, v18

    .line 60
    .line 61
    ushr-long/2addr v6, v12

    .line 62
    and-long v13, v16, v13

    .line 63
    .line 64
    or-long/2addr v6, v13

    .line 65
    const/16 v1, 0x1b

    .line 66
    .line 67
    ushr-long v13, v6, v1

    .line 68
    .line 69
    ushr-long v16, v3, v1

    .line 70
    .line 71
    const/16 v1, 0x25

    .line 72
    .line 73
    shl-long v18, v6, v1

    .line 74
    .line 75
    or-long v16, v16, v18

    .line 76
    .line 77
    xor-long v6, v6, v16

    .line 78
    .line 79
    shl-long v16, v3, v1

    .line 80
    .line 81
    xor-long v3, v3, v16

    .line 82
    .line 83
    const/16 v1, 0x8

    .line 84
    .line 85
    new-array v1, v1, [J

    .line 86
    .line 87
    move/from16 p0, v2

    .line 88
    .line 89
    const/16 v2, 0x75

    .line 90
    .line 91
    move/from16 v16, v5

    .line 92
    .line 93
    const/16 v5, 0xbf

    .line 94
    .line 95
    filled-new-array {v12, v2, v5}, [I

    .line 96
    .line 97
    .line 98
    move-result-object v2

    .line 99
    move/from16 v5, p0

    .line 100
    .line 101
    :goto_64
    if-ge v5, v15, :cond_a2

    .line 102
    .line 103
    aget v12, v2, v5

    .line 104
    .line 105
    ushr-int/lit8 v17, v12, 0x6

    .line 106
    .line 107
    and-int/lit8 v12, v12, 0x3f

    .line 108
    .line 109
    aget-wide v18, v1, v17

    .line 110
    .line 111
    shl-long v20, v3, v12

    .line 112
    .line 113
    xor-long v18, v18, v20

    .line 114
    .line 115
    aput-wide v18, v1, v17

    .line 116
    .line 117
    add-int/lit8 v18, v17, 0x1

    .line 118
    .line 119
    aget-wide v19, v1, v18

    .line 120
    .line 121
    shl-long v21, v6, v12

    .line 122
    .line 123
    move/from16 v23, v15

    .line 124
    .line 125
    neg-int v15, v12

    .line 126
    ushr-long v24, v3, v15

    .line 127
    .line 128
    or-long v21, v21, v24

    .line 129
    .line 130
    xor-long v19, v19, v21

    .line 131
    .line 132
    aput-wide v19, v1, v18

    .line 133
    .line 134
    add-int/lit8 v18, v17, 0x2

    .line 135
    .line 136
    aget-wide v19, v1, v18

    .line 137
    .line 138
    shl-long v21, v13, v12

    .line 139
    .line 140
    ushr-long v24, v6, v15

    .line 141
    .line 142
    or-long v21, v21, v24

    .line 143
    .line 144
    xor-long v19, v19, v21

    .line 145
    .line 146
    aput-wide v19, v1, v18

    .line 147
    .line 148
    add-int/lit8 v17, v17, 0x3

    .line 149
    .line 150
    aget-wide v18, v1, v17

    .line 151
    .line 152
    ushr-long v20, v13, v15

    .line 153
    .line 154
    xor-long v18, v18, v20

    .line 155
    .line 156
    aput-wide v18, v1, v17

    .line 157
    .line 158
    add-int/lit8 v5, v5, 0x1

    .line 159
    .line 160
    move/from16 v15, v23

    .line 161
    .line 162
    goto :goto_64

    .line 163
    :cond_a2
    invoke-static {v1, v0}, Lcom/kousei/framework/n6;->K0([J[J)V

    .line 164
    .line 165
    .line 166
    aget-wide v1, v0, p0

    .line 167
    .line 168
    xor-long/2addr v1, v10

    .line 169
    aput-wide v1, v0, p0

    .line 170
    .line 171
    aget-wide v1, v0, v16

    .line 172
    .line 173
    xor-long/2addr v1, v8

    .line 174
    aput-wide v1, v0, v16

    .line 175
    .line 176
    new-instance v1, Lcom/kousei/framework/r9;

    .line 177
    .line 178
    invoke-direct {v1, v0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 179
    .line 180
    .line 181
    return-object v1
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    const/4 v0, 0x4

    .line 2
    new-array v0, v0, [J

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 5
    .line 6
    invoke-static {p0, v0}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 7
    .line 8
    .line 9
    new-instance p0, Lcom/kousei/framework/r9;

    .line 10
    .line 11
    invoke-direct {p0, v0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 12
    .line 13
    .line 14
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->l1([J)Ljava/math/BigInteger;

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
    const/16 p0, 0xe9

    .line 2
    .line 3
    return p0
.end method

.method public final b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 14

    .line 1
    check-cast p1, Lcom/kousei/framework/r9;

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/r9;->S:[J

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 6
    .line 7
    const/4 v0, 0x0

    .line 8
    aget-wide v1, p0, v0

    .line 9
    .line 10
    aget-wide v3, p1, v0

    .line 11
    .line 12
    xor-long/2addr v1, v3

    .line 13
    const/4 v3, 0x1

    .line 14
    aget-wide v4, p0, v3

    .line 15
    .line 16
    aget-wide v6, p1, v3

    .line 17
    .line 18
    xor-long/2addr v4, v6

    .line 19
    const/4 v6, 0x2

    .line 20
    aget-wide v7, p0, v6

    .line 21
    .line 22
    aget-wide v9, p1, v6

    .line 23
    .line 24
    xor-long/2addr v7, v9

    .line 25
    const/4 v9, 0x3

    .line 26
    aget-wide v10, p0, v9

    .line 27
    .line 28
    aget-wide p0, p1, v9

    .line 29
    .line 30
    xor-long/2addr p0, v10

    .line 31
    const/4 v10, 0x4

    .line 32
    new-array v10, v10, [J

    .line 33
    .line 34
    aput-wide v1, v10, v0

    .line 35
    .line 36
    aput-wide v4, v10, v3

    .line 37
    .line 38
    aput-wide v7, v10, v6

    .line 39
    .line 40
    aput-wide p0, v10, v9

    .line 41
    .line 42
    new-instance p0, Lcom/kousei/framework/r9;

    .line 43
    .line 44
    invoke-direct {p0, v10}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 45
    .line 46
    .line 47
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
    instance-of v0, p1, Lcom/kousei/framework/r9;

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
    check-cast p1, Lcom/kousei/framework/r9;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/r9;->S:[J

    .line 16
    .line 17
    invoke-static {p0, p1}, Lcom/kousei/framework/n6;->F([J[J)Z

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    return p0
.end method

.method public final hashCode()I
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 2
    .line 3
    const/4 v0, 0x4

    .line 4
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->j0([JI)I

    .line 5
    .line 6
    .line 7
    move-result p0

    .line 8
    const v0, 0x238dda

    .line 9
    .line 10
    .line 11
    xor-int/2addr p0, v0

    .line 12
    return p0
.end method

.method public final k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    invoke-virtual {p0, p1, p2, p3}, Lcom/kousei/framework/r9;->l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

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
    const/4 v0, 0x4

    .line 2
    new-array v1, v0, [J

    .line 3
    .line 4
    const/16 v2, 0x8

    .line 5
    .line 6
    new-array v2, v2, [J

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 9
    .line 10
    invoke-static {p0, v1}, Lcom/kousei/framework/n6;->w([J[J)V

    .line 11
    .line 12
    .line 13
    const/4 v3, 0x1

    .line 14
    move v4, v3

    .line 15
    :goto_e
    const/16 v5, 0xe9

    .line 16
    .line 17
    if-ge v4, v5, :cond_40

    .line 18
    .line 19
    invoke-static {v0, v1, v2}, Lcom/kousei/framework/h0;->X(I[J[J)V

    .line 20
    .line 21
    .line 22
    invoke-static {v2, v1}, Lcom/kousei/framework/n6;->K0([J[J)V

    .line 23
    .line 24
    .line 25
    invoke-static {v0, v1, v2}, Lcom/kousei/framework/h0;->X(I[J[J)V

    .line 26
    .line 27
    .line 28
    invoke-static {v2, v1}, Lcom/kousei/framework/n6;->K0([J[J)V

    .line 29
    .line 30
    .line 31
    const/4 v5, 0x0

    .line 32
    aget-wide v6, v1, v5

    .line 33
    .line 34
    aget-wide v8, p0, v5

    .line 35
    .line 36
    xor-long/2addr v6, v8

    .line 37
    aput-wide v6, v1, v5

    .line 38
    .line 39
    aget-wide v5, v1, v3

    .line 40
    .line 41
    aget-wide v7, p0, v3

    .line 42
    .line 43
    xor-long/2addr v5, v7

    .line 44
    aput-wide v5, v1, v3

    .line 45
    .line 46
    const/4 v5, 0x2

    .line 47
    aget-wide v6, v1, v5

    .line 48
    .line 49
    aget-wide v8, p0, v5

    .line 50
    .line 51
    xor-long/2addr v6, v8

    .line 52
    aput-wide v6, v1, v5

    .line 53
    .line 54
    const/4 v5, 0x3

    .line 55
    aget-wide v6, v1, v5

    .line 56
    .line 57
    aget-wide v8, p0, v5

    .line 58
    .line 59
    xor-long/2addr v6, v8

    .line 60
    aput-wide v6, v1, v5

    .line 61
    .line 62
    add-int/lit8 v4, v4, 0x2

    .line 63
    .line 64
    goto :goto_e

    .line 65
    :cond_40
    new-instance p0, Lcom/kousei/framework/r9;

    .line 66
    .line 67
    invoke-direct {p0, v1}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 68
    .line 69
    .line 70
    return-object p0
.end method

.method public final l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 7

    .line 1
    check-cast p1, Lcom/kousei/framework/r9;

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/r9;->S:[J

    .line 4
    .line 5
    check-cast p2, Lcom/kousei/framework/r9;

    .line 6
    .line 7
    iget-object p2, p2, Lcom/kousei/framework/r9;->S:[J

    .line 8
    .line 9
    check-cast p3, Lcom/kousei/framework/r9;

    .line 10
    .line 11
    iget-object p3, p3, Lcom/kousei/framework/r9;->S:[J

    .line 12
    .line 13
    const/16 v0, 0x8

    .line 14
    .line 15
    new-array v1, v0, [J

    .line 16
    .line 17
    new-array v2, v0, [J

    .line 18
    .line 19
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 20
    .line 21
    invoke-static {p0, p1, v2}, Lcom/kousei/framework/n6;->V([J[J[J)V

    .line 22
    .line 23
    .line 24
    invoke-static {v1, v2, v1}, Lcom/kousei/framework/n6;->j([J[J[J)V

    .line 25
    .line 26
    .line 27
    new-array p0, v0, [J

    .line 28
    .line 29
    invoke-static {p2, p3, p0}, Lcom/kousei/framework/n6;->V([J[J[J)V

    .line 30
    .line 31
    .line 32
    invoke-static {v1, p0, v1}, Lcom/kousei/framework/n6;->j([J[J[J)V

    .line 33
    .line 34
    .line 35
    const/4 p0, 0x4

    .line 36
    new-array p0, p0, [J

    .line 37
    .line 38
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->K0([J[J)V

    .line 39
    .line 40
    .line 41
    new-instance p1, Lcom/kousei/framework/r9;

    .line 42
    .line 43
    invoke-direct {p1, p0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 44
    .line 45
    .line 46
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
    .registers 5

    .line 1
    const/4 v0, 0x0

    .line 2
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 3
    .line 4
    aget-wide v0, p0, v0

    .line 5
    .line 6
    const/4 v2, 0x2

    .line 7
    aget-wide v2, p0, v2

    .line 8
    .line 9
    const/16 p0, 0x1f

    .line 10
    .line 11
    ushr-long/2addr v2, p0

    .line 12
    xor-long/2addr v0, v2

    .line 13
    long-to-int p0, v0

    .line 14
    and-int/lit8 p0, p0, 0x1

    .line 15
    .line 16
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 1

    .line 1
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 13

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

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
    xor-long/2addr v1, v3

    .line 9
    const/4 v3, 0x1

    .line 10
    aget-wide v4, p0, v3

    .line 11
    .line 12
    const/4 v6, 0x2

    .line 13
    aget-wide v7, p0, v6

    .line 14
    .line 15
    const/4 v9, 0x3

    .line 16
    aget-wide v10, p0, v9

    .line 17
    .line 18
    const/4 p0, 0x4

    .line 19
    new-array p0, p0, [J

    .line 20
    .line 21
    aput-wide v1, p0, v0

    .line 22
    .line 23
    aput-wide v4, p0, v3

    .line 24
    .line 25
    aput-wide v7, p0, v6

    .line 26
    .line 27
    aput-wide v10, p0, v9

    .line 28
    .line 29
    new-instance v0, Lcom/kousei/framework/r9;

    .line 30
    .line 31
    invoke-direct {v0, p0}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 32
    .line 33
    .line 34
    return-object v0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    const/4 v0, 0x4

    .line 2
    new-array v1, v0, [J

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/r9;->S:[J

    .line 5
    .line 6
    invoke-static {p0}, Lcom/kousei/framework/n6;->r0([J)Z

    .line 7
    .line 8
    .line 9
    move-result v2

    .line 10
    if-nez v2, :cond_5e

    .line 11
    .line 12
    new-array v2, v0, [J

    .line 13
    .line 14
    new-array v0, v0, [J

    .line 15
    .line 16
    invoke-static {p0, v2}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 17
    .line 18
    .line 19
    invoke-static {v2, p0, v2}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 20
    .line 21
    .line 22
    invoke-static {v2, v2}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 23
    .line 24
    .line 25
    invoke-static {v2, p0, v2}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 26
    .line 27
    .line 28
    const/4 v3, 0x3

    .line 29
    invoke-static {v3, v2, v0}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 30
    .line 31
    .line 32
    invoke-static {v0, v2, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 33
    .line 34
    .line 35
    invoke-static {v0, v0}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 36
    .line 37
    .line 38
    invoke-static {v0, p0, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 39
    .line 40
    .line 41
    const/4 v3, 0x7

    .line 42
    invoke-static {v3, v0, v2}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 43
    .line 44
    .line 45
    invoke-static {v2, v0, v2}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 46
    .line 47
    .line 48
    const/16 v3, 0xe

    .line 49
    .line 50
    invoke-static {v3, v2, v0}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 51
    .line 52
    .line 53
    invoke-static {v0, v2, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 54
    .line 55
    .line 56
    invoke-static {v0, v0}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 57
    .line 58
    .line 59
    invoke-static {v0, p0, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 60
    .line 61
    .line 62
    const/16 p0, 0x1d

    .line 63
    .line 64
    invoke-static {p0, v0, v2}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 65
    .line 66
    .line 67
    invoke-static {v2, v0, v2}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 68
    .line 69
    .line 70
    const/16 p0, 0x3a

    .line 71
    .line 72
    invoke-static {p0, v2, v0}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 73
    .line 74
    .line 75
    invoke-static {v0, v2, v0}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 76
    .line 77
    .line 78
    const/16 p0, 0x74

    .line 79
    .line 80
    invoke-static {p0, v0, v2}, Lcom/kousei/framework/n6;->X0(I[J[J)V

    .line 81
    .line 82
    .line 83
    invoke-static {v2, v0, v2}, Lcom/kousei/framework/n6;->D0([J[J[J)V

    .line 84
    .line 85
    .line 86
    invoke-static {v2, v1}, Lcom/kousei/framework/n6;->R0([J[J)V

    .line 87
    .line 88
    .line 89
    new-instance p0, Lcom/kousei/framework/r9;

    .line 90
    .line 91
    invoke-direct {p0, v1}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 92
    .line 93
    .line 94
    return-object p0

    .line 95
    :cond_5e
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 96
    .line 97
    invoke-direct {p0}, Ljava/lang/IllegalStateException;-><init>()V

    .line 98
    .line 99
    .line 100
    throw p0
.end method
