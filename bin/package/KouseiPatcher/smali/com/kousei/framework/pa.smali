.class public abstract Lcom/kousei/framework/pa;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# direct methods
.method public static a(Landroid/content/Context;Ljava/lang/String;)V
    .registers 7

    .line 1
    if-nez p1, :cond_4

    .line 2
    .line 3
    goto/16 :goto_104

    .line 4
    .line 5
    :cond_4
    const-wide v0, -0xb6770dbb5469L

    .line 6
    .line 7
    .line 8
    .line 9
    .line 10
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 11
    .line 12
    .line 13
    move-result-object v0

    .line 14
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 15
    .line 16
    .line 17
    move-result v0

    .line 18
    if-nez v0, :cond_33

    .line 19
    .line 20
    const-wide v0, -0xb9ad0dbb5469L

    .line 21
    .line 22
    .line 23
    .line 24
    .line 25
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 26
    .line 27
    .line 28
    move-result-object v0

    .line 29
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 30
    .line 31
    .line 32
    move-result v0

    .line 33
    if-nez v0, :cond_33

    .line 34
    .line 35
    const-wide v0, -0xb9c50dbb5469L

    .line 36
    .line 37
    .line 38
    .line 39
    .line 40
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 41
    .line 42
    .line 43
    move-result-object v0

    .line 44
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 45
    .line 46
    .line 47
    move-result v0

    .line 48
    if-nez v0, :cond_33

    .line 49
    .line 50
    goto/16 :goto_104

    .line 51
    .line 52
    :cond_33
    const/4 v0, 0x0

    .line 53
    if-eqz p0, :cond_3b

    .line 54
    .line 55
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 56
    .line 57
    .line 58
    move-result-object p0

    .line 59
    goto :goto_62

    .line 60
    :cond_3b
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    .line 61
    .line 62
    .line 63
    move-result-object p0

    .line 64
    if-nez p0, :cond_5a

    .line 65
    .line 66
    invoke-static {}, Landroid/app/ActivityThread;->currentActivityThread()Landroid/app/ActivityThread;

    .line 67
    .line 68
    .line 69
    move-result-object v1

    .line 70
    if-eqz v1, :cond_5a

    .line 71
    .line 72
    :try_start_47
    invoke-virtual {v1}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 73
    .line 74
    .line 75
    move-result-object p0

    .line 76
    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    .line 77
    .line 78
    .line 79
    move-result v2

    .line 80
    if-nez v2, :cond_5a

    .line 81
    .line 82
    invoke-virtual {p0, p1, v0}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    .line 83
    .line 84
    .line 85
    move-result-object p0
    :try_end_55
    .catch Ljava/lang/Exception; {:try_start_47 .. :try_end_55} :catch_56

    .line 86
    goto :goto_5a

    .line 87
    :catch_56
    invoke-virtual {v1}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 88
    .line 89
    .line 90
    move-result-object p0

    .line 91
    :cond_5a
    :goto_5a
    if-nez p0, :cond_5e

    .line 92
    .line 93
    const/4 p0, 0x0

    .line 94
    goto :goto_62

    .line 95
    :cond_5e
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 96
    .line 97
    .line 98
    move-result-object p0

    .line 99
    :goto_62
    if-nez p0, :cond_66

    .line 100
    .line 101
    goto/16 :goto_104

    .line 102
    .line 103
    :cond_66
    const-wide v1, -0xb9fd0dbb5469L

    .line 104
    .line 105
    .line 106
    .line 107
    .line 108
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 109
    .line 110
    .line 111
    move-result-object v1

    .line 112
    invoke-static {p0, v1, v0}, Lcom/kousei/framework/KaoriosFramework;->getGlobalInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    .line 113
    .line 114
    .line 115
    move-result p0

    .line 116
    const/4 v1, 0x1

    .line 117
    if-eq p0, v1, :cond_78

    .line 118
    .line 119
    goto/16 :goto_104

    .line 120
    .line 121
    :cond_78
    new-instance p0, Ljava/lang/StringBuilder;

    .line 122
    .line 123
    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    .line 124
    .line 125
    .line 126
    const-wide v1, -0xb90f0dbb5469L

    .line 127
    .line 128
    .line 129
    .line 130
    .line 131
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 132
    .line 133
    .line 134
    move-result-object v1

    .line 135
    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 136
    .line 137
    .line 138
    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 139
    .line 140
    .line 141
    const-wide v1, -0xb91b0dbb5469L

    .line 142
    .line 143
    .line 144
    .line 145
    .line 146
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 147
    .line 148
    .line 149
    move-result-object p1

    .line 150
    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 151
    .line 152
    .line 153
    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 154
    .line 155
    .line 156
    move-result-object p0

    .line 157
    new-instance p1, Ljava/io/File;

    .line 158
    .line 159
    invoke-direct {p1, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 160
    .line 161
    .line 162
    invoke-virtual {p1}, Ljava/io/File;->exists()Z

    .line 163
    .line 164
    .line 165
    move-result p0

    .line 166
    if-nez p0, :cond_a8

    .line 167
    .line 168
    goto :goto_104

    .line 169
    :cond_a8
    :try_start_a8
    invoke-virtual {p1}, Ljava/io/File;->length()J

    .line 170
    .line 171
    .line 172
    move-result-wide v1

    .line 173
    long-to-int p0, v1

    .line 174
    new-array p0, p0, [B

    .line 175
    .line 176
    new-instance v1, Ljava/io/FileInputStream;

    .line 177
    .line 178
    invoke-direct {v1, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_b4
    .catch Ljava/io/IOException; {:try_start_a8 .. :try_end_b4} :catch_104

    .line 179
    .line 180
    .line 181
    :try_start_b4
    invoke-virtual {v1, p0}, Ljava/io/FileInputStream;->read([B)I
    :try_end_b7
    .catchall {:try_start_b4 .. :try_end_b7} :catchall_fa

    .line 182
    .line 183
    .line 184
    :try_start_b7
    invoke-virtual {v1}, Ljava/io/FileInputStream;->close()V

    .line 185
    .line 186
    .line 187
    new-instance v1, Ljava/lang/String;

    .line 188
    .line 189
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 190
    .line 191
    invoke-direct {v1, p0, v2}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    .line 192
    .line 193
    .line 194
    const-wide v3, -0xb9240dbb5469L

    .line 195
    .line 196
    .line 197
    .line 198
    .line 199
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 200
    .line 201
    .line 202
    move-result-object p0

    .line 203
    const-wide v3, -0xb94a0dbb5469L

    .line 204
    .line 205
    .line 206
    .line 207
    .line 208
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 209
    .line 210
    .line 211
    move-result-object v3

    .line 212
    invoke-virtual {v1, p0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    .line 213
    .line 214
    .line 215
    move-result v4

    .line 216
    if-eqz v4, :cond_104

    .line 217
    .line 218
    invoke-virtual {v1, p0, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    .line 219
    .line 220
    .line 221
    move-result-object p0

    .line 222
    new-instance v1, Ljava/io/FileOutputStream;

    .line 223
    .line 224
    invoke-direct {v1, p1, v0}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V
    :try_end_e2
    .catch Ljava/io/IOException; {:try_start_b7 .. :try_end_e2} :catch_104

    .line 225
    .line 226
    .line 227
    :try_start_e2
    invoke-virtual {p0, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 228
    .line 229
    .line 230
    move-result-object p0

    .line 231
    invoke-virtual {v1, p0}, Ljava/io/FileOutputStream;->write([B)V

    .line 232
    .line 233
    .line 234
    invoke-virtual {v1}, Ljava/io/OutputStream;->flush()V
    :try_end_ec
    .catchall {:try_start_e2 .. :try_end_ec} :catchall_f0

    .line 235
    .line 236
    .line 237
    :try_start_ec
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    :try_end_ef
    .catch Ljava/io/IOException; {:try_start_ec .. :try_end_ef} :catch_104

    .line 238
    .line 239
    .line 240
    goto :goto_104

    .line 241
    :catchall_f0
    move-exception p0

    .line 242
    :try_start_f1
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    :try_end_f4
    .catchall {:try_start_f1 .. :try_end_f4} :catchall_f5

    .line 243
    .line 244
    .line 245
    goto :goto_f9

    .line 246
    :catchall_f5
    move-exception p1

    .line 247
    :try_start_f6
    invoke-virtual {p0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .line 248
    .line 249
    .line 250
    :goto_f9
    throw p0
    :try_end_fa
    .catch Ljava/io/IOException; {:try_start_f6 .. :try_end_fa} :catch_104

    .line 251
    :catchall_fa
    move-exception p0

    .line 252
    :try_start_fb
    invoke-virtual {v1}, Ljava/io/FileInputStream;->close()V
    :try_end_fe
    .catchall {:try_start_fb .. :try_end_fe} :catchall_ff

    .line 253
    .line 254
    .line 255
    goto :goto_103

    .line 256
    :catchall_ff
    move-exception p1

    .line 257
    :try_start_100
    invoke-virtual {p0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .line 258
    .line 259
    .line 260
    :goto_103
    throw p0
    :try_end_104
    .catch Ljava/io/IOException; {:try_start_100 .. :try_end_104} :catch_104

    .line 261
    :catch_104
    :cond_104
    :goto_104
    return-void
.end method
