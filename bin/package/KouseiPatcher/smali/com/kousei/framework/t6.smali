.class public abstract Lcom/kousei/framework/t6;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final a:Ljava/util/concurrent/atomic/AtomicReference;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0xab830dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    new-instance v0, Ljava/util/concurrent/atomic/AtomicReference;

    .line 10
    .line 11
    invoke-direct {v0}, Ljava/util/concurrent/atomic/AtomicReference;-><init>()V

    .line 12
    .line 13
    .line 14
    sput-object v0, Lcom/kousei/framework/t6;->a:Ljava/util/concurrent/atomic/AtomicReference;

    .line 15
    .line 16
    return-void
.end method

.method public static a(Z)[Lcom/kousei/framework/j;
    .registers 6

    .line 1
    invoke-static {p0}, Lcom/kousei/framework/t6;->g(Z)Lcom/kousei/framework/s6;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    iget-object v0, p0, Lcom/kousei/framework/s6;->a:[B

    .line 6
    .line 7
    iget-boolean v1, p0, Lcom/kousei/framework/s6;->b:Z

    .line 8
    .line 9
    iget v2, p0, Lcom/kousei/framework/s6;->c:I

    .line 10
    .line 11
    iget-object p0, p0, Lcom/kousei/framework/s6;->d:[B

    .line 12
    .line 13
    sget-object v3, Lcom/kousei/framework/q6;->b:Lcom/kousei/framework/u;

    .line 14
    .line 15
    new-instance v3, Lcom/kousei/framework/n2;

    .line 16
    .line 17
    const/16 v4, 0x20

    .line 18
    .line 19
    if-eqz v0, :cond_15

    .line 20
    .line 21
    goto :goto_17

    .line 22
    :cond_15
    new-array v0, v4, [B

    .line 23
    .line 24
    :goto_17
    invoke-direct {v3, v0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 25
    .line 26
    .line 27
    if-eqz v1, :cond_1f

    .line 28
    .line 29
    sget-object v0, Lcom/kousei/framework/h;->d:Lcom/kousei/framework/h;

    .line 30
    .line 31
    goto :goto_21

    .line 32
    :cond_1f
    sget-object v0, Lcom/kousei/framework/h;->c:Lcom/kousei/framework/h;

    .line 33
    .line 34
    :goto_21
    new-instance v1, Lcom/kousei/framework/l;

    .line 35
    .line 36
    invoke-direct {v1, v2}, Lcom/kousei/framework/l;-><init>(I)V

    .line 37
    .line 38
    .line 39
    new-instance v2, Lcom/kousei/framework/n2;

    .line 40
    .line 41
    if-eqz p0, :cond_2b

    .line 42
    .line 43
    goto :goto_2d

    .line 44
    :cond_2b
    new-array p0, v4, [B

    .line 45
    .line 46
    :goto_2d
    invoke-direct {v2, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 47
    .line 48
    .line 49
    const/4 p0, 0x4

    .line 50
    new-array p0, p0, [Lcom/kousei/framework/j;

    .line 51
    .line 52
    const/4 v4, 0x0

    .line 53
    aput-object v3, p0, v4

    .line 54
    .line 55
    const/4 v3, 0x1

    .line 56
    aput-object v0, p0, v3

    .line 57
    .line 58
    const/4 v0, 0x2

    .line 59
    aput-object v1, p0, v0

    .line 60
    .line 61
    const/4 v0, 0x3

    .line 62
    aput-object v2, p0, v0

    .line 63
    .line 64
    return-object p0
.end method

.method public static b(Ljava/lang/String;)[B
    .registers 9

    .line 1
    const-wide v0, -0xab880dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    invoke-static {p0, v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 11
    .line 12
    .line 13
    move-result-object p0

    .line 14
    if-eqz p0, :cond_57

    .line 15
    .line 16
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    .line 17
    .line 18
    .line 19
    move-result v0

    .line 20
    const/16 v1, 0x40

    .line 21
    .line 22
    if-eq v0, v1, :cond_18

    .line 23
    .line 24
    goto :goto_57

    .line 25
    :cond_18
    :try_start_18
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    .line 26
    .line 27
    .line 28
    move-result v0

    .line 29
    div-int/lit8 v1, v0, 0x2

    .line 30
    .line 31
    new-array v1, v1, [B

    .line 32
    .line 33
    const/4 v2, 0x0

    .line 34
    move v3, v2

    .line 35
    :goto_22
    const/16 v4, 0x10

    .line 36
    .line 37
    if-ge v3, v0, :cond_43

    .line 38
    .line 39
    div-int/lit8 v5, v3, 0x2

    .line 40
    .line 41
    invoke-virtual {p0, v3}, Ljava/lang/String;->charAt(I)C

    .line 42
    .line 43
    .line 44
    move-result v6

    .line 45
    invoke-static {v6, v4}, Ljava/lang/Character;->digit(CI)I

    .line 46
    .line 47
    .line 48
    move-result v6

    .line 49
    shl-int/lit8 v6, v6, 0x4

    .line 50
    .line 51
    add-int/lit8 v7, v3, 0x1

    .line 52
    .line 53
    invoke-virtual {p0, v7}, Ljava/lang/String;->charAt(I)C

    .line 54
    .line 55
    .line 56
    move-result v7

    .line 57
    invoke-static {v7, v4}, Ljava/lang/Character;->digit(CI)I

    .line 58
    .line 59
    .line 60
    move-result v4

    .line 61
    add-int/2addr v4, v6

    .line 62
    int-to-byte v4, v4

    .line 63
    aput-byte v4, v1, v5

    .line 64
    .line 65
    add-int/lit8 v3, v3, 0x2

    .line 66
    .line 67
    goto :goto_22

    .line 68
    :cond_43
    invoke-virtual {p0}, Ljava/lang/String;->toCharArray()[C

    .line 69
    .line 70
    .line 71
    move-result-object p0

    .line 72
    array-length v0, p0

    .line 73
    :goto_48
    if-ge v2, v0, :cond_56

    .line 74
    .line 75
    aget-char v3, p0, v2

    .line 76
    .line 77
    invoke-static {v3, v4}, Ljava/lang/Character;->digit(CI)I

    .line 78
    .line 79
    .line 80
    move-result v3
    :try_end_50
    .catchall {:try_start_18 .. :try_end_50} :catchall_57

    .line 81
    if-gez v3, :cond_53

    .line 82
    .line 83
    goto :goto_57

    .line 84
    :cond_53
    add-int/lit8 v2, v2, 0x1

    .line 85
    .line 86
    goto :goto_48

    .line 87
    :cond_56
    return-object v1

    .line 88
    :catchall_57
    :cond_57
    :goto_57
    const/4 p0, 0x0

    .line 89
    return-object p0
.end method

.method public static c(Lcom/kousei/framework/s6;)Lcom/kousei/framework/s6;
    .registers 12

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/s6;->d:[B

    .line 2
    .line 3
    const/16 v1, 0x20

    .line 4
    .line 5
    if-eqz v0, :cond_8

    .line 6
    .line 7
    move-object v7, v0

    .line 8
    goto :goto_b

    .line 9
    :cond_8
    new-array v2, v1, [B

    .line 10
    .line 11
    move-object v7, v2

    .line 12
    :goto_b
    const-wide v2, -0xa6330dbb5469L

    .line 13
    .line 14
    .line 15
    .line 16
    .line 17
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object v2

    .line 21
    invoke-static {v2}, Lcom/kousei/framework/t6;->b(Ljava/lang/String;)[B

    .line 22
    .line 23
    .line 24
    move-result-object v2

    .line 25
    if-eqz v2, :cond_22

    .line 26
    .line 27
    invoke-static {v2}, Lcom/kousei/framework/t6;->e([B)Z

    .line 28
    .line 29
    .line 30
    move-result v3

    .line 31
    if-nez v3, :cond_22

    .line 32
    .line 33
    :goto_20
    move-object v4, v2

    .line 34
    goto :goto_57

    .line 35
    :cond_22
    const-wide v2, -0xa6520dbb5469L

    .line 36
    .line 37
    .line 38
    .line 39
    .line 40
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 41
    .line 42
    .line 43
    move-result-object v2

    .line 44
    invoke-static {v2}, Lcom/kousei/framework/t6;->b(Ljava/lang/String;)[B

    .line 45
    .line 46
    .line 47
    move-result-object v2

    .line 48
    if-eqz v2, :cond_3c

    .line 49
    .line 50
    invoke-static {v2}, Lcom/kousei/framework/t6;->e([B)Z

    .line 51
    .line 52
    .line 53
    move-result v3

    .line 54
    if-nez v3, :cond_3c

    .line 55
    .line 56
    invoke-static {v2}, Lcom/kousei/framework/t6;->h([B)[B

    .line 57
    .line 58
    .line 59
    move-result-object v2

    .line 60
    goto :goto_20

    .line 61
    :cond_3c
    iget-object v2, p0, Lcom/kousei/framework/s6;->a:[B

    .line 62
    .line 63
    if-eqz v0, :cond_4b

    .line 64
    .line 65
    invoke-static {v0}, Lcom/kousei/framework/t6;->e([B)Z

    .line 66
    .line 67
    .line 68
    move-result v3

    .line 69
    if-nez v3, :cond_4b

    .line 70
    .line 71
    invoke-static {v0}, Lcom/kousei/framework/t6;->h([B)[B

    .line 72
    .line 73
    .line 74
    move-result-object v2

    .line 75
    goto :goto_20

    .line 76
    :cond_4b
    if-eqz v2, :cond_54

    .line 77
    .line 78
    invoke-static {v2}, Lcom/kousei/framework/t6;->e([B)Z

    .line 79
    .line 80
    .line 81
    move-result v0

    .line 82
    if-nez v0, :cond_54

    .line 83
    .line 84
    goto :goto_20

    .line 85
    :cond_54
    new-array v2, v1, [B

    .line 86
    .line 87
    goto :goto_20

    .line 88
    :goto_57
    new-instance v3, Lcom/kousei/framework/s6;

    .line 89
    .line 90
    iget-boolean v8, p0, Lcom/kousei/framework/s6;->e:Z

    .line 91
    .line 92
    iget v9, p0, Lcom/kousei/framework/s6;->f:I

    .line 93
    .line 94
    iget v10, p0, Lcom/kousei/framework/s6;->g:I

    .line 95
    .line 96
    const/4 v5, 0x1

    .line 97
    const/4 v6, 0x0

    .line 98
    invoke-direct/range {v3 .. v10}, Lcom/kousei/framework/s6;-><init>([BZI[BZII)V

    .line 99
    .line 100
    .line 101
    return-object v3
.end method

.method public static d()Lcom/kousei/framework/s6;
    .registers 11

    .line 1
    const-wide v0, -0xa9240dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    const-wide v1, -0xa94e0dbb5469L

    .line 11
    .line 12
    .line 13
    .line 14
    .line 15
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    invoke-static {v0, v1}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 20
    .line 21
    .line 22
    move-result-object v0

    .line 23
    const/4 v1, 0x1

    .line 24
    const/4 v2, 0x0

    .line 25
    if-nez v0, :cond_1c

    .line 26
    .line 27
    :cond_1a
    :goto_1a
    move v6, v2

    .line 28
    goto :goto_6b

    .line 29
    :cond_1c
    sget-object v3, Ljava/util/Locale;->US:Ljava/util/Locale;

    .line 30
    .line 31
    invoke-virtual {v0, v3}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    .line 32
    .line 33
    .line 34
    move-result-object v0

    .line 35
    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    .line 36
    .line 37
    .line 38
    move-result v3

    .line 39
    sparse-switch v3, :sswitch_data_1c6

    .line 40
    .line 41
    .line 42
    goto :goto_1a

    .line 43
    :sswitch_2a
    const-wide v3, -0xa8720dbb5469L

    .line 44
    .line 45
    .line 46
    .line 47
    .line 48
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 49
    .line 50
    .line 51
    move-result-object v3

    .line 52
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 53
    .line 54
    .line 55
    goto :goto_1a

    .line 56
    :sswitch_37
    const-wide v3, -0xa87e0dbb5469L

    .line 57
    .line 58
    .line 59
    .line 60
    .line 61
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 62
    .line 63
    .line 64
    move-result-object v3

    .line 65
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 66
    .line 67
    .line 68
    move-result v0

    .line 69
    if-eqz v0, :cond_1a

    .line 70
    .line 71
    const/4 v0, 0x3

    .line 72
    :goto_47
    move v6, v0

    .line 73
    goto :goto_6b

    .line 74
    :sswitch_49
    const-wide v3, -0xa8600dbb5469L

    .line 75
    .line 76
    .line 77
    .line 78
    .line 79
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object v3

    .line 83
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 84
    .line 85
    .line 86
    move-result v0

    .line 87
    if-eqz v0, :cond_1a

    .line 88
    .line 89
    move v6, v1

    .line 90
    goto :goto_6b

    .line 91
    :sswitch_5a
    const-wide v3, -0xa8790dbb5469L

    .line 92
    .line 93
    .line 94
    .line 95
    .line 96
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 97
    .line 98
    .line 99
    move-result-object v3

    .line 100
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 101
    .line 102
    .line 103
    move-result v0

    .line 104
    if-eqz v0, :cond_1a

    .line 105
    .line 106
    const/4 v0, 0x2

    .line 107
    goto :goto_47

    .line 108
    :goto_6b
    const-wide v3, -0xa9440dbb5469L

    .line 109
    .line 110
    .line 111
    .line 112
    .line 113
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 114
    .line 115
    .line 116
    move-result-object v0

    .line 117
    const-wide v3, -0xa9460dbb5469L

    .line 118
    .line 119
    .line 120
    .line 121
    .line 122
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 123
    .line 124
    .line 125
    move-result-object v3

    .line 126
    const-wide v4, -0xa96d0dbb5469L

    .line 127
    .line 128
    .line 129
    .line 130
    .line 131
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 132
    .line 133
    .line 134
    move-result-object v4

    .line 135
    invoke-static {v3, v4}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 136
    .line 137
    .line 138
    move-result-object v3

    .line 139
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 140
    .line 141
    .line 142
    move-result v0

    .line 143
    if-nez v0, :cond_b8

    .line 144
    .line 145
    const-wide v3, -0xa96f0dbb5469L

    .line 146
    .line 147
    .line 148
    .line 149
    .line 150
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 151
    .line 152
    .line 153
    move-result-object v0

    .line 154
    const-wide v3, -0xa9660dbb5469L

    .line 155
    .line 156
    .line 157
    .line 158
    .line 159
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 160
    .line 161
    .line 162
    move-result-object v3

    .line 163
    const-wide v4, -0xa8820dbb5469L

    .line 164
    .line 165
    .line 166
    .line 167
    .line 168
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 169
    .line 170
    .line 171
    move-result-object v4

    .line 172
    invoke-static {v3, v4}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 173
    .line 174
    .line 175
    move-result-object v3

    .line 176
    invoke-virtual {v0, v3}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 177
    .line 178
    .line 179
    move-result v0

    .line 180
    if-eqz v0, :cond_b6

    .line 181
    .line 182
    goto :goto_b8

    .line 183
    :cond_b6
    move v0, v2

    .line 184
    goto :goto_b9

    .line 185
    :cond_b8
    :goto_b8
    move v0, v1

    .line 186
    :goto_b9
    const-wide v3, -0xa89b0dbb5469L

    .line 187
    .line 188
    .line 189
    .line 190
    .line 191
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 192
    .line 193
    .line 194
    move-result-object v3

    .line 195
    invoke-static {v3}, Lcom/kousei/framework/t6;->b(Ljava/lang/String;)[B

    .line 196
    .line 197
    .line 198
    move-result-object v3

    .line 199
    if-nez v3, :cond_ce

    .line 200
    .line 201
    if-eqz v0, :cond_d0

    .line 202
    .line 203
    const/16 v3, 0x20

    .line 204
    .line 205
    new-array v3, v3, [B

    .line 206
    .line 207
    :cond_ce
    :goto_ce
    move-object v4, v3

    .line 208
    goto :goto_f1

    .line 209
    :cond_d0
    const-wide v3, -0xa8ba0dbb5469L

    .line 210
    .line 211
    .line 212
    .line 213
    .line 214
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 215
    .line 216
    .line 217
    move-result-object v3

    .line 218
    const-wide v4, -0xa8c00dbb5469L

    .line 219
    .line 220
    .line 221
    .line 222
    .line 223
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 224
    .line 225
    .line 226
    move-result-object v4

    .line 227
    invoke-static {v3, v4}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 228
    .line 229
    .line 230
    move-result-object v3

    .line 231
    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 232
    .line 233
    invoke-virtual {v3, v4}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 234
    .line 235
    .line 236
    move-result-object v3

    .line 237
    invoke-static {v3}, Lcom/kousei/framework/t6;->h([B)[B

    .line 238
    .line 239
    .line 240
    move-result-object v3

    .line 241
    goto :goto_ce

    .line 242
    :goto_f1
    const-wide v7, -0xa8c30dbb5469L

    .line 243
    .line 244
    .line 245
    .line 246
    .line 247
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 248
    .line 249
    .line 250
    move-result-object v3

    .line 251
    invoke-static {v3}, Lcom/kousei/framework/t6;->b(Ljava/lang/String;)[B

    .line 252
    .line 253
    .line 254
    move-result-object v3

    .line 255
    if-eqz v3, :cond_10a

    .line 256
    .line 257
    invoke-static {v3}, Lcom/kousei/framework/t6;->e([B)Z

    .line 258
    .line 259
    .line 260
    move-result v5

    .line 261
    if-eqz v5, :cond_107

    .line 262
    .line 263
    goto :goto_10a

    .line 264
    :cond_107
    :goto_107
    move-object v7, v3

    .line 265
    goto/16 :goto_1bb

    .line 266
    .line 267
    :cond_10a
    :goto_10a
    new-instance v3, Ljava/lang/StringBuilder;

    .line 268
    .line 269
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    .line 270
    .line 271
    .line 272
    const-wide v7, -0xa8e90dbb5469L

    .line 273
    .line 274
    .line 275
    .line 276
    .line 277
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 278
    .line 279
    .line 280
    move-result-object v5

    .line 281
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 282
    .line 283
    .line 284
    const-wide v7, -0xa8f50dbb5469L

    .line 285
    .line 286
    .line 287
    .line 288
    .line 289
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 290
    .line 291
    .line 292
    move-result-object v5

    .line 293
    const-wide v7, -0xa8140dbb5469L

    .line 294
    .line 295
    .line 296
    .line 297
    .line 298
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 299
    .line 300
    .line 301
    move-result-object v7

    .line 302
    invoke-static {v5, v7}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 303
    .line 304
    .line 305
    move-result-object v5

    .line 306
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 307
    .line 308
    .line 309
    const-wide v7, -0xa8170dbb5469L

    .line 310
    .line 311
    .line 312
    .line 313
    .line 314
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 315
    .line 316
    .line 317
    move-result-object v5

    .line 318
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 319
    .line 320
    .line 321
    const-wide v7, -0xa8290dbb5469L

    .line 322
    .line 323
    .line 324
    .line 325
    .line 326
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 327
    .line 328
    .line 329
    move-result-object v5

    .line 330
    const-wide v7, -0xa83c0dbb5469L

    .line 331
    .line 332
    .line 333
    .line 334
    .line 335
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 336
    .line 337
    .line 338
    move-result-object v7

    .line 339
    invoke-static {v5, v7}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 340
    .line 341
    .line 342
    move-result-object v5

    .line 343
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 344
    .line 345
    .line 346
    const-wide v7, -0xa83f0dbb5469L

    .line 347
    .line 348
    .line 349
    .line 350
    .line 351
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 352
    .line 353
    .line 354
    move-result-object v5

    .line 355
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 356
    .line 357
    .line 358
    const-wide v7, -0xa8310dbb5469L

    .line 359
    .line 360
    .line 361
    .line 362
    .line 363
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 364
    .line 365
    .line 366
    move-result-object v5

    .line 367
    const-wide v7, -0xa8420dbb5469L

    .line 368
    .line 369
    .line 370
    .line 371
    .line 372
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 373
    .line 374
    .line 375
    move-result-object v7

    .line 376
    invoke-static {v5, v7}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 377
    .line 378
    .line 379
    move-result-object v5

    .line 380
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 381
    .line 382
    .line 383
    const-wide v7, -0xa8450dbb5469L

    .line 384
    .line 385
    .line 386
    .line 387
    .line 388
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 389
    .line 390
    .line 391
    move-result-object v5

    .line 392
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 393
    .line 394
    .line 395
    const-wide v7, -0xa8470dbb5469L

    .line 396
    .line 397
    .line 398
    .line 399
    .line 400
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 401
    .line 402
    .line 403
    move-result-object v5

    .line 404
    const-wide v7, -0xa8610dbb5469L

    .line 405
    .line 406
    .line 407
    .line 408
    .line 409
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 410
    .line 411
    .line 412
    move-result-object v7

    .line 413
    invoke-static {v5, v7}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 414
    .line 415
    .line 416
    move-result-object v5

    .line 417
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 418
    .line 419
    .line 420
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 421
    .line 422
    .line 423
    move-result-object v3

    .line 424
    sget-object v5, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 425
    .line 426
    invoke-virtual {v3, v5}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 427
    .line 428
    .line 429
    move-result-object v3

    .line 430
    invoke-static {v3}, Lcom/kousei/framework/t6;->h([B)[B

    .line 431
    .line 432
    .line 433
    move-result-object v3

    .line 434
    invoke-static {v3}, Lcom/kousei/framework/t6;->e([B)Z

    .line 435
    .line 436
    .line 437
    move-result v5

    .line 438
    if-eqz v5, :cond_107

    .line 439
    .line 440
    aput-byte v1, v3, v2

    .line 441
    .line 442
    goto/16 :goto_107

    .line 443
    .line 444
    :goto_1bb
    new-instance v3, Lcom/kousei/framework/s6;

    .line 445
    .line 446
    xor-int/lit8 v5, v0, 0x1

    .line 447
    .line 448
    const/4 v9, -0x1

    .line 449
    const/4 v10, -0x1

    .line 450
    const/4 v8, 0x0

    .line 451
    invoke-direct/range {v3 .. v10}, Lcom/kousei/framework/s6;-><init>([BZI[BZII)V

    .line 452
    .line 453
    .line 454
    return-object v3

    .line 455
    :sswitch_data_1c6
    .sparse-switch
        -0x3c21d9d2 -> :sswitch_5a
        -0x2bc39b8c -> :sswitch_49
        0x1b891 -> :sswitch_37
        0x5e0cf03 -> :sswitch_2a
    .end sparse-switch
.end method

.method public static e([B)Z
    .registers 5

    .line 1
    array-length v0, p0

    .line 2
    const/4 v1, 0x0

    .line 3
    move v2, v1

    .line 4
    :goto_3
    if-ge v2, v0, :cond_d

    .line 5
    .line 6
    aget-byte v3, p0, v2

    .line 7
    .line 8
    if-eqz v3, :cond_a

    .line 9
    .line 10
    return v1

    .line 11
    :cond_a
    add-int/lit8 v2, v2, 0x1

    .line 12
    .line 13
    goto :goto_3

    .line 14
    :cond_d
    const/4 p0, 0x1

    .line 15
    return p0
.end method

.method public static f()Lcom/kousei/framework/s6;
    .registers 13

    .line 1
    const-wide v0, -0xa6780dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    const/4 v2, 0x0

    .line 7
    const/4 v3, 0x0

    .line 8
    :try_start_7
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object v0

    .line 12
    const-wide v4, -0xa67d0dbb5469L

    .line 13
    .line 14
    .line 15
    .line 16
    .line 17
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object v1

    .line 21
    invoke-static {v0, v1}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    new-instance v1, Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 26
    .line 27
    const-wide v4, -0xa98d0dbb5469L

    .line 28
    .line 29
    .line 30
    .line 31
    .line 32
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 33
    .line 34
    .line 35
    move-result-object v4

    .line 36
    const/16 v5, 0xc

    .line 37
    .line 38
    invoke-direct {v1, v4, v5}, Landroid/security/keystore/KeyGenParameterSpec$Builder;-><init>(Ljava/lang/String;I)V

    .line 39
    .line 40
    .line 41
    const-wide v4, -0xa9910dbb5469L

    .line 42
    .line 43
    .line 44
    .line 45
    .line 46
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 47
    .line 48
    .line 49
    move-result-object v4

    .line 50
    filled-new-array {v4}, [Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object v4

    .line 54
    invoke-virtual {v1, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setDigests([Ljava/lang/String;)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 55
    .line 56
    .line 57
    move-result-object v1

    .line 58
    const/16 v4, 0x20

    .line 59
    .line 60
    new-array v4, v4, [B

    .line 61
    .line 62
    invoke-virtual {v1, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setAttestationChallenge([B)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 63
    .line 64
    .line 65
    move-result-object v1

    .line 66
    invoke-virtual {v1}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->build()Landroid/security/keystore/KeyGenParameterSpec;

    .line 67
    .line 68
    .line 69
    move-result-object v1

    .line 70
    invoke-virtual {v0, v1}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 71
    .line 72
    .line 73
    invoke-virtual {v0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;

    .line 74
    .line 75
    .line 76
    const-wide v0, -0xa9a90dbb5469L

    .line 77
    .line 78
    .line 79
    .line 80
    .line 81
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 82
    .line 83
    .line 84
    move-result-object v0

    .line 85
    invoke-static {v0}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 86
    .line 87
    .line 88
    move-result-object v0
    :try_end_58
    .catchall {:try_start_7 .. :try_end_58} :catchall_9d

    .line 89
    :try_start_58
    invoke-virtual {v0, v3}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 90
    .line 91
    .line 92
    const-wide v4, -0xa9b90dbb5469L

    .line 93
    .line 94
    .line 95
    .line 96
    .line 97
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 98
    .line 99
    .line 100
    move-result-object v1

    .line 101
    invoke-virtual {v0, v1}, Ljava/security/KeyStore;->getCertificateChain(Ljava/lang/String;)[Ljava/security/cert/Certificate;

    .line 102
    .line 103
    .line 104
    move-result-object v1

    .line 105
    if-eqz v1, :cond_90

    .line 106
    .line 107
    array-length v4, v1

    .line 108
    if-eqz v4, :cond_90

    .line 109
    .line 110
    aget-object v1, v1, v2

    .line 111
    .line 112
    instance-of v4, v1, Ljava/security/cert/X509Certificate;

    .line 113
    .line 114
    if-nez v4, :cond_74

    .line 115
    .line 116
    goto :goto_90

    .line 117
    :cond_74
    check-cast v1, Ljava/security/cert/X509Certificate;

    .line 118
    .line 119
    const-wide v4, -0xa9d10dbb5469L

    .line 120
    .line 121
    .line 122
    .line 123
    .line 124
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 125
    .line 126
    .line 127
    move-result-object v4

    .line 128
    invoke-interface {v1, v4}, Ljava/security/cert/X509Extension;->getExtensionValue(Ljava/lang/String;)[B

    .line 129
    .line 130
    .line 131
    move-result-object v1
    :try_end_83
    .catchall {:try_start_58 .. :try_end_83} :catchall_9e

    .line 132
    const-wide v4, -0xa9f80dbb5469L

    .line 133
    .line 134
    .line 135
    .line 136
    .line 137
    :try_start_88
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 138
    .line 139
    .line 140
    move-result-object v4

    .line 141
    invoke-virtual {v0, v4}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_8f
    .catchall {:try_start_88 .. :try_end_8f} :catchall_ad

    .line 142
    .line 143
    .line 144
    goto :goto_ad

    .line 145
    :cond_90
    :goto_90
    const-wide v1, -0xa9cd0dbb5469L

    .line 146
    .line 147
    .line 148
    .line 149
    .line 150
    :try_start_95
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 151
    .line 152
    .line 153
    move-result-object v1

    .line 154
    invoke-virtual {v0, v1}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_9c
    .catchall {:try_start_95 .. :try_end_9c} :catchall_175

    .line 155
    .line 156
    .line 157
    return-object v3

    .line 158
    :catchall_9d
    move-object v0, v3

    .line 159
    :catchall_9e
    if-eqz v0, :cond_ac

    .line 160
    .line 161
    const-wide v4, -0xa90c0dbb5469L

    .line 162
    .line 163
    .line 164
    .line 165
    .line 166
    :try_start_a5
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 167
    .line 168
    .line 169
    move-result-object v1

    .line 170
    invoke-virtual {v0, v1}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_ac
    .catchall {:try_start_a5 .. :try_end_ac} :catchall_ac

    .line 171
    .line 172
    .line 173
    :catchall_ac
    :cond_ac
    move-object v1, v3

    .line 174
    :catchall_ad
    :goto_ad
    if-nez v1, :cond_b1

    .line 175
    .line 176
    goto/16 :goto_175

    .line 177
    .line 178
    :cond_b1
    :try_start_b1
    new-instance v4, Lcom/kousei/framework/o;

    .line 179
    .line 180
    invoke-direct {v4, v1}, Lcom/kousei/framework/o;-><init>([B)V
    :try_end_b6
    .catchall {:try_start_b1 .. :try_end_b6} :catchall_175

    .line 181
    .line 182
    .line 183
    :try_start_b6
    invoke-virtual {v4}, Lcom/kousei/framework/o;->f()Lcom/kousei/framework/z;

    .line 184
    .line 185
    .line 186
    move-result-object v0

    .line 187
    check-cast v0, Lcom/kousei/framework/v;
    :try_end_bc
    .catchall {:try_start_b6 .. :try_end_bc} :catchall_170

    .line 188
    .line 189
    :try_start_bc
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V

    .line 190
    .line 191
    .line 192
    new-instance v1, Lcom/kousei/framework/o;

    .line 193
    .line 194
    iget-object v0, v0, Lcom/kousei/framework/v;->a:[B

    .line 195
    .line 196
    invoke-direct {v1, v0}, Lcom/kousei/framework/o;-><init>([B)V
    :try_end_c6
    .catchall {:try_start_bc .. :try_end_c6} :catchall_175

    .line 197
    .line 198
    .line 199
    :try_start_c6
    invoke-virtual {v1}, Lcom/kousei/framework/o;->f()Lcom/kousei/framework/z;

    .line 200
    .line 201
    .line 202
    move-result-object v0

    .line 203
    check-cast v0, Lcom/kousei/framework/c0;
    :try_end_cc
    .catchall {:try_start_c6 .. :try_end_cc} :catchall_16b

    .line 204
    .line 205
    :try_start_cc
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 206
    .line 207
    .line 208
    invoke-virtual {v0}, Lcom/kousei/framework/c0;->size()I

    .line 209
    .line 210
    .line 211
    move-result v1

    .line 212
    const/16 v4, 0x8

    .line 213
    .line 214
    if-ge v1, v4, :cond_d9

    .line 215
    .line 216
    goto/16 :goto_175

    .line 217
    .line 218
    :cond_d9
    const/4 v1, 0x7

    .line 219
    invoke-virtual {v0, v1}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 220
    .line 221
    .line 222
    move-result-object v1

    .line 223
    check-cast v1, Lcom/kousei/framework/c0;

    .line 224
    .line 225
    move v4, v2

    .line 226
    :goto_e1
    invoke-virtual {v1}, Lcom/kousei/framework/c0;->size()I

    .line 227
    .line 228
    .line 229
    move-result v5

    .line 230
    if-ge v4, v5, :cond_175

    .line 231
    .line 232
    invoke-virtual {v1, v4}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 233
    .line 234
    .line 235
    move-result-object v5

    .line 236
    instance-of v6, v5, Lcom/kousei/framework/a1;

    .line 237
    .line 238
    if-nez v6, :cond_f0

    .line 239
    .line 240
    goto :goto_f8

    .line 241
    :cond_f0
    check-cast v5, Lcom/kousei/framework/a1;

    .line 242
    .line 243
    iget v6, v5, Lcom/kousei/framework/a1;->c:I

    .line 244
    .line 245
    const/16 v7, 0x2c0

    .line 246
    .line 247
    if-eq v6, v7, :cond_fb

    .line 248
    .line 249
    :goto_f8
    add-int/lit8 v4, v4, 0x1

    .line 250
    .line 251
    goto :goto_e1

    .line 252
    :cond_fb
    invoke-virtual {v5}, Lcom/kousei/framework/a1;->r()Lcom/kousei/framework/r;

    .line 253
    .line 254
    .line 255
    move-result-object v1

    .line 256
    invoke-interface {v1}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 257
    .line 258
    .line 259
    move-result-object v1

    .line 260
    invoke-static {v1}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 261
    .line 262
    .line 263
    move-result-object v1

    .line 264
    invoke-virtual {v1}, Lcom/kousei/framework/c0;->size()I

    .line 265
    .line 266
    .line 267
    move-result v4

    .line 268
    const/4 v5, 0x4

    .line 269
    if-ge v4, v5, :cond_10f

    .line 270
    .line 271
    goto :goto_175

    .line 272
    :cond_10f
    invoke-virtual {v1, v2}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 273
    .line 274
    .line 275
    move-result-object v4

    .line 276
    check-cast v4, Lcom/kousei/framework/v;

    .line 277
    .line 278
    iget-object v6, v4, Lcom/kousei/framework/v;->a:[B

    .line 279
    .line 280
    const/4 v4, 0x1

    .line 281
    invoke-virtual {v1, v4}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 282
    .line 283
    .line 284
    move-result-object v4

    .line 285
    invoke-static {v4}, Lcom/kousei/framework/h;->s(Lcom/kousei/framework/j;)Lcom/kousei/framework/h;

    .line 286
    .line 287
    .line 288
    move-result-object v4

    .line 289
    invoke-virtual {v4}, Lcom/kousei/framework/h;->t()Z

    .line 290
    .line 291
    .line 292
    move-result v7

    .line 293
    const/4 v4, 0x2

    .line 294
    invoke-virtual {v1, v4}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 295
    .line 296
    .line 297
    move-result-object v5

    .line 298
    invoke-static {v5}, Lcom/kousei/framework/l;->s(Lcom/kousei/framework/j;)Lcom/kousei/framework/l;

    .line 299
    .line 300
    .line 301
    move-result-object v5

    .line 302
    invoke-virtual {v5}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 303
    .line 304
    .line 305
    new-instance v8, Ljava/math/BigInteger;

    .line 306
    .line 307
    iget-object v5, v5, Lcom/kousei/framework/l;->a:[B

    .line 308
    .line 309
    invoke-direct {v8, v5}, Ljava/math/BigInteger;-><init>([B)V

    .line 310
    .line 311
    .line 312
    invoke-virtual {v8}, Ljava/math/BigInteger;->intValueExact()I

    .line 313
    .line 314
    .line 315
    move-result v8

    .line 316
    const/4 v5, 0x3

    .line 317
    invoke-virtual {v1, v5}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 318
    .line 319
    .line 320
    move-result-object v1

    .line 321
    check-cast v1, Lcom/kousei/framework/v;

    .line 322
    .line 323
    iget-object v9, v1, Lcom/kousei/framework/v;->a:[B

    .line 324
    .line 325
    invoke-virtual {v0, v2}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 326
    .line 327
    .line 328
    move-result-object v1

    .line 329
    invoke-static {v1}, Lcom/kousei/framework/p;->r(Ljava/lang/Object;)Lcom/kousei/framework/p;

    .line 330
    .line 331
    .line 332
    move-result-object v1

    .line 333
    invoke-virtual {v1}, Lcom/kousei/framework/p;->s()Ljava/math/BigInteger;

    .line 334
    .line 335
    .line 336
    move-result-object v1

    .line 337
    invoke-virtual {v1}, Ljava/math/BigInteger;->intValueExact()I

    .line 338
    .line 339
    .line 340
    move-result v11

    .line 341
    invoke-virtual {v0, v4}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 342
    .line 343
    .line 344
    move-result-object v0

    .line 345
    invoke-static {v0}, Lcom/kousei/framework/p;->r(Ljava/lang/Object;)Lcom/kousei/framework/p;

    .line 346
    .line 347
    .line 348
    move-result-object v0

    .line 349
    invoke-virtual {v0}, Lcom/kousei/framework/p;->s()Ljava/math/BigInteger;

    .line 350
    .line 351
    .line 352
    move-result-object v0

    .line 353
    invoke-virtual {v0}, Ljava/math/BigInteger;->intValueExact()I

    .line 354
    .line 355
    .line 356
    move-result v12

    .line 357
    new-instance v5, Lcom/kousei/framework/s6;

    .line 358
    .line 359
    const/4 v10, 0x1

    .line 360
    invoke-direct/range {v5 .. v12}, Lcom/kousei/framework/s6;-><init>([BZI[BZII)V

    .line 361
    .line 362
    .line 363
    return-object v5

    .line 364
    :catchall_16b
    move-exception v0

    .line 365
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 366
    .line 367
    .line 368
    throw v0

    .line 369
    :catchall_170
    move-exception v0

    .line 370
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V

    .line 371
    .line 372
    .line 373
    throw v0
    :try_end_175
    .catchall {:try_start_cc .. :try_end_175} :catchall_175

    .line 374
    :catchall_175
    :cond_175
    :goto_175
    return-object v3
.end method

.method public static g(Z)Lcom/kousei/framework/s6;
    .registers 4

    .line 1
    sget-object v0, Lcom/kousei/framework/t6;->a:Ljava/util/concurrent/atomic/AtomicReference;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v1

    .line 7
    check-cast v1, Lcom/kousei/framework/s6;

    .line 8
    .line 9
    if-eqz v1, :cond_b

    .line 10
    .line 11
    return-object v1

    .line 12
    :cond_b
    const-class v1, Lcom/kousei/framework/t6;

    .line 13
    .line 14
    monitor-enter v1

    .line 15
    :try_start_e
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    .line 16
    .line 17
    .line 18
    move-result-object v2

    .line 19
    check-cast v2, Lcom/kousei/framework/s6;

    .line 20
    .line 21
    if-eqz v2, :cond_1a

    .line 22
    .line 23
    monitor-exit v1
    :try_end_17
    .catchall {:try_start_e .. :try_end_17} :catchall_18

    .line 24
    return-object v2

    .line 25
    :catchall_18
    move-exception p0

    .line 26
    goto :goto_3a

    .line 27
    :cond_1a
    if-eqz p0, :cond_2b

    .line 28
    .line 29
    :try_start_1c
    invoke-static {}, Lcom/kousei/framework/t6;->f()Lcom/kousei/framework/s6;

    .line 30
    .line 31
    .line 32
    move-result-object p0

    .line 33
    if-eqz p0, :cond_2b

    .line 34
    .line 35
    invoke-static {p0}, Lcom/kousei/framework/t6;->c(Lcom/kousei/framework/s6;)Lcom/kousei/framework/s6;

    .line 36
    .line 37
    .line 38
    move-result-object p0

    .line 39
    invoke-virtual {v0, p0}, Ljava/util/concurrent/atomic/AtomicReference;->set(Ljava/lang/Object;)V
    :try_end_29
    .catchall {:try_start_1c .. :try_end_29} :catchall_2b

    .line 40
    .line 41
    .line 42
    :try_start_29
    monitor-exit v1

    .line 43
    return-object p0

    .line 44
    :catchall_2b
    :cond_2b
    invoke-static {}, Lcom/kousei/framework/t6;->d()Lcom/kousei/framework/s6;

    .line 45
    .line 46
    .line 47
    move-result-object p0

    .line 48
    invoke-static {p0}, Lcom/kousei/framework/t6;->c(Lcom/kousei/framework/s6;)Lcom/kousei/framework/s6;

    .line 49
    .line 50
    .line 51
    move-result-object p0

    .line 52
    sget-object v0, Lcom/kousei/framework/t6;->a:Ljava/util/concurrent/atomic/AtomicReference;

    .line 53
    .line 54
    invoke-virtual {v0, p0}, Ljava/util/concurrent/atomic/AtomicReference;->set(Ljava/lang/Object;)V

    .line 55
    .line 56
    .line 57
    monitor-exit v1

    .line 58
    return-object p0

    .line 59
    :goto_3a
    monitor-exit v1
    :try_end_3b
    .catchall {:try_start_29 .. :try_end_3b} :catchall_18

    .line 60
    throw p0
.end method

.method public static h([B)[B
    .registers 3

    .line 1
    const-wide v0, -0xab8b0dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    :try_start_5
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 11
    .line 12
    .line 13
    move-result-object v0

    .line 14
    invoke-virtual {v0, p0}, Ljava/security/MessageDigest;->digest([B)[B

    .line 15
    .line 16
    .line 17
    move-result-object p0
    :try_end_11
    .catchall {:try_start_5 .. :try_end_11} :catchall_12

    .line 18
    return-object p0

    .line 19
    :catchall_12
    const/16 p0, 0x20

    .line 20
    .line 21
    new-array p0, p0, [B

    .line 22
    .line 23
    return-object p0
.end method
