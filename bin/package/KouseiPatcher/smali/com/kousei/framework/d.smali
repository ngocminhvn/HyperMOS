.class public final Lcom/kousei/framework/d;
.super Ljava/lang/Object;


# instance fields
.field public final a:Ljava/lang/Class;

.field public final synthetic b:I


# direct methods
.method public constructor <init>(Ljava/lang/Class;I)V
    .registers 3

    .line 1
    iput p2, p0, Lcom/kousei/framework/d;->b:I

    .line 2
    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 4
    .line 5
    .line 6
    iput-object p1, p0, Lcom/kousei/framework/d;->a:Ljava/lang/Class;

    .line 7
    .line 8
    return-void
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/z;)V
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d;->a:Ljava/lang/Class;

    .line 2
    .line 3
    invoke-virtual {p0, p1}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    if-eqz p0, :cond_9

    .line 8
    .line 9
    return-void

    .line 10
    :cond_9
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 11
    .line 12
    .line 13
    move-result-object p0

    .line 14
    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    .line 15
    .line 16
    .line 17
    move-result-object p0

    .line 18
    const-string p1, "unexpected object: "

    .line 19
    .line 20
    invoke-virtual {p1, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 21
    .line 22
    .line 23
    move-result-object p0

    .line 24
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 25
    .line 26
    .line 27
    return-void
.end method

.method public final b([B)Lcom/kousei/framework/z;
    .registers 2

    .line 1
    invoke-static {p1}, Lcom/kousei/framework/z;->o([B)Lcom/kousei/framework/z;

    .line 2
    .line 3
    .line 4
    move-result-object p1

    .line 5
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d;->a(Lcom/kousei/framework/z;)V

    .line 6
    .line 7
    .line 8
    return-object p1
.end method

.method public c(Lcom/kousei/framework/c0;)Lcom/kousei/framework/z;
    .registers 3

    .line 1
    iget p0, p0, Lcom/kousei/framework/d;->b:I

    .line 2
    .line 3
    const-string v0, "unexpected implicit constructed encoding"

    .line 4
    .line 5
    sparse-switch p0, :sswitch_data_28

    .line 6
    .line 7
    .line 8
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 9
    .line 10
    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 11
    .line 12
    .line 13
    throw p0

    .line 14
    :sswitch_d
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->z()Lcom/kousei/framework/d0;

    .line 15
    .line 16
    .line 17
    move-result-object p0

    .line 18
    return-object p0

    .line 19
    :sswitch_12
    return-object p1

    .line 20
    :sswitch_13
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->y()Lcom/kousei/framework/v;

    .line 21
    .line 22
    .line 23
    move-result-object p0

    .line 24
    return-object p0

    .line 25
    :sswitch_18
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 26
    .line 27
    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 28
    .line 29
    .line 30
    throw p0

    .line 31
    :sswitch_1e
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->x()Lcom/kousei/framework/g2;

    .line 32
    .line 33
    .line 34
    move-result-object p0

    .line 35
    return-object p0

    .line 36
    :sswitch_23
    invoke-virtual {p1}, Lcom/kousei/framework/c0;->w()Lcom/kousei/framework/f;

    .line 37
    .line 38
    .line 39
    move-result-object p0

    .line 40
    return-object p0

    .line 41
    :sswitch_data_28
    .sparse-switch
        0x1 -> :sswitch_23
        0x4 -> :sswitch_1e
        0xc -> :sswitch_18
        0xe -> :sswitch_13
        0x11 -> :sswitch_12
        0x12 -> :sswitch_d
    .end sparse-switch
.end method

.method public final d(Lcom/kousei/framework/a1;Z)Lcom/kousei/framework/z;
    .registers 8

    .line 1
    invoke-static {p1}, Lcom/kousei/framework/h0;->H(Lcom/kousei/framework/a1;)V

    .line 2
    .line 3
    .line 4
    iget v0, p1, Lcom/kousei/framework/a1;->a:I

    .line 5
    .line 6
    iget-object v1, p1, Lcom/kousei/framework/a1;->d:Lcom/kousei/framework/j;

    .line 7
    .line 8
    const/4 v2, 0x0

    .line 9
    if-eqz p2, :cond_1f

    .line 10
    .line 11
    invoke-virtual {p1}, Lcom/kousei/framework/a1;->s()Z

    .line 12
    .line 13
    .line 14
    move-result p1

    .line 15
    if-eqz p1, :cond_19

    .line 16
    .line 17
    invoke-interface {v1}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 18
    .line 19
    .line 20
    move-result-object p1

    .line 21
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d;->a(Lcom/kousei/framework/z;)V

    .line 22
    .line 23
    .line 24
    goto/16 :goto_124

    .line 25
    .line 26
    :cond_19
    const-string p0, "object implicit - explicit expected."

    .line 27
    .line 28
    :goto_1b
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 29
    .line 30
    .line 31
    return-object v2

    .line 32
    :cond_1f
    const/4 p2, 0x1

    .line 33
    if-eq p2, v0, :cond_128

    .line 34
    .line 35
    invoke-interface {v1}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 36
    .line 37
    .line 38
    move-result-object v1

    .line 39
    const/4 v3, 0x3

    .line 40
    const/4 v4, 0x0

    .line 41
    if-eq v0, v3, :cond_105

    .line 42
    .line 43
    const/4 p1, 0x4

    .line 44
    if-eq v0, p1, :cond_33

    .line 45
    .line 46
    invoke-virtual {p0, v1}, Lcom/kousei/framework/d;->a(Lcom/kousei/framework/z;)V

    .line 47
    .line 48
    .line 49
    :pswitch_30
    move-object p1, v1

    .line 50
    goto/16 :goto_124

    .line 51
    .line 52
    :cond_33
    instance-of p1, v1, Lcom/kousei/framework/c0;

    .line 53
    .line 54
    if-eqz p1, :cond_3f

    .line 55
    .line 56
    check-cast v1, Lcom/kousei/framework/c0;

    .line 57
    .line 58
    invoke-virtual {p0, v1}, Lcom/kousei/framework/d;->c(Lcom/kousei/framework/c0;)Lcom/kousei/framework/z;

    .line 59
    .line 60
    .line 61
    move-result-object p1

    .line 62
    goto/16 :goto_124

    .line 63
    .line 64
    :cond_3f
    check-cast v1, Lcom/kousei/framework/n2;

    .line 65
    .line 66
    iget p1, p0, Lcom/kousei/framework/d;->b:I

    .line 67
    .line 68
    packed-switch p1, :pswitch_data_12c

    .line 69
    .line 70
    .line 71
    :pswitch_46
    new-instance p0, Ljava/lang/IllegalStateException;

    .line 72
    .line 73
    const-string p1, "unexpected implicit primitive encoding"

    .line 74
    .line 75
    invoke-direct {p0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 76
    .line 77
    .line 78
    throw p0

    .line 79
    :pswitch_4e
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 80
    .line 81
    new-instance p2, Lcom/kousei/framework/x2;

    .line 82
    .line 83
    invoke-direct {p2, p1}, Lcom/kousei/framework/x2;-><init>([B)V

    .line 84
    .line 85
    .line 86
    :goto_55
    move-object p1, p2

    .line 87
    goto/16 :goto_124

    .line 88
    .line 89
    :pswitch_58
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 90
    .line 91
    new-instance p2, Lcom/kousei/framework/w2;

    .line 92
    .line 93
    invoke-direct {p2, p1}, Lcom/kousei/framework/w2;-><init>([B)V

    .line 94
    .line 95
    .line 96
    goto :goto_55

    .line 97
    :pswitch_60
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 98
    .line 99
    new-instance p2, Lcom/kousei/framework/v2;

    .line 100
    .line 101
    invoke-direct {p2, p1}, Lcom/kousei/framework/v2;-><init>([B)V

    .line 102
    .line 103
    .line 104
    goto :goto_55

    .line 105
    :pswitch_68
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 106
    .line 107
    new-instance p2, Lcom/kousei/framework/u2;

    .line 108
    .line 109
    invoke-direct {p2, p1}, Lcom/kousei/framework/u2;-><init>([B)V

    .line 110
    .line 111
    .line 112
    goto :goto_55

    .line 113
    :pswitch_70
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 114
    .line 115
    new-instance p2, Lcom/kousei/framework/g0;

    .line 116
    .line 117
    invoke-direct {p2, p1}, Lcom/kousei/framework/g0;-><init>([B)V

    .line 118
    .line 119
    .line 120
    goto :goto_55

    .line 121
    :pswitch_78
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 122
    .line 123
    new-instance p2, Lcom/kousei/framework/s2;

    .line 124
    .line 125
    invoke-direct {p2, p1}, Lcom/kousei/framework/s2;-><init>([B)V

    .line 126
    .line 127
    .line 128
    goto :goto_55

    .line 129
    :pswitch_80
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 130
    .line 131
    invoke-static {p1, v4}, Lcom/kousei/framework/a0;->r([BZ)Lcom/kousei/framework/a0;

    .line 132
    .line 133
    .line 134
    move-result-object p1

    .line 135
    goto/16 :goto_124

    .line 136
    .line 137
    :pswitch_88
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 138
    .line 139
    new-instance p2, Lcom/kousei/framework/p2;

    .line 140
    .line 141
    invoke-direct {p2, p1}, Lcom/kousei/framework/p2;-><init>([B)V

    .line 142
    .line 143
    .line 144
    goto :goto_55

    .line 145
    :pswitch_90
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 146
    .line 147
    invoke-static {p1, v4}, Lcom/kousei/framework/u;->t([BZ)Lcom/kousei/framework/u;

    .line 148
    .line 149
    .line 150
    move-result-object p1

    .line 151
    goto/16 :goto_124

    .line 152
    .line 153
    :pswitch_98
    new-instance p1, Lcom/kousei/framework/s;

    .line 154
    .line 155
    iget-object p2, v1, Lcom/kousei/framework/v;->a:[B

    .line 156
    .line 157
    new-instance v0, Lcom/kousei/framework/j2;

    .line 158
    .line 159
    invoke-direct {v0, p2}, Lcom/kousei/framework/j2;-><init>([B)V

    .line 160
    .line 161
    .line 162
    invoke-direct {p1, v0}, Lcom/kousei/framework/s;-><init>(Lcom/kousei/framework/j2;)V

    .line 163
    .line 164
    .line 165
    goto/16 :goto_124

    .line 166
    .line 167
    :pswitch_a6
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 168
    .line 169
    new-instance p2, Lcom/kousei/framework/m2;

    .line 170
    .line 171
    invoke-direct {p2, p1}, Lcom/kousei/framework/m2;-><init>([B)V

    .line 172
    .line 173
    .line 174
    goto :goto_55

    .line 175
    :pswitch_ae
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 176
    .line 177
    array-length p1, p1

    .line 178
    if-nez p1, :cond_b6

    .line 179
    .line 180
    sget-object v2, Lcom/kousei/framework/l2;->a:Lcom/kousei/framework/l2;

    .line 181
    .line 182
    goto :goto_bb

    .line 183
    :cond_b6
    const-string p1, "malformed NULL encoding encountered"

    .line 184
    .line 185
    invoke-static {p1}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 186
    .line 187
    .line 188
    :goto_bb
    move-object p1, v2

    .line 189
    goto :goto_124

    .line 190
    :pswitch_bd
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 191
    .line 192
    new-instance p2, Lcom/kousei/framework/p;

    .line 193
    .line 194
    invoke-direct {p2, p1}, Lcom/kousei/framework/p;-><init>([B)V

    .line 195
    .line 196
    .line 197
    goto :goto_55

    .line 198
    :pswitch_c5
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 199
    .line 200
    new-instance p2, Lcom/kousei/framework/k2;

    .line 201
    .line 202
    invoke-direct {p2, p1}, Lcom/kousei/framework/k2;-><init>([B)V

    .line 203
    .line 204
    .line 205
    goto :goto_55

    .line 206
    :pswitch_cd
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 207
    .line 208
    new-instance p2, Lcom/kousei/framework/j2;

    .line 209
    .line 210
    invoke-direct {p2, p1}, Lcom/kousei/framework/j2;-><init>([B)V

    .line 211
    .line 212
    .line 213
    goto :goto_55

    .line 214
    :pswitch_d5
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 215
    .line 216
    new-instance p2, Lcom/kousei/framework/n;

    .line 217
    .line 218
    invoke-direct {p2, p1}, Lcom/kousei/framework/n;-><init>([B)V

    .line 219
    .line 220
    .line 221
    goto/16 :goto_55

    .line 222
    .line 223
    :pswitch_de
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 224
    .line 225
    new-instance p2, Lcom/kousei/framework/h2;

    .line 226
    .line 227
    invoke-direct {p2, p1}, Lcom/kousei/framework/h2;-><init>([B)V

    .line 228
    .line 229
    .line 230
    goto/16 :goto_55

    .line 231
    .line 232
    :pswitch_e7
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 233
    .line 234
    invoke-static {p1, v4}, Lcom/kousei/framework/l;->r([BZ)Lcom/kousei/framework/l;

    .line 235
    .line 236
    .line 237
    move-result-object p1

    .line 238
    goto :goto_124

    .line 239
    :pswitch_ee
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 240
    .line 241
    invoke-static {p1}, Lcom/kousei/framework/h;->r([B)Lcom/kousei/framework/h;

    .line 242
    .line 243
    .line 244
    move-result-object p1

    .line 245
    goto :goto_124

    .line 246
    :pswitch_f5
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 247
    .line 248
    invoke-static {p1}, Lcom/kousei/framework/f;->r([B)Lcom/kousei/framework/f;

    .line 249
    .line 250
    .line 251
    move-result-object p1

    .line 252
    goto :goto_124

    .line 253
    :pswitch_fc
    iget-object p1, v1, Lcom/kousei/framework/v;->a:[B

    .line 254
    .line 255
    new-instance p2, Lcom/kousei/framework/e2;

    .line 256
    .line 257
    invoke-direct {p2, p1}, Lcom/kousei/framework/e2;-><init>([B)V

    .line 258
    .line 259
    .line 260
    goto/16 :goto_55

    .line 261
    .line 262
    :cond_105
    iget p1, p1, Lcom/kousei/framework/a1;->e:I

    .line 263
    .line 264
    const/4 v0, -0x1

    .line 265
    packed-switch p1, :pswitch_data_162

    .line 266
    .line 267
    .line 268
    new-instance p1, Lcom/kousei/framework/q2;

    .line 269
    .line 270
    invoke-direct {p1, p2, v1}, Lcom/kousei/framework/q2;-><init>(ILcom/kousei/framework/z;)V

    .line 271
    .line 272
    .line 273
    iput v0, p1, Lcom/kousei/framework/q2;->d:I

    .line 274
    .line 275
    goto :goto_120

    .line 276
    :pswitch_113
    new-instance p1, Lcom/kousei/framework/q2;

    .line 277
    .line 278
    invoke-direct {p1, v4, v1}, Lcom/kousei/framework/q2;-><init>(ILcom/kousei/framework/z;)V

    .line 279
    .line 280
    .line 281
    iput v0, p1, Lcom/kousei/framework/q2;->d:I

    .line 282
    .line 283
    goto :goto_120

    .line 284
    :pswitch_11b
    new-instance p1, Lcom/kousei/framework/x0;

    .line 285
    .line 286
    invoke-direct {p1, v1}, Lcom/kousei/framework/c0;-><init>(Lcom/kousei/framework/z;)V

    .line 287
    .line 288
    .line 289
    :goto_120
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d;->c(Lcom/kousei/framework/c0;)Lcom/kousei/framework/z;

    .line 290
    .line 291
    .line 292
    move-result-object p1

    .line 293
    :goto_124
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d;->a(Lcom/kousei/framework/z;)V

    .line 294
    .line 295
    .line 296
    return-object p1

    .line 297
    :cond_128
    const-string p0, "object explicit - implicit expected."

    .line 298
    .line 299
    goto/16 :goto_1b

    .line 300
    .line 301
    :pswitch_data_12c
    .packed-switch 0x0
        :pswitch_fc
        :pswitch_f5
        :pswitch_ee
        :pswitch_e7
        :pswitch_46
        :pswitch_de
        :pswitch_d5
        :pswitch_cd
        :pswitch_c5
        :pswitch_bd
        :pswitch_ae
        :pswitch_a6
        :pswitch_98
        :pswitch_90
        :pswitch_30
        :pswitch_88
        :pswitch_80
        :pswitch_46
        :pswitch_46
        :pswitch_78
        :pswitch_70
        :pswitch_68
        :pswitch_60
        :pswitch_58
        :pswitch_4e
    .end packed-switch

    .line 302
    .line 303
    .line 304
    .line 305
    .line 306
    .line 307
    .line 308
    .line 309
    .line 310
    .line 311
    .line 312
    .line 313
    .line 314
    .line 315
    .line 316
    .line 317
    .line 318
    .line 319
    .line 320
    .line 321
    .line 322
    .line 323
    .line 324
    .line 325
    .line 326
    .line 327
    .line 328
    .line 329
    .line 330
    .line 331
    .line 332
    .line 333
    .line 334
    .line 335
    .line 336
    .line 337
    .line 338
    .line 339
    .line 340
    .line 341
    .line 342
    .line 343
    .line 344
    .line 345
    .line 346
    .line 347
    .line 348
    .line 349
    .line 350
    .line 351
    .line 352
    .line 353
    .line 354
    .line 355
    :pswitch_data_162
    .packed-switch 0x0
        :pswitch_11b
        :pswitch_113
    .end packed-switch
.end method

.method public final equals(Ljava/lang/Object;)Z
    .registers 2

    .line 1
    if-ne p0, p1, :cond_4

    .line 2
    .line 3
    const/4 p0, 0x1

    .line 4
    return p0

    .line 5
    :cond_4
    const/4 p0, 0x0

    .line 6
    return p0
.end method
