.class public abstract Lcom/kousei/framework/h6;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/HashMap;


# direct methods
.method static constructor <clinit>()V
    .registers 23

    .line 1
    new-instance v0, Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 4
    .line 5
    .line 6
    sput-object v0, Lcom/kousei/framework/h6;->a:Ljava/util/HashMap;

    .line 7
    .line 8
    new-instance v1, Ljava/util/HashMap;

    .line 9
    .line 10
    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    .line 11
    .line 12
    .line 13
    sget-object v2, Lcom/kousei/framework/e7;->r:Lcom/kousei/framework/u;

    .line 14
    .line 15
    const-string v3, "MD2"

    .line 16
    .line 17
    invoke-virtual {v0, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 18
    .line 19
    .line 20
    sget-object v2, Lcom/kousei/framework/e7;->s:Lcom/kousei/framework/u;

    .line 21
    .line 22
    const-string v3, "MD4"

    .line 23
    .line 24
    invoke-virtual {v0, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 25
    .line 26
    .line 27
    sget-object v2, Lcom/kousei/framework/e7;->t:Lcom/kousei/framework/u;

    .line 28
    .line 29
    const-string v3, "MD5"

    .line 30
    .line 31
    invoke-virtual {v0, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 32
    .line 33
    .line 34
    sget-object v2, Lcom/kousei/framework/o6;->a:Lcom/kousei/framework/u;

    .line 35
    .line 36
    const-string v3, "SHA-1"

    .line 37
    .line 38
    invoke-virtual {v0, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 39
    .line 40
    .line 41
    sget-object v4, Lcom/kousei/framework/l6;->d:Lcom/kousei/framework/u;

    .line 42
    .line 43
    const-string v5, "SHA-224"

    .line 44
    .line 45
    invoke-virtual {v0, v4, v5}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 46
    .line 47
    .line 48
    sget-object v6, Lcom/kousei/framework/l6;->a:Lcom/kousei/framework/u;

    .line 49
    .line 50
    const-string v7, "SHA-256"

    .line 51
    .line 52
    invoke-virtual {v0, v6, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 53
    .line 54
    .line 55
    sget-object v8, Lcom/kousei/framework/l6;->b:Lcom/kousei/framework/u;

    .line 56
    .line 57
    const-string v9, "SHA-384"

    .line 58
    .line 59
    invoke-virtual {v0, v8, v9}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 60
    .line 61
    .line 62
    sget-object v10, Lcom/kousei/framework/l6;->c:Lcom/kousei/framework/u;

    .line 63
    .line 64
    const-string v11, "SHA-512"

    .line 65
    .line 66
    invoke-virtual {v0, v10, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 67
    .line 68
    .line 69
    sget-object v12, Lcom/kousei/framework/l6;->e:Lcom/kousei/framework/u;

    .line 70
    .line 71
    const-string v13, "SHA-512(224)"

    .line 72
    .line 73
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 74
    .line 75
    .line 76
    sget-object v12, Lcom/kousei/framework/l6;->f:Lcom/kousei/framework/u;

    .line 77
    .line 78
    const-string v13, "SHA-512(256)"

    .line 79
    .line 80
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 81
    .line 82
    .line 83
    sget-object v12, Lcom/kousei/framework/oa;->b:Lcom/kousei/framework/u;

    .line 84
    .line 85
    const-string v13, "RIPEMD-128"

    .line 86
    .line 87
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 88
    .line 89
    .line 90
    sget-object v12, Lcom/kousei/framework/oa;->a:Lcom/kousei/framework/u;

    .line 91
    .line 92
    const-string v14, "RIPEMD-160"

    .line 93
    .line 94
    invoke-virtual {v0, v12, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 95
    .line 96
    .line 97
    sget-object v12, Lcom/kousei/framework/oa;->c:Lcom/kousei/framework/u;

    .line 98
    .line 99
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 100
    .line 101
    .line 102
    sget-object v12, Lcom/kousei/framework/g5;->b:Lcom/kousei/framework/u;

    .line 103
    .line 104
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 105
    .line 106
    .line 107
    sget-object v12, Lcom/kousei/framework/g5;->a:Lcom/kousei/framework/u;

    .line 108
    .line 109
    invoke-virtual {v0, v12, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 110
    .line 111
    .line 112
    sget-object v12, Lcom/kousei/framework/s1;->a:Lcom/kousei/framework/u;

    .line 113
    .line 114
    const-string v13, "GOST3411"

    .line 115
    .line 116
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 117
    .line 118
    .line 119
    sget-object v12, Lcom/kousei/framework/s4;->a:Lcom/kousei/framework/u;

    .line 120
    .line 121
    const-string v13, "Tiger"

    .line 122
    .line 123
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 124
    .line 125
    .line 126
    sget-object v12, Lcom/kousei/framework/g5;->c:Lcom/kousei/framework/u;

    .line 127
    .line 128
    const-string v13, "Whirlpool"

    .line 129
    .line 130
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 131
    .line 132
    .line 133
    sget-object v12, Lcom/kousei/framework/l6;->g:Lcom/kousei/framework/u;

    .line 134
    .line 135
    const-string v13, "SHA3-224"

    .line 136
    .line 137
    invoke-virtual {v0, v12, v13}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 138
    .line 139
    .line 140
    sget-object v14, Lcom/kousei/framework/l6;->h:Lcom/kousei/framework/u;

    .line 141
    .line 142
    const-string v15, "SHA3-256"

    .line 143
    .line 144
    invoke-virtual {v0, v14, v15}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 145
    .line 146
    .line 147
    move-object/from16 v16, v15

    .line 148
    .line 149
    sget-object v15, Lcom/kousei/framework/l6;->i:Lcom/kousei/framework/u;

    .line 150
    .line 151
    move-object/from16 v17, v14

    .line 152
    .line 153
    const-string v14, "SHA3-384"

    .line 154
    .line 155
    invoke-virtual {v0, v15, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 156
    .line 157
    .line 158
    move-object/from16 v18, v14

    .line 159
    .line 160
    sget-object v14, Lcom/kousei/framework/l6;->j:Lcom/kousei/framework/u;

    .line 161
    .line 162
    move-object/from16 v19, v15

    .line 163
    .line 164
    const-string v15, "SHA3-512"

    .line 165
    .line 166
    invoke-virtual {v0, v14, v15}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 167
    .line 168
    .line 169
    move-object/from16 v20, v15

    .line 170
    .line 171
    sget-object v15, Lcom/kousei/framework/l6;->k:Lcom/kousei/framework/u;

    .line 172
    .line 173
    move-object/from16 v21, v14

    .line 174
    .line 175
    const-string v14, "SHAKE128"

    .line 176
    .line 177
    invoke-virtual {v0, v15, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 178
    .line 179
    .line 180
    sget-object v14, Lcom/kousei/framework/l6;->l:Lcom/kousei/framework/u;

    .line 181
    .line 182
    const-string v15, "SHAKE256"

    .line 183
    .line 184
    invoke-virtual {v0, v14, v15}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 185
    .line 186
    .line 187
    sget-object v14, Lcom/kousei/framework/r4;->d:Lcom/kousei/framework/u;

    .line 188
    .line 189
    const-string v15, "SM3"

    .line 190
    .line 191
    invoke-virtual {v0, v14, v15}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 192
    .line 193
    .line 194
    sget-object v14, Lcom/kousei/framework/i6;->b:Lcom/kousei/framework/u;

    .line 195
    .line 196
    const-string v15, "BLAKE3-256"

    .line 197
    .line 198
    invoke-virtual {v0, v14, v15}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 199
    .line 200
    .line 201
    new-instance v0, Lcom/kousei/framework/j0;

    .line 202
    .line 203
    move-object/from16 v22, v15

    .line 204
    .line 205
    sget-object v15, Lcom/kousei/framework/l2;->a:Lcom/kousei/framework/l2;

    .line 206
    .line 207
    invoke-direct {v0, v2, v15}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V

    .line 208
    .line 209
    .line 210
    invoke-virtual {v1, v3, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 211
    .line 212
    .line 213
    new-instance v0, Lcom/kousei/framework/j0;

    .line 214
    .line 215
    invoke-direct {v0, v4}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 216
    .line 217
    .line 218
    invoke-virtual {v1, v5, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 219
    .line 220
    .line 221
    new-instance v0, Lcom/kousei/framework/j0;

    .line 222
    .line 223
    invoke-direct {v0, v4}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 224
    .line 225
    .line 226
    const-string v2, "SHA224"

    .line 227
    .line 228
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 229
    .line 230
    .line 231
    new-instance v0, Lcom/kousei/framework/j0;

    .line 232
    .line 233
    invoke-direct {v0, v6}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 234
    .line 235
    .line 236
    invoke-virtual {v1, v7, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 237
    .line 238
    .line 239
    new-instance v0, Lcom/kousei/framework/j0;

    .line 240
    .line 241
    invoke-direct {v0, v6}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 242
    .line 243
    .line 244
    const-string v2, "SHA256"

    .line 245
    .line 246
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 247
    .line 248
    .line 249
    new-instance v0, Lcom/kousei/framework/j0;

    .line 250
    .line 251
    invoke-direct {v0, v8}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 252
    .line 253
    .line 254
    invoke-virtual {v1, v9, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 255
    .line 256
    .line 257
    new-instance v0, Lcom/kousei/framework/j0;

    .line 258
    .line 259
    invoke-direct {v0, v8}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 260
    .line 261
    .line 262
    const-string v2, "SHA384"

    .line 263
    .line 264
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 265
    .line 266
    .line 267
    new-instance v0, Lcom/kousei/framework/j0;

    .line 268
    .line 269
    invoke-direct {v0, v10}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 270
    .line 271
    .line 272
    invoke-virtual {v1, v11, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 273
    .line 274
    .line 275
    new-instance v0, Lcom/kousei/framework/j0;

    .line 276
    .line 277
    invoke-direct {v0, v10}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 278
    .line 279
    .line 280
    const-string v2, "SHA512"

    .line 281
    .line 282
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 283
    .line 284
    .line 285
    new-instance v0, Lcom/kousei/framework/j0;

    .line 286
    .line 287
    invoke-direct {v0, v12}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 288
    .line 289
    .line 290
    invoke-virtual {v1, v13, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 291
    .line 292
    .line 293
    new-instance v0, Lcom/kousei/framework/j0;

    .line 294
    .line 295
    move-object/from16 v2, v17

    .line 296
    .line 297
    invoke-direct {v0, v2}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 298
    .line 299
    .line 300
    move-object/from16 v2, v16

    .line 301
    .line 302
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 303
    .line 304
    .line 305
    new-instance v0, Lcom/kousei/framework/j0;

    .line 306
    .line 307
    move-object/from16 v2, v19

    .line 308
    .line 309
    invoke-direct {v0, v2}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 310
    .line 311
    .line 312
    move-object/from16 v2, v18

    .line 313
    .line 314
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 315
    .line 316
    .line 317
    new-instance v0, Lcom/kousei/framework/j0;

    .line 318
    .line 319
    move-object/from16 v2, v21

    .line 320
    .line 321
    invoke-direct {v0, v2}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 322
    .line 323
    .line 324
    move-object/from16 v2, v20

    .line 325
    .line 326
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 327
    .line 328
    .line 329
    new-instance v0, Lcom/kousei/framework/j0;

    .line 330
    .line 331
    invoke-direct {v0, v14}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;)V

    .line 332
    .line 333
    .line 334
    move-object/from16 v2, v22

    .line 335
    .line 336
    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 337
    .line 338
    .line 339
    return-void
.end method
