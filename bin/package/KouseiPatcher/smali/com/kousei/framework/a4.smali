.class public final Lcom/kousei/framework/a4;
.super Lcom/kousei/framework/y3;


# instance fields
.field public final S:Ljava/math/BigInteger;

.field public final T:Ljava/math/BigInteger;

.field public final U:Ljava/math/BigInteger;


# direct methods
.method public constructor <init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V
    .registers 5

    .line 1
    const/16 v0, 0x17

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    iput-object p1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 7
    .line 8
    iput-object p2, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 9
    .line 10
    iput-object p3, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 11
    .line 12
    return-void
.end method


# virtual methods
.method public final B2(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p2}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p2

    .line 9
    iget-object v0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 10
    .line 11
    invoke-virtual {v0, v0}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    invoke-virtual {p1, p2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 16
    .line 17
    .line 18
    move-result-object p1

    .line 19
    new-instance p2, Lcom/kousei/framework/a4;

    .line 20
    .line 21
    invoke-virtual {v0, p1}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 22
    .line 23
    .line 24
    move-result-object p1

    .line 25
    invoke-virtual {p0, p1}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 26
    .line 27
    .line 28
    move-result-object p1

    .line 29
    iget-object v0, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 30
    .line 31
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 32
    .line 33
    invoke-direct {p2, v0, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 34
    .line 35
    .line 36
    return-object p2
.end method

.method public final L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p1

    .line 9
    invoke-virtual {v1, p1}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p1

    .line 13
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 14
    .line 15
    .line 16
    move-result v1

    .line 17
    iget-object v2, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 18
    .line 19
    if-gez v1, :cond_18

    .line 20
    .line 21
    invoke-virtual {p1, v2}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 22
    .line 23
    .line 24
    move-result-object p1

    .line 25
    :cond_18
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 26
    .line 27
    invoke-direct {v0, v2, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 28
    .line 29
    .line 30
    return-object v0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p1

    .line 9
    invoke-virtual {p0, v1, p1}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p1

    .line 13
    iget-object v1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 14
    .line 15
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 16
    .line 17
    invoke-direct {v0, v1, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 18
    .line 19
    .line 20
    return-object v0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 4
    .line 5
    .line 6
    move-result-object p1

    .line 7
    iget-object v1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 8
    .line 9
    invoke-static {v1, p1}, Lcom/kousei/framework/f1;->c(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p1

    .line 13
    iget-object v2, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 14
    .line 15
    invoke-virtual {p0, v2, p1}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 16
    .line 17
    .line 18
    move-result-object p1

    .line 19
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 20
    .line 21
    invoke-direct {v0, v1, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 22
    .line 23
    .line 24
    return-object v0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 24

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->E0()Z

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_22e

    .line 8
    .line 9
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->A0()Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_10

    .line 14
    .line 15
    goto/16 :goto_22e

    .line 16
    .line 17
    :cond_10
    iget-object v1, v0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 18
    .line 19
    const/4 v2, 0x0

    .line 20
    invoke-virtual {v1, v2}, Ljava/math/BigInteger;->testBit(I)Z

    .line 21
    .line 22
    .line 23
    move-result v3

    .line 24
    if-eqz v3, :cond_226

    .line 25
    .line 26
    const/4 v3, 0x1

    .line 27
    invoke-virtual {v1, v3}, Ljava/math/BigInteger;->testBit(I)Z

    .line 28
    .line 29
    .line 30
    move-result v4

    .line 31
    const/4 v5, 0x0

    .line 32
    const/4 v6, 0x2

    .line 33
    iget-object v7, v0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 34
    .line 35
    iget-object v8, v0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 36
    .line 37
    sget-object v9, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 38
    .line 39
    if-eqz v4, :cond_45

    .line 40
    .line 41
    invoke-virtual {v1, v6}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 42
    .line 43
    .line 44
    move-result-object v2

    .line 45
    invoke-virtual {v2, v9}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 46
    .line 47
    .line 48
    move-result-object v2

    .line 49
    new-instance v3, Lcom/kousei/framework/a4;

    .line 50
    .line 51
    invoke-virtual {v8, v2, v1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 52
    .line 53
    .line 54
    move-result-object v2

    .line 55
    invoke-direct {v3, v1, v7, v2}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 56
    .line 57
    .line 58
    invoke-virtual {v3}, Lcom/kousei/framework/a4;->X1()Lcom/kousei/framework/h0;

    .line 59
    .line 60
    .line 61
    move-result-object v1

    .line 62
    invoke-virtual {v1, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 63
    .line 64
    .line 65
    move-result v0

    .line 66
    if-eqz v0, :cond_44

    .line 67
    .line 68
    return-object v3

    .line 69
    :cond_44
    return-object v5

    .line 70
    :cond_45
    invoke-virtual {v1, v6}, Ljava/math/BigInteger;->testBit(I)Z

    .line 71
    .line 72
    .line 73
    move-result v4

    .line 74
    sget-object v10, Lcom/kousei/framework/o3;->c:Ljava/math/BigInteger;

    .line 75
    .line 76
    if-eqz v4, :cond_96

    .line 77
    .line 78
    const/4 v2, 0x3

    .line 79
    invoke-virtual {v1, v2}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 80
    .line 81
    .line 82
    move-result-object v2

    .line 83
    invoke-virtual {v8, v2, v1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 84
    .line 85
    .line 86
    move-result-object v2

    .line 87
    invoke-virtual {v0, v2, v8}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 88
    .line 89
    .line 90
    move-result-object v3

    .line 91
    invoke-virtual {v0, v3, v2}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 92
    .line 93
    .line 94
    move-result-object v2

    .line 95
    invoke-virtual {v2, v9}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 96
    .line 97
    .line 98
    move-result v2

    .line 99
    if-eqz v2, :cond_75

    .line 100
    .line 101
    new-instance v2, Lcom/kousei/framework/a4;

    .line 102
    .line 103
    invoke-direct {v2, v1, v7, v3}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 104
    .line 105
    .line 106
    invoke-virtual {v2}, Lcom/kousei/framework/a4;->X1()Lcom/kousei/framework/h0;

    .line 107
    .line 108
    .line 109
    move-result-object v1

    .line 110
    invoke-virtual {v1, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 111
    .line 112
    .line 113
    move-result v0

    .line 114
    if-eqz v0, :cond_74

    .line 115
    .line 116
    return-object v2

    .line 117
    :cond_74
    return-object v5

    .line 118
    :cond_75
    invoke-virtual {v1, v6}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 119
    .line 120
    .line 121
    move-result-object v2

    .line 122
    invoke-virtual {v10, v2, v1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 123
    .line 124
    .line 125
    move-result-object v2

    .line 126
    invoke-virtual {v3, v2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 127
    .line 128
    .line 129
    move-result-object v2

    .line 130
    invoke-virtual {v0, v2}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 131
    .line 132
    .line 133
    move-result-object v2

    .line 134
    new-instance v3, Lcom/kousei/framework/a4;

    .line 135
    .line 136
    invoke-direct {v3, v1, v7, v2}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 137
    .line 138
    .line 139
    invoke-virtual {v3}, Lcom/kousei/framework/a4;->X1()Lcom/kousei/framework/h0;

    .line 140
    .line 141
    .line 142
    move-result-object v1

    .line 143
    invoke-virtual {v1, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 144
    .line 145
    .line 146
    move-result v0

    .line 147
    if-eqz v0, :cond_95

    .line 148
    .line 149
    return-object v3

    .line 150
    :cond_95
    return-object v5

    .line 151
    :cond_96
    invoke-virtual {v1, v3}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 152
    .line 153
    .line 154
    move-result-object v4

    .line 155
    invoke-virtual {v8, v4, v1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 156
    .line 157
    .line 158
    move-result-object v6

    .line 159
    invoke-virtual {v6, v9}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 160
    .line 161
    .line 162
    move-result v6

    .line 163
    if-nez v6, :cond_a8

    .line 164
    .line 165
    move-object/from16 v16, v5

    .line 166
    .line 167
    goto/16 :goto_205

    .line 168
    .line 169
    :cond_a8
    invoke-virtual {v8, v3}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 170
    .line 171
    .line 172
    move-result-object v6

    .line 173
    invoke-virtual {v6, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 174
    .line 175
    .line 176
    move-result v11

    .line 177
    if-ltz v11, :cond_b6

    .line 178
    .line 179
    invoke-virtual {v6, v1}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 180
    .line 181
    .line 182
    move-result-object v6

    .line 183
    :cond_b6
    invoke-virtual {v6, v3}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 184
    .line 185
    .line 186
    move-result-object v6

    .line 187
    invoke-virtual {v6, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 188
    .line 189
    .line 190
    move-result v11

    .line 191
    if-ltz v11, :cond_c4

    .line 192
    .line 193
    invoke-virtual {v6, v1}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 194
    .line 195
    .line 196
    move-result-object v6

    .line 197
    :cond_c4
    invoke-virtual {v4, v9}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 198
    .line 199
    .line 200
    move-result-object v11

    .line 201
    invoke-virtual {v1, v9}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 202
    .line 203
    .line 204
    move-result-object v12

    .line 205
    new-instance v13, Ljava/util/Random;

    .line 206
    .line 207
    invoke-direct {v13}, Ljava/util/Random;-><init>()V

    .line 208
    .line 209
    .line 210
    :goto_d1
    new-instance v14, Ljava/math/BigInteger;

    .line 211
    .line 212
    invoke-virtual {v1}, Ljava/math/BigInteger;->bitLength()I

    .line 213
    .line 214
    .line 215
    move-result v15

    .line 216
    invoke-direct {v14, v15, v13}, Ljava/math/BigInteger;-><init>(ILjava/util/Random;)V

    .line 217
    .line 218
    .line 219
    invoke-virtual {v14, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 220
    .line 221
    .line 222
    move-result v15

    .line 223
    if-gez v15, :cond_221

    .line 224
    .line 225
    invoke-virtual {v14, v14}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 226
    .line 227
    .line 228
    move-result-object v15

    .line 229
    invoke-virtual {v15, v6}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 230
    .line 231
    .line 232
    move-result-object v15

    .line 233
    invoke-virtual {v0, v15}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 234
    .line 235
    .line 236
    move-result-object v15

    .line 237
    invoke-virtual {v15, v4, v1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 238
    .line 239
    .line 240
    move-result-object v15

    .line 241
    invoke-virtual {v15, v12}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 242
    .line 243
    .line 244
    move-result v15

    .line 245
    if-eqz v15, :cond_221

    .line 246
    .line 247
    invoke-virtual {v11}, Ljava/math/BigInteger;->bitLength()I

    .line 248
    .line 249
    .line 250
    move-result v15

    .line 251
    move-object/from16 v16, v5

    .line 252
    .line 253
    invoke-virtual {v11}, Ljava/math/BigInteger;->getLowestSetBit()I

    .line 254
    .line 255
    .line 256
    move-result v5

    .line 257
    sub-int/2addr v15, v3

    .line 258
    move/from16 v17, v2

    .line 259
    .line 260
    move-object/from16 v18, v4

    .line 261
    .line 262
    move-object v2, v9

    .line 263
    move-object v3, v2

    .line 264
    move-object v4, v3

    .line 265
    move-object/from16 v19, v10

    .line 266
    .line 267
    move-object/from16 v20, v13

    .line 268
    .line 269
    move-object v13, v14

    .line 270
    :goto_10d
    move-object/from16 v21, v12

    .line 271
    .line 272
    add-int/lit8 v12, v5, 0x1

    .line 273
    .line 274
    invoke-virtual {v0, v2, v3}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 275
    .line 276
    .line 277
    move-result-object v2

    .line 278
    if-lt v15, v12, :cond_181

    .line 279
    .line 280
    invoke-virtual {v11, v15}, Ljava/math/BigInteger;->testBit(I)Z

    .line 281
    .line 282
    .line 283
    move-result v3

    .line 284
    if-eqz v3, :cond_14c

    .line 285
    .line 286
    invoke-virtual {v0, v2, v8}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 287
    .line 288
    .line 289
    move-result-object v3

    .line 290
    invoke-virtual {v0, v4, v13}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 291
    .line 292
    .line 293
    move-result-object v4

    .line 294
    invoke-virtual {v13, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 295
    .line 296
    .line 297
    move-result-object v10

    .line 298
    invoke-virtual {v14, v2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 299
    .line 300
    .line 301
    move-result-object v12

    .line 302
    invoke-virtual {v10, v12}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 303
    .line 304
    .line 305
    move-result-object v10

    .line 306
    invoke-virtual {v0, v10}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 307
    .line 308
    .line 309
    move-result-object v10

    .line 310
    invoke-virtual {v13, v13}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 311
    .line 312
    .line 313
    move-result-object v12

    .line 314
    move-object/from16 v22, v4

    .line 315
    .line 316
    const/4 v13, 0x1

    .line 317
    invoke-virtual {v3, v13}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 318
    .line 319
    .line 320
    move-result-object v4

    .line 321
    invoke-virtual {v12, v4}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 322
    .line 323
    .line 324
    move-result-object v4

    .line 325
    invoke-virtual {v0, v4}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 326
    .line 327
    .line 328
    move-result-object v4

    .line 329
    move-object v13, v4

    .line 330
    move-object/from16 v4, v22

    .line 331
    .line 332
    goto :goto_17c

    .line 333
    :cond_14c
    invoke-virtual {v4, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 334
    .line 335
    .line 336
    move-result-object v3

    .line 337
    invoke-virtual {v3, v2}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 338
    .line 339
    .line 340
    move-result-object v3

    .line 341
    invoke-virtual {v0, v3}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 342
    .line 343
    .line 344
    move-result-object v3

    .line 345
    invoke-virtual {v13, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 346
    .line 347
    .line 348
    move-result-object v4

    .line 349
    invoke-virtual {v14, v2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 350
    .line 351
    .line 352
    move-result-object v12

    .line 353
    invoke-virtual {v4, v12}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 354
    .line 355
    .line 356
    move-result-object v4

    .line 357
    invoke-virtual {v0, v4}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 358
    .line 359
    .line 360
    move-result-object v4

    .line 361
    invoke-virtual {v10, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 362
    .line 363
    .line 364
    move-result-object v10

    .line 365
    const/4 v13, 0x1

    .line 366
    invoke-virtual {v2, v13}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 367
    .line 368
    .line 369
    move-result-object v12

    .line 370
    invoke-virtual {v10, v12}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 371
    .line 372
    .line 373
    move-result-object v10

    .line 374
    invoke-virtual {v0, v10}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 375
    .line 376
    .line 377
    move-result-object v10

    .line 378
    move-object v13, v4

    .line 379
    move-object v4, v3

    .line 380
    move-object v3, v2

    .line 381
    :goto_17c
    add-int/lit8 v15, v15, -0x1

    .line 382
    .line 383
    move-object/from16 v12, v21

    .line 384
    .line 385
    goto :goto_10d

    .line 386
    :cond_181
    invoke-virtual {v0, v2, v8}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 387
    .line 388
    .line 389
    move-result-object v3

    .line 390
    invoke-virtual {v4, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 391
    .line 392
    .line 393
    move-result-object v4

    .line 394
    invoke-virtual {v4, v2}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 395
    .line 396
    .line 397
    move-result-object v4

    .line 398
    invoke-virtual {v0, v4}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 399
    .line 400
    .line 401
    move-result-object v4

    .line 402
    invoke-virtual {v13, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 403
    .line 404
    .line 405
    move-result-object v10

    .line 406
    invoke-virtual {v14, v2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 407
    .line 408
    .line 409
    move-result-object v12

    .line 410
    invoke-virtual {v10, v12}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 411
    .line 412
    .line 413
    move-result-object v10

    .line 414
    invoke-virtual {v0, v10}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 415
    .line 416
    .line 417
    move-result-object v10

    .line 418
    invoke-virtual {v2, v3}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 419
    .line 420
    .line 421
    move-result-object v2

    .line 422
    invoke-virtual {v0, v2}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 423
    .line 424
    .line 425
    move-result-object v2

    .line 426
    const/4 v13, 0x1

    .line 427
    :goto_1aa
    if-gt v13, v5, :cond_1cc

    .line 428
    .line 429
    invoke-virtual {v0, v4, v10}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 430
    .line 431
    .line 432
    move-result-object v4

    .line 433
    invoke-virtual {v10, v10}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 434
    .line 435
    .line 436
    move-result-object v3

    .line 437
    const/4 v12, 0x1

    .line 438
    invoke-virtual {v2, v12}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 439
    .line 440
    .line 441
    move-result-object v10

    .line 442
    invoke-virtual {v3, v10}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 443
    .line 444
    .line 445
    move-result-object v3

    .line 446
    invoke-virtual {v0, v3}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 447
    .line 448
    .line 449
    move-result-object v10

    .line 450
    invoke-virtual {v2, v2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 451
    .line 452
    .line 453
    move-result-object v2

    .line 454
    invoke-virtual {v0, v2}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 455
    .line 456
    .line 457
    move-result-object v2

    .line 458
    add-int/lit8 v13, v13, 0x1

    .line 459
    .line 460
    goto :goto_1aa

    .line 461
    :cond_1cc
    const/4 v12, 0x1

    .line 462
    filled-new-array {v4, v10}, [Ljava/math/BigInteger;

    .line 463
    .line 464
    .line 465
    move-result-object v2

    .line 466
    aget-object v3, v2, v17

    .line 467
    .line 468
    aget-object v2, v2, v12

    .line 469
    .line 470
    invoke-virtual {v0, v2, v2}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 471
    .line 472
    .line 473
    move-result-object v4

    .line 474
    invoke-virtual {v4, v6}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 475
    .line 476
    .line 477
    move-result v4

    .line 478
    if-eqz v4, :cond_1f5

    .line 479
    .line 480
    new-instance v0, Lcom/kousei/framework/a4;

    .line 481
    .line 482
    move/from16 v4, v17

    .line 483
    .line 484
    invoke-virtual {v2, v4}, Ljava/math/BigInteger;->testBit(I)Z

    .line 485
    .line 486
    .line 487
    move-result v3

    .line 488
    if-eqz v3, :cond_1ed

    .line 489
    .line 490
    invoke-virtual {v1, v2}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 491
    .line 492
    .line 493
    move-result-object v2

    .line 494
    :cond_1ed
    invoke-virtual {v2, v12}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 495
    .line 496
    .line 497
    move-result-object v2

    .line 498
    invoke-direct {v0, v1, v7, v2}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 499
    .line 500
    .line 501
    return-object v0

    .line 502
    :cond_1f5
    move/from16 v4, v17

    .line 503
    .line 504
    invoke-virtual {v3, v9}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 505
    .line 506
    .line 507
    move-result v2

    .line 508
    if-nez v2, :cond_213

    .line 509
    .line 510
    move-object/from16 v2, v21

    .line 511
    .line 512
    invoke-virtual {v3, v2}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 513
    .line 514
    .line 515
    move-result v3

    .line 516
    if-nez v3, :cond_206

    .line 517
    .line 518
    :goto_205
    return-object v16

    .line 519
    :cond_206
    move v3, v12

    .line 520
    move-object/from16 v5, v16

    .line 521
    .line 522
    move-object/from16 v10, v19

    .line 523
    .line 524
    move-object/from16 v13, v20

    .line 525
    .line 526
    move-object v12, v2

    .line 527
    :goto_20e
    move v2, v4

    .line 528
    move-object/from16 v4, v18

    .line 529
    .line 530
    goto/16 :goto_d1

    .line 531
    .line 532
    :cond_213
    move v2, v4

    .line 533
    move v3, v12

    .line 534
    move-object/from16 v5, v16

    .line 535
    .line 536
    move-object/from16 v4, v18

    .line 537
    .line 538
    move-object/from16 v10, v19

    .line 539
    .line 540
    move-object/from16 v13, v20

    .line 541
    .line 542
    move-object/from16 v12, v21

    .line 543
    .line 544
    goto/16 :goto_d1

    .line 545
    .line 546
    :cond_221
    move-object/from16 v18, v4

    .line 547
    .line 548
    move v4, v2

    .line 549
    move-object v2, v12

    .line 550
    goto :goto_20e

    .line 551
    :cond_226
    new-instance v0, Ljava/lang/RuntimeException;

    .line 552
    .line 553
    const-string v1, "not done yet"

    .line 554
    .line 555
    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    .line 556
    .line 557
    .line 558
    throw v0

    .line 559
    :cond_22e
    :goto_22e
    return-object v0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-virtual {p0, v1, v1}, Lcom/kousei/framework/a4;->k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    iget-object v2, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 10
    .line 11
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 12
    .line 13
    invoke-direct {v0, v2, p0, v1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 14
    .line 15
    .line 16
    return-object v0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 2
    .line 3
    return-object p0
.end method

.method public final a0()I
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

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
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p1

    .line 9
    invoke-virtual {v1, p1}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p1

    .line 13
    iget-object v1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 14
    .line 15
    invoke-virtual {p1, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 16
    .line 17
    .line 18
    move-result v2

    .line 19
    if-ltz v2, :cond_18

    .line 20
    .line 21
    invoke-virtual {p1, v1}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 22
    .line 23
    .line 24
    move-result-object p1

    .line 25
    :cond_18
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 26
    .line 27
    invoke-direct {v0, v1, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 28
    .line 29
    .line 30
    return-object v0
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
    instance-of v1, p1, Lcom/kousei/framework/a4;

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
    check-cast p1, Lcom/kousei/framework/a4;

    .line 12
    .line 13
    iget-object v1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 14
    .line 15
    iget-object v3, p1, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 16
    .line 17
    invoke-virtual {v1, v3}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 18
    .line 19
    .line 20
    move-result v1

    .line 21
    if-eqz v1, :cond_21

    .line 22
    .line 23
    iget-object p0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 24
    .line 25
    iget-object p1, p1, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 26
    .line 27
    invoke-virtual {p0, p1}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 28
    .line 29
    .line 30
    move-result p0

    .line 31
    if-eqz p0, :cond_21

    .line 32
    .line 33
    return v0

    .line 34
    :cond_21
    return v2
.end method

.method public final hashCode()I
    .registers 2

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget-object p0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 8
    .line 9
    invoke-virtual {p0}, Ljava/math/BigInteger;->hashCode()I

    .line 10
    .line 11
    .line 12
    move-result p0

    .line 13
    xor-int/2addr p0, v0

    .line 14
    return p0
.end method

.method public final k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p2}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p2

    .line 9
    invoke-virtual {p3}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p3

    .line 13
    iget-object v0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 14
    .line 15
    invoke-virtual {v0, p1}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 16
    .line 17
    .line 18
    move-result-object p1

    .line 19
    invoke-virtual {p2, p3}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 20
    .line 21
    .line 22
    move-result-object p2

    .line 23
    new-instance p3, Lcom/kousei/framework/a4;

    .line 24
    .line 25
    invoke-virtual {p1, p2}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 26
    .line 27
    .line 28
    move-result-object p1

    .line 29
    invoke-virtual {p0, p1}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 30
    .line 31
    .line 32
    move-result-object p1

    .line 33
    iget-object p2, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 34
    .line 35
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 36
    .line 37
    invoke-direct {p3, p2, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 38
    .line 39
    .line 40
    return-object p3
.end method

.method public final k3(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;
    .registers 3

    .line 1
    invoke-virtual {p1, p2}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p0, p1}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    return-object p0
.end method

.method public final l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p2}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object p2

    .line 9
    invoke-virtual {p3}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 10
    .line 11
    .line 12
    move-result-object p3

    .line 13
    iget-object v0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 14
    .line 15
    invoke-virtual {v0, p1}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 16
    .line 17
    .line 18
    move-result-object p1

    .line 19
    invoke-virtual {p2, p3}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 20
    .line 21
    .line 22
    move-result-object p2

    .line 23
    new-instance p3, Lcom/kousei/framework/a4;

    .line 24
    .line 25
    invoke-virtual {p1, p2}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 26
    .line 27
    .line 28
    move-result-object p1

    .line 29
    invoke-virtual {p0, p1}, Lcom/kousei/framework/a4;->l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 30
    .line 31
    .line 32
    move-result-object p1

    .line 33
    iget-object p2, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 34
    .line 35
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 36
    .line 37
    invoke-direct {p3, p2, p0, p1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 38
    .line 39
    .line 40
    return-object p3
.end method

.method public final l3(Ljava/math/BigInteger;)Ljava/math/BigInteger;
    .registers 8

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 4
    .line 5
    if-eqz p0, :cond_57

    .line 6
    .line 7
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 8
    .line 9
    .line 10
    move-result v1

    .line 11
    if-gez v1, :cond_e

    .line 12
    .line 13
    const/4 v1, 0x1

    .line 14
    goto :goto_f

    .line 15
    :cond_e
    const/4 v1, 0x0

    .line 16
    :goto_f
    if-eqz v1, :cond_15

    .line 17
    .line 18
    invoke-virtual {p1}, Ljava/math/BigInteger;->abs()Ljava/math/BigInteger;

    .line 19
    .line 20
    .line 21
    move-result-object p1

    .line 22
    :cond_15
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 23
    .line 24
    .line 25
    move-result v2

    .line 26
    sget-object v3, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 27
    .line 28
    invoke-virtual {p0, v3}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 29
    .line 30
    .line 31
    move-result v3

    .line 32
    :goto_1f
    invoke-virtual {p1}, Ljava/math/BigInteger;->bitLength()I

    .line 33
    .line 34
    .line 35
    move-result v4

    .line 36
    add-int/lit8 v5, v2, 0x1

    .line 37
    .line 38
    if-le v4, v5, :cond_3e

    .line 39
    .line 40
    invoke-virtual {p1, v2}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 41
    .line 42
    .line 43
    move-result-object v4

    .line 44
    invoke-virtual {v4, v2}, Ljava/math/BigInteger;->shiftLeft(I)Ljava/math/BigInteger;

    .line 45
    .line 46
    .line 47
    move-result-object v5

    .line 48
    invoke-virtual {p1, v5}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 49
    .line 50
    .line 51
    move-result-object p1

    .line 52
    if-nez v3, :cond_39

    .line 53
    .line 54
    invoke-virtual {v4, p0}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 55
    .line 56
    .line 57
    move-result-object v4

    .line 58
    :cond_39
    invoke-virtual {v4, p1}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 59
    .line 60
    .line 61
    move-result-object p1

    .line 62
    goto :goto_1f

    .line 63
    :cond_3e
    :goto_3e
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 64
    .line 65
    .line 66
    move-result p0

    .line 67
    if-ltz p0, :cond_49

    .line 68
    .line 69
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 70
    .line 71
    .line 72
    move-result-object p1

    .line 73
    goto :goto_3e

    .line 74
    :cond_49
    if-eqz v1, :cond_56

    .line 75
    .line 76
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 77
    .line 78
    .line 79
    move-result p0

    .line 80
    if-eqz p0, :cond_56

    .line 81
    .line 82
    invoke-virtual {v0, p1}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 83
    .line 84
    .line 85
    move-result-object p0

    .line 86
    return-object p0

    .line 87
    :cond_56
    return-object p1

    .line 88
    :cond_57
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->mod(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 89
    .line 90
    .line 91
    move-result-object p0

    .line 92
    return-object p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->signum()I

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_9

    .line 8
    .line 9
    return-object p0

    .line 10
    :cond_9
    new-instance v1, Lcom/kousei/framework/a4;

    .line 11
    .line 12
    iget-object v2, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 13
    .line 14
    iget-object p0, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p0, v0}, Ljava/math/BigInteger;->subtract(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 17
    .line 18
    .line 19
    move-result-object v0

    .line 20
    invoke-direct {v1, p0, v2, v0}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 21
    .line 22
    .line 23
    return-object v1
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 2
    .line 3
    sget-object v1, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-virtual {v0, v1}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object v0

    .line 9
    iget-object v1, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 10
    .line 11
    invoke-virtual {v0, v1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 12
    .line 13
    .line 14
    move-result v2

    .line 15
    if-nez v2, :cond_12

    .line 16
    .line 17
    sget-object v0, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 18
    .line 19
    :cond_12
    new-instance v2, Lcom/kousei/framework/a4;

    .line 20
    .line 21
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 22
    .line 23
    invoke-direct {v2, v1, p0, v0}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 24
    .line 25
    .line 26
    return-object v2
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    new-instance v0, Lcom/kousei/framework/a4;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/a4;->U:Ljava/math/BigInteger;

    .line 4
    .line 5
    iget-object v2, p0, Lcom/kousei/framework/a4;->S:Ljava/math/BigInteger;

    .line 6
    .line 7
    invoke-static {v2, v1}, Lcom/kousei/framework/f1;->c(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 8
    .line 9
    .line 10
    move-result-object v1

    .line 11
    iget-object p0, p0, Lcom/kousei/framework/a4;->T:Ljava/math/BigInteger;

    .line 12
    .line 13
    invoke-direct {v0, v2, p0, v1}, Lcom/kousei/framework/a4;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 14
    .line 15
    .line 16
    return-object v0
.end method
