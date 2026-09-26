.class public final Lcom/kousei/framework/v8;
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
    const-string v1, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000001"

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
    sput-object v0, Lcom/kousei/framework/v8;->T:Ljava/math/BigInteger;

    .line 14
    .line 15
    return-void
.end method

.method public constructor <init>(Ljava/math/BigInteger;)V
    .registers 14

    .line 1
    const/16 v0, 0x17

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    if-eqz p1, :cond_9d

    .line 7
    .line 8
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-ltz v0, :cond_9d

    .line 13
    .line 14
    sget-object v0, Lcom/kousei/framework/v8;->T:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 17
    .line 18
    .line 19
    move-result v0

    .line 20
    if-gez v0, :cond_9d

    .line 21
    .line 22
    invoke-static {p1}, Lcom/kousei/framework/n6;->J(Ljava/math/BigInteger;)[I

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    const/4 v0, 0x6

    .line 27
    aget v1, p1, v0

    .line 28
    .line 29
    const/4 v2, -0x1

    .line 30
    if-ne v1, v2, :cond_9a

    .line 31
    .line 32
    sget-object v1, Lcom/kousei/framework/h0;->C:[I

    .line 33
    .line 34
    invoke-static {p1, v1}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 35
    .line 36
    .line 37
    move-result v2

    .line 38
    if-eqz v2, :cond_9a

    .line 39
    .line 40
    const/4 v2, 0x0

    .line 41
    aget v3, p1, v2

    .line 42
    .line 43
    int-to-long v3, v3

    .line 44
    const-wide v5, 0xffffffffL

    .line 45
    .line 46
    .line 47
    .line 48
    .line 49
    and-long/2addr v3, v5

    .line 50
    aget v7, v1, v2

    .line 51
    .line 52
    int-to-long v7, v7

    .line 53
    and-long/2addr v7, v5

    .line 54
    sub-long/2addr v3, v7

    .line 55
    long-to-int v7, v3

    .line 56
    aput v7, p1, v2

    .line 57
    .line 58
    const/16 v2, 0x20

    .line 59
    .line 60
    shr-long/2addr v3, v2

    .line 61
    const/4 v7, 0x1

    .line 62
    aget v8, p1, v7

    .line 63
    .line 64
    int-to-long v8, v8

    .line 65
    and-long/2addr v8, v5

    .line 66
    aget v10, v1, v7

    .line 67
    .line 68
    int-to-long v10, v10

    .line 69
    and-long/2addr v10, v5

    .line 70
    sub-long/2addr v8, v10

    .line 71
    add-long/2addr v8, v3

    .line 72
    long-to-int v3, v8

    .line 73
    aput v3, p1, v7

    .line 74
    .line 75
    shr-long v3, v8, v2

    .line 76
    .line 77
    const/4 v7, 0x2

    .line 78
    aget v8, p1, v7

    .line 79
    .line 80
    int-to-long v8, v8

    .line 81
    and-long/2addr v8, v5

    .line 82
    aget v10, v1, v7

    .line 83
    .line 84
    int-to-long v10, v10

    .line 85
    and-long/2addr v10, v5

    .line 86
    sub-long/2addr v8, v10

    .line 87
    add-long/2addr v8, v3

    .line 88
    long-to-int v3, v8

    .line 89
    aput v3, p1, v7

    .line 90
    .line 91
    shr-long v3, v8, v2

    .line 92
    .line 93
    const/4 v7, 0x3

    .line 94
    aget v8, p1, v7

    .line 95
    .line 96
    int-to-long v8, v8

    .line 97
    and-long/2addr v8, v5

    .line 98
    aget v10, v1, v7

    .line 99
    .line 100
    int-to-long v10, v10

    .line 101
    and-long/2addr v10, v5

    .line 102
    sub-long/2addr v8, v10

    .line 103
    add-long/2addr v8, v3

    .line 104
    long-to-int v3, v8

    .line 105
    aput v3, p1, v7

    .line 106
    .line 107
    shr-long v3, v8, v2

    .line 108
    .line 109
    const/4 v7, 0x4

    .line 110
    aget v8, p1, v7

    .line 111
    .line 112
    int-to-long v8, v8

    .line 113
    and-long/2addr v8, v5

    .line 114
    aget v10, v1, v7

    .line 115
    .line 116
    int-to-long v10, v10

    .line 117
    and-long/2addr v10, v5

    .line 118
    sub-long/2addr v8, v10

    .line 119
    add-long/2addr v8, v3

    .line 120
    long-to-int v3, v8

    .line 121
    aput v3, p1, v7

    .line 122
    .line 123
    shr-long v3, v8, v2

    .line 124
    .line 125
    const/4 v7, 0x5

    .line 126
    aget v8, p1, v7

    .line 127
    .line 128
    int-to-long v8, v8

    .line 129
    and-long/2addr v8, v5

    .line 130
    aget v10, v1, v7

    .line 131
    .line 132
    int-to-long v10, v10

    .line 133
    and-long/2addr v10, v5

    .line 134
    sub-long/2addr v8, v10

    .line 135
    add-long/2addr v8, v3

    .line 136
    long-to-int v3, v8

    .line 137
    aput v3, p1, v7

    .line 138
    .line 139
    shr-long v2, v8, v2

    .line 140
    .line 141
    aget v4, p1, v0

    .line 142
    .line 143
    int-to-long v7, v4

    .line 144
    and-long/2addr v7, v5

    .line 145
    aget v1, v1, v0

    .line 146
    .line 147
    int-to-long v9, v1

    .line 148
    and-long v4, v9, v5

    .line 149
    .line 150
    sub-long/2addr v7, v4

    .line 151
    add-long/2addr v7, v2

    .line 152
    long-to-int v1, v7

    .line 153
    aput v1, p1, v0

    .line 154
    .line 155
    :cond_9a
    iput-object p1, p0, Lcom/kousei/framework/v8;->S:[I

    .line 156
    .line 157
    return-void

    .line 158
    :cond_9d
    const-string p0, "x value invalid for SecP224R1FieldElement"

    .line 159
    .line 160
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 161
    .line 162
    .line 163
    const/4 p0, 0x0

    .line 164
    throw p0
.end method

.method public constructor <init>([I)V
    .registers 3

    const/16 v0, 0x17

    .line 165
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 166
    iput-object p1, p0, Lcom/kousei/framework/v8;->S:[I

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->l0([I)Z

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
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->p0([I)Z

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
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/v8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/v8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/v8;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 16
    .line 17
    .line 18
    return-object p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/v8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/v8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/v8;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 16
    .line 17
    .line 18
    return-object p0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/v8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/v8;->S:[I

    .line 7
    .line 8
    sget-object v1, Lcom/kousei/framework/h0;->C:[I

    .line 9
    .line 10
    invoke-static {v1, p1, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 11
    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 14
    .line 15
    invoke-static {v0, p0, v0}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 16
    .line 17
    .line 18
    new-instance p0, Lcom/kousei/framework/v8;

    .line 19
    .line 20
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 21
    .line 22
    .line 23
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 18

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget-object v1, v0, Lcom/kousei/framework/v8;->S:[I

    .line 4
    .line 5
    invoke-static {v1}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-nez v2, :cond_143

    .line 10
    .line 11
    invoke-static {v1}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 12
    .line 13
    .line 14
    move-result v2

    .line 15
    if-eqz v2, :cond_12

    .line 16
    .line 17
    goto/16 :goto_143

    .line 18
    .line 19
    :cond_12
    const/4 v2, 0x7

    .line 20
    new-array v3, v2, [I

    .line 21
    .line 22
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->o1([I[I)V

    .line 23
    .line 24
    .line 25
    new-instance v4, Ljava/util/Random;

    .line 26
    .line 27
    invoke-direct {v4}, Ljava/util/Random;-><init>()V

    .line 28
    .line 29
    .line 30
    new-array v5, v2, [I

    .line 31
    .line 32
    sget-object v6, Lcom/kousei/framework/h0;->C:[I

    .line 33
    .line 34
    const/4 v7, 0x6

    .line 35
    aget v0, v6, v7

    .line 36
    .line 37
    ushr-int/lit8 v8, v0, 0x1

    .line 38
    .line 39
    or-int/2addr v0, v8

    .line 40
    ushr-int/lit8 v8, v0, 0x2

    .line 41
    .line 42
    or-int/2addr v0, v8

    .line 43
    ushr-int/lit8 v8, v0, 0x4

    .line 44
    .line 45
    or-int/2addr v0, v8

    .line 46
    ushr-int/lit8 v8, v0, 0x8

    .line 47
    .line 48
    or-int/2addr v0, v8

    .line 49
    ushr-int/lit8 v8, v0, 0x10

    .line 50
    .line 51
    or-int/2addr v8, v0

    .line 52
    :cond_33
    const/4 v0, 0x0

    .line 53
    move v9, v0

    .line 54
    :goto_35
    if-eq v9, v2, :cond_40

    .line 55
    .line 56
    invoke-virtual {v4}, Ljava/util/Random;->nextInt()I

    .line 57
    .line 58
    .line 59
    move-result v10

    .line 60
    aput v10, v5, v9

    .line 61
    .line 62
    add-int/lit8 v9, v9, 0x1

    .line 63
    .line 64
    goto :goto_35

    .line 65
    :cond_40
    aget v9, v5, v7

    .line 66
    .line 67
    and-int/2addr v9, v8

    .line 68
    aput v9, v5, v7

    .line 69
    .line 70
    invoke-static {v2, v5, v6}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 71
    .line 72
    .line 73
    move-result v9

    .line 74
    if-nez v9, :cond_33

    .line 75
    .line 76
    new-array v9, v2, [I

    .line 77
    .line 78
    new-array v4, v2, [I

    .line 79
    .line 80
    new-array v8, v2, [I

    .line 81
    .line 82
    invoke-static {v1, v4}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 83
    .line 84
    .line 85
    move v10, v0

    .line 86
    :goto_55
    const/16 v11, 0xe

    .line 87
    .line 88
    const/4 v12, -0x1

    .line 89
    const/4 v13, 0x1

    .line 90
    if-ge v10, v2, :cond_71

    .line 91
    .line 92
    invoke-static {v4, v8}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 93
    .line 94
    .line 95
    shl-int/2addr v13, v10

    .line 96
    new-array v11, v11, [I

    .line 97
    .line 98
    :goto_61
    invoke-static {v4, v11}, Lcom/kousei/framework/n6;->Q0([I[I)V

    .line 99
    .line 100
    .line 101
    invoke-static {v11, v4}, Lcom/kousei/framework/h0;->H1([I[I)V

    .line 102
    .line 103
    .line 104
    add-int/2addr v13, v12

    .line 105
    if-lez v13, :cond_6b

    .line 106
    .line 107
    goto :goto_61

    .line 108
    :cond_6b
    invoke-static {v4, v8, v4}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 109
    .line 110
    .line 111
    add-int/lit8 v10, v10, 0x1

    .line 112
    .line 113
    goto :goto_55

    .line 114
    :cond_71
    new-array v8, v11, [I

    .line 115
    .line 116
    invoke-static {v4, v8}, Lcom/kousei/framework/n6;->Q0([I[I)V

    .line 117
    .line 118
    .line 119
    invoke-static {v8, v4}, Lcom/kousei/framework/h0;->H1([I[I)V

    .line 120
    .line 121
    .line 122
    const/16 v10, 0x5f

    .line 123
    .line 124
    :goto_7b
    add-int/2addr v10, v12

    .line 125
    if-lez v10, :cond_85

    .line 126
    .line 127
    invoke-static {v4, v8}, Lcom/kousei/framework/n6;->Q0([I[I)V

    .line 128
    .line 129
    .line 130
    invoke-static {v8, v4}, Lcom/kousei/framework/h0;->H1([I[I)V

    .line 131
    .line 132
    .line 133
    goto :goto_7b

    .line 134
    :cond_85
    invoke-static {v4}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 135
    .line 136
    .line 137
    move-result v4

    .line 138
    if-nez v4, :cond_8d

    .line 139
    .line 140
    goto/16 :goto_128

    .line 141
    .line 142
    :cond_8d
    :goto_8d
    new-array v4, v2, [I

    .line 143
    .line 144
    invoke-static {v5, v4}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 145
    .line 146
    .line 147
    new-array v8, v2, [I

    .line 148
    .line 149
    aput v13, v8, v0

    .line 150
    .line 151
    new-array v10, v2, [I

    .line 152
    .line 153
    invoke-static {v3, v10}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 154
    .line 155
    .line 156
    new-array v11, v2, [I

    .line 157
    .line 158
    new-array v14, v2, [I

    .line 159
    .line 160
    move v15, v0

    .line 161
    :goto_a0
    if-ge v15, v2, :cond_e8

    .line 162
    .line 163
    invoke-static {v4, v11}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 164
    .line 165
    .line 166
    invoke-static {v8, v14}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 167
    .line 168
    .line 169
    shl-int v16, v13, v15

    .line 170
    .line 171
    :goto_aa
    add-int/lit8 v16, v16, -0x1

    .line 172
    .line 173
    if-ltz v16, :cond_c6

    .line 174
    .line 175
    invoke-static {v8, v4, v8}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 176
    .line 177
    .line 178
    invoke-static {v8, v8}, Lcom/kousei/framework/h0;->f3([I[I)V

    .line 179
    .line 180
    .line 181
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 182
    .line 183
    .line 184
    invoke-static {v10, v9, v4}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 185
    .line 186
    .line 187
    invoke-static {v10, v9, v10}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 188
    .line 189
    .line 190
    invoke-static {v2, v10}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 191
    .line 192
    .line 193
    move-result v0

    .line 194
    invoke-static {v0, v10}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 195
    .line 196
    .line 197
    const/4 v0, 0x0

    .line 198
    goto :goto_aa

    .line 199
    :cond_c6
    invoke-static {v8, v14, v9}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 200
    .line 201
    .line 202
    invoke-static {v9, v3, v9}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 203
    .line 204
    .line 205
    invoke-static {v4, v11, v10}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 206
    .line 207
    .line 208
    invoke-static {v10, v9, v10}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 209
    .line 210
    .line 211
    invoke-static {v4, v14, v9}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 212
    .line 213
    .line 214
    invoke-static {v10, v4}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 215
    .line 216
    .line 217
    invoke-static {v8, v11, v8}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 218
    .line 219
    .line 220
    invoke-static {v8, v9, v8}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 221
    .line 222
    .line 223
    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 224
    .line 225
    .line 226
    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 227
    .line 228
    .line 229
    add-int/lit8 v15, v15, 0x1

    .line 230
    .line 231
    const/4 v0, 0x0

    .line 232
    goto :goto_a0

    .line 233
    :cond_e8
    new-array v0, v2, [I

    .line 234
    .line 235
    new-array v11, v2, [I

    .line 236
    .line 237
    move v14, v13

    .line 238
    :goto_ed
    const/16 v15, 0x60

    .line 239
    .line 240
    if-ge v14, v15, :cond_12d

    .line 241
    .line 242
    invoke-static {v4, v0}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 243
    .line 244
    .line 245
    invoke-static {v8, v11}, Lcom/kousei/framework/n6;->t([I[I)V

    .line 246
    .line 247
    .line 248
    invoke-static {v8, v4, v8}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 249
    .line 250
    .line 251
    invoke-static {v8, v8}, Lcom/kousei/framework/h0;->f3([I[I)V

    .line 252
    .line 253
    .line 254
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 255
    .line 256
    .line 257
    invoke-static {v10, v9, v4}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 258
    .line 259
    .line 260
    invoke-static {v10, v9, v10}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 261
    .line 262
    .line 263
    invoke-static {v2, v10}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 264
    .line 265
    .line 266
    move-result v15

    .line 267
    invoke-static {v15, v10}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 268
    .line 269
    .line 270
    invoke-static {v4}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 271
    .line 272
    .line 273
    move-result v15

    .line 274
    if-eqz v15, :cond_12a

    .line 275
    .line 276
    invoke-static {v6, v11, v9}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 277
    .line 278
    .line 279
    invoke-static {v9, v0, v9}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 280
    .line 281
    .line 282
    invoke-static {v9, v5}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 283
    .line 284
    .line 285
    invoke-static {v1, v5}, Lcom/kousei/framework/n6;->D([I[I)Z

    .line 286
    .line 287
    .line 288
    move-result v0

    .line 289
    if-eqz v0, :cond_128

    .line 290
    .line 291
    new-instance v0, Lcom/kousei/framework/v8;

    .line 292
    .line 293
    invoke-direct {v0, v9}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 294
    .line 295
    .line 296
    return-object v0

    .line 297
    :cond_128
    :goto_128
    const/4 v0, 0x0

    .line 298
    return-object v0

    .line 299
    :cond_12a
    add-int/lit8 v14, v14, 0x1

    .line 300
    .line 301
    goto :goto_ed

    .line 302
    :cond_12d
    invoke-static {v2, v5, v5}, Lcom/kousei/framework/n6;->f0(I[I[I)I

    .line 303
    .line 304
    .line 305
    move-result v0

    .line 306
    if-nez v0, :cond_13d

    .line 307
    .line 308
    aget v0, v5, v7

    .line 309
    .line 310
    if-ne v0, v12, :cond_140

    .line 311
    .line 312
    invoke-static {v5, v6}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 313
    .line 314
    .line 315
    move-result v0

    .line 316
    if-eqz v0, :cond_140

    .line 317
    .line 318
    :cond_13d
    invoke-static {v5}, Lcom/kousei/framework/h0;->v([I)V

    .line 319
    .line 320
    .line 321
    :cond_140
    const/4 v0, 0x0

    .line 322
    goto/16 :goto_8d

    .line 323
    .line 324
    :cond_143
    :goto_143
    return-object v0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 5
    .line 6
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 7
    .line 8
    .line 9
    new-instance p0, Lcom/kousei/framework/v8;

    .line 10
    .line 11
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 12
    .line 13
    .line 14
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->j1([I)Ljava/math/BigInteger;

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
    sget-object p0, Lcom/kousei/framework/v8;->T:Ljava/math/BigInteger;

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
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/v8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/v8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/v8;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 16
    .line 17
    .line 18
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
    instance-of v0, p1, Lcom/kousei/framework/v8;

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
    check-cast p1, Lcom/kousei/framework/v8;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/v8;->S:[I

    .line 16
    .line 17
    invoke-static {p0, p1}, Lcom/kousei/framework/n6;->D([I[I)Z

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
    sget-object v0, Lcom/kousei/framework/v8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 8
    .line 9
    const/4 v1, 0x7

    .line 10
    invoke-static {v1, p0}, Lcom/kousei/framework/h0;->h0(I[I)I

    .line 11
    .line 12
    .line 13
    move-result p0

    .line 14
    xor-int/2addr p0, v0

    .line 15
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 5
    .line 6
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->o1([I[I)V

    .line 7
    .line 8
    .line 9
    new-instance p0, Lcom/kousei/framework/v8;

    .line 10
    .line 11
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 12
    .line 13
    .line 14
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v1, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 5
    .line 6
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->f0(I[I[I)I

    .line 7
    .line 8
    .line 9
    move-result p0

    .line 10
    if-nez p0, :cond_19

    .line 11
    .line 12
    const/4 p0, 0x6

    .line 13
    aget p0, v1, p0

    .line 14
    .line 15
    const/4 v0, -0x1

    .line 16
    if-ne p0, v0, :cond_1c

    .line 17
    .line 18
    sget-object p0, Lcom/kousei/framework/h0;->C:[I

    .line 19
    .line 20
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 21
    .line 22
    .line 23
    move-result p0

    .line 24
    if-eqz p0, :cond_1c

    .line 25
    .line 26
    :cond_19
    invoke-static {v1}, Lcom/kousei/framework/h0;->v([I)V

    .line 27
    .line 28
    .line 29
    :cond_1c
    new-instance p0, Lcom/kousei/framework/v8;

    .line 30
    .line 31
    invoke-direct {p0, v1}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 32
    .line 33
    .line 34
    return-object p0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/v8;->S:[I

    .line 5
    .line 6
    sget-object v1, Lcom/kousei/framework/h0;->C:[I

    .line 7
    .line 8
    invoke-static {v1, p0, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 9
    .line 10
    .line 11
    new-instance p0, Lcom/kousei/framework/v8;

    .line 12
    .line 13
    invoke-direct {p0, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 14
    .line 15
    .line 16
    return-object p0
.end method
