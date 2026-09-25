.class public final Lcom/kousei/framework/b2;
.super Lcom/kousei/framework/d4;


# instance fields
.field public final synthetic h:I


# direct methods
.method public synthetic constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V
    .registers 5

    .line 1
    iput p4, p0, Lcom/kousei/framework/b2;->h:I

    .line 2
    .line 3
    const/4 p4, 0x1

    .line 4
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/kousei/framework/d4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 5
    .line 6
    .line 7
    return-void
.end method

.method public synthetic constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V
    .registers 6

    .line 8
    iput p5, p0, Lcom/kousei/framework/b2;->h:I

    const/4 p5, 0x1

    invoke-direct/range {p0 .. p5}, Lcom/kousei/framework/d4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-void
.end method

.method private final q(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 25

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-eqz v2, :cond_b

    .line 10
    .line 11
    return-object v1

    .line 12
    :cond_b
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 13
    .line 14
    .line 15
    move-result v2

    .line 16
    if-eqz v2, :cond_12

    .line 17
    .line 18
    return-object v0

    .line 19
    :cond_12
    if-ne v0, v1, :cond_19

    .line 20
    .line 21
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    return-object v0

    .line 26
    :cond_19
    iget-object v2, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 27
    .line 28
    check-cast v2, Lcom/kousei/framework/v8;

    .line 29
    .line 30
    iget-object v3, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 31
    .line 32
    check-cast v3, Lcom/kousei/framework/v8;

    .line 33
    .line 34
    iget-object v4, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 35
    .line 36
    check-cast v4, Lcom/kousei/framework/v8;

    .line 37
    .line 38
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object v5

    .line 42
    check-cast v5, Lcom/kousei/framework/v8;

    .line 43
    .line 44
    iget-object v6, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 45
    .line 46
    const/4 v7, 0x0

    .line 47
    aget-object v6, v6, v7

    .line 48
    .line 49
    check-cast v6, Lcom/kousei/framework/v8;

    .line 50
    .line 51
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    .line 52
    .line 53
    .line 54
    move-result-object v1

    .line 55
    check-cast v1, Lcom/kousei/framework/v8;

    .line 56
    .line 57
    const/16 v8, 0xe

    .line 58
    .line 59
    new-array v9, v8, [I

    .line 60
    .line 61
    const/4 v10, 0x7

    .line 62
    new-array v11, v10, [I

    .line 63
    .line 64
    new-array v12, v10, [I

    .line 65
    .line 66
    new-array v13, v10, [I

    .line 67
    .line 68
    iget-object v6, v6, Lcom/kousei/framework/v8;->S:[I

    .line 69
    .line 70
    invoke-static {v6}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 71
    .line 72
    .line 73
    move-result v14

    .line 74
    if-eqz v14, :cond_50

    .line 75
    .line 76
    iget-object v4, v4, Lcom/kousei/framework/v8;->S:[I

    .line 77
    .line 78
    iget-object v5, v5, Lcom/kousei/framework/v8;->S:[I

    .line 79
    .line 80
    goto :goto_62

    .line 81
    :cond_50
    invoke-static {v6, v12}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 82
    .line 83
    .line 84
    iget-object v4, v4, Lcom/kousei/framework/v8;->S:[I

    .line 85
    .line 86
    invoke-static {v12, v4, v11}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 87
    .line 88
    .line 89
    invoke-static {v12, v6, v12}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 90
    .line 91
    .line 92
    iget-object v4, v5, Lcom/kousei/framework/v8;->S:[I

    .line 93
    .line 94
    invoke-static {v12, v4, v12}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 95
    .line 96
    .line 97
    move-object v4, v11

    .line 98
    move-object v5, v12

    .line 99
    :goto_62
    iget-object v1, v1, Lcom/kousei/framework/v8;->S:[I

    .line 100
    .line 101
    invoke-static {v1}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 102
    .line 103
    .line 104
    move-result v15

    .line 105
    if-eqz v15, :cond_71

    .line 106
    .line 107
    iget-object v2, v2, Lcom/kousei/framework/v8;->S:[I

    .line 108
    .line 109
    iget-object v3, v3, Lcom/kousei/framework/v8;->S:[I

    .line 110
    .line 111
    :goto_6e
    move/from16 v16, v7

    .line 112
    .line 113
    goto :goto_84

    .line 114
    :cond_71
    invoke-static {v1, v13}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 115
    .line 116
    .line 117
    iget-object v2, v2, Lcom/kousei/framework/v8;->S:[I

    .line 118
    .line 119
    invoke-static {v13, v2, v9}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 120
    .line 121
    .line 122
    invoke-static {v13, v1, v13}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 123
    .line 124
    .line 125
    iget-object v2, v3, Lcom/kousei/framework/v8;->S:[I

    .line 126
    .line 127
    invoke-static {v13, v2, v13}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 128
    .line 129
    .line 130
    move-object v2, v9

    .line 131
    move-object v3, v13

    .line 132
    goto :goto_6e

    .line 133
    :goto_84
    new-array v7, v10, [I

    .line 134
    .line 135
    invoke-static {v2, v4, v7}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 136
    .line 137
    .line 138
    invoke-static {v3, v5, v11}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 139
    .line 140
    .line 141
    invoke-static {v7}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 142
    .line 143
    .line 144
    move-result v4

    .line 145
    iget-object v5, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 146
    .line 147
    if-eqz v4, :cond_a4

    .line 148
    .line 149
    invoke-static {v11}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 150
    .line 151
    .line 152
    move-result v1

    .line 153
    if-eqz v1, :cond_9f

    .line 154
    .line 155
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 156
    .line 157
    .line 158
    move-result-object v0

    .line 159
    return-object v0

    .line 160
    :cond_9f
    invoke-virtual {v5}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 161
    .line 162
    .line 163
    move-result-object v0

    .line 164
    return-object v0

    .line 165
    :cond_a4
    invoke-static {v7, v12}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 166
    .line 167
    .line 168
    new-array v0, v10, [I

    .line 169
    .line 170
    invoke-static {v12, v7, v0}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 171
    .line 172
    .line 173
    invoke-static {v12, v2, v12}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 174
    .line 175
    .line 176
    invoke-static {v0, v0}, Lcom/kousei/framework/h0;->o1([I[I)V

    .line 177
    .line 178
    .line 179
    invoke-static {v3, v0, v9}, Lcom/kousei/framework/n6;->w0([I[I[I)V

    .line 180
    .line 181
    .line 182
    invoke-static {v12, v12, v0}, Lcom/kousei/framework/n6;->f([I[I[I)I

    .line 183
    .line 184
    .line 185
    move-result v2

    .line 186
    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 187
    .line 188
    .line 189
    new-instance v2, Lcom/kousei/framework/v8;

    .line 190
    .line 191
    invoke-direct {v2, v13}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 192
    .line 193
    .line 194
    invoke-static {v11, v13}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 195
    .line 196
    .line 197
    invoke-static {v13, v0, v13}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 198
    .line 199
    .line 200
    new-instance v3, Lcom/kousei/framework/v8;

    .line 201
    .line 202
    invoke-direct {v3, v0}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 203
    .line 204
    .line 205
    invoke-static {v12, v13, v0}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 206
    .line 207
    .line 208
    invoke-static {v0, v11, v9}, Lcom/kousei/framework/n6;->z0([I[I[I)I

    .line 209
    .line 210
    .line 211
    move-result v4

    .line 212
    if-nez v4, :cond_e4

    .line 213
    .line 214
    const/16 v4, 0xd

    .line 215
    .line 216
    aget v4, v9, v4

    .line 217
    .line 218
    const/4 v10, -0x1

    .line 219
    if-ne v4, v10, :cond_f1

    .line 220
    .line 221
    sget-object v4, Lcom/kousei/framework/h0;->D:[I

    .line 222
    .line 223
    invoke-static {v8, v9, v4}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 224
    .line 225
    .line 226
    move-result v4

    .line 227
    if-eqz v4, :cond_f1

    .line 228
    .line 229
    :cond_e4
    sget-object v4, Lcom/kousei/framework/h0;->E:[I

    .line 230
    .line 231
    const/16 v10, 0xb

    .line 232
    .line 233
    invoke-static {v10, v4, v9}, Lcom/kousei/framework/n6;->m(I[I[I)I

    .line 234
    .line 235
    .line 236
    move-result v4

    .line 237
    if-eqz v4, :cond_f1

    .line 238
    .line 239
    invoke-static {v8, v10, v9}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 240
    .line 241
    .line 242
    :cond_f1
    invoke-static {v9, v0}, Lcom/kousei/framework/h0;->H1([I[I)V

    .line 243
    .line 244
    .line 245
    new-instance v0, Lcom/kousei/framework/v8;

    .line 246
    .line 247
    invoke-direct {v0, v7}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 248
    .line 249
    .line 250
    if-nez v14, :cond_fe

    .line 251
    .line 252
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 253
    .line 254
    .line 255
    :cond_fe
    if-nez v15, :cond_103

    .line 256
    .line 257
    invoke-static {v7, v1, v7}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 258
    .line 259
    .line 260
    :cond_103
    const/4 v1, 0x1

    .line 261
    new-array v1, v1, [Lcom/kousei/framework/h0;

    .line 262
    .line 263
    aput-object v0, v1, v16

    .line 264
    .line 265
    new-instance v17, Lcom/kousei/framework/b2;

    .line 266
    .line 267
    const/16 v22, 0xa

    .line 268
    .line 269
    move-object/from16 v21, v1

    .line 270
    .line 271
    move-object/from16 v19, v2

    .line 272
    .line 273
    move-object/from16 v20, v3

    .line 274
    .line 275
    move-object/from16 v18, v5

    .line 276
    .line 277
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 278
    .line 279
    .line 280
    return-object v17
.end method

.method private final r(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 26

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-eqz v2, :cond_b

    .line 10
    .line 11
    return-object v1

    .line 12
    :cond_b
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 13
    .line 14
    .line 15
    move-result v2

    .line 16
    if-eqz v2, :cond_12

    .line 17
    .line 18
    return-object v0

    .line 19
    :cond_12
    if-ne v0, v1, :cond_19

    .line 20
    .line 21
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    return-object v0

    .line 26
    :cond_19
    iget-object v2, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 27
    .line 28
    check-cast v2, Lcom/kousei/framework/x8;

    .line 29
    .line 30
    iget-object v3, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 31
    .line 32
    check-cast v3, Lcom/kousei/framework/x8;

    .line 33
    .line 34
    iget-object v4, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 35
    .line 36
    check-cast v4, Lcom/kousei/framework/x8;

    .line 37
    .line 38
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object v5

    .line 42
    check-cast v5, Lcom/kousei/framework/x8;

    .line 43
    .line 44
    iget-object v6, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 45
    .line 46
    const/4 v7, 0x0

    .line 47
    aget-object v6, v6, v7

    .line 48
    .line 49
    check-cast v6, Lcom/kousei/framework/x8;

    .line 50
    .line 51
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    .line 52
    .line 53
    .line 54
    move-result-object v1

    .line 55
    check-cast v1, Lcom/kousei/framework/x8;

    .line 56
    .line 57
    const/16 v8, 0x10

    .line 58
    .line 59
    new-array v9, v8, [I

    .line 60
    .line 61
    new-array v10, v8, [I

    .line 62
    .line 63
    const/16 v11, 0x8

    .line 64
    .line 65
    new-array v12, v11, [I

    .line 66
    .line 67
    new-array v13, v11, [I

    .line 68
    .line 69
    new-array v14, v11, [I

    .line 70
    .line 71
    iget-object v6, v6, Lcom/kousei/framework/x8;->S:[I

    .line 72
    .line 73
    invoke-static {v6}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 74
    .line 75
    .line 76
    move-result v15

    .line 77
    if-eqz v15, :cond_53

    .line 78
    .line 79
    iget-object v4, v4, Lcom/kousei/framework/x8;->S:[I

    .line 80
    .line 81
    iget-object v5, v5, Lcom/kousei/framework/x8;->S:[I

    .line 82
    .line 83
    goto :goto_6b

    .line 84
    :cond_53
    invoke-static {v6, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 85
    .line 86
    .line 87
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 88
    .line 89
    .line 90
    iget-object v4, v4, Lcom/kousei/framework/x8;->S:[I

    .line 91
    .line 92
    invoke-static {v13, v4, v12, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 93
    .line 94
    .line 95
    invoke-static {v13, v6, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 96
    .line 97
    .line 98
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 99
    .line 100
    .line 101
    iget-object v4, v5, Lcom/kousei/framework/x8;->S:[I

    .line 102
    .line 103
    invoke-static {v13, v4, v13, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 104
    .line 105
    .line 106
    move-object v4, v12

    .line 107
    move-object v5, v13

    .line 108
    :goto_6b
    iget-object v1, v1, Lcom/kousei/framework/x8;->S:[I

    .line 109
    .line 110
    invoke-static {v1}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 111
    .line 112
    .line 113
    move-result v16

    .line 114
    if-eqz v16, :cond_7a

    .line 115
    .line 116
    iget-object v2, v2, Lcom/kousei/framework/x8;->S:[I

    .line 117
    .line 118
    iget-object v3, v3, Lcom/kousei/framework/x8;->S:[I

    .line 119
    .line 120
    :goto_77
    move/from16 v17, v7

    .line 121
    .line 122
    goto :goto_93

    .line 123
    :cond_7a
    invoke-static {v1, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 124
    .line 125
    .line 126
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 127
    .line 128
    .line 129
    iget-object v2, v2, Lcom/kousei/framework/x8;->S:[I

    .line 130
    .line 131
    invoke-static {v14, v2, v10, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 132
    .line 133
    .line 134
    invoke-static {v14, v1, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 135
    .line 136
    .line 137
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 138
    .line 139
    .line 140
    iget-object v2, v3, Lcom/kousei/framework/x8;->S:[I

    .line 141
    .line 142
    invoke-static {v14, v2, v14, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 143
    .line 144
    .line 145
    move-object v2, v10

    .line 146
    move-object v3, v14

    .line 147
    goto :goto_77

    .line 148
    :goto_93
    new-array v7, v11, [I

    .line 149
    .line 150
    invoke-static {v2, v4, v7}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 151
    .line 152
    .line 153
    invoke-static {v3, v5, v12}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 154
    .line 155
    .line 156
    invoke-static {v7}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 157
    .line 158
    .line 159
    move-result v4

    .line 160
    iget-object v5, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 161
    .line 162
    if-eqz v4, :cond_b3

    .line 163
    .line 164
    invoke-static {v12}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 165
    .line 166
    .line 167
    move-result v1

    .line 168
    if-eqz v1, :cond_ae

    .line 169
    .line 170
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 171
    .line 172
    .line 173
    move-result-object v0

    .line 174
    return-object v0

    .line 175
    :cond_ae
    invoke-virtual {v5}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 176
    .line 177
    .line 178
    move-result-object v0

    .line 179
    return-object v0

    .line 180
    :cond_b3
    invoke-static {v7, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 181
    .line 182
    .line 183
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 184
    .line 185
    .line 186
    new-array v0, v11, [I

    .line 187
    .line 188
    invoke-static {v13, v7, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 189
    .line 190
    .line 191
    invoke-static {v9, v0}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 192
    .line 193
    .line 194
    invoke-static {v13, v2, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 195
    .line 196
    .line 197
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 198
    .line 199
    .line 200
    sget-object v2, Lcom/kousei/framework/h0;->F:[I

    .line 201
    .line 202
    invoke-static {v11, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 203
    .line 204
    .line 205
    move-result v4

    .line 206
    if-eqz v4, :cond_d3

    .line 207
    .line 208
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 209
    .line 210
    .line 211
    goto :goto_d6

    .line 212
    :cond_d3
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 213
    .line 214
    .line 215
    :goto_d6
    invoke-static {v3, v0, v10}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 216
    .line 217
    .line 218
    invoke-static {v13, v13, v0}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 219
    .line 220
    .line 221
    move-result v2

    .line 222
    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->U1(I[I)V

    .line 223
    .line 224
    .line 225
    new-instance v2, Lcom/kousei/framework/x8;

    .line 226
    .line 227
    invoke-direct {v2, v14}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 228
    .line 229
    .line 230
    invoke-static {v12, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 231
    .line 232
    .line 233
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 234
    .line 235
    .line 236
    invoke-static {v14, v0, v14}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 237
    .line 238
    .line 239
    new-instance v3, Lcom/kousei/framework/x8;

    .line 240
    .line 241
    invoke-direct {v3, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 242
    .line 243
    .line 244
    invoke-static {v13, v14, v0}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 245
    .line 246
    .line 247
    invoke-static {v0, v12, v10}, Lcom/kousei/framework/n6;->A0([I[I[I)I

    .line 248
    .line 249
    .line 250
    move-result v4

    .line 251
    if-nez v4, :cond_10b

    .line 252
    .line 253
    const/16 v4, 0xf

    .line 254
    .line 255
    aget v4, v10, v4

    .line 256
    .line 257
    const/4 v11, -0x1

    .line 258
    if-ne v4, v11, :cond_118

    .line 259
    .line 260
    sget-object v4, Lcom/kousei/framework/h0;->G:[I

    .line 261
    .line 262
    invoke-static {v8, v10, v4}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 263
    .line 264
    .line 265
    move-result v4

    .line 266
    if-eqz v4, :cond_118

    .line 267
    .line 268
    :cond_10b
    sget-object v4, Lcom/kousei/framework/h0;->H:[I

    .line 269
    .line 270
    const/16 v11, 0xa

    .line 271
    .line 272
    invoke-static {v11, v4, v10}, Lcom/kousei/framework/n6;->m(I[I[I)I

    .line 273
    .line 274
    .line 275
    move-result v4

    .line 276
    if-eqz v4, :cond_118

    .line 277
    .line 278
    invoke-static {v8, v11, v10}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 279
    .line 280
    .line 281
    :cond_118
    invoke-static {v10, v0}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 282
    .line 283
    .line 284
    new-instance v0, Lcom/kousei/framework/x8;

    .line 285
    .line 286
    invoke-direct {v0, v7}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 287
    .line 288
    .line 289
    if-nez v15, :cond_125

    .line 290
    .line 291
    invoke-static {v7, v6, v7, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 292
    .line 293
    .line 294
    :cond_125
    if-nez v16, :cond_12a

    .line 295
    .line 296
    invoke-static {v7, v1, v7, v9}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 297
    .line 298
    .line 299
    :cond_12a
    const/4 v1, 0x1

    .line 300
    new-array v1, v1, [Lcom/kousei/framework/h0;

    .line 301
    .line 302
    aput-object v0, v1, v17

    .line 303
    .line 304
    new-instance v18, Lcom/kousei/framework/b2;

    .line 305
    .line 306
    const/16 v23, 0xb

    .line 307
    .line 308
    move-object/from16 v22, v1

    .line 309
    .line 310
    move-object/from16 v20, v2

    .line 311
    .line 312
    move-object/from16 v21, v3

    .line 313
    .line 314
    move-object/from16 v19, v5

    .line 315
    .line 316
    invoke-direct/range {v18 .. v23}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 317
    .line 318
    .line 319
    return-object v18
.end method

.method private final s(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 26

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-eqz v2, :cond_b

    .line 10
    .line 11
    return-object v1

    .line 12
    :cond_b
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 13
    .line 14
    .line 15
    move-result v2

    .line 16
    if-eqz v2, :cond_12

    .line 17
    .line 18
    return-object v0

    .line 19
    :cond_12
    if-ne v0, v1, :cond_19

    .line 20
    .line 21
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    return-object v0

    .line 26
    :cond_19
    iget-object v2, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 27
    .line 28
    check-cast v2, Lcom/kousei/framework/z8;

    .line 29
    .line 30
    iget-object v3, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 31
    .line 32
    check-cast v3, Lcom/kousei/framework/z8;

    .line 33
    .line 34
    iget-object v4, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 35
    .line 36
    check-cast v4, Lcom/kousei/framework/z8;

    .line 37
    .line 38
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object v5

    .line 42
    check-cast v5, Lcom/kousei/framework/z8;

    .line 43
    .line 44
    iget-object v6, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 45
    .line 46
    const/4 v7, 0x0

    .line 47
    aget-object v6, v6, v7

    .line 48
    .line 49
    check-cast v6, Lcom/kousei/framework/z8;

    .line 50
    .line 51
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    .line 52
    .line 53
    .line 54
    move-result-object v1

    .line 55
    check-cast v1, Lcom/kousei/framework/z8;

    .line 56
    .line 57
    const/16 v8, 0x10

    .line 58
    .line 59
    new-array v9, v8, [I

    .line 60
    .line 61
    new-array v10, v8, [I

    .line 62
    .line 63
    const/16 v11, 0x8

    .line 64
    .line 65
    new-array v12, v11, [I

    .line 66
    .line 67
    new-array v13, v11, [I

    .line 68
    .line 69
    new-array v14, v11, [I

    .line 70
    .line 71
    iget-object v6, v6, Lcom/kousei/framework/z8;->S:[I

    .line 72
    .line 73
    invoke-static {v6}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 74
    .line 75
    .line 76
    move-result v15

    .line 77
    if-eqz v15, :cond_53

    .line 78
    .line 79
    iget-object v4, v4, Lcom/kousei/framework/z8;->S:[I

    .line 80
    .line 81
    iget-object v5, v5, Lcom/kousei/framework/z8;->S:[I

    .line 82
    .line 83
    goto :goto_6b

    .line 84
    :cond_53
    invoke-static {v6, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 85
    .line 86
    .line 87
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 88
    .line 89
    .line 90
    iget-object v4, v4, Lcom/kousei/framework/z8;->S:[I

    .line 91
    .line 92
    invoke-static {v13, v4, v12, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 93
    .line 94
    .line 95
    invoke-static {v13, v6, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 96
    .line 97
    .line 98
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 99
    .line 100
    .line 101
    iget-object v4, v5, Lcom/kousei/framework/z8;->S:[I

    .line 102
    .line 103
    invoke-static {v13, v4, v13, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 104
    .line 105
    .line 106
    move-object v4, v12

    .line 107
    move-object v5, v13

    .line 108
    :goto_6b
    iget-object v1, v1, Lcom/kousei/framework/z8;->S:[I

    .line 109
    .line 110
    invoke-static {v1}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 111
    .line 112
    .line 113
    move-result v16

    .line 114
    if-eqz v16, :cond_7a

    .line 115
    .line 116
    iget-object v2, v2, Lcom/kousei/framework/z8;->S:[I

    .line 117
    .line 118
    iget-object v3, v3, Lcom/kousei/framework/z8;->S:[I

    .line 119
    .line 120
    :goto_77
    move/from16 v17, v7

    .line 121
    .line 122
    goto :goto_93

    .line 123
    :cond_7a
    invoke-static {v1, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 124
    .line 125
    .line 126
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 127
    .line 128
    .line 129
    iget-object v2, v2, Lcom/kousei/framework/z8;->S:[I

    .line 130
    .line 131
    invoke-static {v14, v2, v10, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 132
    .line 133
    .line 134
    invoke-static {v14, v1, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 135
    .line 136
    .line 137
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 138
    .line 139
    .line 140
    iget-object v2, v3, Lcom/kousei/framework/z8;->S:[I

    .line 141
    .line 142
    invoke-static {v14, v2, v14, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 143
    .line 144
    .line 145
    move-object v2, v10

    .line 146
    move-object v3, v14

    .line 147
    goto :goto_77

    .line 148
    :goto_93
    new-array v7, v11, [I

    .line 149
    .line 150
    invoke-static {v2, v4, v7}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 151
    .line 152
    .line 153
    invoke-static {v3, v5, v12}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 154
    .line 155
    .line 156
    invoke-static {v7}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 157
    .line 158
    .line 159
    move-result v4

    .line 160
    iget-object v5, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 161
    .line 162
    if-eqz v4, :cond_b3

    .line 163
    .line 164
    invoke-static {v12}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 165
    .line 166
    .line 167
    move-result v1

    .line 168
    if-eqz v1, :cond_ae

    .line 169
    .line 170
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 171
    .line 172
    .line 173
    move-result-object v0

    .line 174
    return-object v0

    .line 175
    :cond_ae
    invoke-virtual {v5}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 176
    .line 177
    .line 178
    move-result-object v0

    .line 179
    return-object v0

    .line 180
    :cond_b3
    invoke-static {v7, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 181
    .line 182
    .line 183
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 184
    .line 185
    .line 186
    new-array v0, v11, [I

    .line 187
    .line 188
    invoke-static {v13, v7, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 189
    .line 190
    .line 191
    invoke-static {v9, v0}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 192
    .line 193
    .line 194
    invoke-static {v13, v2, v9}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 195
    .line 196
    .line 197
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 198
    .line 199
    .line 200
    sget-object v2, Lcom/kousei/framework/h0;->I:[I

    .line 201
    .line 202
    invoke-static {v11, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 203
    .line 204
    .line 205
    move-result v4

    .line 206
    if-eqz v4, :cond_d3

    .line 207
    .line 208
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 209
    .line 210
    .line 211
    goto :goto_d6

    .line 212
    :cond_d3
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 213
    .line 214
    .line 215
    :goto_d6
    invoke-static {v3, v0, v10}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 216
    .line 217
    .line 218
    invoke-static {v13, v13, v0}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 219
    .line 220
    .line 221
    move-result v2

    .line 222
    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->V1(I[I)V

    .line 223
    .line 224
    .line 225
    new-instance v2, Lcom/kousei/framework/z8;

    .line 226
    .line 227
    invoke-direct {v2, v14}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 228
    .line 229
    .line 230
    invoke-static {v12, v9}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 231
    .line 232
    .line 233
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 234
    .line 235
    .line 236
    invoke-static {v14, v0, v14}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 237
    .line 238
    .line 239
    new-instance v3, Lcom/kousei/framework/z8;

    .line 240
    .line 241
    invoke-direct {v3, v0}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 242
    .line 243
    .line 244
    invoke-static {v13, v14, v0}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 245
    .line 246
    .line 247
    sget-object v4, Lcom/kousei/framework/h0;->J:[I

    .line 248
    .line 249
    invoke-static {v0, v12, v10}, Lcom/kousei/framework/n6;->A0([I[I[I)I

    .line 250
    .line 251
    .line 252
    move-result v11

    .line 253
    const/4 v12, 0x1

    .line 254
    if-nez v11, :cond_10f

    .line 255
    .line 256
    const/16 v11, 0xf

    .line 257
    .line 258
    aget v11, v10, v11

    .line 259
    .line 260
    ushr-int/2addr v11, v12

    .line 261
    const v13, 0x7fffffff

    .line 262
    .line 263
    .line 264
    if-lt v11, v13, :cond_112

    .line 265
    .line 266
    invoke-static {v8, v10, v4}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 267
    .line 268
    .line 269
    move-result v11

    .line 270
    if-eqz v11, :cond_112

    .line 271
    .line 272
    :cond_10f
    invoke-static {v8, v4, v10}, Lcom/kousei/framework/n6;->g1(I[I[I)V

    .line 273
    .line 274
    .line 275
    :cond_112
    invoke-static {v10, v0}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 276
    .line 277
    .line 278
    new-instance v0, Lcom/kousei/framework/z8;

    .line 279
    .line 280
    invoke-direct {v0, v7}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 281
    .line 282
    .line 283
    if-nez v15, :cond_11f

    .line 284
    .line 285
    invoke-static {v7, v6, v7, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 286
    .line 287
    .line 288
    :cond_11f
    if-nez v16, :cond_124

    .line 289
    .line 290
    invoke-static {v7, v1, v7, v9}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 291
    .line 292
    .line 293
    :cond_124
    new-array v1, v12, [Lcom/kousei/framework/h0;

    .line 294
    .line 295
    aput-object v0, v1, v17

    .line 296
    .line 297
    new-instance v18, Lcom/kousei/framework/b2;

    .line 298
    .line 299
    const/16 v23, 0xc

    .line 300
    .line 301
    move-object/from16 v22, v1

    .line 302
    .line 303
    move-object/from16 v20, v2

    .line 304
    .line 305
    move-object/from16 v21, v3

    .line 306
    .line 307
    move-object/from16 v19, v5

    .line 308
    .line 309
    invoke-direct/range {v18 .. v23}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 310
    .line 311
    .line 312
    return-object v18
.end method

.method private final t(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 26

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 6
    .line 7
    .line 8
    move-result v2

    .line 9
    if-eqz v2, :cond_b

    .line 10
    .line 11
    return-object v1

    .line 12
    :cond_b
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 13
    .line 14
    .line 15
    move-result v2

    .line 16
    if-eqz v2, :cond_12

    .line 17
    .line 18
    return-object v0

    .line 19
    :cond_12
    if-ne v0, v1, :cond_19

    .line 20
    .line 21
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    return-object v0

    .line 26
    :cond_19
    iget-object v2, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 27
    .line 28
    check-cast v2, Lcom/kousei/framework/b9;

    .line 29
    .line 30
    iget-object v3, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 31
    .line 32
    check-cast v3, Lcom/kousei/framework/b9;

    .line 33
    .line 34
    iget-object v4, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 35
    .line 36
    check-cast v4, Lcom/kousei/framework/b9;

    .line 37
    .line 38
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object v5

    .line 42
    check-cast v5, Lcom/kousei/framework/b9;

    .line 43
    .line 44
    iget-object v6, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 45
    .line 46
    const/4 v7, 0x0

    .line 47
    aget-object v6, v6, v7

    .line 48
    .line 49
    check-cast v6, Lcom/kousei/framework/b9;

    .line 50
    .line 51
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    .line 52
    .line 53
    .line 54
    move-result-object v1

    .line 55
    check-cast v1, Lcom/kousei/framework/b9;

    .line 56
    .line 57
    const/16 v8, 0x18

    .line 58
    .line 59
    new-array v9, v8, [I

    .line 60
    .line 61
    new-array v10, v8, [I

    .line 62
    .line 63
    new-array v11, v8, [I

    .line 64
    .line 65
    const/16 v12, 0xc

    .line 66
    .line 67
    new-array v13, v12, [I

    .line 68
    .line 69
    new-array v14, v12, [I

    .line 70
    .line 71
    invoke-virtual {v6}, Lcom/kousei/framework/b9;->A0()Z

    .line 72
    .line 73
    .line 74
    move-result v15

    .line 75
    iget-object v6, v6, Lcom/kousei/framework/b9;->S:[I

    .line 76
    .line 77
    if-eqz v15, :cond_53

    .line 78
    .line 79
    iget-object v4, v4, Lcom/kousei/framework/b9;->S:[I

    .line 80
    .line 81
    iget-object v5, v5, Lcom/kousei/framework/b9;->S:[I

    .line 82
    .line 83
    goto :goto_6b

    .line 84
    :cond_53
    invoke-static {v6, v9}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 85
    .line 86
    .line 87
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 88
    .line 89
    .line 90
    iget-object v4, v4, Lcom/kousei/framework/b9;->S:[I

    .line 91
    .line 92
    invoke-static {v13, v4, v11, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 93
    .line 94
    .line 95
    invoke-static {v13, v6, v9}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 96
    .line 97
    .line 98
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 99
    .line 100
    .line 101
    iget-object v4, v5, Lcom/kousei/framework/b9;->S:[I

    .line 102
    .line 103
    invoke-static {v13, v4, v13, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 104
    .line 105
    .line 106
    move-object v4, v11

    .line 107
    move-object v5, v13

    .line 108
    :goto_6b
    invoke-virtual {v1}, Lcom/kousei/framework/b9;->A0()Z

    .line 109
    .line 110
    .line 111
    move-result v16

    .line 112
    iget-object v1, v1, Lcom/kousei/framework/b9;->S:[I

    .line 113
    .line 114
    if-eqz v16, :cond_7a

    .line 115
    .line 116
    iget-object v2, v2, Lcom/kousei/framework/b9;->S:[I

    .line 117
    .line 118
    iget-object v3, v3, Lcom/kousei/framework/b9;->S:[I

    .line 119
    .line 120
    :goto_77
    move/from16 v17, v7

    .line 121
    .line 122
    goto :goto_93

    .line 123
    :cond_7a
    invoke-static {v1, v9}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 124
    .line 125
    .line 126
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 127
    .line 128
    .line 129
    iget-object v2, v2, Lcom/kousei/framework/b9;->S:[I

    .line 130
    .line 131
    invoke-static {v14, v2, v10, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 132
    .line 133
    .line 134
    invoke-static {v14, v1, v9}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 135
    .line 136
    .line 137
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 138
    .line 139
    .line 140
    iget-object v2, v3, Lcom/kousei/framework/b9;->S:[I

    .line 141
    .line 142
    invoke-static {v14, v2, v14, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 143
    .line 144
    .line 145
    move-object v2, v10

    .line 146
    move-object v3, v14

    .line 147
    goto :goto_77

    .line 148
    :goto_93
    new-array v7, v12, [I

    .line 149
    .line 150
    invoke-static {v2, v4, v7}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 151
    .line 152
    .line 153
    new-array v4, v12, [I

    .line 154
    .line 155
    invoke-static {v3, v5, v4}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 156
    .line 157
    .line 158
    invoke-static {v12, v7}, Lcom/kousei/framework/n6;->o0(I[I)Z

    .line 159
    .line 160
    .line 161
    move-result v5

    .line 162
    iget-object v8, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 163
    .line 164
    if-eqz v5, :cond_b5

    .line 165
    .line 166
    invoke-static {v12, v4}, Lcom/kousei/framework/n6;->o0(I[I)Z

    .line 167
    .line 168
    .line 169
    move-result v1

    .line 170
    if-eqz v1, :cond_b0

    .line 171
    .line 172
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 173
    .line 174
    .line 175
    move-result-object v0

    .line 176
    return-object v0

    .line 177
    :cond_b0
    invoke-virtual {v8}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 178
    .line 179
    .line 180
    move-result-object v0

    .line 181
    return-object v0

    .line 182
    :cond_b5
    invoke-static {v7, v9}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 183
    .line 184
    .line 185
    invoke-static {v9, v13}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 186
    .line 187
    .line 188
    new-array v0, v12, [I

    .line 189
    .line 190
    invoke-static {v13, v7, v9}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 191
    .line 192
    .line 193
    invoke-static {v9, v0}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 194
    .line 195
    .line 196
    invoke-static {v13, v2, v13, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 197
    .line 198
    .line 199
    sget-object v2, Lcom/kousei/framework/h0;->K:[I

    .line 200
    .line 201
    invoke-static {v12, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 202
    .line 203
    .line 204
    move-result v5

    .line 205
    if-eqz v5, :cond_d2

    .line 206
    .line 207
    invoke-static {v12, v2, v2, v0}, Lcom/kousei/framework/n6;->a1(I[I[I[I)I

    .line 208
    .line 209
    .line 210
    goto :goto_d5

    .line 211
    :cond_d2
    invoke-static {v12, v2, v0, v0}, Lcom/kousei/framework/n6;->a1(I[I[I[I)I

    .line 212
    .line 213
    .line 214
    :goto_d5
    invoke-static {v3, v0, v10}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 215
    .line 216
    .line 217
    invoke-static {v12, v13, v13, v0}, Lcom/kousei/framework/n6;->e(I[I[I[I)I

    .line 218
    .line 219
    .line 220
    move-result v2

    .line 221
    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->N1(I[I)V

    .line 222
    .line 223
    .line 224
    new-instance v2, Lcom/kousei/framework/b9;

    .line 225
    .line 226
    invoke-direct {v2, v14}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 227
    .line 228
    .line 229
    invoke-static {v4, v9}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 230
    .line 231
    .line 232
    invoke-static {v9, v14}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 233
    .line 234
    .line 235
    invoke-static {v14, v0, v14}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 236
    .line 237
    .line 238
    new-instance v3, Lcom/kousei/framework/b9;

    .line 239
    .line 240
    invoke-direct {v3, v0}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 241
    .line 242
    .line 243
    invoke-static {v13, v14, v0}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 244
    .line 245
    .line 246
    invoke-static {v0, v4, v11}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 247
    .line 248
    .line 249
    const/16 v4, 0x18

    .line 250
    .line 251
    invoke-static {v4, v10, v11, v10}, Lcom/kousei/framework/n6;->a(I[I[I[I)I

    .line 252
    .line 253
    .line 254
    move-result v5

    .line 255
    if-nez v5, :cond_10f

    .line 256
    .line 257
    const/16 v5, 0x17

    .line 258
    .line 259
    aget v5, v10, v5

    .line 260
    .line 261
    const/4 v11, -0x1

    .line 262
    if-ne v5, v11, :cond_11c

    .line 263
    .line 264
    sget-object v5, Lcom/kousei/framework/h0;->L:[I

    .line 265
    .line 266
    invoke-static {v4, v10, v5}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 267
    .line 268
    .line 269
    move-result v5

    .line 270
    if-eqz v5, :cond_11c

    .line 271
    .line 272
    :cond_10f
    sget-object v5, Lcom/kousei/framework/h0;->M:[I

    .line 273
    .line 274
    const/16 v11, 0x11

    .line 275
    .line 276
    invoke-static {v11, v5, v10}, Lcom/kousei/framework/n6;->m(I[I[I)I

    .line 277
    .line 278
    .line 279
    move-result v5

    .line 280
    if-eqz v5, :cond_11c

    .line 281
    .line 282
    invoke-static {v4, v11, v10}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 283
    .line 284
    .line 285
    :cond_11c
    invoke-static {v10, v0}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 286
    .line 287
    .line 288
    new-instance v0, Lcom/kousei/framework/b9;

    .line 289
    .line 290
    invoke-direct {v0, v7}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 291
    .line 292
    .line 293
    if-nez v15, :cond_129

    .line 294
    .line 295
    invoke-static {v7, v6, v7, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 296
    .line 297
    .line 298
    :cond_129
    if-nez v16, :cond_12e

    .line 299
    .line 300
    invoke-static {v7, v1, v7, v9}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 301
    .line 302
    .line 303
    :cond_12e
    const/4 v1, 0x1

    .line 304
    new-array v1, v1, [Lcom/kousei/framework/h0;

    .line 305
    .line 306
    aput-object v0, v1, v17

    .line 307
    .line 308
    new-instance v18, Lcom/kousei/framework/b2;

    .line 309
    .line 310
    const/16 v23, 0xd

    .line 311
    .line 312
    move-object/from16 v22, v1

    .line 313
    .line 314
    move-object/from16 v20, v2

    .line 315
    .line 316
    move-object/from16 v21, v3

    .line 317
    .line 318
    move-object/from16 v19, v8

    .line 319
    .line 320
    invoke-direct/range {v18 .. v23}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 321
    .line 322
    .line 323
    return-object v18
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 41

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    iget v2, v0, Lcom/kousei/framework/b2;->h:I

    const/4 v10, 0x4

    const/4 v12, 0x6

    const/16 v13, 0xc

    const-wide/16 v16, 0x0

    const/16 v5, 0xa

    const/4 v6, 0x5

    const-wide v18, 0xffffffffL

    const/4 v7, 0x7

    const/16 v20, 0x20

    const/4 v9, -0x1

    const/16 v21, 0xb

    iget-object v14, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    const/16 v23, 0xf

    iget-object v3, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    const/16 v24, 0x2

    iget-object v15, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    const/16 v26, 0x0

    packed-switch v2, :pswitch_data_df2

    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_32

    move-object v0, v1

    goto/16 :goto_136

    :cond_32
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_3a

    goto/16 :goto_136

    :cond_3a
    if-ne v0, v1, :cond_42

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_136

    .line 1
    :cond_42
    check-cast v15, Lcom/kousei/framework/d9;

    check-cast v3, Lcom/kousei/framework/d9;

    .line 2
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 3
    check-cast v2, Lcom/kousei/framework/d9;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v5

    check-cast v5, Lcom/kousei/framework/d9;

    aget-object v6, v14, v26

    check-cast v6, Lcom/kousei/framework/d9;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/d9;

    const/16 v7, 0x21

    .line 4
    new-array v7, v7, [I

    const/16 v8, 0x11

    new-array v9, v8, [I

    new-array v10, v8, [I

    new-array v11, v8, [I

    new-array v12, v8, [I

    .line 5
    invoke-virtual {v6}, Lcom/kousei/framework/d9;->A0()Z

    move-result v13

    iget-object v6, v6, Lcom/kousei/framework/d9;->S:[I

    if-eqz v13, :cond_75

    iget-object v2, v2, Lcom/kousei/framework/d9;->S:[I

    iget-object v5, v5, Lcom/kousei/framework/d9;->S:[I

    goto :goto_8d

    .line 6
    :cond_75
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->v0([I[I)V

    invoke-static {v7, v11}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 7
    iget-object v2, v2, Lcom/kousei/framework/d9;->S:[I

    invoke-static {v11, v2, v10, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    .line 8
    invoke-static {v11, v6, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v11}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 9
    iget-object v2, v5, Lcom/kousei/framework/d9;->S:[I

    invoke-static {v11, v2, v11, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    move-object v2, v10

    move-object v5, v11

    :goto_8d
    invoke-virtual {v1}, Lcom/kousei/framework/d9;->A0()Z

    move-result v14

    iget-object v1, v1, Lcom/kousei/framework/d9;->S:[I

    if-eqz v14, :cond_9a

    iget-object v15, v15, Lcom/kousei/framework/d9;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/d9;->S:[I

    goto :goto_b2

    .line 10
    :cond_9a
    invoke-static {v1, v7}, Lcom/kousei/framework/h0;->v0([I[I)V

    invoke-static {v7, v12}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 11
    iget-object v15, v15, Lcom/kousei/framework/d9;->S:[I

    invoke-static {v12, v15, v9, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    .line 12
    invoke-static {v12, v1, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v12}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 13
    iget-object v3, v3, Lcom/kousei/framework/d9;->S:[I

    invoke-static {v12, v3, v12, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    move-object v15, v9

    move-object v3, v12

    .line 14
    :goto_b2
    new-array v4, v8, [I

    .line 15
    invoke-static {v15, v2, v4}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    invoke-static {v3, v5, v10}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    invoke-static {v8, v4}, Lcom/kousei/framework/n6;->o0(I[I)Z

    move-result v2

    iget-object v5, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_d2

    invoke-static {v8, v10}, Lcom/kousei/framework/n6;->o0(I[I)Z

    move-result v1

    if-eqz v1, :cond_cd

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_136

    :cond_cd
    invoke-virtual {v5}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_136

    .line 16
    :cond_d2
    invoke-static {v4, v7}, Lcom/kousei/framework/h0;->v0([I[I)V

    invoke-static {v7, v11}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 17
    new-array v0, v8, [I

    .line 18
    invoke-static {v11, v4, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v0}, Lcom/kousei/framework/h0;->y1([I[I)V

    invoke-static {v11, v15, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v11}, Lcom/kousei/framework/h0;->y1([I[I)V

    invoke-static {v3, v0, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 19
    new-instance v2, Lcom/kousei/framework/d9;

    invoke-direct {v2, v12}, Lcom/kousei/framework/d9;-><init>([I)V

    .line 20
    invoke-static {v10, v7}, Lcom/kousei/framework/h0;->v0([I[I)V

    invoke-static {v7, v12}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 21
    invoke-static {v12, v0, v12}, Lcom/kousei/framework/h0;->h([I[I[I)V

    invoke-static {v12, v11, v12}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    invoke-static {v12, v11, v12}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/d9;

    invoke-direct {v3, v0}, Lcom/kousei/framework/d9;-><init>([I)V

    invoke-static {v11, v12, v0}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 22
    invoke-static {v0, v10, v7}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    invoke-static {v7, v10}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 23
    invoke-static {v10, v9, v0}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    new-instance v0, Lcom/kousei/framework/d9;

    invoke-direct {v0, v4}, Lcom/kousei/framework/d9;-><init>([I)V

    if-nez v13, :cond_11b

    invoke-static {v4, v6, v4, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    :cond_11b
    if-nez v14, :cond_120

    invoke-static {v4, v1, v4, v7}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    :cond_120
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v16, Lcom/kousei/framework/b2;

    const/16 v21, 0xe

    move-object/from16 v20, v1

    move-object/from16 v18, v2

    move-object/from16 v19, v3

    move-object/from16 v17, v5

    .line 24
    invoke-direct/range {v16 .. v21}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v16

    :goto_136
    return-object v0

    .line 25
    :pswitch_137
    invoke-direct/range {p0 .. p1}, Lcom/kousei/framework/b2;->t(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    move-result-object v0

    return-object v0

    :pswitch_13c
    invoke-direct/range {p0 .. p1}, Lcom/kousei/framework/b2;->s(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    move-result-object v0

    return-object v0

    :pswitch_141
    invoke-direct/range {p0 .. p1}, Lcom/kousei/framework/b2;->r(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    move-result-object v0

    return-object v0

    :pswitch_146
    invoke-direct/range {p0 .. p1}, Lcom/kousei/framework/b2;->q(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    move-result-object v0

    return-object v0

    :pswitch_14b
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_154

    move-object v0, v1

    goto/16 :goto_266

    :cond_154
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_15c

    goto/16 :goto_266

    :cond_15c
    if-ne v0, v1, :cond_164

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_266

    .line 26
    :cond_164
    check-cast v15, Lcom/kousei/framework/t8;

    check-cast v3, Lcom/kousei/framework/t8;

    .line 27
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 28
    check-cast v2, Lcom/kousei/framework/t8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/t8;

    aget-object v5, v14, v26

    check-cast v5, Lcom/kousei/framework/t8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/t8;

    const/16 v6, 0xe

    .line 29
    new-array v8, v6, [I

    .line 30
    new-array v10, v7, [I

    new-array v12, v7, [I

    new-array v13, v7, [I

    .line 31
    iget-object v5, v5, Lcom/kousei/framework/t8;->S:[I

    .line 32
    invoke-static {v5}, Lcom/kousei/framework/n6;->l0([I)Z

    move-result v14

    if-eqz v14, :cond_193

    .line 33
    iget-object v2, v2, Lcom/kousei/framework/t8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/t8;->S:[I

    goto :goto_1a5

    :cond_193
    invoke-static {v5, v12}, Lcom/kousei/framework/h0;->j2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/t8;->S:[I

    invoke-static {v12, v2, v10}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    invoke-static {v12, v5, v12}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/t8;->S:[I

    invoke-static {v12, v2, v12}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    move-object v2, v10

    move-object v4, v12

    .line 34
    :goto_1a5
    iget-object v1, v1, Lcom/kousei/framework/t8;->S:[I

    .line 35
    invoke-static {v1}, Lcom/kousei/framework/n6;->l0([I)Z

    move-result v16

    if-eqz v16, :cond_1b2

    .line 36
    iget-object v15, v15, Lcom/kousei/framework/t8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/t8;->S:[I

    goto :goto_1c4

    :cond_1b2
    invoke-static {v1, v13}, Lcom/kousei/framework/h0;->j2([I[I)V

    iget-object v15, v15, Lcom/kousei/framework/t8;->S:[I

    invoke-static {v13, v15, v8}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    invoke-static {v13, v1, v13}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/t8;->S:[I

    invoke-static {v13, v3, v13}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    move-object v15, v8

    move-object v3, v13

    .line 37
    :goto_1c4
    new-array v11, v7, [I

    .line 38
    invoke-static {v15, v2, v11}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    invoke-static {v3, v4, v10}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    invoke-static {v11}, Lcom/kousei/framework/n6;->p0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_1e6

    invoke-static {v10}, Lcom/kousei/framework/n6;->p0([I)Z

    move-result v1

    if-eqz v1, :cond_1e0

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_266

    :cond_1e0
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_266

    :cond_1e6
    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 39
    new-array v0, v7, [I

    .line 40
    invoke-static {v12, v11, v0}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    invoke-static {v12, v15, v12}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 41
    sget-object v2, Lcom/kousei/framework/h0;->z:[I

    .line 42
    invoke-static {v7, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v7

    if-eqz v7, :cond_1fd

    .line 43
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/n6;->b1([I[I[I)I

    goto :goto_200

    :cond_1fd
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/n6;->b1([I[I[I)I

    .line 44
    :goto_200
    invoke-static {v3, v0, v8}, Lcom/kousei/framework/n6;->w0([I[I[I)V

    invoke-static {v12, v12, v0}, Lcom/kousei/framework/n6;->f([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->S1(I[I)V

    new-instance v2, Lcom/kousei/framework/t8;

    invoke-direct {v2, v13}, Lcom/kousei/framework/t8;-><init>([I)V

    invoke-static {v10, v13}, Lcom/kousei/framework/h0;->j2([I[I)V

    invoke-static {v13, v0, v13}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/t8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    invoke-static {v12, v13, v0}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 45
    invoke-static {v0, v10, v8}, Lcom/kousei/framework/n6;->z0([I[I[I)I

    move-result v7

    if-nez v7, :cond_231

    const/16 v7, 0xd

    aget v7, v8, v7

    if-ne v7, v9, :cond_23e

    sget-object v7, Lcom/kousei/framework/h0;->A:[I

    invoke-static {v6, v8, v7}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v7

    if-eqz v7, :cond_23e

    :cond_231
    sget-object v7, Lcom/kousei/framework/h0;->B:[I

    const/16 v9, 0x9

    invoke-static {v9, v7, v8}, Lcom/kousei/framework/n6;->m(I[I[I)I

    move-result v7

    if-eqz v7, :cond_23e

    invoke-static {v6, v9, v8}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 46
    :cond_23e
    invoke-static {v8, v0}, Lcom/kousei/framework/h0;->G1([I[I)V

    new-instance v0, Lcom/kousei/framework/t8;

    invoke-direct {v0, v11}, Lcom/kousei/framework/t8;-><init>([I)V

    if-nez v14, :cond_24b

    invoke-static {v11, v5, v11}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    :cond_24b
    if-nez v16, :cond_250

    invoke-static {v11, v1, v11}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    :cond_250
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v17, Lcom/kousei/framework/b2;

    const/16 v22, 0x9

    move-object/from16 v21, v1

    move-object/from16 v19, v2

    move-object/from16 v20, v3

    move-object/from16 v18, v4

    .line 47
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v17

    :goto_266
    return-object v0

    .line 48
    :pswitch_267
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_270

    move-object v0, v1

    goto/16 :goto_383

    :cond_270
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_278

    goto/16 :goto_383

    :cond_278
    if-ne v0, v1, :cond_280

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_383

    .line 49
    :cond_280
    check-cast v15, Lcom/kousei/framework/r8;

    check-cast v3, Lcom/kousei/framework/r8;

    .line 50
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 51
    check-cast v2, Lcom/kousei/framework/r8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/r8;

    aget-object v5, v14, v26

    check-cast v5, Lcom/kousei/framework/r8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/r8;

    .line 52
    new-array v6, v13, [I

    .line 53
    new-array v7, v12, [I

    new-array v8, v12, [I

    new-array v10, v12, [I

    .line 54
    iget-object v5, v5, Lcom/kousei/framework/r8;->S:[I

    .line 55
    invoke-static {v5}, Lcom/kousei/framework/h0;->D0([I)Z

    move-result v11

    if-eqz v11, :cond_2ad

    .line 56
    iget-object v2, v2, Lcom/kousei/framework/r8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/r8;->S:[I

    goto :goto_2bf

    :cond_2ad
    invoke-static {v5, v8}, Lcom/kousei/framework/h0;->i2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/r8;->S:[I

    invoke-static {v8, v2, v7}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    invoke-static {v8, v5, v8}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/r8;->S:[I

    invoke-static {v8, v2, v8}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    move-object v2, v7

    move-object v4, v8

    .line 57
    :goto_2bf
    iget-object v1, v1, Lcom/kousei/framework/r8;->S:[I

    .line 58
    invoke-static {v1}, Lcom/kousei/framework/h0;->D0([I)Z

    move-result v14

    if-eqz v14, :cond_2cc

    .line 59
    iget-object v15, v15, Lcom/kousei/framework/r8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/r8;->S:[I

    goto :goto_2de

    :cond_2cc
    invoke-static {v1, v10}, Lcom/kousei/framework/h0;->i2([I[I)V

    iget-object v15, v15, Lcom/kousei/framework/r8;->S:[I

    invoke-static {v10, v15, v6}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    invoke-static {v10, v1, v10}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/r8;->S:[I

    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    move-object v15, v6

    move-object v3, v10

    .line 60
    :goto_2de
    new-array v13, v12, [I

    .line 61
    invoke-static {v15, v2, v13}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    invoke-static {v3, v4, v7}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    invoke-static {v13}, Lcom/kousei/framework/h0;->H0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_300

    invoke-static {v7}, Lcom/kousei/framework/h0;->H0([I)Z

    move-result v1

    if-eqz v1, :cond_2fa

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_383

    :cond_2fa
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_383

    :cond_300
    invoke-static {v13, v8}, Lcom/kousei/framework/h0;->i2([I[I)V

    .line 62
    new-array v0, v12, [I

    .line 63
    invoke-static {v8, v13, v0}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    invoke-static {v8, v15, v8}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    .line 64
    sget-object v2, Lcom/kousei/framework/h0;->w:[I

    .line 65
    invoke-static {v12, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v12

    if-eqz v12, :cond_317

    .line 66
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->H2([I[I[I)I

    goto :goto_31a

    :cond_317
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->H2([I[I[I)I

    .line 67
    :goto_31a
    invoke-static {v3, v0, v6}, Lcom/kousei/framework/h0;->N0([I[I[I)V

    invoke-static {v8, v8, v0}, Lcom/kousei/framework/h0;->m([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->R1(I[I)V

    new-instance v2, Lcom/kousei/framework/r8;

    invoke-direct {v2, v10}, Lcom/kousei/framework/r8;-><init>([I)V

    invoke-static {v7, v10}, Lcom/kousei/framework/h0;->i2([I[I)V

    invoke-static {v10, v0, v10}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/r8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/r8;-><init>([I)V

    invoke-static {v8, v10, v0}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 68
    invoke-static {v0, v7, v6}, Lcom/kousei/framework/h0;->P0([I[I[I)I

    move-result v7

    if-nez v7, :cond_34c

    aget v7, v6, v21

    if-ne v7, v9, :cond_35b

    sget-object v7, Lcom/kousei/framework/h0;->x:[I

    const/16 v8, 0xc

    invoke-static {v8, v6, v7}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v7

    if-eqz v7, :cond_35b

    goto :goto_34e

    :cond_34c
    const/16 v8, 0xc

    :goto_34e
    sget-object v7, Lcom/kousei/framework/h0;->y:[I

    const/16 v9, 0x9

    invoke-static {v9, v7, v6}, Lcom/kousei/framework/n6;->m(I[I[I)I

    move-result v7

    if-eqz v7, :cond_35b

    invoke-static {v8, v9, v6}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 69
    :cond_35b
    invoke-static {v6, v0}, Lcom/kousei/framework/h0;->F1([I[I)V

    new-instance v0, Lcom/kousei/framework/r8;

    invoke-direct {v0, v13}, Lcom/kousei/framework/r8;-><init>([I)V

    if-nez v11, :cond_368

    invoke-static {v13, v5, v13}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    :cond_368
    if-nez v14, :cond_36d

    invoke-static {v13, v1, v13}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    :cond_36d
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v30, Lcom/kousei/framework/b2;

    const/16 v35, 0x8

    move-object/from16 v34, v1

    move-object/from16 v32, v2

    move-object/from16 v33, v3

    move-object/from16 v31, v4

    .line 70
    invoke-direct/range {v30 .. v35}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v30

    :goto_383
    return-object v0

    .line 71
    :pswitch_384
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_38d

    move-object v0, v1

    goto/16 :goto_4a2

    :cond_38d
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_395

    goto/16 :goto_4a2

    :cond_395
    if-ne v0, v1, :cond_39d

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_4a2

    .line 72
    :cond_39d
    check-cast v15, Lcom/kousei/framework/p8;

    check-cast v3, Lcom/kousei/framework/p8;

    .line 73
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 74
    check-cast v2, Lcom/kousei/framework/p8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/p8;

    aget-object v5, v14, v26

    check-cast v5, Lcom/kousei/framework/p8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/p8;

    const/16 v6, 0xc

    .line 75
    new-array v7, v6, [I

    .line 76
    new-array v6, v12, [I

    new-array v10, v12, [I

    new-array v11, v12, [I

    .line 77
    iget-object v5, v5, Lcom/kousei/framework/p8;->S:[I

    .line 78
    invoke-static {v5}, Lcom/kousei/framework/h0;->D0([I)Z

    move-result v13

    if-eqz v13, :cond_3cc

    .line 79
    iget-object v2, v2, Lcom/kousei/framework/p8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/p8;->S:[I

    goto :goto_3de

    :cond_3cc
    invoke-static {v5, v10}, Lcom/kousei/framework/h0;->h2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/p8;->S:[I

    invoke-static {v10, v2, v6}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    invoke-static {v10, v5, v10}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/p8;->S:[I

    invoke-static {v10, v2, v10}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    move-object v2, v6

    move-object v4, v10

    .line 80
    :goto_3de
    iget-object v1, v1, Lcom/kousei/framework/p8;->S:[I

    .line 81
    invoke-static {v1}, Lcom/kousei/framework/h0;->D0([I)Z

    move-result v14

    if-eqz v14, :cond_3eb

    .line 82
    iget-object v15, v15, Lcom/kousei/framework/p8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/p8;->S:[I

    goto :goto_3fd

    :cond_3eb
    invoke-static {v1, v11}, Lcom/kousei/framework/h0;->h2([I[I)V

    iget-object v15, v15, Lcom/kousei/framework/p8;->S:[I

    invoke-static {v11, v15, v7}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    invoke-static {v11, v1, v11}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/p8;->S:[I

    invoke-static {v11, v3, v11}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    move-object v15, v7

    move-object v3, v11

    .line 83
    :goto_3fd
    new-array v8, v12, [I

    .line 84
    invoke-static {v15, v2, v8}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    invoke-static {v3, v4, v6}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    invoke-static {v8}, Lcom/kousei/framework/h0;->H0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_41f

    invoke-static {v6}, Lcom/kousei/framework/h0;->H0([I)Z

    move-result v1

    if-eqz v1, :cond_419

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_4a2

    :cond_419
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_4a2

    :cond_41f
    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->h2([I[I)V

    .line 85
    new-array v0, v12, [I

    .line 86
    invoke-static {v10, v8, v0}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    invoke-static {v10, v15, v10}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    .line 87
    sget-object v2, Lcom/kousei/framework/h0;->t:[I

    .line 88
    invoke-static {v12, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v12

    if-eqz v12, :cond_436

    .line 89
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->H2([I[I[I)I

    goto :goto_439

    :cond_436
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->H2([I[I[I)I

    .line 90
    :goto_439
    invoke-static {v3, v0, v7}, Lcom/kousei/framework/h0;->N0([I[I[I)V

    invoke-static {v10, v10, v0}, Lcom/kousei/framework/h0;->m([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->Q1(I[I)V

    new-instance v2, Lcom/kousei/framework/p8;

    invoke-direct {v2, v11}, Lcom/kousei/framework/p8;-><init>([I)V

    invoke-static {v6, v11}, Lcom/kousei/framework/h0;->h2([I[I)V

    invoke-static {v11, v0, v11}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/p8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/p8;-><init>([I)V

    invoke-static {v10, v11, v0}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    .line 91
    invoke-static {v0, v6, v7}, Lcom/kousei/framework/h0;->P0([I[I[I)I

    move-result v6

    if-nez v6, :cond_46b

    aget v6, v7, v21

    if-ne v6, v9, :cond_47a

    sget-object v6, Lcom/kousei/framework/h0;->u:[I

    const/16 v9, 0xc

    invoke-static {v9, v7, v6}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v6

    if-eqz v6, :cond_47a

    goto :goto_46d

    :cond_46b
    const/16 v9, 0xc

    :goto_46d
    sget-object v6, Lcom/kousei/framework/h0;->v:[I

    const/16 v10, 0x8

    invoke-static {v10, v6, v7}, Lcom/kousei/framework/n6;->m(I[I[I)I

    move-result v6

    if-eqz v6, :cond_47a

    invoke-static {v9, v10, v7}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 92
    :cond_47a
    invoke-static {v7, v0}, Lcom/kousei/framework/h0;->E1([I[I)V

    new-instance v0, Lcom/kousei/framework/p8;

    invoke-direct {v0, v8}, Lcom/kousei/framework/p8;-><init>([I)V

    if-nez v13, :cond_487

    invoke-static {v8, v5, v8}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    :cond_487
    if-nez v14, :cond_48c

    invoke-static {v8, v1, v8}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    :cond_48c
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v31, Lcom/kousei/framework/b2;

    const/16 v36, 0x7

    move-object/from16 v35, v1

    move-object/from16 v33, v2

    move-object/from16 v34, v3

    move-object/from16 v32, v4

    .line 93
    invoke-direct/range {v31 .. v36}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v31

    :goto_4a2
    return-object v0

    .line 94
    :pswitch_4a3
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_4ac

    move-object v0, v1

    goto/16 :goto_59b

    :cond_4ac
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_4b4

    goto/16 :goto_59b

    :cond_4b4
    if-ne v0, v1, :cond_4bc

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_59b

    .line 95
    :cond_4bc
    check-cast v15, Lcom/kousei/framework/n8;

    check-cast v3, Lcom/kousei/framework/n8;

    .line 96
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 97
    check-cast v2, Lcom/kousei/framework/n8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/n8;

    aget-object v7, v14, v26

    check-cast v7, Lcom/kousei/framework/n8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/n8;

    .line 98
    new-array v5, v5, [I

    .line 99
    new-array v8, v6, [I

    new-array v9, v6, [I

    new-array v10, v6, [I

    .line 100
    iget-object v7, v7, Lcom/kousei/framework/n8;->S:[I

    .line 101
    invoke-static {v7}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v11

    if-eqz v11, :cond_4e9

    .line 102
    iget-object v2, v2, Lcom/kousei/framework/n8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/n8;->S:[I

    goto :goto_4fb

    :cond_4e9
    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->g2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v9, v2, v8}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v9, v2, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    move-object v2, v8

    move-object v4, v9

    .line 103
    :goto_4fb
    iget-object v1, v1, Lcom/kousei/framework/n8;->S:[I

    .line 104
    invoke-static {v1}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v12

    if-eqz v12, :cond_508

    .line 105
    iget-object v13, v15, Lcom/kousei/framework/n8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/n8;->S:[I

    goto :goto_51a

    :cond_508
    invoke-static {v1, v10}, Lcom/kousei/framework/h0;->g2([I[I)V

    iget-object v13, v15, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v10, v13, v5}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v10, v1, v10}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    move-object v13, v5

    move-object v3, v10

    .line 106
    :goto_51a
    new-array v14, v6, [I

    .line 107
    invoke-static {v13, v2, v14}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v3, v4, v8}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v14}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_53a

    invoke-static {v8}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v1

    if-eqz v1, :cond_535

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_59b

    :cond_535
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_59b

    :cond_53a
    invoke-static {v14, v9}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 108
    new-array v0, v6, [I

    .line 109
    invoke-static {v9, v14, v0}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v9, v13, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 110
    sget-object v2, Lcom/kousei/framework/h0;->q:[I

    .line 111
    invoke-static {v6, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v6

    if-eqz v6, :cond_551

    .line 112
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    goto :goto_554

    :cond_551
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    .line 113
    :goto_554
    invoke-static {v3, v0, v5}, Lcom/kousei/framework/h0;->M0([I[I[I)V

    invoke-static {v9, v9, v0}, Lcom/kousei/framework/h0;->l([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->P1(I[I)V

    new-instance v2, Lcom/kousei/framework/n8;

    invoke-direct {v2, v10}, Lcom/kousei/framework/n8;-><init>([I)V

    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->g2([I[I)V

    invoke-static {v10, v0, v10}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/n8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/n8;-><init>([I)V

    invoke-static {v9, v10, v0}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v0, v8, v5}, Lcom/kousei/framework/h0;->i1([I[I[I)V

    invoke-static {v5, v0}, Lcom/kousei/framework/h0;->D1([I[I)V

    new-instance v0, Lcom/kousei/framework/n8;

    invoke-direct {v0, v14}, Lcom/kousei/framework/n8;-><init>([I)V

    if-nez v11, :cond_581

    invoke-static {v14, v7, v14}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    :cond_581
    if-nez v12, :cond_586

    invoke-static {v14, v1, v14}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    :cond_586
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v15, Lcom/kousei/framework/b2;

    const/16 v20, 0x6

    move-object/from16 v19, v1

    move-object/from16 v17, v2

    move-object/from16 v18, v3

    move-object/from16 v16, v4

    .line 114
    invoke-direct/range {v15 .. v20}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object v0, v15

    :goto_59b
    return-object v0

    .line 115
    :pswitch_59c
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_5a5

    move-object v0, v1

    goto/16 :goto_6b4

    :cond_5a5
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_5ad

    goto/16 :goto_6b4

    :cond_5ad
    if-ne v0, v1, :cond_5b5

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_6b4

    .line 116
    :cond_5b5
    check-cast v15, Lcom/kousei/framework/l8;

    check-cast v3, Lcom/kousei/framework/l8;

    .line 117
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 118
    check-cast v2, Lcom/kousei/framework/l8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/l8;

    aget-object v8, v14, v26

    check-cast v8, Lcom/kousei/framework/l8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/l8;

    .line 119
    new-array v10, v5, [I

    .line 120
    new-array v11, v6, [I

    new-array v12, v6, [I

    new-array v13, v6, [I

    .line 121
    iget-object v8, v8, Lcom/kousei/framework/l8;->S:[I

    .line 122
    invoke-static {v8}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v14

    if-eqz v14, :cond_5e2

    .line 123
    iget-object v2, v2, Lcom/kousei/framework/l8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/l8;->S:[I

    goto :goto_5f4

    :cond_5e2
    invoke-static {v8, v12}, Lcom/kousei/framework/h0;->f2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/l8;->S:[I

    invoke-static {v12, v2, v11}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    invoke-static {v12, v8, v12}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/l8;->S:[I

    invoke-static {v12, v2, v12}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    move-object v2, v11

    move-object v4, v12

    .line 124
    :goto_5f4
    iget-object v1, v1, Lcom/kousei/framework/l8;->S:[I

    .line 125
    invoke-static {v1}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v16

    if-eqz v16, :cond_601

    .line 126
    iget-object v15, v15, Lcom/kousei/framework/l8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/l8;->S:[I

    goto :goto_613

    :cond_601
    invoke-static {v1, v13}, Lcom/kousei/framework/h0;->f2([I[I)V

    iget-object v15, v15, Lcom/kousei/framework/l8;->S:[I

    invoke-static {v13, v15, v10}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    invoke-static {v13, v1, v13}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/l8;->S:[I

    invoke-static {v13, v3, v13}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    move-object v15, v10

    move-object v3, v13

    .line 127
    :goto_613
    new-array v7, v6, [I

    .line 128
    invoke-static {v15, v2, v7}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    invoke-static {v3, v4, v11}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    invoke-static {v7}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_635

    invoke-static {v11}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v1

    if-eqz v1, :cond_62f

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_6b4

    :cond_62f
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_6b4

    :cond_635
    invoke-static {v7, v12}, Lcom/kousei/framework/h0;->f2([I[I)V

    .line 129
    new-array v0, v6, [I

    .line 130
    invoke-static {v12, v7, v0}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    invoke-static {v12, v15, v12}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    .line 131
    sget-object v2, Lcom/kousei/framework/h0;->n:[I

    .line 132
    invoke-static {v6, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v6

    if-eqz v6, :cond_64c

    .line 133
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    goto :goto_64f

    :cond_64c
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    .line 134
    :goto_64f
    invoke-static {v3, v0, v10}, Lcom/kousei/framework/h0;->M0([I[I[I)V

    invoke-static {v12, v12, v0}, Lcom/kousei/framework/h0;->l([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->O1(I[I)V

    new-instance v2, Lcom/kousei/framework/l8;

    invoke-direct {v2, v13}, Lcom/kousei/framework/l8;-><init>([I)V

    invoke-static {v11, v13}, Lcom/kousei/framework/h0;->f2([I[I)V

    invoke-static {v13, v0, v13}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/l8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/l8;-><init>([I)V

    invoke-static {v12, v13, v0}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 135
    invoke-static {v0, v11, v10}, Lcom/kousei/framework/h0;->O0([I[I[I)I

    move-result v6

    if-nez v6, :cond_680

    const/16 v28, 0x9

    aget v6, v10, v28

    if-ne v6, v9, :cond_68c

    sget-object v6, Lcom/kousei/framework/h0;->o:[I

    invoke-static {v5, v10, v6}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v6

    if-eqz v6, :cond_68c

    :cond_680
    sget-object v6, Lcom/kousei/framework/h0;->p:[I

    const/4 v9, 0x7

    invoke-static {v9, v6, v10}, Lcom/kousei/framework/n6;->m(I[I[I)I

    move-result v6

    if-eqz v6, :cond_68c

    invoke-static {v5, v9, v10}, Lcom/kousei/framework/n6;->h0(II[I)I

    .line 136
    :cond_68c
    invoke-static {v10, v0}, Lcom/kousei/framework/h0;->B1([I[I)V

    new-instance v0, Lcom/kousei/framework/l8;

    invoke-direct {v0, v7}, Lcom/kousei/framework/l8;-><init>([I)V

    if-nez v14, :cond_699

    invoke-static {v7, v8, v7}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    :cond_699
    if-nez v16, :cond_69e

    invoke-static {v7, v1, v7}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    :cond_69e
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v29, Lcom/kousei/framework/b2;

    const/16 v34, 0x5

    move-object/from16 v33, v1

    move-object/from16 v31, v2

    move-object/from16 v32, v3

    move-object/from16 v30, v4

    .line 137
    invoke-direct/range {v29 .. v34}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v29

    :goto_6b4
    return-object v0

    .line 138
    :pswitch_6b5
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_6be

    move-object v0, v1

    goto/16 :goto_7ad

    :cond_6be
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_6c6

    goto/16 :goto_7ad

    :cond_6c6
    if-ne v0, v1, :cond_6ce

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_7ad

    .line 139
    :cond_6ce
    check-cast v15, Lcom/kousei/framework/n8;

    check-cast v3, Lcom/kousei/framework/n8;

    .line 140
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 141
    check-cast v2, Lcom/kousei/framework/n8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/n8;

    aget-object v7, v14, v26

    check-cast v7, Lcom/kousei/framework/n8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/n8;

    .line 142
    new-array v5, v5, [I

    .line 143
    new-array v8, v6, [I

    new-array v9, v6, [I

    new-array v10, v6, [I

    .line 144
    iget-object v7, v7, Lcom/kousei/framework/n8;->S:[I

    .line 145
    invoke-static {v7}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v11

    if-eqz v11, :cond_6fb

    .line 146
    iget-object v2, v2, Lcom/kousei/framework/n8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/n8;->S:[I

    goto :goto_70d

    :cond_6fb
    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->g2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v9, v2, v8}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v9, v2, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    move-object v2, v8

    move-object v4, v9

    .line 147
    :goto_70d
    iget-object v1, v1, Lcom/kousei/framework/n8;->S:[I

    .line 148
    invoke-static {v1}, Lcom/kousei/framework/h0;->C0([I)Z

    move-result v12

    if-eqz v12, :cond_71a

    .line 149
    iget-object v13, v15, Lcom/kousei/framework/n8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/n8;->S:[I

    goto :goto_72c

    :cond_71a
    invoke-static {v1, v10}, Lcom/kousei/framework/h0;->g2([I[I)V

    iget-object v13, v15, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v10, v13, v5}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v10, v1, v10}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/n8;->S:[I

    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    move-object v13, v5

    move-object v3, v10

    .line 150
    :goto_72c
    new-array v14, v6, [I

    .line 151
    invoke-static {v13, v2, v14}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v3, v4, v8}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v14}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_74c

    invoke-static {v8}, Lcom/kousei/framework/h0;->G0([I)Z

    move-result v1

    if-eqz v1, :cond_747

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_7ad

    :cond_747
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto :goto_7ad

    :cond_74c
    invoke-static {v14, v9}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 152
    new-array v0, v6, [I

    .line 153
    invoke-static {v9, v14, v0}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    invoke-static {v9, v13, v9}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 154
    sget-object v2, Lcom/kousei/framework/h0;->q:[I

    .line 155
    invoke-static {v6, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v6

    if-eqz v6, :cond_763

    .line 156
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    goto :goto_766

    :cond_763
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->G2([I[I[I)I

    .line 157
    :goto_766
    invoke-static {v3, v0, v5}, Lcom/kousei/framework/h0;->M0([I[I[I)V

    invoke-static {v9, v9, v0}, Lcom/kousei/framework/h0;->l([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->P1(I[I)V

    new-instance v2, Lcom/kousei/framework/n8;

    invoke-direct {v2, v10}, Lcom/kousei/framework/n8;-><init>([I)V

    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->g2([I[I)V

    invoke-static {v10, v0, v10}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/n8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/n8;-><init>([I)V

    invoke-static {v9, v10, v0}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    invoke-static {v0, v8, v5}, Lcom/kousei/framework/h0;->i1([I[I[I)V

    invoke-static {v5, v0}, Lcom/kousei/framework/h0;->D1([I[I)V

    new-instance v0, Lcom/kousei/framework/n8;

    invoke-direct {v0, v14}, Lcom/kousei/framework/n8;-><init>([I)V

    if-nez v11, :cond_793

    invoke-static {v14, v7, v14}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    :cond_793
    if-nez v12, :cond_798

    invoke-static {v14, v1, v14}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    :cond_798
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v15, Lcom/kousei/framework/b2;

    const/16 v20, 0x4

    move-object/from16 v19, v1

    move-object/from16 v17, v2

    move-object/from16 v18, v3

    move-object/from16 v16, v4

    .line 158
    invoke-direct/range {v15 .. v20}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object v0, v15

    :goto_7ad
    return-object v0

    .line 159
    :pswitch_7ae
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_7b7

    move-object v0, v1

    goto/16 :goto_959

    :cond_7b7
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_7bf

    goto/16 :goto_959

    :cond_7bf
    if-ne v0, v1, :cond_7c7

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_959

    .line 160
    :cond_7c7
    check-cast v15, Lcom/kousei/framework/i8;

    check-cast v3, Lcom/kousei/framework/i8;

    .line 161
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 162
    check-cast v2, Lcom/kousei/framework/i8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/i8;

    aget-object v5, v14, v26

    check-cast v5, Lcom/kousei/framework/i8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/i8;

    const/16 v6, 0x8

    .line 163
    new-array v7, v6, [I

    .line 164
    new-array v6, v10, [I

    new-array v8, v10, [I

    new-array v9, v10, [I

    .line 165
    iget-object v5, v5, Lcom/kousei/framework/i8;->S:[I

    .line 166
    invoke-static {v5}, Lcom/kousei/framework/h0;->B0([I)Z

    move-result v11

    if-eqz v11, :cond_7f6

    .line 167
    iget-object v2, v2, Lcom/kousei/framework/i8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/i8;->S:[I

    goto :goto_808

    :cond_7f6
    invoke-static {v5, v8}, Lcom/kousei/framework/h0;->e2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/i8;->S:[I

    invoke-static {v8, v2, v6}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    invoke-static {v8, v5, v8}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/i8;->S:[I

    invoke-static {v8, v2, v8}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    move-object v2, v6

    move-object v4, v8

    .line 168
    :goto_808
    iget-object v1, v1, Lcom/kousei/framework/i8;->S:[I

    .line 169
    invoke-static {v1}, Lcom/kousei/framework/h0;->B0([I)Z

    move-result v12

    if-eqz v12, :cond_815

    .line 170
    iget-object v13, v15, Lcom/kousei/framework/i8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/i8;->S:[I

    goto :goto_827

    :cond_815
    invoke-static {v1, v9}, Lcom/kousei/framework/h0;->e2([I[I)V

    iget-object v13, v15, Lcom/kousei/framework/i8;->S:[I

    invoke-static {v9, v13, v7}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    invoke-static {v9, v1, v9}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/i8;->S:[I

    invoke-static {v9, v3, v9}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    move-object v13, v7

    move-object v3, v9

    .line 171
    :goto_827
    new-array v14, v10, [I

    .line 172
    invoke-static {v13, v2, v14}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    invoke-static {v3, v4, v6}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    invoke-static {v14}, Lcom/kousei/framework/h0;->F0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_849

    invoke-static {v6}, Lcom/kousei/framework/h0;->F0([I)Z

    move-result v1

    if-eqz v1, :cond_843

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_959

    :cond_843
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_959

    :cond_849
    invoke-static {v14, v8}, Lcom/kousei/framework/h0;->e2([I[I)V

    .line 173
    new-array v0, v10, [I

    .line 174
    invoke-static {v8, v14, v0}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    invoke-static {v8, v13, v8}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    .line 175
    sget-object v2, Lcom/kousei/framework/h0;->k:[I

    .line 176
    invoke-static {v10, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v13

    if-eqz v13, :cond_860

    .line 177
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/h0;->E2([I[I[I)I

    goto :goto_863

    :cond_860
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/h0;->E2([I[I[I)I

    .line 178
    :goto_863
    invoke-static {v3, v0, v7}, Lcom/kousei/framework/h0;->L0([I[I[I)V

    invoke-static {v8, v8, v0}, Lcom/kousei/framework/h0;->i([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->M1(I[I)V

    new-instance v2, Lcom/kousei/framework/i8;

    invoke-direct {v2, v9}, Lcom/kousei/framework/i8;-><init>([I)V

    invoke-static {v6, v9}, Lcom/kousei/framework/h0;->e2([I[I)V

    invoke-static {v9, v0, v9}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/i8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/i8;-><init>([I)V

    invoke-static {v8, v9, v0}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 179
    aget v8, v6, v26

    int-to-long v8, v8

    and-long v8, v8, v18

    const/16 v27, 0x1

    aget v13, v6, v27

    move/from16 p1, v11

    int-to-long v10, v13

    and-long v10, v10, v18

    aget v13, v6, v24

    move-wide/from16 v22, v8

    int-to-long v8, v13

    and-long v8, v8, v18

    const/4 v13, 0x3

    aget v6, v6, v13

    move-wide/from16 v24, v8

    int-to-long v8, v6

    and-long v8, v8, v18

    move-wide/from16 v31, v8

    move-wide/from16 v8, v16

    move/from16 v6, v26

    :goto_8a3
    const/4 v13, 0x4

    if-ge v6, v13, :cond_910

    aget v13, v0, v6

    move-wide/from16 v33, v10

    int-to-long v10, v13

    and-long v10, v10, v18

    mul-long v15, v10, v22

    aget v13, v7, v6

    move-wide/from16 v35, v10

    int-to-long v10, v13

    and-long v10, v10, v18

    add-long/2addr v10, v15

    long-to-int v13, v10

    aput v13, v7, v6

    ushr-long v10, v10, v20

    mul-long v15, v35, v33

    add-int/lit8 v13, v6, 0x1

    move-object/from16 v29, v0

    aget v0, v7, v13

    move-wide/from16 v37, v10

    int-to-long v10, v0

    and-long v10, v10, v18

    add-long/2addr v15, v10

    add-long v10, v15, v37

    long-to-int v0, v10

    aput v0, v7, v13

    ushr-long v10, v10, v20

    mul-long v15, v35, v24

    add-int/lit8 v0, v6, 0x2

    move/from16 p0, v0

    aget v0, v7, p0

    move-wide/from16 v37, v10

    int-to-long v10, v0

    and-long v10, v10, v18

    add-long/2addr v15, v10

    add-long v10, v15, v37

    long-to-int v0, v10

    aput v0, v7, p0

    ushr-long v10, v10, v20

    mul-long v15, v35, v31

    add-int/lit8 v0, v6, 0x3

    move/from16 p0, v0

    aget v0, v7, p0

    move-wide/from16 v35, v10

    int-to-long v10, v0

    and-long v10, v10, v18

    add-long/2addr v15, v10

    add-long v10, v15, v35

    long-to-int v0, v10

    aput v0, v7, p0

    ushr-long v10, v10, v20

    add-int/lit8 v6, v6, 0x4

    aget v0, v7, v6

    move-wide v15, v10

    int-to-long v10, v0

    and-long v10, v10, v18

    add-long/2addr v10, v15

    add-long/2addr v10, v8

    long-to-int v0, v10

    aput v0, v7, v6

    ushr-long v8, v10, v20

    move v6, v13

    move-object/from16 v0, v29

    move-wide/from16 v10, v33

    goto :goto_8a3

    :cond_910
    long-to-int v0, v8

    if-nez v0, :cond_928

    const/16 v21, 0x7

    .line 180
    aget v0, v7, v21

    const/16 v27, 0x1

    ushr-int/lit8 v0, v0, 0x1

    const v6, 0x7ffffffe

    if-lt v0, v6, :cond_92f

    sget-object v0, Lcom/kousei/framework/h0;->l:[I

    invoke-static {v7, v0}, Lcom/kousei/framework/n6;->O([I[I)Z

    move-result v0

    if-eqz v0, :cond_92f

    :cond_928
    sget-object v0, Lcom/kousei/framework/h0;->m:[I

    const/16 v6, 0x8

    invoke-static {v6, v0, v7}, Lcom/kousei/framework/n6;->m(I[I[I)I

    .line 181
    :cond_92f
    iget-object v0, v3, Lcom/kousei/framework/i8;->S:[I

    invoke-static {v7, v0}, Lcom/kousei/framework/h0;->z1([I[I)V

    new-instance v0, Lcom/kousei/framework/i8;

    invoke-direct {v0, v14}, Lcom/kousei/framework/i8;-><init>([I)V

    if-nez p1, :cond_93e

    invoke-static {v14, v5, v14}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    :cond_93e
    if-nez v12, :cond_943

    invoke-static {v14, v1, v14}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    :cond_943
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v31, Lcom/kousei/framework/b2;

    const/16 v36, 0x3

    move-object/from16 v35, v1

    move-object/from16 v33, v2

    move-object/from16 v34, v3

    move-object/from16 v32, v4

    .line 182
    invoke-direct/range {v31 .. v36}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v31

    :goto_959
    return-object v0

    .line 183
    :pswitch_95a
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_963

    move-object v0, v1

    goto/16 :goto_a7b

    :cond_963
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_96b

    goto/16 :goto_a7b

    :cond_96b
    if-ne v0, v1, :cond_973

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_a7b

    .line 184
    :cond_973
    check-cast v15, Lcom/kousei/framework/g8;

    check-cast v3, Lcom/kousei/framework/g8;

    .line 185
    iget-object v2, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 186
    check-cast v2, Lcom/kousei/framework/g8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v4

    check-cast v4, Lcom/kousei/framework/g8;

    aget-object v5, v14, v26

    check-cast v5, Lcom/kousei/framework/g8;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/g8;

    const/16 v6, 0x10

    .line 187
    new-array v7, v6, [I

    const/16 v6, 0x8

    .line 188
    new-array v8, v6, [I

    new-array v9, v6, [I

    new-array v10, v6, [I

    .line 189
    iget-object v5, v5, Lcom/kousei/framework/g8;->S:[I

    .line 190
    invoke-static {v5}, Lcom/kousei/framework/n6;->m0([I)Z

    move-result v6

    if-eqz v6, :cond_9a4

    .line 191
    iget-object v2, v2, Lcom/kousei/framework/g8;->S:[I

    iget-object v4, v4, Lcom/kousei/framework/g8;->S:[I

    goto :goto_9b6

    :cond_9a4
    invoke-static {v5, v9}, Lcom/kousei/framework/h0;->a2([I[I)V

    iget-object v2, v2, Lcom/kousei/framework/g8;->S:[I

    invoke-static {v9, v2, v8}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    invoke-static {v9, v5, v9}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    iget-object v2, v4, Lcom/kousei/framework/g8;->S:[I

    invoke-static {v9, v2, v9}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    move-object v2, v8

    move-object v4, v9

    .line 192
    :goto_9b6
    iget-object v1, v1, Lcom/kousei/framework/g8;->S:[I

    .line 193
    invoke-static {v1}, Lcom/kousei/framework/n6;->m0([I)Z

    move-result v11

    if-eqz v11, :cond_9c5

    .line 194
    iget-object v12, v15, Lcom/kousei/framework/g8;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/g8;->S:[I

    :goto_9c2
    const/16 v13, 0x8

    goto :goto_9d8

    :cond_9c5
    invoke-static {v1, v10}, Lcom/kousei/framework/h0;->a2([I[I)V

    iget-object v12, v15, Lcom/kousei/framework/g8;->S:[I

    invoke-static {v10, v12, v7}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    invoke-static {v10, v1, v10}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/g8;->S:[I

    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    move-object v12, v7

    move-object v3, v10

    goto :goto_9c2

    .line 195
    :goto_9d8
    new-array v14, v13, [I

    .line 196
    invoke-static {v12, v2, v14}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    invoke-static {v3, v4, v8}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    invoke-static {v14}, Lcom/kousei/framework/n6;->q0([I)Z

    move-result v2

    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v2, :cond_9fa

    invoke-static {v8}, Lcom/kousei/framework/n6;->q0([I)Z

    move-result v1

    if-eqz v1, :cond_9f4

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_a7b

    :cond_9f4
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_a7b

    :cond_9fa
    invoke-static {v14, v9}, Lcom/kousei/framework/h0;->a2([I[I)V

    const/16 v13, 0x8

    .line 197
    new-array v0, v13, [I

    .line 198
    invoke-static {v9, v14, v0}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    invoke-static {v9, v12, v9}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    .line 199
    sget-object v2, Lcom/kousei/framework/h0;->i:[I

    .line 200
    invoke-static {v13, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v12

    if-eqz v12, :cond_a13

    .line 201
    invoke-static {v2, v2, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    goto :goto_a16

    :cond_a13
    invoke-static {v2, v0, v0}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 202
    :goto_a16
    invoke-static {v3, v0, v7}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    invoke-static {v9, v9, v0}, Lcom/kousei/framework/n6;->g([I[I[I)I

    move-result v2

    invoke-static {v2, v0}, Lcom/kousei/framework/h0;->L1(I[I)V

    new-instance v2, Lcom/kousei/framework/g8;

    invoke-direct {v2, v10}, Lcom/kousei/framework/g8;-><init>([I)V

    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->a2([I[I)V

    invoke-static {v10, v0, v10}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    new-instance v3, Lcom/kousei/framework/g8;

    invoke-direct {v3, v0}, Lcom/kousei/framework/g8;-><init>([I)V

    invoke-static {v9, v10, v0}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 203
    sget-object v9, Lcom/kousei/framework/h0;->j:[I

    invoke-static {v0, v8, v7}, Lcom/kousei/framework/n6;->A0([I[I[I)I

    move-result v8

    if-nez v8, :cond_a4f

    aget v8, v7, v23

    const/16 v27, 0x1

    ushr-int/lit8 v8, v8, 0x1

    const v10, 0x7fffffff

    if-lt v8, v10, :cond_a54

    const/16 v8, 0x10

    invoke-static {v8, v7, v9}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v10

    if-eqz v10, :cond_a54

    goto :goto_a51

    :cond_a4f
    const/16 v8, 0x10

    :goto_a51
    invoke-static {v8, v9, v7}, Lcom/kousei/framework/n6;->g1(I[I[I)V

    .line 204
    :cond_a54
    invoke-static {v7, v0}, Lcom/kousei/framework/h0;->u1([I[I)V

    new-instance v0, Lcom/kousei/framework/g8;

    invoke-direct {v0, v14}, Lcom/kousei/framework/g8;-><init>([I)V

    if-nez v6, :cond_a61

    invoke-static {v14, v5, v14}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    :cond_a61
    if-nez v11, :cond_a66

    invoke-static {v14, v1, v14}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    :cond_a66
    const/4 v1, 0x1

    new-array v1, v1, [Lcom/kousei/framework/h0;

    aput-object v0, v1, v26

    new-instance v15, Lcom/kousei/framework/b2;

    const/16 v20, 0x2

    move-object/from16 v19, v1

    move-object/from16 v17, v2

    move-object/from16 v18, v3

    move-object/from16 v16, v4

    .line 205
    invoke-direct/range {v15 .. v20}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object v0, v15

    :goto_a7b
    return-object v0

    .line 206
    :pswitch_a7c
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_a85

    :goto_a82
    move-object v0, v1

    goto/16 :goto_c73

    :cond_a85
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    iget-object v4, v1, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    if-eqz v2, :cond_a8f

    goto/16 :goto_c73

    :cond_a8f
    if-ne v0, v1, :cond_a97

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_c73

    .line 207
    :cond_a97
    iget-object v2, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    iget v5, v2, Lcom/kousei/framework/v3;->f:I

    .line 208
    iget-object v6, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    iget-object v1, v1, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    if-eqz v5, :cond_c3a

    const/4 v7, 0x1

    if-eq v5, v7, :cond_bb2

    move/from16 v7, v24

    if-eq v5, v7, :cond_ab4

    const/4 v13, 0x4

    if-ne v5, v13, :cond_aac

    goto :goto_ab4

    :cond_aac
    const-string v0, "unsupported coordinate system"

    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    const/4 v0, 0x0

    goto/16 :goto_c73

    :cond_ab4
    :goto_ab4
    aget-object v7, v14, v26

    aget-object v4, v4, v26

    invoke-virtual {v7}, Lcom/kousei/framework/h0;->A0()Z

    move-result v8

    if-nez v8, :cond_b19

    invoke-virtual {v7, v4}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_b19

    invoke-virtual {v15, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v4

    invoke-virtual {v3, v1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v4}, Lcom/kousei/framework/h0;->E0()Z

    move-result v8

    if-eqz v8, :cond_ae4

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->E0()Z

    move-result v1

    if-eqz v1, :cond_ade

    :goto_ad8
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_c73

    :cond_ade
    invoke-virtual {v2}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_c73

    :cond_ae4
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v8

    invoke-virtual {v15, v8}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v9

    invoke-virtual {v6, v8}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v9, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v8

    invoke-virtual {v8, v3}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v8

    invoke-virtual {v8, v9}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v8

    invoke-virtual {v8, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v9, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v8

    invoke-virtual {v8, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v1, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v4, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    move-object v4, v1

    :goto_b15
    const/4 v13, 0x4

    const/4 v14, 0x0

    goto/16 :goto_b93

    :cond_b19
    if-eqz v8, :cond_b1c

    goto :goto_b2c

    :cond_b1c
    invoke-virtual {v7}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v9

    invoke-virtual {v9, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v9, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v9

    invoke-virtual {v9, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    :goto_b2c
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->A0()Z

    move-result v9

    if-eqz v9, :cond_b33

    goto :goto_b43

    :cond_b33
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v10

    invoke-virtual {v10, v15}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v15

    invoke-virtual {v10, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v10

    invoke-virtual {v10, v3}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    :goto_b43
    invoke-virtual {v15, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v3, v1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v6}, Lcom/kousei/framework/h0;->E0()Z

    move-result v10

    if-eqz v10, :cond_b58

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->E0()Z

    move-result v1

    if-eqz v1, :cond_ade

    goto :goto_ad8

    :cond_b58
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v10

    invoke-virtual {v10, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v11

    invoke-virtual {v10, v15}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v12

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v13

    invoke-virtual {v13, v11}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v13

    .line 209
    invoke-virtual {v12, v12}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v14

    .line 210
    invoke-virtual {v13, v14}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v13

    invoke-virtual {v12, v13}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v12

    invoke-virtual {v12, v1, v11, v3}, Lcom/kousei/framework/h0;->k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    if-nez v8, :cond_b83

    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    goto :goto_b84

    :cond_b83
    move-object v3, v6

    :goto_b84
    if-nez v9, :cond_b8a

    invoke-virtual {v3, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    :cond_b8a
    move-object v4, v1

    if-ne v3, v6, :cond_b91

    move-object v14, v10

    move-object v6, v13

    const/4 v13, 0x4

    goto :goto_b93

    :cond_b91
    move-object v6, v13

    goto :goto_b15

    :goto_b93
    if-ne v5, v13, :cond_ba3

    invoke-virtual {v0, v3, v14}, Lcom/kousei/framework/b2;->u(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    const/4 v7, 0x2

    new-array v1, v7, [Lcom/kousei/framework/h0;

    aput-object v3, v1, v26

    const/4 v7, 0x1

    aput-object v0, v1, v7

    :goto_ba1
    move-object v5, v1

    goto :goto_ba9

    :cond_ba3
    const/4 v7, 0x1

    new-array v1, v7, [Lcom/kousei/framework/h0;

    aput-object v3, v1, v26

    goto :goto_ba1

    :goto_ba9
    new-instance v1, Lcom/kousei/framework/b2;

    move-object v3, v6

    const/4 v6, 0x1

    .line 211
    invoke-direct/range {v1 .. v6}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    goto/16 :goto_a82

    .line 212
    :cond_bb2
    aget-object v5, v14, v26

    aget-object v4, v4, v26

    invoke-virtual {v5}, Lcom/kousei/framework/h0;->A0()Z

    move-result v7

    invoke-virtual {v4}, Lcom/kousei/framework/h0;->A0()Z

    move-result v8

    if-eqz v7, :cond_bc1

    goto :goto_bc5

    :cond_bc1
    invoke-virtual {v1, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    :goto_bc5
    if-eqz v8, :cond_bc8

    goto :goto_bcc

    :cond_bc8
    invoke-virtual {v3, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v3

    :goto_bcc
    invoke-virtual {v1, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    if-eqz v7, :cond_bd3

    goto :goto_bd7

    :cond_bd3
    invoke-virtual {v6, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    :goto_bd7
    if-eqz v8, :cond_bda

    goto :goto_bde

    :cond_bda
    invoke-virtual {v15, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v15

    :goto_bde
    invoke-virtual {v6, v15}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v6}, Lcom/kousei/framework/h0;->E0()Z

    move-result v9

    if-eqz v9, :cond_bf0

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->E0()Z

    move-result v1

    if-eqz v1, :cond_ade

    goto/16 :goto_ad8

    :cond_bf0
    if-eqz v7, :cond_bf4

    move-object v5, v4

    goto :goto_bfb

    :cond_bf4
    if-eqz v8, :cond_bf7

    goto :goto_bfb

    :cond_bf7
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v5

    :goto_bfb
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v0, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v4

    invoke-virtual {v0, v15}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v7

    invoke-virtual {v7, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v7

    invoke-virtual {v7, v4}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v7

    .line 213
    invoke-virtual {v0, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v8

    .line 214
    invoke-virtual {v7, v8}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v7

    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v6

    invoke-virtual {v0, v7}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v0, v1, v3, v4}, Lcom/kousei/framework/h0;->k1(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v4, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    move-object v3, v1

    new-instance v1, Lcom/kousei/framework/b2;

    filled-new-array {v3}, [Lcom/kousei/framework/h0;

    move-result-object v5

    move-object v3, v6

    const/4 v6, 0x1

    move-object v4, v0

    .line 215
    invoke-direct/range {v1 .. v6}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    goto/16 :goto_a82

    .line 216
    :cond_c3a
    invoke-virtual {v6, v15}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v4

    invoke-virtual {v1, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v4}, Lcom/kousei/framework/h0;->E0()Z

    move-result v5

    if-eqz v5, :cond_c50

    invoke-virtual {v1}, Lcom/kousei/framework/h0;->E0()Z

    move-result v1

    if-eqz v1, :cond_ade

    goto/16 :goto_ad8

    :cond_c50
    invoke-virtual {v1, v4}, Lcom/kousei/framework/h0;->R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v1, v15}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v1, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v1

    invoke-virtual {v15, v1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v4

    invoke-virtual {v0, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    invoke-virtual {v0, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    move-result-object v0

    new-instance v3, Lcom/kousei/framework/b2;

    const/4 v7, 0x1

    .line 217
    invoke-direct {v3, v2, v1, v0, v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    move-object v0, v3

    :goto_c73
    return-object v0

    .line 218
    :pswitch_c74
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_c7d

    move-object v0, v1

    goto/16 :goto_df1

    :cond_c7d
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    move-result v2

    if-eqz v2, :cond_c85

    goto/16 :goto_df1

    :cond_c85
    if-ne v0, v1, :cond_c8d

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_df1

    .line 219
    :cond_c8d
    check-cast v15, Lcom/kousei/framework/a2;

    check-cast v3, Lcom/kousei/framework/a2;

    aget-object v2, v14, v26

    check-cast v2, Lcom/kousei/framework/a2;

    .line 220
    iget-object v4, v1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 221
    check-cast v4, Lcom/kousei/framework/a2;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    move-result-object v5

    check-cast v5, Lcom/kousei/framework/a2;

    invoke-virtual {v1}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    move-result-object v1

    check-cast v1, Lcom/kousei/framework/a2;

    const/16 v6, 0x10

    .line 222
    new-array v7, v6, [I

    const/16 v6, 0x8

    .line 223
    new-array v8, v6, [I

    new-array v9, v6, [I

    new-array v10, v6, [I

    .line 224
    iget-object v2, v2, Lcom/kousei/framework/a2;->S:[I

    .line 225
    invoke-static {v2}, Lcom/kousei/framework/n6;->m0([I)Z

    move-result v6

    if-eqz v6, :cond_cbe

    .line 226
    iget-object v4, v4, Lcom/kousei/framework/a2;->S:[I

    iget-object v5, v5, Lcom/kousei/framework/a2;->S:[I

    goto :goto_cd0

    :cond_cbe
    invoke-static {v2, v9}, Lcom/kousei/framework/h0;->Y1([I[I)V

    iget-object v4, v4, Lcom/kousei/framework/a2;->S:[I

    invoke-static {v9, v4, v8}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    invoke-static {v9, v2, v9}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    iget-object v4, v5, Lcom/kousei/framework/a2;->S:[I

    invoke-static {v9, v4, v9}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    move-object v4, v8

    move-object v5, v9

    .line 227
    :goto_cd0
    iget-object v1, v1, Lcom/kousei/framework/a2;->S:[I

    .line 228
    invoke-static {v1}, Lcom/kousei/framework/n6;->m0([I)Z

    move-result v11

    if-eqz v11, :cond_cdf

    .line 229
    iget-object v12, v15, Lcom/kousei/framework/a2;->S:[I

    iget-object v3, v3, Lcom/kousei/framework/a2;->S:[I

    :goto_cdc
    const/16 v13, 0x8

    goto :goto_cf2

    :cond_cdf
    invoke-static {v1, v10}, Lcom/kousei/framework/h0;->Y1([I[I)V

    iget-object v12, v15, Lcom/kousei/framework/a2;->S:[I

    invoke-static {v10, v12, v7}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    invoke-static {v10, v1, v10}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    iget-object v3, v3, Lcom/kousei/framework/a2;->S:[I

    invoke-static {v10, v3, v10}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    move-object v12, v7

    move-object v3, v10

    goto :goto_cdc

    .line 230
    :goto_cf2
    new-array v14, v13, [I

    .line 231
    invoke-static {v12, v4, v14}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    invoke-static {v3, v5, v8}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    invoke-static {v14}, Lcom/kousei/framework/n6;->q0([I)Z

    move-result v4

    iget-object v5, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    if-eqz v4, :cond_d14

    invoke-static {v8}, Lcom/kousei/framework/n6;->q0([I)Z

    move-result v1

    if-eqz v1, :cond_d0e

    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_df1

    :cond_d0e
    invoke-virtual {v5}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    move-result-object v0

    goto/16 :goto_df1

    :cond_d14
    const/16 v13, 0x8

    .line 232
    new-array v4, v13, [I

    .line 233
    invoke-static {v14, v4}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 234
    new-array v15, v13, [I

    .line 235
    invoke-static {v4, v14, v15}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    invoke-static {v4, v12, v9}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 236
    sget-object v12, Lcom/kousei/framework/h0;->f:[I

    .line 237
    invoke-static {v13, v15}, Lcom/kousei/framework/n6;->G(I[I)I

    move-result v21

    if-eqz v21, :cond_d2f

    .line 238
    invoke-static {v12, v12, v15}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    goto :goto_d32

    :cond_d2f
    invoke-static {v12, v15, v15}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 239
    :goto_d32
    invoke-static {v3, v15, v7}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    invoke-static {v9, v9, v15}, Lcom/kousei/framework/n6;->g([I[I[I)I

    move-result v3

    invoke-static {v3, v15}, Lcom/kousei/framework/h0;->K1(I[I)V

    new-instance v3, Lcom/kousei/framework/a2;

    invoke-direct {v3, v10}, Lcom/kousei/framework/a2;-><init>([I)V

    invoke-static {v8, v10}, Lcom/kousei/framework/h0;->Y1([I[I)V

    invoke-static {v10, v15, v10}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    new-instance v12, Lcom/kousei/framework/a2;

    invoke-direct {v12, v15}, Lcom/kousei/framework/a2;-><init>([I)V

    invoke-static {v9, v10, v15}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    .line 240
    invoke-static {v15, v8, v7}, Lcom/kousei/framework/n6;->A0([I[I[I)I

    sget-object v8, Lcom/kousei/framework/h0;->g:[I

    const/16 v9, 0x10

    invoke-static {v9, v7, v8}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    move-result v9

    if-eqz v9, :cond_db7

    .line 241
    aget v9, v7, v26

    int-to-long v9, v9

    and-long v9, v9, v18

    aget v13, v8, v26

    move-object/from16 v33, v3

    move-object/from16 v21, v4

    int-to-long v3, v13

    and-long v3, v3, v18

    sub-long/2addr v9, v3

    long-to-int v3, v9

    aput v3, v7, v26

    shr-long v3, v9, v20

    cmp-long v9, v3, v16

    if-eqz v9, :cond_d7d

    const/4 v9, 0x1

    const/16 v13, 0x8

    invoke-static {v13, v9, v7}, Lcom/kousei/framework/n6;->A(II[I)I

    move-result v3

    int-to-long v3, v3

    goto :goto_d7f

    :cond_d7d
    const/16 v13, 0x8

    :goto_d7f
    aget v9, v7, v13

    int-to-long v9, v9

    and-long v9, v9, v18

    const-wide/16 v29, 0x13

    add-long v9, v9, v29

    add-long/2addr v9, v3

    long-to-int v3, v9

    aput v3, v7, v13

    shr-long v3, v9, v20

    cmp-long v9, v3, v16

    if-eqz v9, :cond_d9c

    move/from16 v9, v23

    const/16 v10, 0x9

    invoke-static {v9, v10, v7}, Lcom/kousei/framework/n6;->h0(II[I)I

    move-result v3

    int-to-long v3, v3

    goto :goto_d9e

    :cond_d9c
    move/from16 v9, v23

    :goto_d9e
    aget v10, v7, v9

    move/from16 v23, v9

    int-to-long v9, v10

    and-long v9, v9, v18

    aget v8, v8, v23

    const/16 v27, 0x1

    add-int/lit8 v8, v8, 0x1

    move-wide/from16 v16, v3

    int-to-long v3, v8

    and-long v3, v3, v18

    sub-long/2addr v9, v3

    add-long v9, v9, v16

    long-to-int v3, v9

    aput v3, v7, v23

    goto :goto_dbb

    :cond_db7
    move-object/from16 v33, v3

    move-object/from16 v21, v4

    .line 242
    :goto_dbb
    invoke-static {v7, v15}, Lcom/kousei/framework/h0;->s1([I[I)V

    new-instance v3, Lcom/kousei/framework/a2;

    invoke-direct {v3, v14}, Lcom/kousei/framework/a2;-><init>([I)V

    if-nez v6, :cond_dc8

    invoke-static {v14, v2, v14}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    :cond_dc8
    if-nez v11, :cond_dcd

    invoke-static {v14, v1, v14}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    :cond_dcd
    if-eqz v6, :cond_dd4

    if-eqz v11, :cond_dd4

    move-object/from16 v14, v21

    goto :goto_dd5

    :cond_dd4
    const/4 v14, 0x0

    :goto_dd5
    invoke-virtual {v0, v3, v14}, Lcom/kousei/framework/b2;->v(Lcom/kousei/framework/a2;[I)Lcom/kousei/framework/a2;

    move-result-object v0

    const/4 v7, 0x2

    new-array v1, v7, [Lcom/kousei/framework/h0;

    aput-object v3, v1, v26

    const/16 v27, 0x1

    aput-object v0, v1, v27

    new-instance v31, Lcom/kousei/framework/b2;

    const/16 v36, 0x0

    move-object/from16 v35, v1

    move-object/from16 v32, v5

    move-object/from16 v34, v12

    .line 243
    invoke-direct/range {v31 .. v36}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    move-object/from16 v0, v31

    :goto_df1
    return-object v0

    :pswitch_data_df2
    .packed-switch 0x0
        :pswitch_c74
        :pswitch_a7c
        :pswitch_95a
        :pswitch_7ae
        :pswitch_6b5
        :pswitch_59c
        :pswitch_4a3
        :pswitch_384
        :pswitch_267
        :pswitch_14b
        :pswitch_146
        :pswitch_141
        :pswitch_13c
        :pswitch_137
    .end packed-switch
.end method

.method public final j()Lcom/kousei/framework/d4;
    .registers 9

    .line 1
    iget v0, p0, Lcom/kousei/framework/b2;->h:I

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 4
    .line 5
    packed-switch v0, :pswitch_data_194

    .line 6
    .line 7
    .line 8
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-eqz v0, :cond_e

    .line 13
    .line 14
    goto :goto_20

    .line 15
    :cond_e
    new-instance v2, Lcom/kousei/framework/b2;

    .line 16
    .line 17
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 18
    .line 19
    .line 20
    move-result-object v5

    .line 21
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 22
    .line 23
    const/16 v7, 0xe

    .line 24
    .line 25
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 26
    .line 27
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 28
    .line 29
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 30
    .line 31
    .line 32
    move-object p0, v2

    .line 33
    :goto_20
    return-object p0

    .line 34
    :pswitch_21
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 35
    .line 36
    .line 37
    move-result v0

    .line 38
    if-eqz v0, :cond_28

    .line 39
    .line 40
    goto :goto_3a

    .line 41
    :cond_28
    new-instance v2, Lcom/kousei/framework/b2;

    .line 42
    .line 43
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 44
    .line 45
    .line 46
    move-result-object v5

    .line 47
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 48
    .line 49
    const/16 v7, 0xd

    .line 50
    .line 51
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 52
    .line 53
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 54
    .line 55
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 56
    .line 57
    .line 58
    move-object p0, v2

    .line 59
    :goto_3a
    return-object p0

    .line 60
    :pswitch_3b
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 61
    .line 62
    .line 63
    move-result v0

    .line 64
    if-eqz v0, :cond_42

    .line 65
    .line 66
    goto :goto_54

    .line 67
    :cond_42
    new-instance v2, Lcom/kousei/framework/b2;

    .line 68
    .line 69
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 70
    .line 71
    .line 72
    move-result-object v5

    .line 73
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 74
    .line 75
    const/16 v7, 0xc

    .line 76
    .line 77
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 78
    .line 79
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 80
    .line 81
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 82
    .line 83
    .line 84
    move-object p0, v2

    .line 85
    :goto_54
    return-object p0

    .line 86
    :pswitch_55
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 87
    .line 88
    .line 89
    move-result v0

    .line 90
    if-eqz v0, :cond_5c

    .line 91
    .line 92
    goto :goto_6e

    .line 93
    :cond_5c
    new-instance v2, Lcom/kousei/framework/b2;

    .line 94
    .line 95
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 96
    .line 97
    .line 98
    move-result-object v5

    .line 99
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 100
    .line 101
    const/16 v7, 0xb

    .line 102
    .line 103
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 104
    .line 105
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 106
    .line 107
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 108
    .line 109
    .line 110
    move-object p0, v2

    .line 111
    :goto_6e
    return-object p0

    .line 112
    :pswitch_6f
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 113
    .line 114
    .line 115
    move-result v0

    .line 116
    if-eqz v0, :cond_76

    .line 117
    .line 118
    goto :goto_88

    .line 119
    :cond_76
    new-instance v2, Lcom/kousei/framework/b2;

    .line 120
    .line 121
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 122
    .line 123
    .line 124
    move-result-object v5

    .line 125
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 126
    .line 127
    const/16 v7, 0xa

    .line 128
    .line 129
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 130
    .line 131
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 132
    .line 133
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 134
    .line 135
    .line 136
    move-object p0, v2

    .line 137
    :goto_88
    return-object p0

    .line 138
    :pswitch_89
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 139
    .line 140
    .line 141
    move-result v0

    .line 142
    if-eqz v0, :cond_90

    .line 143
    .line 144
    goto :goto_a2

    .line 145
    :cond_90
    new-instance v2, Lcom/kousei/framework/b2;

    .line 146
    .line 147
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 148
    .line 149
    .line 150
    move-result-object v5

    .line 151
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 152
    .line 153
    const/16 v7, 0x9

    .line 154
    .line 155
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 156
    .line 157
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 158
    .line 159
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 160
    .line 161
    .line 162
    move-object p0, v2

    .line 163
    :goto_a2
    return-object p0

    .line 164
    :pswitch_a3
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 165
    .line 166
    .line 167
    move-result v0

    .line 168
    if-eqz v0, :cond_aa

    .line 169
    .line 170
    goto :goto_bc

    .line 171
    :cond_aa
    new-instance v2, Lcom/kousei/framework/b2;

    .line 172
    .line 173
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 174
    .line 175
    .line 176
    move-result-object v5

    .line 177
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 178
    .line 179
    const/16 v7, 0x8

    .line 180
    .line 181
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 182
    .line 183
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 184
    .line 185
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 186
    .line 187
    .line 188
    move-object p0, v2

    .line 189
    :goto_bc
    return-object p0

    .line 190
    :pswitch_bd
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 191
    .line 192
    .line 193
    move-result v0

    .line 194
    if-eqz v0, :cond_c4

    .line 195
    .line 196
    goto :goto_d5

    .line 197
    :cond_c4
    new-instance v2, Lcom/kousei/framework/b2;

    .line 198
    .line 199
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 200
    .line 201
    .line 202
    move-result-object v5

    .line 203
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 204
    .line 205
    const/4 v7, 0x7

    .line 206
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 207
    .line 208
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 209
    .line 210
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 211
    .line 212
    .line 213
    move-object p0, v2

    .line 214
    :goto_d5
    return-object p0

    .line 215
    :pswitch_d6
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 216
    .line 217
    .line 218
    move-result v0

    .line 219
    if-eqz v0, :cond_dd

    .line 220
    .line 221
    goto :goto_ee

    .line 222
    :cond_dd
    new-instance v2, Lcom/kousei/framework/b2;

    .line 223
    .line 224
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 225
    .line 226
    .line 227
    move-result-object v5

    .line 228
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 229
    .line 230
    const/4 v7, 0x6

    .line 231
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 232
    .line 233
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 234
    .line 235
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 236
    .line 237
    .line 238
    move-object p0, v2

    .line 239
    :goto_ee
    return-object p0

    .line 240
    :pswitch_ef
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 241
    .line 242
    .line 243
    move-result v0

    .line 244
    if-eqz v0, :cond_f6

    .line 245
    .line 246
    goto :goto_107

    .line 247
    :cond_f6
    new-instance v2, Lcom/kousei/framework/b2;

    .line 248
    .line 249
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 250
    .line 251
    .line 252
    move-result-object v5

    .line 253
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 254
    .line 255
    const/4 v7, 0x5

    .line 256
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 257
    .line 258
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 259
    .line 260
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 261
    .line 262
    .line 263
    move-object p0, v2

    .line 264
    :goto_107
    return-object p0

    .line 265
    :pswitch_108
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 266
    .line 267
    .line 268
    move-result v0

    .line 269
    if-eqz v0, :cond_10f

    .line 270
    .line 271
    goto :goto_120

    .line 272
    :cond_10f
    new-instance v2, Lcom/kousei/framework/b2;

    .line 273
    .line 274
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 275
    .line 276
    .line 277
    move-result-object v5

    .line 278
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 279
    .line 280
    const/4 v7, 0x4

    .line 281
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 282
    .line 283
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 284
    .line 285
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 286
    .line 287
    .line 288
    move-object p0, v2

    .line 289
    :goto_120
    return-object p0

    .line 290
    :pswitch_121
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 291
    .line 292
    .line 293
    move-result v0

    .line 294
    if-eqz v0, :cond_128

    .line 295
    .line 296
    goto :goto_139

    .line 297
    :cond_128
    new-instance v2, Lcom/kousei/framework/b2;

    .line 298
    .line 299
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 300
    .line 301
    .line 302
    move-result-object v5

    .line 303
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 304
    .line 305
    const/4 v7, 0x3

    .line 306
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 307
    .line 308
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 309
    .line 310
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 311
    .line 312
    .line 313
    move-object p0, v2

    .line 314
    :goto_139
    return-object p0

    .line 315
    :pswitch_13a
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 316
    .line 317
    .line 318
    move-result v0

    .line 319
    if-eqz v0, :cond_141

    .line 320
    .line 321
    goto :goto_152

    .line 322
    :cond_141
    new-instance v2, Lcom/kousei/framework/b2;

    .line 323
    .line 324
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 325
    .line 326
    .line 327
    move-result-object v5

    .line 328
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 329
    .line 330
    const/4 v7, 0x2

    .line 331
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 332
    .line 333
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 334
    .line 335
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 336
    .line 337
    .line 338
    move-object p0, v2

    .line 339
    :goto_152
    return-object p0

    .line 340
    :pswitch_153
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 341
    .line 342
    .line 343
    move-result v0

    .line 344
    if-eqz v0, :cond_15a

    .line 345
    .line 346
    goto :goto_17a

    .line 347
    :cond_15a
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 348
    .line 349
    iget v0, v3, Lcom/kousei/framework/v3;->f:I

    .line 350
    .line 351
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 352
    .line 353
    if-eqz v0, :cond_170

    .line 354
    .line 355
    new-instance v2, Lcom/kousei/framework/b2;

    .line 356
    .line 357
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 358
    .line 359
    .line 360
    move-result-object v5

    .line 361
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 362
    .line 363
    const/4 v7, 0x1

    .line 364
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 365
    .line 366
    .line 367
    move-object p0, v2

    .line 368
    goto :goto_17a

    .line 369
    :cond_170
    new-instance p0, Lcom/kousei/framework/b2;

    .line 370
    .line 371
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 372
    .line 373
    .line 374
    move-result-object v0

    .line 375
    const/4 v1, 0x1

    .line 376
    invoke-direct {p0, v3, v4, v0, v1}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 377
    .line 378
    .line 379
    :goto_17a
    return-object p0

    .line 380
    :pswitch_17b
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 381
    .line 382
    .line 383
    move-result v0

    .line 384
    if-eqz v0, :cond_182

    .line 385
    .line 386
    goto :goto_193

    .line 387
    :cond_182
    new-instance v2, Lcom/kousei/framework/b2;

    .line 388
    .line 389
    invoke-virtual {v1}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 390
    .line 391
    .line 392
    move-result-object v5

    .line 393
    iget-object v6, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 394
    .line 395
    const/4 v7, 0x0

    .line 396
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 397
    .line 398
    iget-object v4, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 399
    .line 400
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 401
    .line 402
    .line 403
    move-object p0, v2

    .line 404
    :goto_193
    return-object p0

    .line 405
    :pswitch_data_194
    .packed-switch 0x0
        :pswitch_17b
        :pswitch_153
        :pswitch_13a
        :pswitch_121
        :pswitch_108
        :pswitch_ef
        :pswitch_d6
        :pswitch_bd
        :pswitch_a3
        :pswitch_89
        :pswitch_6f
        :pswitch_55
        :pswitch_3b
        :pswitch_21
    .end packed-switch
.end method

.method public n(I)Lcom/kousei/framework/d4;
    .registers 18

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move/from16 v1, p1

    .line 4
    .line 5
    iget v2, v0, Lcom/kousei/framework/b2;->h:I

    .line 6
    .line 7
    packed-switch v2, :pswitch_data_14a

    .line 8
    .line 9
    .line 10
    invoke-super/range {p0 .. p1}, Lcom/kousei/framework/d4;->n(I)Lcom/kousei/framework/d4;

    .line 11
    .line 12
    .line 13
    move-result-object v0

    .line 14
    return-object v0

    .line 15
    :pswitch_e
    const/4 v2, 0x0

    .line 16
    if-ltz v1, :cond_143

    .line 17
    .line 18
    if-eqz v1, :cond_149

    .line 19
    .line 20
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 21
    .line 22
    .line 23
    move-result v3

    .line 24
    if-eqz v3, :cond_1b

    .line 25
    .line 26
    goto/16 :goto_149

    .line 27
    .line 28
    :cond_1b
    const/4 v3, 0x1

    .line 29
    if-ne v1, v3, :cond_24

    .line 30
    .line 31
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 32
    .line 33
    .line 34
    move-result-object v0

    .line 35
    goto/16 :goto_149

    .line 36
    .line 37
    :cond_24
    iget-object v4, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 38
    .line 39
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->E0()Z

    .line 40
    .line 41
    .line 42
    move-result v5

    .line 43
    iget-object v7, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 44
    .line 45
    if-eqz v5, :cond_34

    .line 46
    .line 47
    :goto_2e
    invoke-virtual {v7}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 48
    .line 49
    .line 50
    move-result-object v0

    .line 51
    goto/16 :goto_149

    .line 52
    .line 53
    :cond_34
    iget v5, v7, Lcom/kousei/framework/v3;->f:I

    .line 54
    .line 55
    iget-object v6, v7, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 56
    .line 57
    iget-object v8, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 58
    .line 59
    array-length v9, v8

    .line 60
    const/4 v10, 0x0

    .line 61
    if-ge v9, v3, :cond_45

    .line 62
    .line 63
    sget-object v8, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 64
    .line 65
    invoke-virtual {v7, v8}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 66
    .line 67
    .line 68
    move-result-object v8

    .line 69
    goto :goto_47

    .line 70
    :cond_45
    aget-object v8, v8, v10

    .line 71
    .line 72
    :goto_47
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->A0()Z

    .line 73
    .line 74
    .line 75
    move-result v9

    .line 76
    const-string v11, "unsupported coordinate system"

    .line 77
    .line 78
    const/4 v12, 0x4

    .line 79
    const/4 v13, 0x2

    .line 80
    iget-object v14, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 81
    .line 82
    if-nez v9, :cond_7b

    .line 83
    .line 84
    if-eqz v5, :cond_7b

    .line 85
    .line 86
    if-eq v5, v3, :cond_6b

    .line 87
    .line 88
    if-eq v5, v13, :cond_66

    .line 89
    .line 90
    if-ne v5, v12, :cond_60

    .line 91
    .line 92
    invoke-virtual {v0}, Lcom/kousei/framework/b2;->w()Lcom/kousei/framework/h0;

    .line 93
    .line 94
    .line 95
    move-result-object v6

    .line 96
    goto :goto_7b

    .line 97
    :cond_60
    invoke-static {v11}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 98
    .line 99
    .line 100
    :goto_63
    move-object v0, v2

    .line 101
    goto/16 :goto_149

    .line 102
    .line 103
    :cond_66
    invoke-virtual {v0, v8, v2}, Lcom/kousei/framework/b2;->u(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 104
    .line 105
    .line 106
    move-result-object v6

    .line 107
    goto :goto_7b

    .line 108
    :cond_6b
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 109
    .line 110
    .line 111
    move-result-object v6

    .line 112
    invoke-virtual {v14, v8}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 113
    .line 114
    .line 115
    move-result-object v14

    .line 116
    invoke-virtual {v4, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 117
    .line 118
    .line 119
    move-result-object v4

    .line 120
    invoke-virtual {v0, v8, v6}, Lcom/kousei/framework/b2;->u(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 121
    .line 122
    .line 123
    move-result-object v6

    .line 124
    :cond_7b
    :goto_7b
    move-object v9, v4

    .line 125
    :goto_7c
    if-ge v10, v1, :cond_e5

    .line 126
    .line 127
    invoke-virtual {v9}, Lcom/kousei/framework/h0;->E0()Z

    .line 128
    .line 129
    .line 130
    move-result v0

    .line 131
    if-eqz v0, :cond_85

    .line 132
    .line 133
    goto :goto_2e

    .line 134
    :cond_85
    invoke-virtual {v14}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 135
    .line 136
    .line 137
    move-result-object v0

    .line 138
    invoke-virtual {v0, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 139
    .line 140
    .line 141
    move-result-object v4

    .line 142
    invoke-virtual {v4, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 143
    .line 144
    .line 145
    move-result-object v0

    .line 146
    invoke-virtual {v9, v9}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 147
    .line 148
    .line 149
    move-result-object v4

    .line 150
    invoke-virtual {v4, v9}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 151
    .line 152
    .line 153
    move-result-object v9

    .line 154
    invoke-virtual {v14, v9}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 155
    .line 156
    .line 157
    move-result-object v14

    .line 158
    invoke-virtual {v14, v14}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 159
    .line 160
    .line 161
    move-result-object v14

    .line 162
    invoke-virtual {v9}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 163
    .line 164
    .line 165
    move-result-object v9

    .line 166
    invoke-virtual {v9, v9}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 167
    .line 168
    .line 169
    move-result-object v9

    .line 170
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->E0()Z

    .line 171
    .line 172
    .line 173
    move-result v15

    .line 174
    if-nez v15, :cond_bb

    .line 175
    .line 176
    invoke-virtual {v0, v6}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 177
    .line 178
    .line 179
    move-result-object v0

    .line 180
    invoke-virtual {v9, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 181
    .line 182
    .line 183
    move-result-object v6

    .line 184
    invoke-virtual {v6, v6}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 185
    .line 186
    .line 187
    move-result-object v6

    .line 188
    :cond_bb
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 189
    .line 190
    .line 191
    move-result-object v15

    .line 192
    invoke-virtual {v14, v14}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 193
    .line 194
    .line 195
    move-result-object v2

    .line 196
    invoke-virtual {v15, v2}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 197
    .line 198
    .line 199
    move-result-object v2

    .line 200
    invoke-virtual {v14, v2}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 201
    .line 202
    .line 203
    move-result-object v14

    .line 204
    invoke-virtual {v0, v14}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 205
    .line 206
    .line 207
    move-result-object v0

    .line 208
    invoke-virtual {v0, v9}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 209
    .line 210
    .line 211
    move-result-object v9

    .line 212
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->A0()Z

    .line 213
    .line 214
    .line 215
    move-result v0

    .line 216
    if-eqz v0, :cond_db

    .line 217
    .line 218
    move-object v8, v4

    .line 219
    goto :goto_e0

    .line 220
    :cond_db
    invoke-virtual {v4, v8}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 221
    .line 222
    .line 223
    move-result-object v0

    .line 224
    move-object v8, v0

    .line 225
    :goto_e0
    add-int/lit8 v10, v10, 0x1

    .line 226
    .line 227
    move-object v14, v2

    .line 228
    const/4 v2, 0x0

    .line 229
    goto :goto_7c

    .line 230
    :cond_e5
    if-eqz v5, :cond_126

    .line 231
    .line 232
    if-eq v5, v3, :cond_10d

    .line 233
    .line 234
    if-eq v5, v13, :cond_ff

    .line 235
    .line 236
    if-ne v5, v12, :cond_fa

    .line 237
    .line 238
    new-instance v0, Lcom/kousei/framework/b2;

    .line 239
    .line 240
    filled-new-array {v8, v6}, [Lcom/kousei/framework/h0;

    .line 241
    .line 242
    .line 243
    move-result-object v10

    .line 244
    const/4 v11, 0x1

    .line 245
    move-object v6, v0

    .line 246
    move-object v8, v14

    .line 247
    invoke-direct/range {v6 .. v11}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 248
    .line 249
    .line 250
    goto :goto_149

    .line 251
    :cond_fa
    invoke-static {v11}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 252
    .line 253
    .line 254
    :goto_fd
    const/4 v0, 0x0

    .line 255
    goto :goto_149

    .line 256
    :cond_ff
    move-object v0, v8

    .line 257
    move-object v8, v14

    .line 258
    new-instance v6, Lcom/kousei/framework/b2;

    .line 259
    .line 260
    filled-new-array {v0}, [Lcom/kousei/framework/h0;

    .line 261
    .line 262
    .line 263
    move-result-object v10

    .line 264
    const/4 v11, 0x1

    .line 265
    invoke-direct/range {v6 .. v11}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 266
    .line 267
    .line 268
    :goto_10b
    move-object v0, v6

    .line 269
    goto :goto_149

    .line 270
    :cond_10d
    move-object v0, v8

    .line 271
    move-object v8, v14

    .line 272
    invoke-virtual {v8, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 273
    .line 274
    .line 275
    move-result-object v8

    .line 276
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 277
    .line 278
    .line 279
    move-result-object v1

    .line 280
    invoke-virtual {v0, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 281
    .line 282
    .line 283
    move-result-object v0

    .line 284
    new-instance v6, Lcom/kousei/framework/b2;

    .line 285
    .line 286
    filled-new-array {v0}, [Lcom/kousei/framework/h0;

    .line 287
    .line 288
    .line 289
    move-result-object v10

    .line 290
    const/4 v11, 0x1

    .line 291
    invoke-direct/range {v6 .. v11}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 292
    .line 293
    .line 294
    goto :goto_10b

    .line 295
    :cond_126
    move-object v0, v8

    .line 296
    move-object v8, v14

    .line 297
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->z0()Lcom/kousei/framework/h0;

    .line 298
    .line 299
    .line 300
    move-result-object v0

    .line 301
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 302
    .line 303
    .line 304
    move-result-object v1

    .line 305
    invoke-virtual {v1, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 306
    .line 307
    .line 308
    move-result-object v0

    .line 309
    new-instance v2, Lcom/kousei/framework/b2;

    .line 310
    .line 311
    invoke-virtual {v8, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 312
    .line 313
    .line 314
    move-result-object v1

    .line 315
    invoke-virtual {v9, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 316
    .line 317
    .line 318
    move-result-object v0

    .line 319
    invoke-direct {v2, v7, v1, v0, v3}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 320
    .line 321
    .line 322
    goto/16 :goto_63

    .line 323
    .line 324
    :cond_143
    const-string v0, "\'e\' cannot be negative"

    .line 325
    .line 326
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 327
    .line 328
    .line 329
    goto :goto_fd

    .line 330
    :cond_149
    :goto_149
    return-object v0

    .line 331
    :pswitch_data_14a
    .packed-switch 0x1
        :pswitch_e
    .end packed-switch
.end method

.method public final o()Lcom/kousei/framework/d4;
    .registers 24

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget v1, v0, Lcom/kousei/framework/b2;->h:I

    .line 4
    .line 5
    const/4 v2, 0x6

    .line 6
    const/16 v3, 0x8

    .line 7
    .line 8
    const/16 v4, 0x10

    .line 9
    .line 10
    const/4 v5, 0x4

    .line 11
    const/4 v6, 0x5

    .line 12
    const/4 v8, -0x1

    .line 13
    iget-object v9, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 14
    .line 15
    iget-object v10, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 16
    .line 17
    iget-object v11, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 18
    .line 19
    const/4 v12, 0x1

    .line 20
    const/4 v13, 0x0

    .line 21
    packed-switch v1, :pswitch_data_b32

    .line 22
    .line 23
    .line 24
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 25
    .line 26
    .line 27
    move-result v1

    .line 28
    if-eqz v1, :cond_1f

    .line 29
    .line 30
    goto/16 :goto_d4

    .line 31
    .line 32
    :cond_1f
    check-cast v11, Lcom/kousei/framework/d9;

    .line 33
    .line 34
    invoke-virtual {v11}, Lcom/kousei/framework/d9;->E0()Z

    .line 35
    .line 36
    .line 37
    move-result v1

    .line 38
    iget-object v2, v11, Lcom/kousei/framework/d9;->S:[I

    .line 39
    .line 40
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 41
    .line 42
    if-eqz v1, :cond_31

    .line 43
    .line 44
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 45
    .line 46
    .line 47
    move-result-object v0

    .line 48
    goto/16 :goto_d4

    .line 49
    .line 50
    :cond_31
    check-cast v10, Lcom/kousei/framework/d9;

    .line 51
    .line 52
    aget-object v0, v9, v13

    .line 53
    .line 54
    check-cast v0, Lcom/kousei/framework/d9;

    .line 55
    .line 56
    const/16 v1, 0x21

    .line 57
    .line 58
    new-array v1, v1, [I

    .line 59
    .line 60
    const/16 v3, 0x11

    .line 61
    .line 62
    new-array v5, v3, [I

    .line 63
    .line 64
    new-array v6, v3, [I

    .line 65
    .line 66
    new-array v7, v3, [I

    .line 67
    .line 68
    invoke-static {v2, v1}, Lcom/kousei/framework/h0;->v0([I[I)V

    .line 69
    .line 70
    .line 71
    invoke-static {v1, v7}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 72
    .line 73
    .line 74
    new-array v8, v3, [I

    .line 75
    .line 76
    invoke-static {v7, v1}, Lcom/kousei/framework/h0;->v0([I[I)V

    .line 77
    .line 78
    .line 79
    invoke-static {v1, v8}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 80
    .line 81
    .line 82
    invoke-virtual {v0}, Lcom/kousei/framework/d9;->A0()Z

    .line 83
    .line 84
    .line 85
    move-result v9

    .line 86
    iget-object v0, v0, Lcom/kousei/framework/d9;->S:[I

    .line 87
    .line 88
    if-nez v9, :cond_61

    .line 89
    .line 90
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->v0([I[I)V

    .line 91
    .line 92
    .line 93
    invoke-static {v1, v6}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 94
    .line 95
    .line 96
    move-object v11, v6

    .line 97
    goto :goto_62

    .line 98
    :cond_61
    move-object v11, v0

    .line 99
    :goto_62
    iget-object v10, v10, Lcom/kousei/framework/d9;->S:[I

    .line 100
    .line 101
    invoke-static {v10, v11, v5}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 102
    .line 103
    .line 104
    invoke-static {v10, v11, v6}, Lcom/kousei/framework/h0;->h([I[I[I)V

    .line 105
    .line 106
    .line 107
    invoke-static {v6, v5, v1}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    .line 108
    .line 109
    .line 110
    invoke-static {v1, v6}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 111
    .line 112
    .line 113
    invoke-static {v3, v6, v6, v6}, Lcom/kousei/framework/n6;->e(I[I[I[I)I

    .line 114
    .line 115
    .line 116
    invoke-static {v6}, Lcom/kousei/framework/h0;->J1([I)V

    .line 117
    .line 118
    .line 119
    invoke-static {v7, v10, v1}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    .line 120
    .line 121
    .line 122
    invoke-static {v1, v7}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 123
    .line 124
    .line 125
    invoke-static {v3, v7}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 126
    .line 127
    .line 128
    invoke-static {v7}, Lcom/kousei/framework/h0;->J1([I)V

    .line 129
    .line 130
    .line 131
    invoke-static {v3, v8, v5}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 132
    .line 133
    .line 134
    invoke-static {v5}, Lcom/kousei/framework/h0;->J1([I)V

    .line 135
    .line 136
    .line 137
    new-instance v3, Lcom/kousei/framework/d9;

    .line 138
    .line 139
    invoke-direct {v3, v8}, Lcom/kousei/framework/d9;-><init>([I)V

    .line 140
    .line 141
    .line 142
    invoke-static {v6, v1}, Lcom/kousei/framework/h0;->v0([I[I)V

    .line 143
    .line 144
    .line 145
    invoke-static {v1, v8}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 146
    .line 147
    .line 148
    invoke-static {v8, v7, v8}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 149
    .line 150
    .line 151
    invoke-static {v8, v7, v8}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 152
    .line 153
    .line 154
    new-instance v10, Lcom/kousei/framework/d9;

    .line 155
    .line 156
    invoke-direct {v10, v7}, Lcom/kousei/framework/d9;-><init>([I)V

    .line 157
    .line 158
    .line 159
    invoke-static {v7, v8, v7}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 160
    .line 161
    .line 162
    invoke-static {v7, v6, v1}, Lcom/kousei/framework/h0;->l0([I[I[I)V

    .line 163
    .line 164
    .line 165
    invoke-static {v1, v7}, Lcom/kousei/framework/h0;->y1([I[I)V

    .line 166
    .line 167
    .line 168
    invoke-static {v7, v5, v7}, Lcom/kousei/framework/h0;->Q2([I[I[I)V

    .line 169
    .line 170
    .line 171
    new-instance v5, Lcom/kousei/framework/d9;

    .line 172
    .line 173
    invoke-direct {v5, v6}, Lcom/kousei/framework/d9;-><init>([I)V

    .line 174
    .line 175
    .line 176
    aget v7, v2, v4

    .line 177
    .line 178
    shl-int/lit8 v8, v7, 0x17

    .line 179
    .line 180
    invoke-static {v4, v8, v2, v6}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 181
    .line 182
    .line 183
    move-result v2

    .line 184
    shl-int/2addr v7, v12

    .line 185
    or-int/2addr v2, v7

    .line 186
    and-int/lit16 v2, v2, 0x1ff

    .line 187
    .line 188
    aput v2, v6, v4

    .line 189
    .line 190
    if-nez v9, :cond_c2

    .line 191
    .line 192
    invoke-static {v6, v0, v6, v1}, Lcom/kousei/framework/h0;->b1([I[I[I[I)V

    .line 193
    .line 194
    .line 195
    :cond_c2
    new-instance v14, Lcom/kousei/framework/b2;

    .line 196
    .line 197
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 198
    .line 199
    aput-object v5, v0, v13

    .line 200
    .line 201
    const/16 v19, 0xe

    .line 202
    .line 203
    move-object/from16 v18, v0

    .line 204
    .line 205
    move-object/from16 v16, v3

    .line 206
    .line 207
    move-object/from16 v17, v10

    .line 208
    .line 209
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 210
    .line 211
    .line 212
    move-object v0, v14

    .line 213
    :goto_d4
    return-object v0

    .line 214
    :pswitch_d5
    sget-object v1, Lcom/kousei/framework/h0;->K:[I

    .line 215
    .line 216
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 217
    .line 218
    .line 219
    move-result v2

    .line 220
    if-eqz v2, :cond_df

    .line 221
    .line 222
    goto/16 :goto_1ab

    .line 223
    .line 224
    :cond_df
    check-cast v11, Lcom/kousei/framework/b9;

    .line 225
    .line 226
    invoke-virtual {v11}, Lcom/kousei/framework/b9;->E0()Z

    .line 227
    .line 228
    .line 229
    move-result v2

    .line 230
    iget-object v3, v11, Lcom/kousei/framework/b9;->S:[I

    .line 231
    .line 232
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 233
    .line 234
    if-eqz v2, :cond_f1

    .line 235
    .line 236
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 237
    .line 238
    .line 239
    move-result-object v0

    .line 240
    goto/16 :goto_1ab

    .line 241
    .line 242
    :cond_f1
    check-cast v10, Lcom/kousei/framework/b9;

    .line 243
    .line 244
    aget-object v0, v9, v13

    .line 245
    .line 246
    check-cast v0, Lcom/kousei/framework/b9;

    .line 247
    .line 248
    const/16 v2, 0x18

    .line 249
    .line 250
    new-array v2, v2, [I

    .line 251
    .line 252
    const/16 v4, 0xc

    .line 253
    .line 254
    new-array v5, v4, [I

    .line 255
    .line 256
    new-array v6, v4, [I

    .line 257
    .line 258
    new-array v7, v4, [I

    .line 259
    .line 260
    invoke-static {v3, v2}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 261
    .line 262
    .line 263
    invoke-static {v2, v7}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 264
    .line 265
    .line 266
    new-array v9, v4, [I

    .line 267
    .line 268
    invoke-static {v7, v2}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 269
    .line 270
    .line 271
    invoke-static {v2, v9}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 272
    .line 273
    .line 274
    invoke-virtual {v0}, Lcom/kousei/framework/b9;->A0()Z

    .line 275
    .line 276
    .line 277
    move-result v11

    .line 278
    iget-object v0, v0, Lcom/kousei/framework/b9;->S:[I

    .line 279
    .line 280
    if-nez v11, :cond_121

    .line 281
    .line 282
    invoke-static {v0, v2}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 283
    .line 284
    .line 285
    invoke-static {v2, v6}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 286
    .line 287
    .line 288
    move-object v14, v6

    .line 289
    goto :goto_122

    .line 290
    :cond_121
    move-object v14, v0

    .line 291
    :goto_122
    iget-object v10, v10, Lcom/kousei/framework/b9;->S:[I

    .line 292
    .line 293
    invoke-static {v10, v14, v5}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 294
    .line 295
    .line 296
    invoke-static {v4, v10, v14, v6}, Lcom/kousei/framework/n6;->a(I[I[I[I)I

    .line 297
    .line 298
    .line 299
    move-result v14

    .line 300
    const/16 v16, 0xb

    .line 301
    .line 302
    if-nez v14, :cond_139

    .line 303
    .line 304
    aget v14, v6, v16

    .line 305
    .line 306
    if-ne v14, v8, :cond_13c

    .line 307
    .line 308
    invoke-static {v4, v6, v1}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 309
    .line 310
    .line 311
    move-result v14

    .line 312
    if-eqz v14, :cond_13c

    .line 313
    .line 314
    :cond_139
    invoke-static {v6}, Lcom/kousei/framework/h0;->x([I)V

    .line 315
    .line 316
    .line 317
    :cond_13c
    invoke-static {v6, v5, v2}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 318
    .line 319
    .line 320
    invoke-static {v2, v6}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 321
    .line 322
    .line 323
    invoke-static {v4, v6, v6, v6}, Lcom/kousei/framework/n6;->e(I[I[I[I)I

    .line 324
    .line 325
    .line 326
    move-result v14

    .line 327
    invoke-static {v14, v6}, Lcom/kousei/framework/h0;->N1(I[I)V

    .line 328
    .line 329
    .line 330
    invoke-static {v7, v10, v7, v2}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 331
    .line 332
    .line 333
    invoke-static {v4, v7}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 334
    .line 335
    .line 336
    move-result v10

    .line 337
    invoke-static {v10, v7}, Lcom/kousei/framework/h0;->N1(I[I)V

    .line 338
    .line 339
    .line 340
    invoke-static {v4, v9, v5}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 341
    .line 342
    .line 343
    move-result v10

    .line 344
    invoke-static {v10, v5}, Lcom/kousei/framework/h0;->N1(I[I)V

    .line 345
    .line 346
    .line 347
    new-instance v10, Lcom/kousei/framework/b9;

    .line 348
    .line 349
    invoke-direct {v10, v9}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 350
    .line 351
    .line 352
    invoke-static {v6, v2}, Lcom/kousei/framework/n6;->U0([I[I)V

    .line 353
    .line 354
    .line 355
    invoke-static {v2, v9}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 356
    .line 357
    .line 358
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 359
    .line 360
    .line 361
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 362
    .line 363
    .line 364
    new-instance v14, Lcom/kousei/framework/b9;

    .line 365
    .line 366
    invoke-direct {v14, v7}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 367
    .line 368
    .line 369
    invoke-static {v7, v9, v7}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 370
    .line 371
    .line 372
    invoke-static {v7, v6, v2}, Lcom/kousei/framework/n6;->y0([I[I[I)V

    .line 373
    .line 374
    .line 375
    invoke-static {v2, v7}, Lcom/kousei/framework/h0;->x1([I[I)V

    .line 376
    .line 377
    .line 378
    invoke-static {v7, v5, v7}, Lcom/kousei/framework/h0;->P2([I[I[I)V

    .line 379
    .line 380
    .line 381
    new-instance v5, Lcom/kousei/framework/b9;

    .line 382
    .line 383
    invoke-direct {v5, v6}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 384
    .line 385
    .line 386
    invoke-static {v4, v13, v3, v6}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 387
    .line 388
    .line 389
    move-result v3

    .line 390
    if-nez v3, :cond_191

    .line 391
    .line 392
    aget v3, v6, v16

    .line 393
    .line 394
    if-ne v3, v8, :cond_194

    .line 395
    .line 396
    invoke-static {v4, v6, v1}, Lcom/kousei/framework/n6;->M(I[I[I)Z

    .line 397
    .line 398
    .line 399
    move-result v1

    .line 400
    if-eqz v1, :cond_194

    .line 401
    .line 402
    :cond_191
    invoke-static {v6}, Lcom/kousei/framework/h0;->x([I)V

    .line 403
    .line 404
    .line 405
    :cond_194
    if-nez v11, :cond_199

    .line 406
    .line 407
    invoke-static {v6, v0, v6, v2}, Lcom/kousei/framework/h0;->Y0([I[I[I[I)V

    .line 408
    .line 409
    .line 410
    :cond_199
    move-object/from16 v17, v14

    .line 411
    .line 412
    new-instance v14, Lcom/kousei/framework/b2;

    .line 413
    .line 414
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 415
    .line 416
    aput-object v5, v0, v13

    .line 417
    .line 418
    const/16 v19, 0xd

    .line 419
    .line 420
    move-object/from16 v18, v0

    .line 421
    .line 422
    move-object/from16 v16, v10

    .line 423
    .line 424
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 425
    .line 426
    .line 427
    move-object v0, v14

    .line 428
    :goto_1ab
    return-object v0

    .line 429
    :pswitch_1ac
    sget-object v1, Lcom/kousei/framework/h0;->I:[I

    .line 430
    .line 431
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 432
    .line 433
    .line 434
    move-result v2

    .line 435
    if-eqz v2, :cond_1b6

    .line 436
    .line 437
    goto/16 :goto_282

    .line 438
    .line 439
    :cond_1b6
    check-cast v11, Lcom/kousei/framework/z8;

    .line 440
    .line 441
    iget-object v2, v11, Lcom/kousei/framework/z8;->S:[I

    .line 442
    .line 443
    invoke-static {v2}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 444
    .line 445
    .line 446
    move-result v5

    .line 447
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 448
    .line 449
    if-eqz v5, :cond_1c8

    .line 450
    .line 451
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 452
    .line 453
    .line 454
    move-result-object v0

    .line 455
    goto/16 :goto_282

    .line 456
    .line 457
    :cond_1c8
    check-cast v10, Lcom/kousei/framework/z8;

    .line 458
    .line 459
    aget-object v0, v9, v13

    .line 460
    .line 461
    check-cast v0, Lcom/kousei/framework/z8;

    .line 462
    .line 463
    new-array v4, v4, [I

    .line 464
    .line 465
    new-array v5, v3, [I

    .line 466
    .line 467
    new-array v6, v3, [I

    .line 468
    .line 469
    new-array v9, v3, [I

    .line 470
    .line 471
    invoke-static {v2, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 472
    .line 473
    .line 474
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 475
    .line 476
    .line 477
    new-array v11, v3, [I

    .line 478
    .line 479
    invoke-static {v9, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 480
    .line 481
    .line 482
    invoke-static {v4, v11}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 483
    .line 484
    .line 485
    iget-object v0, v0, Lcom/kousei/framework/z8;->S:[I

    .line 486
    .line 487
    invoke-static {v0}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 488
    .line 489
    .line 490
    move-result v14

    .line 491
    if-nez v14, :cond_1f6

    .line 492
    .line 493
    invoke-static {v0, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 494
    .line 495
    .line 496
    invoke-static {v4, v6}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 497
    .line 498
    .line 499
    move-object v7, v6

    .line 500
    :goto_1f3
    const/16 v16, 0x7

    .line 501
    .line 502
    goto :goto_1f8

    .line 503
    :cond_1f6
    move-object v7, v0

    .line 504
    goto :goto_1f3

    .line 505
    :goto_1f8
    iget-object v10, v10, Lcom/kousei/framework/z8;->S:[I

    .line 506
    .line 507
    invoke-static {v10, v7, v5}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 508
    .line 509
    .line 510
    invoke-static {v10, v7, v6}, Lcom/kousei/framework/n6;->c([I[I[I)I

    .line 511
    .line 512
    .line 513
    move-result v7

    .line 514
    if-nez v7, :cond_20d

    .line 515
    .line 516
    aget v7, v6, v16

    .line 517
    .line 518
    if-ne v7, v8, :cond_210

    .line 519
    .line 520
    invoke-static {v6, v1}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 521
    .line 522
    .line 523
    move-result v7

    .line 524
    if-eqz v7, :cond_210

    .line 525
    .line 526
    :cond_20d
    invoke-static {v6}, Lcom/kousei/framework/h0;->w([I)V

    .line 527
    .line 528
    .line 529
    :cond_210
    invoke-static {v6, v5, v4}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 530
    .line 531
    .line 532
    invoke-static {v4, v6}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 533
    .line 534
    .line 535
    invoke-static {v6, v6, v6}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 536
    .line 537
    .line 538
    move-result v7

    .line 539
    invoke-static {v7, v6}, Lcom/kousei/framework/h0;->V1(I[I)V

    .line 540
    .line 541
    .line 542
    invoke-static {v9, v10, v4}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 543
    .line 544
    .line 545
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 546
    .line 547
    .line 548
    invoke-static {v3, v9}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 549
    .line 550
    .line 551
    move-result v7

    .line 552
    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->V1(I[I)V

    .line 553
    .line 554
    .line 555
    invoke-static {v3, v11, v5}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 556
    .line 557
    .line 558
    move-result v7

    .line 559
    invoke-static {v7, v5}, Lcom/kousei/framework/h0;->V1(I[I)V

    .line 560
    .line 561
    .line 562
    new-instance v7, Lcom/kousei/framework/z8;

    .line 563
    .line 564
    invoke-direct {v7, v11}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 565
    .line 566
    .line 567
    invoke-static {v6, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 568
    .line 569
    .line 570
    invoke-static {v4, v11}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 571
    .line 572
    .line 573
    invoke-static {v11, v9, v11}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 574
    .line 575
    .line 576
    invoke-static {v11, v9, v11}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 577
    .line 578
    .line 579
    new-instance v10, Lcom/kousei/framework/z8;

    .line 580
    .line 581
    invoke-direct {v10, v9}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 582
    .line 583
    .line 584
    invoke-static {v9, v11, v9}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 585
    .line 586
    .line 587
    invoke-static {v9, v6, v4}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 588
    .line 589
    .line 590
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->w1([I[I)V

    .line 591
    .line 592
    .line 593
    invoke-static {v9, v5, v9}, Lcom/kousei/framework/h0;->O2([I[I[I)V

    .line 594
    .line 595
    .line 596
    new-instance v5, Lcom/kousei/framework/z8;

    .line 597
    .line 598
    invoke-direct {v5, v6}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 599
    .line 600
    .line 601
    invoke-static {v3, v13, v2, v6}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 602
    .line 603
    .line 604
    move-result v2

    .line 605
    if-nez v2, :cond_268

    .line 606
    .line 607
    aget v2, v6, v16

    .line 608
    .line 609
    if-ne v2, v8, :cond_26b

    .line 610
    .line 611
    invoke-static {v6, v1}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 612
    .line 613
    .line 614
    move-result v1

    .line 615
    if-eqz v1, :cond_26b

    .line 616
    .line 617
    :cond_268
    invoke-static {v6}, Lcom/kousei/framework/h0;->w([I)V

    .line 618
    .line 619
    .line 620
    :cond_26b
    if-nez v14, :cond_270

    .line 621
    .line 622
    invoke-static {v6, v0, v6, v4}, Lcom/kousei/framework/h0;->V0([I[I[I[I)V

    .line 623
    .line 624
    .line 625
    :cond_270
    new-instance v14, Lcom/kousei/framework/b2;

    .line 626
    .line 627
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 628
    .line 629
    aput-object v5, v0, v13

    .line 630
    .line 631
    const/16 v19, 0xc

    .line 632
    .line 633
    move-object/from16 v18, v0

    .line 634
    .line 635
    move-object/from16 v16, v7

    .line 636
    .line 637
    move-object/from16 v17, v10

    .line 638
    .line 639
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 640
    .line 641
    .line 642
    move-object v0, v14

    .line 643
    :goto_282
    return-object v0

    .line 644
    :pswitch_283
    const/16 v16, 0x7

    .line 645
    .line 646
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 647
    .line 648
    .line 649
    move-result v1

    .line 650
    if-eqz v1, :cond_28d

    .line 651
    .line 652
    goto/16 :goto_33d

    .line 653
    .line 654
    :cond_28d
    check-cast v11, Lcom/kousei/framework/x8;

    .line 655
    .line 656
    iget-object v1, v11, Lcom/kousei/framework/x8;->S:[I

    .line 657
    .line 658
    invoke-static {v1}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 659
    .line 660
    .line 661
    move-result v2

    .line 662
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 663
    .line 664
    if-eqz v2, :cond_29f

    .line 665
    .line 666
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 667
    .line 668
    .line 669
    move-result-object v0

    .line 670
    goto/16 :goto_33d

    .line 671
    .line 672
    :cond_29f
    check-cast v10, Lcom/kousei/framework/x8;

    .line 673
    .line 674
    aget-object v2, v9, v13

    .line 675
    .line 676
    check-cast v2, Lcom/kousei/framework/x8;

    .line 677
    .line 678
    new-array v4, v4, [I

    .line 679
    .line 680
    new-array v5, v3, [I

    .line 681
    .line 682
    invoke-static {v1, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 683
    .line 684
    .line 685
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 686
    .line 687
    .line 688
    new-array v6, v3, [I

    .line 689
    .line 690
    invoke-static {v5, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 691
    .line 692
    .line 693
    invoke-static {v4, v6}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 694
    .line 695
    .line 696
    new-array v7, v3, [I

    .line 697
    .line 698
    iget-object v9, v10, Lcom/kousei/framework/x8;->S:[I

    .line 699
    .line 700
    invoke-static {v9, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 701
    .line 702
    .line 703
    invoke-static {v4, v7}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 704
    .line 705
    .line 706
    invoke-static {v7, v7, v7}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 707
    .line 708
    .line 709
    move-result v9

    .line 710
    invoke-static {v9, v7}, Lcom/kousei/framework/h0;->U1(I[I)V

    .line 711
    .line 712
    .line 713
    iget-object v9, v10, Lcom/kousei/framework/x8;->S:[I

    .line 714
    .line 715
    invoke-static {v5, v9, v5, v4}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 716
    .line 717
    .line 718
    invoke-static {v3, v5}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 719
    .line 720
    .line 721
    move-result v9

    .line 722
    invoke-static {v9, v5}, Lcom/kousei/framework/h0;->U1(I[I)V

    .line 723
    .line 724
    .line 725
    new-array v9, v3, [I

    .line 726
    .line 727
    invoke-static {v3, v6, v9}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 728
    .line 729
    .line 730
    move-result v10

    .line 731
    invoke-static {v10, v9}, Lcom/kousei/framework/h0;->U1(I[I)V

    .line 732
    .line 733
    .line 734
    new-instance v10, Lcom/kousei/framework/x8;

    .line 735
    .line 736
    invoke-direct {v10, v6}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 737
    .line 738
    .line 739
    invoke-static {v7, v4}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 740
    .line 741
    .line 742
    invoke-static {v4, v6}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 743
    .line 744
    .line 745
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 746
    .line 747
    .line 748
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 749
    .line 750
    .line 751
    new-instance v11, Lcom/kousei/framework/x8;

    .line 752
    .line 753
    invoke-direct {v11, v5}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 754
    .line 755
    .line 756
    invoke-static {v5, v6, v5}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 757
    .line 758
    .line 759
    invoke-static {v5, v7, v4}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 760
    .line 761
    .line 762
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 763
    .line 764
    .line 765
    invoke-static {v5, v9, v5}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 766
    .line 767
    .line 768
    new-instance v5, Lcom/kousei/framework/x8;

    .line 769
    .line 770
    invoke-direct {v5, v7}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 771
    .line 772
    .line 773
    invoke-static {v3, v13, v1, v7}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 774
    .line 775
    .line 776
    move-result v1

    .line 777
    if-nez v1, :cond_316

    .line 778
    .line 779
    aget v1, v7, v16

    .line 780
    .line 781
    if-ne v1, v8, :cond_31b

    .line 782
    .line 783
    sget-object v1, Lcom/kousei/framework/h0;->F:[I

    .line 784
    .line 785
    invoke-static {v7, v1}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 786
    .line 787
    .line 788
    move-result v1

    .line 789
    if-eqz v1, :cond_31b

    .line 790
    .line 791
    :cond_316
    const/16 v1, 0x3d1

    .line 792
    .line 793
    invoke-static {v3, v1, v7}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 794
    .line 795
    .line 796
    :cond_31b
    iget-object v1, v2, Lcom/kousei/framework/x8;->S:[I

    .line 797
    .line 798
    invoke-static {v1}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 799
    .line 800
    .line 801
    move-result v1

    .line 802
    if-nez v1, :cond_328

    .line 803
    .line 804
    iget-object v1, v2, Lcom/kousei/framework/x8;->S:[I

    .line 805
    .line 806
    invoke-static {v7, v1, v7, v4}, Lcom/kousei/framework/h0;->S0([I[I[I[I)V

    .line 807
    .line 808
    .line 809
    :cond_328
    new-instance v17, Lcom/kousei/framework/b2;

    .line 810
    .line 811
    new-array v1, v12, [Lcom/kousei/framework/h0;

    .line 812
    .line 813
    aput-object v5, v1, v13

    .line 814
    .line 815
    const/16 v22, 0xb

    .line 816
    .line 817
    move-object/from16 v18, v0

    .line 818
    .line 819
    move-object/from16 v21, v1

    .line 820
    .line 821
    move-object/from16 v19, v10

    .line 822
    .line 823
    move-object/from16 v20, v11

    .line 824
    .line 825
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 826
    .line 827
    .line 828
    move-object/from16 v0, v17

    .line 829
    .line 830
    :goto_33d
    return-object v0

    .line 831
    :pswitch_33e
    const/16 v16, 0x7

    .line 832
    .line 833
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 834
    .line 835
    .line 836
    move-result v1

    .line 837
    if-eqz v1, :cond_348

    .line 838
    .line 839
    goto/16 :goto_3da

    .line 840
    .line 841
    :cond_348
    check-cast v11, Lcom/kousei/framework/v8;

    .line 842
    .line 843
    iget-object v1, v11, Lcom/kousei/framework/v8;->S:[I

    .line 844
    .line 845
    invoke-static {v1}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 846
    .line 847
    .line 848
    move-result v2

    .line 849
    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 850
    .line 851
    if-eqz v2, :cond_35a

    .line 852
    .line 853
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 854
    .line 855
    .line 856
    move-result-object v0

    .line 857
    goto/16 :goto_3da

    .line 858
    .line 859
    :cond_35a
    check-cast v10, Lcom/kousei/framework/v8;

    .line 860
    .line 861
    aget-object v0, v9, v13

    .line 862
    .line 863
    check-cast v0, Lcom/kousei/framework/v8;

    .line 864
    .line 865
    move/from16 v2, v16

    .line 866
    .line 867
    new-array v3, v2, [I

    .line 868
    .line 869
    new-array v5, v2, [I

    .line 870
    .line 871
    new-array v6, v2, [I

    .line 872
    .line 873
    invoke-static {v1, v6}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 874
    .line 875
    .line 876
    new-array v7, v2, [I

    .line 877
    .line 878
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 879
    .line 880
    .line 881
    iget-object v0, v0, Lcom/kousei/framework/v8;->S:[I

    .line 882
    .line 883
    invoke-static {v0}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 884
    .line 885
    .line 886
    move-result v2

    .line 887
    if-nez v2, :cond_37d

    .line 888
    .line 889
    invoke-static {v0, v5}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 890
    .line 891
    .line 892
    move-object v8, v5

    .line 893
    goto :goto_37e

    .line 894
    :cond_37d
    move-object v8, v0

    .line 895
    :goto_37e
    iget-object v9, v10, Lcom/kousei/framework/v8;->S:[I

    .line 896
    .line 897
    invoke-static {v9, v8, v3}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 898
    .line 899
    .line 900
    invoke-static {v9, v8, v5}, Lcom/kousei/framework/h0;->g([I[I[I)V

    .line 901
    .line 902
    .line 903
    invoke-static {v5, v3, v5}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 904
    .line 905
    .line 906
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/n6;->f([I[I[I)I

    .line 907
    .line 908
    .line 909
    move-result v8

    .line 910
    invoke-static {v8, v5}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 911
    .line 912
    .line 913
    invoke-static {v6, v9, v6}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 914
    .line 915
    .line 916
    const/4 v8, 0x7

    .line 917
    invoke-static {v8, v6}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 918
    .line 919
    .line 920
    move-result v9

    .line 921
    invoke-static {v9, v6}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 922
    .line 923
    .line 924
    invoke-static {v8, v7, v3}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 925
    .line 926
    .line 927
    move-result v8

    .line 928
    invoke-static {v8, v3}, Lcom/kousei/framework/h0;->T1(I[I)V

    .line 929
    .line 930
    .line 931
    new-instance v8, Lcom/kousei/framework/v8;

    .line 932
    .line 933
    invoke-direct {v8, v7}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 934
    .line 935
    .line 936
    invoke-static {v5, v7}, Lcom/kousei/framework/h0;->k2([I[I)V

    .line 937
    .line 938
    .line 939
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 940
    .line 941
    .line 942
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 943
    .line 944
    .line 945
    new-instance v9, Lcom/kousei/framework/v8;

    .line 946
    .line 947
    invoke-direct {v9, v6}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 948
    .line 949
    .line 950
    invoke-static {v6, v7, v6}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 951
    .line 952
    .line 953
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 954
    .line 955
    .line 956
    invoke-static {v6, v3, v6}, Lcom/kousei/framework/h0;->X2([I[I[I)V

    .line 957
    .line 958
    .line 959
    new-instance v3, Lcom/kousei/framework/v8;

    .line 960
    .line 961
    invoke-direct {v3, v5}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 962
    .line 963
    .line 964
    invoke-static {v1, v5}, Lcom/kousei/framework/h0;->f3([I[I)V

    .line 965
    .line 966
    .line 967
    if-nez v2, :cond_3cb

    .line 968
    .line 969
    invoke-static {v5, v0, v5}, Lcom/kousei/framework/h0;->h1([I[I[I)V

    .line 970
    .line 971
    .line 972
    :cond_3cb
    move-object v0, v3

    .line 973
    new-instance v3, Lcom/kousei/framework/b2;

    .line 974
    .line 975
    new-array v7, v12, [Lcom/kousei/framework/h0;

    .line 976
    .line 977
    aput-object v0, v7, v13

    .line 978
    .line 979
    move-object v5, v8

    .line 980
    const/16 v8, 0xa

    .line 981
    .line 982
    move-object v6, v9

    .line 983
    invoke-direct/range {v3 .. v8}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 984
    .line 985
    .line 986
    move-object v0, v3

    .line 987
    :goto_3da
    return-object v0

    .line 988
    :pswitch_3db
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 989
    .line 990
    .line 991
    move-result v1

    .line 992
    if-eqz v1, :cond_3e3

    .line 993
    .line 994
    goto/16 :goto_485

    .line 995
    .line 996
    :cond_3e3
    check-cast v11, Lcom/kousei/framework/t8;

    .line 997
    .line 998
    iget-object v1, v11, Lcom/kousei/framework/t8;->S:[I

    .line 999
    .line 1000
    invoke-static {v1}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 1001
    .line 1002
    .line 1003
    move-result v3

    .line 1004
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1005
    .line 1006
    if-eqz v3, :cond_3f5

    .line 1007
    .line 1008
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1009
    .line 1010
    .line 1011
    move-result-object v0

    .line 1012
    goto/16 :goto_485

    .line 1013
    .line 1014
    :cond_3f5
    check-cast v10, Lcom/kousei/framework/t8;

    .line 1015
    .line 1016
    aget-object v3, v9, v13

    .line 1017
    .line 1018
    check-cast v3, Lcom/kousei/framework/t8;

    .line 1019
    .line 1020
    const/4 v4, 0x7

    .line 1021
    new-array v5, v4, [I

    .line 1022
    .line 1023
    invoke-static {v1, v5}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 1024
    .line 1025
    .line 1026
    new-array v6, v4, [I

    .line 1027
    .line 1028
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 1029
    .line 1030
    .line 1031
    new-array v7, v4, [I

    .line 1032
    .line 1033
    iget-object v9, v10, Lcom/kousei/framework/t8;->S:[I

    .line 1034
    .line 1035
    invoke-static {v9, v7}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 1036
    .line 1037
    .line 1038
    invoke-static {v7, v7, v7}, Lcom/kousei/framework/n6;->f([I[I[I)I

    .line 1039
    .line 1040
    .line 1041
    move-result v9

    .line 1042
    invoke-static {v9, v7}, Lcom/kousei/framework/h0;->S1(I[I)V

    .line 1043
    .line 1044
    .line 1045
    iget-object v9, v10, Lcom/kousei/framework/t8;->S:[I

    .line 1046
    .line 1047
    invoke-static {v5, v9, v5}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 1048
    .line 1049
    .line 1050
    invoke-static {v4, v5}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1051
    .line 1052
    .line 1053
    move-result v9

    .line 1054
    invoke-static {v9, v5}, Lcom/kousei/framework/h0;->S1(I[I)V

    .line 1055
    .line 1056
    .line 1057
    new-array v9, v4, [I

    .line 1058
    .line 1059
    invoke-static {v4, v6, v9}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1060
    .line 1061
    .line 1062
    move-result v10

    .line 1063
    invoke-static {v10, v9}, Lcom/kousei/framework/h0;->S1(I[I)V

    .line 1064
    .line 1065
    .line 1066
    new-instance v4, Lcom/kousei/framework/t8;

    .line 1067
    .line 1068
    invoke-direct {v4, v6}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 1069
    .line 1070
    .line 1071
    invoke-static {v7, v6}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 1072
    .line 1073
    .line 1074
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 1075
    .line 1076
    .line 1077
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 1078
    .line 1079
    .line 1080
    new-instance v10, Lcom/kousei/framework/t8;

    .line 1081
    .line 1082
    invoke-direct {v10, v5}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 1083
    .line 1084
    .line 1085
    invoke-static {v5, v6, v5}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 1086
    .line 1087
    .line 1088
    invoke-static {v5, v7, v5}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 1089
    .line 1090
    .line 1091
    invoke-static {v5, v9, v5}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 1092
    .line 1093
    .line 1094
    new-instance v5, Lcom/kousei/framework/t8;

    .line 1095
    .line 1096
    invoke-direct {v5, v7}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 1097
    .line 1098
    .line 1099
    const/4 v6, 0x7

    .line 1100
    invoke-static {v6, v13, v1, v7}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 1101
    .line 1102
    .line 1103
    move-result v1

    .line 1104
    if-nez v1, :cond_45d

    .line 1105
    .line 1106
    aget v1, v7, v2

    .line 1107
    .line 1108
    if-ne v1, v8, :cond_463

    .line 1109
    .line 1110
    sget-object v1, Lcom/kousei/framework/h0;->z:[I

    .line 1111
    .line 1112
    invoke-static {v7, v1}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 1113
    .line 1114
    .line 1115
    move-result v1

    .line 1116
    if-eqz v1, :cond_463

    .line 1117
    .line 1118
    :cond_45d
    const/16 v1, 0x1a93

    .line 1119
    .line 1120
    const/4 v2, 0x7

    .line 1121
    invoke-static {v2, v1, v7}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 1122
    .line 1123
    .line 1124
    :cond_463
    iget-object v1, v3, Lcom/kousei/framework/t8;->S:[I

    .line 1125
    .line 1126
    invoke-static {v1}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 1127
    .line 1128
    .line 1129
    move-result v1

    .line 1130
    if-nez v1, :cond_470

    .line 1131
    .line 1132
    iget-object v1, v3, Lcom/kousei/framework/t8;->S:[I

    .line 1133
    .line 1134
    invoke-static {v7, v1, v7}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 1135
    .line 1136
    .line 1137
    :cond_470
    new-instance v17, Lcom/kousei/framework/b2;

    .line 1138
    .line 1139
    new-array v1, v12, [Lcom/kousei/framework/h0;

    .line 1140
    .line 1141
    aput-object v5, v1, v13

    .line 1142
    .line 1143
    const/16 v22, 0x9

    .line 1144
    .line 1145
    move-object/from16 v18, v0

    .line 1146
    .line 1147
    move-object/from16 v21, v1

    .line 1148
    .line 1149
    move-object/from16 v19, v4

    .line 1150
    .line 1151
    move-object/from16 v20, v10

    .line 1152
    .line 1153
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 1154
    .line 1155
    .line 1156
    move-object/from16 v0, v17

    .line 1157
    .line 1158
    :goto_485
    return-object v0

    .line 1159
    :pswitch_486
    sget-object v1, Lcom/kousei/framework/h0;->w:[I

    .line 1160
    .line 1161
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 1162
    .line 1163
    .line 1164
    move-result v3

    .line 1165
    if-eqz v3, :cond_490

    .line 1166
    .line 1167
    goto/16 :goto_542

    .line 1168
    .line 1169
    :cond_490
    check-cast v11, Lcom/kousei/framework/r8;

    .line 1170
    .line 1171
    iget-object v3, v11, Lcom/kousei/framework/r8;->S:[I

    .line 1172
    .line 1173
    invoke-static {v3}, Lcom/kousei/framework/h0;->H0([I)Z

    .line 1174
    .line 1175
    .line 1176
    move-result v4

    .line 1177
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1178
    .line 1179
    if-eqz v4, :cond_4a2

    .line 1180
    .line 1181
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1182
    .line 1183
    .line 1184
    move-result-object v0

    .line 1185
    goto/16 :goto_542

    .line 1186
    .line 1187
    :cond_4a2
    check-cast v10, Lcom/kousei/framework/r8;

    .line 1188
    .line 1189
    aget-object v0, v9, v13

    .line 1190
    .line 1191
    check-cast v0, Lcom/kousei/framework/r8;

    .line 1192
    .line 1193
    new-array v4, v2, [I

    .line 1194
    .line 1195
    new-array v5, v2, [I

    .line 1196
    .line 1197
    new-array v7, v2, [I

    .line 1198
    .line 1199
    invoke-static {v3, v7}, Lcom/kousei/framework/h0;->i2([I[I)V

    .line 1200
    .line 1201
    .line 1202
    new-array v9, v2, [I

    .line 1203
    .line 1204
    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->i2([I[I)V

    .line 1205
    .line 1206
    .line 1207
    iget-object v0, v0, Lcom/kousei/framework/r8;->S:[I

    .line 1208
    .line 1209
    invoke-static {v0}, Lcom/kousei/framework/h0;->D0([I)Z

    .line 1210
    .line 1211
    .line 1212
    move-result v11

    .line 1213
    if-nez v11, :cond_4c3

    .line 1214
    .line 1215
    invoke-static {v0, v5}, Lcom/kousei/framework/h0;->i2([I[I)V

    .line 1216
    .line 1217
    .line 1218
    move-object v14, v5

    .line 1219
    goto :goto_4c4

    .line 1220
    :cond_4c3
    move-object v14, v0

    .line 1221
    :goto_4c4
    iget-object v10, v10, Lcom/kousei/framework/r8;->S:[I

    .line 1222
    .line 1223
    invoke-static {v10, v14, v4}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 1224
    .line 1225
    .line 1226
    invoke-static {v10, v14, v5}, Lcom/kousei/framework/h0;->e([I[I[I)I

    .line 1227
    .line 1228
    .line 1229
    move-result v14

    .line 1230
    if-nez v14, :cond_4d9

    .line 1231
    .line 1232
    aget v14, v5, v6

    .line 1233
    .line 1234
    if-ne v14, v8, :cond_4dc

    .line 1235
    .line 1236
    invoke-static {v5, v1}, Lcom/kousei/framework/h0;->g0([I[I)Z

    .line 1237
    .line 1238
    .line 1239
    move-result v14

    .line 1240
    if-eqz v14, :cond_4dc

    .line 1241
    .line 1242
    :cond_4d9
    invoke-static {v5}, Lcom/kousei/framework/h0;->u([I)V

    .line 1243
    .line 1244
    .line 1245
    :cond_4dc
    invoke-static {v5, v4, v5}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    .line 1246
    .line 1247
    .line 1248
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/h0;->m([I[I[I)I

    .line 1249
    .line 1250
    .line 1251
    move-result v14

    .line 1252
    invoke-static {v14, v5}, Lcom/kousei/framework/h0;->R1(I[I)V

    .line 1253
    .line 1254
    .line 1255
    invoke-static {v7, v10, v7}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    .line 1256
    .line 1257
    .line 1258
    invoke-static {v2, v7}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1259
    .line 1260
    .line 1261
    move-result v10

    .line 1262
    invoke-static {v10, v7}, Lcom/kousei/framework/h0;->R1(I[I)V

    .line 1263
    .line 1264
    .line 1265
    invoke-static {v2, v9, v4}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1266
    .line 1267
    .line 1268
    move-result v10

    .line 1269
    invoke-static {v10, v4}, Lcom/kousei/framework/h0;->R1(I[I)V

    .line 1270
    .line 1271
    .line 1272
    new-instance v10, Lcom/kousei/framework/r8;

    .line 1273
    .line 1274
    invoke-direct {v10, v9}, Lcom/kousei/framework/r8;-><init>([I)V

    .line 1275
    .line 1276
    .line 1277
    invoke-static {v5, v9}, Lcom/kousei/framework/h0;->i2([I[I)V

    .line 1278
    .line 1279
    .line 1280
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 1281
    .line 1282
    .line 1283
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 1284
    .line 1285
    .line 1286
    new-instance v14, Lcom/kousei/framework/r8;

    .line 1287
    .line 1288
    invoke-direct {v14, v7}, Lcom/kousei/framework/r8;-><init>([I)V

    .line 1289
    .line 1290
    .line 1291
    invoke-static {v7, v9, v7}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 1292
    .line 1293
    .line 1294
    invoke-static {v7, v5, v7}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    .line 1295
    .line 1296
    .line 1297
    invoke-static {v7, v4, v7}, Lcom/kousei/framework/h0;->V2([I[I[I)V

    .line 1298
    .line 1299
    .line 1300
    new-instance v4, Lcom/kousei/framework/r8;

    .line 1301
    .line 1302
    invoke-direct {v4, v5}, Lcom/kousei/framework/r8;-><init>([I)V

    .line 1303
    .line 1304
    .line 1305
    invoke-static {v2, v13, v3, v5}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 1306
    .line 1307
    .line 1308
    move-result v2

    .line 1309
    if-nez v2, :cond_528

    .line 1310
    .line 1311
    aget v2, v5, v6

    .line 1312
    .line 1313
    if-ne v2, v8, :cond_52b

    .line 1314
    .line 1315
    invoke-static {v5, v1}, Lcom/kousei/framework/h0;->g0([I[I)Z

    .line 1316
    .line 1317
    .line 1318
    move-result v1

    .line 1319
    if-eqz v1, :cond_52b

    .line 1320
    .line 1321
    :cond_528
    invoke-static {v5}, Lcom/kousei/framework/h0;->u([I)V

    .line 1322
    .line 1323
    .line 1324
    :cond_52b
    if-nez v11, :cond_530

    .line 1325
    .line 1326
    invoke-static {v5, v0, v5}, Lcom/kousei/framework/h0;->f1([I[I[I)V

    .line 1327
    .line 1328
    .line 1329
    :cond_530
    move-object/from16 v17, v14

    .line 1330
    .line 1331
    new-instance v14, Lcom/kousei/framework/b2;

    .line 1332
    .line 1333
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 1334
    .line 1335
    aput-object v4, v0, v13

    .line 1336
    .line 1337
    const/16 v19, 0x8

    .line 1338
    .line 1339
    move-object/from16 v18, v0

    .line 1340
    .line 1341
    move-object/from16 v16, v10

    .line 1342
    .line 1343
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 1344
    .line 1345
    .line 1346
    move-object v0, v14

    .line 1347
    :goto_542
    return-object v0

    .line 1348
    :pswitch_543
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 1349
    .line 1350
    .line 1351
    move-result v1

    .line 1352
    if-eqz v1, :cond_54b

    .line 1353
    .line 1354
    goto/16 :goto_5e7

    .line 1355
    .line 1356
    :cond_54b
    check-cast v11, Lcom/kousei/framework/p8;

    .line 1357
    .line 1358
    iget-object v1, v11, Lcom/kousei/framework/p8;->S:[I

    .line 1359
    .line 1360
    invoke-static {v1}, Lcom/kousei/framework/h0;->H0([I)Z

    .line 1361
    .line 1362
    .line 1363
    move-result v3

    .line 1364
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1365
    .line 1366
    if-eqz v3, :cond_55d

    .line 1367
    .line 1368
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1369
    .line 1370
    .line 1371
    move-result-object v0

    .line 1372
    goto/16 :goto_5e7

    .line 1373
    .line 1374
    :cond_55d
    check-cast v10, Lcom/kousei/framework/p8;

    .line 1375
    .line 1376
    aget-object v0, v9, v13

    .line 1377
    .line 1378
    check-cast v0, Lcom/kousei/framework/p8;

    .line 1379
    .line 1380
    new-array v3, v2, [I

    .line 1381
    .line 1382
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->h2([I[I)V

    .line 1383
    .line 1384
    .line 1385
    new-array v4, v2, [I

    .line 1386
    .line 1387
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->h2([I[I)V

    .line 1388
    .line 1389
    .line 1390
    new-array v5, v2, [I

    .line 1391
    .line 1392
    iget-object v7, v10, Lcom/kousei/framework/p8;->S:[I

    .line 1393
    .line 1394
    invoke-static {v7, v5}, Lcom/kousei/framework/h0;->h2([I[I)V

    .line 1395
    .line 1396
    .line 1397
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/h0;->m([I[I[I)I

    .line 1398
    .line 1399
    .line 1400
    move-result v7

    .line 1401
    invoke-static {v7, v5}, Lcom/kousei/framework/h0;->Q1(I[I)V

    .line 1402
    .line 1403
    .line 1404
    iget-object v7, v10, Lcom/kousei/framework/p8;->S:[I

    .line 1405
    .line 1406
    invoke-static {v3, v7, v3}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    .line 1407
    .line 1408
    .line 1409
    invoke-static {v2, v3}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1410
    .line 1411
    .line 1412
    move-result v7

    .line 1413
    invoke-static {v7, v3}, Lcom/kousei/framework/h0;->Q1(I[I)V

    .line 1414
    .line 1415
    .line 1416
    new-array v7, v2, [I

    .line 1417
    .line 1418
    invoke-static {v2, v4, v7}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1419
    .line 1420
    .line 1421
    move-result v9

    .line 1422
    invoke-static {v9, v7}, Lcom/kousei/framework/h0;->Q1(I[I)V

    .line 1423
    .line 1424
    .line 1425
    new-instance v9, Lcom/kousei/framework/p8;

    .line 1426
    .line 1427
    invoke-direct {v9, v4}, Lcom/kousei/framework/p8;-><init>([I)V

    .line 1428
    .line 1429
    .line 1430
    invoke-static {v5, v4}, Lcom/kousei/framework/h0;->h2([I[I)V

    .line 1431
    .line 1432
    .line 1433
    invoke-static {v4, v3, v4}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    .line 1434
    .line 1435
    .line 1436
    invoke-static {v4, v3, v4}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    .line 1437
    .line 1438
    .line 1439
    new-instance v10, Lcom/kousei/framework/p8;

    .line 1440
    .line 1441
    invoke-direct {v10, v3}, Lcom/kousei/framework/p8;-><init>([I)V

    .line 1442
    .line 1443
    .line 1444
    invoke-static {v3, v4, v3}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    .line 1445
    .line 1446
    .line 1447
    invoke-static {v3, v5, v3}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    .line 1448
    .line 1449
    .line 1450
    invoke-static {v3, v7, v3}, Lcom/kousei/framework/h0;->U2([I[I[I)V

    .line 1451
    .line 1452
    .line 1453
    new-instance v3, Lcom/kousei/framework/p8;

    .line 1454
    .line 1455
    invoke-direct {v3, v5}, Lcom/kousei/framework/p8;-><init>([I)V

    .line 1456
    .line 1457
    .line 1458
    invoke-static {v2, v13, v1, v5}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 1459
    .line 1460
    .line 1461
    move-result v1

    .line 1462
    if-nez v1, :cond_5c3

    .line 1463
    .line 1464
    aget v1, v5, v6

    .line 1465
    .line 1466
    if-ne v1, v8, :cond_5c8

    .line 1467
    .line 1468
    sget-object v1, Lcom/kousei/framework/h0;->t:[I

    .line 1469
    .line 1470
    invoke-static {v5, v1}, Lcom/kousei/framework/h0;->g0([I[I)Z

    .line 1471
    .line 1472
    .line 1473
    move-result v1

    .line 1474
    if-eqz v1, :cond_5c8

    .line 1475
    .line 1476
    :cond_5c3
    const/16 v1, 0x11c9

    .line 1477
    .line 1478
    invoke-static {v2, v1, v5}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 1479
    .line 1480
    .line 1481
    :cond_5c8
    iget-object v1, v0, Lcom/kousei/framework/p8;->S:[I

    .line 1482
    .line 1483
    invoke-static {v1}, Lcom/kousei/framework/h0;->D0([I)Z

    .line 1484
    .line 1485
    .line 1486
    move-result v1

    .line 1487
    if-nez v1, :cond_5d5

    .line 1488
    .line 1489
    iget-object v0, v0, Lcom/kousei/framework/p8;->S:[I

    .line 1490
    .line 1491
    invoke-static {v5, v0, v5}, Lcom/kousei/framework/h0;->e1([I[I[I)V

    .line 1492
    .line 1493
    .line 1494
    :cond_5d5
    new-instance v14, Lcom/kousei/framework/b2;

    .line 1495
    .line 1496
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 1497
    .line 1498
    aput-object v3, v0, v13

    .line 1499
    .line 1500
    const/16 v19, 0x7

    .line 1501
    .line 1502
    move-object/from16 v18, v0

    .line 1503
    .line 1504
    move-object/from16 v16, v9

    .line 1505
    .line 1506
    move-object/from16 v17, v10

    .line 1507
    .line 1508
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 1509
    .line 1510
    .line 1511
    move-object v0, v14

    .line 1512
    :goto_5e7
    return-object v0

    .line 1513
    :pswitch_5e8
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 1514
    .line 1515
    .line 1516
    move-result v1

    .line 1517
    if-eqz v1, :cond_5f0

    .line 1518
    .line 1519
    goto/16 :goto_696

    .line 1520
    .line 1521
    :cond_5f0
    check-cast v11, Lcom/kousei/framework/n8;

    .line 1522
    .line 1523
    iget-object v1, v11, Lcom/kousei/framework/n8;->S:[I

    .line 1524
    .line 1525
    invoke-static {v1}, Lcom/kousei/framework/h0;->G0([I)Z

    .line 1526
    .line 1527
    .line 1528
    move-result v2

    .line 1529
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1530
    .line 1531
    if-eqz v2, :cond_602

    .line 1532
    .line 1533
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1534
    .line 1535
    .line 1536
    move-result-object v0

    .line 1537
    goto/16 :goto_696

    .line 1538
    .line 1539
    :cond_602
    check-cast v10, Lcom/kousei/framework/n8;

    .line 1540
    .line 1541
    aget-object v0, v9, v13

    .line 1542
    .line 1543
    check-cast v0, Lcom/kousei/framework/n8;

    .line 1544
    .line 1545
    new-array v2, v6, [I

    .line 1546
    .line 1547
    new-array v3, v6, [I

    .line 1548
    .line 1549
    new-array v4, v6, [I

    .line 1550
    .line 1551
    invoke-static {v1, v4}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1552
    .line 1553
    .line 1554
    new-array v7, v6, [I

    .line 1555
    .line 1556
    invoke-static {v4, v7}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1557
    .line 1558
    .line 1559
    iget-object v0, v0, Lcom/kousei/framework/n8;->S:[I

    .line 1560
    .line 1561
    invoke-static {v0}, Lcom/kousei/framework/h0;->C0([I)Z

    .line 1562
    .line 1563
    .line 1564
    move-result v9

    .line 1565
    if-nez v9, :cond_623

    .line 1566
    .line 1567
    invoke-static {v0, v3}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1568
    .line 1569
    .line 1570
    move-object v11, v3

    .line 1571
    goto :goto_624

    .line 1572
    :cond_623
    move-object v11, v0

    .line 1573
    :goto_624
    iget-object v10, v10, Lcom/kousei/framework/n8;->S:[I

    .line 1574
    .line 1575
    invoke-static {v10, v11, v2}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1576
    .line 1577
    .line 1578
    invoke-static {v10, v11, v3}, Lcom/kousei/framework/h0;->a([I[I[I)I

    .line 1579
    .line 1580
    .line 1581
    move-result v11

    .line 1582
    if-nez v11, :cond_63b

    .line 1583
    .line 1584
    aget v5, v3, v5

    .line 1585
    .line 1586
    if-ne v5, v8, :cond_640

    .line 1587
    .line 1588
    sget-object v5, Lcom/kousei/framework/h0;->q:[I

    .line 1589
    .line 1590
    invoke-static {v3, v5}, Lcom/kousei/framework/h0;->f0([I[I)Z

    .line 1591
    .line 1592
    .line 1593
    move-result v5

    .line 1594
    if-eqz v5, :cond_640

    .line 1595
    .line 1596
    :cond_63b
    const/16 v5, 0x538d

    .line 1597
    .line 1598
    invoke-static {v6, v5, v3}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 1599
    .line 1600
    .line 1601
    :cond_640
    invoke-static {v3, v2, v3}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1602
    .line 1603
    .line 1604
    invoke-static {v3, v3, v3}, Lcom/kousei/framework/h0;->l([I[I[I)I

    .line 1605
    .line 1606
    .line 1607
    move-result v5

    .line 1608
    invoke-static {v5, v3}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1609
    .line 1610
    .line 1611
    invoke-static {v4, v10, v4}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1612
    .line 1613
    .line 1614
    invoke-static {v6, v4}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1615
    .line 1616
    .line 1617
    move-result v5

    .line 1618
    invoke-static {v5, v4}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1619
    .line 1620
    .line 1621
    invoke-static {v6, v7, v2}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1622
    .line 1623
    .line 1624
    move-result v5

    .line 1625
    invoke-static {v5, v2}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1626
    .line 1627
    .line 1628
    new-instance v5, Lcom/kousei/framework/n8;

    .line 1629
    .line 1630
    invoke-direct {v5, v7}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1631
    .line 1632
    .line 1633
    invoke-static {v3, v7}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1634
    .line 1635
    .line 1636
    invoke-static {v7, v4, v7}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1637
    .line 1638
    .line 1639
    invoke-static {v7, v4, v7}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1640
    .line 1641
    .line 1642
    new-instance v6, Lcom/kousei/framework/n8;

    .line 1643
    .line 1644
    invoke-direct {v6, v4}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1645
    .line 1646
    .line 1647
    invoke-static {v4, v7, v4}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1648
    .line 1649
    .line 1650
    invoke-static {v4, v3, v4}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1651
    .line 1652
    .line 1653
    invoke-static {v4, v2, v4}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1654
    .line 1655
    .line 1656
    new-instance v2, Lcom/kousei/framework/n8;

    .line 1657
    .line 1658
    invoke-direct {v2, v3}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1659
    .line 1660
    .line 1661
    invoke-static {v1, v3}, Lcom/kousei/framework/h0;->e3([I[I)V

    .line 1662
    .line 1663
    .line 1664
    if-nez v9, :cond_684

    .line 1665
    .line 1666
    invoke-static {v3, v0, v3}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1667
    .line 1668
    .line 1669
    :cond_684
    new-instance v14, Lcom/kousei/framework/b2;

    .line 1670
    .line 1671
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 1672
    .line 1673
    aput-object v2, v0, v13

    .line 1674
    .line 1675
    const/16 v19, 0x6

    .line 1676
    .line 1677
    move-object/from16 v18, v0

    .line 1678
    .line 1679
    move-object/from16 v16, v5

    .line 1680
    .line 1681
    move-object/from16 v17, v6

    .line 1682
    .line 1683
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 1684
    .line 1685
    .line 1686
    move-object v0, v14

    .line 1687
    :goto_696
    return-object v0

    .line 1688
    :pswitch_697
    sget-object v1, Lcom/kousei/framework/h0;->n:[I

    .line 1689
    .line 1690
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 1691
    .line 1692
    .line 1693
    move-result v2

    .line 1694
    if-eqz v2, :cond_6a1

    .line 1695
    .line 1696
    goto/16 :goto_758

    .line 1697
    .line 1698
    :cond_6a1
    check-cast v11, Lcom/kousei/framework/l8;

    .line 1699
    .line 1700
    iget-object v2, v11, Lcom/kousei/framework/l8;->S:[I

    .line 1701
    .line 1702
    invoke-static {v2}, Lcom/kousei/framework/h0;->G0([I)Z

    .line 1703
    .line 1704
    .line 1705
    move-result v3

    .line 1706
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1707
    .line 1708
    if-eqz v3, :cond_6b3

    .line 1709
    .line 1710
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1711
    .line 1712
    .line 1713
    move-result-object v0

    .line 1714
    goto/16 :goto_758

    .line 1715
    .line 1716
    :cond_6b3
    check-cast v10, Lcom/kousei/framework/l8;

    .line 1717
    .line 1718
    aget-object v0, v9, v13

    .line 1719
    .line 1720
    check-cast v0, Lcom/kousei/framework/l8;

    .line 1721
    .line 1722
    new-array v3, v6, [I

    .line 1723
    .line 1724
    new-array v4, v6, [I

    .line 1725
    .line 1726
    new-array v7, v6, [I

    .line 1727
    .line 1728
    invoke-static {v2, v7}, Lcom/kousei/framework/h0;->f2([I[I)V

    .line 1729
    .line 1730
    .line 1731
    new-array v9, v6, [I

    .line 1732
    .line 1733
    invoke-static {v7, v9}, Lcom/kousei/framework/h0;->f2([I[I)V

    .line 1734
    .line 1735
    .line 1736
    iget-object v0, v0, Lcom/kousei/framework/l8;->S:[I

    .line 1737
    .line 1738
    invoke-static {v0}, Lcom/kousei/framework/h0;->C0([I)Z

    .line 1739
    .line 1740
    .line 1741
    move-result v11

    .line 1742
    if-nez v11, :cond_6d4

    .line 1743
    .line 1744
    invoke-static {v0, v4}, Lcom/kousei/framework/h0;->f2([I[I)V

    .line 1745
    .line 1746
    .line 1747
    move-object v14, v4

    .line 1748
    goto :goto_6d5

    .line 1749
    :cond_6d4
    move-object v14, v0

    .line 1750
    :goto_6d5
    iget-object v10, v10, Lcom/kousei/framework/l8;->S:[I

    .line 1751
    .line 1752
    invoke-static {v10, v14, v3}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 1753
    .line 1754
    .line 1755
    invoke-static {v10, v14, v4}, Lcom/kousei/framework/h0;->a([I[I[I)I

    .line 1756
    .line 1757
    .line 1758
    move-result v14

    .line 1759
    move/from16 v16, v5

    .line 1760
    .line 1761
    const v5, -0x7fffffff

    .line 1762
    .line 1763
    .line 1764
    if-nez v14, :cond_6ef

    .line 1765
    .line 1766
    aget v14, v4, v16

    .line 1767
    .line 1768
    if-ne v14, v8, :cond_6f2

    .line 1769
    .line 1770
    invoke-static {v4, v1}, Lcom/kousei/framework/h0;->f0([I[I)Z

    .line 1771
    .line 1772
    .line 1773
    move-result v14

    .line 1774
    if-eqz v14, :cond_6f2

    .line 1775
    .line 1776
    :cond_6ef
    invoke-static {v6, v5, v4}, Lcom/kousei/framework/n6;->q(II[I)I

    .line 1777
    .line 1778
    .line 1779
    :cond_6f2
    invoke-static {v4, v3, v4}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    .line 1780
    .line 1781
    .line 1782
    invoke-static {v4, v4, v4}, Lcom/kousei/framework/h0;->l([I[I[I)I

    .line 1783
    .line 1784
    .line 1785
    move-result v14

    .line 1786
    invoke-static {v14, v4}, Lcom/kousei/framework/h0;->O1(I[I)V

    .line 1787
    .line 1788
    .line 1789
    invoke-static {v7, v10, v7}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    .line 1790
    .line 1791
    .line 1792
    invoke-static {v6, v7}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1793
    .line 1794
    .line 1795
    move-result v10

    .line 1796
    invoke-static {v10, v7}, Lcom/kousei/framework/h0;->O1(I[I)V

    .line 1797
    .line 1798
    .line 1799
    invoke-static {v6, v9, v3}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1800
    .line 1801
    .line 1802
    move-result v10

    .line 1803
    invoke-static {v10, v3}, Lcom/kousei/framework/h0;->O1(I[I)V

    .line 1804
    .line 1805
    .line 1806
    new-instance v10, Lcom/kousei/framework/l8;

    .line 1807
    .line 1808
    invoke-direct {v10, v9}, Lcom/kousei/framework/l8;-><init>([I)V

    .line 1809
    .line 1810
    .line 1811
    invoke-static {v4, v9}, Lcom/kousei/framework/h0;->f2([I[I)V

    .line 1812
    .line 1813
    .line 1814
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 1815
    .line 1816
    .line 1817
    invoke-static {v9, v7, v9}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 1818
    .line 1819
    .line 1820
    new-instance v14, Lcom/kousei/framework/l8;

    .line 1821
    .line 1822
    invoke-direct {v14, v7}, Lcom/kousei/framework/l8;-><init>([I)V

    .line 1823
    .line 1824
    .line 1825
    invoke-static {v7, v9, v7}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 1826
    .line 1827
    .line 1828
    invoke-static {v7, v4, v7}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    .line 1829
    .line 1830
    .line 1831
    invoke-static {v7, v3, v7}, Lcom/kousei/framework/h0;->S2([I[I[I)V

    .line 1832
    .line 1833
    .line 1834
    new-instance v3, Lcom/kousei/framework/l8;

    .line 1835
    .line 1836
    invoke-direct {v3, v4}, Lcom/kousei/framework/l8;-><init>([I)V

    .line 1837
    .line 1838
    .line 1839
    invoke-static {v6, v13, v2, v4}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 1840
    .line 1841
    .line 1842
    move-result v2

    .line 1843
    if-nez v2, :cond_73e

    .line 1844
    .line 1845
    aget v2, v4, v16

    .line 1846
    .line 1847
    if-ne v2, v8, :cond_741

    .line 1848
    .line 1849
    invoke-static {v4, v1}, Lcom/kousei/framework/h0;->f0([I[I)Z

    .line 1850
    .line 1851
    .line 1852
    move-result v1

    .line 1853
    if-eqz v1, :cond_741

    .line 1854
    .line 1855
    :cond_73e
    invoke-static {v6, v5, v4}, Lcom/kousei/framework/n6;->q(II[I)I

    .line 1856
    .line 1857
    .line 1858
    :cond_741
    if-nez v11, :cond_746

    .line 1859
    .line 1860
    invoke-static {v4, v0, v4}, Lcom/kousei/framework/h0;->a1([I[I[I)V

    .line 1861
    .line 1862
    .line 1863
    :cond_746
    move-object/from16 v17, v14

    .line 1864
    .line 1865
    new-instance v14, Lcom/kousei/framework/b2;

    .line 1866
    .line 1867
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 1868
    .line 1869
    aput-object v3, v0, v13

    .line 1870
    .line 1871
    const/16 v19, 0x5

    .line 1872
    .line 1873
    move-object/from16 v18, v0

    .line 1874
    .line 1875
    move-object/from16 v16, v10

    .line 1876
    .line 1877
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 1878
    .line 1879
    .line 1880
    move-object v0, v14

    .line 1881
    :goto_758
    return-object v0

    .line 1882
    :pswitch_759
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 1883
    .line 1884
    .line 1885
    move-result v1

    .line 1886
    if-eqz v1, :cond_761

    .line 1887
    .line 1888
    goto/16 :goto_7e8

    .line 1889
    .line 1890
    :cond_761
    check-cast v11, Lcom/kousei/framework/n8;

    .line 1891
    .line 1892
    iget-object v1, v11, Lcom/kousei/framework/n8;->S:[I

    .line 1893
    .line 1894
    invoke-static {v1}, Lcom/kousei/framework/h0;->G0([I)Z

    .line 1895
    .line 1896
    .line 1897
    move-result v2

    .line 1898
    iget-object v15, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 1899
    .line 1900
    if-eqz v2, :cond_772

    .line 1901
    .line 1902
    invoke-virtual {v15}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 1903
    .line 1904
    .line 1905
    move-result-object v0

    .line 1906
    goto :goto_7e8

    .line 1907
    :cond_772
    check-cast v10, Lcom/kousei/framework/n8;

    .line 1908
    .line 1909
    aget-object v0, v9, v13

    .line 1910
    .line 1911
    check-cast v0, Lcom/kousei/framework/n8;

    .line 1912
    .line 1913
    new-array v2, v6, [I

    .line 1914
    .line 1915
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1916
    .line 1917
    .line 1918
    new-array v3, v6, [I

    .line 1919
    .line 1920
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1921
    .line 1922
    .line 1923
    new-array v4, v6, [I

    .line 1924
    .line 1925
    iget-object v5, v10, Lcom/kousei/framework/n8;->S:[I

    .line 1926
    .line 1927
    invoke-static {v5, v4}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1928
    .line 1929
    .line 1930
    invoke-static {v4, v4, v4}, Lcom/kousei/framework/h0;->l([I[I[I)I

    .line 1931
    .line 1932
    .line 1933
    move-result v5

    .line 1934
    invoke-static {v5, v4}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1935
    .line 1936
    .line 1937
    iget-object v5, v10, Lcom/kousei/framework/n8;->S:[I

    .line 1938
    .line 1939
    invoke-static {v2, v5, v2}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1940
    .line 1941
    .line 1942
    invoke-static {v6, v2}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 1943
    .line 1944
    .line 1945
    move-result v5

    .line 1946
    invoke-static {v5, v2}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1947
    .line 1948
    .line 1949
    new-array v5, v6, [I

    .line 1950
    .line 1951
    invoke-static {v6, v3, v5}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 1952
    .line 1953
    .line 1954
    move-result v6

    .line 1955
    invoke-static {v6, v5}, Lcom/kousei/framework/h0;->P1(I[I)V

    .line 1956
    .line 1957
    .line 1958
    new-instance v6, Lcom/kousei/framework/n8;

    .line 1959
    .line 1960
    invoke-direct {v6, v3}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1961
    .line 1962
    .line 1963
    invoke-static {v4, v3}, Lcom/kousei/framework/h0;->g2([I[I)V

    .line 1964
    .line 1965
    .line 1966
    invoke-static {v3, v2, v3}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1967
    .line 1968
    .line 1969
    invoke-static {v3, v2, v3}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1970
    .line 1971
    .line 1972
    new-instance v7, Lcom/kousei/framework/n8;

    .line 1973
    .line 1974
    invoke-direct {v7, v2}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1975
    .line 1976
    .line 1977
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1978
    .line 1979
    .line 1980
    invoke-static {v2, v4, v2}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 1981
    .line 1982
    .line 1983
    invoke-static {v2, v5, v2}, Lcom/kousei/framework/h0;->T2([I[I[I)V

    .line 1984
    .line 1985
    .line 1986
    new-instance v2, Lcom/kousei/framework/n8;

    .line 1987
    .line 1988
    invoke-direct {v2, v4}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 1989
    .line 1990
    .line 1991
    invoke-static {v1, v4}, Lcom/kousei/framework/h0;->e3([I[I)V

    .line 1992
    .line 1993
    .line 1994
    iget-object v1, v0, Lcom/kousei/framework/n8;->S:[I

    .line 1995
    .line 1996
    invoke-static {v1}, Lcom/kousei/framework/h0;->C0([I)Z

    .line 1997
    .line 1998
    .line 1999
    move-result v1

    .line 2000
    if-nez v1, :cond_7d6

    .line 2001
    .line 2002
    iget-object v0, v0, Lcom/kousei/framework/n8;->S:[I

    .line 2003
    .line 2004
    invoke-static {v4, v0, v4}, Lcom/kousei/framework/h0;->d1([I[I[I)V

    .line 2005
    .line 2006
    .line 2007
    :cond_7d6
    new-instance v14, Lcom/kousei/framework/b2;

    .line 2008
    .line 2009
    new-array v0, v12, [Lcom/kousei/framework/h0;

    .line 2010
    .line 2011
    aput-object v2, v0, v13

    .line 2012
    .line 2013
    const/16 v19, 0x4

    .line 2014
    .line 2015
    move-object/from16 v18, v0

    .line 2016
    .line 2017
    move-object/from16 v16, v6

    .line 2018
    .line 2019
    move-object/from16 v17, v7

    .line 2020
    .line 2021
    invoke-direct/range {v14 .. v19}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 2022
    .line 2023
    .line 2024
    move-object v0, v14

    .line 2025
    :goto_7e8
    return-object v0

    .line 2026
    :pswitch_7e9
    move/from16 v16, v5

    .line 2027
    .line 2028
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 2029
    .line 2030
    .line 2031
    move-result v1

    .line 2032
    if-eqz v1, :cond_7f3

    .line 2033
    .line 2034
    goto/16 :goto_89c

    .line 2035
    .line 2036
    :cond_7f3
    check-cast v11, Lcom/kousei/framework/i8;

    .line 2037
    .line 2038
    iget-object v1, v11, Lcom/kousei/framework/i8;->S:[I

    .line 2039
    .line 2040
    invoke-static {v1}, Lcom/kousei/framework/h0;->F0([I)Z

    .line 2041
    .line 2042
    .line 2043
    move-result v2

    .line 2044
    iget-object v4, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2045
    .line 2046
    if-eqz v2, :cond_805

    .line 2047
    .line 2048
    invoke-virtual {v4}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 2049
    .line 2050
    .line 2051
    move-result-object v0

    .line 2052
    goto/16 :goto_89c

    .line 2053
    .line 2054
    :cond_805
    check-cast v10, Lcom/kousei/framework/i8;

    .line 2055
    .line 2056
    aget-object v0, v9, v13

    .line 2057
    .line 2058
    check-cast v0, Lcom/kousei/framework/i8;

    .line 2059
    .line 2060
    move/from16 v2, v16

    .line 2061
    .line 2062
    new-array v3, v2, [I

    .line 2063
    .line 2064
    new-array v5, v2, [I

    .line 2065
    .line 2066
    new-array v6, v2, [I

    .line 2067
    .line 2068
    invoke-static {v1, v6}, Lcom/kousei/framework/h0;->e2([I[I)V

    .line 2069
    .line 2070
    .line 2071
    new-array v7, v2, [I

    .line 2072
    .line 2073
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->e2([I[I)V

    .line 2074
    .line 2075
    .line 2076
    iget-object v0, v0, Lcom/kousei/framework/i8;->S:[I

    .line 2077
    .line 2078
    invoke-static {v0}, Lcom/kousei/framework/h0;->B0([I)Z

    .line 2079
    .line 2080
    .line 2081
    move-result v2

    .line 2082
    if-nez v2, :cond_828

    .line 2083
    .line 2084
    invoke-static {v0, v5}, Lcom/kousei/framework/h0;->e2([I[I)V

    .line 2085
    .line 2086
    .line 2087
    move-object v8, v5

    .line 2088
    goto :goto_829

    .line 2089
    :cond_828
    move-object v8, v0

    .line 2090
    :goto_829
    iget-object v9, v10, Lcom/kousei/framework/i8;->S:[I

    .line 2091
    .line 2092
    invoke-static {v9, v8, v3}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 2093
    .line 2094
    .line 2095
    invoke-static {v9, v8, v5}, Lcom/kousei/framework/h0;->f([I[I[I)V

    .line 2096
    .line 2097
    .line 2098
    invoke-static {v5, v3, v5}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    .line 2099
    .line 2100
    .line 2101
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/h0;->i([I[I[I)I

    .line 2102
    .line 2103
    .line 2104
    move-result v8

    .line 2105
    invoke-static {v8, v5}, Lcom/kousei/framework/h0;->M1(I[I)V

    .line 2106
    .line 2107
    .line 2108
    invoke-static {v6, v9, v6}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    .line 2109
    .line 2110
    .line 2111
    const/4 v8, 0x4

    .line 2112
    invoke-static {v8, v6}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 2113
    .line 2114
    .line 2115
    move-result v9

    .line 2116
    invoke-static {v9, v6}, Lcom/kousei/framework/h0;->M1(I[I)V

    .line 2117
    .line 2118
    .line 2119
    invoke-static {v8, v7, v3}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 2120
    .line 2121
    .line 2122
    move-result v9

    .line 2123
    invoke-static {v9, v3}, Lcom/kousei/framework/h0;->M1(I[I)V

    .line 2124
    .line 2125
    .line 2126
    new-instance v8, Lcom/kousei/framework/i8;

    .line 2127
    .line 2128
    invoke-direct {v8, v7}, Lcom/kousei/framework/i8;-><init>([I)V

    .line 2129
    .line 2130
    .line 2131
    invoke-static {v5, v7}, Lcom/kousei/framework/h0;->e2([I[I)V

    .line 2132
    .line 2133
    .line 2134
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 2135
    .line 2136
    .line 2137
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 2138
    .line 2139
    .line 2140
    new-instance v9, Lcom/kousei/framework/i8;

    .line 2141
    .line 2142
    invoke-direct {v9, v6}, Lcom/kousei/framework/i8;-><init>([I)V

    .line 2143
    .line 2144
    .line 2145
    invoke-static {v6, v7, v6}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 2146
    .line 2147
    .line 2148
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    .line 2149
    .line 2150
    .line 2151
    invoke-static {v6, v3, v6}, Lcom/kousei/framework/h0;->R2([I[I[I)V

    .line 2152
    .line 2153
    .line 2154
    new-instance v3, Lcom/kousei/framework/i8;

    .line 2155
    .line 2156
    invoke-direct {v3, v5}, Lcom/kousei/framework/i8;-><init>([I)V

    .line 2157
    .line 2158
    .line 2159
    const/4 v6, 0x4

    .line 2160
    invoke-static {v6, v13, v1, v5}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 2161
    .line 2162
    .line 2163
    move-result v1

    .line 2164
    if-nez v1, :cond_886

    .line 2165
    .line 2166
    const/4 v1, 0x3

    .line 2167
    aget v1, v5, v1

    .line 2168
    .line 2169
    ushr-int/2addr v1, v12

    .line 2170
    const v6, 0x7ffffffe

    .line 2171
    .line 2172
    .line 2173
    if-lt v1, v6, :cond_889

    .line 2174
    .line 2175
    sget-object v1, Lcom/kousei/framework/h0;->k:[I

    .line 2176
    .line 2177
    invoke-static {v5, v1}, Lcom/kousei/framework/h0;->e0([I[I)Z

    .line 2178
    .line 2179
    .line 2180
    move-result v1

    .line 2181
    if-eqz v1, :cond_889

    .line 2182
    .line 2183
    :cond_886
    invoke-static {v5}, Lcom/kousei/framework/h0;->t([I)V

    .line 2184
    .line 2185
    .line 2186
    :cond_889
    if-nez v2, :cond_88e

    .line 2187
    .line 2188
    invoke-static {v5, v0, v5}, Lcom/kousei/framework/h0;->X0([I[I[I)V

    .line 2189
    .line 2190
    .line 2191
    :cond_88e
    move-object v0, v3

    .line 2192
    new-instance v3, Lcom/kousei/framework/b2;

    .line 2193
    .line 2194
    new-array v7, v12, [Lcom/kousei/framework/h0;

    .line 2195
    .line 2196
    aput-object v0, v7, v13

    .line 2197
    .line 2198
    move-object v5, v8

    .line 2199
    const/4 v8, 0x3

    .line 2200
    move-object v6, v9

    .line 2201
    invoke-direct/range {v3 .. v8}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 2202
    .line 2203
    .line 2204
    move-object v0, v3

    .line 2205
    :goto_89c
    return-object v0

    .line 2206
    :pswitch_89d
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 2207
    .line 2208
    .line 2209
    move-result v1

    .line 2210
    if-eqz v1, :cond_8a5

    .line 2211
    .line 2212
    goto/16 :goto_952

    .line 2213
    .line 2214
    :cond_8a5
    check-cast v11, Lcom/kousei/framework/g8;

    .line 2215
    .line 2216
    iget-object v1, v11, Lcom/kousei/framework/g8;->S:[I

    .line 2217
    .line 2218
    invoke-static {v1}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 2219
    .line 2220
    .line 2221
    move-result v2

    .line 2222
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2223
    .line 2224
    if-eqz v2, :cond_8b7

    .line 2225
    .line 2226
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 2227
    .line 2228
    .line 2229
    move-result-object v0

    .line 2230
    goto/16 :goto_952

    .line 2231
    .line 2232
    :cond_8b7
    check-cast v10, Lcom/kousei/framework/g8;

    .line 2233
    .line 2234
    aget-object v2, v9, v13

    .line 2235
    .line 2236
    check-cast v2, Lcom/kousei/framework/g8;

    .line 2237
    .line 2238
    new-array v4, v3, [I

    .line 2239
    .line 2240
    new-array v5, v3, [I

    .line 2241
    .line 2242
    new-array v6, v3, [I

    .line 2243
    .line 2244
    invoke-static {v1, v6}, Lcom/kousei/framework/h0;->a2([I[I)V

    .line 2245
    .line 2246
    .line 2247
    new-array v7, v3, [I

    .line 2248
    .line 2249
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->a2([I[I)V

    .line 2250
    .line 2251
    .line 2252
    iget-object v2, v2, Lcom/kousei/framework/g8;->S:[I

    .line 2253
    .line 2254
    invoke-static {v2}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 2255
    .line 2256
    .line 2257
    move-result v8

    .line 2258
    if-nez v8, :cond_8d8

    .line 2259
    .line 2260
    invoke-static {v2, v5}, Lcom/kousei/framework/h0;->a2([I[I)V

    .line 2261
    .line 2262
    .line 2263
    move-object v9, v5

    .line 2264
    goto :goto_8d9

    .line 2265
    :cond_8d8
    move-object v9, v2

    .line 2266
    :goto_8d9
    iget-object v10, v10, Lcom/kousei/framework/g8;->S:[I

    .line 2267
    .line 2268
    invoke-static {v10, v9, v4}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 2269
    .line 2270
    .line 2271
    invoke-static {v10, v9, v5}, Lcom/kousei/framework/h0;->c([I[I[I)V

    .line 2272
    .line 2273
    .line 2274
    invoke-static {v5, v4, v5}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    .line 2275
    .line 2276
    .line 2277
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 2278
    .line 2279
    .line 2280
    move-result v9

    .line 2281
    invoke-static {v9, v5}, Lcom/kousei/framework/h0;->L1(I[I)V

    .line 2282
    .line 2283
    .line 2284
    invoke-static {v6, v10, v6}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    .line 2285
    .line 2286
    .line 2287
    invoke-static {v3, v6}, Lcom/kousei/framework/n6;->O0(I[I)I

    .line 2288
    .line 2289
    .line 2290
    move-result v9

    .line 2291
    invoke-static {v9, v6}, Lcom/kousei/framework/h0;->L1(I[I)V

    .line 2292
    .line 2293
    .line 2294
    invoke-static {v3, v7, v4}, Lcom/kousei/framework/n6;->P0(I[I[I)I

    .line 2295
    .line 2296
    .line 2297
    move-result v9

    .line 2298
    invoke-static {v9, v4}, Lcom/kousei/framework/h0;->L1(I[I)V

    .line 2299
    .line 2300
    .line 2301
    new-instance v9, Lcom/kousei/framework/g8;

    .line 2302
    .line 2303
    invoke-direct {v9, v7}, Lcom/kousei/framework/g8;-><init>([I)V

    .line 2304
    .line 2305
    .line 2306
    invoke-static {v5, v7}, Lcom/kousei/framework/h0;->a2([I[I)V

    .line 2307
    .line 2308
    .line 2309
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 2310
    .line 2311
    .line 2312
    invoke-static {v7, v6, v7}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 2313
    .line 2314
    .line 2315
    new-instance v10, Lcom/kousei/framework/g8;

    .line 2316
    .line 2317
    invoke-direct {v10, v6}, Lcom/kousei/framework/g8;-><init>([I)V

    .line 2318
    .line 2319
    .line 2320
    invoke-static {v6, v7, v6}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 2321
    .line 2322
    .line 2323
    invoke-static {v6, v5, v6}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    .line 2324
    .line 2325
    .line 2326
    invoke-static {v6, v4, v6}, Lcom/kousei/framework/h0;->N2([I[I[I)V

    .line 2327
    .line 2328
    .line 2329
    new-instance v4, Lcom/kousei/framework/g8;

    .line 2330
    .line 2331
    invoke-direct {v4, v5}, Lcom/kousei/framework/g8;-><init>([I)V

    .line 2332
    .line 2333
    .line 2334
    invoke-static {v3, v13, v1, v5}, Lcom/kousei/framework/n6;->N0(II[I[I)I

    .line 2335
    .line 2336
    .line 2337
    move-result v1

    .line 2338
    if-nez v1, :cond_935

    .line 2339
    .line 2340
    const/16 v16, 0x7

    .line 2341
    .line 2342
    aget v1, v5, v16

    .line 2343
    .line 2344
    ushr-int/2addr v1, v12

    .line 2345
    const v3, 0x7fffffff

    .line 2346
    .line 2347
    .line 2348
    if-lt v1, v3, :cond_938

    .line 2349
    .line 2350
    sget-object v1, Lcom/kousei/framework/h0;->i:[I

    .line 2351
    .line 2352
    invoke-static {v5, v1}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 2353
    .line 2354
    .line 2355
    move-result v1

    .line 2356
    if-eqz v1, :cond_938

    .line 2357
    .line 2358
    :cond_935
    invoke-static {v5}, Lcom/kousei/framework/h0;->s([I)V

    .line 2359
    .line 2360
    .line 2361
    :cond_938
    if-nez v8, :cond_93d

    .line 2362
    .line 2363
    invoke-static {v5, v2, v5}, Lcom/kousei/framework/h0;->U0([I[I[I)V

    .line 2364
    .line 2365
    .line 2366
    :cond_93d
    new-instance v17, Lcom/kousei/framework/b2;

    .line 2367
    .line 2368
    new-array v1, v12, [Lcom/kousei/framework/h0;

    .line 2369
    .line 2370
    aput-object v4, v1, v13

    .line 2371
    .line 2372
    const/16 v22, 0x2

    .line 2373
    .line 2374
    move-object/from16 v18, v0

    .line 2375
    .line 2376
    move-object/from16 v21, v1

    .line 2377
    .line 2378
    move-object/from16 v19, v9

    .line 2379
    .line 2380
    move-object/from16 v20, v10

    .line 2381
    .line 2382
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 2383
    .line 2384
    .line 2385
    move-object/from16 v0, v17

    .line 2386
    .line 2387
    :goto_952
    return-object v0

    .line 2388
    :pswitch_953
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 2389
    .line 2390
    .line 2391
    move-result v1

    .line 2392
    if-eqz v1, :cond_95b

    .line 2393
    .line 2394
    goto/16 :goto_b17

    .line 2395
    .line 2396
    :cond_95b
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->E0()Z

    .line 2397
    .line 2398
    .line 2399
    move-result v1

    .line 2400
    iget-object v3, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2401
    .line 2402
    if-eqz v1, :cond_969

    .line 2403
    .line 2404
    invoke-virtual {v3}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 2405
    .line 2406
    .line 2407
    move-result-object v0

    .line 2408
    goto/16 :goto_b17

    .line 2409
    .line 2410
    :cond_969
    iget v1, v3, Lcom/kousei/framework/v3;->f:I

    .line 2411
    .line 2412
    if-eqz v1, :cond_adf

    .line 2413
    .line 2414
    if-eq v1, v12, :cond_a4c

    .line 2415
    .line 2416
    const/4 v2, 0x2

    .line 2417
    if-eq v1, v2, :cond_983

    .line 2418
    .line 2419
    const/4 v2, 0x4

    .line 2420
    if-ne v1, v2, :cond_97b

    .line 2421
    .line 2422
    invoke-virtual {v0, v12}, Lcom/kousei/framework/b2;->z(Z)Lcom/kousei/framework/b2;

    .line 2423
    .line 2424
    .line 2425
    move-result-object v0

    .line 2426
    goto/16 :goto_b17

    .line 2427
    .line 2428
    :cond_97b
    const-string v0, "unsupported coordinate system"

    .line 2429
    .line 2430
    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 2431
    .line 2432
    .line 2433
    const/4 v0, 0x0

    .line 2434
    goto/16 :goto_b17

    .line 2435
    .line 2436
    :cond_983
    aget-object v0, v9, v13

    .line 2437
    .line 2438
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->A0()Z

    .line 2439
    .line 2440
    .line 2441
    move-result v1

    .line 2442
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2443
    .line 2444
    .line 2445
    move-result-object v2

    .line 2446
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2447
    .line 2448
    .line 2449
    move-result-object v4

    .line 2450
    iget-object v5, v3, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 2451
    .line 2452
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 2453
    .line 2454
    .line 2455
    move-result-object v6

    .line 2456
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 2457
    .line 2458
    .line 2459
    move-result-object v7

    .line 2460
    const-wide/16 v8, 0x3

    .line 2461
    .line 2462
    invoke-static {v8, v9}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 2463
    .line 2464
    .line 2465
    move-result-object v8

    .line 2466
    invoke-virtual {v7, v8}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 2467
    .line 2468
    .line 2469
    move-result v7

    .line 2470
    if-eqz v7, :cond_9d0

    .line 2471
    .line 2472
    if-eqz v1, :cond_9ab

    .line 2473
    .line 2474
    move-object v5, v0

    .line 2475
    goto :goto_9af

    .line 2476
    :cond_9ab
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2477
    .line 2478
    .line 2479
    move-result-object v5

    .line 2480
    :goto_9af
    invoke-virtual {v10, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2481
    .line 2482
    .line 2483
    move-result-object v6

    .line 2484
    invoke-virtual {v10, v5}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2485
    .line 2486
    .line 2487
    move-result-object v5

    .line 2488
    invoke-virtual {v6, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2489
    .line 2490
    .line 2491
    move-result-object v5

    .line 2492
    invoke-virtual {v5, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2493
    .line 2494
    .line 2495
    move-result-object v6

    .line 2496
    invoke-virtual {v6, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2497
    .line 2498
    .line 2499
    move-result-object v5

    .line 2500
    invoke-virtual {v2, v10}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2501
    .line 2502
    .line 2503
    move-result-object v2

    .line 2504
    :goto_9c7
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2505
    .line 2506
    .line 2507
    move-result-object v2

    .line 2508
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2509
    .line 2510
    .line 2511
    move-result-object v2

    .line 2512
    goto :goto_a0f

    .line 2513
    :cond_9d0
    invoke-virtual {v10}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2514
    .line 2515
    .line 2516
    move-result-object v7

    .line 2517
    invoke-virtual {v7, v7}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2518
    .line 2519
    .line 2520
    move-result-object v8

    .line 2521
    invoke-virtual {v8, v7}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2522
    .line 2523
    .line 2524
    move-result-object v7

    .line 2525
    if-eqz v1, :cond_9e3

    .line 2526
    .line 2527
    :goto_9de
    invoke-virtual {v7, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2528
    .line 2529
    .line 2530
    move-result-object v5

    .line 2531
    goto :goto_a0a

    .line 2532
    :cond_9e3
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->E0()Z

    .line 2533
    .line 2534
    .line 2535
    move-result v8

    .line 2536
    if-nez v8, :cond_a09

    .line 2537
    .line 2538
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2539
    .line 2540
    .line 2541
    move-result-object v8

    .line 2542
    invoke-virtual {v8}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2543
    .line 2544
    .line 2545
    move-result-object v8

    .line 2546
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->D()I

    .line 2547
    .line 2548
    .line 2549
    move-result v9

    .line 2550
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->D()I

    .line 2551
    .line 2552
    .line 2553
    move-result v12

    .line 2554
    if-ge v9, v12, :cond_a04

    .line 2555
    .line 2556
    invoke-virtual {v8, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2557
    .line 2558
    .line 2559
    move-result-object v5

    .line 2560
    invoke-virtual {v7, v5}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2561
    .line 2562
    .line 2563
    move-result-object v5

    .line 2564
    goto :goto_a0a

    .line 2565
    :cond_a04
    invoke-virtual {v8, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2566
    .line 2567
    .line 2568
    move-result-object v5

    .line 2569
    goto :goto_9de

    .line 2570
    :cond_a09
    move-object v5, v7

    .line 2571
    :goto_a0a
    invoke-virtual {v10, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2572
    .line 2573
    .line 2574
    move-result-object v2

    .line 2575
    goto :goto_9c7

    .line 2576
    :goto_a0f
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2577
    .line 2578
    .line 2579
    move-result-object v6

    .line 2580
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2581
    .line 2582
    .line 2583
    move-result-object v7

    .line 2584
    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2585
    .line 2586
    .line 2587
    move-result-object v6

    .line 2588
    invoke-virtual {v2, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2589
    .line 2590
    .line 2591
    move-result-object v2

    .line 2592
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2593
    .line 2594
    .line 2595
    move-result-object v2

    .line 2596
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2597
    .line 2598
    .line 2599
    move-result-object v4

    .line 2600
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2601
    .line 2602
    .line 2603
    move-result-object v4

    .line 2604
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2605
    .line 2606
    .line 2607
    move-result-object v4

    .line 2608
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2609
    .line 2610
    .line 2611
    move-result-object v5

    .line 2612
    invoke-virtual {v11, v11}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2613
    .line 2614
    .line 2615
    move-result-object v2

    .line 2616
    if-nez v1, :cond_a3d

    .line 2617
    .line 2618
    invoke-virtual {v2, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2619
    .line 2620
    .line 2621
    move-result-object v2

    .line 2622
    :cond_a3d
    new-instance v0, Lcom/kousei/framework/b2;

    .line 2623
    .line 2624
    filled-new-array {v2}, [Lcom/kousei/framework/h0;

    .line 2625
    .line 2626
    .line 2627
    move-result-object v1

    .line 2628
    const/4 v7, 0x1

    .line 2629
    move-object v2, v0

    .line 2630
    move-object v4, v6

    .line 2631
    move-object v6, v1

    .line 2632
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 2633
    .line 2634
    .line 2635
    goto/16 :goto_b17

    .line 2636
    .line 2637
    :cond_a4c
    aget-object v0, v9, v13

    .line 2638
    .line 2639
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->A0()Z

    .line 2640
    .line 2641
    .line 2642
    move-result v1

    .line 2643
    iget-object v2, v3, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 2644
    .line 2645
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 2646
    .line 2647
    .line 2648
    move-result v4

    .line 2649
    if-nez v4, :cond_a64

    .line 2650
    .line 2651
    if-nez v1, :cond_a64

    .line 2652
    .line 2653
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2654
    .line 2655
    .line 2656
    move-result-object v4

    .line 2657
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2658
    .line 2659
    .line 2660
    move-result-object v2

    .line 2661
    :cond_a64
    invoke-virtual {v10}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2662
    .line 2663
    .line 2664
    move-result-object v4

    .line 2665
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2666
    .line 2667
    .line 2668
    move-result-object v5

    .line 2669
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2670
    .line 2671
    .line 2672
    move-result-object v4

    .line 2673
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2674
    .line 2675
    .line 2676
    move-result-object v2

    .line 2677
    if-eqz v1, :cond_a78

    .line 2678
    .line 2679
    move-object v0, v11

    .line 2680
    goto :goto_a7c

    .line 2681
    :cond_a78
    invoke-virtual {v11, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2682
    .line 2683
    .line 2684
    move-result-object v0

    .line 2685
    :goto_a7c
    if-eqz v1, :cond_a83

    .line 2686
    .line 2687
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2688
    .line 2689
    .line 2690
    move-result-object v4

    .line 2691
    goto :goto_a87

    .line 2692
    :cond_a83
    invoke-virtual {v0, v11}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2693
    .line 2694
    .line 2695
    move-result-object v4

    .line 2696
    :goto_a87
    invoke-virtual {v10, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2697
    .line 2698
    .line 2699
    move-result-object v5

    .line 2700
    invoke-virtual {v5, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2701
    .line 2702
    .line 2703
    move-result-object v5

    .line 2704
    invoke-virtual {v5, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2705
    .line 2706
    .line 2707
    move-result-object v5

    .line 2708
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2709
    .line 2710
    .line 2711
    move-result-object v6

    .line 2712
    invoke-virtual {v5, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2713
    .line 2714
    .line 2715
    move-result-object v7

    .line 2716
    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2717
    .line 2718
    .line 2719
    move-result-object v6

    .line 2720
    invoke-virtual {v0, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2721
    .line 2722
    .line 2723
    move-result-object v7

    .line 2724
    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2725
    .line 2726
    .line 2727
    move-result-object v8

    .line 2728
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2729
    .line 2730
    .line 2731
    move-result-object v4

    .line 2732
    invoke-virtual {v5, v6}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2733
    .line 2734
    .line 2735
    move-result-object v5

    .line 2736
    invoke-virtual {v5, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2737
    .line 2738
    .line 2739
    move-result-object v2

    .line 2740
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2741
    .line 2742
    .line 2743
    move-result-object v5

    .line 2744
    invoke-virtual {v5, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2745
    .line 2746
    .line 2747
    move-result-object v5

    .line 2748
    invoke-virtual {v2, v5}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2749
    .line 2750
    .line 2751
    move-result-object v5

    .line 2752
    if-eqz v1, :cond_ac6

    .line 2753
    .line 2754
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2755
    .line 2756
    .line 2757
    move-result-object v1

    .line 2758
    goto :goto_aca

    .line 2759
    :cond_ac6
    invoke-virtual {v7}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2760
    .line 2761
    .line 2762
    move-result-object v1

    .line 2763
    :goto_aca
    invoke-virtual {v1, v1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2764
    .line 2765
    .line 2766
    move-result-object v1

    .line 2767
    invoke-virtual {v1, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2768
    .line 2769
    .line 2770
    move-result-object v0

    .line 2771
    new-instance v2, Lcom/kousei/framework/b2;

    .line 2772
    .line 2773
    filled-new-array {v0}, [Lcom/kousei/framework/h0;

    .line 2774
    .line 2775
    .line 2776
    move-result-object v6

    .line 2777
    const/4 v7, 0x1

    .line 2778
    move-object v4, v8

    .line 2779
    invoke-direct/range {v2 .. v7}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 2780
    .line 2781
    .line 2782
    :goto_add
    move-object v0, v2

    .line 2783
    goto :goto_b17

    .line 2784
    :cond_adf
    invoke-virtual {v10}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2785
    .line 2786
    .line 2787
    move-result-object v0

    .line 2788
    invoke-virtual {v0, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2789
    .line 2790
    .line 2791
    move-result-object v1

    .line 2792
    invoke-virtual {v1, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2793
    .line 2794
    .line 2795
    move-result-object v0

    .line 2796
    iget-object v1, v3, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 2797
    .line 2798
    invoke-virtual {v0, v1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2799
    .line 2800
    .line 2801
    move-result-object v0

    .line 2802
    invoke-virtual {v11, v11}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2803
    .line 2804
    .line 2805
    move-result-object v1

    .line 2806
    invoke-virtual {v0, v1}, Lcom/kousei/framework/h0;->R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2807
    .line 2808
    .line 2809
    move-result-object v0

    .line 2810
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 2811
    .line 2812
    .line 2813
    move-result-object v1

    .line 2814
    invoke-virtual {v10, v10}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2815
    .line 2816
    .line 2817
    move-result-object v2

    .line 2818
    invoke-virtual {v1, v2}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2819
    .line 2820
    .line 2821
    move-result-object v1

    .line 2822
    invoke-virtual {v10, v1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2823
    .line 2824
    .line 2825
    move-result-object v2

    .line 2826
    invoke-virtual {v0, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2827
    .line 2828
    .line 2829
    move-result-object v0

    .line 2830
    invoke-virtual {v0, v11}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 2831
    .line 2832
    .line 2833
    move-result-object v0

    .line 2834
    new-instance v2, Lcom/kousei/framework/b2;

    .line 2835
    .line 2836
    invoke-direct {v2, v3, v1, v0, v12}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 2837
    .line 2838
    .line 2839
    goto :goto_add

    .line 2840
    :goto_b17
    return-object v0

    .line 2841
    :pswitch_b18
    invoke-virtual {v0}, Lcom/kousei/framework/d4;->h()Z

    .line 2842
    .line 2843
    .line 2844
    move-result v1

    .line 2845
    if-eqz v1, :cond_b1f

    .line 2846
    .line 2847
    goto :goto_b30

    .line 2848
    :cond_b1f
    invoke-virtual {v11}, Lcom/kousei/framework/h0;->E0()Z

    .line 2849
    .line 2850
    .line 2851
    move-result v1

    .line 2852
    if-eqz v1, :cond_b2c

    .line 2853
    .line 2854
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2855
    .line 2856
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 2857
    .line 2858
    .line 2859
    move-result-object v0

    .line 2860
    goto :goto_b30

    .line 2861
    :cond_b2c
    invoke-virtual {v0, v12}, Lcom/kousei/framework/b2;->y(Z)Lcom/kousei/framework/b2;

    .line 2862
    .line 2863
    .line 2864
    move-result-object v0

    .line 2865
    :goto_b30
    return-object v0

    .line 2866
    nop

    :pswitch_data_b32
    .packed-switch 0x0
        :pswitch_b18
        :pswitch_953
        :pswitch_89d
        :pswitch_7e9
        :pswitch_759
        :pswitch_697
        :pswitch_5e8
        :pswitch_543
        :pswitch_486
        :pswitch_3db
        :pswitch_33e
        :pswitch_283
        :pswitch_1ac
        :pswitch_d5
    .end packed-switch
.end method

.method public final p(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
    .registers 9

    .line 1
    iget v0, p0, Lcom/kousei/framework/b2;->h:I

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    iget-object v2, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 5
    .line 6
    packed-switch v0, :pswitch_data_40e

    .line 7
    .line 8
    .line 9
    if-ne p0, p1, :cond_20

    .line 10
    .line 11
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 12
    .line 13
    .line 14
    move-result p1

    .line 15
    if-nez p1, :cond_42

    .line 16
    .line 17
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 18
    .line 19
    .line 20
    move-result p1

    .line 21
    if-eqz p1, :cond_17

    .line 22
    .line 23
    goto :goto_42

    .line 24
    :cond_17
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 25
    .line 26
    .line 27
    move-result-object p1

    .line 28
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 29
    .line 30
    .line 31
    move-result-object p0

    .line 32
    goto :goto_42

    .line 33
    :cond_20
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 34
    .line 35
    .line 36
    move-result v0

    .line 37
    if-eqz v0, :cond_28

    .line 38
    .line 39
    :goto_26
    move-object p0, p1

    .line 40
    goto :goto_42

    .line 41
    :cond_28
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 42
    .line 43
    .line 44
    move-result v0

    .line 45
    if-eqz v0, :cond_33

    .line 46
    .line 47
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 48
    .line 49
    .line 50
    move-result-object p0

    .line 51
    goto :goto_42

    .line 52
    :cond_33
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 53
    .line 54
    .line 55
    move-result v0

    .line 56
    if-eqz v0, :cond_3a

    .line 57
    .line 58
    goto :goto_26

    .line 59
    :cond_3a
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 60
    .line 61
    .line 62
    move-result-object p0

    .line 63
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    :cond_42
    :goto_42
    return-object p0

    .line 68
    :pswitch_43
    if-ne p0, p1, :cond_5b

    .line 69
    .line 70
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 71
    .line 72
    .line 73
    move-result p1

    .line 74
    if-nez p1, :cond_7d

    .line 75
    .line 76
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 77
    .line 78
    .line 79
    move-result p1

    .line 80
    if-eqz p1, :cond_52

    .line 81
    .line 82
    goto :goto_7d

    .line 83
    :cond_52
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 84
    .line 85
    .line 86
    move-result-object p1

    .line 87
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 88
    .line 89
    .line 90
    move-result-object p0

    .line 91
    goto :goto_7d

    .line 92
    :cond_5b
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 93
    .line 94
    .line 95
    move-result v0

    .line 96
    if-eqz v0, :cond_63

    .line 97
    .line 98
    :goto_61
    move-object p0, p1

    .line 99
    goto :goto_7d

    .line 100
    :cond_63
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 101
    .line 102
    .line 103
    move-result v0

    .line 104
    if-eqz v0, :cond_6e

    .line 105
    .line 106
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 107
    .line 108
    .line 109
    move-result-object p0

    .line 110
    goto :goto_7d

    .line 111
    :cond_6e
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 112
    .line 113
    .line 114
    move-result v0

    .line 115
    if-eqz v0, :cond_75

    .line 116
    .line 117
    goto :goto_61

    .line 118
    :cond_75
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 119
    .line 120
    .line 121
    move-result-object p0

    .line 122
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 123
    .line 124
    .line 125
    move-result-object p0

    .line 126
    :cond_7d
    :goto_7d
    return-object p0

    .line 127
    :pswitch_7e
    if-ne p0, p1, :cond_96

    .line 128
    .line 129
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 130
    .line 131
    .line 132
    move-result p1

    .line 133
    if-nez p1, :cond_b8

    .line 134
    .line 135
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 136
    .line 137
    .line 138
    move-result p1

    .line 139
    if-eqz p1, :cond_8d

    .line 140
    .line 141
    goto :goto_b8

    .line 142
    :cond_8d
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 143
    .line 144
    .line 145
    move-result-object p1

    .line 146
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 147
    .line 148
    .line 149
    move-result-object p0

    .line 150
    goto :goto_b8

    .line 151
    :cond_96
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 152
    .line 153
    .line 154
    move-result v0

    .line 155
    if-eqz v0, :cond_9e

    .line 156
    .line 157
    :goto_9c
    move-object p0, p1

    .line 158
    goto :goto_b8

    .line 159
    :cond_9e
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 160
    .line 161
    .line 162
    move-result v0

    .line 163
    if-eqz v0, :cond_a9

    .line 164
    .line 165
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 166
    .line 167
    .line 168
    move-result-object p0

    .line 169
    goto :goto_b8

    .line 170
    :cond_a9
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 171
    .line 172
    .line 173
    move-result v0

    .line 174
    if-eqz v0, :cond_b0

    .line 175
    .line 176
    goto :goto_9c

    .line 177
    :cond_b0
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 178
    .line 179
    .line 180
    move-result-object p0

    .line 181
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 182
    .line 183
    .line 184
    move-result-object p0

    .line 185
    :cond_b8
    :goto_b8
    return-object p0

    .line 186
    :pswitch_b9
    if-ne p0, p1, :cond_d1

    .line 187
    .line 188
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 189
    .line 190
    .line 191
    move-result p1

    .line 192
    if-nez p1, :cond_f3

    .line 193
    .line 194
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 195
    .line 196
    .line 197
    move-result p1

    .line 198
    if-eqz p1, :cond_c8

    .line 199
    .line 200
    goto :goto_f3

    .line 201
    :cond_c8
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 202
    .line 203
    .line 204
    move-result-object p1

    .line 205
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 206
    .line 207
    .line 208
    move-result-object p0

    .line 209
    goto :goto_f3

    .line 210
    :cond_d1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 211
    .line 212
    .line 213
    move-result v0

    .line 214
    if-eqz v0, :cond_d9

    .line 215
    .line 216
    :goto_d7
    move-object p0, p1

    .line 217
    goto :goto_f3

    .line 218
    :cond_d9
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 219
    .line 220
    .line 221
    move-result v0

    .line 222
    if-eqz v0, :cond_e4

    .line 223
    .line 224
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 225
    .line 226
    .line 227
    move-result-object p0

    .line 228
    goto :goto_f3

    .line 229
    :cond_e4
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 230
    .line 231
    .line 232
    move-result v0

    .line 233
    if-eqz v0, :cond_eb

    .line 234
    .line 235
    goto :goto_d7

    .line 236
    :cond_eb
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 237
    .line 238
    .line 239
    move-result-object p0

    .line 240
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 241
    .line 242
    .line 243
    move-result-object p0

    .line 244
    :cond_f3
    :goto_f3
    return-object p0

    .line 245
    :pswitch_f4
    if-ne p0, p1, :cond_10c

    .line 246
    .line 247
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 248
    .line 249
    .line 250
    move-result p1

    .line 251
    if-nez p1, :cond_12e

    .line 252
    .line 253
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 254
    .line 255
    .line 256
    move-result p1

    .line 257
    if-eqz p1, :cond_103

    .line 258
    .line 259
    goto :goto_12e

    .line 260
    :cond_103
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 261
    .line 262
    .line 263
    move-result-object p1

    .line 264
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 265
    .line 266
    .line 267
    move-result-object p0

    .line 268
    goto :goto_12e

    .line 269
    :cond_10c
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 270
    .line 271
    .line 272
    move-result v0

    .line 273
    if-eqz v0, :cond_114

    .line 274
    .line 275
    :goto_112
    move-object p0, p1

    .line 276
    goto :goto_12e

    .line 277
    :cond_114
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 278
    .line 279
    .line 280
    move-result v0

    .line 281
    if-eqz v0, :cond_11f

    .line 282
    .line 283
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 284
    .line 285
    .line 286
    move-result-object p0

    .line 287
    goto :goto_12e

    .line 288
    :cond_11f
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 289
    .line 290
    .line 291
    move-result v0

    .line 292
    if-eqz v0, :cond_126

    .line 293
    .line 294
    goto :goto_112

    .line 295
    :cond_126
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 296
    .line 297
    .line 298
    move-result-object p0

    .line 299
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 300
    .line 301
    .line 302
    move-result-object p0

    .line 303
    :cond_12e
    :goto_12e
    return-object p0

    .line 304
    :pswitch_12f
    if-ne p0, p1, :cond_147

    .line 305
    .line 306
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 307
    .line 308
    .line 309
    move-result p1

    .line 310
    if-nez p1, :cond_169

    .line 311
    .line 312
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 313
    .line 314
    .line 315
    move-result p1

    .line 316
    if-eqz p1, :cond_13e

    .line 317
    .line 318
    goto :goto_169

    .line 319
    :cond_13e
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 320
    .line 321
    .line 322
    move-result-object p1

    .line 323
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 324
    .line 325
    .line 326
    move-result-object p0

    .line 327
    goto :goto_169

    .line 328
    :cond_147
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 329
    .line 330
    .line 331
    move-result v0

    .line 332
    if-eqz v0, :cond_14f

    .line 333
    .line 334
    :goto_14d
    move-object p0, p1

    .line 335
    goto :goto_169

    .line 336
    :cond_14f
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 337
    .line 338
    .line 339
    move-result v0

    .line 340
    if-eqz v0, :cond_15a

    .line 341
    .line 342
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 343
    .line 344
    .line 345
    move-result-object p0

    .line 346
    goto :goto_169

    .line 347
    :cond_15a
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 348
    .line 349
    .line 350
    move-result v0

    .line 351
    if-eqz v0, :cond_161

    .line 352
    .line 353
    goto :goto_14d

    .line 354
    :cond_161
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 355
    .line 356
    .line 357
    move-result-object p0

    .line 358
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 359
    .line 360
    .line 361
    move-result-object p0

    .line 362
    :cond_169
    :goto_169
    return-object p0

    .line 363
    :pswitch_16a
    if-ne p0, p1, :cond_182

    .line 364
    .line 365
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 366
    .line 367
    .line 368
    move-result p1

    .line 369
    if-nez p1, :cond_1a4

    .line 370
    .line 371
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 372
    .line 373
    .line 374
    move-result p1

    .line 375
    if-eqz p1, :cond_179

    .line 376
    .line 377
    goto :goto_1a4

    .line 378
    :cond_179
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 379
    .line 380
    .line 381
    move-result-object p1

    .line 382
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 383
    .line 384
    .line 385
    move-result-object p0

    .line 386
    goto :goto_1a4

    .line 387
    :cond_182
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 388
    .line 389
    .line 390
    move-result v0

    .line 391
    if-eqz v0, :cond_18a

    .line 392
    .line 393
    :goto_188
    move-object p0, p1

    .line 394
    goto :goto_1a4

    .line 395
    :cond_18a
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 396
    .line 397
    .line 398
    move-result v0

    .line 399
    if-eqz v0, :cond_195

    .line 400
    .line 401
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 402
    .line 403
    .line 404
    move-result-object p0

    .line 405
    goto :goto_1a4

    .line 406
    :cond_195
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 407
    .line 408
    .line 409
    move-result v0

    .line 410
    if-eqz v0, :cond_19c

    .line 411
    .line 412
    goto :goto_188

    .line 413
    :cond_19c
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 414
    .line 415
    .line 416
    move-result-object p0

    .line 417
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 418
    .line 419
    .line 420
    move-result-object p0

    .line 421
    :cond_1a4
    :goto_1a4
    return-object p0

    .line 422
    :pswitch_1a5
    if-ne p0, p1, :cond_1bd

    .line 423
    .line 424
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 425
    .line 426
    .line 427
    move-result p1

    .line 428
    if-nez p1, :cond_1df

    .line 429
    .line 430
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 431
    .line 432
    .line 433
    move-result p1

    .line 434
    if-eqz p1, :cond_1b4

    .line 435
    .line 436
    goto :goto_1df

    .line 437
    :cond_1b4
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 438
    .line 439
    .line 440
    move-result-object p1

    .line 441
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 442
    .line 443
    .line 444
    move-result-object p0

    .line 445
    goto :goto_1df

    .line 446
    :cond_1bd
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 447
    .line 448
    .line 449
    move-result v0

    .line 450
    if-eqz v0, :cond_1c5

    .line 451
    .line 452
    :goto_1c3
    move-object p0, p1

    .line 453
    goto :goto_1df

    .line 454
    :cond_1c5
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 455
    .line 456
    .line 457
    move-result v0

    .line 458
    if-eqz v0, :cond_1d0

    .line 459
    .line 460
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 461
    .line 462
    .line 463
    move-result-object p0

    .line 464
    goto :goto_1df

    .line 465
    :cond_1d0
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 466
    .line 467
    .line 468
    move-result v0

    .line 469
    if-eqz v0, :cond_1d7

    .line 470
    .line 471
    goto :goto_1c3

    .line 472
    :cond_1d7
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 473
    .line 474
    .line 475
    move-result-object p0

    .line 476
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 477
    .line 478
    .line 479
    move-result-object p0

    .line 480
    :cond_1df
    :goto_1df
    return-object p0

    .line 481
    :pswitch_1e0
    if-ne p0, p1, :cond_1f8

    .line 482
    .line 483
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 484
    .line 485
    .line 486
    move-result p1

    .line 487
    if-nez p1, :cond_21a

    .line 488
    .line 489
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 490
    .line 491
    .line 492
    move-result p1

    .line 493
    if-eqz p1, :cond_1ef

    .line 494
    .line 495
    goto :goto_21a

    .line 496
    :cond_1ef
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 497
    .line 498
    .line 499
    move-result-object p1

    .line 500
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 501
    .line 502
    .line 503
    move-result-object p0

    .line 504
    goto :goto_21a

    .line 505
    :cond_1f8
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 506
    .line 507
    .line 508
    move-result v0

    .line 509
    if-eqz v0, :cond_200

    .line 510
    .line 511
    :goto_1fe
    move-object p0, p1

    .line 512
    goto :goto_21a

    .line 513
    :cond_200
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 514
    .line 515
    .line 516
    move-result v0

    .line 517
    if-eqz v0, :cond_20b

    .line 518
    .line 519
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 520
    .line 521
    .line 522
    move-result-object p0

    .line 523
    goto :goto_21a

    .line 524
    :cond_20b
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 525
    .line 526
    .line 527
    move-result v0

    .line 528
    if-eqz v0, :cond_212

    .line 529
    .line 530
    goto :goto_1fe

    .line 531
    :cond_212
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 532
    .line 533
    .line 534
    move-result-object p0

    .line 535
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 536
    .line 537
    .line 538
    move-result-object p0

    .line 539
    :cond_21a
    :goto_21a
    return-object p0

    .line 540
    :pswitch_21b
    if-ne p0, p1, :cond_233

    .line 541
    .line 542
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 543
    .line 544
    .line 545
    move-result p1

    .line 546
    if-nez p1, :cond_255

    .line 547
    .line 548
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 549
    .line 550
    .line 551
    move-result p1

    .line 552
    if-eqz p1, :cond_22a

    .line 553
    .line 554
    goto :goto_255

    .line 555
    :cond_22a
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 556
    .line 557
    .line 558
    move-result-object p1

    .line 559
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 560
    .line 561
    .line 562
    move-result-object p0

    .line 563
    goto :goto_255

    .line 564
    :cond_233
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 565
    .line 566
    .line 567
    move-result v0

    .line 568
    if-eqz v0, :cond_23b

    .line 569
    .line 570
    :goto_239
    move-object p0, p1

    .line 571
    goto :goto_255

    .line 572
    :cond_23b
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 573
    .line 574
    .line 575
    move-result v0

    .line 576
    if-eqz v0, :cond_246

    .line 577
    .line 578
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 579
    .line 580
    .line 581
    move-result-object p0

    .line 582
    goto :goto_255

    .line 583
    :cond_246
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 584
    .line 585
    .line 586
    move-result v0

    .line 587
    if-eqz v0, :cond_24d

    .line 588
    .line 589
    goto :goto_239

    .line 590
    :cond_24d
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 591
    .line 592
    .line 593
    move-result-object p0

    .line 594
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 595
    .line 596
    .line 597
    move-result-object p0

    .line 598
    :cond_255
    :goto_255
    return-object p0

    .line 599
    :pswitch_256
    if-ne p0, p1, :cond_26e

    .line 600
    .line 601
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 602
    .line 603
    .line 604
    move-result p1

    .line 605
    if-nez p1, :cond_290

    .line 606
    .line 607
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 608
    .line 609
    .line 610
    move-result p1

    .line 611
    if-eqz p1, :cond_265

    .line 612
    .line 613
    goto :goto_290

    .line 614
    :cond_265
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 615
    .line 616
    .line 617
    move-result-object p1

    .line 618
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 619
    .line 620
    .line 621
    move-result-object p0

    .line 622
    goto :goto_290

    .line 623
    :cond_26e
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 624
    .line 625
    .line 626
    move-result v0

    .line 627
    if-eqz v0, :cond_276

    .line 628
    .line 629
    :goto_274
    move-object p0, p1

    .line 630
    goto :goto_290

    .line 631
    :cond_276
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 632
    .line 633
    .line 634
    move-result v0

    .line 635
    if-eqz v0, :cond_281

    .line 636
    .line 637
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 638
    .line 639
    .line 640
    move-result-object p0

    .line 641
    goto :goto_290

    .line 642
    :cond_281
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 643
    .line 644
    .line 645
    move-result v0

    .line 646
    if-eqz v0, :cond_288

    .line 647
    .line 648
    goto :goto_274

    .line 649
    :cond_288
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 650
    .line 651
    .line 652
    move-result-object p0

    .line 653
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 654
    .line 655
    .line 656
    move-result-object p0

    .line 657
    :cond_290
    :goto_290
    return-object p0

    .line 658
    :pswitch_291
    if-ne p0, p1, :cond_2a9

    .line 659
    .line 660
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 661
    .line 662
    .line 663
    move-result p1

    .line 664
    if-nez p1, :cond_2cb

    .line 665
    .line 666
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 667
    .line 668
    .line 669
    move-result p1

    .line 670
    if-eqz p1, :cond_2a0

    .line 671
    .line 672
    goto :goto_2cb

    .line 673
    :cond_2a0
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 674
    .line 675
    .line 676
    move-result-object p1

    .line 677
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 678
    .line 679
    .line 680
    move-result-object p0

    .line 681
    goto :goto_2cb

    .line 682
    :cond_2a9
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 683
    .line 684
    .line 685
    move-result v0

    .line 686
    if-eqz v0, :cond_2b1

    .line 687
    .line 688
    :goto_2af
    move-object p0, p1

    .line 689
    goto :goto_2cb

    .line 690
    :cond_2b1
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 691
    .line 692
    .line 693
    move-result v0

    .line 694
    if-eqz v0, :cond_2bc

    .line 695
    .line 696
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 697
    .line 698
    .line 699
    move-result-object p0

    .line 700
    goto :goto_2cb

    .line 701
    :cond_2bc
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 702
    .line 703
    .line 704
    move-result v0

    .line 705
    if-eqz v0, :cond_2c3

    .line 706
    .line 707
    goto :goto_2af

    .line 708
    :cond_2c3
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 709
    .line 710
    .line 711
    move-result-object p0

    .line 712
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 713
    .line 714
    .line 715
    move-result-object p0

    .line 716
    :cond_2cb
    :goto_2cb
    return-object p0

    .line 717
    :pswitch_2cc
    if-ne p0, p1, :cond_2e4

    .line 718
    .line 719
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 720
    .line 721
    .line 722
    move-result p1

    .line 723
    if-nez p1, :cond_306

    .line 724
    .line 725
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 726
    .line 727
    .line 728
    move-result p1

    .line 729
    if-eqz p1, :cond_2db

    .line 730
    .line 731
    goto :goto_306

    .line 732
    :cond_2db
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 733
    .line 734
    .line 735
    move-result-object p1

    .line 736
    invoke-virtual {p1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 737
    .line 738
    .line 739
    move-result-object p0

    .line 740
    goto :goto_306

    .line 741
    :cond_2e4
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 742
    .line 743
    .line 744
    move-result v0

    .line 745
    if-eqz v0, :cond_2ec

    .line 746
    .line 747
    :goto_2ea
    move-object p0, p1

    .line 748
    goto :goto_306

    .line 749
    :cond_2ec
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 750
    .line 751
    .line 752
    move-result v0

    .line 753
    if-eqz v0, :cond_2f7

    .line 754
    .line 755
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 756
    .line 757
    .line 758
    move-result-object p0

    .line 759
    goto :goto_306

    .line 760
    :cond_2f7
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 761
    .line 762
    .line 763
    move-result v0

    .line 764
    if-eqz v0, :cond_2fe

    .line 765
    .line 766
    goto :goto_2ea

    .line 767
    :cond_2fe
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 768
    .line 769
    .line 770
    move-result-object p0

    .line 771
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 772
    .line 773
    .line 774
    move-result-object p0

    .line 775
    :cond_306
    :goto_306
    return-object p0

    .line 776
    :pswitch_307
    if-ne p0, p1, :cond_30f

    .line 777
    .line 778
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->x()Lcom/kousei/framework/d4;

    .line 779
    .line 780
    .line 781
    move-result-object p0

    .line 782
    goto/16 :goto_3d1

    .line 783
    .line 784
    :cond_30f
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 785
    .line 786
    .line 787
    move-result v0

    .line 788
    if-eqz v0, :cond_318

    .line 789
    .line 790
    :goto_315
    move-object p0, p1

    .line 791
    goto/16 :goto_3d1

    .line 792
    .line 793
    :cond_318
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 794
    .line 795
    .line 796
    move-result v0

    .line 797
    if-eqz v0, :cond_324

    .line 798
    .line 799
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 800
    .line 801
    .line 802
    move-result-object p0

    .line 803
    goto/16 :goto_3d1

    .line 804
    .line 805
    :cond_324
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 806
    .line 807
    .line 808
    move-result v0

    .line 809
    if-eqz v0, :cond_32b

    .line 810
    .line 811
    goto :goto_315

    .line 812
    :cond_32b
    iget-object v0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 813
    .line 814
    iget v3, v0, Lcom/kousei/framework/v3;->f:I

    .line 815
    .line 816
    if-eqz v3, :cond_348

    .line 817
    .line 818
    const/4 v0, 0x4

    .line 819
    if-eq v3, v0, :cond_33e

    .line 820
    .line 821
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 822
    .line 823
    .line 824
    move-result-object p0

    .line 825
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 826
    .line 827
    .line 828
    move-result-object p0

    .line 829
    goto/16 :goto_3d1

    .line 830
    .line 831
    :cond_33e
    invoke-virtual {p0, v1}, Lcom/kousei/framework/b2;->z(Z)Lcom/kousei/framework/b2;

    .line 832
    .line 833
    .line 834
    move-result-object p0

    .line 835
    invoke-virtual {p0, p1}, Lcom/kousei/framework/b2;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 836
    .line 837
    .line 838
    move-result-object p0

    .line 839
    goto/16 :goto_3d1

    .line 840
    .line 841
    :cond_348
    iget-object v1, p1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 842
    .line 843
    iget-object p1, p1, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 844
    .line 845
    iget-object v3, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 846
    .line 847
    invoke-virtual {v1, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 848
    .line 849
    .line 850
    move-result-object v4

    .line 851
    invoke-virtual {p1, v2}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 852
    .line 853
    .line 854
    move-result-object p1

    .line 855
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->E0()Z

    .line 856
    .line 857
    .line 858
    move-result v5

    .line 859
    if-eqz v5, :cond_367

    .line 860
    .line 861
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->E0()Z

    .line 862
    .line 863
    .line 864
    move-result p1

    .line 865
    if-eqz p1, :cond_3d1

    .line 866
    .line 867
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->x()Lcom/kousei/framework/d4;

    .line 868
    .line 869
    .line 870
    move-result-object p0

    .line 871
    goto :goto_3d1

    .line 872
    :cond_367
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 873
    .line 874
    .line 875
    move-result-object p0

    .line 876
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 877
    .line 878
    .line 879
    move-result-object v5

    .line 880
    invoke-virtual {v3, v3}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 881
    .line 882
    .line 883
    move-result-object v6

    .line 884
    invoke-virtual {v6, v1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 885
    .line 886
    .line 887
    move-result-object v6

    .line 888
    invoke-virtual {p0, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 889
    .line 890
    .line 891
    move-result-object v6

    .line 892
    invoke-virtual {v6, v5}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 893
    .line 894
    .line 895
    move-result-object v5

    .line 896
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->E0()Z

    .line 897
    .line 898
    .line 899
    move-result v6

    .line 900
    if-eqz v6, :cond_38a

    .line 901
    .line 902
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 903
    .line 904
    .line 905
    move-result-object p0

    .line 906
    goto :goto_3d1

    .line 907
    :cond_38a
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 908
    .line 909
    .line 910
    move-result-object v6

    .line 911
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->z0()Lcom/kousei/framework/h0;

    .line 912
    .line 913
    .line 914
    move-result-object v6

    .line 915
    invoke-virtual {v5, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 916
    .line 917
    .line 918
    move-result-object v5

    .line 919
    invoke-virtual {v5, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 920
    .line 921
    .line 922
    move-result-object p1

    .line 923
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 924
    .line 925
    .line 926
    move-result-object v5

    .line 927
    invoke-virtual {v5, p0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 928
    .line 929
    .line 930
    move-result-object p0

    .line 931
    invoke-virtual {p0, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 932
    .line 933
    .line 934
    move-result-object p0

    .line 935
    invoke-virtual {p0, v6}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 936
    .line 937
    .line 938
    move-result-object p0

    .line 939
    invoke-virtual {p0, p1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 940
    .line 941
    .line 942
    move-result-object p0

    .line 943
    invoke-virtual {p0, p1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 944
    .line 945
    .line 946
    move-result-object v4

    .line 947
    invoke-virtual {p1, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 948
    .line 949
    .line 950
    move-result-object p1

    .line 951
    invoke-virtual {v4, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 952
    .line 953
    .line 954
    move-result-object p1

    .line 955
    invoke-virtual {p1, v1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 956
    .line 957
    .line 958
    move-result-object p1

    .line 959
    invoke-virtual {v3, p1}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 960
    .line 961
    .line 962
    move-result-object v1

    .line 963
    invoke-virtual {v1, p0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 964
    .line 965
    .line 966
    move-result-object p0

    .line 967
    invoke-virtual {p0, v2}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 968
    .line 969
    .line 970
    move-result-object p0

    .line 971
    new-instance v1, Lcom/kousei/framework/b2;

    .line 972
    .line 973
    const/4 v2, 0x1

    .line 974
    invoke-direct {v1, v0, p1, p0, v2}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 975
    .line 976
    .line 977
    move-object p0, v1

    .line 978
    :cond_3d1
    :goto_3d1
    return-object p0

    .line 979
    :pswitch_3d2
    if-ne p0, p1, :cond_3eb

    .line 980
    .line 981
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 982
    .line 983
    .line 984
    move-result p1

    .line 985
    if-eqz p1, :cond_3db

    .line 986
    .line 987
    goto :goto_40d

    .line 988
    :cond_3db
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 989
    .line 990
    .line 991
    move-result p1

    .line 992
    if-eqz p1, :cond_3e2

    .line 993
    .line 994
    goto :goto_40d

    .line 995
    :cond_3e2
    invoke-virtual {p0, v1}, Lcom/kousei/framework/b2;->y(Z)Lcom/kousei/framework/b2;

    .line 996
    .line 997
    .line 998
    move-result-object p1

    .line 999
    invoke-virtual {p1, p0}, Lcom/kousei/framework/b2;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 1000
    .line 1001
    .line 1002
    move-result-object p0

    .line 1003
    goto :goto_40d

    .line 1004
    :cond_3eb
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 1005
    .line 1006
    .line 1007
    move-result v0

    .line 1008
    if-eqz v0, :cond_3f3

    .line 1009
    .line 1010
    :goto_3f1
    move-object p0, p1

    .line 1011
    goto :goto_40d

    .line 1012
    :cond_3f3
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 1013
    .line 1014
    .line 1015
    move-result v0

    .line 1016
    if-eqz v0, :cond_3fe

    .line 1017
    .line 1018
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 1019
    .line 1020
    .line 1021
    move-result-object p0

    .line 1022
    goto :goto_40d

    .line 1023
    :cond_3fe
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->E0()Z

    .line 1024
    .line 1025
    .line 1026
    move-result v0

    .line 1027
    if-eqz v0, :cond_405

    .line 1028
    .line 1029
    goto :goto_3f1

    .line 1030
    :cond_405
    invoke-virtual {p0, v1}, Lcom/kousei/framework/b2;->y(Z)Lcom/kousei/framework/b2;

    .line 1031
    .line 1032
    .line 1033
    move-result-object p0

    .line 1034
    invoke-virtual {p0, p1}, Lcom/kousei/framework/b2;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 1035
    .line 1036
    .line 1037
    move-result-object p0

    .line 1038
    :goto_40d
    return-object p0

    .line 1039
    :pswitch_data_40e
    .packed-switch 0x0
        :pswitch_3d2
        :pswitch_307
        :pswitch_2cc
        :pswitch_291
        :pswitch_256
        :pswitch_21b
        :pswitch_1e0
        :pswitch_1a5
        :pswitch_16a
        :pswitch_12f
        :pswitch_f4
        :pswitch_b9
        :pswitch_7e
        :pswitch_43
    .end packed-switch
.end method

.method public u(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 4
    .line 5
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->E0()Z

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    if-nez v0, :cond_36

    .line 10
    .line 11
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->A0()Z

    .line 12
    .line 13
    .line 14
    move-result v0

    .line 15
    if-eqz v0, :cond_11

    .line 16
    .line 17
    goto :goto_36

    .line 18
    :cond_11
    if-nez p2, :cond_17

    .line 19
    .line 20
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 21
    .line 22
    .line 23
    move-result-object p2

    .line 24
    :cond_17
    invoke-virtual {p2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 25
    .line 26
    .line 27
    move-result-object p1

    .line 28
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 29
    .line 30
    .line 31
    move-result-object p2

    .line 32
    invoke-virtual {p2}, Lcom/kousei/framework/h0;->D()I

    .line 33
    .line 34
    .line 35
    move-result v0

    .line 36
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->D()I

    .line 37
    .line 38
    .line 39
    move-result v1

    .line 40
    if-ge v0, v1, :cond_32

    .line 41
    .line 42
    invoke-virtual {p1, p2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 43
    .line 44
    .line 45
    move-result-object p0

    .line 46
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->n1()Lcom/kousei/framework/h0;

    .line 47
    .line 48
    .line 49
    move-result-object p0

    .line 50
    return-object p0

    .line 51
    :cond_32
    invoke-virtual {p1, p0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 52
    .line 53
    .line 54
    move-result-object p0

    .line 55
    :cond_36
    :goto_36
    return-object p0
.end method

.method public v(Lcom/kousei/framework/a2;[I)Lcom/kousei/framework/a2;
    .registers 5

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 4
    .line 5
    check-cast p0, Lcom/kousei/framework/a2;

    .line 6
    .line 7
    iget-object v0, p1, Lcom/kousei/framework/a2;->S:[I

    .line 8
    .line 9
    invoke-static {v0}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 10
    .line 11
    .line 12
    move-result v0

    .line 13
    if-eqz v0, :cond_f

    .line 14
    .line 15
    return-object p0

    .line 16
    :cond_f
    new-instance v0, Lcom/kousei/framework/a2;

    .line 17
    .line 18
    const/16 v1, 0x17

    .line 19
    .line 20
    invoke-direct {v0, v1}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 21
    .line 22
    .line 23
    const/16 v1, 0x8

    .line 24
    .line 25
    new-array v1, v1, [I

    .line 26
    .line 27
    iput-object v1, v0, Lcom/kousei/framework/a2;->S:[I

    .line 28
    .line 29
    if-nez p2, :cond_24

    .line 30
    .line 31
    iget-object p1, p1, Lcom/kousei/framework/a2;->S:[I

    .line 32
    .line 33
    invoke-static {p1, v1}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 34
    .line 35
    .line 36
    move-object p2, v1

    .line 37
    :cond_24
    invoke-static {p2, v1}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 38
    .line 39
    .line 40
    iget-object p0, p0, Lcom/kousei/framework/a2;->S:[I

    .line 41
    .line 42
    invoke-static {v1, p0, v1}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 43
    .line 44
    .line 45
    return-object v0
.end method

.method public w()Lcom/kousei/framework/h0;
    .registers 5

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    aget-object v2, v0, v1

    .line 5
    .line 6
    if-nez v2, :cond_12

    .line 7
    .line 8
    const/4 v2, 0x0

    .line 9
    aget-object v2, v0, v2

    .line 10
    .line 11
    const/4 v3, 0x0

    .line 12
    invoke-virtual {p0, v2, v3}, Lcom/kousei/framework/b2;->u(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 13
    .line 14
    .line 15
    move-result-object p0

    .line 16
    aput-object p0, v0, v1

    .line 17
    .line 18
    return-object p0

    .line 19
    :cond_12
    return-object v2
.end method

.method public x()Lcom/kousei/framework/d4;
    .registers 8

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_7

    .line 6
    .line 7
    goto :goto_f

    .line 8
    :cond_7
    iget-object v0, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 9
    .line 10
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->E0()Z

    .line 11
    .line 12
    .line 13
    move-result v1

    .line 14
    if-eqz v1, :cond_10

    .line 15
    .line 16
    :goto_f
    return-object p0

    .line 17
    :cond_10
    iget-object v1, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 18
    .line 19
    iget v2, v1, Lcom/kousei/framework/v3;->f:I

    .line 20
    .line 21
    if-eqz v2, :cond_2c

    .line 22
    .line 23
    const/4 v0, 0x4

    .line 24
    if-eq v2, v0, :cond_22

    .line 25
    .line 26
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->o()Lcom/kousei/framework/d4;

    .line 27
    .line 28
    .line 29
    move-result-object v0

    .line 30
    invoke-virtual {v0, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 31
    .line 32
    .line 33
    move-result-object p0

    .line 34
    return-object p0

    .line 35
    :cond_22
    const/4 v0, 0x0

    .line 36
    invoke-virtual {p0, v0}, Lcom/kousei/framework/b2;->z(Z)Lcom/kousei/framework/b2;

    .line 37
    .line 38
    .line 39
    move-result-object v0

    .line 40
    invoke-virtual {v0, p0}, Lcom/kousei/framework/b2;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 41
    .line 42
    .line 43
    move-result-object p0

    .line 44
    return-object p0

    .line 45
    :cond_2c
    invoke-virtual {v0, v0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 46
    .line 47
    .line 48
    move-result-object v2

    .line 49
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 50
    .line 51
    .line 52
    move-result-object v3

    .line 53
    iget-object p0, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 54
    .line 55
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 56
    .line 57
    .line 58
    move-result-object v4

    .line 59
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 60
    .line 61
    .line 62
    move-result-object v5

    .line 63
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 64
    .line 65
    .line 66
    move-result-object v4

    .line 67
    iget-object v5, v1, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 68
    .line 69
    invoke-virtual {v4, v5}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 70
    .line 71
    .line 72
    move-result-object v4

    .line 73
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 74
    .line 75
    .line 76
    move-result-object v5

    .line 77
    invoke-virtual {p0, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 78
    .line 79
    .line 80
    move-result-object v6

    .line 81
    invoke-virtual {v6, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 82
    .line 83
    .line 84
    move-result-object v6

    .line 85
    invoke-virtual {v6, v3}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 86
    .line 87
    .line 88
    move-result-object v6

    .line 89
    invoke-virtual {v6, v5}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 90
    .line 91
    .line 92
    move-result-object v5

    .line 93
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->E0()Z

    .line 94
    .line 95
    .line 96
    move-result v6

    .line 97
    if-eqz v6, :cond_67

    .line 98
    .line 99
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 100
    .line 101
    .line 102
    move-result-object p0

    .line 103
    return-object p0

    .line 104
    :cond_67
    invoke-virtual {v5, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 105
    .line 106
    .line 107
    move-result-object v2

    .line 108
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->z0()Lcom/kousei/framework/h0;

    .line 109
    .line 110
    .line 111
    move-result-object v2

    .line 112
    invoke-virtual {v5, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 113
    .line 114
    .line 115
    move-result-object v5

    .line 116
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 117
    .line 118
    .line 119
    move-result-object v4

    .line 120
    invoke-virtual {v3}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 121
    .line 122
    .line 123
    move-result-object v3

    .line 124
    invoke-virtual {v3, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 125
    .line 126
    .line 127
    move-result-object v2

    .line 128
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 129
    .line 130
    .line 131
    move-result-object v2

    .line 132
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 133
    .line 134
    .line 135
    move-result-object v3

    .line 136
    invoke-virtual {v4, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 137
    .line 138
    .line 139
    move-result-object v4

    .line 140
    invoke-virtual {v3, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 141
    .line 142
    .line 143
    move-result-object v3

    .line 144
    invoke-virtual {v3, p0}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 145
    .line 146
    .line 147
    move-result-object v3

    .line 148
    invoke-virtual {p0, v3}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 149
    .line 150
    .line 151
    move-result-object p0

    .line 152
    invoke-virtual {p0, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 153
    .line 154
    .line 155
    move-result-object p0

    .line 156
    invoke-virtual {p0, v0}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 157
    .line 158
    .line 159
    move-result-object p0

    .line 160
    new-instance v0, Lcom/kousei/framework/b2;

    .line 161
    .line 162
    const/4 v2, 0x1

    .line 163
    invoke-direct {v0, v1, v3, p0, v2}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 164
    .line 165
    .line 166
    return-object v0
.end method

.method public y(Z)Lcom/kousei/framework/b2;
    .registers 26

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget-object v1, v0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 4
    .line 5
    check-cast v1, Lcom/kousei/framework/a2;

    .line 6
    .line 7
    iget-object v2, v0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 8
    .line 9
    check-cast v2, Lcom/kousei/framework/a2;

    .line 10
    .line 11
    iget-object v3, v0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 12
    .line 13
    const/4 v4, 0x0

    .line 14
    aget-object v5, v3, v4

    .line 15
    .line 16
    move-object v6, v5

    .line 17
    check-cast v6, Lcom/kousei/framework/a2;

    .line 18
    .line 19
    const/4 v7, 0x1

    .line 20
    aget-object v8, v3, v7

    .line 21
    .line 22
    check-cast v8, Lcom/kousei/framework/a2;

    .line 23
    .line 24
    const/4 v9, 0x0

    .line 25
    if-nez v8, :cond_22

    .line 26
    .line 27
    check-cast v5, Lcom/kousei/framework/a2;

    .line 28
    .line 29
    invoke-virtual {v0, v5, v9}, Lcom/kousei/framework/b2;->v(Lcom/kousei/framework/a2;[I)Lcom/kousei/framework/a2;

    .line 30
    .line 31
    .line 32
    move-result-object v8

    .line 33
    aput-object v8, v3, v7

    .line 34
    .line 35
    :cond_22
    const/16 v3, 0x8

    .line 36
    .line 37
    new-array v5, v3, [I

    .line 38
    .line 39
    iget-object v10, v1, Lcom/kousei/framework/a2;->S:[I

    .line 40
    .line 41
    invoke-static {v10, v5}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 42
    .line 43
    .line 44
    invoke-static {v5, v5, v5}, Lcom/kousei/framework/n6;->g([I[I[I)I

    .line 45
    .line 46
    .line 47
    move-result v10

    .line 48
    iget-object v11, v8, Lcom/kousei/framework/a2;->S:[I

    .line 49
    .line 50
    aget v12, v11, v4

    .line 51
    .line 52
    int-to-long v12, v12

    .line 53
    const-wide v14, 0xffffffffL

    .line 54
    .line 55
    .line 56
    .line 57
    .line 58
    and-long/2addr v12, v14

    .line 59
    move/from16 v16, v4

    .line 60
    .line 61
    aget v4, v5, v16

    .line 62
    .line 63
    move/from16 v17, v10

    .line 64
    .line 65
    int-to-long v9, v4

    .line 66
    and-long/2addr v9, v14

    .line 67
    add-long/2addr v12, v9

    .line 68
    long-to-int v4, v12

    .line 69
    aput v4, v5, v16

    .line 70
    .line 71
    const/16 v4, 0x20

    .line 72
    .line 73
    ushr-long v9, v12, v4

    .line 74
    .line 75
    aget v12, v11, v7

    .line 76
    .line 77
    int-to-long v12, v12

    .line 78
    and-long/2addr v12, v14

    .line 79
    move/from16 v18, v4

    .line 80
    .line 81
    aget v4, v5, v7

    .line 82
    .line 83
    move-wide/from16 v19, v14

    .line 84
    .line 85
    int-to-long v14, v4

    .line 86
    and-long v14, v14, v19

    .line 87
    .line 88
    add-long/2addr v12, v14

    .line 89
    add-long/2addr v12, v9

    .line 90
    long-to-int v4, v12

    .line 91
    aput v4, v5, v7

    .line 92
    .line 93
    ushr-long v9, v12, v18

    .line 94
    .line 95
    const/4 v4, 0x2

    .line 96
    aget v12, v11, v4

    .line 97
    .line 98
    int-to-long v12, v12

    .line 99
    and-long v12, v12, v19

    .line 100
    .line 101
    aget v14, v5, v4

    .line 102
    .line 103
    int-to-long v14, v14

    .line 104
    and-long v14, v14, v19

    .line 105
    .line 106
    add-long/2addr v12, v14

    .line 107
    add-long/2addr v12, v9

    .line 108
    long-to-int v9, v12

    .line 109
    aput v9, v5, v4

    .line 110
    .line 111
    ushr-long v9, v12, v18

    .line 112
    .line 113
    const/4 v12, 0x3

    .line 114
    aget v13, v11, v12

    .line 115
    .line 116
    int-to-long v13, v13

    .line 117
    and-long v13, v13, v19

    .line 118
    .line 119
    aget v15, v5, v12

    .line 120
    .line 121
    move/from16 v21, v12

    .line 122
    .line 123
    move-wide/from16 v22, v13

    .line 124
    .line 125
    int-to-long v12, v15

    .line 126
    and-long v12, v12, v19

    .line 127
    .line 128
    add-long v13, v22, v12

    .line 129
    .line 130
    add-long/2addr v13, v9

    .line 131
    long-to-int v9, v13

    .line 132
    aput v9, v5, v21

    .line 133
    .line 134
    ushr-long v9, v13, v18

    .line 135
    .line 136
    const/4 v12, 0x4

    .line 137
    aget v13, v11, v12

    .line 138
    .line 139
    int-to-long v13, v13

    .line 140
    and-long v13, v13, v19

    .line 141
    .line 142
    aget v15, v5, v12

    .line 143
    .line 144
    move/from16 v21, v12

    .line 145
    .line 146
    move-wide/from16 v22, v13

    .line 147
    .line 148
    int-to-long v12, v15

    .line 149
    and-long v12, v12, v19

    .line 150
    .line 151
    add-long v13, v22, v12

    .line 152
    .line 153
    add-long/2addr v13, v9

    .line 154
    long-to-int v9, v13

    .line 155
    aput v9, v5, v21

    .line 156
    .line 157
    ushr-long v9, v13, v18

    .line 158
    .line 159
    const/4 v12, 0x5

    .line 160
    aget v13, v11, v12

    .line 161
    .line 162
    int-to-long v13, v13

    .line 163
    and-long v13, v13, v19

    .line 164
    .line 165
    aget v15, v5, v12

    .line 166
    .line 167
    move/from16 v21, v12

    .line 168
    .line 169
    move-wide/from16 v22, v13

    .line 170
    .line 171
    int-to-long v12, v15

    .line 172
    and-long v12, v12, v19

    .line 173
    .line 174
    add-long v13, v22, v12

    .line 175
    .line 176
    add-long/2addr v13, v9

    .line 177
    long-to-int v9, v13

    .line 178
    aput v9, v5, v21

    .line 179
    .line 180
    ushr-long v9, v13, v18

    .line 181
    .line 182
    const/4 v12, 0x6

    .line 183
    aget v13, v11, v12

    .line 184
    .line 185
    int-to-long v13, v13

    .line 186
    and-long v13, v13, v19

    .line 187
    .line 188
    aget v15, v5, v12

    .line 189
    .line 190
    move/from16 v21, v12

    .line 191
    .line 192
    move-wide/from16 v22, v13

    .line 193
    .line 194
    int-to-long v12, v15

    .line 195
    and-long v12, v12, v19

    .line 196
    .line 197
    add-long v13, v22, v12

    .line 198
    .line 199
    add-long/2addr v13, v9

    .line 200
    long-to-int v9, v13

    .line 201
    aput v9, v5, v21

    .line 202
    .line 203
    ushr-long v9, v13, v18

    .line 204
    .line 205
    const/4 v12, 0x7

    .line 206
    aget v11, v11, v12

    .line 207
    .line 208
    int-to-long v13, v11

    .line 209
    and-long v13, v13, v19

    .line 210
    .line 211
    aget v11, v5, v12

    .line 212
    .line 213
    move v15, v12

    .line 214
    move-wide/from16 v21, v13

    .line 215
    .line 216
    int-to-long v12, v11

    .line 217
    and-long v11, v12, v19

    .line 218
    .line 219
    add-long v13, v21, v11

    .line 220
    .line 221
    add-long/2addr v13, v9

    .line 222
    long-to-int v9, v13

    .line 223
    aput v9, v5, v15

    .line 224
    .line 225
    ushr-long v9, v13, v18

    .line 226
    .line 227
    long-to-int v9, v9

    .line 228
    add-int v10, v17, v9

    .line 229
    .line 230
    invoke-static {v10, v5}, Lcom/kousei/framework/h0;->K1(I[I)V

    .line 231
    .line 232
    .line 233
    new-array v9, v3, [I

    .line 234
    .line 235
    iget-object v10, v2, Lcom/kousei/framework/a2;->S:[I

    .line 236
    .line 237
    invoke-static {v10, v9}, Lcom/kousei/framework/h0;->d3([I[I)V

    .line 238
    .line 239
    .line 240
    new-array v10, v3, [I

    .line 241
    .line 242
    iget-object v2, v2, Lcom/kousei/framework/a2;->S:[I

    .line 243
    .line 244
    invoke-static {v9, v2, v10}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 245
    .line 246
    .line 247
    new-array v2, v3, [I

    .line 248
    .line 249
    iget-object v1, v1, Lcom/kousei/framework/a2;->S:[I

    .line 250
    .line 251
    invoke-static {v10, v1, v2}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 252
    .line 253
    .line 254
    invoke-static {v2, v2}, Lcom/kousei/framework/h0;->d3([I[I)V

    .line 255
    .line 256
    .line 257
    new-array v1, v3, [I

    .line 258
    .line 259
    invoke-static {v10, v1}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 260
    .line 261
    .line 262
    invoke-static {v1, v1}, Lcom/kousei/framework/h0;->d3([I[I)V

    .line 263
    .line 264
    .line 265
    new-instance v3, Lcom/kousei/framework/a2;

    .line 266
    .line 267
    invoke-direct {v3, v10}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 268
    .line 269
    .line 270
    invoke-static {v5, v10}, Lcom/kousei/framework/h0;->Y1([I[I)V

    .line 271
    .line 272
    .line 273
    invoke-static {v10, v2, v10}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    .line 274
    .line 275
    .line 276
    invoke-static {v10, v2, v10}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    .line 277
    .line 278
    .line 279
    new-instance v11, Lcom/kousei/framework/a2;

    .line 280
    .line 281
    invoke-direct {v11, v2}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 282
    .line 283
    .line 284
    invoke-static {v2, v10, v2}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    .line 285
    .line 286
    .line 287
    invoke-static {v2, v5, v2}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 288
    .line 289
    .line 290
    invoke-static {v2, v1, v2}, Lcom/kousei/framework/h0;->M2([I[I[I)V

    .line 291
    .line 292
    .line 293
    new-instance v2, Lcom/kousei/framework/a2;

    .line 294
    .line 295
    invoke-direct {v2, v9}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 296
    .line 297
    .line 298
    iget-object v5, v6, Lcom/kousei/framework/a2;->S:[I

    .line 299
    .line 300
    invoke-static {v5}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 301
    .line 302
    .line 303
    move-result v5

    .line 304
    if-nez v5, :cond_136

    .line 305
    .line 306
    iget-object v5, v6, Lcom/kousei/framework/a2;->S:[I

    .line 307
    .line 308
    invoke-static {v9, v5, v9}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 309
    .line 310
    .line 311
    :cond_136
    if-eqz p1, :cond_146

    .line 312
    .line 313
    new-instance v9, Lcom/kousei/framework/a2;

    .line 314
    .line 315
    invoke-direct {v9, v1}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 316
    .line 317
    .line 318
    iget-object v5, v8, Lcom/kousei/framework/a2;->S:[I

    .line 319
    .line 320
    invoke-static {v1, v5, v1}, Lcom/kousei/framework/h0;->R0([I[I[I)V

    .line 321
    .line 322
    .line 323
    invoke-static {v1, v1}, Lcom/kousei/framework/h0;->d3([I[I)V

    .line 324
    .line 325
    .line 326
    goto :goto_147

    .line 327
    :cond_146
    const/4 v9, 0x0

    .line 328
    :goto_147
    new-instance v17, Lcom/kousei/framework/b2;

    .line 329
    .line 330
    new-array v1, v4, [Lcom/kousei/framework/h0;

    .line 331
    .line 332
    aput-object v2, v1, v16

    .line 333
    .line 334
    aput-object v9, v1, v7

    .line 335
    .line 336
    const/16 v22, 0x0

    .line 337
    .line 338
    iget-object v0, v0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 339
    .line 340
    move-object/from16 v18, v0

    .line 341
    .line 342
    move-object/from16 v21, v1

    .line 343
    .line 344
    move-object/from16 v19, v3

    .line 345
    .line 346
    move-object/from16 v20, v11

    .line 347
    .line 348
    invoke-direct/range {v17 .. v22}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 349
    .line 350
    .line 351
    return-object v17
.end method

.method public z(Z)Lcom/kousei/framework/b2;
    .registers 16

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    aget-object v0, v0, v1

    .line 5
    .line 6
    invoke-virtual {p0}, Lcom/kousei/framework/b2;->w()Lcom/kousei/framework/h0;

    .line 7
    .line 8
    .line 9
    move-result-object v1

    .line 10
    iget-object v2, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 11
    .line 12
    invoke-virtual {v2}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 13
    .line 14
    .line 15
    move-result-object v3

    .line 16
    invoke-virtual {v3, v3}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 17
    .line 18
    .line 19
    move-result-object v4

    .line 20
    invoke-virtual {v4, v3}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 21
    .line 22
    .line 23
    move-result-object v3

    .line 24
    invoke-virtual {v3, v1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 25
    .line 26
    .line 27
    move-result-object v3

    .line 28
    iget-object v4, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 29
    .line 30
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 31
    .line 32
    .line 33
    move-result-object v5

    .line 34
    invoke-virtual {v5, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 35
    .line 36
    .line 37
    move-result-object v4

    .line 38
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object v2

    .line 42
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 43
    .line 44
    .line 45
    move-result-object v2

    .line 46
    invoke-virtual {v3}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 47
    .line 48
    .line 49
    move-result-object v6

    .line 50
    invoke-virtual {v2, v2}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 51
    .line 52
    .line 53
    move-result-object v7

    .line 54
    invoke-virtual {v6, v7}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 55
    .line 56
    .line 57
    move-result-object v10

    .line 58
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 59
    .line 60
    .line 61
    move-result-object v4

    .line 62
    invoke-virtual {v4, v4}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 63
    .line 64
    .line 65
    move-result-object v4

    .line 66
    invoke-virtual {v2, v10}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 67
    .line 68
    .line 69
    move-result-object v2

    .line 70
    invoke-virtual {v3, v2}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 71
    .line 72
    .line 73
    move-result-object v2

    .line 74
    invoke-virtual {v2, v4}, Lcom/kousei/framework/h0;->L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 75
    .line 76
    .line 77
    move-result-object v11

    .line 78
    if-eqz p1, :cond_58

    .line 79
    .line 80
    invoke-virtual {v4, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 81
    .line 82
    .line 83
    move-result-object p1

    .line 84
    invoke-virtual {p1, p1}, Lcom/kousei/framework/h0;->b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 85
    .line 86
    .line 87
    move-result-object p1

    .line 88
    goto :goto_59

    .line 89
    :cond_58
    const/4 p1, 0x0

    .line 90
    :goto_59
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->A0()Z

    .line 91
    .line 92
    .line 93
    move-result v1

    .line 94
    if-eqz v1, :cond_60

    .line 95
    .line 96
    goto :goto_64

    .line 97
    :cond_60
    invoke-virtual {v5, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 98
    .line 99
    .line 100
    move-result-object v5

    .line 101
    :goto_64
    new-instance v8, Lcom/kousei/framework/b2;

    .line 102
    .line 103
    filled-new-array {v5, p1}, [Lcom/kousei/framework/h0;

    .line 104
    .line 105
    .line 106
    move-result-object v12

    .line 107
    const/4 v13, 0x1

    .line 108
    iget-object v9, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 109
    .line 110
    invoke-direct/range {v8 .. v13}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 111
    .line 112
    .line 113
    return-object v8
.end method
