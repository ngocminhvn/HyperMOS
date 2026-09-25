.class public final Lcom/kousei/framework/b5;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final f:Lcom/kousei/framework/b5;


# instance fields
.field public final a:Ljava/util/Map;

.field public final b:Ljava/util/Map;

.field public final c:Ljava/util/Map;

.field public final d:Ljava/util/Set;

.field public final e:Z


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 1
    new-instance v0, Lcom/kousei/framework/b5;

    .line 2
    .line 3
    invoke-direct {v0}, Lcom/kousei/framework/b5;-><init>()V

    .line 4
    .line 5
    .line 6
    sput-object v0, Lcom/kousei/framework/b5;->f:Lcom/kousei/framework/b5;

    .line 7
    .line 8
    return-void
.end method

.method public constructor <init>()V
    .registers 3

    .line 416
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 417
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    iput-object v0, p0, Lcom/kousei/framework/b5;->a:Ljava/util/Map;

    .line 418
    iput-object v0, p0, Lcom/kousei/framework/b5;->b:Ljava/util/Map;

    .line 419
    iput-object v0, p0, Lcom/kousei/framework/b5;->c:Ljava/util/Map;

    .line 420
    sget-object v0, Ljava/util/Collections;->EMPTY_SET:Ljava/util/Set;

    iput-object v0, p0, Lcom/kousei/framework/b5;->d:Ljava/util/Set;

    const/4 v0, 0x1

    .line 421
    iput-boolean v0, p0, Lcom/kousei/framework/b5;->e:Z

    const-wide v0, -0xb83c0dbb5469L

    .line 422
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    return-void
.end method

.method public constructor <init>(Lorg/json/JSONObject;)V
    .registers 16

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    const-wide v0, -0xb8310dbb5469L

    .line 5
    .line 6
    .line 7
    .line 8
    .line 9
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 10
    .line 11
    .line 12
    move-result-object v0

    .line 13
    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 14
    .line 15
    .line 16
    move-result-object v0

    .line 17
    sget-object v1, Lcom/kousei/framework/c5;->c:Ljava/util/Set;

    .line 18
    .line 19
    if-nez v0, :cond_17

    .line 20
    .line 21
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 22
    .line 23
    goto :goto_3d

    .line 24
    :cond_17
    new-instance v1, Landroid/util/ArrayMap;

    .line 25
    .line 26
    invoke-direct {v1}, Landroid/util/ArrayMap;-><init>()V

    .line 27
    .line 28
    .line 29
    invoke-virtual {v0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    .line 30
    .line 31
    .line 32
    move-result-object v2

    .line 33
    :goto_20
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 34
    .line 35
    .line 36
    move-result v3

    .line 37
    if-eqz v3, :cond_39

    .line 38
    .line 39
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 40
    .line 41
    .line 42
    move-result-object v3

    .line 43
    check-cast v3, Ljava/lang/String;

    .line 44
    .line 45
    new-instance v4, Lcom/kousei/framework/z4;

    .line 46
    .line 47
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 48
    .line 49
    .line 50
    move-result-object v5

    .line 51
    invoke-direct {v4, v5}, Lcom/kousei/framework/z4;-><init>(Lorg/json/JSONObject;)V

    .line 52
    .line 53
    .line 54
    invoke-virtual {v1, v3, v4}, Landroid/util/ArrayMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 55
    .line 56
    .line 57
    goto :goto_20

    .line 58
    :cond_39
    invoke-static {v1}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 59
    .line 60
    .line 61
    move-result-object v0

    .line 62
    :goto_3d
    iput-object v0, p0, Lcom/kousei/framework/b5;->a:Ljava/util/Map;

    .line 63
    .line 64
    const-wide v0, -0xb8370dbb5469L

    .line 65
    .line 66
    .line 67
    .line 68
    .line 69
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 70
    .line 71
    .line 72
    move-result-object v0

    .line 73
    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 74
    .line 75
    .line 76
    move-result-object v0

    .line 77
    const/4 v1, 0x0

    .line 78
    if-nez v0, :cond_52

    .line 79
    .line 80
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 81
    .line 82
    goto :goto_88

    .line 83
    :cond_52
    new-instance v2, Landroid/util/ArrayMap;

    .line 84
    .line 85
    invoke-direct {v2}, Landroid/util/ArrayMap;-><init>()V

    .line 86
    .line 87
    .line 88
    invoke-virtual {v0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    .line 89
    .line 90
    .line 91
    move-result-object v3

    .line 92
    :goto_5b
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    .line 93
    .line 94
    .line 95
    move-result v4

    .line 96
    if-eqz v4, :cond_84

    .line 97
    .line 98
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 99
    .line 100
    .line 101
    move-result-object v4

    .line 102
    check-cast v4, Ljava/lang/String;

    .line 103
    .line 104
    invoke-virtual {v0, v4}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 105
    .line 106
    .line 107
    move-result-object v5

    .line 108
    if-nez v5, :cond_6f

    .line 109
    .line 110
    move-object v5, v1

    .line 111
    goto :goto_7c

    .line 112
    :cond_6f
    const-wide v6, -0xbd1f0dbb5469L

    .line 113
    .line 114
    .line 115
    .line 116
    .line 117
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 118
    .line 119
    .line 120
    move-result-object v6

    .line 121
    invoke-virtual {v5, v6}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    .line 122
    .line 123
    .line 124
    move-result-object v5

    .line 125
    :goto_7c
    invoke-static {v5}, Lcom/kousei/framework/c5;->h(Lorg/json/JSONArray;)Ljava/util/Set;

    .line 126
    .line 127
    .line 128
    move-result-object v5

    .line 129
    invoke-virtual {v2, v4, v5}, Landroid/util/ArrayMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 130
    .line 131
    .line 132
    goto :goto_5b

    .line 133
    :cond_84
    invoke-static {v2}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 134
    .line 135
    .line 136
    move-result-object v0

    .line 137
    :goto_88
    iput-object v0, p0, Lcom/kousei/framework/b5;->b:Ljava/util/Map;

    .line 138
    .line 139
    const-wide v2, -0xb8410dbb5469L

    .line 140
    .line 141
    .line 142
    .line 143
    .line 144
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 145
    .line 146
    .line 147
    move-result-object v0

    .line 148
    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 149
    .line 150
    .line 151
    move-result-object v0

    .line 152
    if-nez v0, :cond_9d

    .line 153
    .line 154
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 155
    .line 156
    goto/16 :goto_179

    .line 157
    .line 158
    :cond_9d
    new-instance v2, Landroid/util/ArrayMap;

    .line 159
    .line 160
    invoke-direct {v2}, Landroid/util/ArrayMap;-><init>()V

    .line 161
    .line 162
    .line 163
    invoke-virtual {v0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    .line 164
    .line 165
    .line 166
    move-result-object v3

    .line 167
    :goto_a6
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    .line 168
    .line 169
    .line 170
    move-result v4

    .line 171
    if-eqz v4, :cond_175

    .line 172
    .line 173
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 174
    .line 175
    .line 176
    move-result-object v4

    .line 177
    check-cast v4, Ljava/lang/String;

    .line 178
    .line 179
    new-instance v5, Landroid/util/ArrayMap;

    .line 180
    .line 181
    invoke-direct {v5}, Landroid/util/ArrayMap;-><init>()V

    .line 182
    .line 183
    .line 184
    invoke-virtual {v0, v4}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 185
    .line 186
    .line 187
    move-result-object v6

    .line 188
    if-nez v6, :cond_bf

    .line 189
    .line 190
    move-object v6, v1

    .line 191
    goto :goto_cc

    .line 192
    :cond_bf
    const-wide v7, -0xbd170dbb5469L

    .line 193
    .line 194
    .line 195
    .line 196
    .line 197
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 198
    .line 199
    .line 200
    move-result-object v7

    .line 201
    invoke-virtual {v6, v7}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    .line 202
    .line 203
    .line 204
    move-result-object v6

    .line 205
    :goto_cc
    if-eqz v6, :cond_16c

    .line 206
    .line 207
    const/4 v7, 0x0

    .line 208
    move v8, v7

    .line 209
    :goto_d0
    invoke-virtual {v6}, Lorg/json/JSONArray;->length()I

    .line 210
    .line 211
    .line 212
    move-result v9

    .line 213
    if-ge v8, v9, :cond_16c

    .line 214
    .line 215
    invoke-virtual {v6, v8}, Lorg/json/JSONArray;->optJSONObject(I)Lorg/json/JSONObject;

    .line 216
    .line 217
    .line 218
    move-result-object v9

    .line 219
    if-nez v9, :cond_de

    .line 220
    .line 221
    goto/16 :goto_168

    .line 222
    .line 223
    :cond_de
    const-wide v10, -0xbd220dbb5469L

    .line 224
    .line 225
    .line 226
    .line 227
    .line 228
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 229
    .line 230
    .line 231
    move-result-object v10

    .line 232
    invoke-virtual {v9, v10, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 233
    .line 234
    .line 235
    move-result-object v10

    .line 236
    const-wide v11, -0xbd390dbb5469L

    .line 237
    .line 238
    .line 239
    .line 240
    .line 241
    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 242
    .line 243
    .line 244
    move-result-object v11

    .line 245
    const-wide v12, -0xbd300dbb5469L

    .line 246
    .line 247
    .line 248
    .line 249
    .line 250
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 251
    .line 252
    .line 253
    move-result-object v12

    .line 254
    invoke-virtual {v9, v11, v12}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 255
    .line 256
    .line 257
    move-result-object v11

    .line 258
    if-eqz v10, :cond_168

    .line 259
    .line 260
    const-wide v12, -0xbd450dbb5469L

    .line 261
    .line 262
    .line 263
    .line 264
    .line 265
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 266
    .line 267
    .line 268
    move-result-object v12

    .line 269
    invoke-virtual {v12, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 270
    .line 271
    .line 272
    move-result v12

    .line 273
    if-nez v12, :cond_130

    .line 274
    .line 275
    const-wide v12, -0xbd5a0dbb5469L

    .line 276
    .line 277
    .line 278
    .line 279
    .line 280
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 281
    .line 282
    .line 283
    move-result-object v12

    .line 284
    invoke-virtual {v12, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 285
    .line 286
    .line 287
    move-result v12

    .line 288
    if-nez v12, :cond_130

    .line 289
    .line 290
    const-wide v12, -0xbd530dbb5469L

    .line 291
    .line 292
    .line 293
    .line 294
    .line 295
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 296
    .line 297
    .line 298
    move-result-object v12

    .line 299
    invoke-virtual {v12, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 300
    .line 301
    .line 302
    move-result v12

    .line 303
    if-eqz v12, :cond_168

    .line 304
    .line 305
    :cond_130
    const-wide v12, -0xbd490dbb5469L

    .line 306
    .line 307
    .line 308
    .line 309
    .line 310
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 311
    .line 312
    .line 313
    move-result-object v12

    .line 314
    invoke-virtual {v9, v12}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    .line 315
    .line 316
    .line 317
    move-result v12

    .line 318
    if-eqz v12, :cond_141

    .line 319
    .line 320
    move-object v9, v1

    .line 321
    goto :goto_14e

    .line 322
    :cond_141
    const-wide v12, -0xbd4f0dbb5469L

    .line 323
    .line 324
    .line 325
    .line 326
    .line 327
    invoke-static {v12, v13}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 328
    .line 329
    .line 330
    move-result-object v12

    .line 331
    invoke-virtual {v9, v12, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 332
    .line 333
    .line 334
    move-result-object v9

    .line 335
    :goto_14e
    new-instance v12, Ljava/lang/StringBuilder;

    .line 336
    .line 337
    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    .line 338
    .line 339
    .line 340
    invoke-virtual {v12, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 341
    .line 342
    .line 343
    invoke-virtual {v12, v7}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 344
    .line 345
    .line 346
    invoke-virtual {v12, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 347
    .line 348
    .line 349
    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 350
    .line 351
    .line 352
    move-result-object v12

    .line 353
    new-instance v13, Lcom/kousei/framework/a5;

    .line 354
    .line 355
    invoke-direct {v13, v11, v10, v9}, Lcom/kousei/framework/a5;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 356
    .line 357
    .line 358
    invoke-virtual {v5, v12, v13}, Landroid/util/ArrayMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 359
    .line 360
    .line 361
    :cond_168
    :goto_168
    add-int/lit8 v8, v8, 0x1

    .line 362
    .line 363
    goto/16 :goto_d0

    .line 364
    .line 365
    :cond_16c
    invoke-static {v5}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 366
    .line 367
    .line 368
    move-result-object v5

    .line 369
    invoke-virtual {v2, v4, v5}, Landroid/util/ArrayMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 370
    .line 371
    .line 372
    goto/16 :goto_a6

    .line 373
    .line 374
    :cond_175
    invoke-static {v2}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 375
    .line 376
    .line 377
    move-result-object v0

    .line 378
    :goto_179
    iput-object v0, p0, Lcom/kousei/framework/b5;->c:Ljava/util/Map;

    .line 379
    .line 380
    const-wide v0, -0xb8530dbb5469L

    .line 381
    .line 382
    .line 383
    .line 384
    .line 385
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 386
    .line 387
    .line 388
    move-result-object v0

    .line 389
    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    .line 390
    .line 391
    .line 392
    move-result-object v0

    .line 393
    invoke-static {v0}, Lcom/kousei/framework/c5;->h(Lorg/json/JSONArray;)Ljava/util/Set;

    .line 394
    .line 395
    .line 396
    move-result-object v0

    .line 397
    iput-object v0, p0, Lcom/kousei/framework/b5;->d:Ljava/util/Set;

    .line 398
    .line 399
    const-wide v0, -0xb87d0dbb5469L

    .line 400
    .line 401
    .line 402
    .line 403
    .line 404
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 405
    .line 406
    .line 407
    move-result-object v0

    .line 408
    const/4 v1, 0x1

    .line 409
    invoke-virtual {p1, v0, v1}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    .line 410
    .line 411
    .line 412
    move-result p1

    .line 413
    iput-boolean p1, p0, Lcom/kousei/framework/b5;->e:Z

    .line 414
    .line 415
    return-void
.end method
