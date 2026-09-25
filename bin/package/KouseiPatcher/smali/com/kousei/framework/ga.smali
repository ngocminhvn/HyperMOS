.class public abstract Lcom/kousei/framework/ga;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final a:Ljava/lang/Object;

.field public static volatile b:Ljava/lang/String;

.field public static volatile c:Ljava/util/Map;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0x95a60dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    const-wide v0, -0x95cb0dbb5469L

    .line 10
    .line 11
    .line 12
    .line 13
    .line 14
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 15
    .line 16
    .line 17
    const-wide v0, -0x95c00dbb5469L

    .line 18
    .line 19
    .line 20
    .line 21
    .line 22
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    const-wide v0, -0x95d90dbb5469L

    .line 26
    .line 27
    .line 28
    .line 29
    .line 30
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 31
    .line 32
    .line 33
    new-instance v0, Ljava/lang/Object;

    .line 34
    .line 35
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 36
    .line 37
    .line 38
    sput-object v0, Lcom/kousei/framework/ga;->a:Ljava/lang/Object;

    .line 39
    .line 40
    const/4 v0, 0x0

    .line 41
    sput-object v0, Lcom/kousei/framework/ga;->b:Ljava/lang/String;

    .line 42
    .line 43
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 44
    .line 45
    sput-object v0, Lcom/kousei/framework/ga;->c:Ljava/util/Map;

    .line 46
    .line 47
    return-void
.end method

.method public static a(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 11

    .line 1
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-lez v0, :cond_113

    .line 6
    .line 7
    const v1, 0x186a0

    .line 8
    .line 9
    .line 10
    rem-int v1, v0, v1

    .line 11
    .line 12
    const/16 v2, 0x2710

    .line 13
    .line 14
    if-ge v1, v2, :cond_11

    .line 15
    .line 16
    goto/16 :goto_113

    .line 17
    .line 18
    :cond_11
    const/4 v1, 0x0

    .line 19
    if-eqz p0, :cond_15

    .line 20
    .line 21
    goto :goto_2d

    .line 22
    :cond_15
    :try_start_15
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    .line 23
    .line 24
    .line 25
    move-result-object p0

    .line 26
    if-nez p0, :cond_25

    .line 27
    .line 28
    invoke-static {}, Landroid/app/ActivityThread;->currentActivityThread()Landroid/app/ActivityThread;

    .line 29
    .line 30
    .line 31
    move-result-object v2

    .line 32
    if-eqz v2, :cond_25

    .line 33
    .line 34
    invoke-virtual {v2}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 35
    .line 36
    .line 37
    move-result-object p0

    .line 38
    :cond_25
    if-nez p0, :cond_29

    .line 39
    .line 40
    :catchall_27
    move-object p0, v1

    .line 41
    goto :goto_2d

    .line 42
    :cond_29
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 43
    .line 44
    .line 45
    move-result-object p0
    :try_end_2d
    .catchall {:try_start_15 .. :try_end_2d} :catchall_27

    .line 46
    :goto_2d
    if-nez p1, :cond_31

    .line 47
    .line 48
    :cond_2f
    move-object p1, v1

    .line 49
    goto :goto_68

    .line 50
    :cond_31
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object p1

    .line 54
    sget-object v2, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    .line 55
    .line 56
    invoke-virtual {p1, v2}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    .line 57
    .line 58
    .line 59
    move-result-object p1

    .line 60
    const-wide v2, -0x95930dbb5469L

    .line 61
    .line 62
    .line 63
    .line 64
    .line 65
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 66
    .line 67
    .line 68
    move-result-object v2

    .line 69
    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 70
    .line 71
    .line 72
    move-result v2

    .line 73
    if-nez v2, :cond_68

    .line 74
    .line 75
    const-wide v2, -0x95a80dbb5469L

    .line 76
    .line 77
    .line 78
    .line 79
    .line 80
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 81
    .line 82
    .line 83
    move-result-object v2

    .line 84
    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 85
    .line 86
    .line 87
    move-result v2

    .line 88
    if-nez v2, :cond_68

    .line 89
    .line 90
    const-wide v2, -0x95a10dbb5469L

    .line 91
    .line 92
    .line 93
    .line 94
    .line 95
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 96
    .line 97
    .line 98
    move-result-object v2

    .line 99
    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 100
    .line 101
    .line 102
    move-result v2

    .line 103
    if-eqz v2, :cond_2f

    .line 104
    .line 105
    :cond_68
    :goto_68
    if-eqz p0, :cond_113

    .line 106
    .line 107
    if-eqz p1, :cond_113

    .line 108
    .line 109
    if-eqz p2, :cond_113

    .line 110
    .line 111
    const-wide v2, -0x922e0dbb5469L

    .line 112
    .line 113
    .line 114
    .line 115
    .line 116
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 117
    .line 118
    .line 119
    move-result-object v2

    .line 120
    const/4 v3, 0x0

    .line 121
    invoke-static {p0, v2, v3}, Lcom/kousei/framework/KaoriosFramework;->getGlobalBoolean(Landroid/content/ContentResolver;Ljava/lang/String;Z)Z

    .line 122
    .line 123
    .line 124
    move-result v2

    .line 125
    if-nez v2, :cond_80

    .line 126
    .line 127
    goto/16 :goto_113

    .line 128
    .line 129
    :cond_80
    :try_start_80
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    .line 130
    .line 131
    .line 132
    move-result-object v2

    .line 133
    invoke-interface {v2, v0}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 134
    .line 135
    .line 136
    move-result-object v0
    :try_end_88
    .catchall {:try_start_80 .. :try_end_88} :catchall_89

    .line 137
    goto :goto_8a

    .line 138
    :catchall_89
    move-object v0, v1

    .line 139
    :goto_8a
    if-eqz v0, :cond_113

    .line 140
    .line 141
    array-length v2, v0

    .line 142
    const/4 v4, 0x1

    .line 143
    if-eq v2, v4, :cond_92

    .line 144
    .line 145
    goto/16 :goto_113

    .line 146
    .line 147
    :cond_92
    const-wide v4, -0x925d0dbb5469L

    .line 148
    .line 149
    .line 150
    .line 151
    .line 152
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 153
    .line 154
    .line 155
    move-result-object v2

    .line 156
    const-wide v4, -0x92660dbb5469L

    .line 157
    .line 158
    .line 159
    .line 160
    .line 161
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 162
    .line 163
    .line 164
    move-result-object v4

    .line 165
    invoke-static {p0, v2, v4}, Lcom/kousei/framework/KaoriosFramework;->getGlobalString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 166
    .line 167
    .line 168
    move-result-object p0

    .line 169
    if-nez p0, :cond_b3

    .line 170
    .line 171
    const-wide v4, -0x92790dbb5469L

    .line 172
    .line 173
    .line 174
    .line 175
    .line 176
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 177
    .line 178
    .line 179
    move-result-object p0

    .line 180
    :cond_b3
    sget-object v2, Lcom/kousei/framework/ga;->b:Ljava/lang/String;

    .line 181
    .line 182
    invoke-virtual {p0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 183
    .line 184
    .line 185
    move-result v2

    .line 186
    if-eqz v2, :cond_be

    .line 187
    .line 188
    sget-object p0, Lcom/kousei/framework/ga;->c:Ljava/util/Map;

    .line 189
    .line 190
    goto :goto_da

    .line 191
    :cond_be
    sget-object v2, Lcom/kousei/framework/ga;->a:Ljava/lang/Object;

    .line 192
    .line 193
    monitor-enter v2

    .line 194
    :try_start_c1
    sget-object v4, Lcom/kousei/framework/ga;->b:Ljava/lang/String;

    .line 195
    .line 196
    invoke-virtual {p0, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 197
    .line 198
    .line 199
    move-result v4

    .line 200
    if-eqz v4, :cond_cf

    .line 201
    .line 202
    sget-object p0, Lcom/kousei/framework/ga;->c:Ljava/util/Map;

    .line 203
    .line 204
    monitor-exit v2

    .line 205
    goto :goto_da

    .line 206
    :catchall_cd
    move-exception p0

    .line 207
    goto :goto_111

    .line 208
    :cond_cf
    invoke-static {p0}, Lcom/kousei/framework/ga;->b(Ljava/lang/String;)Ljava/util/Map;

    .line 209
    .line 210
    .line 211
    move-result-object v4

    .line 212
    sput-object v4, Lcom/kousei/framework/ga;->c:Ljava/util/Map;

    .line 213
    .line 214
    sput-object p0, Lcom/kousei/framework/ga;->b:Ljava/lang/String;

    .line 215
    .line 216
    sget-object p0, Lcom/kousei/framework/ga;->c:Ljava/util/Map;

    .line 217
    .line 218
    monitor-exit v2
    :try_end_da
    .catchall {:try_start_c1 .. :try_end_da} :catchall_cd

    .line 219
    :goto_da
    array-length v2, v0

    .line 220
    :goto_db
    if-ge v3, v2, :cond_113

    .line 221
    .line 222
    aget-object v4, v0, v3

    .line 223
    .line 224
    const-wide v5, -0x92480dbb5469L

    .line 225
    .line 226
    .line 227
    .line 228
    .line 229
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 230
    .line 231
    .line 232
    move-result-object v5

    .line 233
    invoke-virtual {v5, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 234
    .line 235
    .line 236
    move-result v5

    .line 237
    if-eqz v5, :cond_ef

    .line 238
    .line 239
    goto :goto_113

    .line 240
    :cond_ef
    invoke-interface {p0, v4}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 241
    .line 242
    .line 243
    move-result-object v4

    .line 244
    check-cast v4, Ljava/util/Map;

    .line 245
    .line 246
    if-nez v4, :cond_f9

    .line 247
    .line 248
    move-object v4, v1

    .line 249
    goto :goto_ff

    .line 250
    :cond_f9
    invoke-interface {v4, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 251
    .line 252
    .line 253
    move-result-object v4

    .line 254
    check-cast v4, Ljava/util/Map;

    .line 255
    .line 256
    :goto_ff
    if-eqz v4, :cond_10e

    .line 257
    .line 258
    invoke-interface {v4, p2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    .line 259
    .line 260
    .line 261
    move-result v5

    .line 262
    if-eqz v5, :cond_10e

    .line 263
    .line 264
    invoke-interface {v4, p2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 265
    .line 266
    .line 267
    move-result-object p0

    .line 268
    check-cast p0, Ljava/lang/String;

    .line 269
    .line 270
    return-object p0

    .line 271
    :cond_10e
    add-int/lit8 v3, v3, 0x1

    .line 272
    .line 273
    goto :goto_db

    .line 274
    :goto_111
    :try_start_111
    monitor-exit v2
    :try_end_112
    .catchall {:try_start_111 .. :try_end_112} :catchall_cd

    .line 275
    throw p0

    .line 276
    :cond_113
    :goto_113
    return-object p3
.end method

.method public static b(Ljava/lang/String;)Ljava/util/Map;
    .registers 20

    .line 1
    invoke-virtual/range {p0 .. p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    if-nez v0, :cond_12e

    .line 10
    .line 11
    invoke-virtual/range {p0 .. p0}, Ljava/lang/String;->length()I

    .line 12
    .line 13
    .line 14
    move-result v0

    .line 15
    const/high16 v1, 0x40000

    .line 16
    .line 17
    if-le v0, v1, :cond_14

    .line 18
    .line 19
    goto/16 :goto_12e

    .line 20
    .line 21
    :cond_14
    :try_start_14
    new-instance v0, Lorg/json/JSONObject;

    .line 22
    .line 23
    move-object/from16 v1, p0

    .line 24
    .line 25
    invoke-direct {v0, v1}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 26
    .line 27
    .line 28
    const-wide v1, -0x92780dbb5469L

    .line 29
    .line 30
    .line 31
    .line 32
    .line 33
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 34
    .line 35
    .line 36
    move-result-object v1

    .line 37
    invoke-virtual {v0, v1}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    if-nez v1, :cond_2d

    .line 42
    .line 43
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 44
    .line 45
    return-object v0

    .line 46
    :cond_2d
    const-wide v2, -0x927f0dbb5469L

    .line 47
    .line 48
    .line 49
    .line 50
    .line 51
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 52
    .line 53
    .line 54
    move-result-object v2

    .line 55
    const/4 v3, 0x1

    .line 56
    invoke-virtual {v0, v2, v3}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;I)I

    .line 57
    .line 58
    .line 59
    move-result v0

    .line 60
    const/4 v2, 0x2

    .line 61
    if-lt v0, v2, :cond_3f

    .line 62
    .line 63
    goto :goto_40

    .line 64
    :cond_3f
    const/4 v3, 0x0

    .line 65
    :goto_40
    new-instance v0, Ljava/util/HashMap;

    .line 66
    .line 67
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 68
    .line 69
    .line 70
    invoke-virtual {v1}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    .line 71
    .line 72
    .line 73
    move-result-object v2

    .line 74
    const/4 v5, 0x0

    .line 75
    :goto_4a
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 76
    .line 77
    .line 78
    move-result v6

    .line 79
    if-eqz v6, :cond_126

    .line 80
    .line 81
    add-int/lit8 v6, v5, 0x1

    .line 82
    .line 83
    const/16 v7, 0x400

    .line 84
    .line 85
    if-ge v5, v7, :cond_126

    .line 86
    .line 87
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 88
    .line 89
    .line 90
    move-result-object v5

    .line 91
    check-cast v5, Ljava/lang/String;

    .line 92
    .line 93
    invoke-virtual {v1, v5}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 94
    .line 95
    .line 96
    move-result-object v7

    .line 97
    if-nez v7, :cond_68

    .line 98
    .line 99
    move-object/from16 v17, v1

    .line 100
    .line 101
    move-object/from16 v18, v2

    .line 102
    .line 103
    goto/16 :goto_11f

    .line 104
    .line 105
    :cond_68
    new-instance v8, Ljava/util/HashMap;

    .line 106
    .line 107
    invoke-direct {v8}, Ljava/util/HashMap;-><init>()V

    .line 108
    .line 109
    .line 110
    if-eqz v3, :cond_8f

    .line 111
    .line 112
    const-wide v9, -0x92770dbb5469L

    .line 113
    .line 114
    .line 115
    .line 116
    .line 117
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 118
    .line 119
    .line 120
    move-result-object v9

    .line 121
    const-wide v10, -0x958c0dbb5469L

    .line 122
    .line 123
    .line 124
    .line 125
    .line 126
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 127
    .line 128
    .line 129
    move-result-object v10

    .line 130
    const-wide v11, -0x95850dbb5469L

    .line 131
    .line 132
    .line 133
    .line 134
    .line 135
    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 136
    .line 137
    .line 138
    move-result-object v11

    .line 139
    filled-new-array {v9, v10, v11}, [Ljava/lang/String;

    .line 140
    .line 141
    .line 142
    move-result-object v9

    .line 143
    goto :goto_9c

    .line 144
    :cond_8f
    const-wide v9, -0x959a0dbb5469L

    .line 145
    .line 146
    .line 147
    .line 148
    .line 149
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 150
    .line 151
    .line 152
    move-result-object v9

    .line 153
    filled-new-array {v9}, [Ljava/lang/String;

    .line 154
    .line 155
    .line 156
    move-result-object v9

    .line 157
    :goto_9c
    array-length v10, v9

    .line 158
    const/4 v11, 0x0

    .line 159
    :goto_9e
    if-ge v11, v10, :cond_10e

    .line 160
    .line 161
    aget-object v12, v9, v11

    .line 162
    .line 163
    if-eqz v3, :cond_a9

    .line 164
    .line 165
    invoke-virtual {v7, v12}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    .line 166
    .line 167
    .line 168
    move-result-object v13

    .line 169
    goto :goto_aa

    .line 170
    :cond_a9
    move-object v13, v7

    .line 171
    :goto_aa
    if-nez v13, :cond_b1

    .line 172
    .line 173
    move-object/from16 v17, v1

    .line 174
    .line 175
    move-object/from16 v18, v2

    .line 176
    .line 177
    goto :goto_107

    .line 178
    :cond_b1
    new-instance v14, Ljava/util/HashMap;

    .line 179
    .line 180
    invoke-direct {v14}, Ljava/util/HashMap;-><init>()V

    .line 181
    .line 182
    .line 183
    invoke-virtual {v13}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    .line 184
    .line 185
    .line 186
    move-result-object v15

    .line 187
    const/4 v4, 0x0

    .line 188
    :goto_bb
    invoke-interface {v15}, Ljava/util/Iterator;->hasNext()Z

    .line 189
    .line 190
    .line 191
    move-result v16

    .line 192
    if-eqz v16, :cond_f7

    .line 193
    .line 194
    add-int/lit8 v16, v4, 0x1

    .line 195
    .line 196
    move-object/from16 v17, v1

    .line 197
    .line 198
    const/16 v1, 0x40

    .line 199
    .line 200
    if-ge v4, v1, :cond_f4

    .line 201
    .line 202
    invoke-interface {v15}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 203
    .line 204
    .line 205
    move-result-object v1

    .line 206
    check-cast v1, Ljava/lang/String;

    .line 207
    .line 208
    invoke-virtual {v13, v1}, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;

    .line 209
    .line 210
    .line 211
    move-result-object v4

    .line 212
    if-eqz v1, :cond_eb

    .line 213
    .line 214
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    .line 215
    .line 216
    .line 217
    move-result v18

    .line 218
    if-nez v18, :cond_eb

    .line 219
    .line 220
    if-eqz v4, :cond_eb

    .line 221
    .line 222
    move-object/from16 v18, v2

    .line 223
    .line 224
    sget-object v2, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    .line 225
    .line 226
    if-eq v4, v2, :cond_ed

    .line 227
    .line 228
    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    .line 229
    .line 230
    .line 231
    move-result-object v2

    .line 232
    invoke-virtual {v14, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 233
    .line 234
    .line 235
    goto :goto_ed

    .line 236
    :cond_eb
    move-object/from16 v18, v2

    .line 237
    .line 238
    :cond_ed
    :goto_ed
    move/from16 v4, v16

    .line 239
    .line 240
    move-object/from16 v1, v17

    .line 241
    .line 242
    move-object/from16 v2, v18

    .line 243
    .line 244
    goto :goto_bb

    .line 245
    :cond_f4
    :goto_f4
    move-object/from16 v18, v2

    .line 246
    .line 247
    goto :goto_fa

    .line 248
    :cond_f7
    move-object/from16 v17, v1

    .line 249
    .line 250
    goto :goto_f4

    .line 251
    :goto_fa
    invoke-virtual {v14}, Ljava/util/HashMap;->isEmpty()Z

    .line 252
    .line 253
    .line 254
    move-result v1

    .line 255
    if-nez v1, :cond_107

    .line 256
    .line 257
    invoke-static {v14}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 258
    .line 259
    .line 260
    move-result-object v1

    .line 261
    invoke-virtual {v8, v12, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 262
    .line 263
    .line 264
    :cond_107
    :goto_107
    add-int/lit8 v11, v11, 0x1

    .line 265
    .line 266
    move-object/from16 v1, v17

    .line 267
    .line 268
    move-object/from16 v2, v18

    .line 269
    .line 270
    goto :goto_9e

    .line 271
    :cond_10e
    move-object/from16 v17, v1

    .line 272
    .line 273
    move-object/from16 v18, v2

    .line 274
    .line 275
    invoke-virtual {v8}, Ljava/util/HashMap;->isEmpty()Z

    .line 276
    .line 277
    .line 278
    move-result v1

    .line 279
    if-nez v1, :cond_11f

    .line 280
    .line 281
    invoke-static {v8}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 282
    .line 283
    .line 284
    move-result-object v1

    .line 285
    invoke-virtual {v0, v5, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 286
    .line 287
    .line 288
    :cond_11f
    :goto_11f
    move v5, v6

    .line 289
    move-object/from16 v1, v17

    .line 290
    .line 291
    move-object/from16 v2, v18

    .line 292
    .line 293
    goto/16 :goto_4a

    .line 294
    .line 295
    :cond_126
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    .line 296
    .line 297
    .line 298
    move-result-object v0
    :try_end_12a
    .catchall {:try_start_14 .. :try_end_12a} :catchall_12b

    .line 299
    return-object v0

    .line 300
    :catchall_12b
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 301
    .line 302
    return-object v0

    .line 303
    :cond_12e
    :goto_12e
    sget-object v0, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 304
    .line 305
    return-object v0
.end method
