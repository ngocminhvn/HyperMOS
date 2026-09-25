.class public final Lcom/kousei/framework/c2;
.super Lcom/kousei/framework/bb;


# instance fields
.field public final synthetic b:I


# direct methods
.method public synthetic constructor <init>(I)V
    .registers 2

    .line 1
    iput p1, p0, Lcom/kousei/framework/c2;->b:I

    .line 2
    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 4
    .line 5
    .line 6
    return-void
.end method

.method private final c()Lcom/kousei/framework/v3;
    .registers 11

    .line 1
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F"

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 4
    .line 5
    .line 6
    move-result-object v2

    .line 7
    sget-object v3, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 8
    .line 9
    const-wide/16 v0, 0x7

    .line 10
    .line 11
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 12
    .line 13
    .line 14
    move-result-object v4

    .line 15
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141"

    .line 16
    .line 17
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 18
    .line 19
    .line 20
    move-result-object v5

    .line 21
    const-wide/16 v0, 0x1

    .line 22
    .line 23
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 24
    .line 25
    .line 26
    move-result-object v6

    .line 27
    new-instance p0, Ljava/math/BigInteger;

    .line 28
    .line 29
    const-string v0, "7ae96a2b657c07106e64479eac3434e99cf0497512f58995c1396c28719501ee"

    .line 30
    .line 31
    const/16 v1, 0x10

    .line 32
    .line 33
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 34
    .line 35
    .line 36
    new-instance v0, Ljava/math/BigInteger;

    .line 37
    .line 38
    const-string v7, "5363ad4cc05c30e0a5261c028812645a122e22ea20816678df02967c1b23bd72"

    .line 39
    .line 40
    invoke-direct {v0, v7, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 41
    .line 42
    .line 43
    new-instance v0, Ljava/math/BigInteger;

    .line 44
    .line 45
    const-string v7, "3086d221a7d46bcde86c90e49284eb15"

    .line 46
    .line 47
    invoke-direct {v0, v7, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 48
    .line 49
    .line 50
    new-instance v8, Ljava/math/BigInteger;

    .line 51
    .line 52
    const-string v9, "-e4437ed6010e88286f547fa90abfe4c3"

    .line 53
    .line 54
    invoke-direct {v8, v9, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 55
    .line 56
    .line 57
    filled-new-array {v0, v8}, [Ljava/math/BigInteger;

    .line 58
    .line 59
    .line 60
    move-result-object v0

    .line 61
    new-instance v8, Ljava/math/BigInteger;

    .line 62
    .line 63
    const-string v9, "114ca50f7a8e2f3f657c1108d9d44cfd8"

    .line 64
    .line 65
    invoke-direct {v8, v9, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 66
    .line 67
    .line 68
    new-instance v9, Ljava/math/BigInteger;

    .line 69
    .line 70
    invoke-direct {v9, v7, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 71
    .line 72
    .line 73
    filled-new-array {v8, v9}, [Ljava/math/BigInteger;

    .line 74
    .line 75
    .line 76
    move-result-object v7

    .line 77
    new-instance v8, Ljava/math/BigInteger;

    .line 78
    .line 79
    const-string v9, "3086d221a7d46bcde86c90e49284eb153dab"

    .line 80
    .line 81
    invoke-direct {v8, v9, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 82
    .line 83
    .line 84
    new-instance v8, Ljava/math/BigInteger;

    .line 85
    .line 86
    const-string v9, "e4437ed6010e88286f547fa90abfe4c42212"

    .line 87
    .line 88
    invoke-direct {v8, v9, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 89
    .line 90
    .line 91
    const-string v1, "v1"

    .line 92
    .line 93
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 94
    .line 95
    .line 96
    const-string v0, "v2"

    .line 97
    .line 98
    invoke-static {v7, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 99
    .line 100
    .line 101
    new-instance v1, Lcom/kousei/framework/u3;

    .line 102
    .line 103
    const/4 v7, 0x1

    .line 104
    invoke-direct/range {v1 .. v7}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 105
    .line 106
    .line 107
    monitor-enter v1

    .line 108
    :try_start_6b
    iget v0, v1, Lcom/kousei/framework/v3;->f:I
    :try_end_6d
    .catchall {:try_start_6b .. :try_end_6d} :catchall_8f

    .line 109
    .line 110
    monitor-exit v1

    .line 111
    invoke-virtual {v1, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 112
    .line 113
    .line 114
    invoke-virtual {v1, v0}, Lcom/kousei/framework/v3;->m(I)Z

    .line 115
    .line 116
    .line 117
    move-result p0

    .line 118
    const/4 v2, 0x0

    .line 119
    if-eqz p0, :cond_8c

    .line 120
    .line 121
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 122
    .line 123
    .line 124
    move-result-object p0

    .line 125
    if-eq p0, v1, :cond_86

    .line 126
    .line 127
    monitor-enter p0

    .line 128
    :try_start_7f
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 129
    .line 130
    monitor-exit p0

    .line 131
    return-object p0

    .line 132
    :catchall_83
    move-exception v0

    .line 133
    monitor-exit p0
    :try_end_85
    .catchall {:try_start_7f .. :try_end_85} :catchall_83

    .line 134
    throw v0

    .line 135
    :cond_86
    const-string p0, "implementation returned current curve"

    .line 136
    .line 137
    :goto_88
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 138
    .line 139
    .line 140
    return-object v2

    .line 141
    :cond_8c
    const-string p0, "unsupported coordinate system"

    .line 142
    .line 143
    goto :goto_88

    .line 144
    :catchall_8f
    move-exception v0

    .line 145
    move-object p0, v0

    .line 146
    :try_start_91
    monitor-exit v1
    :try_end_92
    .catchall {:try_start_91 .. :try_end_92} :catchall_8f

    .line 147
    throw p0
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 16

    .line 1
    iget v0, p0, Lcom/kousei/framework/c2;->b:I

    .line 2
    .line 3
    const/16 v1, 0x10

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    const-wide/16 v3, 0x2

    .line 7
    .line 8
    const-wide/16 v5, 0x1

    .line 9
    .line 10
    packed-switch v0, :pswitch_data_45c

    .line 11
    .line 12
    .line 13
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 14
    .line 15
    .line 16
    move-result-object v10

    .line 17
    const-string p0, "0066647EDE6C332C7F8C0923BB58213B333B20E9CE4281FE115F7D8F90AD"

    .line 18
    .line 19
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 20
    .line 21
    .line 22
    move-result-object v11

    .line 23
    const-string p0, "01000000000000000000000000000013E974E72F8A6922031D2603CFE0D7"

    .line 24
    .line 25
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 26
    .line 27
    .line 28
    move-result-object v12

    .line 29
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 30
    .line 31
    .line 32
    move-result-object v13

    .line 33
    new-instance v7, Lcom/kousei/framework/t3;

    .line 34
    .line 35
    const/16 v8, 0xe9

    .line 36
    .line 37
    const/16 v9, 0x4a

    .line 38
    .line 39
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 40
    .line 41
    .line 42
    return-object v7

    .line 43
    :pswitch_2a
    sget-object v3, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 44
    .line 45
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 46
    .line 47
    .line 48
    move-result-object v4

    .line 49
    const-string p0, "8000000000000000000000000000069D5BB915BCD46EFB1AD5F173ABDF"

    .line 50
    .line 51
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 52
    .line 53
    .line 54
    move-result-object v5

    .line 55
    const-wide/16 v0, 0x4

    .line 56
    .line 57
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 58
    .line 59
    .line 60
    move-result-object v6

    .line 61
    new-instance v0, Lcom/kousei/framework/t3;

    .line 62
    .line 63
    const/16 v1, 0xe9

    .line 64
    .line 65
    const/16 v2, 0x4a

    .line 66
    .line 67
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 68
    .line 69
    .line 70
    return-object v0

    .line 71
    :pswitch_46
    const-string p0, "0163F35A5137C2CE3EA6ED8667190B0BC43ECD69977702709B"

    .line 72
    .line 73
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 74
    .line 75
    .line 76
    move-result-object v8

    .line 77
    const-string p0, "00C9BB9E8927D4D64C377E2AB2856A5B16E3EFB7F61D4316AE"

    .line 78
    .line 79
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 80
    .line 81
    .line 82
    move-result-object v9

    .line 83
    const-string p0, "010000000000000000000000015AAB561B005413CCD4EE99D5"

    .line 84
    .line 85
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 86
    .line 87
    .line 88
    move-result-object v10

    .line 89
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 90
    .line 91
    .line 92
    move-result-object v11

    .line 93
    new-instance v5, Lcom/kousei/framework/t3;

    .line 94
    .line 95
    const/16 v6, 0xc1

    .line 96
    .line 97
    const/16 v7, 0xf

    .line 98
    .line 99
    invoke-direct/range {v5 .. v11}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 100
    .line 101
    .line 102
    return-object v5

    .line 103
    :pswitch_66
    const-string p0, "0017858FEB7A98975169E171F77B4087DE098AC8A911DF7B01"

    .line 104
    .line 105
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 106
    .line 107
    .line 108
    move-result-object v8

    .line 109
    const-string p0, "00FDFB49BFE6C3A89FACADAA7A1E5BBC7CC1C2E5D831478814"

    .line 110
    .line 111
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 112
    .line 113
    .line 114
    move-result-object v9

    .line 115
    const-string p0, "01000000000000000000000000C7F34A778F443ACC920EBA49"

    .line 116
    .line 117
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 118
    .line 119
    .line 120
    move-result-object v10

    .line 121
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 122
    .line 123
    .line 124
    move-result-object v11

    .line 125
    new-instance v5, Lcom/kousei/framework/t3;

    .line 126
    .line 127
    const/16 v6, 0xc1

    .line 128
    .line 129
    const/16 v7, 0xf

    .line 130
    .line 131
    invoke-direct/range {v5 .. v11}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 132
    .line 133
    .line 134
    return-object v5

    .line 135
    :pswitch_86
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 136
    .line 137
    .line 138
    move-result-object v11

    .line 139
    const-string p0, "020A601907B8C953CA1481EB10512F78744A3205FD"

    .line 140
    .line 141
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 142
    .line 143
    .line 144
    move-result-object v12

    .line 145
    const-string p0, "040000000000000000000292FE77E70C12A4234C33"

    .line 146
    .line 147
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 148
    .line 149
    .line 150
    move-result-object v13

    .line 151
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 152
    .line 153
    .line 154
    move-result-object v14

    .line 155
    new-instance v6, Lcom/kousei/framework/t3;

    .line 156
    .line 157
    const/16 v7, 0xa3

    .line 158
    .line 159
    const/4 v8, 0x3

    .line 160
    const/4 v9, 0x6

    .line 161
    const/4 v10, 0x7

    .line 162
    invoke-direct/range {v6 .. v14}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 163
    .line 164
    .line 165
    return-object v6

    .line 166
    :pswitch_a5
    const-string p0, "07B6882CAAEFA84F9554FF8428BD88E246D2782AE2"

    .line 167
    .line 168
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 169
    .line 170
    .line 171
    move-result-object v10

    .line 172
    const-string p0, "0713612DCDDCB40AAB946BDA29CA91F73AF958AFD9"

    .line 173
    .line 174
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 175
    .line 176
    .line 177
    move-result-object v11

    .line 178
    const-string p0, "03FFFFFFFFFFFFFFFFFFFF48AAB689C29CA710279B"

    .line 179
    .line 180
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 181
    .line 182
    .line 183
    move-result-object v12

    .line 184
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 185
    .line 186
    .line 187
    move-result-object v13

    .line 188
    new-instance v5, Lcom/kousei/framework/t3;

    .line 189
    .line 190
    const/16 v6, 0xa3

    .line 191
    .line 192
    const/4 v7, 0x3

    .line 193
    const/4 v8, 0x6

    .line 194
    const/4 v9, 0x7

    .line 195
    invoke-direct/range {v5 .. v13}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 196
    .line 197
    .line 198
    return-object v5

    .line 199
    :pswitch_c6
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 200
    .line 201
    .line 202
    move-result-object v11

    .line 203
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 204
    .line 205
    .line 206
    move-result-object v12

    .line 207
    const-string p0, "04000000000000000000020108A2E0CC0D99F8A5EF"

    .line 208
    .line 209
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 210
    .line 211
    .line 212
    move-result-object v13

    .line 213
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 214
    .line 215
    .line 216
    move-result-object v14

    .line 217
    new-instance v6, Lcom/kousei/framework/t3;

    .line 218
    .line 219
    const/16 v7, 0xa3

    .line 220
    .line 221
    const/4 v8, 0x3

    .line 222
    const/4 v9, 0x6

    .line 223
    const/4 v10, 0x7

    .line 224
    invoke-direct/range {v6 .. v14}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 225
    .line 226
    .line 227
    return-object v6

    .line 228
    :pswitch_e3
    const-string p0, "DB7C2ABF62E35E668076BEAD208B"

    .line 229
    .line 230
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 231
    .line 232
    .line 233
    move-result-object v8

    .line 234
    const-string p0, "DB7C2ABF62E35E668076BEAD2088"

    .line 235
    .line 236
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 237
    .line 238
    .line 239
    move-result-object v9

    .line 240
    const-string p0, "659EF8BA043916EEDE8911702B22"

    .line 241
    .line 242
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 243
    .line 244
    .line 245
    move-result-object v10

    .line 246
    const-string p0, "DB7C2ABF62E35E7628DFAC6561C5"

    .line 247
    .line 248
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 249
    .line 250
    .line 251
    move-result-object v11

    .line 252
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 253
    .line 254
    .line 255
    move-result-object v12

    .line 256
    new-instance v7, Lcom/kousei/framework/u3;

    .line 257
    .line 258
    const/4 v13, 0x1

    .line 259
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 260
    .line 261
    .line 262
    return-object v7

    .line 263
    :pswitch_106
    const-string p0, "03E5A88919D7CAFCBF415F07C2176573B2"

    .line 264
    .line 265
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 266
    .line 267
    .line 268
    move-result-object v10

    .line 269
    const-string p0, "04B8266A46C55657AC734CE38F018F2192"

    .line 270
    .line 271
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 272
    .line 273
    .line 274
    move-result-object v11

    .line 275
    const-string p0, "0400000000000000016954A233049BA98F"

    .line 276
    .line 277
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 278
    .line 279
    .line 280
    move-result-object v12

    .line 281
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 282
    .line 283
    .line 284
    move-result-object v13

    .line 285
    new-instance v5, Lcom/kousei/framework/t3;

    .line 286
    .line 287
    const/16 v6, 0x83

    .line 288
    .line 289
    const/4 v7, 0x2

    .line 290
    const/4 v8, 0x3

    .line 291
    const/16 v9, 0x8

    .line 292
    .line 293
    invoke-direct/range {v5 .. v13}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 294
    .line 295
    .line 296
    return-object v5

    .line 297
    :pswitch_128
    const-string p0, "07A11B09A76B562144418FF3FF8C2570B8"

    .line 298
    .line 299
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 300
    .line 301
    .line 302
    move-result-object v10

    .line 303
    const-string p0, "0217C05610884B63B9C6C7291678F9D341"

    .line 304
    .line 305
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 306
    .line 307
    .line 308
    move-result-object v11

    .line 309
    const-string p0, "0400000000000000023123953A9464B54D"

    .line 310
    .line 311
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 312
    .line 313
    .line 314
    move-result-object v12

    .line 315
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 316
    .line 317
    .line 318
    move-result-object v13

    .line 319
    new-instance v5, Lcom/kousei/framework/t3;

    .line 320
    .line 321
    const/16 v6, 0x83

    .line 322
    .line 323
    const/4 v7, 0x2

    .line 324
    const/4 v8, 0x3

    .line 325
    const/16 v9, 0x8

    .line 326
    .line 327
    invoke-direct/range {v5 .. v13}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 328
    .line 329
    .line 330
    return-object v5

    .line 331
    :pswitch_14a
    const-string p0, "00689918DBEC7E5A0DD6DFC0AA55C7"

    .line 332
    .line 333
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 334
    .line 335
    .line 336
    move-result-object v8

    .line 337
    const-string p0, "0095E9A9EC9B297BD4BF36E059184F"

    .line 338
    .line 339
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 340
    .line 341
    .line 342
    move-result-object v9

    .line 343
    const-string p0, "010000000000000108789B2496AF93"

    .line 344
    .line 345
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 346
    .line 347
    .line 348
    move-result-object v10

    .line 349
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 350
    .line 351
    .line 352
    move-result-object v11

    .line 353
    new-instance v5, Lcom/kousei/framework/t3;

    .line 354
    .line 355
    const/16 v6, 0x71

    .line 356
    .line 357
    const/16 v7, 0x9

    .line 358
    .line 359
    invoke-direct/range {v5 .. v11}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 360
    .line 361
    .line 362
    return-object v5

    .line 363
    :pswitch_16a
    const-string p0, "003088250CA6E7C7FE649CE85820F7"

    .line 364
    .line 365
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 366
    .line 367
    .line 368
    move-result-object v8

    .line 369
    const-string p0, "00E8BEE4D3E2260744188BE0E9C723"

    .line 370
    .line 371
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 372
    .line 373
    .line 374
    move-result-object v9

    .line 375
    const-string p0, "0100000000000000D9CCEC8A39E56F"

    .line 376
    .line 377
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 378
    .line 379
    .line 380
    move-result-object v10

    .line 381
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 382
    .line 383
    .line 384
    move-result-object v11

    .line 385
    new-instance v5, Lcom/kousei/framework/t3;

    .line 386
    .line 387
    const/16 v6, 0x71

    .line 388
    .line 389
    const/16 v7, 0x9

    .line 390
    .line 391
    invoke-direct/range {v5 .. v11}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 392
    .line 393
    .line 394
    return-object v5

    .line 395
    :pswitch_18a
    const-string p0, "01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

    .line 396
    .line 397
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 398
    .line 399
    .line 400
    move-result-object v8

    .line 401
    const-string p0, "01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"

    .line 402
    .line 403
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 404
    .line 405
    .line 406
    move-result-object v9

    .line 407
    const-string p0, "0051953EB9618E1C9A1F929A21A0B68540EEA2DA725B99B315F3B8B489918EF109E156193951EC7E937B1652C0BD3BB1BF073573DF883D2C34F1EF451FD46B503F00"

    .line 408
    .line 409
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 410
    .line 411
    .line 412
    move-result-object v10

    .line 413
    const-string p0, "01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA51868783BF2F966B7FCC0148F709A5D03BB5C9B8899C47AEBB6FB71E91386409"

    .line 414
    .line 415
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 416
    .line 417
    .line 418
    move-result-object v11

    .line 419
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 420
    .line 421
    .line 422
    move-result-object v12

    .line 423
    new-instance v7, Lcom/kousei/framework/u3;

    .line 424
    .line 425
    const/4 v13, 0x1

    .line 426
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 427
    .line 428
    .line 429
    return-object v7

    .line 430
    :pswitch_1ad
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFF0000000000000000FFFFFFFF"

    .line 431
    .line 432
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 433
    .line 434
    .line 435
    move-result-object v8

    .line 436
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFF0000000000000000FFFFFFFC"

    .line 437
    .line 438
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 439
    .line 440
    .line 441
    move-result-object v9

    .line 442
    const-string p0, "B3312FA7E23EE7E4988E056BE3F82D19181D9C6EFE8141120314088F5013875AC656398D8A2ED19D2A85C8EDD3EC2AEF"

    .line 443
    .line 444
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 445
    .line 446
    .line 447
    move-result-object v10

    .line 448
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7634D81F4372DDF581A0DB248B0A77AECEC196ACCC52973"

    .line 449
    .line 450
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 451
    .line 452
    .line 453
    move-result-object v11

    .line 454
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 455
    .line 456
    .line 457
    move-result-object v12

    .line 458
    new-instance v7, Lcom/kousei/framework/u3;

    .line 459
    .line 460
    const/4 v13, 0x1

    .line 461
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 462
    .line 463
    .line 464
    return-object v7

    .line 465
    :pswitch_1d0
    const-string p0, "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF"

    .line 466
    .line 467
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 468
    .line 469
    .line 470
    move-result-object v8

    .line 471
    const-string p0, "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC"

    .line 472
    .line 473
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 474
    .line 475
    .line 476
    move-result-object v9

    .line 477
    const-string p0, "5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B"

    .line 478
    .line 479
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 480
    .line 481
    .line 482
    move-result-object v10

    .line 483
    const-string p0, "FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551"

    .line 484
    .line 485
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 486
    .line 487
    .line 488
    move-result-object v11

    .line 489
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 490
    .line 491
    .line 492
    move-result-object v12

    .line 493
    new-instance v7, Lcom/kousei/framework/u3;

    .line 494
    .line 495
    const/4 v13, 0x1

    .line 496
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 497
    .line 498
    .line 499
    return-object v7

    .line 500
    :pswitch_1f3
    invoke-direct {p0}, Lcom/kousei/framework/c2;->c()Lcom/kousei/framework/v3;

    .line 501
    .line 502
    .line 503
    move-result-object p0

    .line 504
    return-object p0

    .line 505
    :pswitch_1f8
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000001"

    .line 506
    .line 507
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 508
    .line 509
    .line 510
    move-result-object v8

    .line 511
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFE"

    .line 512
    .line 513
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 514
    .line 515
    .line 516
    move-result-object v9

    .line 517
    const-string p0, "B4050A850C04B3ABF54132565044B0B7D7BFD8BA270B39432355FFB4"

    .line 518
    .line 519
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 520
    .line 521
    .line 522
    move-result-object v10

    .line 523
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFF16A2E0B8F03E13DD29455C5C2A3D"

    .line 524
    .line 525
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 526
    .line 527
    .line 528
    move-result-object v11

    .line 529
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 530
    .line 531
    .line 532
    move-result-object v12

    .line 533
    new-instance v7, Lcom/kousei/framework/u3;

    .line 534
    .line 535
    const/4 v13, 0x1

    .line 536
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 537
    .line 538
    .line 539
    return-object v7

    .line 540
    :pswitch_21b
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFE56D"

    .line 541
    .line 542
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 543
    .line 544
    .line 545
    move-result-object v8

    .line 546
    sget-object v9, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 547
    .line 548
    const-wide/16 v3, 0x5

    .line 549
    .line 550
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 551
    .line 552
    .line 553
    move-result-object v10

    .line 554
    const-string p0, "010000000000000000000000000001DCE8D2EC6184CAF0A971769FB1F7"

    .line 555
    .line 556
    invoke-static {p0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 557
    .line 558
    .line 559
    move-result-object v11

    .line 560
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 561
    .line 562
    .line 563
    move-result-object v12

    .line 564
    new-instance p0, Ljava/math/BigInteger;

    .line 565
    .line 566
    const-string v0, "fe0e87005b4e83761908c5131d552a850b3f58b749c37cf5b84d6768"

    .line 567
    .line 568
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 569
    .line 570
    .line 571
    new-instance v0, Ljava/math/BigInteger;

    .line 572
    .line 573
    const-string v3, "60dcd2104c4cbc0be6eeefc2bdd610739ec34e317f9b33046c9e4788"

    .line 574
    .line 575
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 576
    .line 577
    .line 578
    new-instance v0, Ljava/math/BigInteger;

    .line 579
    .line 580
    const-string v3, "6b8cf07d4ca75c88957d9d670591"

    .line 581
    .line 582
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 583
    .line 584
    .line 585
    new-instance v4, Ljava/math/BigInteger;

    .line 586
    .line 587
    const-string v5, "-b8adf1378a6eb73409fa6c9c637d"

    .line 588
    .line 589
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 590
    .line 591
    .line 592
    filled-new-array {v0, v4}, [Ljava/math/BigInteger;

    .line 593
    .line 594
    .line 595
    move-result-object v0

    .line 596
    new-instance v4, Ljava/math/BigInteger;

    .line 597
    .line 598
    const-string v5, "1243ae1b4d71613bc9f780a03690e"

    .line 599
    .line 600
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 601
    .line 602
    .line 603
    new-instance v5, Ljava/math/BigInteger;

    .line 604
    .line 605
    invoke-direct {v5, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 606
    .line 607
    .line 608
    filled-new-array {v4, v5}, [Ljava/math/BigInteger;

    .line 609
    .line 610
    .line 611
    move-result-object v3

    .line 612
    new-instance v4, Ljava/math/BigInteger;

    .line 613
    .line 614
    const-string v5, "6b8cf07d4ca75c88957d9d67059037a4"

    .line 615
    .line 616
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 617
    .line 618
    .line 619
    new-instance v4, Ljava/math/BigInteger;

    .line 620
    .line 621
    const-string v5, "b8adf1378a6eb73409fa6c9c637ba7f5"

    .line 622
    .line 623
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 624
    .line 625
    .line 626
    const-string v1, "v1"

    .line 627
    .line 628
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 629
    .line 630
    .line 631
    const-string v0, "v2"

    .line 632
    .line 633
    invoke-static {v3, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 634
    .line 635
    .line 636
    new-instance v7, Lcom/kousei/framework/u3;

    .line 637
    .line 638
    const/4 v13, 0x1

    .line 639
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 640
    .line 641
    .line 642
    monitor-enter v7

    .line 643
    :try_start_282
    iget v0, v7, Lcom/kousei/framework/v3;->f:I
    :try_end_284
    .catchall {:try_start_282 .. :try_end_284} :catchall_2a7

    .line 644
    .line 645
    monitor-exit v7

    .line 646
    invoke-virtual {v7, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 647
    .line 648
    .line 649
    invoke-virtual {v7, v0}, Lcom/kousei/framework/v3;->m(I)Z

    .line 650
    .line 651
    .line 652
    move-result p0

    .line 653
    if-eqz p0, :cond_2a3

    .line 654
    .line 655
    invoke-virtual {v7}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 656
    .line 657
    .line 658
    move-result-object p0

    .line 659
    if-eq p0, v7, :cond_29d

    .line 660
    .line 661
    monitor-enter p0

    .line 662
    :try_start_295
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 663
    .line 664
    monitor-exit p0

    .line 665
    move-object v2, p0

    .line 666
    goto :goto_2a6

    .line 667
    :catchall_29a
    move-exception v0

    .line 668
    monitor-exit p0
    :try_end_29c
    .catchall {:try_start_295 .. :try_end_29c} :catchall_29a

    .line 669
    throw v0

    .line 670
    :cond_29d
    const-string p0, "implementation returned current curve"

    .line 671
    .line 672
    :goto_29f
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 673
    .line 674
    .line 675
    goto :goto_2a6

    .line 676
    :cond_2a3
    const-string p0, "unsupported coordinate system"

    .line 677
    .line 678
    goto :goto_29f

    .line 679
    :goto_2a6
    return-object v2

    .line 680
    :catchall_2a7
    move-exception v0

    .line 681
    move-object p0, v0

    .line 682
    :try_start_2a9
    monitor-exit v7
    :try_end_2aa
    .catchall {:try_start_2a9 .. :try_end_2aa} :catchall_2a7

    .line 683
    throw p0

    .line 684
    :pswitch_2ab
    const-string p0, "BDB6F4FE3E8B1D9E0DA8C0D46F4C318CEFE4AFE3B6B8551F"

    .line 685
    .line 686
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 687
    .line 688
    .line 689
    move-result-object v8

    .line 690
    const-string p0, "BB8E5E8FBC115E139FE6A814FE48AAA6F0ADA1AA5DF91985"

    .line 691
    .line 692
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 693
    .line 694
    .line 695
    move-result-object v9

    .line 696
    const-string p0, "1854BEBDC31B21B7AEFC80AB0ECD10D5B1B3308E6DBF11C1"

    .line 697
    .line 698
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 699
    .line 700
    .line 701
    move-result-object v10

    .line 702
    const-string p0, "BDB6F4FE3E8B1D9E0DA8C0D40FC962195DFAE76F56564677"

    .line 703
    .line 704
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 705
    .line 706
    .line 707
    move-result-object v11

    .line 708
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 709
    .line 710
    .line 711
    move-result-object v12

    .line 712
    new-instance v7, Lcom/kousei/framework/u3;

    .line 713
    .line 714
    const/4 v13, 0x1

    .line 715
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 716
    .line 717
    .line 718
    return-object v7

    .line 719
    :pswitch_2ce
    const-string p0, "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF"

    .line 720
    .line 721
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 722
    .line 723
    .line 724
    move-result-object v8

    .line 725
    const-string p0, "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC"

    .line 726
    .line 727
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 728
    .line 729
    .line 730
    move-result-object v9

    .line 731
    const-string p0, "28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93"

    .line 732
    .line 733
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 734
    .line 735
    .line 736
    move-result-object v10

    .line 737
    const-string p0, "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123"

    .line 738
    .line 739
    invoke-static {p0}, Lcom/kousei/framework/q4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 740
    .line 741
    .line 742
    move-result-object v11

    .line 743
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 744
    .line 745
    .line 746
    move-result-object v12

    .line 747
    new-instance v7, Lcom/kousei/framework/u3;

    .line 748
    .line 749
    const/4 v13, 0x1

    .line 750
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 751
    .line 752
    .line 753
    return-object v7

    .line 754
    :pswitch_2f1
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDC7"

    .line 755
    .line 756
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 757
    .line 758
    .line 759
    move-result-object v1

    .line 760
    const-string p0, "3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC98CDBA46506AB004C33A9FF5147502CC8EDA9E7A769A12694623CEF47F023ED"

    .line 761
    .line 762
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 763
    .line 764
    .line 765
    move-result-object v4

    .line 766
    new-instance v0, Lcom/kousei/framework/u3;

    .line 767
    .line 768
    const-string p0, "DC9203E514A721875485A529D2C722FB187BC8980EB866644DE41C68E143064546E861C0E2C9EDD92ADE71F46FCF50FF2AD97F951FDA9F2A2EB6546F39689BD3"

    .line 769
    .line 770
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 771
    .line 772
    .line 773
    move-result-object v2

    .line 774
    const-string p0, "B4C4EE28CEBC6C2C8AC12952CF37F16AC7EFB6A9F69F4B57FFDA2E4F0DE5ADE038CBC2FFF719D2C18DE0284B8BFEF3B52B8CC7A5F5BF0A3C8D2319A5312557E1"

    .line 775
    .line 776
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 777
    .line 778
    .line 779
    move-result-object v3

    .line 780
    sget-object v5, Lcom/kousei/framework/o3;->d:Ljava/math/BigInteger;

    .line 781
    .line 782
    const/4 v6, 0x1

    .line 783
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 784
    .line 785
    .line 786
    return-object v0

    .line 787
    :pswitch_312
    const-string p0, "8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006F"

    .line 788
    .line 789
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 790
    .line 791
    .line 792
    move-result-object v1

    .line 793
    const-string p0, "800000000000000000000000000000000000000000000000000000000000000149A1EC142565A545ACFDB77BD9D40CFA8B996712101BEA0EC6346C54374F25BD"

    .line 794
    .line 795
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 796
    .line 797
    .line 798
    move-result-object v4

    .line 799
    new-instance v0, Lcom/kousei/framework/u3;

    .line 800
    .line 801
    const-string p0, "8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006C"

    .line 802
    .line 803
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 804
    .line 805
    .line 806
    move-result-object v2

    .line 807
    const-string p0, "687D1B459DC841457E3E06CF6F5E2517B97C7D614AF138BCBF85DC806C4B289F3E965D2DB1416D217F8B276FAD1AB69C50F78BEE1FA3106EFB8CCBC7C5140116"

    .line 808
    .line 809
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 810
    .line 811
    .line 812
    move-result-object v3

    .line 813
    sget-object v5, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 814
    .line 815
    const/4 v6, 0x1

    .line 816
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 817
    .line 818
    .line 819
    return-object v0

    .line 820
    :pswitch_333
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDC7"

    .line 821
    .line 822
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 823
    .line 824
    .line 825
    move-result-object v1

    .line 826
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF27E69532F48D89116FF22B8D4E0560609B4B38ABFAD2B85DCACDB1411F10B275"

    .line 827
    .line 828
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 829
    .line 830
    .line 831
    move-result-object v4

    .line 832
    new-instance v0, Lcom/kousei/framework/u3;

    .line 833
    .line 834
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDC4"

    .line 835
    .line 836
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 837
    .line 838
    .line 839
    move-result-object v2

    .line 840
    const-string p0, "E8C2505DEDFC86DDC1BD0B2B6667F1DA34B82574761CB0E879BD081CFD0B6265EE3CB090F30D27614CB4574010DA90DD862EF9D4EBEE4761503190785A71C760"

    .line 841
    .line 842
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 843
    .line 844
    .line 845
    move-result-object v3

    .line 846
    sget-object v5, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 847
    .line 848
    const/4 v6, 0x1

    .line 849
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 850
    .line 851
    .line 852
    return-object v0

    .line 853
    :pswitch_354
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97"

    .line 854
    .line 855
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 856
    .line 857
    .line 858
    move-result-object v1

    .line 859
    const-string p0, "400000000000000000000000000000000FD8CDDFC87B6635C115AF556C360C67"

    .line 860
    .line 861
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 862
    .line 863
    .line 864
    move-result-object v4

    .line 865
    new-instance v0, Lcom/kousei/framework/u3;

    .line 866
    .line 867
    const-string p0, "C2173F1513981673AF4892C23035A27CE25E2013BF95AA33B22C656F277E7335"

    .line 868
    .line 869
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 870
    .line 871
    .line 872
    move-result-object v2

    .line 873
    const-string p0, "295F9BAE7428ED9CCC20E7C359A9D41A22FCCD9108E17BF7BA9337A6F8AE9513"

    .line 874
    .line 875
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 876
    .line 877
    .line 878
    move-result-object v3

    .line 879
    sget-object v5, Lcom/kousei/framework/o3;->d:Ljava/math/BigInteger;

    .line 880
    .line 881
    const/4 v6, 0x1

    .line 882
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 883
    .line 884
    .line 885
    return-object v0

    .line 886
    :pswitch_375
    const-string p0, "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D759B"

    .line 887
    .line 888
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 889
    .line 890
    .line 891
    move-result-object v1

    .line 892
    const-string p0, "9B9F605F5A858107AB1EC85E6B41C8AA582CA3511EDDFB74F02F3A6598980BB9"

    .line 893
    .line 894
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 895
    .line 896
    .line 897
    move-result-object v4

    .line 898
    new-instance v0, Lcom/kousei/framework/u3;

    .line 899
    .line 900
    const-string p0, "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D7598"

    .line 901
    .line 902
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 903
    .line 904
    .line 905
    move-result-object v2

    .line 906
    const-string p0, "805A"

    .line 907
    .line 908
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 909
    .line 910
    .line 911
    move-result-object v3

    .line 912
    sget-object v5, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 913
    .line 914
    const/4 v6, 0x1

    .line 915
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 916
    .line 917
    .line 918
    return-object v0

    .line 919
    :pswitch_396
    const-string p0, "8000000000000000000000000000000000000000000000000000000000000C99"

    .line 920
    .line 921
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 922
    .line 923
    .line 924
    move-result-object v1

    .line 925
    const-string p0, "800000000000000000000000000000015F700CFFF1A624E5E497161BCC8A198F"

    .line 926
    .line 927
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 928
    .line 929
    .line 930
    move-result-object v4

    .line 931
    new-instance v0, Lcom/kousei/framework/u3;

    .line 932
    .line 933
    const-string p0, "8000000000000000000000000000000000000000000000000000000000000C96"

    .line 934
    .line 935
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 936
    .line 937
    .line 938
    move-result-object v2

    .line 939
    const-string p0, "3E1AF419A269A5F866A7D3C25C3DF80AE979259373FF2B182F49D4CE7E1BBC8B"

    .line 940
    .line 941
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 942
    .line 943
    .line 944
    move-result-object v3

    .line 945
    sget-object v5, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 946
    .line 947
    const/4 v6, 0x1

    .line 948
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 949
    .line 950
    .line 951
    return-object v0

    .line 952
    :pswitch_3b7
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97"

    .line 953
    .line 954
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 955
    .line 956
    .line 957
    move-result-object v1

    .line 958
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893"

    .line 959
    .line 960
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 961
    .line 962
    .line 963
    move-result-object v4

    .line 964
    new-instance v0, Lcom/kousei/framework/u3;

    .line 965
    .line 966
    const-string p0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94"

    .line 967
    .line 968
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 969
    .line 970
    .line 971
    move-result-object v2

    .line 972
    const-string p0, "A6"

    .line 973
    .line 974
    invoke-static {p0}, Lcom/kousei/framework/b4;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 975
    .line 976
    .line 977
    move-result-object v3

    .line 978
    sget-object v5, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 979
    .line 980
    const/4 v6, 0x1

    .line 981
    invoke-direct/range {v0 .. v6}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 982
    .line 983
    .line 984
    return-object v0

    .line 985
    :pswitch_3d8
    new-instance p0, Lcom/kousei/framework/u8;

    .line 986
    .line 987
    invoke-direct {p0}, Lcom/kousei/framework/u8;-><init>()V

    .line 988
    .line 989
    .line 990
    return-object p0

    .line 991
    :pswitch_3de
    new-instance p0, Ljava/math/BigInteger;

    .line 992
    .line 993
    const-string v0, "fe0e87005b4e83761908c5131d552a850b3f58b749c37cf5b84d6768"

    .line 994
    .line 995
    invoke-direct {p0, v0, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 996
    .line 997
    .line 998
    new-instance v0, Ljava/math/BigInteger;

    .line 999
    .line 1000
    const-string v3, "60dcd2104c4cbc0be6eeefc2bdd610739ec34e317f9b33046c9e4788"

    .line 1001
    .line 1002
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1003
    .line 1004
    .line 1005
    new-instance v0, Ljava/math/BigInteger;

    .line 1006
    .line 1007
    const-string v3, "6b8cf07d4ca75c88957d9d670591"

    .line 1008
    .line 1009
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1010
    .line 1011
    .line 1012
    new-instance v4, Ljava/math/BigInteger;

    .line 1013
    .line 1014
    const-string v5, "-b8adf1378a6eb73409fa6c9c637d"

    .line 1015
    .line 1016
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1017
    .line 1018
    .line 1019
    filled-new-array {v0, v4}, [Ljava/math/BigInteger;

    .line 1020
    .line 1021
    .line 1022
    move-result-object v0

    .line 1023
    new-instance v4, Ljava/math/BigInteger;

    .line 1024
    .line 1025
    const-string v5, "1243ae1b4d71613bc9f780a03690e"

    .line 1026
    .line 1027
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1028
    .line 1029
    .line 1030
    new-instance v5, Ljava/math/BigInteger;

    .line 1031
    .line 1032
    invoke-direct {v5, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1033
    .line 1034
    .line 1035
    filled-new-array {v4, v5}, [Ljava/math/BigInteger;

    .line 1036
    .line 1037
    .line 1038
    move-result-object v3

    .line 1039
    new-instance v4, Ljava/math/BigInteger;

    .line 1040
    .line 1041
    const-string v5, "6b8cf07d4ca75c88957d9d67059037a4"

    .line 1042
    .line 1043
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1044
    .line 1045
    .line 1046
    new-instance v4, Ljava/math/BigInteger;

    .line 1047
    .line 1048
    const-string v5, "b8adf1378a6eb73409fa6c9c637ba7f5"

    .line 1049
    .line 1050
    invoke-direct {v4, v5, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 1051
    .line 1052
    .line 1053
    const-string v1, "v1"

    .line 1054
    .line 1055
    invoke-static {v0, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 1056
    .line 1057
    .line 1058
    const-string v0, "v2"

    .line 1059
    .line 1060
    invoke-static {v3, v0}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 1061
    .line 1062
    .line 1063
    new-instance v1, Lcom/kousei/framework/s8;

    .line 1064
    .line 1065
    invoke-direct {v1}, Lcom/kousei/framework/s8;-><init>()V

    .line 1066
    .line 1067
    .line 1068
    monitor-enter v1

    .line 1069
    :try_start_42c
    iget v0, v1, Lcom/kousei/framework/v3;->f:I
    :try_end_42e
    .catchall {:try_start_42c .. :try_end_42e} :catchall_451

    .line 1070
    .line 1071
    monitor-exit v1

    .line 1072
    invoke-virtual {v1, p0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 1073
    .line 1074
    .line 1075
    invoke-virtual {v1, v0}, Lcom/kousei/framework/v3;->m(I)Z

    .line 1076
    .line 1077
    .line 1078
    move-result p0

    .line 1079
    if-eqz p0, :cond_44d

    .line 1080
    .line 1081
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 1082
    .line 1083
    .line 1084
    move-result-object p0

    .line 1085
    if-eq p0, v1, :cond_447

    .line 1086
    .line 1087
    monitor-enter p0

    .line 1088
    :try_start_43f
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 1089
    .line 1090
    monitor-exit p0

    .line 1091
    move-object v2, p0

    .line 1092
    goto :goto_450

    .line 1093
    :catchall_444
    move-exception v0

    .line 1094
    monitor-exit p0
    :try_end_446
    .catchall {:try_start_43f .. :try_end_446} :catchall_444

    .line 1095
    throw v0

    .line 1096
    :cond_447
    const-string p0, "implementation returned current curve"

    .line 1097
    .line 1098
    :goto_449
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 1099
    .line 1100
    .line 1101
    goto :goto_450

    .line 1102
    :cond_44d
    const-string p0, "unsupported coordinate system"

    .line 1103
    .line 1104
    goto :goto_449

    .line 1105
    :goto_450
    return-object v2

    .line 1106
    :catchall_451
    move-exception v0

    .line 1107
    move-object p0, v0

    .line 1108
    :try_start_453
    monitor-exit v1
    :try_end_454
    .catchall {:try_start_453 .. :try_end_454} :catchall_451

    .line 1109
    throw p0

    .line 1110
    :pswitch_455
    new-instance p0, Lcom/kousei/framework/q8;

    .line 1111
    .line 1112
    invoke-direct {p0}, Lcom/kousei/framework/q8;-><init>()V

    .line 1113
    .line 1114
    .line 1115
    return-object p0

    .line 1116
    nop

    .line 1117
    :pswitch_data_45c
    .packed-switch 0x0
        :pswitch_455
        :pswitch_3de
        :pswitch_3d8
        :pswitch_3b7
        :pswitch_396
        :pswitch_375
        :pswitch_354
        :pswitch_333
        :pswitch_312
        :pswitch_2f1
        :pswitch_2ce
        :pswitch_2ab
        :pswitch_21b
        :pswitch_1f8
        :pswitch_1f3
        :pswitch_1d0
        :pswitch_1ad
        :pswitch_18a
        :pswitch_16a
        :pswitch_14a
        :pswitch_128
        :pswitch_106
        :pswitch_e3
        :pswitch_c6
        :pswitch_a5
        :pswitch_86
        :pswitch_66
        :pswitch_46
        :pswitch_2a
    .end packed-switch
.end method
