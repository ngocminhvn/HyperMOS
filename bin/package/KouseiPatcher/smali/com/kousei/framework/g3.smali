.class public final Lcom/kousei/framework/g3;
.super Ljava/lang/Object;


# direct methods
.method public static a(Ljava/util/HashMap;Lcom/kousei/framework/u;)V
    .registers 6

    .line 1
    :try_start_0
    new-instance v0, Lcom/kousei/framework/j0;

    .line 2
    .line 3
    sget-object v1, Lcom/kousei/framework/l2;->a:Lcom/kousei/framework/l2;

    .line 4
    .line 5
    invoke-direct {v0, p1, v1}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V

    .line 6
    .line 7
    .line 8
    new-instance v1, Lcom/kousei/framework/j0;

    .line 9
    .line 10
    sget-object v2, Lcom/kousei/framework/e7;->g:Lcom/kousei/framework/u;

    .line 11
    .line 12
    invoke-direct {v1, v2, v0}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V

    .line 13
    .line 14
    .line 15
    new-instance v2, Lcom/kousei/framework/t7;

    .line 16
    .line 17
    sget-object v3, Lcom/kousei/framework/t7;->f:Lcom/kousei/framework/j0;

    .line 18
    .line 19
    invoke-direct {v2}, Ljava/lang/Object;-><init>()V

    .line 20
    .line 21
    .line 22
    iput-object v0, v2, Lcom/kousei/framework/t7;->a:Lcom/kousei/framework/j0;

    .line 23
    .line 24
    iput-object v1, v2, Lcom/kousei/framework/t7;->b:Lcom/kousei/framework/j0;

    .line 25
    .line 26
    iput-object v3, v2, Lcom/kousei/framework/t7;->c:Lcom/kousei/framework/j0;

    .line 27
    .line 28
    invoke-virtual {v2}, Lcom/kousei/framework/r;->h()[B

    .line 29
    .line 30
    .line 31
    new-instance v0, Lcom/kousei/framework/g3;

    .line 32
    .line 33
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 34
    .line 35
    .line 36
    invoke-virtual {p0, p1, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_26
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_26} :catch_27

    .line 37
    .line 38
    .line 39
    return-void

    .line 40
    :catch_27
    move-exception p0

    .line 41
    new-instance p1, Ljava/lang/RuntimeException;

    .line 42
    .line 43
    invoke-direct {p1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    .line 44
    .line 45
    .line 46
    throw p1
.end method

.method public static b(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p0, :cond_57

    .line 3
    .line 4
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    .line 5
    .line 6
    .line 7
    move-result v1

    .line 8
    if-eqz v1, :cond_a

    .line 9
    .line 10
    goto :goto_57

    .line 11
    :cond_a
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 12
    .line 13
    .line 14
    move-result-object p0

    .line 15
    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    .line 16
    .line 17
    invoke-virtual {p0, v1}, Ljava/lang/String;->toUpperCase(Ljava/util/Locale;)Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object p0

    .line 21
    const-wide v1, -0xa3ea0dbb5469L

    .line 22
    .line 23
    .line 24
    .line 25
    .line 26
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 27
    .line 28
    .line 29
    move-result-object v1

    .line 30
    invoke-virtual {v1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 31
    .line 32
    .line 33
    move-result v1

    .line 34
    if-nez v1, :cond_4d

    .line 35
    .line 36
    const-wide v1, -0xa3ef0dbb5469L

    .line 37
    .line 38
    .line 39
    .line 40
    .line 41
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 42
    .line 43
    .line 44
    move-result-object v1

    .line 45
    invoke-virtual {v1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 46
    .line 47
    .line 48
    move-result v1

    .line 49
    if-eqz v1, :cond_33

    .line 50
    .line 51
    goto :goto_4d

    .line 52
    :cond_33
    const-wide v1, -0xa3e60dbb5469L

    .line 53
    .line 54
    .line 55
    .line 56
    .line 57
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 58
    .line 59
    .line 60
    move-result-object v1

    .line 61
    invoke-virtual {v1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 62
    .line 63
    .line 64
    move-result p0

    .line 65
    if-eqz p0, :cond_4c

    .line 66
    .line 67
    const-wide v0, -0xa3fa0dbb5469L

    .line 68
    .line 69
    .line 70
    .line 71
    .line 72
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 73
    .line 74
    .line 75
    move-result-object p0

    .line 76
    return-object p0

    .line 77
    :cond_4c
    return-object v0

    .line 78
    :cond_4d
    :goto_4d
    const-wide v0, -0xa3e50dbb5469L

    .line 79
    .line 80
    .line 81
    .line 82
    .line 83
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 84
    .line 85
    .line 86
    move-result-object p0

    .line 87
    return-object p0

    .line 88
    :cond_57
    :goto_57
    return-object v0
.end method

.method public static c(Ljava/lang/String;)Lcom/kousei/framework/o4;
    .registers 4

    .line 1
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

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
    if-eqz v0, :cond_14

    .line 10
    .line 11
    new-instance p0, Lcom/kousei/framework/o4;

    .line 12
    .line 13
    sget-object v0, Lcom/kousei/framework/s5;->b:Lcom/kousei/framework/s5;

    .line 14
    .line 15
    sget-object v1, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 16
    .line 17
    invoke-direct {p0, v0, v1}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 18
    .line 19
    .line 20
    return-object p0

    .line 21
    :cond_14
    const/4 v0, 0x0

    .line 22
    :try_start_15
    invoke-static {p0}, Lcom/kousei/framework/g3;->e(Ljava/lang/String;)Ljava/util/HashMap;

    .line 23
    .line 24
    .line 25
    move-result-object p0

    .line 26
    if-eqz p0, :cond_2f

    .line 27
    .line 28
    invoke-interface {p0}, Ljava/util/Map;->isEmpty()Z

    .line 29
    .line 30
    .line 31
    move-result v1

    .line 32
    if-eqz v1, :cond_22

    .line 33
    .line 34
    goto :goto_2f

    .line 35
    :cond_22
    new-instance v1, Lcom/kousei/framework/u5;

    .line 36
    .line 37
    invoke-direct {v1, p0}, Lcom/kousei/framework/u5;-><init>(Ljava/util/Map;)V

    .line 38
    .line 39
    .line 40
    new-instance p0, Lcom/kousei/framework/o4;

    .line 41
    .line 42
    sget-object v2, Lcom/kousei/framework/s5;->a:Lcom/kousei/framework/s5;

    .line 43
    .line 44
    invoke-direct {p0, v2, v1}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 45
    .line 46
    .line 47
    return-object p0

    .line 48
    :cond_2f
    :goto_2f
    new-instance p0, Lcom/kousei/framework/o4;

    .line 49
    .line 50
    sget-object v1, Lcom/kousei/framework/s5;->c:Lcom/kousei/framework/s5;

    .line 51
    .line 52
    invoke-direct {p0, v1, v0}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V
    :try_end_36
    .catch Ljava/lang/Exception; {:try_start_15 .. :try_end_36} :catch_37

    .line 53
    .line 54
    .line 55
    return-object p0

    .line 56
    :catch_37
    new-instance p0, Lcom/kousei/framework/o4;

    .line 57
    .line 58
    sget-object v1, Lcom/kousei/framework/s5;->c:Lcom/kousei/framework/s5;

    .line 59
    .line 60
    invoke-direct {p0, v1, v0}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 61
    .line 62
    .line 63
    return-object p0
.end method

.method public static d(Ljava/lang/String;)[B
    .registers 4

    .line 1
    const-wide v0, -0xa5920dbb5469L

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
    const-wide v1, -0xa5b80dbb5469L

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
    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 20
    .line 21
    .line 22
    move-result-object p0

    .line 23
    const-wide v0, -0xa5bb0dbb5469L

    .line 24
    .line 25
    .line 26
    .line 27
    .line 28
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 29
    .line 30
    .line 31
    move-result-object v0

    .line 32
    const-wide v1, -0xa5cf0dbb5469L

    .line 33
    .line 34
    .line 35
    .line 36
    .line 37
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 42
    .line 43
    .line 44
    move-result-object p0

    .line 45
    const-wide v0, -0xa5ce0dbb5469L

    .line 46
    .line 47
    .line 48
    .line 49
    .line 50
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object v0

    .line 54
    const-wide v1, -0xa5c30dbb5469L

    .line 55
    .line 56
    .line 57
    .line 58
    .line 59
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 60
    .line 61
    .line 62
    move-result-object v1

    .line 63
    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    .line 68
    .line 69
    .line 70
    move-result-object v0

    .line 71
    invoke-virtual {v0, p0}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    .line 72
    .line 73
    .line 74
    move-result-object p0

    .line 75
    return-object p0
.end method

.method public static e(Ljava/lang/String;)Ljava/util/HashMap;
    .registers 31

    .line 1
    new-instance v0, Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 4
    .line 5
    .line 6
    invoke-virtual/range {p0 .. p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v1

    .line 10
    const-wide v2, -0xa5c20dbb5469L

    .line 11
    .line 12
    .line 13
    .line 14
    .line 15
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 16
    .line 17
    .line 18
    move-result-object v2

    .line 19
    const-wide v3, -0xa5c40dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v3

    .line 28
    const-wide v4, -0xa5c60dbb5469L

    .line 29
    .line 30
    .line 31
    .line 32
    .line 33
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 34
    .line 35
    .line 36
    move-result-object v4

    .line 37
    filled-new-array {v2, v3, v4}, [Ljava/lang/String;

    .line 38
    .line 39
    .line 40
    move-result-object v2

    .line 41
    const/4 v3, 0x0

    .line 42
    move v4, v3

    .line 43
    :goto_2a
    const/4 v5, 0x3

    .line 44
    if-ge v4, v5, :cond_40

    .line 45
    .line 46
    aget-object v5, v2, v4

    .line 47
    .line 48
    invoke-virtual {v1, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 49
    .line 50
    .line 51
    move-result v6

    .line 52
    if-eqz v6, :cond_3d

    .line 53
    .line 54
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    .line 55
    .line 56
    .line 57
    move-result v5

    .line 58
    invoke-virtual {v1, v5}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    .line 59
    .line 60
    .line 61
    move-result-object v1

    .line 62
    :cond_3d
    add-int/lit8 v4, v4, 0x1

    .line 63
    .line 64
    goto :goto_2a

    .line 65
    :cond_40
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 66
    .line 67
    .line 68
    move-result-object v1

    .line 69
    invoke-static {}, Lorg/xmlpull/v1/XmlPullParserFactory;->newInstance()Lorg/xmlpull/v1/XmlPullParserFactory;

    .line 70
    .line 71
    .line 72
    move-result-object v2

    .line 73
    invoke-virtual {v2}, Lorg/xmlpull/v1/XmlPullParserFactory;->newPullParser()Lorg/xmlpull/v1/XmlPullParser;

    .line 74
    .line 75
    .line 76
    move-result-object v2

    .line 77
    const-wide v6, -0xa3fe0dbb5469L

    .line 78
    .line 79
    .line 80
    .line 81
    .line 82
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 83
    .line 84
    .line 85
    move-result-object v4

    .line 86
    invoke-interface {v2, v4, v3}, Lorg/xmlpull/v1/XmlPullParser;->setFeature(Ljava/lang/String;Z)V

    .line 87
    .line 88
    .line 89
    new-instance v4, Ljava/io/StringReader;

    .line 90
    .line 91
    invoke-direct {v4, v1}, Ljava/io/StringReader;-><init>(Ljava/lang/String;)V

    .line 92
    .line 93
    .line 94
    invoke-interface {v2, v4}, Lorg/xmlpull/v1/XmlPullParser;->setInput(Ljava/io/Reader;)V

    .line 95
    .line 96
    .line 97
    new-instance v1, Ljava/util/ArrayList;

    .line 98
    .line 99
    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 100
    .line 101
    .line 102
    invoke-interface {v2}, Lorg/xmlpull/v1/XmlPullParser;->getEventType()I

    .line 103
    .line 104
    .line 105
    move-result v4

    .line 106
    move v7, v3

    .line 107
    move v8, v7

    .line 108
    move v9, v8

    .line 109
    move v11, v9

    .line 110
    const/4 v10, 0x0

    .line 111
    const/4 v12, 0x0

    .line 112
    :goto_6f
    const/4 v13, 0x1

    .line 113
    if-eq v4, v13, :cond_47e

    .line 114
    .line 115
    invoke-interface {v2}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    .line 116
    .line 117
    .line 118
    move-result-object v14

    .line 119
    const/4 v15, 0x2

    .line 120
    if-eq v4, v15, :cond_40a

    .line 121
    .line 122
    if-eq v4, v5, :cond_c9

    .line 123
    .line 124
    const/4 v14, 0x4

    .line 125
    if-eq v4, v14, :cond_83

    .line 126
    .line 127
    :cond_7e
    :goto_7e
    move/from16 v20, v7

    .line 128
    .line 129
    const/4 v5, 0x0

    .line 130
    goto/16 :goto_42e

    .line 131
    .line 132
    :cond_83
    invoke-interface {v2}, Lorg/xmlpull/v1/XmlPullParser;->getText()Ljava/lang/String;

    .line 133
    .line 134
    .line 135
    move-result-object v4

    .line 136
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 137
    .line 138
    .line 139
    move-result-object v4

    .line 140
    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    .line 141
    .line 142
    .line 143
    move-result v14

    .line 144
    if-nez v14, :cond_7e

    .line 145
    .line 146
    if-eqz v7, :cond_9f

    .line 147
    .line 148
    if-nez v10, :cond_97

    .line 149
    .line 150
    :goto_95
    move-object v10, v4

    .line 151
    goto :goto_9c

    .line 152
    :cond_97
    invoke-virtual {v10, v4}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 153
    .line 154
    .line 155
    move-result-object v4

    .line 156
    goto :goto_95

    .line 157
    :goto_9c
    const/4 v5, 0x0

    .line 158
    goto/16 :goto_476

    .line 159
    .line 160
    :cond_9f
    if-eqz v9, :cond_7e

    .line 161
    .line 162
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 163
    .line 164
    .line 165
    move-result v14

    .line 166
    if-eqz v14, :cond_ab

    .line 167
    .line 168
    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 169
    .line 170
    .line 171
    goto :goto_7e

    .line 172
    :cond_ab
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    .line 173
    .line 174
    .line 175
    move-result v14

    .line 176
    sub-int/2addr v14, v13

    .line 177
    invoke-virtual {v1, v14}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    .line 178
    .line 179
    .line 180
    move-result-object v13

    .line 181
    check-cast v13, Ljava/lang/String;

    .line 182
    .line 183
    new-instance v14, Ljava/lang/StringBuilder;

    .line 184
    .line 185
    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    .line 186
    .line 187
    .line 188
    invoke-virtual {v14, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 189
    .line 190
    .line 191
    invoke-virtual {v14, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 192
    .line 193
    .line 194
    invoke-virtual {v14}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 195
    .line 196
    .line 197
    move-result-object v4

    .line 198
    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 199
    .line 200
    .line 201
    goto :goto_7e

    .line 202
    :cond_c9
    const-wide v15, -0xa3600dbb5469L

    .line 203
    .line 204
    .line 205
    .line 206
    .line 207
    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 208
    .line 209
    .line 210
    move-result-object v4

    .line 211
    invoke-virtual {v4, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 212
    .line 213
    .line 214
    move-result v4

    .line 215
    if-eqz v4, :cond_da

    .line 216
    .line 217
    move v7, v3

    .line 218
    goto :goto_9c

    .line 219
    :cond_da
    const-wide v15, -0xa37d0dbb5469L

    .line 220
    .line 221
    .line 222
    .line 223
    .line 224
    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 225
    .line 226
    .line 227
    move-result-object v4

    .line 228
    invoke-virtual {v4, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 229
    .line 230
    .line 231
    move-result v4

    .line 232
    if-eqz v4, :cond_103

    .line 233
    .line 234
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 235
    .line 236
    .line 237
    move-result v4

    .line 238
    if-nez v4, :cond_101

    .line 239
    .line 240
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    .line 241
    .line 242
    .line 243
    move-result v4

    .line 244
    sub-int/2addr v4, v13

    .line 245
    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    .line 246
    .line 247
    .line 248
    move-result-object v4

    .line 249
    check-cast v4, Ljava/lang/String;

    .line 250
    .line 251
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 252
    .line 253
    .line 254
    move-result-object v4

    .line 255
    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 256
    .line 257
    .line 258
    :cond_101
    move v9, v3

    .line 259
    goto :goto_9c

    .line 260
    :cond_103
    const-wide v15, -0xa2890dbb5469L

    .line 261
    .line 262
    .line 263
    .line 264
    .line 265
    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 266
    .line 267
    .line 268
    move-result-object v4

    .line 269
    invoke-virtual {v4, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 270
    .line 271
    .line 272
    move-result v4

    .line 273
    if-eqz v4, :cond_114

    .line 274
    .line 275
    move v11, v3

    .line 276
    goto :goto_9c

    .line 277
    :cond_114
    const-wide v15, -0xa2980dbb5469L

    .line 278
    .line 279
    .line 280
    .line 281
    .line 282
    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 283
    .line 284
    .line 285
    move-result-object v4

    .line 286
    invoke-virtual {v4, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 287
    .line 288
    .line 289
    move-result v4

    .line 290
    if-eqz v4, :cond_7e

    .line 291
    .line 292
    if-eqz v12, :cond_137

    .line 293
    .line 294
    if-eqz v10, :cond_137

    .line 295
    .line 296
    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 297
    .line 298
    .line 299
    move-result-object v4

    .line 300
    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    .line 301
    .line 302
    .line 303
    move-result v4

    .line 304
    if-nez v4, :cond_137

    .line 305
    .line 306
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    .line 307
    .line 308
    .line 309
    move-result v4

    .line 310
    if-eqz v4, :cond_13a

    .line 311
    .line 312
    :cond_137
    :goto_137
    const/4 v5, 0x0

    .line 313
    goto/16 :goto_409

    .line 314
    .line 315
    :cond_13a
    invoke-static {v12}, Lcom/kousei/framework/g3;->b(Ljava/lang/String;)Ljava/lang/String;

    .line 316
    .line 317
    .line 318
    move-result-object v4

    .line 319
    if-eqz v4, :cond_137

    .line 320
    .line 321
    invoke-virtual {v0, v4}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    .line 322
    .line 323
    .line 324
    move-result v8

    .line 325
    if-eqz v8, :cond_147

    .line 326
    .line 327
    goto :goto_137

    .line 328
    :cond_147
    invoke-static {v10}, Lcom/kousei/framework/g3;->d(Ljava/lang/String;)[B

    .line 329
    .line 330
    .line 331
    move-result-object v8

    .line 332
    new-instance v14, Lcom/kousei/framework/o;

    .line 333
    .line 334
    invoke-direct {v14, v8}, Lcom/kousei/framework/o;-><init>([B)V

    .line 335
    .line 336
    .line 337
    invoke-virtual {v14}, Lcom/kousei/framework/o;->f()Lcom/kousei/framework/z;

    .line 338
    .line 339
    .line 340
    move-result-object v15

    .line 341
    invoke-virtual {v14}, Ljava/io/InputStream;->close()V

    .line 342
    .line 343
    .line 344
    const-wide v16, -0xa27d0dbb5469L

    .line 345
    .line 346
    .line 347
    .line 348
    .line 349
    invoke-static/range {v16 .. v17}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 350
    .line 351
    .line 352
    move-result-object v14

    .line 353
    invoke-virtual {v14, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 354
    .line 355
    .line 356
    move-result v14

    .line 357
    if-eqz v14, :cond_249

    .line 358
    .line 359
    if-eqz v15, :cond_172

    .line 360
    .line 361
    :try_start_168
    new-instance v8, Lcom/kousei/framework/f4;

    .line 362
    .line 363
    invoke-static {v15}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 364
    .line 365
    .line 366
    move-result-object v14

    .line 367
    invoke-direct {v8, v14}, Lcom/kousei/framework/f4;-><init>(Lcom/kousei/framework/c0;)V

    .line 368
    .line 369
    .line 370
    goto :goto_173

    .line 371
    :cond_172
    const/4 v8, 0x0

    .line 372
    :goto_173
    new-instance v14, Lcom/kousei/framework/j0;

    .line 373
    .line 374
    new-instance v5, Lcom/kousei/framework/u;

    .line 375
    .line 376
    const-wide v16, -0xa27e0dbb5469L

    .line 377
    .line 378
    .line 379
    .line 380
    .line 381
    invoke-static/range {v16 .. v17}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 382
    .line 383
    .line 384
    move-result-object v13

    .line 385
    invoke-direct {v5, v13}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 386
    .line 387
    .line 388
    iget-object v13, v8, Lcom/kousei/framework/f4;->a:Lcom/kousei/framework/c0;

    .line 389
    .line 390
    invoke-virtual {v13}, Lcom/kousei/framework/c0;->size()I

    .line 391
    .line 392
    .line 393
    move-result v3

    .line 394
    const/4 v6, 0x0

    .line 395
    :goto_18a
    if-ge v6, v3, :cond_1e3

    .line 396
    .line 397
    move/from16 v18, v3

    .line 398
    .line 399
    invoke-virtual {v13, v6}, Lcom/kousei/framework/c0;->u(I)Lcom/kousei/framework/j;

    .line 400
    .line 401
    .line 402
    move-result-object v3

    .line 403
    if-eqz v3, :cond_1d9

    .line 404
    .line 405
    move/from16 v19, v6

    .line 406
    .line 407
    instance-of v6, v3, Lcom/kousei/framework/a1;

    .line 408
    .line 409
    if-eqz v6, :cond_19d

    .line 410
    .line 411
    check-cast v3, Lcom/kousei/framework/a1;

    .line 412
    .line 413
    goto :goto_19e

    .line 414
    :cond_19d
    const/4 v3, 0x0

    .line 415
    :goto_19e
    if-eqz v3, :cond_1ad

    .line 416
    .line 417
    iget v6, v3, Lcom/kousei/framework/a1;->b:I
    :try_end_1a2
    .catch Ljava/lang/Exception; {:try_start_168 .. :try_end_1a2} :catch_227

    .line 418
    .line 419
    move/from16 v20, v7

    .line 420
    .line 421
    const/16 v7, 0x80

    .line 422
    .line 423
    if-ne v6, v7, :cond_1af

    .line 424
    .line 425
    :try_start_1a8
    iget v6, v3, Lcom/kousei/framework/a1;->c:I

    .line 426
    .line 427
    if-nez v6, :cond_1af

    .line 428
    .line 429
    goto :goto_1b0

    .line 430
    :cond_1ad
    move/from16 v20, v7

    .line 431
    .line 432
    :cond_1af
    const/4 v3, 0x0

    .line 433
    :goto_1b0
    if-eqz v3, :cond_1d2

    .line 434
    .line 435
    invoke-virtual {v3}, Lcom/kousei/framework/a1;->s()Z

    .line 436
    .line 437
    .line 438
    move-result v6

    .line 439
    if-eqz v6, :cond_1ca

    .line 440
    .line 441
    iget-object v3, v3, Lcom/kousei/framework/a1;->d:Lcom/kousei/framework/j;

    .line 442
    .line 443
    instance-of v6, v3, Lcom/kousei/framework/r;

    .line 444
    .line 445
    if-eqz v6, :cond_1c1

    .line 446
    .line 447
    check-cast v3, Lcom/kousei/framework/r;

    .line 448
    .line 449
    goto :goto_1c5

    .line 450
    :cond_1c1
    invoke-interface {v3}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 451
    .line 452
    .line 453
    move-result-object v3

    .line 454
    :goto_1c5
    invoke-interface {v3}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 455
    .line 456
    .line 457
    move-result-object v3

    .line 458
    goto :goto_1e6

    .line 459
    :cond_1ca
    new-instance v3, Ljava/lang/IllegalStateException;

    .line 460
    .line 461
    const-string v5, "object implicit - explicit expected."

    .line 462
    .line 463
    invoke-direct {v3, v5}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 464
    .line 465
    .line 466
    throw v3

    .line 467
    :cond_1d2
    add-int/lit8 v6, v19, 0x1

    .line 468
    .line 469
    move/from16 v3, v18

    .line 470
    .line 471
    move/from16 v7, v20

    .line 472
    .line 473
    goto :goto_18a

    .line 474
    :cond_1d9
    move/from16 v20, v7

    .line 475
    .line 476
    new-instance v3, Ljava/lang/NullPointerException;

    .line 477
    .line 478
    const-string v5, "\'element\' cannot be null"

    .line 479
    .line 480
    invoke-direct {v3, v5}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    .line 481
    .line 482
    .line 483
    throw v3

    .line 484
    :cond_1e3
    move/from16 v20, v7

    .line 485
    .line 486
    const/4 v3, 0x0

    .line 487
    :goto_1e6
    invoke-direct {v14, v5, v3}, Lcom/kousei/framework/j0;-><init>(Lcom/kousei/framework/u;Lcom/kousei/framework/j;)V

    .line 488
    .line 489
    .line 490
    new-instance v3, Lcom/kousei/framework/m7;

    .line 491
    .line 492
    iget-object v5, v8, Lcom/kousei/framework/f4;->a:Lcom/kousei/framework/c0;

    .line 493
    .line 494
    invoke-virtual {v5}, Lcom/kousei/framework/r;->h()[B

    .line 495
    .line 496
    .line 497
    move-result-object v5

    .line 498
    invoke-direct {v3}, Ljava/lang/Object;-><init>()V

    .line 499
    .line 500
    .line 501
    new-instance v6, Lcom/kousei/framework/p;

    .line 502
    .line 503
    sget-object v7, Lcom/kousei/framework/f1;->a:Ljava/math/BigInteger;

    .line 504
    .line 505
    invoke-direct {v6, v7}, Lcom/kousei/framework/p;-><init>(Ljava/math/BigInteger;)V

    .line 506
    .line 507
    .line 508
    iput-object v6, v3, Lcom/kousei/framework/m7;->a:Lcom/kousei/framework/p;

    .line 509
    .line 510
    iput-object v14, v3, Lcom/kousei/framework/m7;->b:Lcom/kousei/framework/j0;

    .line 511
    .line 512
    new-instance v6, Lcom/kousei/framework/n2;

    .line 513
    .line 514
    invoke-direct {v6, v5}, Lcom/kousei/framework/v;-><init>([B)V

    .line 515
    .line 516
    .line 517
    iput-object v6, v3, Lcom/kousei/framework/m7;->c:Lcom/kousei/framework/v;

    .line 518
    .line 519
    const/4 v5, 0x0

    .line 520
    iput-object v5, v3, Lcom/kousei/framework/m7;->d:Lcom/kousei/framework/d0;

    .line 521
    .line 522
    iput-object v5, v3, Lcom/kousei/framework/m7;->e:Lcom/kousei/framework/f;

    .line 523
    .line 524
    const-wide v5, -0xa5800dbb5469L

    .line 525
    .line 526
    .line 527
    .line 528
    .line 529
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 530
    .line 531
    .line 532
    move-result-object v5

    .line 533
    invoke-static {v5}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    .line 534
    .line 535
    .line 536
    move-result-object v5

    .line 537
    new-instance v6, Ljava/security/spec/PKCS8EncodedKeySpec;

    .line 538
    .line 539
    invoke-virtual {v3}, Lcom/kousei/framework/r;->g()[B

    .line 540
    .line 541
    .line 542
    move-result-object v3

    .line 543
    invoke-direct {v6, v3}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    .line 544
    .line 545
    .line 546
    invoke-virtual {v5, v6}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    .line 547
    .line 548
    .line 549
    move-result-object v3
    :try_end_225
    .catch Ljava/lang/Exception; {:try_start_1a8 .. :try_end_225} :catch_229

    .line 550
    goto/16 :goto_2c3

    .line 551
    .line 552
    :catch_227
    move/from16 v20, v7

    .line 553
    .line 554
    :catch_229
    invoke-static {v15}, Lcom/kousei/framework/m7;->i(Ljava/lang/Object;)Lcom/kousei/framework/m7;

    .line 555
    .line 556
    .line 557
    move-result-object v3

    .line 558
    const-wide v5, -0xa5850dbb5469L

    .line 559
    .line 560
    .line 561
    .line 562
    .line 563
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 564
    .line 565
    .line 566
    move-result-object v5

    .line 567
    invoke-static {v5}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    .line 568
    .line 569
    .line 570
    move-result-object v5

    .line 571
    new-instance v6, Ljava/security/spec/PKCS8EncodedKeySpec;

    .line 572
    .line 573
    invoke-virtual {v3}, Lcom/kousei/framework/r;->g()[B

    .line 574
    .line 575
    .line 576
    move-result-object v3

    .line 577
    invoke-direct {v6, v3}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    .line 578
    .line 579
    .line 580
    invoke-virtual {v5, v6}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    .line 581
    .line 582
    .line 583
    move-result-object v3

    .line 584
    goto/16 :goto_2c3

    .line 585
    .line 586
    :cond_249
    move/from16 v20, v7

    .line 587
    .line 588
    const-wide v5, -0xa5860dbb5469L

    .line 589
    .line 590
    .line 591
    .line 592
    .line 593
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 594
    .line 595
    .line 596
    move-result-object v3

    .line 597
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 598
    .line 599
    .line 600
    move-result v3

    .line 601
    if-eqz v3, :cond_2b6

    .line 602
    .line 603
    :try_start_25a
    invoke-static {v15}, Lcom/kousei/framework/v7;->i(Lcom/kousei/framework/z;)Lcom/kousei/framework/v7;

    .line 604
    .line 605
    .line 606
    move-result-object v3

    .line 607
    new-instance v21, Ljava/security/spec/RSAPrivateCrtKeySpec;

    .line 608
    .line 609
    iget-object v5, v3, Lcom/kousei/framework/v7;->b:Ljava/math/BigInteger;

    .line 610
    .line 611
    iget-object v6, v3, Lcom/kousei/framework/v7;->c:Ljava/math/BigInteger;

    .line 612
    .line 613
    iget-object v7, v3, Lcom/kousei/framework/v7;->d:Ljava/math/BigInteger;

    .line 614
    .line 615
    iget-object v8, v3, Lcom/kousei/framework/v7;->e:Ljava/math/BigInteger;

    .line 616
    .line 617
    iget-object v13, v3, Lcom/kousei/framework/v7;->f:Ljava/math/BigInteger;

    .line 618
    .line 619
    iget-object v14, v3, Lcom/kousei/framework/v7;->g:Ljava/math/BigInteger;

    .line 620
    .line 621
    move-object/from16 v22, v5

    .line 622
    .line 623
    iget-object v5, v3, Lcom/kousei/framework/v7;->h:Ljava/math/BigInteger;

    .line 624
    .line 625
    iget-object v3, v3, Lcom/kousei/framework/v7;->i:Ljava/math/BigInteger;

    .line 626
    .line 627
    move-object/from16 v29, v3

    .line 628
    .line 629
    move-object/from16 v28, v5

    .line 630
    .line 631
    move-object/from16 v23, v6

    .line 632
    .line 633
    move-object/from16 v24, v7

    .line 634
    .line 635
    move-object/from16 v25, v8

    .line 636
    .line 637
    move-object/from16 v26, v13

    .line 638
    .line 639
    move-object/from16 v27, v14

    .line 640
    .line 641
    invoke-direct/range {v21 .. v29}, Ljava/security/spec/RSAPrivateCrtKeySpec;-><init>(Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;Ljava/math/BigInteger;)V

    .line 642
    .line 643
    .line 644
    move-object/from16 v3, v21

    .line 645
    .line 646
    const-wide v5, -0xa59a0dbb5469L

    .line 647
    .line 648
    .line 649
    .line 650
    .line 651
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 652
    .line 653
    .line 654
    move-result-object v5

    .line 655
    invoke-static {v5}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    .line 656
    .line 657
    .line 658
    move-result-object v5

    .line 659
    invoke-virtual {v5, v3}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    .line 660
    .line 661
    .line 662
    move-result-object v3
    :try_end_296
    .catch Ljava/lang/Exception; {:try_start_25a .. :try_end_296} :catch_297

    .line 663
    goto :goto_2c3

    .line 664
    :catch_297
    invoke-static {v15}, Lcom/kousei/framework/m7;->i(Ljava/lang/Object;)Lcom/kousei/framework/m7;

    .line 665
    .line 666
    .line 667
    move-result-object v3

    .line 668
    const-wide v5, -0xa59e0dbb5469L

    .line 669
    .line 670
    .line 671
    .line 672
    .line 673
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 674
    .line 675
    .line 676
    move-result-object v5

    .line 677
    invoke-static {v5}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    .line 678
    .line 679
    .line 680
    move-result-object v5

    .line 681
    new-instance v6, Ljava/security/spec/PKCS8EncodedKeySpec;

    .line 682
    .line 683
    invoke-virtual {v3}, Lcom/kousei/framework/r;->g()[B

    .line 684
    .line 685
    .line 686
    move-result-object v3

    .line 687
    invoke-direct {v6, v3}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    .line 688
    .line 689
    .line 690
    invoke-virtual {v5, v6}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    .line 691
    .line 692
    .line 693
    move-result-object v3

    .line 694
    goto :goto_2c3

    .line 695
    :cond_2b6
    new-instance v3, Ljava/security/spec/PKCS8EncodedKeySpec;

    .line 696
    .line 697
    invoke-direct {v3, v8}, Ljava/security/spec/PKCS8EncodedKeySpec;-><init>([B)V

    .line 698
    .line 699
    .line 700
    invoke-static {v4}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    .line 701
    .line 702
    .line 703
    move-result-object v5

    .line 704
    invoke-virtual {v5, v3}, Ljava/security/KeyFactory;->generatePrivate(Ljava/security/spec/KeySpec;)Ljava/security/PrivateKey;

    .line 705
    .line 706
    .line 707
    move-result-object v3

    .line 708
    :goto_2c3
    new-instance v5, Ljava/util/ArrayList;

    .line 709
    .line 710
    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    .line 711
    .line 712
    .line 713
    const-wide v6, -0xa29c0dbb5469L

    .line 714
    .line 715
    .line 716
    .line 717
    .line 718
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 719
    .line 720
    .line 721
    move-result-object v6

    .line 722
    invoke-static {v6}, Ljava/security/cert/CertificateFactory;->getInstance(Ljava/lang/String;)Ljava/security/cert/CertificateFactory;

    .line 723
    .line 724
    .line 725
    move-result-object v6

    .line 726
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    .line 727
    .line 728
    .line 729
    move-result v7

    .line 730
    const/4 v8, 0x0

    .line 731
    :goto_2da
    if-ge v8, v7, :cond_323

    .line 732
    .line 733
    invoke-virtual {v1, v8}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 734
    .line 735
    .line 736
    move-result-object v13

    .line 737
    add-int/lit8 v8, v8, 0x1

    .line 738
    .line 739
    check-cast v13, Ljava/lang/String;

    .line 740
    .line 741
    if-eqz v13, :cond_314

    .line 742
    .line 743
    invoke-virtual {v13}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 744
    .line 745
    .line 746
    move-result-object v14

    .line 747
    invoke-virtual {v14}, Ljava/lang/String;->isEmpty()Z

    .line 748
    .line 749
    .line 750
    move-result v14

    .line 751
    if-nez v14, :cond_314

    .line 752
    .line 753
    invoke-static {v13}, Lcom/kousei/framework/g3;->d(Ljava/lang/String;)[B

    .line 754
    .line 755
    .line 756
    move-result-object v13

    .line 757
    new-instance v14, Ljava/io/ByteArrayInputStream;

    .line 758
    .line 759
    invoke-direct {v14, v13}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    .line 760
    .line 761
    .line 762
    invoke-virtual {v6, v14}, Ljava/security/cert/CertificateFactory;->generateCertificate(Ljava/io/InputStream;)Ljava/security/cert/Certificate;

    .line 763
    .line 764
    .line 765
    move-result-object v13

    .line 766
    instance-of v14, v13, Ljava/security/cert/X509Certificate;

    .line 767
    .line 768
    if-eqz v14, :cond_305

    .line 769
    .line 770
    invoke-virtual {v5, v13}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 771
    .line 772
    .line 773
    goto :goto_2da

    .line 774
    :cond_305
    const-wide v0, -0xa2a40dbb5469L

    .line 775
    .line 776
    .line 777
    .line 778
    .line 779
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 780
    .line 781
    .line 782
    move-result-object v0

    .line 783
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 784
    .line 785
    .line 786
    const/16 v17, 0x0

    .line 787
    .line 788
    return-object v17

    .line 789
    :cond_314
    const/16 v17, 0x0

    .line 790
    .line 791
    const-wide v0, -0xa2920dbb5469L

    .line 792
    .line 793
    .line 794
    .line 795
    .line 796
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 797
    .line 798
    .line 799
    move-result-object v0

    .line 800
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 801
    .line 802
    .line 803
    return-object v17

    .line 804
    :cond_323
    const/4 v6, 0x0

    .line 805
    invoke-virtual {v5, v6}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 806
    .line 807
    .line 808
    move-result-object v7

    .line 809
    check-cast v7, Ljava/security/cert/X509Certificate;

    .line 810
    .line 811
    invoke-virtual {v7}, Ljava/security/cert/Certificate;->getPublicKey()Ljava/security/PublicKey;

    .line 812
    .line 813
    .line 814
    move-result-object v7

    .line 815
    invoke-interface {v3}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    .line 816
    .line 817
    .line 818
    move-result-object v8

    .line 819
    invoke-static {v8}, Lcom/kousei/framework/g3;->b(Ljava/lang/String;)Ljava/lang/String;

    .line 820
    .line 821
    .line 822
    move-result-object v8

    .line 823
    invoke-interface {v7}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    .line 824
    .line 825
    .line 826
    move-result-object v13

    .line 827
    invoke-static {v13}, Lcom/kousei/framework/g3;->b(Ljava/lang/String;)Ljava/lang/String;

    .line 828
    .line 829
    .line 830
    move-result-object v13

    .line 831
    invoke-virtual {v4, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 832
    .line 833
    .line 834
    move-result v8

    .line 835
    if-eqz v8, :cond_3fc

    .line 836
    .line 837
    invoke-virtual {v4, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 838
    .line 839
    .line 840
    move-result v8

    .line 841
    if-eqz v8, :cond_3fc

    .line 842
    .line 843
    const-wide v13, -0xa22e0dbb5469L

    .line 844
    .line 845
    .line 846
    .line 847
    .line 848
    invoke-static {v13, v14}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 849
    .line 850
    .line 851
    move-result-object v8

    .line 852
    invoke-virtual {v8, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 853
    .line 854
    .line 855
    move-result v8

    .line 856
    if-eqz v8, :cond_363

    .line 857
    .line 858
    const-wide v13, -0xa2230dbb5469L

    .line 859
    .line 860
    .line 861
    .line 862
    .line 863
    :goto_35e
    invoke-static {v13, v14}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 864
    .line 865
    .line 866
    move-result-object v8

    .line 867
    goto :goto_369

    .line 868
    :cond_363
    const-wide v13, -0xa2330dbb5469L

    .line 869
    .line 870
    .line 871
    .line 872
    .line 873
    goto :goto_35e

    .line 874
    :goto_369
    const/16 v13, 0x20

    .line 875
    .line 876
    new-array v13, v13, [B

    .line 877
    .line 878
    new-instance v14, Ljava/security/SecureRandom;

    .line 879
    .line 880
    invoke-direct {v14}, Ljava/security/SecureRandom;-><init>()V

    .line 881
    .line 882
    .line 883
    invoke-virtual {v14, v13}, Ljava/security/SecureRandom;->nextBytes([B)V

    .line 884
    .line 885
    .line 886
    invoke-static {v8}, Ljava/security/Signature;->getInstance(Ljava/lang/String;)Ljava/security/Signature;

    .line 887
    .line 888
    .line 889
    move-result-object v14

    .line 890
    invoke-virtual {v14, v3}, Ljava/security/Signature;->initSign(Ljava/security/PrivateKey;)V

    .line 891
    .line 892
    .line 893
    invoke-virtual {v14, v13}, Ljava/security/Signature;->update([B)V

    .line 894
    .line 895
    .line 896
    invoke-virtual {v14}, Ljava/security/Signature;->sign()[B

    .line 897
    .line 898
    .line 899
    move-result-object v14

    .line 900
    invoke-static {v8}, Ljava/security/Signature;->getInstance(Ljava/lang/String;)Ljava/security/Signature;

    .line 901
    .line 902
    .line 903
    move-result-object v8

    .line 904
    invoke-virtual {v8, v7}, Ljava/security/Signature;->initVerify(Ljava/security/PublicKey;)V

    .line 905
    .line 906
    .line 907
    invoke-virtual {v8, v13}, Ljava/security/Signature;->update([B)V

    .line 908
    .line 909
    .line 910
    invoke-virtual {v8, v14}, Ljava/security/Signature;->verify([B)Z

    .line 911
    .line 912
    .line 913
    move-result v8

    .line 914
    if-eqz v8, :cond_3ee

    .line 915
    .line 916
    invoke-virtual {v5}, Ljava/util/ArrayList;->size()I

    .line 917
    .line 918
    .line 919
    move-result v8

    .line 920
    const/4 v13, 0x1

    .line 921
    if-gt v8, v13, :cond_39b

    .line 922
    .line 923
    goto :goto_3d7

    .line 924
    :cond_39b
    move v8, v6

    .line 925
    :goto_39c
    add-int/lit8 v13, v8, 0x1

    .line 926
    .line 927
    invoke-virtual {v5}, Ljava/util/ArrayList;->size()I

    .line 928
    .line 929
    .line 930
    move-result v14

    .line 931
    if-ge v13, v14, :cond_3d7

    .line 932
    .line 933
    invoke-virtual {v5, v8}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 934
    .line 935
    .line 936
    move-result-object v8

    .line 937
    check-cast v8, Ljava/security/cert/X509Certificate;

    .line 938
    .line 939
    invoke-virtual {v5, v13}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 940
    .line 941
    .line 942
    move-result-object v14

    .line 943
    check-cast v14, Ljava/security/cert/X509Certificate;

    .line 944
    .line 945
    invoke-virtual {v8}, Ljava/security/cert/X509Certificate;->getIssuerX500Principal()Ljavax/security/auth/x500/X500Principal;

    .line 946
    .line 947
    .line 948
    move-result-object v15

    .line 949
    invoke-virtual {v14}, Ljava/security/cert/X509Certificate;->getSubjectX500Principal()Ljavax/security/auth/x500/X500Principal;

    .line 950
    .line 951
    .line 952
    move-result-object v6

    .line 953
    invoke-virtual {v15, v6}, Ljavax/security/auth/x500/X500Principal;->equals(Ljava/lang/Object;)Z

    .line 954
    .line 955
    .line 956
    move-result v6

    .line 957
    if-eqz v6, :cond_3c8

    .line 958
    .line 959
    invoke-virtual {v14}, Ljava/security/cert/Certificate;->getPublicKey()Ljava/security/PublicKey;

    .line 960
    .line 961
    .line 962
    move-result-object v6

    .line 963
    invoke-virtual {v8, v6}, Ljava/security/cert/Certificate;->verify(Ljava/security/PublicKey;)V

    .line 964
    .line 965
    .line 966
    move v8, v13

    .line 967
    const/4 v6, 0x0

    .line 968
    goto :goto_39c

    .line 969
    :cond_3c8
    const-wide v0, -0xa2cf0dbb5469L

    .line 970
    .line 971
    .line 972
    .line 973
    .line 974
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 975
    .line 976
    .line 977
    move-result-object v0

    .line 978
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 979
    .line 980
    .line 981
    const/16 v17, 0x0

    .line 982
    .line 983
    return-object v17

    .line 984
    :cond_3d7
    :goto_3d7
    new-instance v6, Ljava/security/KeyPair;

    .line 985
    .line 986
    invoke-direct {v6, v7, v3}, Ljava/security/KeyPair;-><init>(Ljava/security/PublicKey;Ljava/security/PrivateKey;)V

    .line 987
    .line 988
    .line 989
    new-instance v3, Lcom/kousei/framework/t5;

    .line 990
    .line 991
    invoke-static {v5}, Ljava/util/Collections;->unmodifiableList(Ljava/util/List;)Ljava/util/List;

    .line 992
    .line 993
    .line 994
    move-result-object v5

    .line 995
    invoke-direct {v3, v6, v5}, Lcom/kousei/framework/t5;-><init>(Ljava/security/KeyPair;Ljava/util/List;)V

    .line 996
    .line 997
    .line 998
    invoke-virtual {v0, v4, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 999
    .line 1000
    .line 1001
    move/from16 v7, v20

    .line 1002
    .line 1003
    const/4 v5, 0x0

    .line 1004
    const/4 v8, 0x0

    .line 1005
    goto/16 :goto_476

    .line 1006
    .line 1007
    :cond_3ee
    const-wide v0, -0xa2410dbb5469L

    .line 1008
    .line 1009
    .line 1010
    .line 1011
    .line 1012
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1013
    .line 1014
    .line 1015
    move-result-object v0

    .line 1016
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 1017
    .line 1018
    .line 1019
    const/4 v5, 0x0

    .line 1020
    return-object v5

    .line 1021
    :cond_3fc
    const/4 v5, 0x0

    .line 1022
    const-wide v0, -0xa2fe0dbb5469L

    .line 1023
    .line 1024
    .line 1025
    .line 1026
    .line 1027
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1028
    .line 1029
    .line 1030
    move-result-object v0

    .line 1031
    invoke-static {v0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 1032
    .line 1033
    .line 1034
    :goto_409
    return-object v5

    .line 1035
    :cond_40a
    move/from16 v20, v7

    .line 1036
    .line 1037
    const/4 v5, 0x0

    .line 1038
    const-wide v3, -0xa33b0dbb5469L

    .line 1039
    .line 1040
    .line 1041
    .line 1042
    .line 1043
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1044
    .line 1045
    .line 1046
    move-result-object v3

    .line 1047
    invoke-virtual {v3, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 1048
    .line 1049
    .line 1050
    move-result v3

    .line 1051
    if-eqz v3, :cond_431

    .line 1052
    .line 1053
    const-wide v3, -0xa33f0dbb5469L

    .line 1054
    .line 1055
    .line 1056
    .line 1057
    .line 1058
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1059
    .line 1060
    .line 1061
    move-result-object v3

    .line 1062
    invoke-interface {v2, v5, v3}, Lorg/xmlpull/v1/XmlPullParser;->getAttributeValue(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 1063
    .line 1064
    .line 1065
    move-result-object v12

    .line 1066
    invoke-virtual {v1}, Ljava/util/ArrayList;->clear()V

    .line 1067
    .line 1068
    .line 1069
    move-object v10, v5

    .line 1070
    move v8, v13

    .line 1071
    :cond_42e
    :goto_42e
    move/from16 v7, v20

    .line 1072
    .line 1073
    goto :goto_476

    .line 1074
    :cond_431
    const-wide v3, -0xa3490dbb5469L

    .line 1075
    .line 1076
    .line 1077
    .line 1078
    .line 1079
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1080
    .line 1081
    .line 1082
    move-result-object v3

    .line 1083
    invoke-virtual {v3, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 1084
    .line 1085
    .line 1086
    move-result v3

    .line 1087
    if-eqz v3, :cond_444

    .line 1088
    .line 1089
    if-eqz v8, :cond_444

    .line 1090
    .line 1091
    move v7, v13

    .line 1092
    goto :goto_476

    .line 1093
    :cond_444
    const-wide v3, -0xa3420dbb5469L

    .line 1094
    .line 1095
    .line 1096
    .line 1097
    .line 1098
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1099
    .line 1100
    .line 1101
    move-result-object v3

    .line 1102
    invoke-virtual {v3, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 1103
    .line 1104
    .line 1105
    move-result v3

    .line 1106
    if-eqz v3, :cond_457

    .line 1107
    .line 1108
    if-eqz v8, :cond_457

    .line 1109
    .line 1110
    move v11, v13

    .line 1111
    goto :goto_42e

    .line 1112
    :cond_457
    const-wide v3, -0xa3550dbb5469L

    .line 1113
    .line 1114
    .line 1115
    .line 1116
    .line 1117
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1118
    .line 1119
    .line 1120
    move-result-object v3

    .line 1121
    invoke-virtual {v3, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 1122
    .line 1123
    .line 1124
    move-result v3

    .line 1125
    if-eqz v3, :cond_42e

    .line 1126
    .line 1127
    if-eqz v11, :cond_42e

    .line 1128
    .line 1129
    const-wide v3, -0xa3610dbb5469L

    .line 1130
    .line 1131
    .line 1132
    .line 1133
    .line 1134
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 1135
    .line 1136
    .line 1137
    move-result-object v3

    .line 1138
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1139
    .line 1140
    .line 1141
    move v9, v13

    .line 1142
    goto :goto_42e

    .line 1143
    :goto_476
    invoke-interface {v2}, Lorg/xmlpull/v1/XmlPullParser;->next()I

    .line 1144
    .line 1145
    .line 1146
    move-result v4

    .line 1147
    const/4 v3, 0x0

    .line 1148
    const/4 v5, 0x3

    .line 1149
    goto/16 :goto_6f

    .line 1150
    .line 1151
    :cond_47e
    const/4 v5, 0x0

    .line 1152
    invoke-virtual {v0}, Ljava/util/HashMap;->isEmpty()Z

    .line 1153
    .line 1154
    .line 1155
    move-result v1

    .line 1156
    if-eqz v1, :cond_486

    .line 1157
    .line 1158
    move-object v0, v5

    .line 1159
    :cond_486
    return-object v0
.end method
