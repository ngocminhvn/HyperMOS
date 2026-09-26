.class public final Lcom/kousei/framework/r0;
.super Lcom/kousei/framework/h0;


# static fields
.field public static final U:Lcom/kousei/framework/u;

.field public static final V:Lcom/kousei/framework/u;

.field public static final W:Lcom/kousei/framework/u;

.field public static final X:Lcom/kousei/framework/u;

.field public static final Y:Lcom/kousei/framework/u;

.field public static final Z:Lcom/kousei/framework/u;

.field public static final a0:Lcom/kousei/framework/u;

.field public static final b0:Lcom/kousei/framework/u;

.field public static final c0:Ljava/util/Hashtable;

.field public static final d0:Ljava/util/Hashtable;

.field public static final e0:Lcom/kousei/framework/r0;


# instance fields
.field public final S:Ljava/util/Hashtable;

.field public final T:Ljava/util/Hashtable;


# direct methods
.method static constructor <clinit>()V
    .registers 42

    .line 1
    const-string v0, "2.5.4.6"

    .line 2
    .line 3
    invoke-static {v0}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    sput-object v0, Lcom/kousei/framework/r0;->U:Lcom/kousei/framework/u;

    .line 8
    .line 9
    const-string v1, "2.5.4.10"

    .line 10
    .line 11
    invoke-static {v1}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 12
    .line 13
    .line 14
    move-result-object v1

    .line 15
    const-string v2, "2.5.4.11"

    .line 16
    .line 17
    invoke-static {v2}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 18
    .line 19
    .line 20
    move-result-object v2

    .line 21
    const-string v3, "2.5.4.12"

    .line 22
    .line 23
    invoke-static {v3}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 24
    .line 25
    .line 26
    move-result-object v3

    .line 27
    const-string v4, "2.5.4.3"

    .line 28
    .line 29
    invoke-static {v4}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 30
    .line 31
    .line 32
    move-result-object v4

    .line 33
    new-instance v5, Lcom/kousei/framework/u;

    .line 34
    .line 35
    const-string v6, "2.5.4.5"

    .line 36
    .line 37
    invoke-direct {v5, v6}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 38
    .line 39
    .line 40
    invoke-virtual {v5}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 41
    .line 42
    .line 43
    new-instance v5, Lcom/kousei/framework/u;

    .line 44
    .line 45
    const-string v7, "2.5.4.9"

    .line 46
    .line 47
    invoke-direct {v5, v7}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 48
    .line 49
    .line 50
    invoke-virtual {v5}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 51
    .line 52
    .line 53
    move-result-object v5

    .line 54
    invoke-static {v6}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 55
    .line 56
    .line 57
    move-result-object v6

    .line 58
    sput-object v6, Lcom/kousei/framework/r0;->V:Lcom/kousei/framework/u;

    .line 59
    .line 60
    const-string v7, "2.5.4.7"

    .line 61
    .line 62
    invoke-static {v7}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 63
    .line 64
    .line 65
    move-result-object v7

    .line 66
    const-string v8, "2.5.4.8"

    .line 67
    .line 68
    invoke-static {v8}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 69
    .line 70
    .line 71
    move-result-object v8

    .line 72
    const-string v9, "2.5.4.4"

    .line 73
    .line 74
    invoke-static {v9}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 75
    .line 76
    .line 77
    move-result-object v9

    .line 78
    const-string v10, "2.5.4.42"

    .line 79
    .line 80
    invoke-static {v10}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 81
    .line 82
    .line 83
    move-result-object v10

    .line 84
    const-string v11, "2.5.4.43"

    .line 85
    .line 86
    invoke-static {v11}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 87
    .line 88
    .line 89
    move-result-object v11

    .line 90
    const-string v12, "2.5.4.44"

    .line 91
    .line 92
    invoke-static {v12}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 93
    .line 94
    .line 95
    move-result-object v12

    .line 96
    const-string v13, "2.5.4.45"

    .line 97
    .line 98
    invoke-static {v13}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 99
    .line 100
    .line 101
    move-result-object v13

    .line 102
    const-string v14, "2.5.4.13"

    .line 103
    .line 104
    invoke-static {v14}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 105
    .line 106
    .line 107
    move-result-object v14

    .line 108
    const-string v15, "2.5.4.15"

    .line 109
    .line 110
    invoke-static {v15}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 111
    .line 112
    .line 113
    move-result-object v15

    .line 114
    const-string v16, "2.5.4.17"

    .line 115
    .line 116
    move-object/from16 v17, v15

    .line 117
    .line 118
    invoke-static/range {v16 .. v16}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 119
    .line 120
    .line 121
    move-result-object v15

    .line 122
    const-string v16, "2.5.4.46"

    .line 123
    .line 124
    move-object/from16 v18, v15

    .line 125
    .line 126
    invoke-static/range {v16 .. v16}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 127
    .line 128
    .line 129
    move-result-object v15

    .line 130
    sput-object v15, Lcom/kousei/framework/r0;->W:Lcom/kousei/framework/u;

    .line 131
    .line 132
    const-string v16, "2.5.4.65"

    .line 133
    .line 134
    move-object/from16 v19, v15

    .line 135
    .line 136
    invoke-static/range {v16 .. v16}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 137
    .line 138
    .line 139
    move-result-object v15

    .line 140
    const-string v16, "2.5.4.72"

    .line 141
    .line 142
    move-object/from16 v20, v15

    .line 143
    .line 144
    invoke-static/range {v16 .. v16}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 145
    .line 146
    .line 147
    move-result-object v15

    .line 148
    move-object/from16 v16, v13

    .line 149
    .line 150
    sget-object v13, Lcom/kousei/framework/ya;->i:Lcom/kousei/framework/u;

    .line 151
    .line 152
    move-object/from16 v21, v15

    .line 153
    .line 154
    const-string v15, "1"

    .line 155
    .line 156
    invoke-virtual {v13, v15}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 157
    .line 158
    .line 159
    move-result-object v15

    .line 160
    invoke-virtual {v15}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 161
    .line 162
    .line 163
    move-result-object v15

    .line 164
    sput-object v15, Lcom/kousei/framework/r0;->X:Lcom/kousei/framework/u;

    .line 165
    .line 166
    move-object/from16 v22, v15

    .line 167
    .line 168
    const-string v15, "2"

    .line 169
    .line 170
    invoke-virtual {v13, v15}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 171
    .line 172
    .line 173
    move-result-object v15

    .line 174
    invoke-virtual {v15}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 175
    .line 176
    .line 177
    move-result-object v15

    .line 178
    move-object/from16 v23, v15

    .line 179
    .line 180
    const-string v15, "3"

    .line 181
    .line 182
    invoke-virtual {v13, v15}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 183
    .line 184
    .line 185
    move-result-object v15

    .line 186
    invoke-virtual {v15}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 187
    .line 188
    .line 189
    move-result-object v15

    .line 190
    move-object/from16 v24, v15

    .line 191
    .line 192
    const-string v15, "4"

    .line 193
    .line 194
    invoke-virtual {v13, v15}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 195
    .line 196
    .line 197
    move-result-object v15

    .line 198
    invoke-virtual {v15}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 199
    .line 200
    .line 201
    move-result-object v15

    .line 202
    move-object/from16 v25, v15

    .line 203
    .line 204
    const-string v15, "5"

    .line 205
    .line 206
    invoke-virtual {v13, v15}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 207
    .line 208
    .line 209
    move-result-object v13

    .line 210
    invoke-virtual {v13}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 211
    .line 212
    .line 213
    move-result-object v13

    .line 214
    const-string v15, "1.3.36.8.3.14"

    .line 215
    .line 216
    invoke-static {v15}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 217
    .line 218
    .line 219
    move-result-object v15

    .line 220
    const-string v26, "2.5.4.16"

    .line 221
    .line 222
    move-object/from16 v27, v13

    .line 223
    .line 224
    invoke-static/range {v26 .. v26}, Lcom/kousei/framework/p0;->c(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 225
    .line 226
    .line 227
    move-result-object v13

    .line 228
    move-object/from16 v26, v15

    .line 229
    .line 230
    new-instance v15, Lcom/kousei/framework/u;

    .line 231
    .line 232
    move-object/from16 v28, v13

    .line 233
    .line 234
    const-string v13, "2.5.4.54"

    .line 235
    .line 236
    invoke-direct {v15, v13}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 237
    .line 238
    .line 239
    invoke-virtual {v15}, Lcom/kousei/framework/u;->w()Lcom/kousei/framework/u;

    .line 240
    .line 241
    .line 242
    sget-object v13, Lcom/kousei/framework/ya;->a:Lcom/kousei/framework/u;

    .line 243
    .line 244
    sput-object v13, Lcom/kousei/framework/r0;->Y:Lcom/kousei/framework/u;

    .line 245
    .line 246
    sget-object v15, Lcom/kousei/framework/ya;->b:Lcom/kousei/framework/u;

    .line 247
    .line 248
    move-object/from16 v29, v15

    .line 249
    .line 250
    sget-object v15, Lcom/kousei/framework/ya;->c:Lcom/kousei/framework/u;

    .line 251
    .line 252
    move-object/from16 v30, v15

    .line 253
    .line 254
    sget-object v15, Lcom/kousei/framework/e7;->u:Lcom/kousei/framework/u;

    .line 255
    .line 256
    sput-object v15, Lcom/kousei/framework/r0;->Z:Lcom/kousei/framework/u;

    .line 257
    .line 258
    move-object/from16 v31, v13

    .line 259
    .line 260
    sget-object v13, Lcom/kousei/framework/e7;->v:Lcom/kousei/framework/u;

    .line 261
    .line 262
    move-object/from16 v32, v13

    .line 263
    .line 264
    sget-object v13, Lcom/kousei/framework/e7;->w:Lcom/kousei/framework/u;

    .line 265
    .line 266
    move-object/from16 v33, v13

    .line 267
    .line 268
    new-instance v13, Lcom/kousei/framework/u;

    .line 269
    .line 270
    move-object/from16 v34, v14

    .line 271
    .line 272
    const-string v14, "0.9.2342.19200300.100.1.25"

    .line 273
    .line 274
    invoke-direct {v13, v14}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 275
    .line 276
    .line 277
    sput-object v13, Lcom/kousei/framework/r0;->a0:Lcom/kousei/framework/u;

    .line 278
    .line 279
    new-instance v14, Lcom/kousei/framework/u;

    .line 280
    .line 281
    move-object/from16 v35, v12

    .line 282
    .line 283
    const-string v12, "0.9.2342.19200300.100.1.1"

    .line 284
    .line 285
    invoke-direct {v14, v12}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 286
    .line 287
    .line 288
    new-instance v12, Lcom/kousei/framework/u;

    .line 289
    .line 290
    move-object/from16 v36, v11

    .line 291
    .line 292
    const-string v11, "1.3.6.1.4.1.311.60.2.1.3"

    .line 293
    .line 294
    invoke-direct {v12, v11}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 295
    .line 296
    .line 297
    sput-object v12, Lcom/kousei/framework/r0;->b0:Lcom/kousei/framework/u;

    .line 298
    .line 299
    new-instance v11, Lcom/kousei/framework/u;

    .line 300
    .line 301
    move-object/from16 v37, v12

    .line 302
    .line 303
    const-string v12, "1.3.6.1.4.1.311.60.2.1.2"

    .line 304
    .line 305
    invoke-direct {v11, v12}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 306
    .line 307
    .line 308
    new-instance v12, Lcom/kousei/framework/u;

    .line 309
    .line 310
    move-object/from16 v38, v11

    .line 311
    .line 312
    const-string v11, "1.3.6.1.4.1.311.60.2.1.1"

    .line 313
    .line 314
    invoke-direct {v12, v11}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 315
    .line 316
    .line 317
    new-instance v11, Ljava/util/Hashtable;

    .line 318
    .line 319
    invoke-direct {v11}, Ljava/util/Hashtable;-><init>()V

    .line 320
    .line 321
    .line 322
    sput-object v11, Lcom/kousei/framework/r0;->c0:Ljava/util/Hashtable;

    .line 323
    .line 324
    move-object/from16 v39, v12

    .line 325
    .line 326
    new-instance v12, Ljava/util/Hashtable;

    .line 327
    .line 328
    invoke-direct {v12}, Ljava/util/Hashtable;-><init>()V

    .line 329
    .line 330
    .line 331
    sput-object v12, Lcom/kousei/framework/r0;->d0:Ljava/util/Hashtable;

    .line 332
    .line 333
    move-object/from16 v40, v12

    .line 334
    .line 335
    const-string v12, "C"

    .line 336
    .line 337
    invoke-virtual {v11, v0, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 338
    .line 339
    .line 340
    const-string v12, "O"

    .line 341
    .line 342
    invoke-virtual {v11, v1, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 343
    .line 344
    .line 345
    const-string v12, "T"

    .line 346
    .line 347
    invoke-virtual {v11, v3, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 348
    .line 349
    .line 350
    const-string v12, "OU"

    .line 351
    .line 352
    invoke-virtual {v11, v2, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 353
    .line 354
    .line 355
    const-string v12, "CN"

    .line 356
    .line 357
    invoke-virtual {v11, v4, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 358
    .line 359
    .line 360
    const-string v12, "L"

    .line 361
    .line 362
    invoke-virtual {v11, v7, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 363
    .line 364
    .line 365
    const-string v12, "ST"

    .line 366
    .line 367
    invoke-virtual {v11, v8, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 368
    .line 369
    .line 370
    const-string v12, "SERIALNUMBER"

    .line 371
    .line 372
    invoke-virtual {v11, v6, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 373
    .line 374
    .line 375
    const-string v12, "E"

    .line 376
    .line 377
    invoke-virtual {v11, v15, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 378
    .line 379
    .line 380
    const-string v12, "DC"

    .line 381
    .line 382
    invoke-virtual {v11, v13, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 383
    .line 384
    .line 385
    const-string v12, "UID"

    .line 386
    .line 387
    invoke-virtual {v11, v14, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 388
    .line 389
    .line 390
    const-string v12, "STREET"

    .line 391
    .line 392
    invoke-virtual {v11, v5, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 393
    .line 394
    .line 395
    const-string v12, "SURNAME"

    .line 396
    .line 397
    invoke-virtual {v11, v9, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 398
    .line 399
    .line 400
    const-string v12, "GIVENNAME"

    .line 401
    .line 402
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 403
    .line 404
    .line 405
    const-string v12, "INITIALS"

    .line 406
    .line 407
    move-object/from16 v41, v10

    .line 408
    .line 409
    move-object/from16 v10, v36

    .line 410
    .line 411
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 412
    .line 413
    .line 414
    const-string v12, "GENERATION"

    .line 415
    .line 416
    move-object/from16 v10, v35

    .line 417
    .line 418
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 419
    .line 420
    .line 421
    const-string v12, "DESCRIPTION"

    .line 422
    .line 423
    move-object/from16 v10, v34

    .line 424
    .line 425
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 426
    .line 427
    .line 428
    const-string v12, "ROLE"

    .line 429
    .line 430
    move-object/from16 v10, v21

    .line 431
    .line 432
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 433
    .line 434
    .line 435
    const-string v12, "unstructuredAddress"

    .line 436
    .line 437
    move-object/from16 v10, v33

    .line 438
    .line 439
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 440
    .line 441
    .line 442
    const-string v12, "unstructuredName"

    .line 443
    .line 444
    move-object/from16 v10, v32

    .line 445
    .line 446
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 447
    .line 448
    .line 449
    const-string v12, "UniqueIdentifier"

    .line 450
    .line 451
    move-object/from16 v10, v16

    .line 452
    .line 453
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 454
    .line 455
    .line 456
    const-string v12, "DN"

    .line 457
    .line 458
    move-object/from16 v10, v19

    .line 459
    .line 460
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 461
    .line 462
    .line 463
    const-string v12, "Pseudonym"

    .line 464
    .line 465
    move-object/from16 v10, v20

    .line 466
    .line 467
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 468
    .line 469
    .line 470
    const-string v12, "PostalAddress"

    .line 471
    .line 472
    move-object/from16 v10, v28

    .line 473
    .line 474
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 475
    .line 476
    .line 477
    const-string v12, "NameAtBirth"

    .line 478
    .line 479
    move-object/from16 v10, v26

    .line 480
    .line 481
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 482
    .line 483
    .line 484
    const-string v12, "CountryOfCitizenship"

    .line 485
    .line 486
    move-object/from16 v10, v25

    .line 487
    .line 488
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 489
    .line 490
    .line 491
    const-string v12, "CountryOfResidence"

    .line 492
    .line 493
    move-object/from16 v10, v27

    .line 494
    .line 495
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 496
    .line 497
    .line 498
    const-string v12, "Gender"

    .line 499
    .line 500
    move-object/from16 v10, v24

    .line 501
    .line 502
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 503
    .line 504
    .line 505
    const-string v12, "PlaceOfBirth"

    .line 506
    .line 507
    move-object/from16 v10, v23

    .line 508
    .line 509
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 510
    .line 511
    .line 512
    const-string v12, "DateOfBirth"

    .line 513
    .line 514
    move-object/from16 v10, v22

    .line 515
    .line 516
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 517
    .line 518
    .line 519
    const-string v12, "PostalCode"

    .line 520
    .line 521
    move-object/from16 v10, v18

    .line 522
    .line 523
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 524
    .line 525
    .line 526
    const-string v12, "BusinessCategory"

    .line 527
    .line 528
    move-object/from16 v10, v17

    .line 529
    .line 530
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 531
    .line 532
    .line 533
    const-string v12, "TelephoneNumber"

    .line 534
    .line 535
    move-object/from16 v10, v31

    .line 536
    .line 537
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 538
    .line 539
    .line 540
    const-string v12, "Name"

    .line 541
    .line 542
    move-object/from16 v10, v29

    .line 543
    .line 544
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 545
    .line 546
    .line 547
    const-string v12, "organizationIdentifier"

    .line 548
    .line 549
    move-object/from16 v10, v30

    .line 550
    .line 551
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 552
    .line 553
    .line 554
    const-string v12, "jurisdictionCountry"

    .line 555
    .line 556
    move-object/from16 v10, v37

    .line 557
    .line 558
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 559
    .line 560
    .line 561
    const-string v12, "jurisdictionState"

    .line 562
    .line 563
    move-object/from16 v10, v38

    .line 564
    .line 565
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 566
    .line 567
    .line 568
    const-string v12, "jurisdictionLocality"

    .line 569
    .line 570
    move-object/from16 v10, v39

    .line 571
    .line 572
    invoke-virtual {v11, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 573
    .line 574
    .line 575
    const-string v11, "c"

    .line 576
    .line 577
    move-object/from16 v12, v40

    .line 578
    .line 579
    invoke-virtual {v12, v11, v0}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 580
    .line 581
    .line 582
    const-string v0, "o"

    .line 583
    .line 584
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 585
    .line 586
    .line 587
    const-string v0, "t"

    .line 588
    .line 589
    invoke-virtual {v12, v0, v3}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 590
    .line 591
    .line 592
    const-string v0, "ou"

    .line 593
    .line 594
    invoke-virtual {v12, v0, v2}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 595
    .line 596
    .line 597
    const-string v0, "cn"

    .line 598
    .line 599
    invoke-virtual {v12, v0, v4}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 600
    .line 601
    .line 602
    const-string v0, "l"

    .line 603
    .line 604
    invoke-virtual {v12, v0, v7}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 605
    .line 606
    .line 607
    const-string v0, "st"

    .line 608
    .line 609
    invoke-virtual {v12, v0, v8}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 610
    .line 611
    .line 612
    const-string v0, "sn"

    .line 613
    .line 614
    invoke-virtual {v12, v0, v9}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 615
    .line 616
    .line 617
    const-string v0, "serialnumber"

    .line 618
    .line 619
    invoke-virtual {v12, v0, v6}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 620
    .line 621
    .line 622
    const-string v0, "street"

    .line 623
    .line 624
    invoke-virtual {v12, v0, v5}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 625
    .line 626
    .line 627
    const-string v0, "emailaddress"

    .line 628
    .line 629
    invoke-virtual {v12, v0, v15}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 630
    .line 631
    .line 632
    const-string v0, "dc"

    .line 633
    .line 634
    invoke-virtual {v12, v0, v13}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 635
    .line 636
    .line 637
    const-string v0, "e"

    .line 638
    .line 639
    invoke-virtual {v12, v0, v15}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 640
    .line 641
    .line 642
    const-string v0, "uid"

    .line 643
    .line 644
    invoke-virtual {v12, v0, v14}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 645
    .line 646
    .line 647
    const-string v0, "surname"

    .line 648
    .line 649
    invoke-virtual {v12, v0, v9}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 650
    .line 651
    .line 652
    const-string v0, "givenname"

    .line 653
    .line 654
    move-object/from16 v1, v41

    .line 655
    .line 656
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 657
    .line 658
    .line 659
    const-string v0, "initials"

    .line 660
    .line 661
    move-object/from16 v1, v36

    .line 662
    .line 663
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 664
    .line 665
    .line 666
    const-string v0, "generation"

    .line 667
    .line 668
    move-object/from16 v1, v35

    .line 669
    .line 670
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 671
    .line 672
    .line 673
    const-string v0, "description"

    .line 674
    .line 675
    move-object/from16 v1, v34

    .line 676
    .line 677
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 678
    .line 679
    .line 680
    const-string v0, "role"

    .line 681
    .line 682
    move-object/from16 v1, v21

    .line 683
    .line 684
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 685
    .line 686
    .line 687
    const-string v0, "unstructuredaddress"

    .line 688
    .line 689
    move-object/from16 v1, v33

    .line 690
    .line 691
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 692
    .line 693
    .line 694
    const-string v0, "unstructuredname"

    .line 695
    .line 696
    move-object/from16 v1, v32

    .line 697
    .line 698
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 699
    .line 700
    .line 701
    const-string v0, "uniqueidentifier"

    .line 702
    .line 703
    move-object/from16 v1, v16

    .line 704
    .line 705
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 706
    .line 707
    .line 708
    const-string v0, "dn"

    .line 709
    .line 710
    move-object/from16 v1, v19

    .line 711
    .line 712
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 713
    .line 714
    .line 715
    const-string v0, "pseudonym"

    .line 716
    .line 717
    move-object/from16 v1, v20

    .line 718
    .line 719
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 720
    .line 721
    .line 722
    const-string v0, "postaladdress"

    .line 723
    .line 724
    move-object/from16 v1, v28

    .line 725
    .line 726
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 727
    .line 728
    .line 729
    const-string v0, "nameatbirth"

    .line 730
    .line 731
    move-object/from16 v1, v26

    .line 732
    .line 733
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 734
    .line 735
    .line 736
    const-string v0, "countryofcitizenship"

    .line 737
    .line 738
    move-object/from16 v1, v25

    .line 739
    .line 740
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 741
    .line 742
    .line 743
    const-string v0, "countryofresidence"

    .line 744
    .line 745
    move-object/from16 v1, v27

    .line 746
    .line 747
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 748
    .line 749
    .line 750
    const-string v0, "gender"

    .line 751
    .line 752
    move-object/from16 v1, v24

    .line 753
    .line 754
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 755
    .line 756
    .line 757
    const-string v0, "placeofbirth"

    .line 758
    .line 759
    move-object/from16 v1, v23

    .line 760
    .line 761
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 762
    .line 763
    .line 764
    const-string v0, "dateofbirth"

    .line 765
    .line 766
    move-object/from16 v1, v22

    .line 767
    .line 768
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 769
    .line 770
    .line 771
    const-string v0, "postalcode"

    .line 772
    .line 773
    move-object/from16 v1, v18

    .line 774
    .line 775
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 776
    .line 777
    .line 778
    const-string v0, "businesscategory"

    .line 779
    .line 780
    move-object/from16 v1, v17

    .line 781
    .line 782
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 783
    .line 784
    .line 785
    const-string v0, "telephonenumber"

    .line 786
    .line 787
    move-object/from16 v1, v31

    .line 788
    .line 789
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 790
    .line 791
    .line 792
    const-string v0, "name"

    .line 793
    .line 794
    move-object/from16 v1, v29

    .line 795
    .line 796
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 797
    .line 798
    .line 799
    const-string v0, "organizationidentifier"

    .line 800
    .line 801
    move-object/from16 v1, v30

    .line 802
    .line 803
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 804
    .line 805
    .line 806
    const-string v0, "jurisdictioncountry"

    .line 807
    .line 808
    move-object/from16 v1, v37

    .line 809
    .line 810
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 811
    .line 812
    .line 813
    const-string v0, "jurisdictionstate"

    .line 814
    .line 815
    move-object/from16 v1, v38

    .line 816
    .line 817
    invoke-virtual {v12, v0, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 818
    .line 819
    .line 820
    const-string v0, "jurisdictionlocality"

    .line 821
    .line 822
    invoke-virtual {v12, v0, v10}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 823
    .line 824
    .line 825
    new-instance v0, Lcom/kousei/framework/r0;

    .line 826
    .line 827
    invoke-direct {v0}, Lcom/kousei/framework/r0;-><init>()V

    .line 828
    .line 829
    .line 830
    sput-object v0, Lcom/kousei/framework/r0;->e0:Lcom/kousei/framework/r0;

    .line 831
    .line 832
    return-void
.end method

.method public constructor <init>()V
    .registers 6

    .line 1
    const/4 v0, 0x0

    .line 2
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 3
    .line 4
    .line 5
    new-instance v0, Ljava/util/Hashtable;

    .line 6
    .line 7
    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    .line 8
    .line 9
    .line 10
    sget-object v1, Lcom/kousei/framework/r0;->c0:Ljava/util/Hashtable;

    .line 11
    .line 12
    invoke-virtual {v1}, Ljava/util/Hashtable;->keys()Ljava/util/Enumeration;

    .line 13
    .line 14
    .line 15
    move-result-object v2

    .line 16
    :goto_f
    invoke-interface {v2}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 17
    .line 18
    .line 19
    move-result v3

    .line 20
    if-eqz v3, :cond_21

    .line 21
    .line 22
    invoke-interface {v2}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 23
    .line 24
    .line 25
    move-result-object v3

    .line 26
    invoke-virtual {v1, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 27
    .line 28
    .line 29
    move-result-object v4

    .line 30
    invoke-virtual {v0, v3, v4}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 31
    .line 32
    .line 33
    goto :goto_f

    .line 34
    :cond_21
    iput-object v0, p0, Lcom/kousei/framework/r0;->T:Ljava/util/Hashtable;

    .line 35
    .line 36
    new-instance v0, Ljava/util/Hashtable;

    .line 37
    .line 38
    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    .line 39
    .line 40
    .line 41
    sget-object v1, Lcom/kousei/framework/r0;->d0:Ljava/util/Hashtable;

    .line 42
    .line 43
    invoke-virtual {v1}, Ljava/util/Hashtable;->keys()Ljava/util/Enumeration;

    .line 44
    .line 45
    .line 46
    move-result-object v2

    .line 47
    :goto_2e
    invoke-interface {v2}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 48
    .line 49
    .line 50
    move-result v3

    .line 51
    if-eqz v3, :cond_40

    .line 52
    .line 53
    invoke-interface {v2}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 54
    .line 55
    .line 56
    move-result-object v3

    .line 57
    invoke-virtual {v1, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 58
    .line 59
    .line 60
    move-result-object v4

    .line 61
    invoke-virtual {v0, v3, v4}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 62
    .line 63
    .line 64
    goto :goto_2e

    .line 65
    :cond_40
    iput-object v0, p0, Lcom/kousei/framework/r0;->S:Ljava/util/Hashtable;

    .line 66
    .line 67
    return-void
.end method


# virtual methods
.method public final k3(Ljava/lang/String;)Lcom/kousei/framework/u;
    .registers 8

    .line 1
    const/4 v4, 0x0

    .line 2
    const/4 v5, 0x4

    .line 3
    const/4 v1, 0x1

    .line 4
    const/4 v2, 0x0

    .line 5
    const-string v3, "OID."

    .line 6
    .line 7
    move-object v0, p1

    .line 8
    invoke-virtual/range {v0 .. v5}, Ljava/lang/String;->regionMatches(ZILjava/lang/String;II)Z

    .line 9
    .line 10
    .line 11
    move-result p1

    .line 12
    if-eqz p1, :cond_18

    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/u;

    .line 15
    .line 16
    const/4 p1, 0x4

    .line 17
    invoke-virtual {v0, p1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object p1

    .line 21
    invoke-direct {p0, p1}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 22
    .line 23
    .line 24
    return-object p0

    .line 25
    :cond_18
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    .line 26
    .line 27
    .line 28
    move-result p1

    .line 29
    const/16 v1, 0x4001

    .line 30
    .line 31
    const/4 v2, 0x0

    .line 32
    if-gt p1, v1, :cond_36

    .line 33
    .line 34
    invoke-static {v0}, Lcom/kousei/framework/u;->x(Ljava/lang/String;)Z

    .line 35
    .line 36
    .line 37
    move-result p1

    .line 38
    if-eqz p1, :cond_36

    .line 39
    .line 40
    invoke-static {v0}, Lcom/kousei/framework/u;->z(Ljava/lang/String;)[B

    .line 41
    .line 42
    .line 43
    move-result-object p1

    .line 44
    array-length v1, p1

    .line 45
    const/16 v3, 0x1000

    .line 46
    .line 47
    if-gt v1, v3, :cond_36

    .line 48
    .line 49
    new-instance v1, Lcom/kousei/framework/u;

    .line 50
    .line 51
    invoke-direct {v1, p1, v0}, Lcom/kousei/framework/u;-><init>([BLjava/lang/String;)V

    .line 52
    .line 53
    .line 54
    goto :goto_37

    .line 55
    :cond_36
    move-object v1, v2

    .line 56
    :goto_37
    if-eqz v1, :cond_3a

    .line 57
    .line 58
    return-object v1

    .line 59
    :cond_3a
    invoke-static {v0}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 60
    .line 61
    .line 62
    move-result-object p1

    .line 63
    iget-object p0, p0, Lcom/kousei/framework/r0;->S:Ljava/util/Hashtable;

    .line 64
    .line 65
    invoke-virtual {p0, p1}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 66
    .line 67
    .line 68
    move-result-object p0

    .line 69
    check-cast p0, Lcom/kousei/framework/u;

    .line 70
    .line 71
    if-eqz p0, :cond_49

    .line 72
    .line 73
    return-object p0

    .line 74
    :cond_49
    const-string p0, "Unknown object id - "

    .line 75
    .line 76
    const-string p1, " - passed to distinguished name"

    .line 77
    .line 78
    invoke-static {p0, v0, p1}, Lcom/kousei/framework/e;->g(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)V

    .line 79
    .line 80
    .line 81
    return-object v2
.end method
