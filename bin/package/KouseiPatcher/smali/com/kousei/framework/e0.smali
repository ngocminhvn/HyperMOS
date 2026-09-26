.class public final Lcom/kousei/framework/e0;
.super Ljava/lang/Object;


# instance fields
.field public final a:Lcom/kousei/framework/e6;

.field public final b:I

.field public final c:[[B

.field public final d:I

.field public final e:I


# direct methods
.method public constructor <init>(Lcom/kousei/framework/e6;I[[BII)V
    .registers 6

    .line 24
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/kousei/framework/e0;->a:Lcom/kousei/framework/e6;

    iput p2, p0, Lcom/kousei/framework/e0;->b:I

    iput-object p3, p0, Lcom/kousei/framework/e0;->c:[[B

    iput p4, p0, Lcom/kousei/framework/e0;->d:I

    iput p5, p0, Lcom/kousei/framework/e0;->e:I

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/i5;I[[B)V
    .registers 4

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-object p1, p0, Lcom/kousei/framework/e0;->a:Lcom/kousei/framework/e6;

    .line 5
    .line 6
    iput p2, p0, Lcom/kousei/framework/e0;->b:I

    .line 7
    .line 8
    iput-object p3, p0, Lcom/kousei/framework/e0;->c:[[B

    .line 9
    .line 10
    const/4 p1, 0x0

    .line 11
    iput p1, p0, Lcom/kousei/framework/e0;->d:I

    .line 12
    .line 13
    const-string p1, "org.bouncycastle.asn1.max_cons_depth"

    .line 14
    .line 15
    const/16 p2, 0x20

    .line 16
    .line 17
    invoke-static {p2, p1}, Lcom/kousei/framework/o7;->a(ILjava/lang/String;)I

    .line 18
    .line 19
    .line 20
    move-result p1

    .line 21
    iput p1, p0, Lcom/kousei/framework/e0;->e:I

    .line 22
    .line 23
    return-void
.end method


# virtual methods
.method public final a(I)Lcom/kousei/framework/j;
    .registers 23

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move/from16 v1, p1

    .line 4
    .line 5
    iget v2, v0, Lcom/kousei/framework/e0;->d:I

    .line 6
    .line 7
    iget v3, v0, Lcom/kousei/framework/e0;->e:I

    .line 8
    .line 9
    if-eq v2, v3, :cond_147

    .line 10
    .line 11
    iget-object v3, v0, Lcom/kousei/framework/e0;->a:Lcom/kousei/framework/e6;

    .line 12
    .line 13
    instance-of v4, v3, Lcom/kousei/framework/i5;

    .line 14
    .line 15
    const/4 v5, 0x0

    .line 16
    if-eqz v4, :cond_19

    .line 17
    .line 18
    move-object v4, v3

    .line 19
    check-cast v4, Lcom/kousei/framework/i5;

    .line 20
    .line 21
    iput-boolean v5, v4, Lcom/kousei/framework/i5;->f:Z

    .line 22
    .line 23
    invoke-virtual {v4}, Lcom/kousei/framework/i5;->b()Z

    .line 24
    .line 25
    .line 26
    :cond_19
    invoke-static {v3, v1}, Lcom/kousei/framework/o;->g(Ljava/io/InputStream;I)I

    .line 27
    .line 28
    .line 29
    move-result v4

    .line 30
    const/4 v6, 0x1

    .line 31
    const/16 v7, 0x8

    .line 32
    .line 33
    const/16 v8, 0x11

    .line 34
    .line 35
    const/16 v9, 0x10

    .line 36
    .line 37
    const/4 v10, 0x4

    .line 38
    const/4 v11, 0x3

    .line 39
    if-eq v4, v11, :cond_33

    .line 40
    .line 41
    if-eq v4, v10, :cond_33

    .line 42
    .line 43
    if-eq v4, v9, :cond_33

    .line 44
    .line 45
    if-eq v4, v8, :cond_33

    .line 46
    .line 47
    if-ne v4, v7, :cond_31

    .line 48
    .line 49
    goto :goto_33

    .line 50
    :cond_31
    move v12, v5

    .line 51
    goto :goto_34

    .line 52
    :cond_33
    :goto_33
    move v12, v6

    .line 53
    :goto_34
    iget v13, v0, Lcom/kousei/framework/e0;->b:I

    .line 54
    .line 55
    invoke-static {v3, v13, v12}, Lcom/kousei/framework/o;->e(Ljava/io/InputStream;IZ)I

    .line 56
    .line 57
    .line 58
    move-result v12

    .line 59
    const/4 v14, 0x0

    .line 60
    if-gez v12, :cond_a3

    .line 61
    .line 62
    and-int/lit8 v12, v1, 0x20

    .line 63
    .line 64
    if-eqz v12, :cond_9b

    .line 65
    .line 66
    new-instance v12, Lcom/kousei/framework/i5;

    .line 67
    .line 68
    invoke-direct {v12, v3, v13}, Lcom/kousei/framework/i5;-><init>(Ljava/io/InputStream;I)V

    .line 69
    .line 70
    .line 71
    new-instance v15, Lcom/kousei/framework/e0;

    .line 72
    .line 73
    add-int/lit8 v19, v2, 0x1

    .line 74
    .line 75
    iget v2, v0, Lcom/kousei/framework/e0;->e:I

    .line 76
    .line 77
    iget v3, v0, Lcom/kousei/framework/e0;->b:I

    .line 78
    .line 79
    iget-object v0, v0, Lcom/kousei/framework/e0;->c:[[B

    .line 80
    .line 81
    move-object/from16 v18, v0

    .line 82
    .line 83
    move/from16 v20, v2

    .line 84
    .line 85
    move/from16 v17, v3

    .line 86
    .line 87
    move-object/from16 v16, v12

    .line 88
    .line 89
    invoke-direct/range {v15 .. v20}, Lcom/kousei/framework/e0;-><init>(Lcom/kousei/framework/e6;I[[BII)V

    .line 90
    .line 91
    .line 92
    and-int/lit16 v0, v1, 0xc0

    .line 93
    .line 94
    if-eqz v0, :cond_65

    .line 95
    .line 96
    new-instance v1, Lcom/kousei/framework/b1;

    .line 97
    .line 98
    invoke-direct {v1, v0, v4, v15}, Lcom/kousei/framework/b1;-><init>(IILcom/kousei/framework/e0;)V

    .line 99
    .line 100
    .line 101
    return-object v1

    .line 102
    :cond_65
    if-eq v4, v11, :cond_95

    .line 103
    .line 104
    if-eq v4, v10, :cond_8f

    .line 105
    .line 106
    if-eq v4, v7, :cond_89

    .line 107
    .line 108
    if-eq v4, v9, :cond_81

    .line 109
    .line 110
    if-ne v4, v8, :cond_77

    .line 111
    .line 112
    new-instance v0, Lcom/kousei/framework/y0;

    .line 113
    .line 114
    invoke-direct {v0, v6}, Lcom/kousei/framework/y0;-><init>(I)V

    .line 115
    .line 116
    .line 117
    iput-object v15, v0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 118
    .line 119
    return-object v0

    .line 120
    :cond_77
    const-string v0, "unknown BER object encountered: 0x"

    .line 121
    .line 122
    invoke-static {v4}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    .line 123
    .line 124
    .line 125
    move-result-object v1

    .line 126
    invoke-static {v1, v0}, Lcom/kousei/framework/e;->i(Ljava/lang/Object;Ljava/lang/String;)V

    .line 127
    .line 128
    .line 129
    return-object v14

    .line 130
    :cond_81
    new-instance v0, Lcom/kousei/framework/y0;

    .line 131
    .line 132
    invoke-direct {v0, v5}, Lcom/kousei/framework/y0;-><init>(I)V

    .line 133
    .line 134
    .line 135
    iput-object v15, v0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 136
    .line 137
    return-object v0

    .line 138
    :cond_89
    new-instance v0, Lcom/kousei/framework/y0;

    .line 139
    .line 140
    invoke-direct {v0, v15}, Lcom/kousei/framework/y0;-><init>(Lcom/kousei/framework/e0;)V

    .line 141
    .line 142
    .line 143
    return-object v0

    .line 144
    :cond_8f
    new-instance v0, Lcom/kousei/framework/w0;

    .line 145
    .line 146
    invoke-direct {v0, v15}, Lcom/kousei/framework/w0;-><init>(Lcom/kousei/framework/e0;)V

    .line 147
    .line 148
    .line 149
    return-object v0

    .line 150
    :cond_95
    new-instance v0, Lcom/kousei/framework/t0;

    .line 151
    .line 152
    invoke-direct {v0, v15}, Lcom/kousei/framework/t0;-><init>(Lcom/kousei/framework/e0;)V

    .line 153
    .line 154
    .line 155
    return-object v0

    .line 156
    :cond_9b
    new-instance v0, Ljava/io/IOException;

    .line 157
    .line 158
    const-string v1, "indefinite-length primitive encoding encountered"

    .line 159
    .line 160
    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 161
    .line 162
    .line 163
    throw v0

    .line 164
    :cond_a3
    new-instance v15, Lcom/kousei/framework/j3;

    .line 165
    .line 166
    invoke-direct {v15, v3, v12, v13}, Lcom/kousei/framework/j3;-><init>(Ljava/io/InputStream;II)V

    .line 167
    .line 168
    .line 169
    and-int/lit16 v3, v1, 0xe0

    .line 170
    .line 171
    if-nez v3, :cond_ec

    .line 172
    .line 173
    if-eq v4, v11, :cond_e6

    .line 174
    .line 175
    if-eq v4, v10, :cond_de

    .line 176
    .line 177
    if-eq v4, v7, :cond_d6

    .line 178
    .line 179
    if-eq v4, v9, :cond_ce

    .line 180
    .line 181
    if-eq v4, v8, :cond_c6

    .line 182
    .line 183
    :try_start_b6
    iget-object v0, v0, Lcom/kousei/framework/e0;->c:[[B

    .line 184
    .line 185
    invoke-static {v4, v15, v0}, Lcom/kousei/framework/o;->b(ILcom/kousei/framework/j3;[[B)Lcom/kousei/framework/z;

    .line 186
    .line 187
    .line 188
    move-result-object v0
    :try_end_bc
    .catch Ljava/lang/IllegalArgumentException; {:try_start_b6 .. :try_end_bc} :catch_bd

    .line 189
    return-object v0

    .line 190
    :catch_bd
    move-exception v0

    .line 191
    new-instance v1, Lcom/kousei/framework/m;

    .line 192
    .line 193
    const-string v2, "corrupted stream detected"

    .line 194
    .line 195
    invoke-direct {v1, v2, v0, v5}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 196
    .line 197
    .line 198
    throw v1

    .line 199
    :cond_c6
    new-instance v0, Lcom/kousei/framework/m;

    .line 200
    .line 201
    const-string v1, "sequences must use constructed encoding (see X.690 8.9.1/8.10.1)"

    .line 202
    .line 203
    invoke-direct {v0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;)V

    .line 204
    .line 205
    .line 206
    throw v0

    .line 207
    :cond_ce
    new-instance v0, Lcom/kousei/framework/m;

    .line 208
    .line 209
    const-string v1, "sets must use constructed encoding (see X.690 8.11.1/8.12.1)"

    .line 210
    .line 211
    invoke-direct {v0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;)V

    .line 212
    .line 213
    .line 214
    throw v0

    .line 215
    :cond_d6
    new-instance v0, Lcom/kousei/framework/m;

    .line 216
    .line 217
    const-string v1, "externals must use constructed encoding (see X.690 8.18)"

    .line 218
    .line 219
    invoke-direct {v0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;)V

    .line 220
    .line 221
    .line 222
    throw v0

    .line 223
    :cond_de
    new-instance v0, Lcom/kousei/framework/w0;

    .line 224
    .line 225
    invoke-direct {v0}, Lcom/kousei/framework/w0;-><init>()V

    .line 226
    .line 227
    .line 228
    iput-object v15, v0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 229
    .line 230
    return-object v0

    .line 231
    :cond_e6
    new-instance v0, Lcom/kousei/framework/z2;

    .line 232
    .line 233
    invoke-direct {v0, v15}, Lcom/kousei/framework/z2;-><init>(Lcom/kousei/framework/j3;)V

    .line 234
    .line 235
    .line 236
    return-object v0

    .line 237
    :cond_ec
    new-instance v3, Lcom/kousei/framework/e0;

    .line 238
    .line 239
    add-int/lit8 v19, v2, 0x1

    .line 240
    .line 241
    iget v2, v0, Lcom/kousei/framework/e0;->e:I

    .line 242
    .line 243
    iget v12, v15, Lcom/kousei/framework/e6;->b:I

    .line 244
    .line 245
    iget-object v0, v0, Lcom/kousei/framework/e0;->c:[[B

    .line 246
    .line 247
    move-object/from16 v18, v0

    .line 248
    .line 249
    move/from16 v20, v2

    .line 250
    .line 251
    move/from16 v17, v12

    .line 252
    .line 253
    move-object/from16 v16, v15

    .line 254
    .line 255
    move-object v15, v3

    .line 256
    invoke-direct/range {v15 .. v20}, Lcom/kousei/framework/e0;-><init>(Lcom/kousei/framework/e6;I[[BII)V

    .line 257
    .line 258
    .line 259
    and-int/lit16 v0, v1, 0xc0

    .line 260
    .line 261
    if-eqz v0, :cond_111

    .line 262
    .line 263
    and-int/lit8 v1, v1, 0x20

    .line 264
    .line 265
    if-eqz v1, :cond_10b

    .line 266
    .line 267
    move v5, v6

    .line 268
    :cond_10b
    new-instance v1, Lcom/kousei/framework/c3;

    .line 269
    .line 270
    invoke-direct {v1, v0, v4, v5, v15}, Lcom/kousei/framework/c3;-><init>(IIZLcom/kousei/framework/e0;)V

    .line 271
    .line 272
    .line 273
    return-object v1

    .line 274
    :cond_111
    if-eq v4, v11, :cond_141

    .line 275
    .line 276
    if-eq v4, v10, :cond_13b

    .line 277
    .line 278
    if-eq v4, v7, :cond_135

    .line 279
    .line 280
    if-eq v4, v9, :cond_12d

    .line 281
    .line 282
    if-ne v4, v8, :cond_123

    .line 283
    .line 284
    new-instance v0, Lcom/kousei/framework/y0;

    .line 285
    .line 286
    invoke-direct {v0, v10}, Lcom/kousei/framework/y0;-><init>(I)V

    .line 287
    .line 288
    .line 289
    iput-object v15, v0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 290
    .line 291
    return-object v0

    .line 292
    :cond_123
    const-string v0, "unknown DL object encountered: 0x"

    .line 293
    .line 294
    invoke-static {v4}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    .line 295
    .line 296
    .line 297
    move-result-object v1

    .line 298
    invoke-static {v1, v0}, Lcom/kousei/framework/e;->i(Ljava/lang/Object;Ljava/lang/String;)V

    .line 299
    .line 300
    .line 301
    return-object v14

    .line 302
    :cond_12d
    new-instance v0, Lcom/kousei/framework/y0;

    .line 303
    .line 304
    invoke-direct {v0, v11}, Lcom/kousei/framework/y0;-><init>(I)V

    .line 305
    .line 306
    .line 307
    iput-object v15, v0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 308
    .line 309
    return-object v0

    .line 310
    :cond_135
    new-instance v0, Lcom/kousei/framework/y0;

    .line 311
    .line 312
    invoke-direct {v0, v15}, Lcom/kousei/framework/y0;-><init>(Lcom/kousei/framework/e0;)V

    .line 313
    .line 314
    .line 315
    return-object v0

    .line 316
    :cond_13b
    new-instance v0, Lcom/kousei/framework/w0;

    .line 317
    .line 318
    invoke-direct {v0, v15}, Lcom/kousei/framework/w0;-><init>(Lcom/kousei/framework/e0;)V

    .line 319
    .line 320
    .line 321
    return-object v0

    .line 322
    :cond_141
    new-instance v0, Lcom/kousei/framework/t0;

    .line 323
    .line 324
    invoke-direct {v0, v15}, Lcom/kousei/framework/t0;-><init>(Lcom/kousei/framework/e0;)V

    .line 325
    .line 326
    .line 327
    return-object v0

    .line 328
    :cond_147
    new-instance v0, Ljava/io/IOException;

    .line 329
    .line 330
    new-instance v1, Ljava/lang/StringBuilder;

    .line 331
    .line 332
    const-string v2, "maximum nested construction level reached - increase org.bouncycastle.asn1.max_cons_depth (currently "

    .line 333
    .line 334
    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 335
    .line 336
    .line 337
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 338
    .line 339
    .line 340
    const-string v2, ")"

    .line 341
    .line 342
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 343
    .line 344
    .line 345
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 346
    .line 347
    .line 348
    move-result-object v1

    .line 349
    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 350
    .line 351
    .line 352
    throw v0
.end method

.method public final b(II)Lcom/kousei/framework/a1;
    .registers 12

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    iget v0, p0, Lcom/kousei/framework/k;->b:I

    .line 6
    .line 7
    const/4 v1, 0x1

    .line 8
    if-ne v0, v1, :cond_18

    .line 9
    .line 10
    new-instance v2, Lcom/kousei/framework/a1;

    .line 11
    .line 12
    const/4 v0, 0x0

    .line 13
    invoke-virtual {p0, v0}, Lcom/kousei/framework/k;->c(I)Lcom/kousei/framework/j;

    .line 14
    .line 15
    .line 16
    move-result-object v6

    .line 17
    const/4 v7, 0x0

    .line 18
    const/4 v3, 0x3

    .line 19
    move v4, p1

    .line 20
    move v5, p2

    .line 21
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/a1;-><init>(IIILcom/kousei/framework/j;I)V

    .line 22
    .line 23
    .line 24
    return-object v2

    .line 25
    :cond_18
    move v4, p1

    .line 26
    move v5, p2

    .line 27
    new-instance v3, Lcom/kousei/framework/a1;

    .line 28
    .line 29
    sget-object p1, Lcom/kousei/framework/u0;->a:Lcom/kousei/framework/x0;

    .line 30
    .line 31
    if-ge v0, v1, :cond_24

    .line 32
    .line 33
    sget-object p0, Lcom/kousei/framework/u0;->a:Lcom/kousei/framework/x0;

    .line 34
    .line 35
    move-object v7, p0

    .line 36
    goto :goto_2a

    .line 37
    :cond_24
    new-instance p1, Lcom/kousei/framework/x0;

    .line 38
    .line 39
    invoke-direct {p1, p0}, Lcom/kousei/framework/c0;-><init>(Lcom/kousei/framework/k;)V

    .line 40
    .line 41
    .line 42
    move-object v7, p1

    .line 43
    :goto_2a
    const/4 v8, 0x0

    .line 44
    move v6, v5

    .line 45
    move v5, v4

    .line 46
    const/4 v4, 0x4

    .line 47
    invoke-direct/range {v3 .. v8}, Lcom/kousei/framework/a1;-><init>(IIILcom/kousei/framework/j;I)V

    .line 48
    .line 49
    .line 50
    return-object v3
.end method

.method public final c()Lcom/kousei/framework/k;
    .registers 5

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/e0;->a:Lcom/kousei/framework/e6;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/io/InputStream;->read()I

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-gez v1, :cond_f

    .line 8
    .line 9
    new-instance p0, Lcom/kousei/framework/k;

    .line 10
    .line 11
    const/4 v0, 0x0

    .line 12
    invoke-direct {p0, v0}, Lcom/kousei/framework/k;-><init>(I)V

    .line 13
    .line 14
    .line 15
    return-object p0

    .line 16
    :cond_f
    new-instance v2, Lcom/kousei/framework/k;

    .line 17
    .line 18
    invoke-direct {v2}, Lcom/kousei/framework/k;-><init>()V

    .line 19
    .line 20
    .line 21
    :cond_14
    invoke-virtual {p0, v1}, Lcom/kousei/framework/e0;->a(I)Lcom/kousei/framework/j;

    .line 22
    .line 23
    .line 24
    move-result-object v1

    .line 25
    instance-of v3, v1, Lcom/kousei/framework/h5;

    .line 26
    .line 27
    if-eqz v3, :cond_26

    .line 28
    .line 29
    check-cast v1, Lcom/kousei/framework/h5;

    .line 30
    .line 31
    invoke-interface {v1}, Lcom/kousei/framework/h5;->e()Lcom/kousei/framework/z;

    .line 32
    .line 33
    .line 34
    move-result-object v1

    .line 35
    :goto_22
    invoke-virtual {v2, v1}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 36
    .line 37
    .line 38
    goto :goto_2b

    .line 39
    :cond_26
    invoke-interface {v1}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 40
    .line 41
    .line 42
    move-result-object v1

    .line 43
    goto :goto_22

    .line 44
    :goto_2b
    invoke-virtual {v0}, Ljava/io/InputStream;->read()I

    .line 45
    .line 46
    .line 47
    move-result v1

    .line 48
    if-gez v1, :cond_14

    .line 49
    .line 50
    return-object v2
.end method
