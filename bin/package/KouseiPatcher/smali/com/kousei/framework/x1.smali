.class public abstract Lcom/kousei/framework/x1;
.super Ljava/lang/Object;


# static fields
.field public static final a:Lcom/kousei/framework/w1;

.field public static final b:Ljava/util/concurrent/atomic/AtomicReference;

.field public static final c:Ljava/util/concurrent/atomic/AtomicReference;


# direct methods
.method static constructor <clinit>()V
    .registers 14

    .line 1
    const-class v0, Lcom/kousei/framework/x1;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    invoke-static {v0}, Ljava/util/logging/Logger;->getLogger(Ljava/lang/String;)Ljava/util/logging/Logger;

    .line 8
    .line 9
    .line 10
    new-instance v0, Lcom/kousei/framework/u1;

    .line 11
    .line 12
    const-string v1, "globalConfig"

    .line 13
    .line 14
    invoke-direct {v0, v1}, Lcom/kousei/framework/u1;-><init>(Ljava/lang/String;)V

    .line 15
    .line 16
    .line 17
    new-instance v0, Lcom/kousei/framework/u1;

    .line 18
    .line 19
    const-string v1, "threadLocalConfig"

    .line 20
    .line 21
    invoke-direct {v0, v1}, Lcom/kousei/framework/u1;-><init>(Ljava/lang/String;)V

    .line 22
    .line 23
    .line 24
    new-instance v0, Lcom/kousei/framework/u1;

    .line 25
    .line 26
    const-string v1, "defaultRandomConfig"

    .line 27
    .line 28
    invoke-direct {v0, v1}, Lcom/kousei/framework/u1;-><init>(Ljava/lang/String;)V

    .line 29
    .line 30
    .line 31
    new-instance v0, Lcom/kousei/framework/u1;

    .line 32
    .line 33
    const-string v1, "constraints"

    .line 34
    .line 35
    invoke-direct {v0, v1}, Lcom/kousei/framework/u1;-><init>(Ljava/lang/String;)V

    .line 36
    .line 37
    .line 38
    new-instance v0, Ljava/lang/ThreadLocal;

    .line 39
    .line 40
    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V

    .line 41
    .line 42
    .line 43
    new-instance v1, Ljava/util/HashMap;

    .line 44
    .line 45
    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    .line 46
    .line 47
    .line 48
    invoke-static {v1}, Ljava/util/Collections;->synchronizedMap(Ljava/util/Map;)Ljava/util/Map;

    .line 49
    .line 50
    .line 51
    move-result-object v1

    .line 52
    new-instance v2, Lcom/kousei/framework/w1;

    .line 53
    .line 54
    invoke-direct {v2}, Lcom/kousei/framework/w1;-><init>()V

    .line 55
    .line 56
    .line 57
    sput-object v2, Lcom/kousei/framework/x1;->a:Lcom/kousei/framework/w1;

    .line 58
    .line 59
    new-instance v2, Lcom/kousei/framework/v1;

    .line 60
    .line 61
    invoke-direct {v2}, Ljava/lang/Object;-><init>()V

    .line 62
    .line 63
    .line 64
    new-instance v3, Ljava/util/concurrent/atomic/AtomicReference;

    .line 65
    .line 66
    invoke-direct {v3}, Ljava/util/concurrent/atomic/AtomicReference;-><init>()V

    .line 67
    .line 68
    .line 69
    sput-object v3, Lcom/kousei/framework/x1;->b:Ljava/util/concurrent/atomic/AtomicReference;

    .line 70
    .line 71
    new-instance v3, Ljava/util/concurrent/atomic/AtomicReference;

    .line 72
    .line 73
    invoke-direct {v3}, Ljava/util/concurrent/atomic/AtomicReference;-><init>()V

    .line 74
    .line 75
    .line 76
    sput-object v3, Lcom/kousei/framework/x1;->c:Ljava/util/concurrent/atomic/AtomicReference;

    .line 77
    .line 78
    new-instance v4, Lcom/kousei/framework/d3;

    .line 79
    .line 80
    new-instance v5, Ljava/math/BigInteger;

    .line 81
    .line 82
    const-string v6, "fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17"

    .line 83
    .line 84
    const/16 v7, 0x10

    .line 85
    .line 86
    invoke-direct {v5, v6, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 87
    .line 88
    .line 89
    new-instance v6, Ljava/math/BigInteger;

    .line 90
    .line 91
    const-string v8, "962eddcc369cba8ebb260ee6b6a126d9346e38c5"

    .line 92
    .line 93
    invoke-direct {v6, v8, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 94
    .line 95
    .line 96
    new-instance v8, Ljava/math/BigInteger;

    .line 97
    .line 98
    const-string v9, "678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4"

    .line 99
    .line 100
    invoke-direct {v8, v9, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 101
    .line 102
    .line 103
    new-instance v9, Lcom/kousei/framework/e3;

    .line 104
    .line 105
    const-string v10, "b869c82b35d70e1b1ff91b28e37a62ecdc34409b"

    .line 106
    .line 107
    invoke-static {v10}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 108
    .line 109
    .line 110
    move-result-object v10

    .line 111
    const/16 v11, 0x7b

    .line 112
    .line 113
    invoke-direct {v9, v11, v10}, Lcom/kousei/framework/e3;-><init>(I[B)V

    .line 114
    .line 115
    .line 116
    invoke-direct {v4, v5, v6, v8, v9}, Lcom/kousei/framework/d3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Lcom/kousei/framework/e3;)V

    .line 117
    .line 118
    .line 119
    new-instance v5, Lcom/kousei/framework/d3;

    .line 120
    .line 121
    new-instance v6, Ljava/math/BigInteger;

    .line 122
    .line 123
    const-string v8, "e9e642599d355f37c97ffd3567120b8e25c9cd43e927b3a9670fbec5d890141922d2c3b3ad2480093799869d1e846aab49fab0ad26d2ce6a22219d470bce7d777d4a21fbe9c270b57f607002f3cef8393694cf45ee3688c11a8c56ab127a3daf"

    .line 124
    .line 125
    invoke-direct {v6, v8, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 126
    .line 127
    .line 128
    new-instance v8, Ljava/math/BigInteger;

    .line 129
    .line 130
    const-string v9, "9cdbd84c9f1ac2f38d0f80f42ab952e7338bf511"

    .line 131
    .line 132
    invoke-direct {v8, v9, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 133
    .line 134
    .line 135
    new-instance v9, Ljava/math/BigInteger;

    .line 136
    .line 137
    const-string v10, "30470ad5a005fb14ce2d9dcd87e38bc7d1b1c5facbaecbe95f190aa7a31d23c4dbbcbe06174544401a5b2c020965d8c2bd2171d3668445771f74ba084d2029d83c1c158547f3a9f1a2715be23d51ae4d3e5a1f6a7064f316933a346d3f529252"

    .line 138
    .line 139
    invoke-direct {v9, v10, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 140
    .line 141
    .line 142
    new-instance v10, Lcom/kousei/framework/e3;

    .line 143
    .line 144
    const-string v11, "77d0f8c4dad15eb8c4f2f8d6726cefd96d5bb399"

    .line 145
    .line 146
    invoke-static {v11}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 147
    .line 148
    .line 149
    move-result-object v11

    .line 150
    const/16 v12, 0x107

    .line 151
    .line 152
    invoke-direct {v10, v12, v11}, Lcom/kousei/framework/e3;-><init>(I[B)V

    .line 153
    .line 154
    .line 155
    invoke-direct {v5, v6, v8, v9, v10}, Lcom/kousei/framework/d3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Lcom/kousei/framework/e3;)V

    .line 156
    .line 157
    .line 158
    new-instance v6, Lcom/kousei/framework/d3;

    .line 159
    .line 160
    new-instance v8, Ljava/math/BigInteger;

    .line 161
    .line 162
    const-string v9, "fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c7"

    .line 163
    .line 164
    invoke-direct {v8, v9, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 165
    .line 166
    .line 167
    new-instance v9, Ljava/math/BigInteger;

    .line 168
    .line 169
    const-string v10, "9760508f15230bccb292b982a2eb840bf0581cf5"

    .line 170
    .line 171
    invoke-direct {v9, v10, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 172
    .line 173
    .line 174
    new-instance v10, Ljava/math/BigInteger;

    .line 175
    .line 176
    const-string v11, "f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a"

    .line 177
    .line 178
    invoke-direct {v10, v11, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 179
    .line 180
    .line 181
    new-instance v11, Lcom/kousei/framework/e3;

    .line 182
    .line 183
    const-string v12, "8d5155894229d5e689ee01e6018a237e2cae64cd"

    .line 184
    .line 185
    invoke-static {v12}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 186
    .line 187
    .line 188
    move-result-object v12

    .line 189
    const/16 v13, 0x5c

    .line 190
    .line 191
    invoke-direct {v11, v13, v12}, Lcom/kousei/framework/e3;-><init>(I[B)V

    .line 192
    .line 193
    .line 194
    invoke-direct {v6, v8, v9, v10, v11}, Lcom/kousei/framework/d3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Lcom/kousei/framework/e3;)V

    .line 195
    .line 196
    .line 197
    new-instance v8, Lcom/kousei/framework/d3;

    .line 198
    .line 199
    new-instance v9, Ljava/math/BigInteger;

    .line 200
    .line 201
    const-string v10, "95475cf5d93e596c3fcd1d902add02f427f5f3c7210313bb45fb4d5bb2e5fe1cbd678cd4bbdd84c9836be1f31c0777725aeb6c2fc38b85f48076fa76bcd8146cc89a6fb2f706dd719898c2083dc8d896f84062e2c9c94d137b054a8d8096adb8d51952398eeca852a0af12df83e475aa65d4ec0c38a9560d5661186ff98b9fc9eb60eee8b030376b236bc73be3acdbd74fd61c1d2475fa3077b8f080467881ff7e1ca56fee066d79506ade51edbb5443a563927dbc4ba520086746175c8885925ebc64c6147906773496990cb714ec667304e261faee33b3cbdf008e0c3fa90650d97d3909c9275bf4ac86ffcb3d03e6dfc8ada5934242dd6d3bcca2a406cb0b"

    .line 202
    .line 203
    invoke-direct {v9, v10, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 204
    .line 205
    .line 206
    new-instance v10, Ljava/math/BigInteger;

    .line 207
    .line 208
    const-string v11, "f8183668ba5fc5bb06b5981e6d8b795d30b8978d43ca0ec572e37e09939a9773"

    .line 209
    .line 210
    invoke-direct {v10, v11, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 211
    .line 212
    .line 213
    new-instance v11, Ljava/math/BigInteger;

    .line 214
    .line 215
    const-string v12, "42debb9da5b3d88cc956e08787ec3f3a09bba5f48b889a74aaf53174aa0fbe7e3c5b8fcd7a53bef563b0e98560328960a9517f4014d3325fc7962bf1e049370d76d1314a76137e792f3f0db859d095e4a5b932024f079ecf2ef09c797452b0770e1350782ed57ddf794979dcef23cb96f183061965c4ebc93c9c71c56b925955a75f94cccf1449ac43d586d0beee43251b0b2287349d68de0d144403f13e802f4146d882e057af19b6f6275c6676c8fa0e3ca2713a3257fd1b27d0639f695e347d8d1cf9ac819a26ca9b04cb0eb9b7b035988d15bbac65212a55239cfc7e58fae38d7250ab9991ffbc97134025fe8ce04c4399ad96569be91a546f4978693c7a"

    .line 216
    .line 217
    invoke-direct {v11, v12, v7}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 218
    .line 219
    .line 220
    new-instance v7, Lcom/kousei/framework/e3;

    .line 221
    .line 222
    const-string v12, "b0b4417601b59cbc9d8ac8f935cadaec4f5fbb2f23785609ae466748d9b5a536"

    .line 223
    .line 224
    invoke-static {v12}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 225
    .line 226
    .line 227
    move-result-object v12

    .line 228
    const/16 v13, 0x1f1

    .line 229
    .line 230
    invoke-direct {v7, v13, v12}, Lcom/kousei/framework/e3;-><init>(I[B)V

    .line 231
    .line 232
    .line 233
    invoke-direct {v8, v9, v10, v11, v7}, Lcom/kousei/framework/d3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Lcom/kousei/framework/e3;)V

    .line 234
    .line 235
    .line 236
    filled-new-array {v4, v5, v6, v8}, [Lcom/kousei/framework/d3;

    .line 237
    .line 238
    .line 239
    move-result-object v7

    .line 240
    const/4 v9, 0x0

    .line 241
    aget-object v10, v7, v9

    .line 242
    .line 243
    invoke-virtual {v10}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 244
    .line 245
    .line 246
    move-result-object v10

    .line 247
    const-class v11, Lcom/kousei/framework/d3;

    .line 248
    .line 249
    invoke-virtual {v11, v10}, Ljava/lang/Class;->isAssignableFrom(Ljava/lang/Class;)Z

    .line 250
    .line 251
    .line 252
    move-result v10

    .line 253
    const-string v11, "Bad property value passed"

    .line 254
    .line 255
    if-eqz v10, :cond_15d

    .line 256
    .line 257
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 258
    .line 259
    .line 260
    move-result-object v10

    .line 261
    check-cast v10, Ljava/util/Map;

    .line 262
    .line 263
    if-nez v10, :cond_110

    .line 264
    .line 265
    new-instance v10, Ljava/util/HashMap;

    .line 266
    .line 267
    invoke-direct {v10}, Ljava/util/HashMap;-><init>()V

    .line 268
    .line 269
    .line 270
    invoke-virtual {v0, v10}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 271
    .line 272
    .line 273
    :cond_110
    const-string v12, "dsaDefaultParams"

    .line 274
    .line 275
    invoke-interface {v10, v12, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 276
    .line 277
    .line 278
    invoke-interface {v1, v12, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 279
    .line 280
    .line 281
    invoke-static {v4}, Lcom/kousei/framework/x1;->b(Lcom/kousei/framework/d3;)Lcom/kousei/framework/y2;

    .line 282
    .line 283
    .line 284
    move-result-object v4

    .line 285
    invoke-static {v5}, Lcom/kousei/framework/x1;->b(Lcom/kousei/framework/d3;)Lcom/kousei/framework/y2;

    .line 286
    .line 287
    .line 288
    move-result-object v5

    .line 289
    invoke-static {v6}, Lcom/kousei/framework/x1;->b(Lcom/kousei/framework/d3;)Lcom/kousei/framework/y2;

    .line 290
    .line 291
    .line 292
    move-result-object v6

    .line 293
    invoke-static {v8}, Lcom/kousei/framework/x1;->b(Lcom/kousei/framework/d3;)Lcom/kousei/framework/y2;

    .line 294
    .line 295
    .line 296
    move-result-object v7

    .line 297
    filled-new-array {v4, v5, v6, v7}, [Lcom/kousei/framework/y2;

    .line 298
    .line 299
    .line 300
    move-result-object v4

    .line 301
    aget-object v5, v4, v9

    .line 302
    .line 303
    invoke-virtual {v5}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 304
    .line 305
    .line 306
    move-result-object v5

    .line 307
    const-class v6, Lcom/kousei/framework/y2;

    .line 308
    .line 309
    invoke-virtual {v6, v5}, Ljava/lang/Class;->isAssignableFrom(Ljava/lang/Class;)Z

    .line 310
    .line 311
    .line 312
    move-result v5

    .line 313
    if-eqz v5, :cond_159

    .line 314
    .line 315
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 316
    .line 317
    .line 318
    move-result-object v5

    .line 319
    check-cast v5, Ljava/util/Map;

    .line 320
    .line 321
    if-nez v5, :cond_14a

    .line 322
    .line 323
    new-instance v5, Ljava/util/HashMap;

    .line 324
    .line 325
    invoke-direct {v5}, Ljava/util/HashMap;-><init>()V

    .line 326
    .line 327
    .line 328
    invoke-virtual {v0, v5}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 329
    .line 330
    .line 331
    :cond_14a
    const-string v0, "dhDefaultParams"

    .line 332
    .line 333
    invoke-interface {v5, v0, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 334
    .line 335
    .line 336
    invoke-interface {v1, v0, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 337
    .line 338
    .line 339
    invoke-virtual {v3, v2}, Ljava/util/concurrent/atomic/AtomicReference;->set(Ljava/lang/Object;)V

    .line 340
    .line 341
    .line 342
    invoke-virtual {v3}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 343
    .line 344
    .line 345
    return-void

    .line 346
    :cond_159
    invoke-static {v11}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 347
    .line 348
    .line 349
    return-void

    .line 350
    :cond_15d
    invoke-static {v11}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 351
    .line 352
    .line 353
    return-void
.end method

.method public static a()Ljava/security/SecureRandom;
    .registers 3

    .line 1
    :cond_0
    sget-object v0, Lcom/kousei/framework/x1;->b:Ljava/util/concurrent/atomic/AtomicReference;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    sget-object v2, Lcom/kousei/framework/x1;->a:Lcom/kousei/framework/w1;

    .line 5
    .line 6
    invoke-virtual {v0, v1, v2}, Ljava/util/concurrent/atomic/AtomicReference;->compareAndSet(Ljava/lang/Object;Ljava/lang/Object;)Z

    .line 7
    .line 8
    .line 9
    move-result v1

    .line 10
    if-eqz v1, :cond_c

    .line 11
    .line 12
    goto :goto_12

    .line 13
    :cond_c
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 14
    .line 15
    .line 16
    move-result-object v1

    .line 17
    if-eqz v1, :cond_0

    .line 18
    .line 19
    :goto_12
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 20
    .line 21
    .line 22
    move-result-object v0

    .line 23
    check-cast v0, Lcom/kousei/framework/w1;

    .line 24
    .line 25
    iget-object v0, v0, Lcom/kousei/framework/w1;->a:Ljava/lang/ThreadLocal;

    .line 26
    .line 27
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 28
    .line 29
    .line 30
    move-result-object v1

    .line 31
    if-nez v1, :cond_28

    .line 32
    .line 33
    new-instance v1, Ljava/security/SecureRandom;

    .line 34
    .line 35
    invoke-direct {v1}, Ljava/security/SecureRandom;-><init>()V

    .line 36
    .line 37
    .line 38
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 39
    .line 40
    .line 41
    :cond_28
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 42
    .line 43
    .line 44
    move-result-object v0

    .line 45
    check-cast v0, Ljava/security/SecureRandom;

    .line 46
    .line 47
    return-object v0
.end method

.method public static b(Lcom/kousei/framework/d3;)Lcom/kousei/framework/y2;
    .registers 6

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/d3;->c:Ljava/math/BigInteger;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/d3;->d:Lcom/kousei/framework/e3;

    .line 4
    .line 5
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    const/16 v3, 0x400

    .line 10
    .line 11
    if-le v2, v3, :cond_24

    .line 12
    .line 13
    const/16 v3, 0x800

    .line 14
    .line 15
    if-gt v2, v3, :cond_13

    .line 16
    .line 17
    const/16 v2, 0xe0

    .line 18
    .line 19
    goto :goto_26

    .line 20
    :cond_13
    const/16 v3, 0xc00

    .line 21
    .line 22
    if-gt v2, v3, :cond_1a

    .line 23
    .line 24
    const/16 v2, 0x100

    .line 25
    .line 26
    goto :goto_26

    .line 27
    :cond_1a
    const/16 v3, 0x1e00

    .line 28
    .line 29
    if-gt v2, v3, :cond_21

    .line 30
    .line 31
    const/16 v2, 0x180

    .line 32
    .line 33
    goto :goto_26

    .line 34
    :cond_21
    const/16 v2, 0x200

    .line 35
    .line 36
    goto :goto_26

    .line 37
    :cond_24
    const/16 v2, 0xa0

    .line 38
    .line 39
    :goto_26
    new-instance v3, Lcom/kousei/framework/y2;

    .line 40
    .line 41
    iget-object v4, p0, Lcom/kousei/framework/d3;->a:Ljava/math/BigInteger;

    .line 42
    .line 43
    iget-object p0, p0, Lcom/kousei/framework/d3;->b:Ljava/math/BigInteger;

    .line 44
    .line 45
    iget-object v1, v1, Lcom/kousei/framework/e3;->a:[B

    .line 46
    .line 47
    invoke-static {v1}, Lcom/kousei/framework/h0;->J([B)[B

    .line 48
    .line 49
    .line 50
    move-result-object v1

    .line 51
    invoke-static {v1}, Lcom/kousei/framework/h0;->J([B)[B

    .line 52
    .line 53
    .line 54
    invoke-direct {v3}, Ljava/lang/Object;-><init>()V

    .line 55
    .line 56
    .line 57
    invoke-virtual {v0}, Ljava/math/BigInteger;->bitLength()I

    .line 58
    .line 59
    .line 60
    move-result v1

    .line 61
    if-le v2, v1, :cond_4e

    .line 62
    .line 63
    const-string v1, "org.bouncycastle.dh.allow_unsafe_p_value"

    .line 64
    .line 65
    invoke-static {v1}, Lcom/kousei/framework/o7;->c(Ljava/lang/String;)Z

    .line 66
    .line 67
    .line 68
    move-result v1

    .line 69
    if-eqz v1, :cond_47

    .line 70
    .line 71
    goto :goto_4e

    .line 72
    :cond_47
    const-string p0, "unsafe p value so small specific l required"

    .line 73
    .line 74
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 75
    .line 76
    .line 77
    const/4 p0, 0x0

    .line 78
    return-object p0

    .line 79
    :cond_4e
    :goto_4e
    iput-object v4, v3, Lcom/kousei/framework/y2;->a:Ljava/math/BigInteger;

    .line 80
    .line 81
    iput-object v0, v3, Lcom/kousei/framework/y2;->b:Ljava/math/BigInteger;

    .line 82
    .line 83
    iput-object p0, v3, Lcom/kousei/framework/y2;->c:Ljava/math/BigInteger;

    .line 84
    .line 85
    return-object v3
.end method
