.class public final Lcom/kousei/framework/a;
.super Lcom/kousei/framework/bb;


# instance fields
.field public final synthetic b:I


# direct methods
.method public synthetic constructor <init>(I)V
    .registers 2

    .line 1
    iput p1, p0, Lcom/kousei/framework/a;->b:I

    .line 2
    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 4
    .line 5
    .line 6
    return-void
.end method

.method private final c()Lcom/kousei/framework/v3;
    .registers 6

    .line 1
    new-instance p0, Ljava/math/BigInteger;

    .line 2
    .line 3
    const-string v0, "9ba48cba5ebcb9b6bd33b92830b2a2e0e192f10a"

    .line 4
    .line 5
    const/16 v1, 0x10

    .line 6
    .line 7
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 8
    .line 9
    .line 10
    new-instance v0, Ljava/math/BigInteger;

    .line 11
    .line 12
    const-string v2, "c39c6c3b3a36d7701b9c71a1f5804ae5d0003f4"

    .line 13
    .line 14
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 15
    .line 16
    .line 17
    new-instance v0, Ljava/math/BigInteger;

    .line 18
    .line 19
    const-string v2, "9162fbe73984472a0a9e"

    .line 20
    .line 21
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 22
    .line 23
    .line 24
    new-instance v3, Ljava/math/BigInteger;

    .line 25
    .line 26
    const-string v4, "-96341f1138933bc2f505"

    .line 27
    .line 28
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 29
    .line 30
    .line 31
    filled-new-array {v0, v3}, [Ljava/math/BigInteger;

    .line 32
    .line 33
    .line 34
    move-result-object v0

    .line 35
    new-instance v3, Ljava/math/BigInteger;

    .line 36
    .line 37
    const-string v4, "127971af8721782ecffa3"

    .line 38
    .line 39
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 40
    .line 41
    .line 42
    new-instance v4, Ljava/math/BigInteger;

    .line 43
    .line 44
    invoke-direct {v4, v2, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 45
    .line 46
    .line 47
    filled-new-array {v3, v4}, [Ljava/math/BigInteger;

    .line 48
    .line 49
    .line 50
    move-result-object v2

    .line 51
    new-instance v3, Ljava/math/BigInteger;

    .line 52
    .line 53
    const-string v4, "9162fbe73984472a0a9d0590"

    .line 54
    .line 55
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 56
    .line 57
    .line 58
    new-instance v3, Ljava/math/BigInteger;

    .line 59
    .line 60
    const-string v4, "96341f1138933bc2f503fd44"

    .line 61
    .line 62
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 63
    .line 64
    .line 65
    const-string v1, "v1"

    .line 66
    .line 67
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 68
    .line 69
    .line 70
    const-string v0, "v2"

    .line 71
    .line 72
    invoke-static {v2, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 73
    .line 74
    .line 75
    new-instance v0, Lcom/kousei/framework/j8;

    .line 76
    .line 77
    invoke-direct {v0}, Lcom/kousei/framework/j8;-><init>()V

    .line 78
    .line 79
    .line 80
    monitor-enter v0

    .line 81
    :try_start_50
    iget v1, v0, Lcom/kousei/framework/v3;->f:I
    :try_end_52
    .catchall {:try_start_50 .. :try_end_52} :catchall_74

    .line 82
    .line 83
    monitor-exit v0

    .line 84
    invoke-virtual {v0, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 85
    .line 86
    .line 87
    invoke-virtual {v0, v1}, Lcom/kousei/framework/v3;->m(I)Z

    .line 88
    .line 89
    .line 90
    move-result p0

    .line 91
    const/4 v2, 0x0

    .line 92
    if-eqz p0, :cond_71

    .line 93
    .line 94
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 95
    .line 96
    .line 97
    move-result-object p0

    .line 98
    if-eq p0, v0, :cond_6b

    .line 99
    .line 100
    monitor-enter p0

    .line 101
    :try_start_64
    iput v1, p0, Lcom/kousei/framework/v3;->f:I

    .line 102
    .line 103
    monitor-exit p0

    .line 104
    return-object p0

    .line 105
    :catchall_68
    move-exception v0

    .line 106
    monitor-exit p0
    :try_end_6a
    .catchall {:try_start_64 .. :try_end_6a} :catchall_68

    .line 107
    throw v0

    .line 108
    :cond_6b
    const-string p0, "implementation returned current curve"

    .line 109
    .line 110
    :goto_6d
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 111
    .line 112
    .line 113
    return-object v2

    .line 114
    :cond_71
    const-string p0, "unsupported coordinate system"

    .line 115
    .line 116
    goto :goto_6d

    .line 117
    :catchall_74
    move-exception p0

    .line 118
    :try_start_75
    monitor-exit v0
    :try_end_76
    .catchall {:try_start_75 .. :try_end_76} :catchall_74

    .line 119
    throw p0
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 8

    .line 1
    iget v0, p0, Lcom/kousei/framework/a;->b:I

    .line 2
    .line 3
    const/16 v1, 0x10

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    packed-switch v0, :pswitch_data_1d2

    .line 7
    .line 8
    .line 9
    new-instance p0, Ljava/math/BigInteger;

    .line 10
    .line 11
    const-string v0, "bb85691939b869c1d087f601554b96b80cb4f55b35f433c2"

    .line 12
    .line 13
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 14
    .line 15
    .line 16
    new-instance v0, Ljava/math/BigInteger;

    .line 17
    .line 18
    const-string v3, "3d84f26c12238d7b4f3d516613c1759033b1a5800175d0b1"

    .line 19
    .line 20
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 21
    .line 22
    .line 23
    new-instance v0, Ljava/math/BigInteger;

    .line 24
    .line 25
    const-string v3, "71169be7330b3038edb025f1"

    .line 26
    .line 27
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 28
    .line 29
    .line 30
    new-instance v4, Ljava/math/BigInteger;

    .line 31
    .line 32
    const-string v5, "-b3fb3400dec5c4adceb8655c"

    .line 33
    .line 34
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 35
    .line 36
    .line 37
    filled-new-array {v0, v4}, [Ljava/math/BigInteger;

    .line 38
    .line 39
    .line 40
    move-result-object v0

    .line 41
    new-instance v4, Ljava/math/BigInteger;

    .line 42
    .line 43
    const-string v5, "12511cfe811d0f4e6bc688b4d"

    .line 44
    .line 45
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 46
    .line 47
    .line 48
    new-instance v5, Ljava/math/BigInteger;

    .line 49
    .line 50
    invoke-direct {v5, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 51
    .line 52
    .line 53
    filled-new-array {v4, v5}, [Ljava/math/BigInteger;

    .line 54
    .line 55
    .line 56
    move-result-object v3

    .line 57
    new-instance v4, Ljava/math/BigInteger;

    .line 58
    .line 59
    const-string v5, "71169be7330b3038edb025f1d0f9"

    .line 60
    .line 61
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 62
    .line 63
    .line 64
    new-instance v4, Ljava/math/BigInteger;

    .line 65
    .line 66
    const-string v5, "b3fb3400dec5c4adceb8655d4c94"

    .line 67
    .line 68
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 69
    .line 70
    .line 71
    const-string v1, "v1"

    .line 72
    .line 73
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 74
    .line 75
    .line 76
    const-string v0, "v2"

    .line 77
    .line 78
    invoke-static {v3, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 79
    .line 80
    .line 81
    new-instance v1, Lcom/kousei/framework/o8;

    .line 82
    .line 83
    invoke-direct {v1}, Lcom/kousei/framework/o8;-><init>()V

    .line 84
    .line 85
    .line 86
    monitor-enter v1

    .line 87
    :try_start_56
    iget v0, v1, Lcom/kousei/framework/v3;->f:I
    :try_end_58
    .catchall {:try_start_56 .. :try_end_58} :catchall_7b

    .line 88
    .line 89
    monitor-exit v1

    .line 90
    invoke-virtual {v1, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 91
    .line 92
    .line 93
    invoke-virtual {v1, v0}, Lcom/kousei/framework/v3;->m(I)Z

    .line 94
    .line 95
    .line 96
    move-result p0

    .line 97
    if-eqz p0, :cond_77

    .line 98
    .line 99
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 100
    .line 101
    .line 102
    move-result-object p0

    .line 103
    if-eq p0, v1, :cond_71

    .line 104
    .line 105
    monitor-enter p0

    .line 106
    :try_start_69
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 107
    .line 108
    monitor-exit p0

    .line 109
    move-object v2, p0

    .line 110
    goto :goto_7a

    .line 111
    :catchall_6e
    move-exception v0

    .line 112
    monitor-exit p0
    :try_end_70
    .catchall {:try_start_69 .. :try_end_70} :catchall_6e

    .line 113
    throw v0

    .line 114
    :cond_71
    const-string p0, "implementation returned current curve"

    .line 115
    .line 116
    :goto_73
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 117
    .line 118
    .line 119
    goto :goto_7a

    .line 120
    :cond_77
    const-string p0, "unsupported coordinate system"

    .line 121
    .line 122
    goto :goto_73

    .line 123
    :goto_7a
    return-object v2

    .line 124
    :catchall_7b
    move-exception v0

    .line 125
    move-object p0, v0

    .line 126
    :try_start_7d
    monitor-exit v1
    :try_end_7e
    .catchall {:try_start_7d .. :try_end_7e} :catchall_7b

    .line 127
    throw p0

    .line 128
    :pswitch_7f
    new-instance p0, Lcom/kousei/framework/m8;

    .line 129
    .line 130
    invoke-direct {p0}, Lcom/kousei/framework/m8;-><init>()V

    .line 131
    .line 132
    .line 133
    return-object p0

    .line 134
    :pswitch_85
    new-instance p0, Lcom/kousei/framework/k8;

    .line 135
    .line 136
    invoke-direct {p0}, Lcom/kousei/framework/k8;-><init>()V

    .line 137
    .line 138
    .line 139
    return-object p0

    .line 140
    :pswitch_8b
    invoke-direct {p0}, Lcom/kousei/framework/a;->c()Lcom/kousei/framework/v3;

    .line 141
    .line 142
    .line 143
    move-result-object p0

    .line 144
    return-object p0

    .line 145
    :pswitch_90
    new-instance p0, Lcom/kousei/framework/f8;

    .line 146
    .line 147
    invoke-direct {p0}, Lcom/kousei/framework/f8;-><init>()V

    .line 148
    .line 149
    .line 150
    return-object p0

    .line 151
    :pswitch_96
    new-instance p0, Lcom/kousei/framework/fa;

    .line 152
    .line 153
    invoke-direct {p0}, Lcom/kousei/framework/fa;-><init>()V

    .line 154
    .line 155
    .line 156
    return-object p0

    .line 157
    :pswitch_9c
    new-instance p0, Lcom/kousei/framework/ea;

    .line 158
    .line 159
    invoke-direct {p0}, Lcom/kousei/framework/ea;-><init>()V

    .line 160
    .line 161
    .line 162
    return-object p0

    .line 163
    :pswitch_a2
    new-instance p0, Lcom/kousei/framework/h8;

    .line 164
    .line 165
    invoke-direct {p0}, Lcom/kousei/framework/h8;-><init>()V

    .line 166
    .line 167
    .line 168
    return-object p0

    .line 169
    :pswitch_a8
    new-instance p0, Lcom/kousei/framework/ba;

    .line 170
    .line 171
    invoke-direct {p0}, Lcom/kousei/framework/ba;-><init>()V

    .line 172
    .line 173
    .line 174
    return-object p0

    .line 175
    :pswitch_ae
    new-instance p0, Lcom/kousei/framework/aa;

    .line 176
    .line 177
    invoke-direct {p0}, Lcom/kousei/framework/aa;-><init>()V

    .line 178
    .line 179
    .line 180
    return-object p0

    .line 181
    :pswitch_b4
    new-instance p0, Lcom/kousei/framework/y9;

    .line 182
    .line 183
    invoke-direct {p0}, Lcom/kousei/framework/y9;-><init>()V

    .line 184
    .line 185
    .line 186
    return-object p0

    .line 187
    :pswitch_ba
    new-instance p0, Lcom/kousei/framework/x9;

    .line 188
    .line 189
    invoke-direct {p0}, Lcom/kousei/framework/x9;-><init>()V

    .line 190
    .line 191
    .line 192
    return-object p0

    .line 193
    :pswitch_c0
    new-instance p0, Lcom/kousei/framework/v9;

    .line 194
    .line 195
    invoke-direct {p0}, Lcom/kousei/framework/v9;-><init>()V

    .line 196
    .line 197
    .line 198
    return-object p0

    .line 199
    :pswitch_c6
    new-instance p0, Lcom/kousei/framework/t9;

    .line 200
    .line 201
    invoke-direct {p0}, Lcom/kousei/framework/t9;-><init>()V

    .line 202
    .line 203
    .line 204
    return-object p0

    .line 205
    :pswitch_cc
    new-instance p0, Lcom/kousei/framework/s9;

    .line 206
    .line 207
    invoke-direct {p0}, Lcom/kousei/framework/s9;-><init>()V

    .line 208
    .line 209
    .line 210
    return-object p0

    .line 211
    :pswitch_d2
    new-instance p0, Lcom/kousei/framework/q9;

    .line 212
    .line 213
    invoke-direct {p0}, Lcom/kousei/framework/q9;-><init>()V

    .line 214
    .line 215
    .line 216
    return-object p0

    .line 217
    :pswitch_d8
    new-instance p0, Lcom/kousei/framework/p9;

    .line 218
    .line 219
    invoke-direct {p0}, Lcom/kousei/framework/p9;-><init>()V

    .line 220
    .line 221
    .line 222
    return-object p0

    .line 223
    :pswitch_de
    new-instance p0, Lcom/kousei/framework/n9;

    .line 224
    .line 225
    invoke-direct {p0}, Lcom/kousei/framework/n9;-><init>()V

    .line 226
    .line 227
    .line 228
    return-object p0

    .line 229
    :pswitch_e4
    new-instance p0, Lcom/kousei/framework/z1;

    .line 230
    .line 231
    invoke-direct {p0}, Lcom/kousei/framework/z1;-><init>()V

    .line 232
    .line 233
    .line 234
    return-object p0

    .line 235
    :pswitch_ea
    new-instance p0, Lcom/kousei/framework/m9;

    .line 236
    .line 237
    invoke-direct {p0}, Lcom/kousei/framework/m9;-><init>()V

    .line 238
    .line 239
    .line 240
    return-object p0

    .line 241
    :pswitch_f0
    new-instance p0, Lcom/kousei/framework/l9;

    .line 242
    .line 243
    invoke-direct {p0}, Lcom/kousei/framework/l9;-><init>()V

    .line 244
    .line 245
    .line 246
    return-object p0

    .line 247
    :pswitch_f6
    new-instance p0, Lcom/kousei/framework/j9;

    .line 248
    .line 249
    invoke-direct {p0}, Lcom/kousei/framework/j9;-><init>()V

    .line 250
    .line 251
    .line 252
    return-object p0

    .line 253
    :pswitch_fc
    new-instance p0, Lcom/kousei/framework/i9;

    .line 254
    .line 255
    invoke-direct {p0}, Lcom/kousei/framework/i9;-><init>()V

    .line 256
    .line 257
    .line 258
    return-object p0

    .line 259
    :pswitch_102
    new-instance p0, Lcom/kousei/framework/g9;

    .line 260
    .line 261
    invoke-direct {p0}, Lcom/kousei/framework/g9;-><init>()V

    .line 262
    .line 263
    .line 264
    return-object p0

    .line 265
    :pswitch_108
    new-instance p0, Lcom/kousei/framework/f9;

    .line 266
    .line 267
    invoke-direct {p0}, Lcom/kousei/framework/f9;-><init>()V

    .line 268
    .line 269
    .line 270
    return-object p0

    .line 271
    :pswitch_10e
    new-instance p0, Lcom/kousei/framework/c9;

    .line 272
    .line 273
    invoke-direct {p0}, Lcom/kousei/framework/c9;-><init>()V

    .line 274
    .line 275
    .line 276
    return-object p0

    .line 277
    :pswitch_114
    new-instance p0, Lcom/kousei/framework/a9;

    .line 278
    .line 279
    invoke-direct {p0}, Lcom/kousei/framework/a9;-><init>()V

    .line 280
    .line 281
    .line 282
    return-object p0

    .line 283
    :pswitch_11a
    new-instance p0, Lcom/kousei/framework/y8;

    .line 284
    .line 285
    invoke-direct {p0}, Lcom/kousei/framework/y8;-><init>()V

    .line 286
    .line 287
    .line 288
    return-object p0

    .line 289
    :pswitch_120
    new-instance p0, Ljava/math/BigInteger;

    .line 290
    .line 291
    const-string v0, "7ae96a2b657c07106e64479eac3434e99cf0497512f58995c1396c28719501ee"

    .line 292
    .line 293
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 294
    .line 295
    .line 296
    new-instance v0, Ljava/math/BigInteger;

    .line 297
    .line 298
    const-string v3, "5363ad4cc05c30e0a5261c028812645a122e22ea20816678df02967c1b23bd72"

    .line 299
    .line 300
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 301
    .line 302
    .line 303
    new-instance v0, Ljava/math/BigInteger;

    .line 304
    .line 305
    const-string v3, "3086d221a7d46bcde86c90e49284eb15"

    .line 306
    .line 307
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 308
    .line 309
    .line 310
    new-instance v4, Ljava/math/BigInteger;

    .line 311
    .line 312
    const-string v5, "-e4437ed6010e88286f547fa90abfe4c3"

    .line 313
    .line 314
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 315
    .line 316
    .line 317
    filled-new-array {v0, v4}, [Ljava/math/BigInteger;

    .line 318
    .line 319
    .line 320
    move-result-object v0

    .line 321
    new-instance v4, Ljava/math/BigInteger;

    .line 322
    .line 323
    const-string v5, "114ca50f7a8e2f3f657c1108d9d44cfd8"

    .line 324
    .line 325
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 326
    .line 327
    .line 328
    new-instance v5, Ljava/math/BigInteger;

    .line 329
    .line 330
    invoke-direct {v5, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 331
    .line 332
    .line 333
    filled-new-array {v4, v5}, [Ljava/math/BigInteger;

    .line 334
    .line 335
    .line 336
    move-result-object v3

    .line 337
    new-instance v4, Ljava/math/BigInteger;

    .line 338
    .line 339
    const-string v5, "3086d221a7d46bcde86c90e49284eb153dab"

    .line 340
    .line 341
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 342
    .line 343
    .line 344
    new-instance v4, Ljava/math/BigInteger;

    .line 345
    .line 346
    const-string v5, "e4437ed6010e88286f547fa90abfe4c42212"

    .line 347
    .line 348
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 349
    .line 350
    .line 351
    const-string v1, "v1"

    .line 352
    .line 353
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 354
    .line 355
    .line 356
    const-string v0, "v2"

    .line 357
    .line 358
    invoke-static {v3, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 359
    .line 360
    .line 361
    new-instance v1, Lcom/kousei/framework/w8;

    .line 362
    .line 363
    invoke-direct {v1}, Lcom/kousei/framework/w8;-><init>()V

    .line 364
    .line 365
    .line 366
    monitor-enter v1

    .line 367
    :try_start_16e
    iget v0, v1, Lcom/kousei/framework/v3;->f:I
    :try_end_170
    .catchall {:try_start_16e .. :try_end_170} :catchall_193

    .line 368
    .line 369
    monitor-exit v1

    .line 370
    invoke-virtual {v1, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 371
    .line 372
    .line 373
    invoke-virtual {v1, v0}, Lcom/kousei/framework/v3;->m(I)Z

    .line 374
    .line 375
    .line 376
    move-result p0

    .line 377
    if-eqz p0, :cond_18f

    .line 378
    .line 379
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 380
    .line 381
    .line 382
    move-result-object p0

    .line 383
    if-eq p0, v1, :cond_189

    .line 384
    .line 385
    monitor-enter p0

    .line 386
    :try_start_181
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 387
    .line 388
    monitor-exit p0

    .line 389
    move-object v2, p0

    .line 390
    goto :goto_192

    .line 391
    :catchall_186
    move-exception v0

    .line 392
    monitor-exit p0
    :try_end_188
    .catchall {:try_start_181 .. :try_end_188} :catchall_186

    .line 393
    throw v0

    .line 394
    :cond_189
    const-string p0, "implementation returned current curve"

    .line 395
    .line 396
    :goto_18b
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 397
    .line 398
    .line 399
    goto :goto_192

    .line 400
    :cond_18f
    const-string p0, "unsupported coordinate system"

    .line 401
    .line 402
    goto :goto_18b

    .line 403
    :goto_192
    return-object v2

    .line 404
    :catchall_193
    move-exception v0

    .line 405
    move-object p0, v0

    .line 406
    :try_start_195
    monitor-exit v1
    :try_end_196
    .catchall {:try_start_195 .. :try_end_196} :catchall_193

    .line 407
    throw p0

    .line 408
    :pswitch_197
    const-string p0, "F1FD178C0B3AD58F10126DE8CE42435B3961ADBCABC8CA6DE8FCF353D86E9C03"

    .line 409
    .line 410
    new-instance v1, Ljava/math/BigInteger;

    .line 411
    .line 412
    invoke-static {p0}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 413
    .line 414
    .line 415
    move-result-object p0

    .line 416
    const/4 v0, 0x1

    .line 417
    invoke-direct {v1, v0, p0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 418
    .line 419
    .line 420
    const-string p0, "F1FD178C0B3AD58F10126DE8CE42435B3961ADBCABC8CA6DE8FCF353D86E9C00"

    .line 421
    .line 422
    new-instance v2, Ljava/math/BigInteger;

    .line 423
    .line 424
    invoke-static {p0}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 425
    .line 426
    .line 427
    move-result-object p0

    .line 428
    invoke-direct {v2, v0, p0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 429
    .line 430
    .line 431
    const-string p0, "EE353FCA5428A9300D4ABA754A44C00FDFEC0C9AE4B1A1803075ED967B7BB73F"

    .line 432
    .line 433
    new-instance v3, Ljava/math/BigInteger;

    .line 434
    .line 435
    invoke-static {p0}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 436
    .line 437
    .line 438
    move-result-object p0

    .line 439
    invoke-direct {v3, v0, p0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 440
    .line 441
    .line 442
    const-string p0, "F1FD178C0B3AD58F10126DE8CE42435B53DC67E140D2BF941FFDD459C6D655E1"

    .line 443
    .line 444
    new-instance v4, Ljava/math/BigInteger;

    .line 445
    .line 446
    invoke-static {p0}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 447
    .line 448
    .line 449
    move-result-object p0

    .line 450
    invoke-direct {v4, v0, p0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 451
    .line 452
    .line 453
    const-wide/16 v5, 0x1

    .line 454
    .line 455
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 456
    .line 457
    .line 458
    move-result-object v5

    .line 459
    new-instance v0, Lcom/kousei/framework/u3;

    .line 460
    .line 461
    const/4 v6, 0x1

    .line 462
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 463
    .line 464
    .line 465
    return-object v0

    .line 466
    nop

    .line 467
    :pswitch_data_1d2
    .packed-switch 0x0
        :pswitch_197
        :pswitch_120
        :pswitch_11a
        :pswitch_114
        :pswitch_10e
        :pswitch_108
        :pswitch_102
        :pswitch_fc
        :pswitch_f6
        :pswitch_f0
        :pswitch_ea
        :pswitch_e4
        :pswitch_de
        :pswitch_d8
        :pswitch_d2
        :pswitch_cc
        :pswitch_c6
        :pswitch_c0
        :pswitch_ba
        :pswitch_b4
        :pswitch_ae
        :pswitch_a8
        :pswitch_a2
        :pswitch_9c
        :pswitch_96
        :pswitch_90
        :pswitch_8b
        :pswitch_85
        :pswitch_7f
    .end packed-switch
.end method
