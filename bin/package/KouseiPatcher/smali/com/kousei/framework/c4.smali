.class public final Lcom/kousei/framework/c4;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/kousei/framework/h7;


# instance fields
.field public final synthetic a:Z

.field public final synthetic b:Z

.field public final synthetic c:Lcom/kousei/framework/d4;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/d4;ZZ)V
    .registers 4

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-boolean p2, p0, Lcom/kousei/framework/c4;->a:Z

    .line 5
    .line 6
    iput-boolean p3, p0, Lcom/kousei/framework/c4;->b:Z

    .line 7
    .line 8
    iput-object p1, p0, Lcom/kousei/framework/c4;->c:Lcom/kousei/framework/d4;

    .line 9
    .line 10
    return-void
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/i7;)Lcom/kousei/framework/i7;
    .registers 16

    .line 1
    instance-of v0, p1, Lcom/kousei/framework/ua;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    if-eqz v0, :cond_8

    .line 5
    .line 6
    check-cast p1, Lcom/kousei/framework/ua;

    .line 7
    .line 8
    goto :goto_9

    .line 9
    :cond_8
    move-object p1, v1

    .line 10
    :goto_9
    const/4 v0, 0x0

    .line 11
    if-nez p1, :cond_17

    .line 12
    .line 13
    new-instance p1, Lcom/kousei/framework/ua;

    .line 14
    .line 15
    invoke-direct {p1}, Ljava/lang/Object;-><init>()V

    .line 16
    .line 17
    .line 18
    iput-boolean v0, p1, Lcom/kousei/framework/ua;->a:Z

    .line 19
    .line 20
    iput-boolean v0, p1, Lcom/kousei/framework/ua;->b:Z

    .line 21
    .line 22
    iput-boolean v0, p1, Lcom/kousei/framework/ua;->c:Z

    .line 23
    .line 24
    :cond_17
    iget-boolean v2, p1, Lcom/kousei/framework/ua;->a:Z

    .line 25
    .line 26
    if-eqz v2, :cond_1d

    .line 27
    .line 28
    goto/16 :goto_241

    .line 29
    .line 30
    :cond_1d
    iget-boolean v2, p1, Lcom/kousei/framework/ua;->b:Z

    .line 31
    .line 32
    iget-object v3, p0, Lcom/kousei/framework/c4;->c:Lcom/kousei/framework/d4;

    .line 33
    .line 34
    const/4 v4, 0x1

    .line 35
    if-nez v2, :cond_14c

    .line 36
    .line 37
    iget-boolean v2, p0, Lcom/kousei/framework/c4;->a:Z

    .line 38
    .line 39
    if-nez v2, :cond_14a

    .line 40
    .line 41
    iget v2, v3, Lcom/kousei/framework/d4;->f:I

    .line 42
    .line 43
    const-string v5, "unsupported coordinate system"

    .line 44
    .line 45
    packed-switch v2, :pswitch_data_242

    .line 46
    .line 47
    .line 48
    iget-object v2, v3, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 49
    .line 50
    iget-object v6, v3, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 51
    .line 52
    iget-object v7, v3, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 53
    .line 54
    iget-object v8, v3, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 55
    .line 56
    iget-object v9, v8, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 57
    .line 58
    iget-object v8, v8, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 59
    .line 60
    invoke-virtual {v7}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 61
    .line 62
    .line 63
    move-result-object v7

    .line 64
    invoke-virtual {v3}, Lcom/kousei/framework/d4;->d()I

    .line 65
    .line 66
    .line 67
    move-result v10

    .line 68
    if-eqz v10, :cond_90

    .line 69
    .line 70
    if-eq v10, v4, :cond_74

    .line 71
    .line 72
    const/4 v11, 0x2

    .line 73
    if-eq v10, v11, :cond_57

    .line 74
    .line 75
    const/4 v11, 0x3

    .line 76
    if-eq v10, v11, :cond_57

    .line 77
    .line 78
    const/4 v11, 0x4

    .line 79
    if-ne v10, v11, :cond_51

    .line 80
    .line 81
    goto :goto_57

    .line 82
    :cond_51
    invoke-static {v5}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 83
    .line 84
    .line 85
    :goto_54
    move v2, v0

    .line 86
    goto/16 :goto_145

    .line 87
    .line 88
    :cond_57
    :goto_57
    aget-object v2, v2, v0

    .line 89
    .line 90
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->A0()Z

    .line 91
    .line 92
    .line 93
    move-result v5

    .line 94
    if-nez v5, :cond_90

    .line 95
    .line 96
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 97
    .line 98
    .line 99
    move-result-object v2

    .line 100
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 101
    .line 102
    .line 103
    move-result-object v5

    .line 104
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 105
    .line 106
    .line 107
    move-result-object v2

    .line 108
    invoke-virtual {v9, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 109
    .line 110
    .line 111
    move-result-object v9

    .line 112
    invoke-virtual {v8, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 113
    .line 114
    .line 115
    move-result-object v8

    .line 116
    goto :goto_90

    .line 117
    :cond_74
    aget-object v2, v2, v0

    .line 118
    .line 119
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->A0()Z

    .line 120
    .line 121
    .line 122
    move-result v5

    .line 123
    if-nez v5, :cond_90

    .line 124
    .line 125
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 126
    .line 127
    .line 128
    move-result-object v5

    .line 129
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 130
    .line 131
    .line 132
    move-result-object v10

    .line 133
    invoke-virtual {v7, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 134
    .line 135
    .line 136
    move-result-object v7

    .line 137
    invoke-virtual {v9, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 138
    .line 139
    .line 140
    move-result-object v9

    .line 141
    invoke-virtual {v8, v10}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 142
    .line 143
    .line 144
    move-result-object v8

    .line 145
    :cond_90
    :goto_90
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 146
    .line 147
    .line 148
    move-result-object v2

    .line 149
    invoke-virtual {v2, v9}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 150
    .line 151
    .line 152
    move-result-object v2

    .line 153
    invoke-virtual {v2, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 154
    .line 155
    .line 156
    move-result-object v2

    .line 157
    invoke-virtual {v2, v8}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 158
    .line 159
    .line 160
    move-result-object v2

    .line 161
    invoke-virtual {v7, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 162
    .line 163
    .line 164
    move-result v2

    .line 165
    goto/16 :goto_145

    .line 166
    .line 167
    :pswitch_a6
    iget-object v2, v3, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 168
    .line 169
    iget-object v6, v3, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 170
    .line 171
    iget-object v7, v3, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 172
    .line 173
    iget-object v8, v3, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 174
    .line 175
    iget-object v9, v7, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 176
    .line 177
    iget-object v10, v7, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 178
    .line 179
    iget v7, v7, Lcom/kousei/framework/v3;->f:I

    .line 180
    .line 181
    const/4 v11, 0x6

    .line 182
    if-ne v7, v11, :cond_106

    .line 183
    .line 184
    aget-object v5, v6, v0

    .line 185
    .line 186
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->A0()Z

    .line 187
    .line 188
    .line 189
    move-result v6

    .line 190
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->E0()Z

    .line 191
    .line 192
    .line 193
    move-result v7

    .line 194
    if-eqz v7, :cond_d6

    .line 195
    .line 196
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 197
    .line 198
    .line 199
    move-result-object v2

    .line 200
    if-nez v6, :cond_d1

    .line 201
    .line 202
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 203
    .line 204
    .line 205
    move-result-object v5

    .line 206
    invoke-virtual {v10, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 207
    .line 208
    .line 209
    move-result-object v10

    .line 210
    :cond_d1
    invoke-virtual {v2, v10}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 211
    .line 212
    .line 213
    move-result v2

    .line 214
    goto :goto_145

    .line 215
    :cond_d6
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 216
    .line 217
    .line 218
    move-result-object v7

    .line 219
    if-eqz v6, :cond_e9

    .line 220
    .line 221
    invoke-static {v2, v2, v9}, Lcom/kousei/framework/p0;->d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 222
    .line 223
    .line 224
    move-result-object v2

    .line 225
    invoke-virtual {v7}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 226
    .line 227
    .line 228
    move-result-object v5

    .line 229
    invoke-virtual {v5, v10}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 230
    .line 231
    .line 232
    move-result-object v5

    .line 233
    goto :goto_fd

    .line 234
    :cond_e9
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 235
    .line 236
    .line 237
    move-result-object v6

    .line 238
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 239
    .line 240
    .line 241
    move-result-object v8

    .line 242
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 243
    .line 244
    .line 245
    move-result-object v5

    .line 246
    invoke-virtual {v5, v2, v9, v6}, Lcom/kousei/framework/h0;->l1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 247
    .line 248
    .line 249
    move-result-object v2

    .line 250
    invoke-virtual {v7, v10, v8}, Lcom/kousei/framework/h0;->B2(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 251
    .line 252
    .line 253
    move-result-object v5

    .line 254
    :goto_fd
    invoke-virtual {v2, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 255
    .line 256
    .line 257
    move-result-object v2

    .line 258
    :goto_101
    invoke-virtual {v2, v5}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 259
    .line 260
    .line 261
    move-result v2

    .line 262
    goto :goto_145

    .line 263
    :cond_106
    invoke-virtual {v2, v8}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 264
    .line 265
    .line 266
    move-result-object v11

    .line 267
    invoke-virtual {v11, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 268
    .line 269
    .line 270
    move-result-object v2

    .line 271
    if-eqz v7, :cond_134

    .line 272
    .line 273
    if-ne v7, v4, :cond_12f

    .line 274
    .line 275
    aget-object v5, v6, v0

    .line 276
    .line 277
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->A0()Z

    .line 278
    .line 279
    .line 280
    move-result v6

    .line 281
    if-nez v6, :cond_134

    .line 282
    .line 283
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 284
    .line 285
    .line 286
    move-result-object v6

    .line 287
    invoke-virtual {v5, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 288
    .line 289
    .line 290
    move-result-object v6

    .line 291
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 292
    .line 293
    .line 294
    move-result-object v2

    .line 295
    invoke-virtual {v9, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 296
    .line 297
    .line 298
    move-result-object v9

    .line 299
    invoke-virtual {v10, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 300
    .line 301
    .line 302
    move-result-object v10

    .line 303
    goto :goto_134

    .line 304
    :cond_12f
    invoke-static {v5}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 305
    .line 306
    .line 307
    goto/16 :goto_54

    .line 308
    .line 309
    :cond_134
    :goto_134
    invoke-virtual {v8, v9}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 310
    .line 311
    .line 312
    move-result-object v5

    .line 313
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 314
    .line 315
    .line 316
    move-result-object v6

    .line 317
    invoke-virtual {v5, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 318
    .line 319
    .line 320
    move-result-object v5

    .line 321
    invoke-virtual {v5, v10}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 322
    .line 323
    .line 324
    move-result-object v5

    .line 325
    goto :goto_101

    .line 326
    :goto_145
    if-nez v2, :cond_14a

    .line 327
    .line 328
    iput-boolean v4, p1, Lcom/kousei/framework/ua;->a:Z

    .line 329
    .line 330
    return-object p1

    .line 331
    :cond_14a
    iput-boolean v4, p1, Lcom/kousei/framework/ua;->b:Z

    .line 332
    .line 333
    :cond_14c
    iget-boolean p0, p0, Lcom/kousei/framework/c4;->b:Z

    .line 334
    .line 335
    if-eqz p0, :cond_241

    .line 336
    .line 337
    iget-boolean p0, p1, Lcom/kousei/framework/ua;->c:Z

    .line 338
    .line 339
    if-nez p0, :cond_241

    .line 340
    .line 341
    iget p0, v3, Lcom/kousei/framework/d4;->f:I

    .line 342
    .line 343
    packed-switch p0, :pswitch_data_248

    .line 344
    .line 345
    .line 346
    invoke-virtual {v3}, Lcom/kousei/framework/d4;->m()Z

    .line 347
    .line 348
    .line 349
    move-result p0

    .line 350
    goto/16 :goto_23a

    .line 351
    .line 352
    :pswitch_15f
    iget-object p0, v3, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 353
    .line 354
    iget-object v2, p0, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 355
    .line 356
    sget-object v5, Lcom/kousei/framework/o3;->c:Ljava/math/BigInteger;

    .line 357
    .line 358
    invoke-virtual {v5, v2}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 359
    .line 360
    .line 361
    move-result v5

    .line 362
    if-eqz v5, :cond_17e

    .line 363
    .line 364
    invoke-virtual {v3}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 365
    .line 366
    .line 367
    move-result-object p0

    .line 368
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->b()V

    .line 369
    .line 370
    .line 371
    iget-object p0, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 372
    .line 373
    check-cast p0, Lcom/kousei/framework/x3;

    .line 374
    .line 375
    invoke-virtual {p0}, Lcom/kousei/framework/x3;->m3()I

    .line 376
    .line 377
    .line 378
    move-result p0

    .line 379
    if-eqz p0, :cond_239

    .line 380
    .line 381
    goto/16 :goto_233

    .line 382
    .line 383
    :cond_17e
    sget-object v5, Lcom/kousei/framework/o3;->d:Ljava/math/BigInteger;

    .line 384
    .line 385
    invoke-virtual {v5, v2}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 386
    .line 387
    .line 388
    move-result v2

    .line 389
    if-eqz v2, :cond_235

    .line 390
    .line 391
    invoke-virtual {v3}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 392
    .line 393
    .line 394
    move-result-object v2

    .line 395
    invoke-virtual {v2}, Lcom/kousei/framework/d4;->b()V

    .line 396
    .line 397
    .line 398
    iget-object v5, v2, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 399
    .line 400
    move-object v6, p0

    .line 401
    check-cast v6, Lcom/kousei/framework/q3;

    .line 402
    .line 403
    iget-object p0, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 404
    .line 405
    invoke-virtual {v5, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 406
    .line 407
    .line 408
    move-result-object p0

    .line 409
    move-object v3, p0

    .line 410
    check-cast v3, Lcom/kousei/framework/x3;

    .line 411
    .line 412
    invoke-virtual {v3}, Lcom/kousei/framework/x3;->l3()Z

    .line 413
    .line 414
    .line 415
    move-result v7

    .line 416
    if-eqz v7, :cond_1a9

    .line 417
    .line 418
    invoke-virtual {v3}, Lcom/kousei/framework/x3;->m3()I

    .line 419
    .line 420
    .line 421
    move-result v8

    .line 422
    if-eqz v8, :cond_1a9

    .line 423
    .line 424
    goto/16 :goto_219

    .line 425
    .line 426
    :cond_1a9
    invoke-virtual {v6}, Lcom/kousei/framework/v3;->g()I

    .line 427
    .line 428
    .line 429
    move-result v8

    .line 430
    and-int/lit8 v9, v8, 0x1

    .line 431
    .line 432
    if-eqz v9, :cond_1cb

    .line 433
    .line 434
    invoke-virtual {v3}, Lcom/kousei/framework/x3;->k3()Lcom/kousei/framework/h0;

    .line 435
    .line 436
    .line 437
    move-result-object v3

    .line 438
    if-nez v7, :cond_1c9

    .line 439
    .line 440
    invoke-virtual {v3}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 441
    .line 442
    .line 443
    move-result-object v6

    .line 444
    invoke-virtual {v6, v3}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 445
    .line 446
    .line 447
    move-result-object v6

    .line 448
    invoke-virtual {v6, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 449
    .line 450
    .line 451
    move-result-object p0

    .line 452
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->E0()Z

    .line 453
    .line 454
    .line 455
    move-result p0

    .line 456
    if-eqz p0, :cond_219

    .line 457
    .line 458
    :cond_1c9
    move-object v1, v3

    .line 459
    goto :goto_219

    .line 460
    :cond_1cb
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->E0()Z

    .line 461
    .line 462
    .line 463
    move-result v3

    .line 464
    if-eqz v3, :cond_1d3

    .line 465
    .line 466
    move-object v1, p0

    .line 467
    goto :goto_219

    .line 468
    :cond_1d3
    sget-object v3, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 469
    .line 470
    invoke-virtual {v6, v3}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 471
    .line 472
    .line 473
    move-result-object v7

    .line 474
    new-instance v9, Ljava/util/Random;

    .line 475
    .line 476
    invoke-direct {v9}, Ljava/util/Random;-><init>()V

    .line 477
    .line 478
    .line 479
    :cond_1de
    new-instance v3, Ljava/math/BigInteger;

    .line 480
    .line 481
    invoke-direct {v3, v8, v9}, Ljava/math/BigInteger;-><init>(ILjava/util/Random;)V

    .line 482
    .line 483
    .line 484
    invoke-virtual {v6, v3}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 485
    .line 486
    .line 487
    move-result-object v3

    .line 488
    move-object v11, p0

    .line 489
    move v10, v4

    .line 490
    move-object v12, v7

    .line 491
    :goto_1ea
    if-ge v10, v8, :cond_203

    .line 492
    .line 493
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 494
    .line 495
    .line 496
    move-result-object v11

    .line 497
    invoke-virtual {v12}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 498
    .line 499
    .line 500
    move-result-object v12

    .line 501
    invoke-virtual {v11, v3}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 502
    .line 503
    .line 504
    move-result-object v13

    .line 505
    invoke-virtual {v12, v13}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 506
    .line 507
    .line 508
    move-result-object v12

    .line 509
    invoke-virtual {v11, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 510
    .line 511
    .line 512
    move-result-object v11

    .line 513
    add-int/lit8 v10, v10, 0x1

    .line 514
    .line 515
    goto :goto_1ea

    .line 516
    :cond_203
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->E0()Z

    .line 517
    .line 518
    .line 519
    move-result v3

    .line 520
    if-nez v3, :cond_20a

    .line 521
    .line 522
    goto :goto_219

    .line 523
    :cond_20a
    invoke-virtual {v12}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 524
    .line 525
    .line 526
    move-result-object v3

    .line 527
    invoke-virtual {v3, v12}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 528
    .line 529
    .line 530
    move-result-object v3

    .line 531
    invoke-virtual {v3}, Lcom/kousei/framework/h0;->E0()Z

    .line 532
    .line 533
    .line 534
    move-result v3

    .line 535
    if-nez v3, :cond_1de

    .line 536
    .line 537
    move-object v1, v12

    .line 538
    :cond_219
    :goto_219
    if-nez v1, :cond_21c

    .line 539
    .line 540
    goto :goto_239

    .line 541
    :cond_21c
    invoke-virtual {v2}, Lcom/kousei/framework/d4;->b()V

    .line 542
    .line 543
    .line 544
    invoke-virtual {v2}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 545
    .line 546
    .line 547
    move-result-object p0

    .line 548
    invoke-virtual {v5, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 549
    .line 550
    .line 551
    move-result-object v1

    .line 552
    invoke-virtual {v1, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 553
    .line 554
    .line 555
    move-result-object p0

    .line 556
    check-cast p0, Lcom/kousei/framework/x3;

    .line 557
    .line 558
    invoke-virtual {p0}, Lcom/kousei/framework/x3;->m3()I

    .line 559
    .line 560
    .line 561
    move-result p0

    .line 562
    if-nez p0, :cond_239

    .line 563
    .line 564
    :goto_233
    move v0, v4

    .line 565
    goto :goto_239

    .line 566
    :cond_235
    invoke-virtual {v3}, Lcom/kousei/framework/d4;->m()Z

    .line 567
    .line 568
    .line 569
    move-result v0

    .line 570
    :cond_239
    :goto_239
    move p0, v0

    .line 571
    :goto_23a
    if-nez p0, :cond_23f

    .line 572
    .line 573
    iput-boolean v4, p1, Lcom/kousei/framework/ua;->a:Z

    .line 574
    .line 575
    return-object p1

    .line 576
    :cond_23f
    iput-boolean v4, p1, Lcom/kousei/framework/ua;->c:Z

    .line 577
    .line 578
    :cond_241
    :goto_241
    return-object p1

    .line 579
    :pswitch_data_242
    .packed-switch 0x0
        :pswitch_a6
    .end packed-switch

    .line 580
    .line 581
    .line 582
    .line 583
    .line 584
    .line 585
    :pswitch_data_248
    .packed-switch 0x0
        :pswitch_15f
    .end packed-switch
.end method
