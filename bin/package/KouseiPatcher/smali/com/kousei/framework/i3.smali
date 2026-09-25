.class public final Lcom/kousei/framework/i3;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/HashMap;

.field public static final b:Ljava/util/HashMap;


# direct methods
.method static constructor <clinit>()V
    .registers 5

    .line 1
    new-instance v0, Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 4
    .line 5
    .line 6
    sput-object v0, Lcom/kousei/framework/i3;->a:Ljava/util/HashMap;

    .line 7
    .line 8
    new-instance v0, Ljava/util/HashMap;

    .line 9
    .line 10
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 11
    .line 12
    .line 13
    sput-object v0, Lcom/kousei/framework/i3;->b:Ljava/util/HashMap;

    .line 14
    .line 15
    sget-object v1, Lcom/kousei/framework/e7;->i:Lcom/kousei/framework/u;

    .line 16
    .line 17
    const-string v2, "RSASSA-PSS"

    .line 18
    .line 19
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 20
    .line 21
    .line 22
    sget-object v1, Lcom/kousei/framework/h4;->a:Lcom/kousei/framework/u;

    .line 23
    .line 24
    const-string v2, "ED25519"

    .line 25
    .line 26
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 27
    .line 28
    .line 29
    sget-object v1, Lcom/kousei/framework/h4;->b:Lcom/kousei/framework/u;

    .line 30
    .line 31
    const-string v2, "ED448"

    .line 32
    .line 33
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 34
    .line 35
    .line 36
    new-instance v1, Lcom/kousei/framework/u;

    .line 37
    .line 38
    const-string v2, "1.2.840.113549.1.1.5"

    .line 39
    .line 40
    invoke-direct {v1, v2}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 41
    .line 42
    .line 43
    const-string v2, "SHA1WITHRSA"

    .line 44
    .line 45
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 46
    .line 47
    .line 48
    sget-object v1, Lcom/kousei/framework/e7;->m:Lcom/kousei/framework/u;

    .line 49
    .line 50
    const-string v3, "SHA224WITHRSA"

    .line 51
    .line 52
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 53
    .line 54
    .line 55
    sget-object v1, Lcom/kousei/framework/e7;->j:Lcom/kousei/framework/u;

    .line 56
    .line 57
    const-string v3, "SHA256WITHRSA"

    .line 58
    .line 59
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 60
    .line 61
    .line 62
    sget-object v1, Lcom/kousei/framework/e7;->k:Lcom/kousei/framework/u;

    .line 63
    .line 64
    const-string v3, "SHA384WITHRSA"

    .line 65
    .line 66
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 67
    .line 68
    .line 69
    sget-object v1, Lcom/kousei/framework/e7;->l:Lcom/kousei/framework/u;

    .line 70
    .line 71
    const-string v3, "SHA512WITHRSA"

    .line 72
    .line 73
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 74
    .line 75
    .line 76
    sget-object v1, Lcom/kousei/framework/ya;->e:Lcom/kousei/framework/u;

    .line 77
    .line 78
    const-string v3, "SHAKE128WITHRSAPSS"

    .line 79
    .line 80
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 81
    .line 82
    .line 83
    sget-object v1, Lcom/kousei/framework/ya;->f:Lcom/kousei/framework/u;

    .line 84
    .line 85
    const-string v3, "SHAKE256WITHRSAPSS"

    .line 86
    .line 87
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 88
    .line 89
    .line 90
    sget-object v1, Lcom/kousei/framework/s1;->c:Lcom/kousei/framework/u;

    .line 91
    .line 92
    const-string v3, "GOST3411WITHGOST3410"

    .line 93
    .line 94
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 95
    .line 96
    .line 97
    sget-object v1, Lcom/kousei/framework/s1;->d:Lcom/kousei/framework/u;

    .line 98
    .line 99
    const-string v3, "GOST3411WITHECGOST3410"

    .line 100
    .line 101
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 102
    .line 103
    .line 104
    sget-object v1, Lcom/kousei/framework/z7;->c:Lcom/kousei/framework/u;

    .line 105
    .line 106
    const-string v3, "GOST3411-2012-256WITHECGOST3410-2012-256"

    .line 107
    .line 108
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 109
    .line 110
    .line 111
    sget-object v1, Lcom/kousei/framework/z7;->d:Lcom/kousei/framework/u;

    .line 112
    .line 113
    const-string v3, "GOST3411-2012-512WITHECGOST3410-2012-512"

    .line 114
    .line 115
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 116
    .line 117
    .line 118
    sget-object v1, Lcom/kousei/framework/c1;->a:Lcom/kousei/framework/u;

    .line 119
    .line 120
    const-string v3, "SHA1WITHPLAIN-ECDSA"

    .line 121
    .line 122
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 123
    .line 124
    .line 125
    sget-object v1, Lcom/kousei/framework/c1;->b:Lcom/kousei/framework/u;

    .line 126
    .line 127
    const-string v3, "SHA224WITHPLAIN-ECDSA"

    .line 128
    .line 129
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 130
    .line 131
    .line 132
    sget-object v1, Lcom/kousei/framework/c1;->c:Lcom/kousei/framework/u;

    .line 133
    .line 134
    const-string v3, "SHA256WITHPLAIN-ECDSA"

    .line 135
    .line 136
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 137
    .line 138
    .line 139
    sget-object v1, Lcom/kousei/framework/c1;->d:Lcom/kousei/framework/u;

    .line 140
    .line 141
    const-string v3, "SHA384WITHPLAIN-ECDSA"

    .line 142
    .line 143
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 144
    .line 145
    .line 146
    sget-object v1, Lcom/kousei/framework/c1;->e:Lcom/kousei/framework/u;

    .line 147
    .line 148
    const-string v3, "SHA512WITHPLAIN-ECDSA"

    .line 149
    .line 150
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 151
    .line 152
    .line 153
    sget-object v1, Lcom/kousei/framework/c1;->g:Lcom/kousei/framework/u;

    .line 154
    .line 155
    const-string v3, "SHA3-224WITHPLAIN-ECDSA"

    .line 156
    .line 157
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 158
    .line 159
    .line 160
    sget-object v1, Lcom/kousei/framework/c1;->h:Lcom/kousei/framework/u;

    .line 161
    .line 162
    const-string v3, "SHA3-256WITHPLAIN-ECDSA"

    .line 163
    .line 164
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 165
    .line 166
    .line 167
    sget-object v1, Lcom/kousei/framework/c1;->i:Lcom/kousei/framework/u;

    .line 168
    .line 169
    const-string v3, "SHA3-384WITHPLAIN-ECDSA"

    .line 170
    .line 171
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 172
    .line 173
    .line 174
    sget-object v1, Lcom/kousei/framework/c1;->j:Lcom/kousei/framework/u;

    .line 175
    .line 176
    const-string v3, "SHA3-512WITHPLAIN-ECDSA"

    .line 177
    .line 178
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 179
    .line 180
    .line 181
    sget-object v1, Lcom/kousei/framework/c1;->f:Lcom/kousei/framework/u;

    .line 182
    .line 183
    const-string v3, "RIPEMD160WITHPLAIN-ECDSA"

    .line 184
    .line 185
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 186
    .line 187
    .line 188
    sget-object v1, Lcom/kousei/framework/m3;->a:Lcom/kousei/framework/u;

    .line 189
    .line 190
    const-string v3, "SHA1WITHCVC-ECDSA"

    .line 191
    .line 192
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 193
    .line 194
    .line 195
    sget-object v1, Lcom/kousei/framework/m3;->b:Lcom/kousei/framework/u;

    .line 196
    .line 197
    const-string v3, "SHA224WITHCVC-ECDSA"

    .line 198
    .line 199
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 200
    .line 201
    .line 202
    sget-object v1, Lcom/kousei/framework/m3;->c:Lcom/kousei/framework/u;

    .line 203
    .line 204
    const-string v3, "SHA256WITHCVC-ECDSA"

    .line 205
    .line 206
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 207
    .line 208
    .line 209
    sget-object v1, Lcom/kousei/framework/m3;->d:Lcom/kousei/framework/u;

    .line 210
    .line 211
    const-string v3, "SHA384WITHCVC-ECDSA"

    .line 212
    .line 213
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 214
    .line 215
    .line 216
    sget-object v1, Lcom/kousei/framework/m3;->e:Lcom/kousei/framework/u;

    .line 217
    .line 218
    const-string v3, "SHA512WITHCVC-ECDSA"

    .line 219
    .line 220
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 221
    .line 222
    .line 223
    sget-object v1, Lcom/kousei/framework/k5;->a:Lcom/kousei/framework/u;

    .line 224
    .line 225
    const-string v3, "XMSS"

    .line 226
    .line 227
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 228
    .line 229
    .line 230
    sget-object v1, Lcom/kousei/framework/k5;->b:Lcom/kousei/framework/u;

    .line 231
    .line 232
    const-string v3, "XMSSMT"

    .line 233
    .line 234
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 235
    .line 236
    .line 237
    sget-object v1, Lcom/kousei/framework/oa;->e:Lcom/kousei/framework/u;

    .line 238
    .line 239
    const-string v3, "RIPEMD128WITHRSA"

    .line 240
    .line 241
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 242
    .line 243
    .line 244
    sget-object v1, Lcom/kousei/framework/oa;->d:Lcom/kousei/framework/u;

    .line 245
    .line 246
    const-string v3, "RIPEMD160WITHRSA"

    .line 247
    .line 248
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 249
    .line 250
    .line 251
    sget-object v1, Lcom/kousei/framework/oa;->f:Lcom/kousei/framework/u;

    .line 252
    .line 253
    const-string v3, "RIPEMD256WITHRSA"

    .line 254
    .line 255
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 256
    .line 257
    .line 258
    new-instance v1, Lcom/kousei/framework/u;

    .line 259
    .line 260
    const-string v3, "1.2.840.113549.1.1.4"

    .line 261
    .line 262
    invoke-direct {v1, v3}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 263
    .line 264
    .line 265
    const-string v3, "MD5WITHRSA"

    .line 266
    .line 267
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 268
    .line 269
    .line 270
    new-instance v1, Lcom/kousei/framework/u;

    .line 271
    .line 272
    const-string v3, "1.2.840.113549.1.1.2"

    .line 273
    .line 274
    invoke-direct {v1, v3}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 275
    .line 276
    .line 277
    const-string v3, "MD2WITHRSA"

    .line 278
    .line 279
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 280
    .line 281
    .line 282
    new-instance v1, Lcom/kousei/framework/u;

    .line 283
    .line 284
    const-string v3, "1.2.840.10040.4.3"

    .line 285
    .line 286
    invoke-direct {v1, v3}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 287
    .line 288
    .line 289
    const-string v3, "SHA1WITHDSA"

    .line 290
    .line 291
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 292
    .line 293
    .line 294
    sget-object v1, Lcom/kousei/framework/cb;->a:Lcom/kousei/framework/u;

    .line 295
    .line 296
    const-string v4, "SHA1WITHECDSA"

    .line 297
    .line 298
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 299
    .line 300
    .line 301
    sget-object v1, Lcom/kousei/framework/cb;->b:Lcom/kousei/framework/u;

    .line 302
    .line 303
    const-string v4, "SHA224WITHECDSA"

    .line 304
    .line 305
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 306
    .line 307
    .line 308
    sget-object v1, Lcom/kousei/framework/cb;->c:Lcom/kousei/framework/u;

    .line 309
    .line 310
    const-string v4, "SHA256WITHECDSA"

    .line 311
    .line 312
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 313
    .line 314
    .line 315
    sget-object v1, Lcom/kousei/framework/cb;->d:Lcom/kousei/framework/u;

    .line 316
    .line 317
    const-string v4, "SHA384WITHECDSA"

    .line 318
    .line 319
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 320
    .line 321
    .line 322
    sget-object v1, Lcom/kousei/framework/cb;->e:Lcom/kousei/framework/u;

    .line 323
    .line 324
    const-string v4, "SHA512WITHECDSA"

    .line 325
    .line 326
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 327
    .line 328
    .line 329
    sget-object v1, Lcom/kousei/framework/ya;->g:Lcom/kousei/framework/u;

    .line 330
    .line 331
    const-string v4, "SHAKE128WITHECDSA"

    .line 332
    .line 333
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 334
    .line 335
    .line 336
    sget-object v1, Lcom/kousei/framework/ya;->h:Lcom/kousei/framework/u;

    .line 337
    .line 338
    const-string v4, "SHAKE256WITHECDSA"

    .line 339
    .line 340
    invoke-static {v1, v4}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 341
    .line 342
    .line 343
    sget-object v1, Lcom/kousei/framework/p6;->c:Lcom/kousei/framework/u;

    .line 344
    .line 345
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 346
    .line 347
    .line 348
    sget-object v1, Lcom/kousei/framework/p6;->b:Lcom/kousei/framework/u;

    .line 349
    .line 350
    invoke-static {v1, v3}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 351
    .line 352
    .line 353
    sget-object v1, Lcom/kousei/framework/l6;->v:Lcom/kousei/framework/u;

    .line 354
    .line 355
    const-string v2, "SHA224WITHDSA"

    .line 356
    .line 357
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 358
    .line 359
    .line 360
    sget-object v1, Lcom/kousei/framework/l6;->w:Lcom/kousei/framework/u;

    .line 361
    .line 362
    const-string v2, "SHA256WITHDSA"

    .line 363
    .line 364
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 365
    .line 366
    .line 367
    sget-object v1, Lcom/kousei/framework/e7;->z:Lcom/kousei/framework/u;

    .line 368
    .line 369
    const-string v2, "LMS"

    .line 370
    .line 371
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 372
    .line 373
    .line 374
    sget-object v1, Lcom/kousei/framework/l6;->L:Lcom/kousei/framework/u;

    .line 375
    .line 376
    const-string v2, "ML-DSA-44"

    .line 377
    .line 378
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 379
    .line 380
    .line 381
    sget-object v1, Lcom/kousei/framework/l6;->M:Lcom/kousei/framework/u;

    .line 382
    .line 383
    const-string v2, "ML-DSA-65"

    .line 384
    .line 385
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 386
    .line 387
    .line 388
    sget-object v1, Lcom/kousei/framework/l6;->N:Lcom/kousei/framework/u;

    .line 389
    .line 390
    const-string v2, "ML-DSA-87"

    .line 391
    .line 392
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 393
    .line 394
    .line 395
    sget-object v1, Lcom/kousei/framework/l6;->O:Lcom/kousei/framework/u;

    .line 396
    .line 397
    const-string v2, "ML-DSA-44-WITH-SHA512"

    .line 398
    .line 399
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 400
    .line 401
    .line 402
    sget-object v1, Lcom/kousei/framework/l6;->P:Lcom/kousei/framework/u;

    .line 403
    .line 404
    const-string v2, "ML-DSA-65-WITH-SHA512"

    .line 405
    .line 406
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 407
    .line 408
    .line 409
    sget-object v1, Lcom/kousei/framework/l6;->Q:Lcom/kousei/framework/u;

    .line 410
    .line 411
    const-string v2, "ML-DSA-87-WITH-SHA512"

    .line 412
    .line 413
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 414
    .line 415
    .line 416
    sget-object v1, Lcom/kousei/framework/l6;->R:Lcom/kousei/framework/u;

    .line 417
    .line 418
    const-string v2, "SLH-DSA-SHA2-128S"

    .line 419
    .line 420
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 421
    .line 422
    .line 423
    sget-object v1, Lcom/kousei/framework/l6;->S:Lcom/kousei/framework/u;

    .line 424
    .line 425
    const-string v2, "SLH-DSA-SHA2-128F"

    .line 426
    .line 427
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 428
    .line 429
    .line 430
    sget-object v1, Lcom/kousei/framework/l6;->T:Lcom/kousei/framework/u;

    .line 431
    .line 432
    const-string v2, "SLH-DSA-SHA2-192S"

    .line 433
    .line 434
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 435
    .line 436
    .line 437
    sget-object v1, Lcom/kousei/framework/l6;->U:Lcom/kousei/framework/u;

    .line 438
    .line 439
    const-string v2, "SLH-DSA-SHA2-192F"

    .line 440
    .line 441
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 442
    .line 443
    .line 444
    sget-object v1, Lcom/kousei/framework/l6;->V:Lcom/kousei/framework/u;

    .line 445
    .line 446
    const-string v2, "SLH-DSA-SHA2-256S"

    .line 447
    .line 448
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 449
    .line 450
    .line 451
    sget-object v1, Lcom/kousei/framework/l6;->W:Lcom/kousei/framework/u;

    .line 452
    .line 453
    const-string v2, "SLH-DSA-SHA2-256F"

    .line 454
    .line 455
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 456
    .line 457
    .line 458
    sget-object v1, Lcom/kousei/framework/l6;->X:Lcom/kousei/framework/u;

    .line 459
    .line 460
    const-string v2, "SLH-DSA-SHAKE-128S"

    .line 461
    .line 462
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 463
    .line 464
    .line 465
    sget-object v1, Lcom/kousei/framework/l6;->Y:Lcom/kousei/framework/u;

    .line 466
    .line 467
    const-string v2, "SLH-DSA-SHAKE-128F"

    .line 468
    .line 469
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 470
    .line 471
    .line 472
    sget-object v1, Lcom/kousei/framework/l6;->Z:Lcom/kousei/framework/u;

    .line 473
    .line 474
    const-string v2, "SLH-DSA-SHAKE-192S"

    .line 475
    .line 476
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 477
    .line 478
    .line 479
    sget-object v1, Lcom/kousei/framework/l6;->a0:Lcom/kousei/framework/u;

    .line 480
    .line 481
    const-string v2, "SLH-DSA-SHAKE-192F"

    .line 482
    .line 483
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 484
    .line 485
    .line 486
    sget-object v1, Lcom/kousei/framework/l6;->b0:Lcom/kousei/framework/u;

    .line 487
    .line 488
    const-string v2, "SLH-DSA-SHAKE-256S"

    .line 489
    .line 490
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 491
    .line 492
    .line 493
    sget-object v1, Lcom/kousei/framework/l6;->c0:Lcom/kousei/framework/u;

    .line 494
    .line 495
    const-string v2, "SLH-DSA-SHAKE-256F"

    .line 496
    .line 497
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 498
    .line 499
    .line 500
    sget-object v1, Lcom/kousei/framework/l6;->d0:Lcom/kousei/framework/u;

    .line 501
    .line 502
    const-string v2, "SLH-DSA-SHA2-128S-WITH-SHA256"

    .line 503
    .line 504
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 505
    .line 506
    .line 507
    sget-object v1, Lcom/kousei/framework/l6;->e0:Lcom/kousei/framework/u;

    .line 508
    .line 509
    const-string v2, "SLH-DSA-SHA2-128F-WITH-SHA256"

    .line 510
    .line 511
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 512
    .line 513
    .line 514
    sget-object v1, Lcom/kousei/framework/l6;->f0:Lcom/kousei/framework/u;

    .line 515
    .line 516
    const-string v2, "SLH-DSA-SHA2-192S-WITH-SHA512"

    .line 517
    .line 518
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 519
    .line 520
    .line 521
    sget-object v1, Lcom/kousei/framework/l6;->g0:Lcom/kousei/framework/u;

    .line 522
    .line 523
    const-string v2, "SLH-DSA-SHA2-192F-WITH-SHA512"

    .line 524
    .line 525
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 526
    .line 527
    .line 528
    sget-object v1, Lcom/kousei/framework/l6;->h0:Lcom/kousei/framework/u;

    .line 529
    .line 530
    const-string v2, "SLH-DSA-SHA2-256S-WITH-SHA512"

    .line 531
    .line 532
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 533
    .line 534
    .line 535
    sget-object v1, Lcom/kousei/framework/l6;->i0:Lcom/kousei/framework/u;

    .line 536
    .line 537
    const-string v2, "SLH-DSA-SHA2-256F-WITH-SHA512"

    .line 538
    .line 539
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 540
    .line 541
    .line 542
    sget-object v1, Lcom/kousei/framework/l6;->j0:Lcom/kousei/framework/u;

    .line 543
    .line 544
    const-string v2, "SLH-DSA-SHAKE-128S-WITH-SHAKE128"

    .line 545
    .line 546
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 547
    .line 548
    .line 549
    sget-object v1, Lcom/kousei/framework/l6;->k0:Lcom/kousei/framework/u;

    .line 550
    .line 551
    const-string v2, "SLH-DSA-SHAKE-128F-WITH-SHAKE128"

    .line 552
    .line 553
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 554
    .line 555
    .line 556
    sget-object v1, Lcom/kousei/framework/l6;->l0:Lcom/kousei/framework/u;

    .line 557
    .line 558
    const-string v2, "SLH-DSA-SHAKE-192S-WITH-SHAKE256"

    .line 559
    .line 560
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 561
    .line 562
    .line 563
    sget-object v1, Lcom/kousei/framework/l6;->m0:Lcom/kousei/framework/u;

    .line 564
    .line 565
    const-string v2, "SLH-DSA-SHAKE-192F-WITH-SHAKE256"

    .line 566
    .line 567
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 568
    .line 569
    .line 570
    sget-object v1, Lcom/kousei/framework/l6;->n0:Lcom/kousei/framework/u;

    .line 571
    .line 572
    const-string v2, "SLH-DSA-SHAKE-256S-WITH-SHAKE256"

    .line 573
    .line 574
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 575
    .line 576
    .line 577
    sget-object v1, Lcom/kousei/framework/l6;->o0:Lcom/kousei/framework/u;

    .line 578
    .line 579
    const-string v2, "SLH-DSA-SHAKE-256F-WITH-SHAKE256"

    .line 580
    .line 581
    invoke-static {v1, v2}, Lcom/kousei/framework/i3;->a(Lcom/kousei/framework/u;Ljava/lang/String;)V

    .line 582
    .line 583
    .line 584
    sget-object v1, Lcom/kousei/framework/p6;->a:Lcom/kousei/framework/u;

    .line 585
    .line 586
    const-string v2, "SHA1"

    .line 587
    .line 588
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 589
    .line 590
    .line 591
    sget-object v1, Lcom/kousei/framework/l6;->d:Lcom/kousei/framework/u;

    .line 592
    .line 593
    const-string v2, "SHA224"

    .line 594
    .line 595
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 596
    .line 597
    .line 598
    sget-object v1, Lcom/kousei/framework/l6;->a:Lcom/kousei/framework/u;

    .line 599
    .line 600
    const-string v2, "SHA256"

    .line 601
    .line 602
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 603
    .line 604
    .line 605
    sget-object v1, Lcom/kousei/framework/l6;->b:Lcom/kousei/framework/u;

    .line 606
    .line 607
    const-string v2, "SHA384"

    .line 608
    .line 609
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 610
    .line 611
    .line 612
    sget-object v1, Lcom/kousei/framework/l6;->c:Lcom/kousei/framework/u;

    .line 613
    .line 614
    const-string v2, "SHA512"

    .line 615
    .line 616
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 617
    .line 618
    .line 619
    sget-object v1, Lcom/kousei/framework/l6;->k:Lcom/kousei/framework/u;

    .line 620
    .line 621
    const-string v2, "SHAKE128"

    .line 622
    .line 623
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 624
    .line 625
    .line 626
    sget-object v1, Lcom/kousei/framework/l6;->l:Lcom/kousei/framework/u;

    .line 627
    .line 628
    const-string v2, "SHAKE256"

    .line 629
    .line 630
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 631
    .line 632
    .line 633
    sget-object v1, Lcom/kousei/framework/l6;->g:Lcom/kousei/framework/u;

    .line 634
    .line 635
    const-string v2, "SHA3-224"

    .line 636
    .line 637
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 638
    .line 639
    .line 640
    sget-object v1, Lcom/kousei/framework/l6;->h:Lcom/kousei/framework/u;

    .line 641
    .line 642
    const-string v2, "SHA3-256"

    .line 643
    .line 644
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 645
    .line 646
    .line 647
    sget-object v1, Lcom/kousei/framework/l6;->i:Lcom/kousei/framework/u;

    .line 648
    .line 649
    const-string v2, "SHA3-384"

    .line 650
    .line 651
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 652
    .line 653
    .line 654
    sget-object v1, Lcom/kousei/framework/l6;->j:Lcom/kousei/framework/u;

    .line 655
    .line 656
    const-string v2, "SHA3-512"

    .line 657
    .line 658
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 659
    .line 660
    .line 661
    sget-object v1, Lcom/kousei/framework/oa;->b:Lcom/kousei/framework/u;

    .line 662
    .line 663
    const-string v2, "RIPEMD128"

    .line 664
    .line 665
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 666
    .line 667
    .line 668
    sget-object v1, Lcom/kousei/framework/oa;->a:Lcom/kousei/framework/u;

    .line 669
    .line 670
    const-string v2, "RIPEMD160"

    .line 671
    .line 672
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 673
    .line 674
    .line 675
    sget-object v1, Lcom/kousei/framework/oa;->c:Lcom/kousei/framework/u;

    .line 676
    .line 677
    const-string v2, "RIPEMD256"

    .line 678
    .line 679
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 680
    .line 681
    .line 682
    return-void
.end method

.method public static a(Lcom/kousei/framework/u;Ljava/lang/String;)V
    .registers 4

    .line 1
    sget-object v0, Lcom/kousei/framework/i3;->a:Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-virtual {v0, p0}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_c

    .line 8
    .line 9
    invoke-virtual {v0, p0, p1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 10
    .line 11
    .line 12
    return-void

    .line 13
    :cond_c
    const-string p0, "object identifier already present in addSignatureName"

    .line 14
    .line 15
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 16
    .line 17
    .line 18
    return-void
.end method

.method public static b(Lcom/kousei/framework/u;)Ljava/lang/String;
    .registers 2

    .line 1
    sget-object v0, Lcom/kousei/framework/i3;->b:Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-virtual {v0, p0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    check-cast v0, Ljava/lang/String;

    .line 8
    .line 9
    if-eqz v0, :cond_b

    .line 10
    .line 11
    return-object v0

    .line 12
    :cond_b
    invoke-virtual {p0}, Lcom/kousei/framework/u;->u()Ljava/lang/String;

    .line 13
    .line 14
    .line 15
    move-result-object p0

    .line 16
    return-object p0
.end method
