.class public abstract Lcom/kousei/framework/w4;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static volatile a:Z


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0xbe820dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    const/4 v0, 0x0

    .line 10
    sput-boolean v0, Lcom/kousei/framework/w4;->a:Z

    .line 11
    .line 12
    return-void
.end method

.method public static a(Landroid/content/ContentResolver;Ljava/lang/String;)Z
    .registers 11

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p0, :cond_4

    .line 3
    .line 4
    goto :goto_1c

    .line 5
    :cond_4
    :try_start_4
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    if-nez p0, :cond_14

    .line 10
    .line 11
    invoke-static {}, Landroid/app/ActivityThread;->currentActivityThread()Landroid/app/ActivityThread;

    .line 12
    .line 13
    .line 14
    move-result-object v1

    .line 15
    if-eqz v1, :cond_14

    .line 16
    .line 17
    invoke-virtual {v1}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 18
    .line 19
    .line 20
    move-result-object p0

    .line 21
    :cond_14
    if-eqz p0, :cond_1b

    .line 22
    .line 23
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 24
    .line 25
    .line 26
    move-result-object p0
    :try_end_1a
    .catchall {:try_start_4 .. :try_end_1a} :catchall_1b

    .line 27
    goto :goto_1c

    .line 28
    :catchall_1b
    :cond_1b
    move-object p0, v0

    .line 29
    :goto_1c
    const/4 v1, 0x0

    .line 30
    if-eqz p0, :cond_112

    .line 31
    .line 32
    if-eqz p1, :cond_112

    .line 33
    .line 34
    const-wide v2, -0xbfde0dbb5469L

    .line 35
    .line 36
    .line 37
    .line 38
    .line 39
    :try_start_26
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object v2

    .line 43
    invoke-static {v2, v1}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    .line 44
    .line 45
    .line 46
    move-result v2
    :try_end_2e
    .catchall {:try_start_26 .. :try_end_2e} :catchall_2f

    .line 47
    goto :goto_30

    .line 48
    :catchall_2f
    move v2, v1

    .line 49
    :goto_30
    if-nez v2, :cond_34

    .line 50
    .line 51
    goto/16 :goto_112

    .line 52
    .line 53
    :cond_34
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 54
    .line 55
    .line 56
    move-result v2

    .line 57
    if-lez v2, :cond_112

    .line 58
    .line 59
    const v3, 0x186a0

    .line 60
    .line 61
    .line 62
    rem-int v3, v2, v3

    .line 63
    .line 64
    const/16 v4, 0x2710

    .line 65
    .line 66
    if-ge v3, v4, :cond_45

    .line 67
    .line 68
    goto/16 :goto_112

    .line 69
    .line 70
    :cond_45
    :try_start_45
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    .line 71
    .line 72
    .line 73
    move-result-object v3

    .line 74
    invoke-interface {v3, v2}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 75
    .line 76
    .line 77
    move-result-object v0
    :try_end_4d
    .catchall {:try_start_45 .. :try_end_4d} :catchall_4d

    .line 78
    :catchall_4d
    if-eqz v0, :cond_112

    .line 79
    .line 80
    array-length v2, v0

    .line 81
    if-nez v2, :cond_54

    .line 82
    .line 83
    goto/16 :goto_112

    .line 84
    .line 85
    :cond_54
    const-wide v2, -0xbf0b0dbb5469L

    .line 86
    .line 87
    .line 88
    .line 89
    .line 90
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 91
    .line 92
    .line 93
    move-result-object v2

    .line 94
    invoke-static {p0, v2, v1}, Lcom/kousei/framework/KaoriosFramework;->getGlobalBoolean(Landroid/content/ContentResolver;Ljava/lang/String;Z)Z

    .line 95
    .line 96
    .line 97
    move-result v2

    .line 98
    if-eqz v2, :cond_64

    .line 99
    .line 100
    return v1

    .line 101
    :cond_64
    array-length v2, v0

    .line 102
    move v3, v1

    .line 103
    move v4, v3

    .line 104
    :goto_67
    const/4 v5, 0x1

    .line 105
    if-ge v3, v2, :cond_92

    .line 106
    .line 107
    aget-object v6, v0, v3

    .line 108
    .line 109
    if-nez v6, :cond_6f

    .line 110
    .line 111
    goto :goto_8f

    .line 112
    :cond_6f
    const-wide v7, -0xbf150dbb5469L

    .line 113
    .line 114
    .line 115
    .line 116
    .line 117
    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 118
    .line 119
    .line 120
    move-result-object v7

    .line 121
    invoke-virtual {v7, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 122
    .line 123
    .line 124
    move-result v7

    .line 125
    if-eqz v7, :cond_7f

    .line 126
    .line 127
    return v1

    .line 128
    :cond_7f
    invoke-virtual {v6, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 129
    .line 130
    .line 131
    move-result v7

    .line 132
    if-eqz v7, :cond_86

    .line 133
    .line 134
    return v1

    .line 135
    :cond_86
    :try_start_86
    invoke-static {p0, v6}, Lcom/kousei/framework/KaoriosFramework;->getHideConfig(Landroid/content/ContentResolver;Ljava/lang/String;)Lcom/kousei/framework/o5;

    .line 136
    .line 137
    .line 138
    move-result-object v6

    .line 139
    iget-boolean v6, v6, Lcom/kousei/framework/o5;->b:Z
    :try_end_8c
    .catchall {:try_start_86 .. :try_end_8c} :catchall_8f

    .line 140
    .line 141
    if-eqz v6, :cond_8f

    .line 142
    .line 143
    move v4, v5

    .line 144
    :catchall_8f
    :cond_8f
    :goto_8f
    add-int/lit8 v3, v3, 0x1

    .line 145
    .line 146
    goto :goto_67

    .line 147
    :cond_92
    if-nez v4, :cond_95

    .line 148
    .line 149
    return v1

    .line 150
    :cond_95
    const-wide v2, -0xbf260dbb5469L

    .line 151
    .line 152
    .line 153
    .line 154
    .line 155
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 156
    .line 157
    .line 158
    move-result-object v0

    .line 159
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 160
    .line 161
    .line 162
    move-result v0

    .line 163
    if-nez v0, :cond_e3

    .line 164
    .line 165
    const-wide v2, -0xbf3e0dbb5469L

    .line 166
    .line 167
    .line 168
    .line 169
    .line 170
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 171
    .line 172
    .line 173
    move-result-object v0

    .line 174
    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 175
    .line 176
    .line 177
    move-result v0

    .line 178
    if-nez v0, :cond_e3

    .line 179
    .line 180
    const-wide v2, -0xbf490dbb5469L

    .line 181
    .line 182
    .line 183
    .line 184
    .line 185
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 186
    .line 187
    .line 188
    move-result-object v0

    .line 189
    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 190
    .line 191
    .line 192
    move-result v0

    .line 193
    if-nez v0, :cond_e3

    .line 194
    .line 195
    const-wide v2, -0xbf5e0dbb5469L

    .line 196
    .line 197
    .line 198
    .line 199
    .line 200
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 201
    .line 202
    .line 203
    move-result-object v0

    .line 204
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 205
    .line 206
    .line 207
    move-result v0

    .line 208
    if-nez v0, :cond_e3

    .line 209
    .line 210
    const-wide v2, -0xbf710dbb5469L

    .line 211
    .line 212
    .line 213
    .line 214
    .line 215
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 216
    .line 217
    .line 218
    move-result-object v0

    .line 219
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 220
    .line 221
    .line 222
    move-result p1

    .line 223
    if-eqz p1, :cond_e1

    .line 224
    .line 225
    goto :goto_e3

    .line 226
    :cond_e1
    move p1, v1

    .line 227
    goto :goto_e4

    .line 228
    :cond_e3
    :goto_e3
    move p1, v5

    .line 229
    :goto_e4
    if-eqz p1, :cond_e7

    .line 230
    .line 231
    return v1

    .line 232
    :cond_e7
    sget-boolean p1, Lcom/kousei/framework/w4;->a:Z

    .line 233
    .line 234
    if-nez p1, :cond_111

    .line 235
    .line 236
    const-class p1, Lcom/kousei/framework/w4;

    .line 237
    .line 238
    monitor-enter p1

    .line 239
    :try_start_ee
    sget-boolean v0, Lcom/kousei/framework/w4;->a:Z

    .line 240
    .line 241
    if-eqz v0, :cond_f6

    .line 242
    .line 243
    monitor-exit p1
    :try_end_f3
    .catchall {:try_start_ee .. :try_end_f3} :catchall_f4

    .line 244
    goto :goto_111

    .line 245
    :catchall_f4
    move-exception p0

    .line 246
    goto :goto_10f

    .line 247
    :cond_f6
    const-wide v0, -0xbfe30dbb5469L

    .line 248
    .line 249
    .line 250
    .line 251
    .line 252
    :try_start_fb
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 253
    .line 254
    .line 255
    move-result-object v0

    .line 256
    const-wide v1, -0xbf090dbb5469L

    .line 257
    .line 258
    .line 259
    .line 260
    .line 261
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 262
    .line 263
    .line 264
    move-result-object v1

    .line 265
    invoke-static {p0, v0, v1}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    .line 266
    .line 267
    .line 268
    sput-boolean v5, Lcom/kousei/framework/w4;->a:Z
    :try_end_10d
    .catchall {:try_start_fb .. :try_end_10d} :catchall_10d

    .line 269
    .line 270
    :catchall_10d
    :try_start_10d
    monitor-exit p1

    .line 271
    goto :goto_111

    .line 272
    :goto_10f
    monitor-exit p1
    :try_end_110
    .catchall {:try_start_10d .. :try_end_110} :catchall_f4

    .line 273
    throw p0

    .line 274
    :cond_111
    :goto_111
    return v5

    .line 275
    :cond_112
    :goto_112
    return v1
.end method
