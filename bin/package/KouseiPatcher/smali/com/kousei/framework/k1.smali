.class public final Lcom/kousei/framework/k1;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"

# interfaces
.implements Lcom/kousei/framework/o3;


# instance fields
.field public final synthetic e:I

.field public final f:Ljava/lang/Object;

.field public g:Ljava/lang/Object;

.field public h:Ljava/lang/Object;


# direct methods
.method public constructor <init>()V
    .registers 2

    const/4 v0, 0x2

    iput v0, p0, Lcom/kousei/framework/k1;->e:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/kousei/framework/x7;

    .line 21
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 22
    iput-object v0, p0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/j0;Lcom/kousei/framework/g4;)V
    .registers 4

    const/4 v0, 0x0

    iput v0, p0, Lcom/kousei/framework/k1;->e:I

    .line 23
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 24
    iput-object p1, p0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 25
    iput-object p2, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 26
    new-instance p1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    iput-object p1, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/j0;Lcom/kousei/framework/u7;)V
    .registers 4

    const/4 v0, 0x1

    iput v0, p0, Lcom/kousei/framework/k1;->e:I

    .line 27
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 28
    iput-object p1, p0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 29
    iput-object p2, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 30
    new-instance p1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    iput-object p1, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    return-void
.end method

.method public constructor <init>(Ljava/security/Signature;Lcom/kousei/framework/j0;)V
    .registers 4

    .line 1
    const/4 v0, 0x3

    .line 2
    iput v0, p0, Lcom/kousei/framework/k1;->e:I

    .line 3
    .line 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 5
    .line 6
    .line 7
    iput-object p1, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 8
    .line 9
    iput-object p2, p0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 10
    .line 11
    new-instance p2, Lcom/kousei/framework/ha;

    .line 12
    .line 13
    invoke-direct {p2}, Ljava/io/OutputStream;-><init>()V

    .line 14
    .line 15
    .line 16
    iput-object p1, p2, Lcom/kousei/framework/ha;->a:Ljava/security/Signature;

    .line 17
    .line 18
    iput-object p2, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 19
    .line 20
    return-void
.end method


# virtual methods
.method public a([B)[Ljava/math/BigInteger;
    .registers 22

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    iget-object v2, v0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 6
    .line 7
    check-cast v2, Lcom/kousei/framework/x7;

    .line 8
    .line 9
    iget-object v3, v0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 10
    .line 11
    check-cast v3, Lcom/kousei/framework/g4;

    .line 12
    .line 13
    iget-object v3, v3, Lcom/kousei/framework/g4;->a:Lcom/kousei/framework/w3;

    .line 14
    .line 15
    iget-object v4, v3, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 16
    .line 17
    invoke-virtual {v4}, Ljava/math/BigInteger;->bitLength()I

    .line 18
    .line 19
    .line 20
    move-result v5

    .line 21
    array-length v6, v1

    .line 22
    mul-int/lit8 v6, v6, 0x8

    .line 23
    .line 24
    new-instance v7, Ljava/math/BigInteger;

    .line 25
    .line 26
    const/4 v8, 0x1

    .line 27
    invoke-direct {v7, v8, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 28
    .line 29
    .line 30
    if-ge v5, v6, :cond_24

    .line 31
    .line 32
    sub-int/2addr v6, v5

    .line 33
    invoke-virtual {v7, v6}, Ljava/math/BigInteger;->shiftRight(I)Ljava/math/BigInteger;

    .line 34
    .line 35
    .line 36
    move-result-object v7

    .line 37
    :cond_24
    iget-object v1, v0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 38
    .line 39
    check-cast v1, Lcom/kousei/framework/g4;

    .line 40
    .line 41
    iget-object v1, v1, Lcom/kousei/framework/g4;->b:Ljava/math/BigInteger;

    .line 42
    .line 43
    invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 44
    .line 45
    .line 46
    iget-object v0, v0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 47
    .line 48
    check-cast v0, Ljava/security/SecureRandom;

    .line 49
    .line 50
    iput-object v4, v2, Lcom/kousei/framework/x7;->a:Ljava/math/BigInteger;

    .line 51
    .line 52
    iput-object v0, v2, Lcom/kousei/framework/x7;->b:Ljava/security/SecureRandom;

    .line 53
    .line 54
    :goto_35
    iget-object v0, v2, Lcom/kousei/framework/x7;->a:Ljava/math/BigInteger;

    .line 55
    .line 56
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 57
    .line 58
    .line 59
    move-result v0

    .line 60
    :cond_3b
    iget-object v5, v2, Lcom/kousei/framework/x7;->b:Ljava/security/SecureRandom;

    .line 61
    .line 62
    invoke-static {v0, v5}, Lcom/kousei/framework/f1;->a(ILjava/security/SecureRandom;)Ljava/math/BigInteger;

    .line 63
    .line 64
    .line 65
    move-result-object v5

    .line 66
    sget-object v6, Lcom/kousei/framework/x7;->c:Ljava/math/BigInteger;

    .line 67
    .line 68
    invoke-virtual {v5, v6}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 69
    .line 70
    .line 71
    move-result v6

    .line 72
    if-nez v6, :cond_3b

    .line 73
    .line 74
    iget-object v6, v2, Lcom/kousei/framework/x7;->a:Ljava/math/BigInteger;

    .line 75
    .line 76
    invoke-virtual {v5, v6}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 77
    .line 78
    .line 79
    move-result v6

    .line 80
    if-gez v6, :cond_3b

    .line 81
    .line 82
    iget-object v0, v3, Lcom/kousei/framework/w3;->f:Lcom/kousei/framework/d4;

    .line 83
    .line 84
    invoke-virtual {v5}, Ljava/math/BigInteger;->signum()I

    .line 85
    .line 86
    .line 87
    move-result v6

    .line 88
    if-eqz v6, :cond_61

    .line 89
    .line 90
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 91
    .line 92
    .line 93
    move-result v9

    .line 94
    iget-object v10, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 95
    .line 96
    if-eqz v9, :cond_65

    .line 97
    .line 98
    :cond_61
    move/from16 v16, v8

    .line 99
    .line 100
    goto/16 :goto_ea

    .line 101
    .line 102
    :cond_65
    invoke-virtual {v5}, Ljava/math/BigInteger;->abs()Ljava/math/BigInteger;

    .line 103
    .line 104
    .line 105
    move-result-object v9

    .line 106
    iget-object v11, v10, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 107
    .line 108
    if-nez v11, :cond_73

    .line 109
    .line 110
    invoke-virtual {v10}, Lcom/kousei/framework/v3;->g()I

    .line 111
    .line 112
    .line 113
    move-result v11

    .line 114
    add-int/2addr v11, v8

    .line 115
    goto :goto_77

    .line 116
    :cond_73
    invoke-virtual {v11}, Ljava/math/BigInteger;->bitLength()I

    .line 117
    .line 118
    .line 119
    move-result v11

    .line 120
    :goto_77
    invoke-virtual {v9}, Ljava/math/BigInteger;->bitLength()I

    .line 121
    .line 122
    .line 123
    move-result v12

    .line 124
    if-gt v12, v11, :cond_e2

    .line 125
    .line 126
    new-instance v12, Lcom/kousei/framework/o4;

    .line 127
    .line 128
    invoke-direct {v12, v10, v0}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 129
    .line 130
    .line 131
    const-string v14, "bc_fixed_point"

    .line 132
    .line 133
    invoke-virtual {v10, v0, v14, v12}, Lcom/kousei/framework/v3;->k(Lcom/kousei/framework/d4;Ljava/lang/String;Lcom/kousei/framework/h7;)Lcom/kousei/framework/i7;

    .line 134
    .line 135
    .line 136
    move-result-object v0

    .line 137
    check-cast v0, Lcom/kousei/framework/n4;

    .line 138
    .line 139
    iget-object v12, v0, Lcom/kousei/framework/n4;->b:Lcom/kousei/framework/h0;

    .line 140
    .line 141
    iget v14, v0, Lcom/kousei/framework/n4;->c:I

    .line 142
    .line 143
    add-int/2addr v11, v14

    .line 144
    sub-int/2addr v11, v8

    .line 145
    div-int/2addr v11, v14

    .line 146
    invoke-virtual {v10}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 147
    .line 148
    .line 149
    move-result-object v10

    .line 150
    mul-int/2addr v14, v11

    .line 151
    invoke-static {v14, v9}, Lcom/kousei/framework/n6;->I(ILjava/math/BigInteger;)[I

    .line 152
    .line 153
    .line 154
    move-result-object v9

    .line 155
    sub-int/2addr v14, v8

    .line 156
    const/4 v15, 0x0

    .line 157
    move/from16 v16, v8

    .line 158
    .line 159
    move v8, v15

    .line 160
    :goto_9f
    if-ge v8, v11, :cond_c6

    .line 161
    .line 162
    sub-int v17, v14, v8

    .line 163
    .line 164
    move v13, v15

    .line 165
    const/16 p0, 0x0

    .line 166
    .line 167
    :goto_a6
    if-ltz v17, :cond_bb

    .line 168
    .line 169
    ushr-int/lit8 v18, v17, 0x5

    .line 170
    .line 171
    aget v18, v9, v18

    .line 172
    .line 173
    and-int/lit8 v19, v17, 0x1f

    .line 174
    .line 175
    ushr-int v18, v18, v19

    .line 176
    .line 177
    ushr-int/lit8 v19, v18, 0x1

    .line 178
    .line 179
    xor-int v13, v13, v19

    .line 180
    .line 181
    shl-int/lit8 v13, v13, 0x1

    .line 182
    .line 183
    xor-int v13, v13, v18

    .line 184
    .line 185
    sub-int v17, v17, v11

    .line 186
    .line 187
    goto :goto_a6

    .line 188
    :cond_bb
    invoke-virtual {v12, v13}, Lcom/kousei/framework/h0;->J0(I)Lcom/kousei/framework/d4;

    .line 189
    .line 190
    .line 191
    move-result-object v13

    .line 192
    invoke-virtual {v10, v13}, Lcom/kousei/framework/d4;->p(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 193
    .line 194
    .line 195
    move-result-object v10

    .line 196
    add-int/lit8 v8, v8, 0x1

    .line 197
    .line 198
    goto :goto_9f

    .line 199
    :cond_c6
    const/16 p0, 0x0

    .line 200
    .line 201
    iget-object v0, v0, Lcom/kousei/framework/n4;->a:Lcom/kousei/framework/d4;

    .line 202
    .line 203
    invoke-virtual {v10, v0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 204
    .line 205
    .line 206
    move-result-object v0

    .line 207
    if-lez v6, :cond_d1

    .line 208
    .line 209
    goto :goto_d5

    .line 210
    :cond_d1
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->j()Lcom/kousei/framework/d4;

    .line 211
    .line 212
    .line 213
    move-result-object v0

    .line 214
    :goto_d5
    invoke-virtual {v0, v15, v15}, Lcom/kousei/framework/d4;->g(ZZ)Z

    .line 215
    .line 216
    .line 217
    move-result v6

    .line 218
    if-eqz v6, :cond_dc

    .line 219
    .line 220
    goto :goto_f0

    .line 221
    :cond_dc
    const-string v0, "Invalid result"

    .line 222
    .line 223
    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 224
    .line 225
    .line 226
    return-object p0

    .line 227
    :cond_e2
    const/16 p0, 0x0

    .line 228
    .line 229
    const-string v0, "fixed-point comb doesn\'t support scalars larger than the curve order"

    .line 230
    .line 231
    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 232
    .line 233
    .line 234
    return-object p0

    .line 235
    :goto_ea
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 236
    .line 237
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 238
    .line 239
    .line 240
    move-result-object v0

    .line 241
    :goto_f0
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 242
    .line 243
    .line 244
    move-result-object v0

    .line 245
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->b()V

    .line 246
    .line 247
    .line 248
    iget-object v0, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 249
    .line 250
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 251
    .line 252
    .line 253
    move-result-object v0

    .line 254
    invoke-virtual {v0, v4}, Ljava/math/BigInteger;->mod(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 255
    .line 256
    .line 257
    move-result-object v0

    .line 258
    sget-object v6, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 259
    .line 260
    invoke-virtual {v0, v6}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 261
    .line 262
    .line 263
    move-result v8

    .line 264
    if-nez v8, :cond_128

    .line 265
    .line 266
    invoke-static {v4, v5}, Lcom/kousei/framework/f1;->c(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 267
    .line 268
    .line 269
    move-result-object v5

    .line 270
    invoke-virtual {v1, v0}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 271
    .line 272
    .line 273
    move-result-object v8

    .line 274
    invoke-virtual {v7, v8}, Ljava/math/BigInteger;->add(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 275
    .line 276
    .line 277
    move-result-object v8

    .line 278
    invoke-virtual {v5, v8}, Ljava/math/BigInteger;->multiply(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 279
    .line 280
    .line 281
    move-result-object v5

    .line 282
    invoke-virtual {v5, v4}, Ljava/math/BigInteger;->mod(Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 283
    .line 284
    .line 285
    move-result-object v5

    .line 286
    invoke-virtual {v5, v6}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 287
    .line 288
    .line 289
    move-result v6

    .line 290
    if-nez v6, :cond_128

    .line 291
    .line 292
    filled-new-array {v0, v5}, [Ljava/math/BigInteger;

    .line 293
    .line 294
    .line 295
    move-result-object v0

    .line 296
    return-object v0

    .line 297
    :cond_128
    move/from16 v8, v16

    .line 298
    .line 299
    goto/16 :goto_35
.end method

.method public b()[B
    .registers 6

    .line 1
    iget v0, p0, Lcom/kousei/framework/k1;->e:I

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    packed-switch v0, :pswitch_data_c4

    .line 5
    .line 6
    .line 7
    :try_start_6
    iget-object p0, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 8
    .line 9
    check-cast p0, Ljava/security/Signature;

    .line 10
    .line 11
    invoke-virtual {p0}, Ljava/security/Signature;->sign()[B

    .line 12
    .line 13
    .line 14
    move-result-object p0
    :try_end_e
    .catch Ljava/security/SignatureException; {:try_start_6 .. :try_end_e} :catch_f

    .line 15
    return-object p0

    .line 16
    :catch_f
    move-exception p0

    .line 17
    new-instance v0, Lcom/kousei/framework/a8;

    .line 18
    .line 19
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 20
    .line 21
    .line 22
    move-result-object v1

    .line 23
    new-instance v2, Ljava/lang/StringBuilder;

    .line 24
    .line 25
    const-string v3, "exception obtaining signature: "

    .line 26
    .line 27
    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 28
    .line 29
    .line 30
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 31
    .line 32
    .line 33
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 34
    .line 35
    .line 36
    move-result-object v1

    .line 37
    invoke-direct {v0, v1, p0}, Lcom/kousei/framework/a8;-><init>(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 38
    .line 39
    .line 40
    throw v0

    .line 41
    :pswitch_28
    :try_start_28
    iget-object v0, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 42
    .line 43
    check-cast v0, Ljava/io/ByteArrayOutputStream;

    .line 44
    .line 45
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    .line 46
    .line 47
    .line 48
    move-result-object v0

    .line 49
    new-instance v2, Lcom/kousei/framework/s7;

    .line 50
    .line 51
    new-instance v3, Lcom/kousei/framework/e8;

    .line 52
    .line 53
    invoke-direct {v3}, Lcom/kousei/framework/e8;-><init>()V

    .line 54
    .line 55
    .line 56
    invoke-direct {v2, v3}, Lcom/kousei/framework/s7;-><init>(Lcom/kousei/framework/e8;)V

    .line 57
    .line 58
    .line 59
    iget-object p0, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 60
    .line 61
    check-cast p0, Lcom/kousei/framework/u7;

    .line 62
    .line 63
    iput-boolean v1, v2, Lcom/kousei/framework/s7;->d:Z

    .line 64
    .line 65
    iget-object v1, v2, Lcom/kousei/framework/s7;->c:Lcom/kousei/framework/e8;

    .line 66
    .line 67
    invoke-virtual {v1}, Lcom/kousei/framework/e8;->g()V

    .line 68
    .line 69
    .line 70
    iget-object v1, v2, Lcom/kousei/framework/s7;->a:Lcom/kousei/framework/d7;

    .line 71
    .line 72
    invoke-virtual {v1, p0}, Lcom/kousei/framework/d7;->a(Lcom/kousei/framework/n1;)V

    .line 73
    .line 74
    .line 75
    array-length p0, v0

    .line 76
    invoke-virtual {v2, p0, v0}, Lcom/kousei/framework/s7;->c(I[B)V

    .line 77
    .line 78
    .line 79
    invoke-virtual {v2}, Lcom/kousei/framework/s7;->b()[B

    .line 80
    .line 81
    .line 82
    move-result-object p0
    :try_end_52
    .catch Ljava/lang/Exception; {:try_start_28 .. :try_end_52} :catch_53

    .line 83
    return-object p0

    .line 84
    :catch_53
    move-exception p0

    .line 85
    new-instance v0, Ljava/lang/RuntimeException;

    .line 86
    .line 87
    const-wide v1, -0xa3cb0dbb5469L

    .line 88
    .line 89
    .line 90
    .line 91
    .line 92
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 93
    .line 94
    .line 95
    move-result-object v1

    .line 96
    invoke-direct {v0, v1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 97
    .line 98
    .line 99
    throw v0

    .line 100
    :pswitch_63
    :try_start_63
    iget-object v0, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 101
    .line 102
    check-cast v0, Ljava/io/ByteArrayOutputStream;

    .line 103
    .line 104
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    .line 105
    .line 106
    .line 107
    move-result-object v0

    .line 108
    const-wide v2, -0xa39e0dbb5469L

    .line 109
    .line 110
    .line 111
    .line 112
    .line 113
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 114
    .line 115
    .line 116
    move-result-object v2

    .line 117
    invoke-static {v2}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 118
    .line 119
    .line 120
    move-result-object v2

    .line 121
    invoke-virtual {v2, v0}, Ljava/security/MessageDigest;->digest([B)[B

    .line 122
    .line 123
    .line 124
    move-result-object v0

    .line 125
    new-instance v2, Lcom/kousei/framework/k1;

    .line 126
    .line 127
    invoke-direct {v2}, Lcom/kousei/framework/k1;-><init>()V

    .line 128
    .line 129
    .line 130
    iget-object p0, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 131
    .line 132
    check-cast p0, Lcom/kousei/framework/g4;

    .line 133
    .line 134
    invoke-virtual {v2, p0}, Lcom/kousei/framework/k1;->c(Lcom/kousei/framework/n1;)V

    .line 135
    .line 136
    .line 137
    invoke-virtual {v2, v0}, Lcom/kousei/framework/k1;->a([B)[Ljava/math/BigInteger;

    .line 138
    .line 139
    .line 140
    move-result-object p0

    .line 141
    new-instance v0, Lcom/kousei/framework/k;

    .line 142
    .line 143
    invoke-direct {v0}, Lcom/kousei/framework/k;-><init>()V

    .line 144
    .line 145
    .line 146
    new-instance v2, Lcom/kousei/framework/p;

    .line 147
    .line 148
    const/4 v3, 0x0

    .line 149
    aget-object v4, p0, v3

    .line 150
    .line 151
    invoke-direct {v2, v4}, Lcom/kousei/framework/p;-><init>(Ljava/math/BigInteger;)V

    .line 152
    .line 153
    .line 154
    invoke-virtual {v0, v2}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 155
    .line 156
    .line 157
    new-instance v2, Lcom/kousei/framework/p;

    .line 158
    .line 159
    aget-object p0, p0, v1

    .line 160
    .line 161
    invoke-direct {v2, p0}, Lcom/kousei/framework/p;-><init>(Ljava/math/BigInteger;)V

    .line 162
    .line 163
    .line 164
    invoke-virtual {v0, v2}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 165
    .line 166
    .line 167
    new-instance p0, Lcom/kousei/framework/q2;

    .line 168
    .line 169
    invoke-direct {p0, v0, v3}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/k;I)V

    .line 170
    .line 171
    .line 172
    const/4 v0, -0x1

    .line 173
    iput v0, p0, Lcom/kousei/framework/q2;->d:I

    .line 174
    .line 175
    invoke-virtual {p0}, Lcom/kousei/framework/r;->g()[B

    .line 176
    .line 177
    .line 178
    move-result-object p0
    :try_end_b2
    .catch Ljava/lang/Exception; {:try_start_63 .. :try_end_b2} :catch_b3

    .line 179
    return-object p0

    .line 180
    :catch_b3
    move-exception p0

    .line 181
    new-instance v0, Ljava/lang/RuntimeException;

    .line 182
    .line 183
    const-wide v1, -0xa3960dbb5469L

    .line 184
    .line 185
    .line 186
    .line 187
    .line 188
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 189
    .line 190
    .line 191
    move-result-object v1

    .line 192
    invoke-direct {v0, v1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 193
    .line 194
    .line 195
    throw v0

    .line 196
    nop

    .line 197
    :pswitch_data_c4
    .packed-switch 0x0
        :pswitch_63
        :pswitch_28
    .end packed-switch
.end method

.method public c(Lcom/kousei/framework/n1;)V
    .registers 2

    .line 1
    check-cast p1, Lcom/kousei/framework/g4;

    .line 2
    .line 3
    iput-object p1, p0, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 4
    .line 5
    iget-object p1, p1, Lcom/kousei/framework/g4;->a:Lcom/kousei/framework/w3;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/w3;->e:Lcom/kousei/framework/v3;

    .line 8
    .line 9
    invoke-virtual {p1}, Lcom/kousei/framework/v3;->g()I

    .line 10
    .line 11
    .line 12
    sget-object p1, Lcom/kousei/framework/x1;->c:Ljava/util/concurrent/atomic/AtomicReference;

    .line 13
    .line 14
    invoke-virtual {p1}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 15
    .line 16
    .line 17
    move-result-object p1

    .line 18
    check-cast p1, Lcom/kousei/framework/v1;

    .line 19
    .line 20
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 21
    .line 22
    .line 23
    iget-object p1, p0, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 24
    .line 25
    check-cast p1, Lcom/kousei/framework/x7;

    .line 26
    .line 27
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 28
    .line 29
    .line 30
    invoke-static {}, Lcom/kousei/framework/x1;->a()Ljava/security/SecureRandom;

    .line 31
    .line 32
    .line 33
    move-result-object p1

    .line 34
    iput-object p1, p0, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 35
    .line 36
    return-void
.end method
