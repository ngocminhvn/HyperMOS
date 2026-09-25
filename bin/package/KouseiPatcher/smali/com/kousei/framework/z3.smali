.class public final Lcom/kousei/framework/z3;
.super Lcom/kousei/framework/x3;


# instance fields
.field public final S:I

.field public final T:I

.field public final U:[I

.field public final V:Lcom/kousei/framework/g6;


# direct methods
.method public constructor <init>(I[ILcom/kousei/framework/g6;)V
    .registers 5

    .line 1
    const/16 v0, 0x17

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    iput p1, p0, Lcom/kousei/framework/z3;->T:I

    .line 7
    .line 8
    array-length p1, p2

    .line 9
    const/4 v0, 0x1

    .line 10
    if-ne p1, v0, :cond_d

    .line 11
    .line 12
    const/4 p1, 0x2

    .line 13
    goto :goto_e

    .line 14
    :cond_d
    const/4 p1, 0x3

    .line 15
    :goto_e
    iput p1, p0, Lcom/kousei/framework/z3;->S:I

    .line 16
    .line 17
    iput-object p2, p0, Lcom/kousei/framework/z3;->U:[I

    .line 18
    .line 19
    iput-object p3, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 20
    .line 21
    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    invoke-virtual {p0}, Lcom/kousei/framework/g6;->l()Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final B2(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 13

    .line 1
    check-cast p1, Lcom/kousei/framework/z3;

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 4
    .line 5
    check-cast p2, Lcom/kousei/framework/z3;

    .line 6
    .line 7
    iget-object p2, p2, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 8
    .line 9
    iget-object v0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 10
    .line 11
    invoke-virtual {v0}, Lcom/kousei/framework/g6;->j()I

    .line 12
    .line 13
    .line 14
    move-result v1

    .line 15
    const/4 v2, 0x0

    .line 16
    if-nez v1, :cond_13

    .line 17
    .line 18
    move-object v4, v0

    .line 19
    goto :goto_3b

    .line 20
    :cond_13
    shl-int/lit8 v1, v1, 0x1

    .line 21
    .line 22
    new-array v3, v1, [J

    .line 23
    .line 24
    move v4, v2

    .line 25
    :goto_18
    if-ge v4, v1, :cond_36

    .line 26
    .line 27
    iget-object v5, v0, Lcom/kousei/framework/g6;->a:[J

    .line 28
    .line 29
    ushr-int/lit8 v6, v4, 0x1

    .line 30
    .line 31
    aget-wide v5, v5, v6

    .line 32
    .line 33
    add-int/lit8 v7, v4, 0x1

    .line 34
    .line 35
    long-to-int v8, v5

    .line 36
    invoke-static {v8}, Lcom/kousei/framework/g6;->k(I)J

    .line 37
    .line 38
    .line 39
    move-result-wide v8

    .line 40
    aput-wide v8, v3, v4

    .line 41
    .line 42
    add-int/lit8 v4, v4, 0x2

    .line 43
    .line 44
    const/16 v8, 0x20

    .line 45
    .line 46
    ushr-long/2addr v5, v8

    .line 47
    long-to-int v5, v5

    .line 48
    invoke-static {v5}, Lcom/kousei/framework/g6;->k(I)J

    .line 49
    .line 50
    .line 51
    move-result-wide v5

    .line 52
    aput-wide v5, v3, v7

    .line 53
    .line 54
    goto :goto_18

    .line 55
    :cond_36
    new-instance v4, Lcom/kousei/framework/g6;

    .line 56
    .line 57
    invoke-direct {v4, v3, v1}, Lcom/kousei/framework/g6;-><init>([JI)V

    .line 58
    .line 59
    .line 60
    :goto_3b
    invoke-virtual {p1, p2}, Lcom/kousei/framework/g6;->m(Lcom/kousei/framework/g6;)Lcom/kousei/framework/g6;

    .line 61
    .line 62
    .line 63
    move-result-object p1

    .line 64
    if-ne v4, v0, :cond_48

    .line 65
    .line 66
    invoke-virtual {v4}, Lcom/kousei/framework/g6;->clone()Ljava/lang/Object;

    .line 67
    .line 68
    .line 69
    move-result-object p2

    .line 70
    move-object v4, p2

    .line 71
    check-cast v4, Lcom/kousei/framework/g6;

    .line 72
    .line 73
    :cond_48
    invoke-virtual {v4, p1}, Lcom/kousei/framework/g6;->c(Lcom/kousei/framework/g6;)V

    .line 74
    .line 75
    .line 76
    iget-object p1, v4, Lcom/kousei/framework/g6;->a:[J

    .line 77
    .line 78
    array-length p2, p1

    .line 79
    iget v0, p0, Lcom/kousei/framework/z3;->T:I

    .line 80
    .line 81
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 82
    .line 83
    invoke-static {p1, p2, v0, p0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 84
    .line 85
    .line 86
    move-result p2

    .line 87
    array-length v1, p1

    .line 88
    if-ge p2, v1, :cond_60

    .line 89
    .line 90
    new-array v1, p2, [J

    .line 91
    .line 92
    iput-object v1, v4, Lcom/kousei/framework/g6;->a:[J

    .line 93
    .line 94
    invoke-static {p1, v2, v1, v2, p2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 95
    .line 96
    .line 97
    :cond_60
    new-instance p1, Lcom/kousei/framework/z3;

    .line 98
    .line 99
    invoke-direct {p1, v0, p0, v4}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 100
    .line 101
    .line 102
    return-object p1
.end method

.method public final C2(I)Lcom/kousei/framework/h0;
    .registers 13

    .line 1
    const/4 v0, 0x1

    .line 2
    if-ge p1, v0, :cond_4

    .line 3
    .line 4
    return-object p0

    .line 5
    :cond_4
    new-instance v1, Lcom/kousei/framework/z3;

    .line 6
    .line 7
    iget-object v2, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 8
    .line 9
    invoke-virtual {v2}, Lcom/kousei/framework/g6;->j()I

    .line 10
    .line 11
    .line 12
    move-result v3

    .line 13
    iget v4, p0, Lcom/kousei/framework/z3;->T:I

    .line 14
    .line 15
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 16
    .line 17
    if-nez v3, :cond_13

    .line 18
    .line 19
    goto :goto_4e

    .line 20
    :cond_13
    add-int/lit8 v5, v4, 0x3f

    .line 21
    .line 22
    ushr-int/lit8 v5, v5, 0x6

    .line 23
    .line 24
    shl-int/lit8 v0, v5, 0x1

    .line 25
    .line 26
    new-array v5, v0, [J

    .line 27
    .line 28
    iget-object v2, v2, Lcom/kousei/framework/g6;->a:[J

    .line 29
    .line 30
    const/4 v6, 0x0

    .line 31
    invoke-static {v2, v6, v5, v6, v3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 32
    .line 33
    .line 34
    :goto_21
    add-int/lit8 p1, p1, -0x1

    .line 35
    .line 36
    if-ltz p1, :cond_49

    .line 37
    .line 38
    shl-int/lit8 v2, v3, 0x1

    .line 39
    .line 40
    :goto_27
    add-int/lit8 v3, v3, -0x1

    .line 41
    .line 42
    if-ltz v3, :cond_44

    .line 43
    .line 44
    aget-wide v6, v5, v3

    .line 45
    .line 46
    add-int/lit8 v8, v2, -0x1

    .line 47
    .line 48
    const/16 v9, 0x20

    .line 49
    .line 50
    ushr-long v9, v6, v9

    .line 51
    .line 52
    long-to-int v9, v9

    .line 53
    invoke-static {v9}, Lcom/kousei/framework/g6;->k(I)J

    .line 54
    .line 55
    .line 56
    move-result-wide v9

    .line 57
    aput-wide v9, v5, v8

    .line 58
    .line 59
    add-int/lit8 v2, v2, -0x2

    .line 60
    .line 61
    long-to-int v6, v6

    .line 62
    invoke-static {v6}, Lcom/kousei/framework/g6;->k(I)J

    .line 63
    .line 64
    .line 65
    move-result-wide v6

    .line 66
    aput-wide v6, v5, v2

    .line 67
    .line 68
    goto :goto_27

    .line 69
    :cond_44
    invoke-static {v5, v0, v4, p0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 70
    .line 71
    .line 72
    move-result v3

    .line 73
    goto :goto_21

    .line 74
    :cond_49
    new-instance v2, Lcom/kousei/framework/g6;

    .line 75
    .line 76
    invoke-direct {v2, v5, v3}, Lcom/kousei/framework/g6;-><init>([JI)V

    .line 77
    .line 78
    .line 79
    :goto_4e
    invoke-direct {v1, v4, p0, v2}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 80
    .line 81
    .line 82
    return-object v1
.end method

.method public final D()I
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    invoke-virtual {p0}, Lcom/kousei/framework/g6;->e()I

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final E0()Z
    .registers 7

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/g6;->a:[J

    .line 4
    .line 5
    const/4 v0, 0x0

    .line 6
    move v1, v0

    .line 7
    :goto_6
    array-length v2, p0

    .line 8
    if-ge v1, v2, :cond_15

    .line 9
    .line 10
    aget-wide v2, p0, v1

    .line 11
    .line 12
    const-wide/16 v4, 0x0

    .line 13
    .line 14
    cmp-long v2, v2, v4

    .line 15
    .line 16
    if-eqz v2, :cond_12

    .line 17
    .line 18
    return v0

    .line 19
    :cond_12
    add-int/lit8 v1, v1, 0x1

    .line 20
    .line 21
    goto :goto_6

    .line 22
    :cond_15
    const/4 p0, 0x1

    .line 23
    return p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 28

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    new-instance v1, Lcom/kousei/framework/z3;

    .line 4
    .line 5
    move-object/from16 v2, p1

    .line 6
    .line 7
    check-cast v2, Lcom/kousei/framework/z3;

    .line 8
    .line 9
    iget-object v2, v2, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 10
    .line 11
    iget-object v3, v0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 12
    .line 13
    invoke-virtual {v3}, Lcom/kousei/framework/g6;->e()I

    .line 14
    .line 15
    .line 16
    move-result v4

    .line 17
    iget v5, v0, Lcom/kousei/framework/z3;->T:I

    .line 18
    .line 19
    iget-object v0, v0, Lcom/kousei/framework/z3;->U:[I

    .line 20
    .line 21
    if-nez v4, :cond_1a

    .line 22
    .line 23
    :goto_16
    move-object v2, v3

    .line 24
    :goto_17
    move v15, v5

    .line 25
    goto/16 :goto_11a

    .line 26
    .line 27
    :cond_1a
    invoke-virtual {v2}, Lcom/kousei/framework/g6;->e()I

    .line 28
    .line 29
    .line 30
    move-result v6

    .line 31
    if-nez v6, :cond_21

    .line 32
    .line 33
    :goto_20
    goto :goto_17

    .line 34
    :cond_21
    if-le v4, v6, :cond_2d

    .line 35
    .line 36
    move-object/from16 v25, v3

    .line 37
    .line 38
    move-object v3, v2

    .line 39
    move-object/from16 v2, v25

    .line 40
    .line 41
    move/from16 v25, v6

    .line 42
    .line 43
    move v6, v4

    .line 44
    move/from16 v4, v25

    .line 45
    .line 46
    :cond_2d
    add-int/lit8 v7, v4, 0x3f

    .line 47
    .line 48
    ushr-int/lit8 v7, v7, 0x6

    .line 49
    .line 50
    add-int/lit8 v8, v6, 0x3f

    .line 51
    .line 52
    ushr-int/lit8 v8, v8, 0x6

    .line 53
    .line 54
    add-int/2addr v4, v6

    .line 55
    add-int/lit8 v4, v4, 0x3e

    .line 56
    .line 57
    ushr-int/lit8 v13, v4, 0x6

    .line 58
    .line 59
    const/4 v4, 0x0

    .line 60
    const/4 v9, 0x1

    .line 61
    if-ne v7, v9, :cond_5a

    .line 62
    .line 63
    iget-object v3, v3, Lcom/kousei/framework/g6;->a:[J

    .line 64
    .line 65
    aget-wide v3, v3, v4

    .line 66
    .line 67
    const-wide/16 v6, 0x1

    .line 68
    .line 69
    cmp-long v6, v3, v6

    .line 70
    .line 71
    if-nez v6, :cond_49

    .line 72
    .line 73
    goto :goto_20

    .line 74
    :cond_49
    new-array v6, v13, [J

    .line 75
    .line 76
    iget-object v2, v2, Lcom/kousei/framework/g6;->a:[J

    .line 77
    .line 78
    invoke-static {v3, v4, v2, v8, v6}, Lcom/kousei/framework/g6;->n(J[JI[J)V

    .line 79
    .line 80
    .line 81
    invoke-static {v6, v13, v5, v0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 82
    .line 83
    .line 84
    move-result v2

    .line 85
    new-instance v3, Lcom/kousei/framework/g6;

    .line 86
    .line 87
    invoke-direct {v3, v6, v2}, Lcom/kousei/framework/g6;-><init>([JI)V

    .line 88
    .line 89
    .line 90
    goto :goto_16

    .line 91
    :cond_5a
    add-int/lit8 v6, v6, 0x46

    .line 92
    .line 93
    ushr-int/lit8 v6, v6, 0x6

    .line 94
    .line 95
    const/16 v10, 0x10

    .line 96
    .line 97
    new-array v11, v10, [I

    .line 98
    .line 99
    shl-int/lit8 v12, v6, 0x4

    .line 100
    .line 101
    new-array v14, v12, [J

    .line 102
    .line 103
    aput v6, v11, v9

    .line 104
    .line 105
    iget-object v2, v2, Lcom/kousei/framework/g6;->a:[J

    .line 106
    .line 107
    invoke-static {v2, v4, v14, v6, v8}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 108
    .line 109
    .line 110
    const/4 v2, 0x2

    .line 111
    move v8, v6

    .line 112
    :goto_6f
    if-ge v2, v10, :cond_a0

    .line 113
    .line 114
    add-int v17, v8, v6

    .line 115
    .line 116
    aput v17, v11, v2

    .line 117
    .line 118
    and-int/lit8 v8, v2, 0x1

    .line 119
    .line 120
    if-nez v8, :cond_85

    .line 121
    .line 122
    ushr-int/lit8 v15, v17, 0x1

    .line 123
    .line 124
    const/16 v19, 0x1

    .line 125
    .line 126
    move-object/from16 v16, v14

    .line 127
    .line 128
    move/from16 v18, v6

    .line 129
    .line 130
    invoke-static/range {v14 .. v19}, Lcom/kousei/framework/g6;->p([JI[JIII)V

    .line 131
    .line 132
    .line 133
    goto :goto_9b

    .line 134
    :cond_85
    sub-int v8, v17, v6

    .line 135
    .line 136
    move v9, v4

    .line 137
    :goto_88
    if-ge v9, v6, :cond_9b

    .line 138
    .line 139
    add-int v15, v17, v9

    .line 140
    .line 141
    add-int v16, v6, v9

    .line 142
    .line 143
    aget-wide v18, v14, v16

    .line 144
    .line 145
    add-int v16, v8, v9

    .line 146
    .line 147
    aget-wide v20, v14, v16

    .line 148
    .line 149
    xor-long v18, v18, v20

    .line 150
    .line 151
    aput-wide v18, v14, v15

    .line 152
    .line 153
    add-int/lit8 v9, v9, 0x1

    .line 154
    .line 155
    goto :goto_88

    .line 156
    :cond_9b
    :goto_9b
    add-int/lit8 v2, v2, 0x1

    .line 157
    .line 158
    move/from16 v8, v17

    .line 159
    .line 160
    goto :goto_6f

    .line 161
    :cond_a0
    new-array v2, v12, [J

    .line 162
    .line 163
    const/16 v17, 0x0

    .line 164
    .line 165
    const/16 v19, 0x4

    .line 166
    .line 167
    const/4 v15, 0x0

    .line 168
    move-object/from16 v16, v2

    .line 169
    .line 170
    move/from16 v18, v12

    .line 171
    .line 172
    invoke-static/range {v14 .. v19}, Lcom/kousei/framework/g6;->p([JI[JIII)V

    .line 173
    .line 174
    .line 175
    iget-object v2, v3, Lcom/kousei/framework/g6;->a:[J

    .line 176
    .line 177
    shl-int/lit8 v3, v13, 0x3

    .line 178
    .line 179
    new-array v9, v3, [J

    .line 180
    .line 181
    move v8, v4

    .line 182
    :goto_b5
    if-ge v8, v7, :cond_ff

    .line 183
    .line 184
    aget-wide v17, v2, v8

    .line 185
    .line 186
    move v15, v5

    .line 187
    move v10, v8

    .line 188
    move-wide/from16 v4, v17

    .line 189
    .line 190
    :goto_bd
    long-to-int v12, v4

    .line 191
    and-int/lit8 v12, v12, 0xf

    .line 192
    .line 193
    const/16 v17, 0x4

    .line 194
    .line 195
    move-object/from16 v18, v2

    .line 196
    .line 197
    move/from16 p1, v3

    .line 198
    .line 199
    ushr-long v2, v4, v17

    .line 200
    .line 201
    long-to-int v2, v2

    .line 202
    and-int/lit8 v2, v2, 0xf

    .line 203
    .line 204
    aget v3, v11, v12

    .line 205
    .line 206
    aget v2, v11, v2

    .line 207
    .line 208
    const/4 v12, 0x0

    .line 209
    :goto_d0
    if-ge v12, v6, :cond_e7

    .line 210
    .line 211
    add-int v17, v10, v12

    .line 212
    .line 213
    aget-wide v19, v9, v17

    .line 214
    .line 215
    add-int v21, v3, v12

    .line 216
    .line 217
    aget-wide v21, v14, v21

    .line 218
    .line 219
    add-int v23, v2, v12

    .line 220
    .line 221
    aget-wide v23, v16, v23

    .line 222
    .line 223
    xor-long v21, v21, v23

    .line 224
    .line 225
    xor-long v19, v19, v21

    .line 226
    .line 227
    aput-wide v19, v9, v17

    .line 228
    .line 229
    add-int/lit8 v12, v12, 0x1

    .line 230
    .line 231
    goto :goto_d0

    .line 232
    :cond_e7
    const/16 v2, 0x8

    .line 233
    .line 234
    ushr-long/2addr v4, v2

    .line 235
    const-wide/16 v2, 0x0

    .line 236
    .line 237
    cmp-long v2, v4, v2

    .line 238
    .line 239
    if-nez v2, :cond_f9

    .line 240
    .line 241
    add-int/lit8 v8, v8, 0x1

    .line 242
    .line 243
    move/from16 v3, p1

    .line 244
    .line 245
    move v5, v15

    .line 246
    move-object/from16 v2, v18

    .line 247
    .line 248
    const/4 v4, 0x0

    .line 249
    goto :goto_b5

    .line 250
    :cond_f9
    add-int/2addr v10, v13

    .line 251
    move/from16 v3, p1

    .line 252
    .line 253
    move-object/from16 v2, v18

    .line 254
    .line 255
    goto :goto_bd

    .line 256
    :cond_ff
    move/from16 p1, v3

    .line 257
    .line 258
    move v15, v5

    .line 259
    :goto_102
    sub-int v12, v3, v13

    .line 260
    .line 261
    if-eqz v12, :cond_110

    .line 262
    .line 263
    sub-int v10, v12, v13

    .line 264
    .line 265
    const/16 v14, 0x8

    .line 266
    .line 267
    move-object v11, v9

    .line 268
    invoke-static/range {v9 .. v14}, Lcom/kousei/framework/g6;->d([JI[JIII)J

    .line 269
    .line 270
    .line 271
    move v3, v12

    .line 272
    goto :goto_102

    .line 273
    :cond_110
    invoke-static {v9, v13, v15, v0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 274
    .line 275
    .line 276
    move-result v2

    .line 277
    new-instance v3, Lcom/kousei/framework/g6;

    .line 278
    .line 279
    invoke-direct {v3, v9, v2}, Lcom/kousei/framework/g6;-><init>([JI)V

    .line 280
    .line 281
    .line 282
    move-object v2, v3

    .line 283
    :goto_11a
    invoke-direct {v1, v15, v0, v2}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 284
    .line 285
    .line 286
    return-object v1
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
    invoke-virtual {p0, p1}, Lcom/kousei/framework/z3;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 8

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    iget-object v1, v0, Lcom/kousei/framework/g6;->a:[J

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    :goto_5
    array-length v3, v1

    .line 7
    if-ge v2, v3, :cond_23

    .line 8
    .line 9
    aget-wide v3, v1, v2

    .line 10
    .line 11
    const-wide/16 v5, 0x0

    .line 12
    .line 13
    cmp-long v3, v3, v5

    .line 14
    .line 15
    if-eqz v3, :cond_20

    .line 16
    .line 17
    invoke-virtual {v0}, Lcom/kousei/framework/g6;->l()Z

    .line 18
    .line 19
    .line 20
    move-result v0

    .line 21
    if-eqz v0, :cond_17

    .line 22
    .line 23
    goto :goto_23

    .line 24
    :cond_17
    iget v0, p0, Lcom/kousei/framework/z3;->T:I

    .line 25
    .line 26
    add-int/lit8 v0, v0, -0x1

    .line 27
    .line 28
    invoke-virtual {p0, v0}, Lcom/kousei/framework/z3;->C2(I)Lcom/kousei/framework/h0;

    .line 29
    .line 30
    .line 31
    move-result-object p0

    .line 32
    return-object p0

    .line 33
    :cond_20
    add-int/lit8 v2, v2, 0x1

    .line 34
    .line 35
    goto :goto_5

    .line 36
    :cond_23
    :goto_23
    return-object p0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 12

    .line 1
    new-instance v0, Lcom/kousei/framework/z3;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 4
    .line 5
    invoke-virtual {v1}, Lcom/kousei/framework/g6;->j()I

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    iget v3, p0, Lcom/kousei/framework/z3;->T:I

    .line 10
    .line 11
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 12
    .line 13
    if-nez v2, :cond_f

    .line 14
    .line 15
    goto :goto_3b

    .line 16
    :cond_f
    shl-int/lit8 v2, v2, 0x1

    .line 17
    .line 18
    new-array v4, v2, [J

    .line 19
    .line 20
    const/4 v5, 0x0

    .line 21
    :goto_14
    if-ge v5, v2, :cond_32

    .line 22
    .line 23
    iget-object v6, v1, Lcom/kousei/framework/g6;->a:[J

    .line 24
    .line 25
    ushr-int/lit8 v7, v5, 0x1

    .line 26
    .line 27
    aget-wide v6, v6, v7

    .line 28
    .line 29
    add-int/lit8 v8, v5, 0x1

    .line 30
    .line 31
    long-to-int v9, v6

    .line 32
    invoke-static {v9}, Lcom/kousei/framework/g6;->k(I)J

    .line 33
    .line 34
    .line 35
    move-result-wide v9

    .line 36
    aput-wide v9, v4, v5

    .line 37
    .line 38
    add-int/lit8 v5, v5, 0x2

    .line 39
    .line 40
    const/16 v9, 0x20

    .line 41
    .line 42
    ushr-long/2addr v6, v9

    .line 43
    long-to-int v6, v6

    .line 44
    invoke-static {v6}, Lcom/kousei/framework/g6;->k(I)J

    .line 45
    .line 46
    .line 47
    move-result-wide v6

    .line 48
    aput-wide v6, v4, v8

    .line 49
    .line 50
    goto :goto_14

    .line 51
    :cond_32
    new-instance v1, Lcom/kousei/framework/g6;

    .line 52
    .line 53
    invoke-static {v4, v2, v3, p0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 54
    .line 55
    .line 56
    move-result v2

    .line 57
    invoke-direct {v1, v4, v2}, Lcom/kousei/framework/g6;-><init>([JI)V

    .line 58
    .line 59
    .line 60
    :goto_3b
    invoke-direct {v0, v3, p0, v1}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 61
    .line 62
    .line 63
    return-object v0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 15

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    invoke-virtual {p0}, Lcom/kousei/framework/g6;->j()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    if-nez v0, :cond_b

    .line 8
    .line 9
    sget-object p0, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 10
    .line 11
    return-object p0

    .line 12
    :cond_b
    iget-object v1, p0, Lcom/kousei/framework/g6;->a:[J

    .line 13
    .line 14
    add-int/lit8 v2, v0, -0x1

    .line 15
    .line 16
    aget-wide v3, v1, v2

    .line 17
    .line 18
    const/16 v1, 0x8

    .line 19
    .line 20
    new-array v5, v1, [B

    .line 21
    .line 22
    const/4 v6, 0x7

    .line 23
    const/4 v7, 0x0

    .line 24
    move v8, v6

    .line 25
    move v9, v7

    .line 26
    move v10, v9

    .line 27
    :goto_1a
    const/4 v11, 0x1

    .line 28
    if-ltz v8, :cond_30

    .line 29
    .line 30
    mul-int/lit8 v12, v8, 0x8

    .line 31
    .line 32
    ushr-long v12, v3, v12

    .line 33
    .line 34
    long-to-int v12, v12

    .line 35
    int-to-byte v12, v12

    .line 36
    if-nez v10, :cond_27

    .line 37
    .line 38
    if-eqz v12, :cond_2d

    .line 39
    .line 40
    :cond_27
    add-int/lit8 v10, v9, 0x1

    .line 41
    .line 42
    aput-byte v12, v5, v9

    .line 43
    .line 44
    move v9, v10

    .line 45
    move v10, v11

    .line 46
    :cond_2d
    add-int/lit8 v8, v8, -0x1

    .line 47
    .line 48
    goto :goto_1a

    .line 49
    :cond_30
    mul-int/2addr v2, v1

    .line 50
    add-int/2addr v2, v9

    .line 51
    new-array v1, v2, [B

    .line 52
    .line 53
    :goto_34
    if-ge v7, v9, :cond_3d

    .line 54
    .line 55
    aget-byte v2, v5, v7

    .line 56
    .line 57
    aput-byte v2, v1, v7

    .line 58
    .line 59
    add-int/lit8 v7, v7, 0x1

    .line 60
    .line 61
    goto :goto_34

    .line 62
    :cond_3d
    add-int/lit8 v0, v0, -0x2

    .line 63
    .line 64
    :goto_3f
    if-ltz v0, :cond_59

    .line 65
    .line 66
    iget-object v2, p0, Lcom/kousei/framework/g6;->a:[J

    .line 67
    .line 68
    aget-wide v2, v2, v0

    .line 69
    .line 70
    move v4, v6

    .line 71
    :goto_46
    if-ltz v4, :cond_56

    .line 72
    .line 73
    add-int/lit8 v5, v9, 0x1

    .line 74
    .line 75
    mul-int/lit8 v7, v4, 0x8

    .line 76
    .line 77
    ushr-long v7, v2, v7

    .line 78
    .line 79
    long-to-int v7, v7

    .line 80
    int-to-byte v7, v7

    .line 81
    aput-byte v7, v1, v9

    .line 82
    .line 83
    add-int/lit8 v4, v4, -0x1

    .line 84
    .line 85
    move v9, v5

    .line 86
    goto :goto_46

    .line 87
    :cond_56
    add-int/lit8 v0, v0, -0x1

    .line 88
    .line 89
    goto :goto_3f

    .line 90
    :cond_59
    new-instance p0, Ljava/math/BigInteger;

    .line 91
    .line 92
    invoke-direct {p0, v11, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 93
    .line 94
    .line 95
    return-object p0
.end method

.method public final a0()I
    .registers 1

    .line 1
    iget p0, p0, Lcom/kousei/framework/z3;->T:I

    .line 2
    .line 3
    return p0
.end method

.method public final b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    invoke-virtual {v0}, Lcom/kousei/framework/g6;->clone()Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    check-cast v0, Lcom/kousei/framework/g6;

    .line 8
    .line 9
    check-cast p1, Lcom/kousei/framework/z3;

    .line 10
    .line 11
    iget-object p1, p1, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 12
    .line 13
    invoke-virtual {v0, p1}, Lcom/kousei/framework/g6;->c(Lcom/kousei/framework/g6;)V

    .line 14
    .line 15
    .line 16
    new-instance p1, Lcom/kousei/framework/z3;

    .line 17
    .line 18
    iget v1, p0, Lcom/kousei/framework/z3;->T:I

    .line 19
    .line 20
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 21
    .line 22
    invoke-direct {p1, v1, p0, v0}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 23
    .line 24
    .line 25
    return-object p1
.end method

.method public final equals(Ljava/lang/Object;)Z
    .registers 6

    .line 1
    const/4 v0, 0x1

    .line 2
    if-ne p1, p0, :cond_4

    .line 3
    .line 4
    return v0

    .line 5
    :cond_4
    instance-of v1, p1, Lcom/kousei/framework/z3;

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
    check-cast p1, Lcom/kousei/framework/z3;

    .line 12
    .line 13
    iget v1, p0, Lcom/kousei/framework/z3;->T:I

    .line 14
    .line 15
    iget v3, p1, Lcom/kousei/framework/z3;->T:I

    .line 16
    .line 17
    if-ne v1, v3, :cond_2d

    .line 18
    .line 19
    iget v1, p0, Lcom/kousei/framework/z3;->S:I

    .line 20
    .line 21
    iget v3, p1, Lcom/kousei/framework/z3;->S:I

    .line 22
    .line 23
    if-ne v1, v3, :cond_2d

    .line 24
    .line 25
    iget-object v1, p0, Lcom/kousei/framework/z3;->U:[I

    .line 26
    .line 27
    iget-object v3, p1, Lcom/kousei/framework/z3;->U:[I

    .line 28
    .line 29
    invoke-static {v1, v3}, Ljava/util/Arrays;->equals([I[I)Z

    .line 30
    .line 31
    .line 32
    move-result v1

    .line 33
    if-eqz v1, :cond_2d

    .line 34
    .line 35
    iget-object p0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 36
    .line 37
    iget-object p1, p1, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 38
    .line 39
    invoke-virtual {p0, p1}, Lcom/kousei/framework/g6;->equals(Ljava/lang/Object;)Z

    .line 40
    .line 41
    .line 42
    move-result p0

    .line 43
    if-eqz p0, :cond_2d

    .line 44
    .line 45
    return v0

    .line 46
    :cond_2d
    return v2
.end method

.method public final hashCode()I
    .registers 5

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 2
    .line 3
    invoke-virtual {v0}, Lcom/kousei/framework/g6;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget v1, p0, Lcom/kousei/framework/z3;->T:I

    .line 8
    .line 9
    xor-int/2addr v0, v1

    .line 10
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 11
    .line 12
    if-nez p0, :cond_f

    .line 13
    .line 14
    const/4 p0, 0x0

    .line 15
    goto :goto_1d

    .line 16
    :cond_f
    array-length v1, p0

    .line 17
    add-int/lit8 v2, v1, 0x1

    .line 18
    .line 19
    :goto_12
    add-int/lit8 v1, v1, -0x1

    .line 20
    .line 21
    if-ltz v1, :cond_1c

    .line 22
    .line 23
    mul-int/lit16 v2, v2, 0x101

    .line 24
    .line 25
    aget v3, p0, v1

    .line 26
    .line 27
    xor-int/2addr v2, v3

    .line 28
    goto :goto_12

    .line 29
    :cond_1c
    move p0, v2

    .line 30
    :goto_1d
    xor-int/2addr p0, v0

    .line 31
    return p0
.end method

.method public final k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    invoke-virtual {p0, p1, p2, p3}, Lcom/kousei/framework/z3;->l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    return-object p0
.end method

.method public final l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 7

    .line 1
    check-cast p1, Lcom/kousei/framework/z3;

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 4
    .line 5
    check-cast p2, Lcom/kousei/framework/z3;

    .line 6
    .line 7
    iget-object p2, p2, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 8
    .line 9
    check-cast p3, Lcom/kousei/framework/z3;

    .line 10
    .line 11
    iget-object p3, p3, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 12
    .line 13
    iget-object v0, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 14
    .line 15
    invoke-virtual {v0, p1}, Lcom/kousei/framework/g6;->m(Lcom/kousei/framework/g6;)Lcom/kousei/framework/g6;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    invoke-virtual {p2, p3}, Lcom/kousei/framework/g6;->m(Lcom/kousei/framework/g6;)Lcom/kousei/framework/g6;

    .line 20
    .line 21
    .line 22
    move-result-object p2

    .line 23
    if-eq v1, v0, :cond_1a

    .line 24
    .line 25
    if-ne v1, p1, :cond_21

    .line 26
    .line 27
    :cond_1a
    invoke-virtual {v1}, Lcom/kousei/framework/g6;->clone()Ljava/lang/Object;

    .line 28
    .line 29
    .line 30
    move-result-object p1

    .line 31
    move-object v1, p1

    .line 32
    check-cast v1, Lcom/kousei/framework/g6;

    .line 33
    .line 34
    :cond_21
    invoke-virtual {v1, p2}, Lcom/kousei/framework/g6;->c(Lcom/kousei/framework/g6;)V

    .line 35
    .line 36
    .line 37
    iget-object p1, v1, Lcom/kousei/framework/g6;->a:[J

    .line 38
    .line 39
    array-length p2, p1

    .line 40
    iget p3, p0, Lcom/kousei/framework/z3;->T:I

    .line 41
    .line 42
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 43
    .line 44
    invoke-static {p1, p2, p3, p0}, Lcom/kousei/framework/g6;->o([JII[I)I

    .line 45
    .line 46
    .line 47
    move-result p2

    .line 48
    array-length v0, p1

    .line 49
    if-ge p2, v0, :cond_3a

    .line 50
    .line 51
    new-array v0, p2, [J

    .line 52
    .line 53
    iput-object v0, v1, Lcom/kousei/framework/g6;->a:[J

    .line 54
    .line 55
    const/4 v2, 0x0

    .line 56
    invoke-static {p1, v2, v0, v2, p2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 57
    .line 58
    .line 59
    :cond_3a
    new-instance p1, Lcom/kousei/framework/z3;

    .line 60
    .line 61
    invoke-direct {p1, p3, p0, v1}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 62
    .line 63
    .line 64
    return-object p1
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 1

    .line 1
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 9

    .line 1
    new-instance v0, Lcom/kousei/framework/z3;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 4
    .line 5
    iget-object v2, v1, Lcom/kousei/framework/g6;->a:[J

    .line 6
    .line 7
    array-length v2, v2

    .line 8
    const/4 v3, 0x1

    .line 9
    const/4 v4, 0x0

    .line 10
    const-wide/16 v5, 0x1

    .line 11
    .line 12
    if-nez v2, :cond_17

    .line 13
    .line 14
    new-instance v1, Lcom/kousei/framework/g6;

    .line 15
    .line 16
    new-array v2, v3, [J

    .line 17
    .line 18
    aput-wide v5, v2, v4

    .line 19
    .line 20
    invoke-direct {v1, v2}, Lcom/kousei/framework/g6;-><init>([J)V

    .line 21
    .line 22
    .line 23
    goto :goto_35

    .line 24
    :cond_17
    invoke-virtual {v1}, Lcom/kousei/framework/g6;->j()I

    .line 25
    .line 26
    .line 27
    move-result v2

    .line 28
    invoke-static {v3, v2}, Ljava/lang/Math;->max(II)I

    .line 29
    .line 30
    .line 31
    move-result v2

    .line 32
    new-array v3, v2, [J

    .line 33
    .line 34
    iget-object v1, v1, Lcom/kousei/framework/g6;->a:[J

    .line 35
    .line 36
    array-length v7, v1

    .line 37
    invoke-static {v7, v2}, Ljava/lang/Math;->min(II)I

    .line 38
    .line 39
    .line 40
    move-result v2

    .line 41
    invoke-static {v1, v4, v3, v4, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 42
    .line 43
    .line 44
    aget-wide v1, v3, v4

    .line 45
    .line 46
    xor-long/2addr v1, v5

    .line 47
    aput-wide v1, v3, v4

    .line 48
    .line 49
    new-instance v1, Lcom/kousei/framework/g6;

    .line 50
    .line 51
    invoke-direct {v1, v3}, Lcom/kousei/framework/g6;-><init>([J)V

    .line 52
    .line 53
    .line 54
    :goto_35
    iget v2, p0, Lcom/kousei/framework/z3;->T:I

    .line 55
    .line 56
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 57
    .line 58
    invoke-direct {v0, v2, p0, v1}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 59
    .line 60
    .line 61
    return-object v0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 15

    .line 1
    new-instance v0, Lcom/kousei/framework/z3;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/z3;->V:Lcom/kousei/framework/g6;

    .line 4
    .line 5
    invoke-virtual {v1}, Lcom/kousei/framework/g6;->e()I

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-eqz v2, :cond_a3

    .line 10
    .line 11
    iget v3, p0, Lcom/kousei/framework/z3;->T:I

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/z3;->U:[I

    .line 14
    .line 15
    const/4 v4, 0x1

    .line 16
    if-ne v2, v4, :cond_12

    .line 17
    .line 18
    goto :goto_84

    .line 19
    :cond_12
    invoke-virtual {v1}, Lcom/kousei/framework/g6;->clone()Ljava/lang/Object;

    .line 20
    .line 21
    .line 22
    move-result-object v1

    .line 23
    check-cast v1, Lcom/kousei/framework/g6;

    .line 24
    .line 25
    add-int/lit8 v5, v3, 0x3f

    .line 26
    .line 27
    ushr-int/lit8 v5, v5, 0x6

    .line 28
    .line 29
    new-instance v6, Lcom/kousei/framework/g6;

    .line 30
    .line 31
    invoke-direct {v6, v5}, Lcom/kousei/framework/g6;-><init>(I)V

    .line 32
    .line 33
    .line 34
    iget-object v7, v6, Lcom/kousei/framework/g6;->a:[J

    .line 35
    .line 36
    invoke-static {v7, v3}, Lcom/kousei/framework/g6;->g([JI)V

    .line 37
    .line 38
    .line 39
    array-length v8, p0

    .line 40
    :goto_27
    add-int/lit8 v8, v8, -0x1

    .line 41
    .line 42
    if-ltz v8, :cond_31

    .line 43
    .line 44
    aget v9, p0, v8

    .line 45
    .line 46
    invoke-static {v7, v9}, Lcom/kousei/framework/g6;->g([JI)V

    .line 47
    .line 48
    .line 49
    goto :goto_27

    .line 50
    :cond_31
    const/4 v8, 0x0

    .line 51
    invoke-static {v7, v8}, Lcom/kousei/framework/g6;->g([JI)V

    .line 52
    .line 53
    .line 54
    new-instance v7, Lcom/kousei/framework/g6;

    .line 55
    .line 56
    invoke-direct {v7, v5}, Lcom/kousei/framework/g6;-><init>(I)V

    .line 57
    .line 58
    .line 59
    iget-object v9, v7, Lcom/kousei/framework/g6;->a:[J

    .line 60
    .line 61
    const-wide/16 v10, 0x1

    .line 62
    .line 63
    aput-wide v10, v9, v8

    .line 64
    .line 65
    new-instance v9, Lcom/kousei/framework/g6;

    .line 66
    .line 67
    invoke-direct {v9, v5}, Lcom/kousei/framework/g6;-><init>(I)V

    .line 68
    .line 69
    .line 70
    const/4 v5, 0x2

    .line 71
    new-array v10, v5, [I

    .line 72
    .line 73
    aput v2, v10, v8

    .line 74
    .line 75
    add-int/lit8 v2, v3, 0x1

    .line 76
    .line 77
    aput v2, v10, v4

    .line 78
    .line 79
    filled-new-array {v1, v6}, [Lcom/kousei/framework/g6;

    .line 80
    .line 81
    .line 82
    move-result-object v1

    .line 83
    new-array v2, v5, [I

    .line 84
    .line 85
    aput v4, v2, v8

    .line 86
    .line 87
    aput v8, v2, v4

    .line 88
    .line 89
    filled-new-array {v7, v9}, [Lcom/kousei/framework/g6;

    .line 90
    .line 91
    .line 92
    move-result-object v5

    .line 93
    aget v6, v10, v4

    .line 94
    .line 95
    aget v7, v10, v8

    .line 96
    .line 97
    sub-int v7, v6, v7

    .line 98
    .line 99
    :goto_62
    if-gez v7, :cond_6f

    .line 100
    .line 101
    neg-int v7, v7

    .line 102
    aput v6, v10, v4

    .line 103
    .line 104
    aput v8, v2, v4

    .line 105
    .line 106
    rsub-int/lit8 v4, v4, 0x1

    .line 107
    .line 108
    aget v6, v10, v4

    .line 109
    .line 110
    aget v8, v2, v4

    .line 111
    .line 112
    :cond_6f
    aget-object v9, v1, v4

    .line 113
    .line 114
    rsub-int/lit8 v11, v4, 0x1

    .line 115
    .line 116
    aget-object v12, v1, v11

    .line 117
    .line 118
    aget v13, v10, v11

    .line 119
    .line 120
    invoke-virtual {v9, v12, v13, v7}, Lcom/kousei/framework/g6;->b(Lcom/kousei/framework/g6;II)V

    .line 121
    .line 122
    .line 123
    aget-object v9, v1, v4

    .line 124
    .line 125
    invoke-virtual {v9, v6}, Lcom/kousei/framework/g6;->f(I)I

    .line 126
    .line 127
    .line 128
    move-result v9

    .line 129
    if-nez v9, :cond_88

    .line 130
    .line 131
    aget-object v1, v5, v11

    .line 132
    .line 133
    :goto_84
    invoke-direct {v0, v3, p0, v1}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 134
    .line 135
    .line 136
    return-object v0

    .line 137
    :cond_88
    aget v12, v2, v11

    .line 138
    .line 139
    aget-object v13, v5, v4

    .line 140
    .line 141
    aget-object v11, v5, v11

    .line 142
    .line 143
    invoke-virtual {v13, v11, v12, v7}, Lcom/kousei/framework/g6;->b(Lcom/kousei/framework/g6;II)V

    .line 144
    .line 145
    .line 146
    add-int/2addr v12, v7

    .line 147
    if-le v12, v8, :cond_96

    .line 148
    .line 149
    move v8, v12

    .line 150
    goto :goto_9e

    .line 151
    :cond_96
    if-ne v12, v8, :cond_9e

    .line 152
    .line 153
    aget-object v11, v5, v4

    .line 154
    .line 155
    invoke-virtual {v11, v8}, Lcom/kousei/framework/g6;->f(I)I

    .line 156
    .line 157
    .line 158
    move-result v8

    .line 159
    :cond_9e
    :goto_9e
    sub-int v6, v9, v6

    .line 160
    .line 161
    add-int/2addr v7, v6

    .line 162
    move v6, v9

    .line 163
    goto :goto_62

    .line 164
    :cond_a3
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 165
    .line 166
    invoke-direct {p0}, Ljava/lang/IllegalStateException;-><init>()V

    .line 167
    .line 168
    .line 169
    throw p0
.end method
