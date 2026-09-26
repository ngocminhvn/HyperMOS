.class public final Lcom/kousei/framework/c7;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/HashMap;

.field public static final b:Lcom/kousei/framework/i3;


# direct methods
.method static constructor <clinit>()V
    .registers 19

    .line 1
    new-instance v0, Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 4
    .line 5
    .line 6
    sput-object v0, Lcom/kousei/framework/c7;->a:Ljava/util/HashMap;

    .line 7
    .line 8
    new-instance v1, Ljava/util/HashMap;

    .line 9
    .line 10
    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    .line 11
    .line 12
    .line 13
    new-instance v2, Ljava/util/HashMap;

    .line 14
    .line 15
    invoke-direct {v2}, Ljava/util/HashMap;-><init>()V

    .line 16
    .line 17
    .line 18
    new-instance v3, Ljava/util/HashMap;

    .line 19
    .line 20
    invoke-direct {v3}, Ljava/util/HashMap;-><init>()V

    .line 21
    .line 22
    .line 23
    new-instance v4, Ljava/util/HashMap;

    .line 24
    .line 25
    invoke-direct {v4}, Ljava/util/HashMap;-><init>()V

    .line 26
    .line 27
    .line 28
    new-instance v5, Ljava/util/HashMap;

    .line 29
    .line 30
    invoke-direct {v5}, Ljava/util/HashMap;-><init>()V

    .line 31
    .line 32
    .line 33
    new-instance v6, Lcom/kousei/framework/i3;

    .line 34
    .line 35
    invoke-direct {v6}, Ljava/lang/Object;-><init>()V

    .line 36
    .line 37
    .line 38
    sput-object v6, Lcom/kousei/framework/c7;->b:Lcom/kousei/framework/i3;

    .line 39
    .line 40
    sget-object v6, Lcom/kousei/framework/p6;->a:Lcom/kousei/framework/u;

    .line 41
    .line 42
    const-string v7, "SHA1"

    .line 43
    .line 44
    invoke-virtual {v0, v6, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 45
    .line 46
    .line 47
    sget-object v7, Lcom/kousei/framework/l6;->d:Lcom/kousei/framework/u;

    .line 48
    .line 49
    const-string v8, "SHA224"

    .line 50
    .line 51
    invoke-virtual {v0, v7, v8}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 52
    .line 53
    .line 54
    sget-object v8, Lcom/kousei/framework/l6;->a:Lcom/kousei/framework/u;

    .line 55
    .line 56
    const-string v9, "SHA256"

    .line 57
    .line 58
    invoke-virtual {v0, v8, v9}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 59
    .line 60
    .line 61
    sget-object v9, Lcom/kousei/framework/l6;->b:Lcom/kousei/framework/u;

    .line 62
    .line 63
    const-string v10, "SHA384"

    .line 64
    .line 65
    invoke-virtual {v0, v9, v10}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 66
    .line 67
    .line 68
    sget-object v10, Lcom/kousei/framework/l6;->c:Lcom/kousei/framework/u;

    .line 69
    .line 70
    const-string v11, "SHA512"

    .line 71
    .line 72
    invoke-virtual {v0, v10, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 73
    .line 74
    .line 75
    sget-object v11, Lcom/kousei/framework/oa;->b:Lcom/kousei/framework/u;

    .line 76
    .line 77
    const-string v12, "RIPEMD128"

    .line 78
    .line 79
    invoke-virtual {v0, v11, v12}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 80
    .line 81
    .line 82
    sget-object v11, Lcom/kousei/framework/oa;->a:Lcom/kousei/framework/u;

    .line 83
    .line 84
    const-string v12, "RIPEMD160"

    .line 85
    .line 86
    invoke-virtual {v0, v11, v12}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 87
    .line 88
    .line 89
    sget-object v11, Lcom/kousei/framework/oa;->c:Lcom/kousei/framework/u;

    .line 90
    .line 91
    const-string v12, "RIPEMD256"

    .line 92
    .line 93
    invoke-virtual {v0, v11, v12}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 94
    .line 95
    .line 96
    sget-object v0, Lcom/kousei/framework/e7;->a:Lcom/kousei/framework/u;

    .line 97
    .line 98
    const-string v11, "RSA/ECB/PKCS1Padding"

    .line 99
    .line 100
    invoke-virtual {v1, v0, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 101
    .line 102
    .line 103
    sget-object v0, Lcom/kousei/framework/p6;->d:Lcom/kousei/framework/u;

    .line 104
    .line 105
    const-string v11, "Elgamal/ECB/PKCS1Padding"

    .line 106
    .line 107
    invoke-virtual {v1, v0, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 108
    .line 109
    .line 110
    sget-object v0, Lcom/kousei/framework/e7;->f:Lcom/kousei/framework/u;

    .line 111
    .line 112
    const-string v11, "RSA/ECB/OAEPPadding"

    .line 113
    .line 114
    invoke-virtual {v1, v0, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 115
    .line 116
    .line 117
    sget-object v0, Lcom/kousei/framework/s1;->b:Lcom/kousei/framework/u;

    .line 118
    .line 119
    const-string v11, "ECGOST3410"

    .line 120
    .line 121
    invoke-virtual {v1, v0, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 122
    .line 123
    .line 124
    sget-object v0, Lcom/kousei/framework/e7;->x:Lcom/kousei/framework/u;

    .line 125
    .line 126
    const-string v1, "DESEDEWrap"

    .line 127
    .line 128
    invoke-virtual {v2, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 129
    .line 130
    .line 131
    sget-object v1, Lcom/kousei/framework/e7;->y:Lcom/kousei/framework/u;

    .line 132
    .line 133
    const-string v11, "RC2Wrap"

    .line 134
    .line 135
    invoke-virtual {v2, v1, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    .line 137
    .line 138
    sget-object v1, Lcom/kousei/framework/l6;->q:Lcom/kousei/framework/u;

    .line 139
    .line 140
    const-string v11, "AESWrap"

    .line 141
    .line 142
    invoke-virtual {v2, v1, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 143
    .line 144
    .line 145
    sget-object v12, Lcom/kousei/framework/l6;->s:Lcom/kousei/framework/u;

    .line 146
    .line 147
    invoke-virtual {v2, v12, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 148
    .line 149
    .line 150
    sget-object v13, Lcom/kousei/framework/l6;->u:Lcom/kousei/framework/u;

    .line 151
    .line 152
    invoke-virtual {v2, v13, v11}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    .line 154
    .line 155
    sget-object v11, Lcom/kousei/framework/m6;->a:Lcom/kousei/framework/u;

    .line 156
    .line 157
    const-string v14, "CamelliaWrap"

    .line 158
    .line 159
    invoke-virtual {v2, v11, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 160
    .line 161
    .line 162
    sget-object v15, Lcom/kousei/framework/m6;->b:Lcom/kousei/framework/u;

    .line 163
    .line 164
    invoke-virtual {v2, v15, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 165
    .line 166
    .line 167
    move-object/from16 v16, v10

    .line 168
    .line 169
    sget-object v10, Lcom/kousei/framework/m6;->c:Lcom/kousei/framework/u;

    .line 170
    .line 171
    invoke-virtual {v2, v10, v14}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 172
    .line 173
    .line 174
    sget-object v14, Lcom/kousei/framework/m5;->a:Lcom/kousei/framework/u;

    .line 175
    .line 176
    move-object/from16 v17, v9

    .line 177
    .line 178
    const-string v9, "SEEDWrap"

    .line 179
    .line 180
    invoke-virtual {v2, v14, v9}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 181
    .line 182
    .line 183
    sget-object v9, Lcom/kousei/framework/e7;->p:Lcom/kousei/framework/u;

    .line 184
    .line 185
    move-object/from16 v18, v8

    .line 186
    .line 187
    const-string v8, "DESede"

    .line 188
    .line 189
    invoke-virtual {v2, v9, v8}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 190
    .line 191
    .line 192
    const/16 v2, 0xc0

    .line 193
    .line 194
    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 195
    .line 196
    .line 197
    move-result-object v2

    .line 198
    invoke-virtual {v4, v0, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 199
    .line 200
    .line 201
    const/16 v0, 0x80

    .line 202
    .line 203
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 204
    .line 205
    .line 206
    move-result-object v0

    .line 207
    invoke-virtual {v4, v1, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 208
    .line 209
    .line 210
    invoke-virtual {v4, v12, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 211
    .line 212
    .line 213
    const/16 v1, 0x100

    .line 214
    .line 215
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 216
    .line 217
    .line 218
    move-result-object v1

    .line 219
    invoke-virtual {v4, v13, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 220
    .line 221
    .line 222
    invoke-virtual {v4, v11, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 223
    .line 224
    .line 225
    invoke-virtual {v4, v15, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 226
    .line 227
    .line 228
    invoke-virtual {v4, v10, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 229
    .line 230
    .line 231
    invoke-virtual {v4, v14, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 232
    .line 233
    .line 234
    invoke-virtual {v4, v9, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 235
    .line 236
    .line 237
    sget-object v0, Lcom/kousei/framework/l6;->o:Lcom/kousei/framework/u;

    .line 238
    .line 239
    const-string v1, "AES"

    .line 240
    .line 241
    invoke-virtual {v3, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 242
    .line 243
    .line 244
    sget-object v0, Lcom/kousei/framework/l6;->p:Lcom/kousei/framework/u;

    .line 245
    .line 246
    invoke-virtual {v3, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 247
    .line 248
    .line 249
    sget-object v0, Lcom/kousei/framework/l6;->r:Lcom/kousei/framework/u;

    .line 250
    .line 251
    invoke-virtual {v3, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 252
    .line 253
    .line 254
    sget-object v0, Lcom/kousei/framework/l6;->t:Lcom/kousei/framework/u;

    .line 255
    .line 256
    invoke-virtual {v3, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 257
    .line 258
    .line 259
    invoke-virtual {v3, v9, v8}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 260
    .line 261
    .line 262
    sget-object v0, Lcom/kousei/framework/e7;->q:Lcom/kousei/framework/u;

    .line 263
    .line 264
    const-string v1, "RC2"

    .line 265
    .line 266
    invoke-virtual {v3, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 267
    .line 268
    .line 269
    invoke-static {v5, v6}, Lcom/kousei/framework/g3;->a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V

    .line 270
    .line 271
    .line 272
    invoke-static {v5, v7}, Lcom/kousei/framework/g3;->a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V

    .line 273
    .line 274
    .line 275
    move-object/from16 v0, v18

    .line 276
    .line 277
    invoke-static {v5, v0}, Lcom/kousei/framework/g3;->a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V

    .line 278
    .line 279
    .line 280
    move-object/from16 v0, v17

    .line 281
    .line 282
    invoke-static {v5, v0}, Lcom/kousei/framework/g3;->a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V

    .line 283
    .line 284
    .line 285
    move-object/from16 v0, v16

    .line 286
    .line 287
    invoke-static {v5, v0}, Lcom/kousei/framework/g3;->a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V

    .line 288
    .line 289
    .line 290
    return-void
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/j0;)Ljava/security/Signature;
    .registers 8

    .line 1
    sget-object p0, Lcom/kousei/framework/c7;->b:Lcom/kousei/framework/i3;

    .line 2
    .line 3
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 4
    .line 5
    .line 6
    iget-object p0, p1, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 7
    .line 8
    iget-object p1, p1, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 9
    .line 10
    const-string v0, "WITHRSAANDMGF1"

    .line 11
    .line 12
    if-eqz p0, :cond_94

    .line 13
    .line 14
    sget-object v1, Lcom/kousei/framework/l2;->a:Lcom/kousei/framework/l2;

    .line 15
    .line 16
    if-eq v1, p0, :cond_94

    .line 17
    .line 18
    invoke-interface {p0}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 19
    .line 20
    .line 21
    move-result-object v2

    .line 22
    invoke-virtual {v1, v2}, Lcom/kousei/framework/q;->i(Lcom/kousei/framework/z;)Z

    .line 23
    .line 24
    .line 25
    move-result v1

    .line 26
    if-eqz v1, :cond_1d

    .line 27
    .line 28
    goto/16 :goto_94

    .line 29
    .line 30
    :cond_1d
    sget-object v1, Lcom/kousei/framework/e7;->i:Lcom/kousei/framework/u;

    .line 31
    .line 32
    invoke-virtual {p1, v1}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 33
    .line 34
    .line 35
    move-result v1

    .line 36
    if-eqz v1, :cond_94

    .line 37
    .line 38
    invoke-static {p0}, Lcom/kousei/framework/w7;->i(Ljava/lang/Object;)Lcom/kousei/framework/w7;

    .line 39
    .line 40
    .line 41
    move-result-object v1

    .line 42
    iget-object v2, v1, Lcom/kousei/framework/w7;->b:Lcom/kousei/framework/j0;

    .line 43
    .line 44
    iget-object v3, v2, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 45
    .line 46
    sget-object v4, Lcom/kousei/framework/e7;->g:Lcom/kousei/framework/u;

    .line 47
    .line 48
    invoke-virtual {v3, v4}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 49
    .line 50
    .line 51
    move-result v3

    .line 52
    iget-object v1, v1, Lcom/kousei/framework/w7;->a:Lcom/kousei/framework/j0;

    .line 53
    .line 54
    if-eqz v3, :cond_7a

    .line 55
    .line 56
    iget-object v2, v2, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 57
    .line 58
    invoke-static {v2}, Lcom/kousei/framework/j0;->i(Ljava/lang/Object;)Lcom/kousei/framework/j0;

    .line 59
    .line 60
    .line 61
    move-result-object v2

    .line 62
    iget-object v2, v2, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 63
    .line 64
    iget-object v3, v1, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 65
    .line 66
    invoke-virtual {v2, v3}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 67
    .line 68
    .line 69
    move-result v3

    .line 70
    iget-object v1, v1, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 71
    .line 72
    if-eqz v3, :cond_5d

    .line 73
    .line 74
    new-instance v2, Ljava/lang/StringBuilder;

    .line 75
    .line 76
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    .line 77
    .line 78
    .line 79
    invoke-static {v1}, Lcom/kousei/framework/i3;->b(Lcom/kousei/framework/u;)Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object v1

    .line 83
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 84
    .line 85
    .line 86
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 87
    .line 88
    .line 89
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 90
    .line 91
    .line 92
    move-result-object v1

    .line 93
    goto :goto_a7

    .line 94
    :cond_5d
    new-instance v3, Ljava/lang/StringBuilder;

    .line 95
    .line 96
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    .line 97
    .line 98
    .line 99
    invoke-static {v1}, Lcom/kousei/framework/i3;->b(Lcom/kousei/framework/u;)Ljava/lang/String;

    .line 100
    .line 101
    .line 102
    move-result-object v1

    .line 103
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 104
    .line 105
    .line 106
    const-string v1, "WITHRSAANDMGF1USING"

    .line 107
    .line 108
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 109
    .line 110
    .line 111
    invoke-static {v2}, Lcom/kousei/framework/i3;->b(Lcom/kousei/framework/u;)Ljava/lang/String;

    .line 112
    .line 113
    .line 114
    move-result-object v1

    .line 115
    :goto_72
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 116
    .line 117
    .line 118
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 119
    .line 120
    .line 121
    move-result-object v1

    .line 122
    goto :goto_a7

    .line 123
    :cond_7a
    new-instance v3, Ljava/lang/StringBuilder;

    .line 124
    .line 125
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    .line 126
    .line 127
    .line 128
    iget-object v1, v1, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 129
    .line 130
    invoke-static {v1}, Lcom/kousei/framework/i3;->b(Lcom/kousei/framework/u;)Ljava/lang/String;

    .line 131
    .line 132
    .line 133
    move-result-object v1

    .line 134
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 135
    .line 136
    .line 137
    const-string v1, "WITHRSAAND"

    .line 138
    .line 139
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 140
    .line 141
    .line 142
    iget-object v1, v2, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 143
    .line 144
    invoke-virtual {v1}, Lcom/kousei/framework/u;->u()Ljava/lang/String;

    .line 145
    .line 146
    .line 147
    move-result-object v1

    .line 148
    goto :goto_72

    .line 149
    :cond_94
    :goto_94
    sget-object v1, Lcom/kousei/framework/i3;->a:Ljava/util/HashMap;

    .line 150
    .line 151
    invoke-virtual {v1, p1}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    .line 152
    .line 153
    .line 154
    move-result v2

    .line 155
    if-eqz v2, :cond_a3

    .line 156
    .line 157
    invoke-virtual {v1, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 158
    .line 159
    .line 160
    move-result-object v1

    .line 161
    check-cast v1, Ljava/lang/String;

    .line 162
    .line 163
    goto :goto_a7

    .line 164
    :cond_a3
    invoke-virtual {p1}, Lcom/kousei/framework/u;->u()Ljava/lang/String;

    .line 165
    .line 166
    .line 167
    move-result-object v1

    .line 168
    :goto_a7
    :try_start_a7
    invoke-static {v1}, Ljava/security/Signature;->getInstance(Ljava/lang/String;)Ljava/security/Signature;

    .line 169
    .line 170
    .line 171
    move-result-object v0
    :try_end_ab
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_a7 .. :try_end_ab} :catch_ac

    .line 172
    goto :goto_c8

    .line 173
    :catch_ac
    move-exception v2

    .line 174
    invoke-virtual {v1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    .line 175
    .line 176
    .line 177
    move-result v0

    .line 178
    if-eqz v0, :cond_1ae

    .line 179
    .line 180
    const/16 v0, 0x57

    .line 181
    .line 182
    invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(I)I

    .line 183
    .line 184
    .line 185
    move-result v0

    .line 186
    const/4 v2, 0x0

    .line 187
    invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 188
    .line 189
    .line 190
    move-result-object v0

    .line 191
    const-string v1, "WITHRSASSA-PSS"

    .line 192
    .line 193
    invoke-virtual {v0, v1}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 194
    .line 195
    .line 196
    move-result-object v0

    .line 197
    invoke-static {v0}, Ljava/security/Signature;->getInstance(Ljava/lang/String;)Ljava/security/Signature;

    .line 198
    .line 199
    .line 200
    move-result-object v0

    .line 201
    :goto_c8
    sget-object v1, Lcom/kousei/framework/e7;->i:Lcom/kousei/framework/u;

    .line 202
    .line 203
    invoke-virtual {p1, v1}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 204
    .line 205
    .line 206
    move-result p1

    .line 207
    if-eqz p1, :cond_1ad

    .line 208
    .line 209
    invoke-static {p0}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 210
    .line 211
    .line 212
    move-result-object p0

    .line 213
    if-eqz p0, :cond_1ad

    .line 214
    .line 215
    invoke-virtual {p0}, Lcom/kousei/framework/c0;->size()I

    .line 216
    .line 217
    .line 218
    move-result p1

    .line 219
    if-nez p1, :cond_de

    .line 220
    .line 221
    goto/16 :goto_1ad

    .line 222
    .line 223
    :cond_de
    invoke-static {p0}, Lcom/kousei/framework/w7;->i(Ljava/lang/Object;)Lcom/kousei/framework/w7;

    .line 224
    .line 225
    .line 226
    move-result-object p1

    .line 227
    iget-object v1, p1, Lcom/kousei/framework/w7;->b:Lcom/kousei/framework/j0;

    .line 228
    .line 229
    iget-object v2, p1, Lcom/kousei/framework/w7;->a:Lcom/kousei/framework/j0;

    .line 230
    .line 231
    iget-object v1, v1, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 232
    .line 233
    sget-object v3, Lcom/kousei/framework/e7;->g:Lcom/kousei/framework/u;

    .line 234
    .line 235
    invoke-virtual {v1, v3}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 236
    .line 237
    .line 238
    move-result v1

    .line 239
    if-nez v1, :cond_f2

    .line 240
    .line 241
    goto/16 :goto_17c

    .line 242
    .line 243
    :cond_f2
    iget-object v1, p1, Lcom/kousei/framework/w7;->b:Lcom/kousei/framework/j0;

    .line 244
    .line 245
    iget-object v1, v1, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 246
    .line 247
    invoke-static {v1}, Lcom/kousei/framework/j0;->i(Ljava/lang/Object;)Lcom/kousei/framework/j0;

    .line 248
    .line 249
    .line 250
    move-result-object v1

    .line 251
    invoke-virtual {v2, v1}, Lcom/kousei/framework/r;->equals(Ljava/lang/Object;)Z

    .line 252
    .line 253
    .line 254
    move-result v1

    .line 255
    iget-object v3, v2, Lcom/kousei/framework/j0;->a:Lcom/kousei/framework/u;

    .line 256
    .line 257
    if-nez v1, :cond_104

    .line 258
    .line 259
    goto/16 :goto_17c

    .line 260
    .line 261
    :cond_104
    const-string v1, "SHAKE128-"

    .line 262
    .line 263
    const-string v4, "SHAKE256-"

    .line 264
    .line 265
    :try_start_108
    iget-object v2, v2, Lcom/kousei/framework/j0;->b:Lcom/kousei/framework/j;

    .line 266
    .line 267
    sget-object v5, Lcom/kousei/framework/l6;->n:Lcom/kousei/framework/u;

    .line 268
    .line 269
    invoke-virtual {v3, v5}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 270
    .line 271
    .line 272
    move-result v5

    .line 273
    if-eqz v5, :cond_12d

    .line 274
    .line 275
    new-instance v1, Ljava/lang/StringBuilder;

    .line 276
    .line 277
    invoke-direct {v1, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 278
    .line 279
    .line 280
    invoke-static {v2}, Lcom/kousei/framework/p;->r(Ljava/lang/Object;)Lcom/kousei/framework/p;

    .line 281
    .line 282
    .line 283
    move-result-object v2

    .line 284
    invoke-virtual {v2}, Lcom/kousei/framework/p;->s()Ljava/math/BigInteger;

    .line 285
    .line 286
    .line 287
    move-result-object v2

    .line 288
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 289
    .line 290
    .line 291
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 292
    .line 293
    .line 294
    move-result-object v1

    .line 295
    :goto_126
    invoke-static {v1}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 296
    .line 297
    .line 298
    move-result-object v1

    .line 299
    goto :goto_16c

    .line 300
    :catch_12b
    move-exception v1

    .line 301
    goto :goto_15a

    .line 302
    :cond_12d
    sget-object v4, Lcom/kousei/framework/l6;->m:Lcom/kousei/framework/u;

    .line 303
    .line 304
    invoke-virtual {v3, v4}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 305
    .line 306
    .line 307
    move-result v4

    .line 308
    if-eqz v4, :cond_14a

    .line 309
    .line 310
    new-instance v4, Ljava/lang/StringBuilder;

    .line 311
    .line 312
    invoke-direct {v4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 313
    .line 314
    .line 315
    invoke-static {v2}, Lcom/kousei/framework/p;->r(Ljava/lang/Object;)Lcom/kousei/framework/p;

    .line 316
    .line 317
    .line 318
    move-result-object v1

    .line 319
    invoke-virtual {v1}, Lcom/kousei/framework/p;->s()Ljava/math/BigInteger;

    .line 320
    .line 321
    .line 322
    move-result-object v1

    .line 323
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 324
    .line 325
    .line 326
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 327
    .line 328
    .line 329
    move-result-object v1

    .line 330
    goto :goto_126

    .line 331
    :cond_14a
    sget-object v1, Lcom/kousei/framework/h6;->a:Ljava/util/HashMap;

    .line 332
    .line 333
    invoke-virtual {v1, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 334
    .line 335
    .line 336
    move-result-object v1

    .line 337
    check-cast v1, Ljava/lang/String;

    .line 338
    .line 339
    if-eqz v1, :cond_155

    .line 340
    .line 341
    goto :goto_126

    .line 342
    :cond_155
    invoke-virtual {v3}, Lcom/kousei/framework/u;->u()Ljava/lang/String;

    .line 343
    .line 344
    .line 345
    move-result-object v1
    :try_end_159
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_108 .. :try_end_159} :catch_12b

    .line 346
    goto :goto_126

    .line 347
    :goto_15a
    sget-object v2, Lcom/kousei/framework/c7;->a:Ljava/util/HashMap;

    .line 348
    .line 349
    invoke-virtual {v2, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 350
    .line 351
    .line 352
    move-result-object v4

    .line 353
    if-eqz v4, :cond_1ac

    .line 354
    .line 355
    invoke-virtual {v2, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 356
    .line 357
    .line 358
    move-result-object v1

    .line 359
    check-cast v1, Ljava/lang/String;

    .line 360
    .line 361
    invoke-static {v1}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 362
    .line 363
    .line 364
    move-result-object v1

    .line 365
    :goto_16c
    iget-object p1, p1, Lcom/kousei/framework/w7;->c:Lcom/kousei/framework/p;

    .line 366
    .line 367
    invoke-virtual {p1}, Lcom/kousei/framework/p;->s()Ljava/math/BigInteger;

    .line 368
    .line 369
    .line 370
    move-result-object p1

    .line 371
    invoke-virtual {p1}, Ljava/math/BigInteger;->intValue()I

    .line 372
    .line 373
    .line 374
    move-result p1

    .line 375
    invoke-virtual {v1}, Ljava/security/MessageDigest;->getDigestLength()I

    .line 376
    .line 377
    .line 378
    move-result v1

    .line 379
    if-eq p1, v1, :cond_1ad

    .line 380
    .line 381
    :goto_17c
    :try_start_17c
    const-string p1, "PSS"

    .line 382
    .line 383
    invoke-static {p1}, Ljava/security/AlgorithmParameters;->getInstance(Ljava/lang/String;)Ljava/security/AlgorithmParameters;

    .line 384
    .line 385
    .line 386
    move-result-object p1

    .line 387
    invoke-virtual {p0}, Lcom/kousei/framework/r;->g()[B

    .line 388
    .line 389
    .line 390
    move-result-object p0

    .line 391
    invoke-virtual {p1, p0}, Ljava/security/AlgorithmParameters;->init([B)V

    .line 392
    .line 393
    .line 394
    const-class p0, Ljava/security/spec/PSSParameterSpec;

    .line 395
    .line 396
    invoke-virtual {p1, p0}, Ljava/security/AlgorithmParameters;->getParameterSpec(Ljava/lang/Class;)Ljava/security/spec/AlgorithmParameterSpec;

    .line 397
    .line 398
    .line 399
    move-result-object p0

    .line 400
    invoke-virtual {v0, p0}, Ljava/security/Signature;->setParameter(Ljava/security/spec/AlgorithmParameterSpec;)V
    :try_end_192
    .catch Ljava/io/IOException; {:try_start_17c .. :try_end_192} :catch_193

    .line 401
    .line 402
    .line 403
    goto :goto_1ad

    .line 404
    :catch_193
    move-exception p0

    .line 405
    new-instance p1, Ljava/security/GeneralSecurityException;

    .line 406
    .line 407
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 408
    .line 409
    .line 410
    move-result-object p0

    .line 411
    new-instance v0, Ljava/lang/StringBuilder;

    .line 412
    .line 413
    const-string v1, "unable to process PSS parameters: "

    .line 414
    .line 415
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 416
    .line 417
    .line 418
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 419
    .line 420
    .line 421
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 422
    .line 423
    .line 424
    move-result-object p0

    .line 425
    invoke-direct {p1, p0}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    .line 426
    .line 427
    .line 428
    throw p1

    .line 429
    :cond_1ac
    throw v1

    .line 430
    :cond_1ad
    :goto_1ad
    return-object v0

    .line 431
    :cond_1ae
    throw v2
.end method
