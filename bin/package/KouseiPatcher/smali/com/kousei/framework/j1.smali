.class public abstract Lcom/kousei/framework/j1;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final a:Lcom/kousei/framework/u;


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/u;

    .line 2
    .line 3
    const-wide v1, -0xa0100dbb5469L

    .line 4
    .line 5
    .line 6
    .line 7
    .line 8
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    invoke-direct {v0, v1}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 13
    .line 14
    .line 15
    sput-object v0, Lcom/kousei/framework/j1;->a:Lcom/kousei/framework/u;

    .line 16
    .line 17
    return-void
.end method

.method public static a(Lcom/kousei/framework/m0;Lcom/kousei/framework/i1;II)Lcom/kousei/framework/i4;
    .registers 15

    .line 1
    :try_start_0
    sget-boolean v0, Lcom/kousei/framework/n0;->a:Z

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    xor-int/2addr v0, v1

    .line 5
    invoke-static {v0}, Lcom/kousei/framework/t6;->a(Z)[Lcom/kousei/framework/j;

    .line 6
    .line 7
    .line 8
    move-result-object v0

    .line 9
    new-instance v8, Lcom/kousei/framework/q6;

    .line 10
    .line 11
    invoke-direct {v8}, Lcom/kousei/framework/q6;-><init>()V

    .line 12
    .line 13
    .line 14
    iget-object v2, p1, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    .line 15
    .line 16
    invoke-virtual {v2}, Ljava/util/ArrayList;->isEmpty()Z

    .line 17
    .line 18
    .line 19
    move-result v2

    .line 20
    if-nez v2, :cond_1a

    .line 21
    .line 22
    iget-object v2, p1, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    .line 23
    .line 24
    invoke-virtual {v8, v1, v2}, Lcom/kousei/framework/q6;->c(ILjava/util/ArrayList;)V

    .line 25
    .line 26
    .line 27
    :cond_1a
    iget v1, p1, Lcom/kousei/framework/i1;->b:I

    .line 28
    .line 29
    int-to-long v1, v1

    .line 30
    const/4 v3, 0x2

    .line 31
    invoke-virtual {v8, v3, v1, v2}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 32
    .line 33
    .line 34
    iget v1, p1, Lcom/kousei/framework/i1;->a:I

    .line 35
    .line 36
    int-to-long v1, v1

    .line 37
    const/4 v3, 0x3

    .line 38
    invoke-virtual {v8, v3, v1, v2}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 39
    .line 40
    .line 41
    iget-object v1, p1, Lcom/kousei/framework/i1;->k:Ljava/util/ArrayList;

    .line 42
    .line 43
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 44
    .line 45
    .line 46
    move-result v1

    .line 47
    if-nez v1, :cond_36

    .line 48
    .line 49
    iget-object v1, p1, Lcom/kousei/framework/i1;->k:Ljava/util/ArrayList;

    .line 50
    .line 51
    const/4 v2, 0x5

    .line 52
    invoke-virtual {v8, v2, v1}, Lcom/kousei/framework/q6;->c(ILjava/util/ArrayList;)V

    .line 53
    .line 54
    .line 55
    :cond_36
    iget v1, p1, Lcom/kousei/framework/i1;->b:I

    .line 56
    .line 57
    const/16 v2, 0xc8

    .line 58
    .line 59
    if-ne v1, v3, :cond_45

    .line 60
    .line 61
    iget v1, p1, Lcom/kousei/framework/i1;->h:I

    .line 62
    .line 63
    int-to-long v3, v1

    .line 64
    const/16 v1, 0xa

    .line 65
    .line 66
    invoke-virtual {v8, v1, v3, v4}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 67
    .line 68
    .line 69
    goto :goto_59

    .line 70
    :cond_45
    iget-object v1, p1, Lcom/kousei/framework/i1;->g:Ljava/math/BigInteger;

    .line 71
    .line 72
    if-eqz v1, :cond_4a

    .line 73
    .line 74
    goto :goto_51

    .line 75
    :cond_4a
    const-wide/32 v3, 0x10001

    .line 76
    .line 77
    .line 78
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 79
    .line 80
    .line 81
    move-result-object v1

    .line 82
    :goto_51
    new-instance v3, Lcom/kousei/framework/p;

    .line 83
    .line 84
    invoke-direct {v3, v1}, Lcom/kousei/framework/p;-><init>(Ljava/math/BigInteger;)V

    .line 85
    .line 86
    .line 87
    invoke-virtual {v8, v2, v3}, Lcom/kousei/framework/q6;->f(ILcom/kousei/framework/z;)V

    .line 88
    .line 89
    .line 90
    :goto_59
    iget-object v1, p1, Lcom/kousei/framework/i1;->l:Ljava/util/ArrayList;

    .line 91
    .line 92
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 93
    .line 94
    .line 95
    move-result v1

    .line 96
    if-nez v1, :cond_67

    .line 97
    .line 98
    iget-object v1, p1, Lcom/kousei/framework/i1;->l:Ljava/util/ArrayList;

    .line 99
    .line 100
    const/4 v3, 0x6

    .line 101
    invoke-virtual {v8, v3, v1}, Lcom/kousei/framework/q6;->c(ILjava/util/ArrayList;)V

    .line 102
    .line 103
    .line 104
    :cond_67
    iget-object v1, p1, Lcom/kousei/framework/i1;->m:Ljava/util/ArrayList;

    .line 105
    .line 106
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 107
    .line 108
    .line 109
    move-result v1

    .line 110
    if-nez v1, :cond_75

    .line 111
    .line 112
    iget-object v1, p1, Lcom/kousei/framework/i1;->m:Ljava/util/ArrayList;

    .line 113
    .line 114
    const/4 v3, 0x4

    .line 115
    invoke-virtual {v8, v3, v1}, Lcom/kousei/framework/q6;->c(ILjava/util/ArrayList;)V

    .line 116
    .line 117
    .line 118
    :cond_75
    iget-boolean v1, p1, Lcom/kousei/framework/i1;->n:Z

    .line 119
    .line 120
    if-eqz v1, :cond_80

    .line 121
    .line 122
    sget-object v1, Lcom/kousei/framework/l2;->a:Lcom/kousei/framework/l2;

    .line 123
    .line 124
    const/16 v3, 0x1f7

    .line 125
    .line 126
    invoke-virtual {v8, v3, v1}, Lcom/kousei/framework/q6;->f(ILcom/kousei/framework/z;)V

    .line 127
    .line 128
    .line 129
    :cond_80
    iget-wide v3, p1, Lcom/kousei/framework/i1;->o:J

    .line 130
    .line 131
    const-wide/16 v5, 0x0

    .line 132
    .line 133
    cmp-long v1, v3, v5

    .line 134
    .line 135
    if-ltz v1, :cond_8d

    .line 136
    .line 137
    const/16 v1, 0x1f8

    .line 138
    .line 139
    invoke-virtual {v8, v1, v3, v4}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 140
    .line 141
    .line 142
    :cond_8d
    iget v1, p1, Lcom/kousei/framework/i1;->p:I

    .line 143
    .line 144
    if-ltz v1, :cond_97

    .line 145
    .line 146
    const/16 v3, 0x1f9

    .line 147
    .line 148
    int-to-long v9, v1

    .line 149
    invoke-virtual {v8, v3, v9, v10}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 150
    .line 151
    .line 152
    :cond_97
    const/16 v1, 0x2be

    .line 153
    .line 154
    invoke-virtual {v8, v1, v5, v6}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 155
    .line 156
    .line 157
    new-instance v1, Lcom/kousei/framework/q2;

    .line 158
    .line 159
    const/4 v3, 0x0

    .line 160
    invoke-direct {v1, v0, v3}, Lcom/kousei/framework/q2;-><init>([Lcom/kousei/framework/j;I)V

    .line 161
    .line 162
    .line 163
    const/16 v0, 0x2c0

    .line 164
    .line 165
    invoke-virtual {v8, v0, v1}, Lcom/kousei/framework/q6;->f(ILcom/kousei/framework/z;)V

    .line 166
    .line 167
    .line 168
    invoke-static {}, Lcom/kousei/framework/n0;->c()I

    .line 169
    .line 170
    .line 171
    move-result v0

    .line 172
    int-to-long v0, v0

    .line 173
    const/16 v4, 0x2c1

    .line 174
    .line 175
    invoke-virtual {v8, v4, v0, v1}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 176
    .line 177
    .line 178
    iget-object p0, p0, Lcom/kousei/framework/m0;->d:Ljava/lang/Object;

    .line 179
    .line 180
    check-cast p0, Lcom/kousei/framework/v6;

    .line 181
    .line 182
    invoke-static {v3, p0}, Lcom/kousei/framework/n0;->d(ZLcom/kousei/framework/v6;)I

    .line 183
    .line 184
    .line 185
    move-result v0

    .line 186
    int-to-long v0, v0

    .line 187
    const/16 v3, 0x2c2

    .line 188
    .line 189
    invoke-virtual {v8, v3, v0, v1}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 190
    .line 191
    .line 192
    iget-object v0, p1, Lcom/kousei/framework/i1;->r:[B

    .line 193
    .line 194
    if-eqz v0, :cond_c8

    .line 195
    .line 196
    const/16 v1, 0x2c6

    .line 197
    .line 198
    invoke-virtual {v8, v1, v0}, Lcom/kousei/framework/q6;->b(I[B)V

    .line 199
    .line 200
    .line 201
    :cond_c8
    iget-object v0, p1, Lcom/kousei/framework/i1;->s:[B

    .line 202
    .line 203
    if-eqz v0, :cond_d1

    .line 204
    .line 205
    const/16 v1, 0x2c7

    .line 206
    .line 207
    invoke-virtual {v8, v1, v0}, Lcom/kousei/framework/q6;->b(I[B)V

    .line 208
    .line 209
    .line 210
    :cond_d1
    iget-object v0, p1, Lcom/kousei/framework/i1;->t:[B

    .line 211
    .line 212
    if-eqz v0, :cond_da

    .line 213
    .line 214
    const/16 v1, 0x2c8

    .line 215
    .line 216
    invoke-virtual {v8, v1, v0}, Lcom/kousei/framework/q6;->b(I[B)V

    .line 217
    .line 218
    .line 219
    :cond_da
    iget-object v0, p1, Lcom/kousei/framework/i1;->u:[B

    .line 220
    .line 221
    if-eqz v0, :cond_e3

    .line 222
    .line 223
    const/16 v1, 0x2cc

    .line 224
    .line 225
    invoke-virtual {v8, v1, v0}, Lcom/kousei/framework/q6;->b(I[B)V

    .line 226
    .line 227
    .line 228
    :cond_e3
    iget-object v0, p1, Lcom/kousei/framework/i1;->v:[B

    .line 229
    .line 230
    if-eqz v0, :cond_ec

    .line 231
    .line 232
    const/16 v1, 0x2cd

    .line 233
    .line 234
    invoke-virtual {v8, v1, v0}, Lcom/kousei/framework/q6;->b(I[B)V

    .line 235
    .line 236
    .line 237
    :cond_ec
    invoke-static {p0}, Lcom/kousei/framework/n0;->e(Lcom/kousei/framework/v6;)I

    .line 238
    .line 239
    .line 240
    move-result v0

    .line 241
    int-to-long v0, v0

    .line 242
    const/16 v3, 0x2ce

    .line 243
    .line 244
    invoke-virtual {v8, v3, v0, v1}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 245
    .line 246
    .line 247
    invoke-static {p0}, Lcom/kousei/framework/n0;->a(Lcom/kousei/framework/v6;)I

    .line 248
    .line 249
    .line 250
    move-result p0

    .line 251
    int-to-long v0, p0

    .line 252
    const/16 p0, 0x2cf

    .line 253
    .line 254
    invoke-virtual {v8, p0, v0, v1}, Lcom/kousei/framework/q6;->a(IJ)V

    .line 255
    .line 256
    .line 257
    new-instance v7, Lcom/kousei/framework/q6;

    .line 258
    .line 259
    invoke-direct {v7}, Lcom/kousei/framework/q6;-><init>()V
    :try_end_105
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_105} :catch_163

    .line 260
    .line 261
    .line 262
    :try_start_105
    invoke-static {p3}, Lcom/kousei/framework/j1;->d(I)Lcom/kousei/framework/n2;

    .line 263
    .line 264
    .line 265
    move-result-object p0

    .line 266
    if-eqz p0, :cond_112

    .line 267
    .line 268
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 269
    .line 270
    const/16 p3, 0x2c5

    .line 271
    .line 272
    invoke-virtual {v7, p3, p0}, Lcom/kousei/framework/q6;->b(I[B)V
    :try_end_112
    .catchall {:try_start_105 .. :try_end_112} :catchall_112

    .line 273
    .line 274
    .line 275
    :catchall_112
    :cond_112
    :try_start_112
    sget-object p0, Lcom/kousei/framework/t6;->a:Ljava/util/concurrent/atomic/AtomicReference;

    .line 276
    .line 277
    invoke-virtual {p0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 278
    .line 279
    .line 280
    move-result-object p3

    .line 281
    check-cast p3, Lcom/kousei/framework/s6;

    .line 282
    .line 283
    const/4 v0, -0x1

    .line 284
    if-eqz p3, :cond_124

    .line 285
    .line 286
    iget-boolean v1, p3, Lcom/kousei/framework/s6;->e:Z

    .line 287
    .line 288
    if-eqz v1, :cond_124

    .line 289
    .line 290
    iget p3, p3, Lcom/kousei/framework/s6;->f:I

    .line 291
    .line 292
    goto :goto_125

    .line 293
    :cond_124
    move p3, v0

    .line 294
    :goto_125
    const/16 v1, 0x64

    .line 295
    .line 296
    const/16 v3, 0x190

    .line 297
    .line 298
    const/16 v4, 0x12c

    .line 299
    .line 300
    if-lez p3, :cond_12e

    .line 301
    .line 302
    goto :goto_13a

    .line 303
    :cond_12e
    sget p3, Landroid/os/Build$VERSION;->SDK_INT:I

    .line 304
    .line 305
    packed-switch p3, :pswitch_data_166

    .line 306
    .line 307
    .line 308
    move p3, v3

    .line 309
    goto :goto_13a

    .line 310
    :pswitch_135
    move p3, v4

    .line 311
    goto :goto_13a

    .line 312
    :pswitch_137
    move p3, v2

    .line 313
    goto :goto_13a

    .line 314
    :pswitch_139
    move p3, v1

    .line 315
    :goto_13a
    invoke-virtual {p0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 316
    .line 317
    .line 318
    move-result-object p0

    .line 319
    check-cast p0, Lcom/kousei/framework/s6;

    .line 320
    .line 321
    if-eqz p0, :cond_148

    .line 322
    .line 323
    iget-boolean v5, p0, Lcom/kousei/framework/s6;->e:Z

    .line 324
    .line 325
    if-eqz v5, :cond_148

    .line 326
    .line 327
    iget v0, p0, Lcom/kousei/framework/s6;->g:I

    .line 328
    .line 329
    :cond_148
    if-lez v0, :cond_14c

    .line 330
    .line 331
    move v4, v0

    .line 332
    goto :goto_157

    .line 333
    :cond_14c
    sget p0, Landroid/os/Build$VERSION;->SDK_INT:I

    .line 334
    .line 335
    packed-switch p0, :pswitch_data_174

    .line 336
    .line 337
    .line 338
    move v2, v3

    .line 339
    goto :goto_156

    .line 340
    :pswitch_153
    move v2, v4

    .line 341
    goto :goto_156

    .line 342
    :pswitch_155
    move v2, v1

    .line 343
    :goto_156
    :pswitch_156
    move v4, v2

    .line 344
    :goto_157
    iget-object v6, p1, Lcom/kousei/framework/i1;->q:[B

    .line 345
    .line 346
    move v5, p2

    .line 347
    move v3, p2

    .line 348
    move v2, p3

    .line 349
    invoke-static/range {v2 .. v8}, Lcom/kousei/framework/q6;->e(IIII[BLcom/kousei/framework/q6;Lcom/kousei/framework/q6;)Lcom/kousei/framework/i4;

    .line 350
    .line 351
    .line 352
    move-result-object p0
    :try_end_160
    .catch Ljava/lang/Exception; {:try_start_112 .. :try_end_160} :catch_163

    .line 353
    if-eqz p0, :cond_163

    .line 354
    .line 355
    return-object p0

    .line 356
    :catch_163
    :cond_163
    const/4 p0, 0x0

    .line 357
    return-object p0

    .line 358
    nop

    :pswitch_data_166
    .packed-switch 0x1f
        :pswitch_139
        :pswitch_139
        :pswitch_137
        :pswitch_135
        :pswitch_135
    .end packed-switch

    :pswitch_data_174
    .packed-switch 0x1f
        :pswitch_155
        :pswitch_155
        :pswitch_156
        :pswitch_153
        :pswitch_153
    .end packed-switch
.end method

.method public static b(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/t5;Lcom/kousei/framework/i1;Lcom/kousei/framework/va;II)Ljava/security/cert/X509Certificate;
    .registers 15

    .line 1
    iget-object v0, p3, Lcom/kousei/framework/i1;->c:Ljava/math/BigInteger;

    if-eqz v0, :cond_6

    :goto_4
    move-object v3, v0

    goto :goto_9

    .line 2
    :cond_6
    sget-object v0, Ljava/math/BigInteger;->ONE:Ljava/math/BigInteger;

    goto :goto_4

    .line 3
    :goto_9
    iget-object v0, p3, Lcom/kousei/framework/i1;->d:Ljava/util/Date;

    if-eqz v0, :cond_f

    :goto_d
    move-object v4, v0

    goto :goto_15

    .line 4
    :cond_f
    new-instance v0, Ljava/util/Date;

    invoke-direct {v0}, Ljava/util/Date;-><init>()V

    goto :goto_d

    .line 5
    :goto_15
    iget-object v0, p3, Lcom/kousei/framework/i1;->e:Ljava/util/Date;

    if-eqz v0, :cond_1b

    :goto_19
    move-object v5, v0

    goto :goto_29

    .line 6
    :cond_1b
    iget-object v0, p2, Lcom/kousei/framework/t5;->b:Ljava/util/List;

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/security/cert/X509Certificate;

    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getNotAfter()Ljava/util/Date;

    move-result-object v0

    goto :goto_19

    .line 7
    :goto_29
    iget-object v0, p3, Lcom/kousei/framework/i1;->f:Ljavax/security/auth/x500/X500Principal;

    if-eqz v0, :cond_37

    .line 8
    invoke-virtual {v0}, Ljavax/security/auth/x500/X500Principal;->getEncoded()[B

    move-result-object v0

    invoke-static {v0}, Lcom/kousei/framework/va;->i(Ljava/lang/Object;)Lcom/kousei/framework/va;

    move-result-object v0

    :goto_35
    move-object v6, v0

    goto :goto_3c

    .line 9
    :cond_37
    invoke-static {}, Lcom/kousei/framework/j1;->e()Lcom/kousei/framework/va;

    move-result-object v0

    goto :goto_35

    .line 10
    :goto_3c
    invoke-virtual {p1}, Ljava/security/KeyPair;->getPublic()Ljava/security/PublicKey;

    move-result-object p1

    invoke-interface {p1}, Ljava/security/Key;->getEncoded()[B

    move-result-object p1

    .line 11
    invoke-static {p1}, Lcom/kousei/framework/ka;->i(Ljava/lang/Object;)Lcom/kousei/framework/ka;

    move-result-object v7

    .line 12
    :try_start_48
    new-instance v1, Lcom/kousei/framework/o4;

    move-object v2, p4

    invoke-direct/range {v1 .. v7}, Lcom/kousei/framework/o4;-><init>(Lcom/kousei/framework/va;Ljava/math/BigInteger;Ljava/util/Date;Ljava/util/Date;Lcom/kousei/framework/va;Lcom/kousei/framework/ka;)V

    .line 13
    iget-object p1, p3, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    invoke-static {p1}, Lcom/kousei/framework/j1;->i(Ljava/util/ArrayList;)I

    move-result p1

    const/4 p4, 0x4

    if-nez p1, :cond_58

    move p1, p4

    .line 14
    :cond_58
    sget-object v0, Lcom/kousei/framework/i4;->e:Lcom/kousei/framework/u;

    new-instance v2, Lcom/kousei/framework/d1;

    invoke-direct {v2, p1}, Lcom/kousei/framework/d1;-><init>(I)V

    invoke-virtual {v1, v0, v2}, Lcom/kousei/framework/o4;->b(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V

    and-int/2addr p1, p4

    if-eqz p1, :cond_6f

    .line 15
    sget-object p1, Lcom/kousei/framework/i4;->h:Lcom/kousei/framework/u;

    new-instance p4, Lcom/kousei/framework/d1;

    invoke-direct {p4}, Lcom/kousei/framework/d1;-><init>()V

    invoke-virtual {v1, p1, p4}, Lcom/kousei/framework/o4;->b(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V

    .line 16
    :cond_6f
    invoke-static {p0, p3, p5, p6}, Lcom/kousei/framework/j1;->a(Lcom/kousei/framework/m0;Lcom/kousei/framework/i1;II)Lcom/kousei/framework/i4;

    move-result-object p0

    if-eqz p0, :cond_7c

    .line 17
    iget-object p1, v1, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    check-cast p1, Lcom/kousei/framework/k4;

    invoke-virtual {p1, p0}, Lcom/kousei/framework/k4;->b(Lcom/kousei/framework/i4;)V

    .line 18
    :cond_7c
    iget-object p0, p2, Lcom/kousei/framework/t5;->a:Ljava/security/KeyPair;

    invoke-virtual {p0}, Ljava/security/KeyPair;->getPrivate()Ljava/security/PrivateKey;

    move-result-object p0

    .line 19
    invoke-static {p0}, Lcom/kousei/framework/j1;->j(Ljava/security/PrivateKey;)Ljava/lang/String;

    move-result-object p1

    .line 20
    new-instance p2, Lcom/kousei/framework/l5;

    invoke-direct {p2, p1}, Lcom/kousei/framework/l5;-><init>(Ljava/lang/String;)V
    :try_end_8b
    .catch Ljava/lang/Exception; {:try_start_48 .. :try_end_8b} :catch_c7

    .line 21
    :try_start_8b
    invoke-static {p0}, Lcom/kousei/framework/j1;->h(Ljava/security/PrivateKey;)Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    move-result-object p1

    .line 22
    new-instance p3, Ljava/security/spec/PKCS8EncodedKeySpec;

    invoke-interface {p0}, Ljava/security/Key;->getEncoded()[B

    move-result-object p4

    invoke-direct {p3, p4}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    invoke-virtual {p1, p3}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    move-result-object p0
    :try_end_a0
    .catch Ljava/lang/Exception; {:try_start_8b .. :try_end_a0} :catch_a0

    .line 23
    :catch_a0
    :try_start_a0
    invoke-virtual {p2, p0}, Lcom/kousei/framework/l5;->a(Ljava/security/PrivateKey;)Lcom/kousei/framework/k1;

    move-result-object p0

    .line 24
    invoke-virtual {v1, p0}, Lcom/kousei/framework/o4;->c(Lcom/kousei/framework/k1;)Lcom/kousei/framework/xa;

    move-result-object p0

    const-wide p1, -0xa09f0dbb5469L

    .line 25
    invoke-static {p1, p2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/security/cert/CertificateFactory;->getInstance(Ljava/lang/String;)Ljava/security/cert/CertificateFactory;

    move-result-object p1

    .line 26
    new-instance p2, Ljava/io/ByteArrayInputStream;

    .line 27
    iget-object p0, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    invoke-virtual {p0}, Lcom/kousei/framework/r;->g()[B

    move-result-object p0

    .line 28
    invoke-direct {p2, p0}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    .line 29
    invoke-virtual {p1, p2}, Ljava/security/cert/CertificateFactory;->generateCertificate(Ljava/io/InputStream;)Ljava/security/cert/Certificate;

    move-result-object p0

    check-cast p0, Ljava/security/cert/X509Certificate;
    :try_end_c6
    .catch Ljava/lang/Exception; {:try_start_a0 .. :try_end_c6} :catch_c7

    return-object p0

    :catch_c7
    const/4 p0, 0x0

    return-object p0
.end method

.method public static c(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;IILcom/kousei/framework/va;Ljava/security/PrivateKey;)Ljava/security/cert/X509Certificate;
    .registers 15

    if-eqz p5, :cond_c9

    if-nez p6, :cond_6

    goto/16 :goto_c9

    .line 1
    :cond_6
    :try_start_6
    iget-object v0, p2, Lcom/kousei/framework/i1;->c:Ljava/math/BigInteger;

    if-eqz v0, :cond_c

    :goto_a
    move-object v3, v0

    goto :goto_f

    .line 2
    :cond_c
    sget-object v0, Ljava/math/BigInteger;->ONE:Ljava/math/BigInteger;

    goto :goto_a

    .line 3
    :goto_f
    iget-object v0, p2, Lcom/kousei/framework/i1;->d:Ljava/util/Date;

    if-eqz v0, :cond_15

    :goto_13
    move-object v4, v0

    goto :goto_1b

    .line 4
    :cond_15
    new-instance v0, Ljava/util/Date;

    invoke-direct {v0}, Ljava/util/Date;-><init>()V

    goto :goto_13

    .line 5
    :goto_1b
    iget-object v0, p2, Lcom/kousei/framework/i1;->e:Ljava/util/Date;

    if-eqz v0, :cond_21

    :goto_1f
    move-object v5, v0

    goto :goto_31

    .line 6
    :cond_21
    new-instance v0, Ljava/util/Date;

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v1

    const-wide v5, 0x496cebb800L

    add-long/2addr v1, v5

    invoke-direct {v0, v1, v2}, Ljava/util/Date;-><init>(J)V

    goto :goto_1f

    .line 7
    :goto_31
    iget-object v0, p2, Lcom/kousei/framework/i1;->f:Ljavax/security/auth/x500/X500Principal;

    if-eqz v0, :cond_3f

    .line 8
    invoke-virtual {v0}, Ljavax/security/auth/x500/X500Principal;->getEncoded()[B

    move-result-object v0

    invoke-static {v0}, Lcom/kousei/framework/va;->i(Ljava/lang/Object;)Lcom/kousei/framework/va;

    move-result-object v0

    :goto_3d
    move-object v6, v0

    goto :goto_44

    .line 9
    :cond_3f
    invoke-static {}, Lcom/kousei/framework/j1;->e()Lcom/kousei/framework/va;

    move-result-object v0

    goto :goto_3d

    .line 10
    :goto_44
    invoke-virtual {p1}, Ljava/security/KeyPair;->getPublic()Ljava/security/PublicKey;

    move-result-object p1

    invoke-interface {p1}, Ljava/security/Key;->getEncoded()[B

    move-result-object p1

    .line 11
    invoke-static {p1}, Lcom/kousei/framework/ka;->i(Ljava/lang/Object;)Lcom/kousei/framework/ka;

    move-result-object v7

    .line 12
    new-instance v1, Lcom/kousei/framework/o4;

    move-object v2, p5

    invoke-direct/range {v1 .. v7}, Lcom/kousei/framework/o4;-><init>(Lcom/kousei/framework/va;Ljava/math/BigInteger;Ljava/util/Date;Ljava/util/Date;Lcom/kousei/framework/va;Lcom/kousei/framework/ka;)V

    .line 13
    iget-object p1, p2, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    invoke-static {p1}, Lcom/kousei/framework/j1;->i(Ljava/util/ArrayList;)I

    move-result p1

    const/4 p5, 0x4

    if-nez p1, :cond_60

    move p1, p5

    .line 14
    :cond_60
    sget-object v0, Lcom/kousei/framework/i4;->e:Lcom/kousei/framework/u;

    new-instance v2, Lcom/kousei/framework/d1;

    invoke-direct {v2, p1}, Lcom/kousei/framework/d1;-><init>(I)V

    invoke-virtual {v1, v0, v2}, Lcom/kousei/framework/o4;->b(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V

    and-int/2addr p1, p5

    if-eqz p1, :cond_77

    .line 15
    sget-object p1, Lcom/kousei/framework/i4;->h:Lcom/kousei/framework/u;

    new-instance p5, Lcom/kousei/framework/d1;

    invoke-direct {p5}, Lcom/kousei/framework/d1;-><init>()V

    invoke-virtual {v1, p1, p5}, Lcom/kousei/framework/o4;->b(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V

    .line 16
    :cond_77
    invoke-static {p0, p2, p3, p4}, Lcom/kousei/framework/j1;->a(Lcom/kousei/framework/m0;Lcom/kousei/framework/i1;II)Lcom/kousei/framework/i4;

    move-result-object p0

    if-eqz p0, :cond_84

    .line 17
    iget-object p1, v1, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    check-cast p1, Lcom/kousei/framework/k4;

    invoke-virtual {p1, p0}, Lcom/kousei/framework/k4;->b(Lcom/kousei/framework/i4;)V

    .line 18
    :cond_84
    invoke-static {p6}, Lcom/kousei/framework/j1;->j(Ljava/security/PrivateKey;)Ljava/lang/String;

    move-result-object p0

    .line 19
    new-instance p1, Lcom/kousei/framework/l5;

    invoke-direct {p1, p0}, Lcom/kousei/framework/l5;-><init>(Ljava/lang/String;)V
    :try_end_8d
    .catchall {:try_start_6 .. :try_end_8d} :catchall_c9

    .line 20
    :try_start_8d
    invoke-static {p6}, Lcom/kousei/framework/j1;->h(Ljava/security/PrivateKey;)Ljava/lang/String;

    move-result-object p0

    .line 21
    invoke-static {p0}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    move-result-object p0

    .line 22
    new-instance p2, Ljava/security/spec/PKCS8EncodedKeySpec;

    .line 23
    invoke-interface {p6}, Ljava/security/Key;->getEncoded()[B

    move-result-object p3

    invoke-direct {p2, p3}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    .line 24
    invoke-virtual {p0, p2}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    move-result-object p6
    :try_end_a2
    .catch Ljava/lang/Exception; {:try_start_8d .. :try_end_a2} :catch_a2
    .catchall {:try_start_8d .. :try_end_a2} :catchall_c9

    .line 25
    :catch_a2
    :try_start_a2
    invoke-virtual {p1, p6}, Lcom/kousei/framework/l5;->a(Ljava/security/PrivateKey;)Lcom/kousei/framework/k1;

    move-result-object p0

    .line 26
    invoke-virtual {v1, p0}, Lcom/kousei/framework/o4;->c(Lcom/kousei/framework/k1;)Lcom/kousei/framework/xa;

    move-result-object p0

    const-wide p1, -0xa0950dbb5469L

    .line 27
    invoke-static {p1, p2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/security/cert/CertificateFactory;->getInstance(Ljava/lang/String;)Ljava/security/cert/CertificateFactory;

    move-result-object p1

    .line 28
    new-instance p2, Ljava/io/ByteArrayInputStream;

    .line 29
    iget-object p0, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    invoke-virtual {p0}, Lcom/kousei/framework/r;->g()[B

    move-result-object p0

    .line 30
    invoke-direct {p2, p0}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    .line 31
    invoke-virtual {p1, p2}, Ljava/security/cert/CertificateFactory;->generateCertificate(Ljava/io/InputStream;)Ljava/security/cert/Certificate;

    move-result-object p0

    check-cast p0, Ljava/security/cert/X509Certificate;
    :try_end_c8
    .catchall {:try_start_a2 .. :try_end_c8} :catchall_c9

    return-object p0

    :catchall_c9
    :cond_c9
    :goto_c9
    const/4 p0, 0x0

    return-object p0
.end method

.method public static d(I)Lcom/kousei/framework/n2;
    .registers 15

    .line 1
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    const/4 v1, 0x0

    .line 6
    if-eqz v0, :cond_ce

    .line 7
    .line 8
    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    .line 9
    .line 10
    .line 11
    move-result-object v0

    .line 12
    if-eqz v0, :cond_c1

    .line 13
    .line 14
    invoke-virtual {v0, p0}, Landroid/content/pm/PackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 15
    .line 16
    .line 17
    move-result-object p0

    .line 18
    if-eqz p0, :cond_c0

    .line 19
    .line 20
    array-length v2, p0

    .line 21
    if-nez v2, :cond_18

    .line 22
    .line 23
    goto/16 :goto_c0

    .line 24
    .line 25
    :cond_18
    array-length v1, p0

    .line 26
    new-array v2, v1, [Lcom/kousei/framework/j;

    .line 27
    .line 28
    new-instance v3, Ljava/util/HashSet;

    .line 29
    .line 30
    invoke-direct {v3}, Ljava/util/HashSet;-><init>()V

    .line 31
    .line 32
    .line 33
    const-wide v4, -0xa0180dbb5469L

    .line 34
    .line 35
    .line 36
    .line 37
    .line 38
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 39
    .line 40
    .line 41
    move-result-object v4

    .line 42
    invoke-static {v4}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 43
    .line 44
    .line 45
    move-result-object v4

    .line 46
    const/4 v5, 0x0

    .line 47
    move v6, v5

    .line 48
    :goto_2f
    const/4 v7, 0x2

    .line 49
    const/4 v8, 0x1

    .line 50
    if-ge v6, v1, :cond_7b

    .line 51
    .line 52
    aget-object v9, p0, v6

    .line 53
    .line 54
    const/16 v10, 0x40

    .line 55
    .line 56
    invoke-virtual {v0, v9, v10}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    .line 57
    .line 58
    .line 59
    move-result-object v10

    .line 60
    new-instance v11, Lcom/kousei/framework/n2;

    .line 61
    .line 62
    sget-object v12, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 63
    .line 64
    invoke-virtual {v9, v12}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 65
    .line 66
    .line 67
    move-result-object v9

    .line 68
    invoke-direct {v11, v9}, Lcom/kousei/framework/v;-><init>([B)V

    .line 69
    .line 70
    .line 71
    new-instance v9, Lcom/kousei/framework/p;

    .line 72
    .line 73
    invoke-virtual {v10}, Landroid/content/pm/PackageInfo;->getLongVersionCode()J

    .line 74
    .line 75
    .line 76
    move-result-wide v12

    .line 77
    invoke-direct {v9, v12, v13}, Lcom/kousei/framework/p;-><init>(J)V

    .line 78
    .line 79
    .line 80
    new-array v7, v7, [Lcom/kousei/framework/j;

    .line 81
    .line 82
    aput-object v11, v7, v5

    .line 83
    .line 84
    aput-object v9, v7, v8

    .line 85
    .line 86
    new-instance v8, Lcom/kousei/framework/q2;

    .line 87
    .line 88
    invoke-direct {v8, v7, v5}, Lcom/kousei/framework/q2;-><init>([Lcom/kousei/framework/j;I)V

    .line 89
    .line 90
    .line 91
    aput-object v8, v2, v6

    .line 92
    .line 93
    iget-object v7, v10, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;

    .line 94
    .line 95
    if-eqz v7, :cond_78

    .line 96
    .line 97
    array-length v8, v7

    .line 98
    move v9, v5

    .line 99
    :goto_62
    if-ge v9, v8, :cond_78

    .line 100
    .line 101
    aget-object v10, v7, v9

    .line 102
    .line 103
    invoke-virtual {v10}, Landroid/content/pm/Signature;->toByteArray()[B

    .line 104
    .line 105
    .line 106
    move-result-object v10

    .line 107
    invoke-virtual {v4, v10}, Ljava/security/MessageDigest;->digest([B)[B

    .line 108
    .line 109
    .line 110
    move-result-object v10

    .line 111
    invoke-static {v10}, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;

    .line 112
    .line 113
    .line 114
    move-result-object v10

    .line 115
    invoke-virtual {v3, v10}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 116
    .line 117
    .line 118
    add-int/lit8 v9, v9, 0x1

    .line 119
    .line 120
    goto :goto_62

    .line 121
    :cond_78
    add-int/lit8 v6, v6, 0x1

    .line 122
    .line 123
    goto :goto_2f

    .line 124
    :cond_7b
    invoke-virtual {v3}, Ljava/util/HashSet;->size()I

    .line 125
    .line 126
    .line 127
    move-result p0

    .line 128
    new-array p0, p0, [Lcom/kousei/framework/j;

    .line 129
    .line 130
    invoke-virtual {v3}, Ljava/util/HashSet;->iterator()Ljava/util/Iterator;

    .line 131
    .line 132
    .line 133
    move-result-object v0

    .line 134
    move v1, v5

    .line 135
    :goto_86
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    .line 136
    .line 137
    .line 138
    move-result v3

    .line 139
    if-eqz v3, :cond_a1

    .line 140
    .line 141
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 142
    .line 143
    .line 144
    move-result-object v3

    .line 145
    check-cast v3, Ljava/nio/ByteBuffer;

    .line 146
    .line 147
    add-int/lit8 v4, v1, 0x1

    .line 148
    .line 149
    new-instance v6, Lcom/kousei/framework/n2;

    .line 150
    .line 151
    invoke-virtual {v3}, Ljava/nio/ByteBuffer;->array()[B

    .line 152
    .line 153
    .line 154
    move-result-object v3

    .line 155
    invoke-direct {v6, v3}, Lcom/kousei/framework/v;-><init>([B)V

    .line 156
    .line 157
    .line 158
    aput-object v6, p0, v1

    .line 159
    .line 160
    move v1, v4

    .line 161
    goto :goto_86

    .line 162
    :cond_a1
    new-instance v0, Lcom/kousei/framework/r2;

    .line 163
    .line 164
    invoke-direct {v0, v2, v5}, Lcom/kousei/framework/r2;-><init>([Lcom/kousei/framework/j;I)V

    .line 165
    .line 166
    .line 167
    new-instance v1, Lcom/kousei/framework/r2;

    .line 168
    .line 169
    invoke-direct {v1, p0, v5}, Lcom/kousei/framework/r2;-><init>([Lcom/kousei/framework/j;I)V

    .line 170
    .line 171
    .line 172
    new-array p0, v7, [Lcom/kousei/framework/j;

    .line 173
    .line 174
    aput-object v0, p0, v5

    .line 175
    .line 176
    aput-object v1, p0, v8

    .line 177
    .line 178
    new-instance v0, Lcom/kousei/framework/n2;

    .line 179
    .line 180
    new-instance v1, Lcom/kousei/framework/q2;

    .line 181
    .line 182
    invoke-direct {v1, p0, v5}, Lcom/kousei/framework/q2;-><init>([Lcom/kousei/framework/j;I)V

    .line 183
    .line 184
    .line 185
    invoke-virtual {v1}, Lcom/kousei/framework/r;->g()[B

    .line 186
    .line 187
    .line 188
    move-result-object p0

    .line 189
    invoke-direct {v0, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 190
    .line 191
    .line 192
    return-object v0

    .line 193
    :cond_c0
    :goto_c0
    return-object v1

    .line 194
    :cond_c1
    const-wide v2, -0xa0eb0dbb5469L

    .line 195
    .line 196
    .line 197
    .line 198
    .line 199
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 200
    .line 201
    .line 202
    move-result-object p0

    .line 203
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 204
    .line 205
    .line 206
    return-object v1

    .line 207
    :cond_ce
    const-wide v2, -0xa0ab0dbb5469L

    .line 208
    .line 209
    .line 210
    .line 211
    .line 212
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 213
    .line 214
    .line 215
    move-result-object p0

    .line 216
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 217
    .line 218
    .line 219
    return-object v1
.end method

.method public static e()Lcom/kousei/framework/va;
    .registers 7

    .line 1
    new-instance v0, Lcom/kousei/framework/va;

    .line 2
    .line 3
    new-instance v1, Lcom/kousei/framework/p7;

    .line 4
    .line 5
    new-instance v2, Lcom/kousei/framework/o0;

    .line 6
    .line 7
    new-instance v3, Lcom/kousei/framework/u;

    .line 8
    .line 9
    const-wide v4, -0xa1f40dbb5469L

    .line 10
    .line 11
    .line 12
    .line 13
    .line 14
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 15
    .line 16
    .line 17
    move-result-object v4

    .line 18
    invoke-direct {v3, v4}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 19
    .line 20
    .line 21
    new-instance v4, Lcom/kousei/framework/u2;

    .line 22
    .line 23
    const-wide v5, -0xa10c0dbb5469L

    .line 24
    .line 25
    .line 26
    .line 27
    .line 28
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 29
    .line 30
    .line 31
    move-result-object v5

    .line 32
    invoke-direct {v4, v5}, Lcom/kousei/framework/u2;-><init>(Ljava/lang/String;)V

    .line 33
    .line 34
    .line 35
    invoke-direct {v2, v3, v4}, Lcom/kousei/framework/o0;-><init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V

    .line 36
    .line 37
    .line 38
    invoke-direct {v1, v2}, Lcom/kousei/framework/p7;-><init>(Lcom/kousei/framework/o0;)V

    .line 39
    .line 40
    .line 41
    filled-new-array {v1}, [Lcom/kousei/framework/p7;

    .line 42
    .line 43
    .line 44
    move-result-object v1

    .line 45
    invoke-direct {v0, v1}, Lcom/kousei/framework/va;-><init>([Lcom/kousei/framework/p7;)V

    .line 46
    .line 47
    .line 48
    return-object v0
.end method

.method public static f(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;II)Ljava/util/ArrayList;
    .registers 13

    .line 1
    iget v0, p2, Lcom/kousei/framework/i1;->b:I

    .line 2
    .line 3
    const/4 v1, 0x3

    .line 4
    if-ne v0, v1, :cond_f

    .line 5
    .line 6
    const-wide v0, -0xa0860dbb5469L

    .line 7
    .line 8
    .line 9
    .line 10
    .line 11
    :goto_a
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    goto :goto_15

    .line 16
    :cond_f
    const-wide v0, -0xa09b0dbb5469L

    .line 17
    .line 18
    .line 19
    .line 20
    .line 21
    goto :goto_a

    .line 22
    :goto_15
    invoke-virtual {p0, v0}, Lcom/kousei/framework/m0;->a(Ljava/lang/String;)Lcom/kousei/framework/t5;

    .line 23
    .line 24
    .line 25
    move-result-object v3

    .line 26
    if-nez v3, :cond_1c

    .line 27
    .line 28
    goto :goto_4a

    .line 29
    :cond_1c
    :try_start_1c
    iget-object v0, v3, Lcom/kousei/framework/t5;->b:Ljava/util/List;

    .line 30
    .line 31
    new-instance v1, Lcom/kousei/framework/xa;

    .line 32
    .line 33
    const/4 v2, 0x0

    .line 34
    invoke-interface {v0, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    .line 35
    .line 36
    .line 37
    move-result-object v2

    .line 38
    check-cast v2, Ljava/security/cert/Certificate;

    .line 39
    .line 40
    invoke-virtual {v2}, Ljava/security/cert/Certificate;->getEncoded()[B

    .line 41
    .line 42
    .line 43
    move-result-object v2

    .line 44
    invoke-direct {v1, v2}, Lcom/kousei/framework/xa;-><init>([B)V

    .line 45
    .line 46
    .line 47
    invoke-virtual {v1}, Lcom/kousei/framework/xa;->b()Lcom/kousei/framework/va;

    .line 48
    .line 49
    .line 50
    move-result-object v5

    .line 51
    move-object v1, p0

    .line 52
    move-object v2, p1

    .line 53
    move-object v4, p2

    .line 54
    move v6, p3

    .line 55
    move v7, p4

    .line 56
    invoke-static/range {v1 .. v7}, Lcom/kousei/framework/j1;->b(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/t5;Lcom/kousei/framework/i1;Lcom/kousei/framework/va;II)Ljava/security/cert/X509Certificate;

    .line 57
    .line 58
    .line 59
    move-result-object p0

    .line 60
    if-nez p0, :cond_3e

    .line 61
    .line 62
    goto :goto_4a

    .line 63
    :cond_3e
    new-instance p1, Ljava/util/ArrayList;

    .line 64
    .line 65
    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    .line 66
    .line 67
    .line 68
    invoke-virtual {p1, p0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 69
    .line 70
    .line 71
    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z
    :try_end_49
    .catch Ljava/lang/Exception; {:try_start_1c .. :try_end_49} :catch_4a

    .line 72
    .line 73
    .line 74
    return-object p1

    .line 75
    :catch_4a
    :goto_4a
    const/4 p0, 0x0

    .line 76
    return-object p0
.end method

.method public static g(Lcom/kousei/framework/i1;)Ljava/security/KeyPair;
    .registers 5

    .line 1
    :try_start_0
    iget v0, p0, Lcom/kousei/framework/i1;->b:I

    .line 2
    .line 3
    const/4 v1, 0x3

    .line 4
    if-ne v0, v1, :cond_63

    .line 5
    .line 6
    const-wide v0, -0xa0810dbb5469L

    .line 7
    .line 8
    .line 9
    .line 10
    .line 11
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    invoke-static {v0}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 16
    .line 17
    .line 18
    move-result-object v0

    .line 19
    new-instance v1, Ljava/security/spec/ECGenParameterSpec;

    .line 20
    .line 21
    iget-object v2, p0, Lcom/kousei/framework/i1;->i:Ljava/lang/String;

    .line 22
    .line 23
    if-eqz v2, :cond_19

    .line 24
    .line 25
    goto :goto_5c

    .line 26
    :cond_19
    iget p0, p0, Lcom/kousei/framework/i1;->a:I

    .line 27
    .line 28
    const/16 v2, 0xe0

    .line 29
    .line 30
    if-eq p0, v2, :cond_53

    .line 31
    .line 32
    const/16 v2, 0x100

    .line 33
    .line 34
    if-eq p0, v2, :cond_49

    .line 35
    .line 36
    const/16 v2, 0x180

    .line 37
    .line 38
    if-eq p0, v2, :cond_3f

    .line 39
    .line 40
    const/16 v2, 0x209

    .line 41
    .line 42
    if-eq p0, v2, :cond_35

    .line 43
    .line 44
    const-wide v2, -0xa3840dbb5469L

    .line 45
    .line 46
    .line 47
    .line 48
    .line 49
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 50
    .line 51
    .line 52
    move-result-object v2

    .line 53
    goto :goto_5c

    .line 54
    :cond_35
    const-wide v2, -0xa38a0dbb5469L

    .line 55
    .line 56
    .line 57
    .line 58
    .line 59
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 60
    .line 61
    .line 62
    move-result-object v2

    .line 63
    goto :goto_5c

    .line 64
    :cond_3f
    const-wide v2, -0xa0700dbb5469L

    .line 65
    .line 66
    .line 67
    .line 68
    .line 69
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 70
    .line 71
    .line 72
    move-result-object v2

    .line 73
    goto :goto_5c

    .line 74
    :cond_49
    const-wide v2, -0xa0660dbb5469L

    .line 75
    .line 76
    .line 77
    .line 78
    .line 79
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object v2

    .line 83
    goto :goto_5c

    .line 84
    :cond_53
    const-wide v2, -0xa06c0dbb5469L

    .line 85
    .line 86
    .line 87
    .line 88
    .line 89
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 90
    .line 91
    .line 92
    move-result-object v2

    .line 93
    :goto_5c
    invoke-direct {v1, v2}, Ljava/security/spec/ECGenParameterSpec;-><init>(Ljava/lang/String;)V

    .line 94
    .line 95
    .line 96
    invoke-virtual {v0, v1}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 97
    .line 98
    .line 99
    goto :goto_84

    .line 100
    :cond_63
    const/4 v1, 0x1

    .line 101
    if-ne v0, v1, :cond_89

    .line 102
    .line 103
    const-wide v0, -0xa0820dbb5469L

    .line 104
    .line 105
    .line 106
    .line 107
    .line 108
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 109
    .line 110
    .line 111
    move-result-object v0

    .line 112
    invoke-static {v0}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 113
    .line 114
    .line 115
    move-result-object v0

    .line 116
    new-instance v1, Ljava/security/spec/RSAKeyGenParameterSpec;

    .line 117
    .line 118
    iget v2, p0, Lcom/kousei/framework/i1;->a:I

    .line 119
    .line 120
    iget-object p0, p0, Lcom/kousei/framework/i1;->g:Ljava/math/BigInteger;

    .line 121
    .line 122
    if-eqz p0, :cond_7c

    .line 123
    .line 124
    goto :goto_7e

    .line 125
    :cond_7c
    sget-object p0, Ljava/security/spec/RSAKeyGenParameterSpec;->F4:Ljava/math/BigInteger;

    .line 126
    .line 127
    :goto_7e
    invoke-direct {v1, v2, p0}, Ljava/security/spec/RSAKeyGenParameterSpec;-><init>(ILjava/math/BigInteger;)V

    .line 128
    .line 129
    .line 130
    invoke-virtual {v0, v1}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 131
    .line 132
    .line 133
    :goto_84
    invoke-virtual {v0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;

    .line 134
    .line 135
    .line 136
    move-result-object p0
    :try_end_88
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_88} :catch_89

    .line 137
    return-object p0

    .line 138
    :catch_89
    :cond_89
    const/4 p0, 0x0

    .line 139
    return-object p0
.end method

.method public static h(Ljava/security/PrivateKey;)Ljava/lang/String;
    .registers 3

    .line 1
    if-nez p0, :cond_c

    .line 2
    .line 3
    const-wide v0, -0xa1700dbb5469L

    .line 4
    .line 5
    .line 6
    .line 7
    .line 8
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object p0

    .line 12
    return-object p0

    .line 13
    :cond_c
    instance-of v0, p0, Ljava/security/interfaces/RSAPrivateKey;

    .line 14
    .line 15
    if-nez v0, :cond_2e

    .line 16
    .line 17
    const-wide v0, -0xa1740dbb5469L

    .line 18
    .line 19
    .line 20
    .line 21
    .line 22
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    move-result-object v0

    .line 26
    invoke-interface {p0}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    .line 27
    .line 28
    .line 29
    move-result-object p0

    .line 30
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 31
    .line 32
    .line 33
    move-result p0

    .line 34
    if-eqz p0, :cond_24

    .line 35
    .line 36
    goto :goto_2e

    .line 37
    :cond_24
    const-wide v0, -0xa08c0dbb5469L

    .line 38
    .line 39
    .line 40
    .line 41
    .line 42
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 43
    .line 44
    .line 45
    move-result-object p0

    .line 46
    return-object p0

    .line 47
    :cond_2e
    :goto_2e
    const-wide v0, -0xa0880dbb5469L

    .line 48
    .line 49
    .line 50
    .line 51
    .line 52
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 53
    .line 54
    .line 55
    move-result-object p0

    .line 56
    return-object p0
.end method

.method public static i(Ljava/util/ArrayList;)I
    .registers 3

    .line 1
    const/4 v0, 0x0

    .line 2
    if-nez p0, :cond_4

    .line 3
    .line 4
    return v0

    .line 5
    :cond_4
    const/4 v1, 0x2

    .line 6
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 7
    .line 8
    .line 9
    move-result-object v1

    .line 10
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 11
    .line 12
    .line 13
    move-result v1

    .line 14
    if-nez v1, :cond_1d

    .line 15
    .line 16
    const/4 v1, 0x3

    .line 17
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 18
    .line 19
    .line 20
    move-result-object v1

    .line 21
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 22
    .line 23
    .line 24
    move-result v1

    .line 25
    if-eqz v1, :cond_1b

    .line 26
    .line 27
    goto :goto_1d

    .line 28
    :cond_1b
    move v1, v0

    .line 29
    goto :goto_1f

    .line 30
    :cond_1d
    :goto_1d
    const/16 v1, 0x80

    .line 31
    .line 32
    :goto_1f
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 33
    .line 34
    .line 35
    move-result-object v0

    .line 36
    invoke-virtual {p0, v0}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 37
    .line 38
    .line 39
    move-result v0

    .line 40
    if-nez v0, :cond_34

    .line 41
    .line 42
    const/4 v0, 0x1

    .line 43
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 44
    .line 45
    .line 46
    move-result-object v0

    .line 47
    invoke-virtual {p0, v0}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 48
    .line 49
    .line 50
    move-result v0

    .line 51
    if-eqz v0, :cond_36

    .line 52
    .line 53
    :cond_34
    or-int/lit8 v1, v1, 0x30

    .line 54
    .line 55
    :cond_36
    const/4 v0, 0x5

    .line 56
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 57
    .line 58
    .line 59
    move-result-object v0

    .line 60
    invoke-virtual {p0, v0}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 61
    .line 62
    .line 63
    move-result v0

    .line 64
    if-eqz v0, :cond_43

    .line 65
    .line 66
    or-int/lit8 v1, v1, 0x20

    .line 67
    .line 68
    :cond_43
    const/4 v0, 0x6

    .line 69
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 70
    .line 71
    .line 72
    move-result-object v0

    .line 73
    invoke-virtual {p0, v0}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 74
    .line 75
    .line 76
    move-result v0

    .line 77
    if-eqz v0, :cond_50

    .line 78
    .line 79
    or-int/lit8 v1, v1, 0x8

    .line 80
    .line 81
    :cond_50
    const/4 v0, 0x7

    .line 82
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 83
    .line 84
    .line 85
    move-result-object v0

    .line 86
    invoke-virtual {p0, v0}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    .line 87
    .line 88
    .line 89
    move-result p0

    .line 90
    if-eqz p0, :cond_5e

    .line 91
    .line 92
    or-int/lit8 p0, v1, 0x4

    .line 93
    .line 94
    return p0

    .line 95
    :cond_5e
    return v1
.end method

.method public static j(Ljava/security/PrivateKey;)Ljava/lang/String;
    .registers 3

    .line 1
    if-nez p0, :cond_c

    .line 2
    .line 3
    const-wide v0, -0xa1130dbb5469L

    .line 4
    .line 5
    .line 6
    .line 7
    .line 8
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object p0

    .line 12
    return-object p0

    .line 13
    :cond_c
    instance-of v0, p0, Ljava/security/interfaces/RSAPrivateKey;

    .line 14
    .line 15
    if-eqz v0, :cond_1a

    .line 16
    .line 17
    const-wide v0, -0xa1210dbb5469L

    .line 18
    .line 19
    .line 20
    .line 21
    .line 22
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    move-result-object p0

    .line 26
    return-object p0

    .line 27
    :cond_1a
    instance-of v0, p0, Ljava/security/interfaces/ECPrivateKey;

    .line 28
    .line 29
    if-eqz v0, :cond_28

    .line 30
    .line 31
    const-wide v0, -0xa13f0dbb5469L

    .line 32
    .line 33
    .line 34
    .line 35
    .line 36
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 37
    .line 38
    .line 39
    move-result-object p0

    .line 40
    return-object p0

    .line 41
    :cond_28
    invoke-interface {p0}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    .line 42
    .line 43
    .line 44
    move-result-object p0

    .line 45
    const-wide v0, -0xa14f0dbb5469L

    .line 46
    .line 47
    .line 48
    .line 49
    .line 50
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object v0

    .line 54
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 55
    .line 56
    .line 57
    move-result v0

    .line 58
    if-eqz v0, :cond_45

    .line 59
    .line 60
    const-wide v0, -0xa1430dbb5469L

    .line 61
    .line 62
    .line 63
    .line 64
    .line 65
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 66
    .line 67
    .line 68
    move-result-object p0

    .line 69
    return-object p0

    .line 70
    :cond_45
    const-wide v0, -0xa1510dbb5469L

    .line 71
    .line 72
    .line 73
    .line 74
    .line 75
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 76
    .line 77
    .line 78
    move-result-object v0

    .line 79
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 80
    .line 81
    .line 82
    move-result p0

    .line 83
    if-eqz p0, :cond_5e

    .line 84
    .line 85
    const-wide v0, -0xa1520dbb5469L

    .line 86
    .line 87
    .line 88
    .line 89
    .line 90
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 91
    .line 92
    .line 93
    move-result-object p0

    .line 94
    return-object p0

    .line 95
    :cond_5e
    const-wide v0, -0xa1620dbb5469L

    .line 96
    .line 97
    .line 98
    .line 99
    .line 100
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 101
    .line 102
    .line 103
    move-result-object p0

    .line 104
    return-object p0
.end method
