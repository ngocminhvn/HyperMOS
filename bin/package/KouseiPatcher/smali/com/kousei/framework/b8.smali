.class public final Lcom/kousei/framework/b8;
.super Lcom/kousei/framework/bb;


# instance fields
.field public final synthetic b:I


# direct methods
.method public synthetic constructor <init>(I)V
    .registers 2

    .line 1
    iput p1, p0, Lcom/kousei/framework/b8;->b:I

    .line 2
    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 4
    .line 5
    .line 6
    return-void
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 17

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget v0, v0, Lcom/kousei/framework/b8;->b:I

    .line 4
    .line 5
    const/16 v1, 0x10

    .line 6
    .line 7
    const/4 v2, 0x0

    .line 8
    const-wide/16 v3, 0x2

    .line 9
    .line 10
    const-wide/16 v5, 0x4

    .line 11
    .line 12
    const-wide/16 v7, 0x1

    .line 13
    .line 14
    packed-switch v0, :pswitch_data_4dc

    .line 15
    .line 16
    .line 17
    const-string v0, "03FFFFFFFFFFFFFFFFFFFE1AEE140F110AFF961309"

    .line 18
    .line 19
    invoke-static {v0}, Lcom/kousei/framework/ab;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 20
    .line 21
    .line 22
    move-result-object v12

    .line 23
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 24
    .line 25
    .line 26
    move-result-object v13

    .line 27
    new-instance v5, Lcom/kousei/framework/t3;

    .line 28
    .line 29
    const-string v0, "07A526C63D3E25A256A007699F5447E32AE456B50E"

    .line 30
    .line 31
    invoke-static {v0}, Lcom/kousei/framework/ab;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 32
    .line 33
    .line 34
    move-result-object v10

    .line 35
    const-string v0, "03F7061798EB99E238FD6F1BF95B48FEEB4854252B"

    .line 36
    .line 37
    invoke-static {v0}, Lcom/kousei/framework/ab;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 38
    .line 39
    .line 40
    move-result-object v11

    .line 41
    const/16 v6, 0xa3

    .line 42
    .line 43
    const/4 v7, 0x1

    .line 44
    const/4 v8, 0x2

    .line 45
    const/16 v9, 0x8

    .line 46
    .line 47
    invoke-direct/range {v5 .. v13}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 48
    .line 49
    .line 50
    return-object v5

    .line 51
    :pswitch_32
    const-string v0, "D35E472036BC4FB7E13C785ED201E065F98FCFA5B68F12A32D482EC7EE8658E98691555B44C59311"

    .line 52
    .line 53
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 54
    .line 55
    .line 56
    move-result-object v13

    .line 57
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 58
    .line 59
    .line 60
    move-result-object v14

    .line 61
    new-instance v9, Lcom/kousei/framework/u3;

    .line 62
    .line 63
    const-string v0, "D35E472036BC4FB7E13C785ED201E065F98FCFA6F6F40DEF4F92B9EC7893EC28FCD412B1F1B32E27"

    .line 64
    .line 65
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 66
    .line 67
    .line 68
    move-result-object v10

    .line 69
    const-string v0, "3EE30B568FBAB0F883CCEBD46D3F3BB8A2A73513F5EB79DA66190EB085FFA9F492F375A97D860EB4"

    .line 70
    .line 71
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 72
    .line 73
    .line 74
    move-result-object v11

    .line 75
    const-string v0, "520883949DFDBC42D3AD198640688A6FE13F41349554B49ACC31DCCD884539816F5EB4AC8FB1F1A6"

    .line 76
    .line 77
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 78
    .line 79
    .line 80
    move-result-object v12

    .line 81
    const/4 v15, 0x1

    .line 82
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 83
    .line 84
    .line 85
    return-object v9

    .line 86
    :pswitch_55
    const-string v0, "A9FB57DBA1EEA9BC3E660A909D838D718C397AA3B561A6F7901E0E82974856A7"

    .line 87
    .line 88
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 89
    .line 90
    .line 91
    move-result-object v13

    .line 92
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 93
    .line 94
    .line 95
    move-result-object v14

    .line 96
    new-instance v9, Lcom/kousei/framework/u3;

    .line 97
    .line 98
    const-string v0, "A9FB57DBA1EEA9BC3E660A909D838D726E3BF623D52620282013481D1F6E5377"

    .line 99
    .line 100
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 101
    .line 102
    .line 103
    move-result-object v10

    .line 104
    const-string v0, "A9FB57DBA1EEA9BC3E660A909D838D726E3BF623D52620282013481D1F6E5374"

    .line 105
    .line 106
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 107
    .line 108
    .line 109
    move-result-object v11

    .line 110
    const-string v0, "662C61C430D84EA4FE66A7733D0B76B7BF93EBC4AF2F49256AE58101FEE92B04"

    .line 111
    .line 112
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 113
    .line 114
    .line 115
    move-result-object v12

    .line 116
    const/4 v15, 0x1

    .line 117
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 118
    .line 119
    .line 120
    return-object v9

    .line 121
    :pswitch_78
    const-string v0, "A9FB57DBA1EEA9BC3E660A909D838D718C397AA3B561A6F7901E0E82974856A7"

    .line 122
    .line 123
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 124
    .line 125
    .line 126
    move-result-object v13

    .line 127
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 128
    .line 129
    .line 130
    move-result-object v14

    .line 131
    new-instance v9, Lcom/kousei/framework/u3;

    .line 132
    .line 133
    const-string v0, "A9FB57DBA1EEA9BC3E660A909D838D726E3BF623D52620282013481D1F6E5377"

    .line 134
    .line 135
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 136
    .line 137
    .line 138
    move-result-object v10

    .line 139
    const-string v0, "7D5A0975FC2C3057EEF67530417AFFE7FB8055C126DC5C6CE94A4B44F330B5D9"

    .line 140
    .line 141
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 142
    .line 143
    .line 144
    move-result-object v11

    .line 145
    const-string v0, "26DC5C6CE94A4B44F330B5D9BBD77CBF958416295CF7E1CE6BCCDC18FF8C07B6"

    .line 146
    .line 147
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 148
    .line 149
    .line 150
    move-result-object v12

    .line 151
    const/4 v15, 0x1

    .line 152
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 153
    .line 154
    .line 155
    return-object v9

    .line 156
    :pswitch_9b
    const-string v0, "D7C134AA264366862A18302575D0FB98D116BC4B6DDEBCA3A5A7939F"

    .line 157
    .line 158
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 159
    .line 160
    .line 161
    move-result-object v13

    .line 162
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 163
    .line 164
    .line 165
    move-result-object v14

    .line 166
    new-instance v9, Lcom/kousei/framework/u3;

    .line 167
    .line 168
    const-string v0, "D7C134AA264366862A18302575D1D787B09F075797DA89F57EC8C0FF"

    .line 169
    .line 170
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 171
    .line 172
    .line 173
    move-result-object v10

    .line 174
    const-string v0, "D7C134AA264366862A18302575D1D787B09F075797DA89F57EC8C0FC"

    .line 175
    .line 176
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 177
    .line 178
    .line 179
    move-result-object v11

    .line 180
    const-string v0, "4B337D934104CD7BEF271BF60CED1ED20DA14C08B3BB64F18A60888D"

    .line 181
    .line 182
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 183
    .line 184
    .line 185
    move-result-object v12

    .line 186
    const/4 v15, 0x1

    .line 187
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 188
    .line 189
    .line 190
    return-object v9

    .line 191
    :pswitch_be
    const-string v0, "D7C134AA264366862A18302575D0FB98D116BC4B6DDEBCA3A5A7939F"

    .line 192
    .line 193
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 194
    .line 195
    .line 196
    move-result-object v13

    .line 197
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 198
    .line 199
    .line 200
    move-result-object v14

    .line 201
    new-instance v9, Lcom/kousei/framework/u3;

    .line 202
    .line 203
    const-string v0, "D7C134AA264366862A18302575D1D787B09F075797DA89F57EC8C0FF"

    .line 204
    .line 205
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 206
    .line 207
    .line 208
    move-result-object v10

    .line 209
    const-string v0, "68A5E62CA9CE6C1C299803A6C1530B514E182AD8B0042A59CAD29F43"

    .line 210
    .line 211
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 212
    .line 213
    .line 214
    move-result-object v11

    .line 215
    const-string v0, "2580F63CCFE44138870713B1A92369E33E2135D266DBB372386C400B"

    .line 216
    .line 217
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 218
    .line 219
    .line 220
    move-result-object v12

    .line 221
    const/4 v15, 0x1

    .line 222
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 223
    .line 224
    .line 225
    return-object v9

    .line 226
    :pswitch_e1
    const-string v0, "C302F41D932A36CDA7A3462F9E9E916B5BE8F1029AC4ACC1"

    .line 227
    .line 228
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 229
    .line 230
    .line 231
    move-result-object v13

    .line 232
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 233
    .line 234
    .line 235
    move-result-object v14

    .line 236
    new-instance v9, Lcom/kousei/framework/u3;

    .line 237
    .line 238
    const-string v0, "C302F41D932A36CDA7A3463093D18DB78FCE476DE1A86297"

    .line 239
    .line 240
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 241
    .line 242
    .line 243
    move-result-object v10

    .line 244
    const-string v0, "C302F41D932A36CDA7A3463093D18DB78FCE476DE1A86294"

    .line 245
    .line 246
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 247
    .line 248
    .line 249
    move-result-object v11

    .line 250
    const-string v0, "13D56FFAEC78681E68F9DEB43B35BEC2FB68542E27897B79"

    .line 251
    .line 252
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 253
    .line 254
    .line 255
    move-result-object v12

    .line 256
    const/4 v15, 0x1

    .line 257
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 258
    .line 259
    .line 260
    return-object v9

    .line 261
    :pswitch_104
    const-string v0, "C302F41D932A36CDA7A3462F9E9E916B5BE8F1029AC4ACC1"

    .line 262
    .line 263
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 264
    .line 265
    .line 266
    move-result-object v13

    .line 267
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 268
    .line 269
    .line 270
    move-result-object v14

    .line 271
    new-instance v9, Lcom/kousei/framework/u3;

    .line 272
    .line 273
    const-string v0, "C302F41D932A36CDA7A3463093D18DB78FCE476DE1A86297"

    .line 274
    .line 275
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 276
    .line 277
    .line 278
    move-result-object v10

    .line 279
    const-string v0, "6A91174076B1E0E19C39C031FE8685C1CAE040E5C69A28EF"

    .line 280
    .line 281
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 282
    .line 283
    .line 284
    move-result-object v11

    .line 285
    const-string v0, "469A28EF7C28CCA3DC721D044F4496BCCA7EF4146FBF25C9"

    .line 286
    .line 287
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 288
    .line 289
    .line 290
    move-result-object v12

    .line 291
    const/4 v15, 0x1

    .line 292
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 293
    .line 294
    .line 295
    return-object v9

    .line 296
    :pswitch_127
    const-string v0, "E95E4A5F737059DC60DF5991D45029409E60FC09"

    .line 297
    .line 298
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 299
    .line 300
    .line 301
    move-result-object v13

    .line 302
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 303
    .line 304
    .line 305
    move-result-object v14

    .line 306
    new-instance v9, Lcom/kousei/framework/u3;

    .line 307
    .line 308
    const-string v0, "E95E4A5F737059DC60DFC7AD95B3D8139515620F"

    .line 309
    .line 310
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 311
    .line 312
    .line 313
    move-result-object v10

    .line 314
    const-string v0, "E95E4A5F737059DC60DFC7AD95B3D8139515620C"

    .line 315
    .line 316
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 317
    .line 318
    .line 319
    move-result-object v11

    .line 320
    const-string v0, "7A556B6DAE535B7B51ED2C4D7DAA7A0B5C55F380"

    .line 321
    .line 322
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 323
    .line 324
    .line 325
    move-result-object v12

    .line 326
    const/4 v15, 0x1

    .line 327
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 328
    .line 329
    .line 330
    return-object v9

    .line 331
    :pswitch_14a
    const-string v0, "E95E4A5F737059DC60DF5991D45029409E60FC09"

    .line 332
    .line 333
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 334
    .line 335
    .line 336
    move-result-object v13

    .line 337
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 338
    .line 339
    .line 340
    move-result-object v14

    .line 341
    new-instance v9, Lcom/kousei/framework/u3;

    .line 342
    .line 343
    const-string v0, "E95E4A5F737059DC60DFC7AD95B3D8139515620F"

    .line 344
    .line 345
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 346
    .line 347
    .line 348
    move-result-object v10

    .line 349
    const-string v0, "340E7BE2A280EB74E2BE61BADA745D97E8F7C300"

    .line 350
    .line 351
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 352
    .line 353
    .line 354
    move-result-object v11

    .line 355
    const-string v0, "1E589A8595423412134FAA2DBDEC95C8D8675E58"

    .line 356
    .line 357
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 358
    .line 359
    .line 360
    move-result-object v12

    .line 361
    const/4 v15, 0x1

    .line 362
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 363
    .line 364
    .line 365
    return-object v9

    .line 366
    :pswitch_16d
    const-string v0, "AADD9DB8DBE9C48B3FD4E6AE33C9FC07CB308DB3B3C9D20ED6639CCA70330870553E5C414CA92619418661197FAC10471DB1D381085DDADDB58796829CA90069"

    .line 367
    .line 368
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 369
    .line 370
    .line 371
    move-result-object v13

    .line 372
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 373
    .line 374
    .line 375
    move-result-object v14

    .line 376
    new-instance v9, Lcom/kousei/framework/u3;

    .line 377
    .line 378
    const-string v0, "AADD9DB8DBE9C48B3FD4E6AE33C9FC07CB308DB3B3C9D20ED6639CCA703308717D4D9B009BC66842AECDA12AE6A380E62881FF2F2D82C68528AA6056583A48F3"

    .line 379
    .line 380
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 381
    .line 382
    .line 383
    move-result-object v10

    .line 384
    const-string v0, "AADD9DB8DBE9C48B3FD4E6AE33C9FC07CB308DB3B3C9D20ED6639CCA703308717D4D9B009BC66842AECDA12AE6A380E62881FF2F2D82C68528AA6056583A48F0"

    .line 385
    .line 386
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 387
    .line 388
    .line 389
    move-result-object v11

    .line 390
    const-string v0, "7CBBBCF9441CFAB76E1890E46884EAE321F70C0BCB4981527897504BEC3E36A62BCDFA2304976540F6450085F2DAE145C22553B465763689180EA2571867423E"

    .line 391
    .line 392
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 393
    .line 394
    .line 395
    move-result-object v12

    .line 396
    const/4 v15, 0x1

    .line 397
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 398
    .line 399
    .line 400
    return-object v9

    .line 401
    :pswitch_190
    const-string v0, "AADD9DB8DBE9C48B3FD4E6AE33C9FC07CB308DB3B3C9D20ED6639CCA70330870553E5C414CA92619418661197FAC10471DB1D381085DDADDB58796829CA90069"

    .line 402
    .line 403
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 404
    .line 405
    .line 406
    move-result-object v13

    .line 407
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 408
    .line 409
    .line 410
    move-result-object v14

    .line 411
    new-instance v9, Lcom/kousei/framework/u3;

    .line 412
    .line 413
    const-string v0, "AADD9DB8DBE9C48B3FD4E6AE33C9FC07CB308DB3B3C9D20ED6639CCA703308717D4D9B009BC66842AECDA12AE6A380E62881FF2F2D82C68528AA6056583A48F3"

    .line 414
    .line 415
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 416
    .line 417
    .line 418
    move-result-object v10

    .line 419
    const-string v0, "7830A3318B603B89E2327145AC234CC594CBDD8D3DF91610A83441CAEA9863BC2DED5D5AA8253AA10A2EF1C98B9AC8B57F1117A72BF2C7B9E7C1AC4D77FC94CA"

    .line 420
    .line 421
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 422
    .line 423
    .line 424
    move-result-object v11

    .line 425
    const-string v0, "3DF91610A83441CAEA9863BC2DED5D5AA8253AA10A2EF1C98B9AC8B57F1117A72BF2C7B9E7C1AC4D77FC94CADC083E67984050B75EBAE5DD2809BD638016F723"

    .line 426
    .line 427
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 428
    .line 429
    .line 430
    move-result-object v12

    .line 431
    const/4 v15, 0x1

    .line 432
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 433
    .line 434
    .line 435
    return-object v9

    .line 436
    :pswitch_1b3
    const-string v0, "8CB91E82A3386D280F5D6F7E50E641DF152F7109ED5456B31F166E6CAC0425A7CF3AB6AF6B7FC3103B883202E9046565"

    .line 437
    .line 438
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 439
    .line 440
    .line 441
    move-result-object v13

    .line 442
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 443
    .line 444
    .line 445
    move-result-object v14

    .line 446
    new-instance v9, Lcom/kousei/framework/u3;

    .line 447
    .line 448
    const-string v0, "8CB91E82A3386D280F5D6F7E50E641DF152F7109ED5456B412B1DA197FB71123ACD3A729901D1A71874700133107EC53"

    .line 449
    .line 450
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 451
    .line 452
    .line 453
    move-result-object v10

    .line 454
    const-string v0, "8CB91E82A3386D280F5D6F7E50E641DF152F7109ED5456B412B1DA197FB71123ACD3A729901D1A71874700133107EC50"

    .line 455
    .line 456
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 457
    .line 458
    .line 459
    move-result-object v11

    .line 460
    const-string v0, "7F519EADA7BDA81BD826DBA647910F8C4B9346ED8CCDC64E4B1ABD11756DCE1D2074AA263B88805CED70355A33B471EE"

    .line 461
    .line 462
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 463
    .line 464
    .line 465
    move-result-object v12

    .line 466
    const/4 v15, 0x1

    .line 467
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 468
    .line 469
    .line 470
    return-object v9

    .line 471
    :pswitch_1d6
    const-string v0, "8CB91E82A3386D280F5D6F7E50E641DF152F7109ED5456B31F166E6CAC0425A7CF3AB6AF6B7FC3103B883202E9046565"

    .line 472
    .line 473
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 474
    .line 475
    .line 476
    move-result-object v13

    .line 477
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 478
    .line 479
    .line 480
    move-result-object v14

    .line 481
    new-instance v9, Lcom/kousei/framework/u3;

    .line 482
    .line 483
    const-string v0, "8CB91E82A3386D280F5D6F7E50E641DF152F7109ED5456B412B1DA197FB71123ACD3A729901D1A71874700133107EC53"

    .line 484
    .line 485
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 486
    .line 487
    .line 488
    move-result-object v10

    .line 489
    const-string v0, "7BC382C63D8C150C3C72080ACE05AFA0C2BEA28E4FB22787139165EFBA91F90F8AA5814A503AD4EB04A8C7DD22CE2826"

    .line 490
    .line 491
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 492
    .line 493
    .line 494
    move-result-object v11

    .line 495
    const-string v0, "04A8C7DD22CE28268B39B55416F0447C2FB77DE107DCD2A62E880EA53EEB62D57CB4390295DBC9943AB78696FA504C11"

    .line 496
    .line 497
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 498
    .line 499
    .line 500
    move-result-object v12

    .line 501
    const/4 v15, 0x1

    .line 502
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 503
    .line 504
    .line 505
    return-object v9

    .line 506
    :pswitch_1f9
    const-string v0, "D35E472036BC4FB7E13C785ED201E065F98FCFA5B68F12A32D482EC7EE8658E98691555B44C59311"

    .line 507
    .line 508
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 509
    .line 510
    .line 511
    move-result-object v13

    .line 512
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 513
    .line 514
    .line 515
    move-result-object v14

    .line 516
    new-instance v9, Lcom/kousei/framework/u3;

    .line 517
    .line 518
    const-string v0, "D35E472036BC4FB7E13C785ED201E065F98FCFA6F6F40DEF4F92B9EC7893EC28FCD412B1F1B32E27"

    .line 519
    .line 520
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 521
    .line 522
    .line 523
    move-result-object v10

    .line 524
    const-string v0, "D35E472036BC4FB7E13C785ED201E065F98FCFA6F6F40DEF4F92B9EC7893EC28FCD412B1F1B32E24"

    .line 525
    .line 526
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 527
    .line 528
    .line 529
    move-result-object v11

    .line 530
    const-string v0, "A7F561E038EB1ED560B3D147DB782013064C19F27ED27C6780AAF77FB8A547CEB5B4FEF422340353"

    .line 531
    .line 532
    invoke-static {v0}, Lcom/kousei/framework/na;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 533
    .line 534
    .line 535
    move-result-object v12

    .line 536
    const/4 v15, 0x1

    .line 537
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 538
    .line 539
    .line 540
    return-object v9

    .line 541
    :pswitch_21c
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFF"

    .line 542
    .line 543
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 544
    .line 545
    .line 546
    move-result-object v10

    .line 547
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFC"

    .line 548
    .line 549
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 550
    .line 551
    .line 552
    move-result-object v11

    .line 553
    const-string v0, "64210519E59C80E70FA7E9AB72243049FEB8DEECC146B9B1"

    .line 554
    .line 555
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 556
    .line 557
    .line 558
    move-result-object v12

    .line 559
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFF99DEF836146BC9B1B4D22831"

    .line 560
    .line 561
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 562
    .line 563
    .line 564
    move-result-object v13

    .line 565
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 566
    .line 567
    .line 568
    move-result-object v14

    .line 569
    new-instance v9, Lcom/kousei/framework/u3;

    .line 570
    .line 571
    const/4 v15, 0x1

    .line 572
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 573
    .line 574
    .line 575
    return-object v9

    .line 576
    :pswitch_23f
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFEE37"

    .line 577
    .line 578
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 579
    .line 580
    .line 581
    move-result-object v10

    .line 582
    sget-object v11, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 583
    .line 584
    const-wide/16 v3, 0x3

    .line 585
    .line 586
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 587
    .line 588
    .line 589
    move-result-object v12

    .line 590
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFE26F2FC170F69466A74DEFD8D"

    .line 591
    .line 592
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 593
    .line 594
    .line 595
    move-result-object v13

    .line 596
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 597
    .line 598
    .line 599
    move-result-object v14

    .line 600
    new-instance v0, Ljava/math/BigInteger;

    .line 601
    .line 602
    const-string v3, "bb85691939b869c1d087f601554b96b80cb4f55b35f433c2"

    .line 603
    .line 604
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 605
    .line 606
    .line 607
    new-instance v3, Ljava/math/BigInteger;

    .line 608
    .line 609
    const-string v4, "3d84f26c12238d7b4f3d516613c1759033b1a5800175d0b1"

    .line 610
    .line 611
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 612
    .line 613
    .line 614
    new-instance v3, Ljava/math/BigInteger;

    .line 615
    .line 616
    const-string v4, "71169be7330b3038edb025f1"

    .line 617
    .line 618
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 619
    .line 620
    .line 621
    new-instance v5, Ljava/math/BigInteger;

    .line 622
    .line 623
    const-string v6, "-b3fb3400dec5c4adceb8655c"

    .line 624
    .line 625
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 626
    .line 627
    .line 628
    filled-new-array {v3, v5}, [Ljava/math/BigInteger;

    .line 629
    .line 630
    .line 631
    move-result-object v3

    .line 632
    new-instance v5, Ljava/math/BigInteger;

    .line 633
    .line 634
    const-string v6, "12511cfe811d0f4e6bc688b4d"

    .line 635
    .line 636
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 637
    .line 638
    .line 639
    new-instance v6, Ljava/math/BigInteger;

    .line 640
    .line 641
    invoke-direct {v6, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 642
    .line 643
    .line 644
    filled-new-array {v5, v6}, [Ljava/math/BigInteger;

    .line 645
    .line 646
    .line 647
    move-result-object v4

    .line 648
    new-instance v5, Ljava/math/BigInteger;

    .line 649
    .line 650
    const-string v6, "71169be7330b3038edb025f1d0f9"

    .line 651
    .line 652
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 653
    .line 654
    .line 655
    new-instance v5, Ljava/math/BigInteger;

    .line 656
    .line 657
    const-string v6, "b3fb3400dec5c4adceb8655d4c94"

    .line 658
    .line 659
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 660
    .line 661
    .line 662
    const-string v1, "v1"

    .line 663
    .line 664
    invoke-static {v3, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 665
    .line 666
    .line 667
    const-string v1, "v2"

    .line 668
    .line 669
    invoke-static {v4, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 670
    .line 671
    .line 672
    new-instance v9, Lcom/kousei/framework/u3;

    .line 673
    .line 674
    const/4 v15, 0x1

    .line 675
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 676
    .line 677
    .line 678
    monitor-enter v9

    .line 679
    :try_start_2a6
    iget v1, v9, Lcom/kousei/framework/v3;->f:I
    :try_end_2a8
    .catchall {:try_start_2a6 .. :try_end_2a8} :catchall_2cb

    .line 680
    .line 681
    monitor-exit v9

    .line 682
    invoke-virtual {v9, v0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 683
    .line 684
    .line 685
    invoke-virtual {v9, v1}, Lcom/kousei/framework/v3;->m(I)Z

    .line 686
    .line 687
    .line 688
    move-result v0

    .line 689
    if-eqz v0, :cond_2c7

    .line 690
    .line 691
    invoke-virtual {v9}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 692
    .line 693
    .line 694
    move-result-object v3

    .line 695
    if-eq v3, v9, :cond_2c1

    .line 696
    .line 697
    monitor-enter v3

    .line 698
    :try_start_2b9
    iput v1, v3, Lcom/kousei/framework/v3;->f:I

    .line 699
    .line 700
    monitor-exit v3

    .line 701
    move-object v2, v3

    .line 702
    goto :goto_2ca

    .line 703
    :catchall_2be
    move-exception v0

    .line 704
    monitor-exit v3
    :try_end_2c0
    .catchall {:try_start_2b9 .. :try_end_2c0} :catchall_2be

    .line 705
    throw v0

    .line 706
    :cond_2c1
    const-string v0, "implementation returned current curve"

    .line 707
    .line 708
    :goto_2c3
    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 709
    .line 710
    .line 711
    goto :goto_2ca

    .line 712
    :cond_2c7
    const-string v0, "unsupported coordinate system"

    .line 713
    .line 714
    goto :goto_2c3

    .line 715
    :goto_2ca
    return-object v2

    .line 716
    :catchall_2cb
    move-exception v0

    .line 717
    :try_start_2cc
    monitor-exit v9
    :try_end_2cd
    .catchall {:try_start_2cc .. :try_end_2cd} :catchall_2cb

    .line 718
    throw v0

    .line 719
    :pswitch_2ce
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFAC73"

    .line 720
    .line 721
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 722
    .line 723
    .line 724
    move-result-object v10

    .line 725
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFAC70"

    .line 726
    .line 727
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 728
    .line 729
    .line 730
    move-result-object v11

    .line 731
    const-string v0, "B4E134D3FB59EB8BAB57274904664D5AF50388BA"

    .line 732
    .line 733
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 734
    .line 735
    .line 736
    move-result-object v12

    .line 737
    const-string v0, "0100000000000000000000351EE786A818F3A1A16B"

    .line 738
    .line 739
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 740
    .line 741
    .line 742
    move-result-object v13

    .line 743
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 744
    .line 745
    .line 746
    move-result-object v14

    .line 747
    new-instance v9, Lcom/kousei/framework/u3;

    .line 748
    .line 749
    const/4 v15, 0x1

    .line 750
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 751
    .line 752
    .line 753
    return-object v9

    .line 754
    :pswitch_2f1
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFF"

    .line 755
    .line 756
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 757
    .line 758
    .line 759
    move-result-object v10

    .line 760
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFC"

    .line 761
    .line 762
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 763
    .line 764
    .line 765
    move-result-object v11

    .line 766
    const-string v0, "1C97BEFC54BD7A8B65ACF89F81D4D4ADC565FA45"

    .line 767
    .line 768
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 769
    .line 770
    .line 771
    move-result-object v12

    .line 772
    const-string v0, "0100000000000000000001F4C8F927AED3CA752257"

    .line 773
    .line 774
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 775
    .line 776
    .line 777
    move-result-object v13

    .line 778
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 779
    .line 780
    .line 781
    move-result-object v14

    .line 782
    new-instance v9, Lcom/kousei/framework/u3;

    .line 783
    .line 784
    const/4 v15, 0x1

    .line 785
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 786
    .line 787
    .line 788
    return-object v9

    .line 789
    :pswitch_314
    const-string v0, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFAC73"

    .line 790
    .line 791
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 792
    .line 793
    .line 794
    move-result-object v10

    .line 795
    sget-object v11, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 796
    .line 797
    const-wide/16 v3, 0x7

    .line 798
    .line 799
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 800
    .line 801
    .line 802
    move-result-object v12

    .line 803
    const-string v0, "0100000000000000000001B8FA16DFAB9ACA16B6B3"

    .line 804
    .line 805
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 806
    .line 807
    .line 808
    move-result-object v13

    .line 809
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 810
    .line 811
    .line 812
    move-result-object v14

    .line 813
    new-instance v0, Ljava/math/BigInteger;

    .line 814
    .line 815
    const-string v3, "9ba48cba5ebcb9b6bd33b92830b2a2e0e192f10a"

    .line 816
    .line 817
    invoke-direct {v0, v3, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 818
    .line 819
    .line 820
    new-instance v3, Ljava/math/BigInteger;

    .line 821
    .line 822
    const-string v4, "c39c6c3b3a36d7701b9c71a1f5804ae5d0003f4"

    .line 823
    .line 824
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 825
    .line 826
    .line 827
    new-instance v3, Ljava/math/BigInteger;

    .line 828
    .line 829
    const-string v4, "9162fbe73984472a0a9e"

    .line 830
    .line 831
    invoke-direct {v3, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 832
    .line 833
    .line 834
    new-instance v5, Ljava/math/BigInteger;

    .line 835
    .line 836
    const-string v6, "-96341f1138933bc2f505"

    .line 837
    .line 838
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 839
    .line 840
    .line 841
    filled-new-array {v3, v5}, [Ljava/math/BigInteger;

    .line 842
    .line 843
    .line 844
    move-result-object v3

    .line 845
    new-instance v5, Ljava/math/BigInteger;

    .line 846
    .line 847
    const-string v6, "127971af8721782ecffa3"

    .line 848
    .line 849
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 850
    .line 851
    .line 852
    new-instance v6, Ljava/math/BigInteger;

    .line 853
    .line 854
    invoke-direct {v6, v4, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 855
    .line 856
    .line 857
    filled-new-array {v5, v6}, [Ljava/math/BigInteger;

    .line 858
    .line 859
    .line 860
    move-result-object v4

    .line 861
    new-instance v5, Ljava/math/BigInteger;

    .line 862
    .line 863
    const-string v6, "9162fbe73984472a0a9d0590"

    .line 864
    .line 865
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 866
    .line 867
    .line 868
    new-instance v5, Ljava/math/BigInteger;

    .line 869
    .line 870
    const-string v6, "96341f1138933bc2f503fd44"

    .line 871
    .line 872
    invoke-direct {v5, v6, v1}, Ljava/math/BigInteger;-><init>(Ljava/lang/String;I)V

    .line 873
    .line 874
    .line 875
    const-string v1, "v1"

    .line 876
    .line 877
    invoke-static {v3, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 878
    .line 879
    .line 880
    const-string v1, "v2"

    .line 881
    .line 882
    invoke-static {v4, v1}, Lcom/kousei/framework/n6;->r([Ljava/math/BigInteger;Ljava/lang/String;)V

    .line 883
    .line 884
    .line 885
    new-instance v9, Lcom/kousei/framework/u3;

    .line 886
    .line 887
    const/4 v15, 0x1

    .line 888
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 889
    .line 890
    .line 891
    monitor-enter v9

    .line 892
    :try_start_37b
    iget v1, v9, Lcom/kousei/framework/v3;->f:I
    :try_end_37d
    .catchall {:try_start_37b .. :try_end_37d} :catchall_3a0

    .line 893
    .line 894
    monitor-exit v9

    .line 895
    invoke-virtual {v9, v0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 896
    .line 897
    .line 898
    invoke-virtual {v9, v1}, Lcom/kousei/framework/v3;->m(I)Z

    .line 899
    .line 900
    .line 901
    move-result v0

    .line 902
    if-eqz v0, :cond_39c

    .line 903
    .line 904
    invoke-virtual {v9}, Lcom/kousei/framework/v3;->a()Lcom/kousei/framework/v3;

    .line 905
    .line 906
    .line 907
    move-result-object v3

    .line 908
    if-eq v3, v9, :cond_396

    .line 909
    .line 910
    monitor-enter v3

    .line 911
    :try_start_38e
    iput v1, v3, Lcom/kousei/framework/v3;->f:I

    .line 912
    .line 913
    monitor-exit v3

    .line 914
    move-object v2, v3

    .line 915
    goto :goto_39f

    .line 916
    :catchall_393
    move-exception v0

    .line 917
    monitor-exit v3
    :try_end_395
    .catchall {:try_start_38e .. :try_end_395} :catchall_393

    .line 918
    throw v0

    .line 919
    :cond_396
    const-string v0, "implementation returned current curve"

    .line 920
    .line 921
    :goto_398
    invoke-static {v0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 922
    .line 923
    .line 924
    goto :goto_39f

    .line 925
    :cond_39c
    const-string v0, "unsupported coordinate system"

    .line 926
    .line 927
    goto :goto_398

    .line 928
    :goto_39f
    return-object v2

    .line 929
    :catchall_3a0
    move-exception v0

    .line 930
    :try_start_3a1
    monitor-exit v9
    :try_end_3a2
    .catchall {:try_start_3a1 .. :try_end_3a2} :catchall_3a0

    .line 931
    throw v0

    .line 932
    :pswitch_3a3
    const-string v0, "FFFFFFFDFFFFFFFFFFFFFFFFFFFFFFFF"

    .line 933
    .line 934
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 935
    .line 936
    .line 937
    move-result-object v8

    .line 938
    const-string v0, "D6031998D1B3BBFEBF59CC9BBFF9AEE1"

    .line 939
    .line 940
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 941
    .line 942
    .line 943
    move-result-object v9

    .line 944
    const-string v0, "5EEEFCA380D02919DC2C6558BB6D8A5D"

    .line 945
    .line 946
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 947
    .line 948
    .line 949
    move-result-object v10

    .line 950
    const-string v0, "3FFFFFFF7FFFFFFFBE0024720613B5A3"

    .line 951
    .line 952
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 953
    .line 954
    .line 955
    move-result-object v11

    .line 956
    invoke-static {v5, v6}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 957
    .line 958
    .line 959
    move-result-object v12

    .line 960
    new-instance v7, Lcom/kousei/framework/u3;

    .line 961
    .line 962
    const/4 v13, 0x1

    .line 963
    invoke-direct/range {v7 .. v13}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 964
    .line 965
    .line 966
    return-object v7

    .line 967
    :pswitch_3c6
    const-string v0, "FFFFFFFDFFFFFFFFFFFFFFFFFFFFFFFF"

    .line 968
    .line 969
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 970
    .line 971
    .line 972
    move-result-object v10

    .line 973
    const-string v0, "FFFFFFFDFFFFFFFFFFFFFFFFFFFFFFFC"

    .line 974
    .line 975
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 976
    .line 977
    .line 978
    move-result-object v11

    .line 979
    const-string v0, "E87579C11079F43DD824993C2CEE5ED3"

    .line 980
    .line 981
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 982
    .line 983
    .line 984
    move-result-object v12

    .line 985
    const-string v0, "FFFFFFFE0000000075A30D1B9038A115"

    .line 986
    .line 987
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 988
    .line 989
    .line 990
    move-result-object v13

    .line 991
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 992
    .line 993
    .line 994
    move-result-object v14

    .line 995
    new-instance v9, Lcom/kousei/framework/u3;

    .line 996
    .line 997
    const/4 v15, 0x1

    .line 998
    invoke-direct/range {v9 .. v15}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 999
    .line 1000
    .line 1001
    return-object v9

    .line 1002
    :pswitch_3e9
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1003
    .line 1004
    .line 1005
    move-result-object v5

    .line 1006
    const-string v0, "02F40E7E2221F295DE297117B7F3D62F5C6A97FFCB8CEFF1CD6BA8CE4A9A18AD84FFABBD8EFA59332BE7AD6756A66E294AFD185A78FF12AA520E4DE739BACA0C7FFEFF7F2955727A"

    .line 1007
    .line 1008
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1009
    .line 1010
    .line 1011
    move-result-object v6

    .line 1012
    const-string v0, "03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE661CE18FF55987308059B186823851EC7DD9CA1161DE93D5174D66E8382E9BB2FE84E47"

    .line 1013
    .line 1014
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1015
    .line 1016
    .line 1017
    move-result-object v7

    .line 1018
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1019
    .line 1020
    .line 1021
    move-result-object v8

    .line 1022
    new-instance v0, Lcom/kousei/framework/t3;

    .line 1023
    .line 1024
    const/16 v1, 0x23b

    .line 1025
    .line 1026
    const/4 v2, 0x2

    .line 1027
    const/4 v3, 0x5

    .line 1028
    const/16 v4, 0xa

    .line 1029
    .line 1030
    invoke-direct/range {v0 .. v8}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1031
    .line 1032
    .line 1033
    return-object v0

    .line 1034
    :pswitch_409
    move-wide v0, v5

    .line 1035
    sget-object v6, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 1036
    .line 1037
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1038
    .line 1039
    .line 1040
    move-result-object v7

    .line 1041
    const-string v2, "020000000000000000000000000000000000000000000000000000000000000000000000131850E1F19A63E4B391A8DB917F4138B630D84BE5D639381E91DEB45CFE778F637C1001"

    .line 1042
    .line 1043
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1044
    .line 1045
    .line 1046
    move-result-object v8

    .line 1047
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1048
    .line 1049
    .line 1050
    move-result-object v9

    .line 1051
    new-instance v1, Lcom/kousei/framework/t3;

    .line 1052
    .line 1053
    const/16 v2, 0x23b

    .line 1054
    .line 1055
    const/4 v3, 0x2

    .line 1056
    const/4 v4, 0x5

    .line 1057
    const/16 v5, 0xa

    .line 1058
    .line 1059
    invoke-direct/range {v1 .. v9}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1060
    .line 1061
    .line 1062
    return-object v1

    .line 1063
    :pswitch_426
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1064
    .line 1065
    .line 1066
    move-result-object v5

    .line 1067
    const-string v0, "0021A5C2C8EE9FEB5C4B9A753B7B476B7FD6422EF1F3DD674761FA99D6AC27C8A9A197B272822F6CD57A55AA4F50AE317B13545F"

    .line 1068
    .line 1069
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1070
    .line 1071
    .line 1072
    move-result-object v6

    .line 1073
    const-string v0, "010000000000000000000000000000000000000000000000000001E2AAD6A612F33307BE5FA47C3C9E052F838164CD37D9A21173"

    .line 1074
    .line 1075
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1076
    .line 1077
    .line 1078
    move-result-object v7

    .line 1079
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1080
    .line 1081
    .line 1082
    move-result-object v8

    .line 1083
    new-instance v2, Lcom/kousei/framework/t3;

    .line 1084
    .line 1085
    const/16 v3, 0x199

    .line 1086
    .line 1087
    const/16 v4, 0x57

    .line 1088
    .line 1089
    invoke-direct/range {v2 .. v8}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1090
    .line 1091
    .line 1092
    return-object v2

    .line 1093
    :pswitch_444
    move-wide v0, v5

    .line 1094
    sget-object v6, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 1095
    .line 1096
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1097
    .line 1098
    .line 1099
    move-result-object v7

    .line 1100
    const-string v2, "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE5F83B2D4EA20400EC4557D5ED3E3E7CA5B4B5C83B8E01E5FCF"

    .line 1101
    .line 1102
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1103
    .line 1104
    .line 1105
    move-result-object v8

    .line 1106
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1107
    .line 1108
    .line 1109
    move-result-object v9

    .line 1110
    new-instance v3, Lcom/kousei/framework/t3;

    .line 1111
    .line 1112
    const/16 v4, 0x199

    .line 1113
    .line 1114
    const/16 v5, 0x57

    .line 1115
    .line 1116
    invoke-direct/range {v3 .. v9}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1117
    .line 1118
    .line 1119
    return-object v3

    .line 1120
    :pswitch_45f
    move-wide v0, v5

    .line 1121
    const-string v2, "DB7C2ABF62E35E668076BEAD208B"

    .line 1122
    .line 1123
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1124
    .line 1125
    .line 1126
    move-result-object v4

    .line 1127
    const-string v2, "6127C24C05F38A0AAAF65C0EF02C"

    .line 1128
    .line 1129
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1130
    .line 1131
    .line 1132
    move-result-object v5

    .line 1133
    const-string v2, "51DEF1815DB5ED74FCC34C85D709"

    .line 1134
    .line 1135
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1136
    .line 1137
    .line 1138
    move-result-object v6

    .line 1139
    const-string v2, "36DF0AAFD8B8D7597CA10520D04B"

    .line 1140
    .line 1141
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1142
    .line 1143
    .line 1144
    move-result-object v7

    .line 1145
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1146
    .line 1147
    .line 1148
    move-result-object v8

    .line 1149
    new-instance v3, Lcom/kousei/framework/u3;

    .line 1150
    .line 1151
    const/4 v9, 0x1

    .line 1152
    invoke-direct/range {v3 .. v9}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 1153
    .line 1154
    .line 1155
    return-object v3

    .line 1156
    :pswitch_483
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1157
    .line 1158
    .line 1159
    move-result-object v9

    .line 1160
    const-string v0, "027B680AC8B8596DA5A4AF8A19A0303FCA97FD7645309FA2A581485AF6263E313B79A2F5"

    .line 1161
    .line 1162
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1163
    .line 1164
    .line 1165
    move-result-object v10

    .line 1166
    const-string v0, "03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEF90399660FC938A90165B042A7CEFADB307"

    .line 1167
    .line 1168
    invoke-static {v0}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1169
    .line 1170
    .line 1171
    move-result-object v11

    .line 1172
    invoke-static {v3, v4}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1173
    .line 1174
    .line 1175
    move-result-object v12

    .line 1176
    new-instance v4, Lcom/kousei/framework/t3;

    .line 1177
    .line 1178
    const/16 v5, 0x11b

    .line 1179
    .line 1180
    const/4 v6, 0x5

    .line 1181
    const/4 v7, 0x7

    .line 1182
    const/16 v8, 0xc

    .line 1183
    .line 1184
    invoke-direct/range {v4 .. v12}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1185
    .line 1186
    .line 1187
    return-object v4

    .line 1188
    :pswitch_4a3
    move-wide v0, v5

    .line 1189
    sget-object v10, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 1190
    .line 1191
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1192
    .line 1193
    .line 1194
    move-result-object v11

    .line 1195
    const-string v2, "01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9AE2ED07577265DFF7F94451E061E163C61"

    .line 1196
    .line 1197
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1198
    .line 1199
    .line 1200
    move-result-object v12

    .line 1201
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1202
    .line 1203
    .line 1204
    move-result-object v13

    .line 1205
    new-instance v5, Lcom/kousei/framework/t3;

    .line 1206
    .line 1207
    const/16 v6, 0x11b

    .line 1208
    .line 1209
    const/4 v7, 0x5

    .line 1210
    const/4 v8, 0x7

    .line 1211
    const/16 v9, 0xc

    .line 1212
    .line 1213
    invoke-direct/range {v5 .. v13}, Lcom/kousei/framework/t3;-><init>(IIIILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1214
    .line 1215
    .line 1216
    return-object v5

    .line 1217
    :pswitch_4c0
    move-wide v0, v5

    .line 1218
    sget-object v9, Lcom/kousei/framework/o3;->a:Ljava/math/BigInteger;

    .line 1219
    .line 1220
    invoke-static {v7, v8}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1221
    .line 1222
    .line 1223
    move-result-object v10

    .line 1224
    const-string v2, "2000000000000000000000000000005A79FEC67CB6E91F1C1DA800E478A5"

    .line 1225
    .line 1226
    invoke-static {v2}, Lcom/kousei/framework/c8;->a(Ljava/lang/String;)Ljava/math/BigInteger;

    .line 1227
    .line 1228
    .line 1229
    move-result-object v11

    .line 1230
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 1231
    .line 1232
    .line 1233
    move-result-object v12

    .line 1234
    new-instance v6, Lcom/kousei/framework/t3;

    .line 1235
    .line 1236
    const/16 v7, 0xef

    .line 1237
    .line 1238
    const/16 v8, 0x9e

    .line 1239
    .line 1240
    invoke-direct/range {v6 .. v12}, Lcom/kousei/framework/t3;-><init>(IILjava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 1241
    .line 1242
    .line 1243
    return-object v6

    .line 1244
    nop

    .line 1245
    :pswitch_data_4dc
    .packed-switch 0x0
        :pswitch_4c0
        :pswitch_4a3
        :pswitch_483
        :pswitch_45f
        :pswitch_444
        :pswitch_426
        :pswitch_409
        :pswitch_3e9
        :pswitch_3c6
        :pswitch_3a3
        :pswitch_314
        :pswitch_2f1
        :pswitch_2ce
        :pswitch_23f
        :pswitch_21c
        :pswitch_1f9
        :pswitch_1d6
        :pswitch_1b3
        :pswitch_190
        :pswitch_16d
        :pswitch_14a
        :pswitch_127
        :pswitch_104
        :pswitch_e1
        :pswitch_be
        :pswitch_9b
        :pswitch_78
        :pswitch_55
        :pswitch_32
    .end packed-switch
.end method
