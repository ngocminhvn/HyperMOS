.class public abstract Lcom/kousei/framework/n3;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/HashMap;


# direct methods
.method static constructor <clinit>()V
    .registers 9

    .line 1
    new-instance v0, Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 4
    .line 5
    .line 6
    sget-object v1, Lcom/kousei/framework/d2;->e:Ljava/util/Vector;

    .line 7
    .line 8
    invoke-virtual {v1}, Ljava/util/Vector;->elements()Ljava/util/Enumeration;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    :cond_b
    :goto_b
    invoke-interface {v1}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 13
    .line 14
    .line 15
    move-result v2

    .line 16
    if-eqz v2, :cond_ee

    .line 17
    .line 18
    invoke-interface {v1}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 19
    .line 20
    .line 21
    move-result-object v2

    .line 22
    check-cast v2, Ljava/lang/String;

    .line 23
    .line 24
    sget-object v3, Lcom/kousei/framework/ab;->a:Ljava/util/Hashtable;

    .line 25
    .line 26
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 27
    .line 28
    .line 29
    move-result-object v4

    .line 30
    invoke-virtual {v3, v4}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 31
    .line 32
    .line 33
    move-result-object v3

    .line 34
    check-cast v3, Lcom/kousei/framework/u;

    .line 35
    .line 36
    const/4 v4, 0x0

    .line 37
    if-nez v3, :cond_28

    .line 38
    .line 39
    move-object v3, v4

    .line 40
    goto :goto_30

    .line 41
    :cond_28
    sget-object v5, Lcom/kousei/framework/ab;->b:Ljava/util/Hashtable;

    .line 42
    .line 43
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 44
    .line 45
    .line 46
    move-result-object v3

    .line 47
    check-cast v3, Lcom/kousei/framework/bb;

    .line 48
    .line 49
    :goto_30
    if-nez v3, :cond_4a

    .line 50
    .line 51
    sget-object v3, Lcom/kousei/framework/c8;->a:Ljava/util/Hashtable;

    .line 52
    .line 53
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v5

    .line 57
    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 58
    .line 59
    .line 60
    move-result-object v3

    .line 61
    check-cast v3, Lcom/kousei/framework/u;

    .line 62
    .line 63
    if-nez v3, :cond_42

    .line 64
    .line 65
    move-object v3, v4

    .line 66
    goto :goto_4a

    .line 67
    :cond_42
    sget-object v5, Lcom/kousei/framework/c8;->b:Ljava/util/Hashtable;

    .line 68
    .line 69
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 70
    .line 71
    .line 72
    move-result-object v3

    .line 73
    check-cast v3, Lcom/kousei/framework/bb;

    .line 74
    .line 75
    :cond_4a
    :goto_4a
    if-nez v3, :cond_64

    .line 76
    .line 77
    sget-object v3, Lcom/kousei/framework/k6;->a:Ljava/util/Hashtable;

    .line 78
    .line 79
    invoke-static {v2}, Lcom/kousei/framework/ja;->e(Ljava/lang/String;)Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object v5

    .line 83
    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 84
    .line 85
    .line 86
    move-result-object v3

    .line 87
    check-cast v3, Lcom/kousei/framework/u;

    .line 88
    .line 89
    if-eqz v3, :cond_63

    .line 90
    .line 91
    sget-object v5, Lcom/kousei/framework/c8;->b:Ljava/util/Hashtable;

    .line 92
    .line 93
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 94
    .line 95
    .line 96
    move-result-object v3

    .line 97
    check-cast v3, Lcom/kousei/framework/bb;

    .line 98
    .line 99
    goto :goto_64

    .line 100
    :cond_63
    move-object v3, v4

    .line 101
    :cond_64
    :goto_64
    if-nez v3, :cond_7e

    .line 102
    .line 103
    sget-object v3, Lcom/kousei/framework/na;->a:Ljava/util/Hashtable;

    .line 104
    .line 105
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 106
    .line 107
    .line 108
    move-result-object v5

    .line 109
    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 110
    .line 111
    .line 112
    move-result-object v3

    .line 113
    check-cast v3, Lcom/kousei/framework/u;

    .line 114
    .line 115
    if-nez v3, :cond_76

    .line 116
    .line 117
    move-object v3, v4

    .line 118
    goto :goto_7e

    .line 119
    :cond_76
    sget-object v5, Lcom/kousei/framework/na;->b:Ljava/util/Hashtable;

    .line 120
    .line 121
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 122
    .line 123
    .line 124
    move-result-object v3

    .line 125
    check-cast v3, Lcom/kousei/framework/bb;

    .line 126
    .line 127
    :cond_7e
    :goto_7e
    if-nez v3, :cond_98

    .line 128
    .line 129
    sget-object v3, Lcom/kousei/framework/b;->a:Ljava/util/Hashtable;

    .line 130
    .line 131
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 132
    .line 133
    .line 134
    move-result-object v5

    .line 135
    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    .line 137
    .line 138
    move-result-object v3

    .line 139
    check-cast v3, Lcom/kousei/framework/u;

    .line 140
    .line 141
    if-nez v3, :cond_90

    .line 142
    .line 143
    move-object v3, v4

    .line 144
    goto :goto_98

    .line 145
    :cond_90
    sget-object v5, Lcom/kousei/framework/b;->b:Ljava/util/Hashtable;

    .line 146
    .line 147
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 148
    .line 149
    .line 150
    move-result-object v3

    .line 151
    check-cast v3, Lcom/kousei/framework/bb;

    .line 152
    .line 153
    :cond_98
    :goto_98
    if-nez v3, :cond_ae

    .line 154
    .line 155
    sget-object v3, Lcom/kousei/framework/b4;->a:Ljava/util/Hashtable;

    .line 156
    .line 157
    invoke-virtual {v3, v2}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 158
    .line 159
    .line 160
    move-result-object v3

    .line 161
    check-cast v3, Lcom/kousei/framework/u;

    .line 162
    .line 163
    if-nez v3, :cond_a6

    .line 164
    .line 165
    move-object v3, v4

    .line 166
    goto :goto_ae

    .line 167
    :cond_a6
    sget-object v5, Lcom/kousei/framework/b4;->b:Ljava/util/Hashtable;

    .line 168
    .line 169
    invoke-virtual {v5, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 170
    .line 171
    .line 172
    move-result-object v3

    .line 173
    check-cast v3, Lcom/kousei/framework/bb;

    .line 174
    .line 175
    :cond_ae
    :goto_ae
    if-nez v3, :cond_c9

    .line 176
    .line 177
    sget-object v3, Lcom/kousei/framework/q4;->a:Ljava/util/Hashtable;

    .line 178
    .line 179
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 180
    .line 181
    .line 182
    move-result-object v5

    .line 183
    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 184
    .line 185
    .line 186
    move-result-object v3

    .line 187
    check-cast v3, Lcom/kousei/framework/u;

    .line 188
    .line 189
    if-nez v3, :cond_bf

    .line 190
    .line 191
    goto :goto_ca

    .line 192
    :cond_bf
    sget-object v4, Lcom/kousei/framework/q4;->b:Ljava/util/Hashtable;

    .line 193
    .line 194
    invoke-virtual {v4, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 195
    .line 196
    .line 197
    move-result-object v3

    .line 198
    move-object v4, v3

    .line 199
    check-cast v4, Lcom/kousei/framework/bb;

    .line 200
    .line 201
    goto :goto_ca

    .line 202
    :cond_c9
    move-object v4, v3

    .line 203
    :goto_ca
    if-eqz v4, :cond_b

    .line 204
    .line 205
    invoke-virtual {v4}, Lcom/kousei/framework/bb;->b()Lcom/kousei/framework/v3;

    .line 206
    .line 207
    .line 208
    move-result-object v3

    .line 209
    iget-object v4, v3, Lcom/kousei/framework/v3;->a:Lcom/kousei/framework/l4;

    .line 210
    .line 211
    invoke-interface {v4}, Lcom/kousei/framework/l4;->a()I

    .line 212
    .line 213
    .line 214
    move-result v4

    .line 215
    const/4 v5, 0x1

    .line 216
    if-ne v4, v5, :cond_b

    .line 217
    .line 218
    sget-object v4, Lcom/kousei/framework/d2;->a:Ljava/util/Hashtable;

    .line 219
    .line 220
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 221
    .line 222
    .line 223
    move-result-object v2

    .line 224
    invoke-virtual {v4, v2}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 225
    .line 226
    .line 227
    move-result-object v2

    .line 228
    check-cast v2, Lcom/kousei/framework/bb;

    .line 229
    .line 230
    invoke-virtual {v2}, Lcom/kousei/framework/bb;->b()Lcom/kousei/framework/v3;

    .line 231
    .line 232
    .line 233
    move-result-object v2

    .line 234
    invoke-virtual {v0, v3, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 235
    .line 236
    .line 237
    goto/16 :goto_b

    .line 238
    .line 239
    :cond_ee
    sget-object v1, Lcom/kousei/framework/d2;->a:Ljava/util/Hashtable;

    .line 240
    .line 241
    const-string v2, "Curve25519"

    .line 242
    .line 243
    invoke-static {v2}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 244
    .line 245
    .line 246
    move-result-object v2

    .line 247
    invoke-virtual {v1, v2}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 248
    .line 249
    .line 250
    move-result-object v1

    .line 251
    check-cast v1, Lcom/kousei/framework/bb;

    .line 252
    .line 253
    invoke-virtual {v1}, Lcom/kousei/framework/bb;->b()Lcom/kousei/framework/v3;

    .line 254
    .line 255
    .line 256
    move-result-object v1

    .line 257
    new-instance v2, Lcom/kousei/framework/u3;

    .line 258
    .line 259
    iget-object v3, v1, Lcom/kousei/framework/v3;->a:Lcom/kousei/framework/l4;

    .line 260
    .line 261
    invoke-interface {v3}, Lcom/kousei/framework/l4;->b()Ljava/math/BigInteger;

    .line 262
    .line 263
    .line 264
    move-result-object v3

    .line 265
    iget-object v4, v1, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 266
    .line 267
    invoke-virtual {v4}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 268
    .line 269
    .line 270
    move-result-object v4

    .line 271
    iget-object v5, v1, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 272
    .line 273
    invoke-virtual {v5}, Lcom/kousei/framework/h0;->Z2()Ljava/math/BigInteger;

    .line 274
    .line 275
    .line 276
    move-result-object v5

    .line 277
    iget-object v6, v1, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 278
    .line 279
    iget-object v7, v1, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 280
    .line 281
    const/4 v8, 0x1

    .line 282
    invoke-direct/range {v2 .. v8}, Lcom/kousei/framework/u3;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Z)V

    .line 283
    .line 284
    .line 285
    invoke-virtual {v0, v2, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 286
    .line 287
    .line 288
    sput-object v0, Lcom/kousei/framework/n3;->a:Ljava/util/HashMap;

    .line 289
    .line 290
    return-void
.end method
