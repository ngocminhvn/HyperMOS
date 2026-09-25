.class public final Lcom/kousei/framework/b7;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final l:Lcom/kousei/framework/r5;

.field public static m:Lcom/kousei/framework/b7;


# instance fields
.field public volatile a:Lcom/kousei/framework/m0;

.field public final b:Ljava/lang/Object;

.field public volatile c:Ljava/lang/String;

.field public volatile d:J

.field public final e:Ljava/lang/Object;

.field public final f:Ljava/util/concurrent/ExecutorService;

.field public volatile g:Lcom/kousei/framework/a7;

.field public volatile h:Ljava/lang/String;

.field public volatile i:Lcom/kousei/framework/w6;

.field public final j:Lcom/kousei/framework/g3;

.field public volatile k:Lcom/kousei/framework/z5;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0xa6270dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    new-instance v0, Lcom/kousei/framework/r5;

    .line 10
    .line 11
    const/4 v1, 0x1

    .line 12
    invoke-direct {v0, v1}, Lcom/kousei/framework/r5;-><init>(I)V

    .line 13
    .line 14
    .line 15
    sput-object v0, Lcom/kousei/framework/b7;->l:Lcom/kousei/framework/r5;

    .line 16
    .line 17
    return-void
.end method

.method public constructor <init>()V
    .registers 10

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    new-instance v0, Lcom/kousei/framework/m0;

    .line 5
    .line 6
    new-instance v1, Lcom/kousei/framework/x6;

    .line 7
    .line 8
    sget-object v2, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 9
    .line 10
    sget-object v3, Ljava/util/Collections;->EMPTY_SET:Ljava/util/Set;

    .line 11
    .line 12
    const/4 v7, 0x0

    .line 13
    sget-object v8, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 14
    .line 15
    const/4 v4, 0x0

    .line 16
    const/4 v6, 0x0

    .line 17
    move-object v5, v2

    .line 18
    invoke-direct/range {v1 .. v8}, Lcom/kousei/framework/x6;-><init>(Ljava/util/Map;Ljava/util/Set;Lcom/kousei/framework/v6;Ljava/util/Map;ZZLcom/kousei/framework/ma;)V

    .line 19
    .line 20
    .line 21
    sget-object v2, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 22
    .line 23
    const/4 v3, 0x0

    .line 24
    invoke-direct {v0, v1, v2, v3, v3}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/x6;Lcom/kousei/framework/u5;Ljava/lang/String;Lcom/kousei/framework/w6;)V

    .line 25
    .line 26
    .line 27
    iput-object v0, p0, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 28
    .line 29
    new-instance v0, Ljava/lang/Object;

    .line 30
    .line 31
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 32
    .line 33
    .line 34
    iput-object v0, p0, Lcom/kousei/framework/b7;->b:Ljava/lang/Object;

    .line 35
    .line 36
    new-instance v0, Ljava/lang/Object;

    .line 37
    .line 38
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 39
    .line 40
    .line 41
    iput-object v0, p0, Lcom/kousei/framework/b7;->e:Ljava/lang/Object;

    .line 42
    .line 43
    new-instance v0, Lcom/kousei/framework/x5;

    .line 44
    .line 45
    const/4 v1, 0x1

    .line 46
    invoke-direct {v0, v1}, Lcom/kousei/framework/x5;-><init>(I)V

    .line 47
    .line 48
    .line 49
    invoke-static {v0}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor(Ljava/util/concurrent/ThreadFactory;)Ljava/util/concurrent/ExecutorService;

    .line 50
    .line 51
    .line 52
    move-result-object v0

    .line 53
    iput-object v0, p0, Lcom/kousei/framework/b7;->f:Ljava/util/concurrent/ExecutorService;

    .line 54
    .line 55
    sget-object v0, Lcom/kousei/framework/a7;->a:Lcom/kousei/framework/a7;

    .line 56
    .line 57
    iput-object v0, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;

    .line 58
    .line 59
    iput-object v3, p0, Lcom/kousei/framework/b7;->h:Ljava/lang/String;

    .line 60
    .line 61
    iput-object v3, p0, Lcom/kousei/framework/b7;->i:Lcom/kousei/framework/w6;

    .line 62
    .line 63
    new-instance v0, Lcom/kousei/framework/g3;

    .line 64
    .line 65
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 66
    .line 67
    .line 68
    iput-object v0, p0, Lcom/kousei/framework/b7;->j:Lcom/kousei/framework/g3;

    .line 69
    .line 70
    new-instance v0, Lcom/kousei/framework/z5;

    .line 71
    .line 72
    invoke-direct {v0}, Lcom/kousei/framework/z5;-><init>()V

    .line 73
    .line 74
    .line 75
    iput-object v0, p0, Lcom/kousei/framework/b7;->k:Lcom/kousei/framework/z5;

    .line 76
    .line 77
    return-void
.end method

.method public static b()Z
    .registers 7

    .line 1
    sget-object v0, Lcom/kousei/framework/b7;->l:Lcom/kousei/framework/r5;

    .line 2
    .line 3
    :try_start_2
    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    .line 4
    .line 5
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 6
    .line 7
    .line 8
    move-result-object v2

    .line 9
    invoke-virtual {v1, v2}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    .line 10
    .line 11
    .line 12
    move-result v2
    :try_end_c
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_c} :catch_b7
    .catchall {:try_start_2 .. :try_end_c} :catchall_91

    .line 13
    const/4 v3, 0x0

    .line 14
    if-eqz v2, :cond_15

    .line 15
    .line 16
    :catch_f
    :goto_f
    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 17
    .line 18
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 19
    .line 20
    .line 21
    return v3

    .line 22
    :cond_15
    :try_start_15
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 23
    .line 24
    .line 25
    const-wide v1, -0xa7550dbb5469L

    .line 26
    .line 27
    .line 28
    .line 29
    .line 30
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 31
    .line 32
    .line 33
    move-result-object v1

    .line 34
    const-wide v4, -0xa7560dbb5469L

    .line 35
    .line 36
    .line 37
    .line 38
    .line 39
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object v2

    .line 43
    invoke-static {v1, v2}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 44
    .line 45
    .line 46
    move-result-object v1

    .line 47
    new-instance v2, Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 48
    .line 49
    const-wide v4, -0xa7660dbb5469L

    .line 50
    .line 51
    .line 52
    .line 53
    .line 54
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 55
    .line 56
    .line 57
    move-result-object v4

    .line 58
    const/4 v5, 0x4

    .line 59
    invoke-direct {v2, v4, v5}, Landroid/security/keystore/KeyGenParameterSpec$Builder;-><init>(Ljava/lang/String;I)V

    .line 60
    .line 61
    .line 62
    new-instance v4, Ljava/security/spec/ECGenParameterSpec;

    .line 63
    .line 64
    const-wide v5, -0xa7720dbb5469L

    .line 65
    .line 66
    .line 67
    .line 68
    .line 69
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 70
    .line 71
    .line 72
    move-result-object v5

    .line 73
    invoke-direct {v4, v5}, Ljava/security/spec/ECGenParameterSpec;-><init>(Ljava/lang/String;)V

    .line 74
    .line 75
    .line 76
    invoke-virtual {v2, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setAlgorithmParameterSpec(Ljava/security/spec/AlgorithmParameterSpec;)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 77
    .line 78
    .line 79
    move-result-object v2

    .line 80
    const-wide v4, -0xa68c0dbb5469L

    .line 81
    .line 82
    .line 83
    .line 84
    .line 85
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 86
    .line 87
    .line 88
    move-result-object v4

    .line 89
    filled-new-array {v4}, [Ljava/lang/String;

    .line 90
    .line 91
    .line 92
    move-result-object v4

    .line 93
    invoke-virtual {v2, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setDigests([Ljava/lang/String;)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 94
    .line 95
    .line 96
    move-result-object v2

    .line 97
    const/16 v4, 0x10

    .line 98
    .line 99
    new-array v4, v4, [B

    .line 100
    .line 101
    invoke-virtual {v2, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setAttestationChallenge([B)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 102
    .line 103
    .line 104
    move-result-object v2
    :try_end_68
    .catch Ljava/lang/Exception; {:try_start_15 .. :try_end_68} :catch_b7
    .catchall {:try_start_15 .. :try_end_68} :catchall_91

    .line 105
    const/4 v4, 0x0

    .line 106
    :try_start_69
    invoke-virtual {v2}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->build()Landroid/security/keystore/KeyGenParameterSpec;

    .line 107
    .line 108
    .line 109
    move-result-object v2

    .line 110
    invoke-virtual {v1, v2}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 111
    .line 112
    .line 113
    invoke-virtual {v1}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;
    :try_end_73
    .catchall {:try_start_69 .. :try_end_73} :catchall_93

    .line 114
    .line 115
    .line 116
    const-wide v1, -0xa6840dbb5469L

    .line 117
    .line 118
    .line 119
    .line 120
    .line 121
    :try_start_78
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 122
    .line 123
    .line 124
    move-result-object v1

    .line 125
    invoke-static {v1}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 126
    .line 127
    .line 128
    move-result-object v1

    .line 129
    invoke-virtual {v1, v4}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 130
    .line 131
    .line 132
    const-wide v4, -0xa6940dbb5469L

    .line 133
    .line 134
    .line 135
    .line 136
    .line 137
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 138
    .line 139
    .line 140
    move-result-object v2

    .line 141
    invoke-virtual {v1, v2}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_8f
    .catch Ljava/lang/Exception; {:try_start_78 .. :try_end_8f} :catch_f
    .catchall {:try_start_78 .. :try_end_8f} :catchall_91

    .line 142
    .line 143
    .line 144
    goto/16 :goto_f

    .line 145
    .line 146
    :catchall_91
    move-exception v1

    .line 147
    goto :goto_b1

    .line 148
    :catchall_93
    move-exception v1

    .line 149
    const-wide v2, -0xa6a00dbb5469L

    .line 150
    .line 151
    .line 152
    .line 153
    .line 154
    :try_start_99
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 155
    .line 156
    .line 157
    move-result-object v2

    .line 158
    invoke-static {v2}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 159
    .line 160
    .line 161
    move-result-object v2

    .line 162
    invoke-virtual {v2, v4}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 163
    .line 164
    .line 165
    const-wide v3, -0xa6b00dbb5469L

    .line 166
    .line 167
    .line 168
    .line 169
    .line 170
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 171
    .line 172
    .line 173
    move-result-object v3

    .line 174
    invoke-virtual {v2, v3}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_b0
    .catch Ljava/lang/Exception; {:try_start_99 .. :try_end_b0} :catch_b0
    .catchall {:try_start_99 .. :try_end_b0} :catchall_91

    .line 175
    .line 176
    .line 177
    :catch_b0
    :try_start_b0
    throw v1
    :try_end_b1
    .catch Ljava/lang/Exception; {:try_start_b0 .. :try_end_b1} :catch_b7
    .catchall {:try_start_b0 .. :try_end_b1} :catchall_91

    .line 178
    :goto_b1
    sget-object v2, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 179
    .line 180
    invoke-virtual {v0, v2}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 181
    .line 182
    .line 183
    throw v1

    .line 184
    :catch_b7
    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 185
    .line 186
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 187
    .line 188
    .line 189
    const/4 v0, 0x1

    .line 190
    return v0
.end method

.method public static declared-synchronized c()Lcom/kousei/framework/b7;
    .registers 3

    .line 1
    const-class v0, Lcom/kousei/framework/b7;

    .line 2
    .line 3
    monitor-enter v0

    .line 4
    :try_start_3
    sget-object v1, Lcom/kousei/framework/b7;->m:Lcom/kousei/framework/b7;

    .line 5
    .line 6
    if-nez v1, :cond_18

    .line 7
    .line 8
    new-instance v1, Lcom/kousei/framework/b7;

    .line 9
    .line 10
    invoke-direct {v1}, Lcom/kousei/framework/b7;-><init>()V

    .line 11
    .line 12
    .line 13
    sput-object v1, Lcom/kousei/framework/b7;->m:Lcom/kousei/framework/b7;

    .line 14
    .line 15
    const/4 v2, 0x1

    .line 16
    invoke-virtual {v1, v2}, Lcom/kousei/framework/b7;->k(Z)V

    .line 17
    .line 18
    .line 19
    invoke-virtual {v1}, Lcom/kousei/framework/b7;->l()V

    .line 20
    .line 21
    .line 22
    goto :goto_18

    .line 23
    :catchall_16
    move-exception v1

    .line 24
    goto :goto_1c

    .line 25
    :cond_18
    :goto_18
    sget-object v1, Lcom/kousei/framework/b7;->m:Lcom/kousei/framework/b7;
    :try_end_1a
    .catchall {:try_start_3 .. :try_end_1a} :catchall_16

    .line 26
    .line 27
    monitor-exit v0

    .line 28
    return-object v1

    .line 29
    :goto_1c
    :try_start_1c
    monitor-exit v0
    :try_end_1d
    .catchall {:try_start_1c .. :try_end_1d} :catchall_16

    .line 30
    throw v1
.end method

.method public static f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 1
    invoke-virtual {p0, p1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    const/4 v1, 0x0

    .line 6
    if-nez v0, :cond_8

    .line 7
    .line 8
    goto :goto_2a

    .line 9
    :cond_8
    invoke-virtual {p0, p1, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 10
    .line 11
    .line 12
    move-result-object p0

    .line 13
    if-nez p0, :cond_f

    .line 14
    .line 15
    goto :goto_2a

    .line 16
    :cond_f
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 17
    .line 18
    .line 19
    move-result-object p0

    .line 20
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    .line 21
    .line 22
    .line 23
    move-result p1

    .line 24
    if-nez p1, :cond_2a

    .line 25
    .line 26
    const-wide v2, -0xa6f40dbb5469L

    .line 27
    .line 28
    .line 29
    .line 30
    .line 31
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 32
    .line 33
    .line 34
    move-result-object p1

    .line 35
    invoke-virtual {p1, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 36
    .line 37
    .line 38
    move-result p1

    .line 39
    if-eqz p1, :cond_29

    .line 40
    .line 41
    goto :goto_2a

    .line 42
    :cond_29
    return-object p0

    .line 43
    :cond_2a
    :goto_2a
    return-object v1
.end method

.method public static g(Ljava/lang/String;)Lcom/kousei/framework/v6;
    .registers 13

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
    const/4 v1, 0x0

    .line 10
    if-eqz v0, :cond_d

    .line 11
    .line 12
    goto/16 :goto_112

    .line 13
    .line 14
    :cond_d
    :try_start_d
    new-instance v0, Ljava/lang/StringBuilder;

    .line 15
    .line 16
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 17
    .line 18
    .line 19
    const-wide v2, -0xa7320dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v2

    .line 28
    invoke-virtual {p0, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    .line 29
    .line 30
    .line 31
    move-result-object p0

    .line 32
    const/4 v2, 0x0

    .line 33
    move v3, v2

    .line 34
    :goto_21
    array-length v4, p0

    .line 35
    if-ge v3, v4, :cond_51

    .line 36
    .line 37
    aget-object v4, p0, v3

    .line 38
    .line 39
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object v4

    .line 43
    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    .line 44
    .line 45
    .line 46
    move-result v5

    .line 47
    if-nez v5, :cond_4e

    .line 48
    .line 49
    const-wide v5, -0xa7340dbb5469L

    .line 50
    .line 51
    .line 52
    .line 53
    .line 54
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 55
    .line 56
    .line 57
    move-result-object v5

    .line 58
    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 59
    .line 60
    .line 61
    move-result v5

    .line 62
    if-nez v5, :cond_4e

    .line 63
    .line 64
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 65
    .line 66
    .line 67
    const-wide v4, -0xa7360dbb5469L

    .line 68
    .line 69
    .line 70
    .line 71
    .line 72
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 73
    .line 74
    .line 75
    move-result-object v4

    .line 76
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 77
    .line 78
    .line 79
    :cond_4e
    add-int/lit8 v3, v3, 0x1

    .line 80
    .line 81
    goto :goto_21

    .line 82
    :cond_51
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 83
    .line 84
    .line 85
    move-result-object p0

    .line 86
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 87
    .line 88
    .line 89
    move-result-object p0

    .line 90
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    .line 91
    .line 92
    .line 93
    move-result v0

    .line 94
    if-eqz v0, :cond_61

    .line 95
    .line 96
    goto/16 :goto_112

    .line 97
    .line 98
    :cond_61
    const-wide v3, -0xa7480dbb5469L

    .line 99
    .line 100
    .line 101
    .line 102
    .line 103
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 104
    .line 105
    .line 106
    move-result-object v0

    .line 107
    invoke-virtual {p0, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    .line 108
    .line 109
    .line 110
    move-result-object p0

    .line 111
    array-length v0, p0

    .line 112
    const/4 v3, 0x1

    .line 113
    if-ne v0, v3, :cond_8b

    .line 114
    .line 115
    aget-object v0, p0, v2

    .line 116
    .line 117
    const-wide v3, -0xa74a0dbb5469L

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
    invoke-virtual {v0, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    .line 127
    .line 128
    .line 129
    move-result v0

    .line 130
    if-nez v0, :cond_8b

    .line 131
    .line 132
    new-instance v0, Lcom/kousei/framework/v6;

    .line 133
    .line 134
    aget-object p0, p0, v2

    .line 135
    .line 136
    invoke-direct {v0, p0, p0, p0}, Lcom/kousei/framework/v6;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 137
    .line 138
    .line 139
    return-object v0

    .line 140
    :cond_8b
    move-object v3, v1

    .line 141
    move-object v4, v3

    .line 142
    move-object v5, v4

    .line 143
    move-object v6, v5

    .line 144
    move v0, v2

    .line 145
    :goto_90
    array-length v7, p0

    .line 146
    if-ge v0, v7, :cond_101

    .line 147
    .line 148
    aget-object v7, p0, v0

    .line 149
    .line 150
    const/16 v8, 0x3d

    .line 151
    .line 152
    invoke-virtual {v7, v8}, Ljava/lang/String;->indexOf(I)I

    .line 153
    .line 154
    .line 155
    move-result v8

    .line 156
    if-lez v8, :cond_fe

    .line 157
    .line 158
    invoke-virtual {v7, v2, v8}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 159
    .line 160
    .line 161
    move-result-object v9

    .line 162
    invoke-virtual {v9}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 163
    .line 164
    .line 165
    move-result-object v9

    .line 166
    invoke-virtual {v9}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    .line 167
    .line 168
    .line 169
    move-result-object v9

    .line 170
    add-int/lit8 v8, v8, 0x1

    .line 171
    .line 172
    invoke-virtual {v7, v8}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    .line 173
    .line 174
    .line 175
    move-result-object v7

    .line 176
    invoke-virtual {v7}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 177
    .line 178
    .line 179
    move-result-object v7

    .line 180
    invoke-virtual {v9}, Ljava/lang/String;->hashCode()I

    .line 181
    .line 182
    .line 183
    move-result v8

    .line 184
    sparse-switch v8, :sswitch_data_114

    .line 185
    .line 186
    .line 187
    goto :goto_fe

    .line 188
    :sswitch_bb
    const-wide v10, -0xa75a0dbb5469L

    .line 189
    .line 190
    .line 191
    .line 192
    .line 193
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 194
    .line 195
    .line 196
    move-result-object v8

    .line 197
    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 198
    .line 199
    .line 200
    move-result v8

    .line 201
    if-eqz v8, :cond_fe

    .line 202
    .line 203
    move-object v6, v7

    .line 204
    goto :goto_fe

    .line 205
    :sswitch_cc
    const-wide v10, -0xa7510dbb5469L

    .line 206
    .line 207
    .line 208
    .line 209
    .line 210
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 211
    .line 212
    .line 213
    move-result-object v8

    .line 214
    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 215
    .line 216
    .line 217
    move-result v8

    .line 218
    if-eqz v8, :cond_fe

    .line 219
    .line 220
    move-object v4, v7

    .line 221
    goto :goto_fe

    .line 222
    :sswitch_dd
    const-wide v10, -0xa7450dbb5469L

    .line 223
    .line 224
    .line 225
    .line 226
    .line 227
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 228
    .line 229
    .line 230
    move-result-object v8

    .line 231
    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 232
    .line 233
    .line 234
    move-result v8

    .line 235
    if-eqz v8, :cond_fe

    .line 236
    .line 237
    move-object v5, v7

    .line 238
    goto :goto_fe

    .line 239
    :sswitch_ee
    const-wide v10, -0xa74c0dbb5469L

    .line 240
    .line 241
    .line 242
    .line 243
    .line 244
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 245
    .line 246
    .line 247
    move-result-object v8

    .line 248
    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 249
    .line 250
    .line 251
    move-result v8

    .line 252
    if-eqz v8, :cond_fe

    .line 253
    .line 254
    move-object v3, v7

    .line 255
    :cond_fe
    :goto_fe
    add-int/lit8 v0, v0, 0x1

    .line 256
    .line 257
    goto :goto_90

    .line 258
    :cond_101
    new-instance p0, Lcom/kousei/framework/v6;

    .line 259
    .line 260
    if-eqz v3, :cond_106

    .line 261
    .line 262
    goto :goto_107

    .line 263
    :cond_106
    move-object v3, v4

    .line 264
    :goto_107
    if-eqz v5, :cond_10a

    .line 265
    .line 266
    goto :goto_10b

    .line 267
    :cond_10a
    move-object v5, v4

    .line 268
    :goto_10b
    if-eqz v6, :cond_10e

    .line 269
    .line 270
    move-object v4, v6

    .line 271
    :cond_10e
    invoke-direct {p0, v3, v5, v4}, Lcom/kousei/framework/v6;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_111
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_111} :catch_112

    .line 272
    .line 273
    .line 274
    return-object p0

    .line 275
    :catch_112
    :goto_112
    return-object v1

    .line 276
    nop

    .line 277
    :sswitch_data_114
    .sparse-switch
        -0x34e38dd1 -> :sswitch_ee
        -0x30e15ab8 -> :sswitch_dd
        0x179a1 -> :sswitch_cc
        0x2e3af2 -> :sswitch_bb
    .end sparse-switch
.end method

.method public static h(Ljava/lang/String;)Lcom/kousei/framework/w6;
    .registers 14

    .line 1
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    if-eqz v0, :cond_c

    .line 10
    .line 11
    goto/16 :goto_a1

    .line 12
    .line 13
    :cond_c
    const-wide v0, -0xa6da0dbb5469L

    .line 14
    .line 15
    .line 16
    .line 17
    .line 18
    :try_start_11
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 19
    .line 20
    .line 21
    move-result-object v0

    .line 22
    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 23
    .line 24
    .line 25
    move-result v0

    .line 26
    const/4 v1, 0x1

    .line 27
    const/4 v2, 0x0

    .line 28
    if-eqz v0, :cond_64

    .line 29
    .line 30
    new-instance v0, Lorg/json/JSONObject;

    .line 31
    .line 32
    invoke-direct {v0, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 33
    .line 34
    .line 35
    const-wide v3, -0xa6dc0dbb5469L

    .line 36
    .line 37
    .line 38
    .line 39
    .line 40
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 41
    .line 42
    .line 43
    move-result-object p0

    .line 44
    invoke-static {v0, p0}, Lcom/kousei/framework/b7;->f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;

    .line 45
    .line 46
    .line 47
    move-result-object p0

    .line 48
    const-wide v3, -0xa6d20dbb5469L

    .line 49
    .line 50
    .line 51
    .line 52
    .line 53
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v3

    .line 57
    invoke-static {v0, v3}, Lcom/kousei/framework/b7;->f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;

    .line 58
    .line 59
    .line 60
    move-result-object v3

    .line 61
    const-wide v4, -0xa6eb0dbb5469L

    .line 62
    .line 63
    .line 64
    .line 65
    .line 66
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 67
    .line 68
    .line 69
    move-result-object v4

    .line 70
    invoke-static {v0, v4}, Lcom/kousei/framework/b7;->f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;

    .line 71
    .line 72
    .line 73
    move-result-object v4

    .line 74
    const-wide v5, -0xa6e30dbb5469L

    .line 75
    .line 76
    .line 77
    .line 78
    .line 79
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object v5

    .line 83
    invoke-static {v0, v5}, Lcom/kousei/framework/b7;->f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;

    .line 84
    .line 85
    .line 86
    move-result-object v5

    .line 87
    const-wide v6, -0xa6fe0dbb5469L

    .line 88
    .line 89
    .line 90
    .line 91
    .line 92
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 93
    .line 94
    .line 95
    move-result-object v6

    .line 96
    invoke-static {v0, v6}, Lcom/kousei/framework/b7;->f(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;

    .line 97
    .line 98
    .line 99
    move-result-object v0

    .line 100
    goto :goto_78

    .line 101
    :cond_64
    invoke-static {p0}, Lcom/kousei/framework/b7;->i(Ljava/lang/String;)[Ljava/lang/String;

    .line 102
    .line 103
    .line 104
    move-result-object p0

    .line 105
    aget-object v0, p0, v2

    .line 106
    .line 107
    aget-object v3, p0, v1

    .line 108
    .line 109
    const/4 v4, 0x2

    .line 110
    aget-object v4, p0, v4

    .line 111
    .line 112
    const/4 v5, 0x3

    .line 113
    aget-object v5, p0, v5

    .line 114
    .line 115
    const/4 v6, 0x4

    .line 116
    aget-object p0, p0, v6

    .line 117
    .line 118
    move-object v12, v0

    .line 119
    move-object v0, p0

    .line 120
    move-object p0, v12

    .line 121
    :goto_78
    new-instance v6, Lcom/kousei/framework/w6;

    .line 122
    .line 123
    invoke-static {p0}, Lcom/kousei/framework/b7;->n(Ljava/lang/String;)[B

    .line 124
    .line 125
    .line 126
    move-result-object v7

    .line 127
    invoke-static {v3}, Lcom/kousei/framework/b7;->n(Ljava/lang/String;)[B

    .line 128
    .line 129
    .line 130
    move-result-object v8

    .line 131
    invoke-static {v4}, Lcom/kousei/framework/b7;->n(Ljava/lang/String;)[B

    .line 132
    .line 133
    .line 134
    move-result-object v9

    .line 135
    invoke-static {v5}, Lcom/kousei/framework/b7;->n(Ljava/lang/String;)[B

    .line 136
    .line 137
    .line 138
    move-result-object v10

    .line 139
    invoke-static {v0}, Lcom/kousei/framework/b7;->n(Ljava/lang/String;)[B

    .line 140
    .line 141
    .line 142
    move-result-object v11

    .line 143
    invoke-direct/range {v6 .. v11}, Lcom/kousei/framework/w6;-><init>([B[B[B[B[B)V
    :try_end_91
    .catchall {:try_start_11 .. :try_end_91} :catchall_a1

    .line 144
    .line 145
    .line 146
    if-nez v7, :cond_9c

    .line 147
    .line 148
    if-nez v8, :cond_9c

    .line 149
    .line 150
    if-nez v9, :cond_9c

    .line 151
    .line 152
    if-nez v10, :cond_9c

    .line 153
    .line 154
    if-nez v11, :cond_9c

    .line 155
    .line 156
    goto :goto_9d

    .line 157
    :cond_9c
    move v1, v2

    .line 158
    :goto_9d
    if-eqz v1, :cond_a0

    .line 159
    .line 160
    goto :goto_a1

    .line 161
    :cond_a0
    return-object v6

    .line 162
    :catchall_a1
    :goto_a1
    const/4 p0, 0x0

    .line 163
    return-object p0
.end method

.method public static i(Ljava/lang/String;)[Ljava/lang/String;
    .registers 9

    .line 1
    const/4 v0, 0x5

    .line 2
    new-array v0, v0, [Ljava/lang/String;

    .line 3
    .line 4
    const-wide v1, -0xa60b0dbb5469L

    .line 5
    .line 6
    .line 7
    .line 8
    .line 9
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    invoke-virtual {p0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    .line 14
    .line 15
    .line 16
    move-result-object p0

    .line 17
    const/4 v1, 0x0

    .line 18
    move v2, v1

    .line 19
    :goto_12
    array-length v3, p0

    .line 20
    if-ge v2, v3, :cond_c6

    .line 21
    .line 22
    aget-object v3, p0, v2

    .line 23
    .line 24
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v3

    .line 28
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    .line 29
    .line 30
    .line 31
    move-result v4

    .line 32
    if-nez v4, :cond_c2

    .line 33
    .line 34
    const-wide v4, -0xa60d0dbb5469L

    .line 35
    .line 36
    .line 37
    .line 38
    .line 39
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object v4

    .line 43
    invoke-virtual {v3, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 44
    .line 45
    .line 46
    move-result v4

    .line 47
    if-eqz v4, :cond_32

    .line 48
    .line 49
    goto/16 :goto_c2

    .line 50
    .line 51
    :cond_32
    const/16 v4, 0x3d

    .line 52
    .line 53
    invoke-virtual {v3, v4}, Ljava/lang/String;->indexOf(I)I

    .line 54
    .line 55
    .line 56
    move-result v4

    .line 57
    if-gtz v4, :cond_3c

    .line 58
    .line 59
    goto/16 :goto_c2

    .line 60
    .line 61
    :cond_3c
    invoke-virtual {v3, v1, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 62
    .line 63
    .line 64
    move-result-object v5

    .line 65
    invoke-virtual {v5}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 66
    .line 67
    .line 68
    move-result-object v5

    .line 69
    add-int/lit8 v4, v4, 0x1

    .line 70
    .line 71
    invoke-virtual {v3, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    .line 72
    .line 73
    .line 74
    move-result-object v3

    .line 75
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 76
    .line 77
    .line 78
    move-result-object v3

    .line 79
    const/16 v4, 0x23

    .line 80
    .line 81
    invoke-virtual {v3, v4}, Ljava/lang/String;->indexOf(I)I

    .line 82
    .line 83
    .line 84
    move-result v4

    .line 85
    if-ltz v4, :cond_5e

    .line 86
    .line 87
    invoke-virtual {v3, v1, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 88
    .line 89
    .line 90
    move-result-object v3

    .line 91
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 92
    .line 93
    .line 94
    move-result-object v3

    .line 95
    :cond_5e
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    .line 96
    .line 97
    .line 98
    move-result v4

    .line 99
    if-eqz v4, :cond_65

    .line 100
    .line 101
    goto :goto_c2

    .line 102
    :cond_65
    const-wide v6, -0xa60f0dbb5469L

    .line 103
    .line 104
    .line 105
    .line 106
    .line 107
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 108
    .line 109
    .line 110
    move-result-object v4

    .line 111
    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 112
    .line 113
    .line 114
    move-result v4

    .line 115
    if-eqz v4, :cond_77

    .line 116
    .line 117
    aput-object v3, v0, v1

    .line 118
    .line 119
    goto :goto_c2

    .line 120
    :cond_77
    const-wide v6, -0xa6050dbb5469L

    .line 121
    .line 122
    .line 123
    .line 124
    .line 125
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 126
    .line 127
    .line 128
    move-result-object v4

    .line 129
    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 130
    .line 131
    .line 132
    move-result v4

    .line 133
    if-eqz v4, :cond_8a

    .line 134
    .line 135
    const/4 v4, 0x1

    .line 136
    aput-object v3, v0, v4

    .line 137
    .line 138
    goto :goto_c2

    .line 139
    :cond_8a
    const-wide v6, -0xa61a0dbb5469L

    .line 140
    .line 141
    .line 142
    .line 143
    .line 144
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 145
    .line 146
    .line 147
    move-result-object v4

    .line 148
    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 149
    .line 150
    .line 151
    move-result v4

    .line 152
    if-eqz v4, :cond_9d

    .line 153
    .line 154
    const/4 v4, 0x2

    .line 155
    aput-object v3, v0, v4

    .line 156
    .line 157
    goto :goto_c2

    .line 158
    :cond_9d
    const-wide v6, -0xa6120dbb5469L

    .line 159
    .line 160
    .line 161
    .line 162
    .line 163
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 164
    .line 165
    .line 166
    move-result-object v4

    .line 167
    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 168
    .line 169
    .line 170
    move-result v4

    .line 171
    if-eqz v4, :cond_b0

    .line 172
    .line 173
    const/4 v4, 0x3

    .line 174
    aput-object v3, v0, v4

    .line 175
    .line 176
    goto :goto_c2

    .line 177
    :cond_b0
    const-wide v6, -0xa6210dbb5469L

    .line 178
    .line 179
    .line 180
    .line 181
    .line 182
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 183
    .line 184
    .line 185
    move-result-object v4

    .line 186
    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 187
    .line 188
    .line 189
    move-result v4

    .line 190
    if-eqz v4, :cond_c2

    .line 191
    .line 192
    const/4 v4, 0x4

    .line 193
    aput-object v3, v0, v4

    .line 194
    .line 195
    :cond_c2
    :goto_c2
    add-int/lit8 v2, v2, 0x1

    .line 196
    .line 197
    goto/16 :goto_12

    .line 198
    .line 199
    :cond_c6
    return-object v0
.end method

.method public static j(Ljava/lang/String;Ljava/lang/String;ZZLcom/kousei/framework/ma;)Lcom/kousei/framework/x6;
    .registers 22

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    .line 1
    new-instance v2, Ljava/util/LinkedHashMap;

    invoke-direct {v2}, Ljava/util/LinkedHashMap;-><init>()V

    .line 2
    new-instance v3, Ljava/util/LinkedHashSet;

    invoke-direct {v3}, Ljava/util/LinkedHashSet;-><init>()V

    const-wide v4, -0xa7a20dbb5469L

    const/4 v6, 0x1

    const/4 v7, 0x0

    if-eqz v0, :cond_ed

    .line 3
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-eqz v8, :cond_23

    goto/16 :goto_ed

    :cond_23
    const-wide v8, -0xa7970dbb5469L

    .line 4
    invoke-static {v8, v9}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v0, v8}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    array-length v8, v0

    move v9, v7

    :goto_32
    if-ge v9, v8, :cond_e7

    aget-object v10, v0, v9

    .line 5
    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v10

    .line 6
    invoke-virtual {v10}, Ljava/lang/String;->isEmpty()Z

    move-result v11

    if-nez v11, :cond_e3

    const-wide v11, -0xa7a80dbb5469L

    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_51

    goto/16 :goto_e3

    :cond_51
    const-wide v11, -0xa7aa0dbb5469L

    .line 7
    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_6d

    .line 8
    invoke-virtual {v10}, Ljava/lang/String;->length()I

    move-result v12

    sub-int/2addr v12, v6

    invoke-virtual {v10, v7, v12}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v10

    .line 9
    :cond_6d
    sget-object v12, Lcom/kousei/framework/ma;->a:Lcom/kousei/framework/ma;

    const-wide v13, -0xa7ac0dbb5469L

    .line 10
    invoke-static {v13, v14}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v10, v13}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_8e

    .line 11
    sget-object v12, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 12
    invoke-virtual {v10}, Ljava/lang/String;->length()I

    move-result v13

    sub-int/2addr v13, v6

    invoke-virtual {v10, v7, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v10

    goto :goto_cb

    :cond_8e
    const-wide v13, -0xa7ae0dbb5469L

    .line 13
    invoke-static {v13, v14}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v10, v13}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_ad

    .line 14
    sget-object v12, Lcom/kousei/framework/ma;->b:Lcom/kousei/framework/ma;

    .line 15
    invoke-virtual {v10}, Ljava/lang/String;->length()I

    move-result v13

    sub-int/2addr v13, v6

    invoke-virtual {v10, v7, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v10

    goto :goto_cb

    :cond_ad
    const-wide v13, -0xa7a00dbb5469L

    .line 16
    invoke-static {v13, v14}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v10, v13}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_cb

    .line 17
    sget-object v12, Lcom/kousei/framework/ma;->d:Lcom/kousei/framework/ma;

    .line 18
    invoke-virtual {v10}, Ljava/lang/String;->length()I

    move-result v13

    sub-int/2addr v13, v6

    invoke-virtual {v10, v7, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v10

    :cond_cb
    :goto_cb
    if-eqz v10, :cond_e3

    .line 19
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v10, v13}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_e3

    .line 20
    invoke-interface {v2, v10, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    if-eqz v11, :cond_e0

    .line 21
    invoke-interface {v3, v10}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    goto :goto_e3

    :cond_e0
    invoke-interface {v3, v10}, Ljava/util/Set;->remove(Ljava/lang/Object;)Z

    :cond_e3
    :goto_e3
    add-int/lit8 v9, v9, 0x1

    goto/16 :goto_32

    .line 22
    :cond_e7
    new-instance v0, Lcom/kousei/framework/o4;

    invoke-direct {v0, v2, v3}, Lcom/kousei/framework/o4;-><init>(Ljava/util/LinkedHashMap;Ljava/util/LinkedHashSet;)V

    goto :goto_f2

    .line 23
    :cond_ed
    :goto_ed
    new-instance v0, Lcom/kousei/framework/o4;

    invoke-direct {v0, v2, v3}, Lcom/kousei/framework/o4;-><init>(Ljava/util/LinkedHashMap;Ljava/util/LinkedHashSet;)V

    .line 24
    :goto_f2
    new-instance v2, Ljava/util/HashMap;

    iget-object v3, v0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    check-cast v3, Ljava/util/Map;

    invoke-direct {v2, v3}, Ljava/util/HashMap;-><init>(Ljava/util/Map;)V

    .line 25
    new-instance v3, Ljava/util/HashSet;

    iget-object v0, v0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    check-cast v0, Ljava/util/Set;

    invoke-direct {v3, v0}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    const/4 v0, 0x0

    if-eqz v1, :cond_1f9

    .line 26
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-eqz v8, :cond_113

    goto/16 :goto_1f9

    .line 27
    :cond_113
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    .line 28
    new-instance v9, Ljava/util/LinkedHashMap;

    invoke-direct {v9}, Ljava/util/LinkedHashMap;-><init>()V

    const-wide v10, -0xa7130dbb5469L

    .line 29
    invoke-static {v10, v11}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v1, v10}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    array-length v10, v1

    move-object v12, v0

    move v11, v7

    move v13, v11

    :goto_12e
    if-ge v11, v10, :cond_1b4

    aget-object v14, v1, v11

    .line 30
    invoke-virtual {v14}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v14

    .line 31
    invoke-virtual {v14}, Ljava/lang/String;->isEmpty()Z

    move-result v15

    if-nez v15, :cond_1b0

    const-wide v15, -0xa7150dbb5469L

    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v15

    if-eqz v15, :cond_14d

    goto/16 :goto_1b0

    :cond_14d
    const-wide v15, -0xa7170dbb5469L

    .line 32
    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v15

    if-eqz v15, :cond_19b

    const-wide v15, -0xa7290dbb5469L

    invoke-static/range {v15 .. v16}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v15

    if-eqz v15, :cond_19b

    .line 33
    invoke-virtual {v14}, Ljava/lang/String;->length()I

    move-result v12

    sub-int/2addr v12, v6

    invoke-virtual {v14, v6, v12}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v12

    if-eqz v12, :cond_186

    .line 34
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v12, v13}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_186

    move v13, v6

    goto :goto_187

    :cond_186
    move v13, v7

    :goto_187
    xor-int/lit8 v14, v13, 0x1

    if-nez v13, :cond_18d

    move-object v15, v0

    goto :goto_18e

    :cond_18d
    move-object v15, v12

    :goto_18e
    if-eqz v13, :cond_198

    .line 35
    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    invoke-interface {v9, v12, v13}, Ljava/util/Map;->putIfAbsent(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_198
    move v13, v14

    move-object v12, v15

    goto :goto_1b0

    :cond_19b
    if-eqz v13, :cond_19e

    goto :goto_1b0

    :cond_19e
    if-nez v12, :cond_1a2

    move-object v15, v8

    goto :goto_1a8

    .line 36
    :cond_1a2
    invoke-virtual {v9, v12}, Ljava/util/LinkedHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v15

    check-cast v15, Ljava/lang/StringBuilder;

    .line 37
    :goto_1a8
    invoke-virtual {v15, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/16 v14, 0xa

    invoke-virtual {v15, v14}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    :cond_1b0
    :goto_1b0
    add-int/lit8 v11, v11, 0x1

    goto/16 :goto_12e

    .line 38
    :cond_1b4
    new-instance v0, Ljava/util/LinkedHashMap;

    invoke-direct {v0}, Ljava/util/LinkedHashMap;-><init>()V

    .line 39
    invoke-virtual {v9}, Ljava/util/LinkedHashMap;->entrySet()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_1c1
    :goto_1c1
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_1e7

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/util/Map$Entry;

    .line 40
    invoke-interface {v4}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Lcom/kousei/framework/b7;->g(Ljava/lang/String;)Lcom/kousei/framework/v6;

    move-result-object v5

    if-eqz v5, :cond_1c1

    .line 41
    invoke-interface {v4}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-interface {v0, v4, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_1c1

    .line 42
    :cond_1e7
    new-instance v1, Lcom/kousei/framework/o4;

    .line 43
    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v4}, Lcom/kousei/framework/b7;->g(Ljava/lang/String;)Lcom/kousei/framework/v6;

    move-result-object v4

    .line 44
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    invoke-direct {v1, v4, v0}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    goto :goto_200

    .line 45
    :cond_1f9
    :goto_1f9
    new-instance v1, Lcom/kousei/framework/o4;

    sget-object v4, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    invoke-direct {v1, v0, v4}, Lcom/kousei/framework/o4;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 46
    :goto_200
    new-instance v4, Lcom/kousei/framework/x6;

    .line 47
    invoke-static {v2}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v5

    .line 48
    invoke-static {v3}, Ljava/util/Collections;->unmodifiableSet(Ljava/util/Set;)Ljava/util/Set;

    move-result-object v6

    iget-object v0, v1, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    move-object v7, v0

    check-cast v7, Lcom/kousei/framework/v6;

    iget-object v0, v1, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    move-object v8, v0

    check-cast v8, Ljava/util/Map;

    move/from16 v9, p2

    move/from16 v10, p3

    move-object/from16 v11, p4

    invoke-direct/range {v4 .. v11}, Lcom/kousei/framework/x6;-><init>(Ljava/util/Map;Ljava/util/Set;Lcom/kousei/framework/v6;Ljava/util/Map;ZZLcom/kousei/framework/ma;)V

    return-object v4
.end method

.method public static m(Ljava/lang/String;)Ljava/lang/String;
    .registers 7

    .line 1
    const-wide v0, -0xa72b0dbb5469L

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
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    .line 11
    .line 12
    .line 13
    move-result-object v0

    .line 14
    sget-object v1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 15
    .line 16
    invoke-virtual {p0, v1}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 17
    .line 18
    .line 19
    move-result-object p0

    .line 20
    invoke-virtual {v0, p0}, Ljava/security/MessageDigest;->digest([B)[B

    .line 21
    .line 22
    .line 23
    move-result-object p0

    .line 24
    array-length v0, p0

    .line 25
    mul-int/lit8 v0, v0, 0x2

    .line 26
    .line 27
    new-array v0, v0, [C

    .line 28
    .line 29
    const-wide v1, -0xa7230dbb5469L

    .line 30
    .line 31
    .line 32
    .line 33
    .line 34
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 35
    .line 36
    .line 37
    move-result-object v1

    .line 38
    invoke-virtual {v1}, Ljava/lang/String;->toCharArray()[C

    .line 39
    .line 40
    .line 41
    move-result-object v1

    .line 42
    const/4 v2, 0x0

    .line 43
    :goto_2a
    array-length v3, p0

    .line 44
    if-ge v2, v3, :cond_44

    .line 45
    .line 46
    aget-byte v3, p0, v2

    .line 47
    .line 48
    and-int/lit16 v4, v3, 0xff

    .line 49
    .line 50
    mul-int/lit8 v5, v2, 0x2

    .line 51
    .line 52
    ushr-int/lit8 v4, v4, 0x4

    .line 53
    .line 54
    aget-char v4, v1, v4

    .line 55
    .line 56
    aput-char v4, v0, v5

    .line 57
    .line 58
    add-int/lit8 v5, v5, 0x1

    .line 59
    .line 60
    and-int/lit8 v3, v3, 0xf

    .line 61
    .line 62
    aget-char v3, v1, v3

    .line 63
    .line 64
    aput-char v3, v0, v5

    .line 65
    .line 66
    add-int/lit8 v2, v2, 0x1

    .line 67
    .line 68
    goto :goto_2a

    .line 69
    :cond_44
    new-instance p0, Ljava/lang/String;

    .line 70
    .line 71
    invoke-direct {p0, v0}, Ljava/lang/String;-><init>([C)V

    .line 72
    .line 73
    .line 74
    return-object p0
.end method

.method public static n(Ljava/lang/String;)[B
    .registers 3

    .line 1
    const/4 v0, 0x0

    .line 2
    if-nez p0, :cond_4

    .line 3
    .line 4
    return-object v0

    .line 5
    :cond_4
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 6
    .line 7
    .line 8
    move-result-object p0

    .line 9
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_f

    .line 14
    .line 15
    return-object v0

    .line 16
    :cond_f
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 17
    .line 18
    invoke-virtual {p0, v0}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    .line 19
    .line 20
    .line 21
    move-result-object p0

    .line 22
    return-object p0
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/a7;
    .registers 5

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/b7;->l()V

    .line 2
    .line 3
    .line 4
    iget-object v0, p0, Lcom/kousei/framework/b7;->e:Ljava/lang/Object;

    .line 5
    .line 6
    monitor-enter v0

    .line 7
    :try_start_6
    iget-object v1, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;

    .line 8
    .line 9
    sget-object v2, Lcom/kousei/framework/a7;->b:Lcom/kousei/framework/a7;
    :try_end_a
    .catchall {:try_start_6 .. :try_end_a} :catchall_14

    .line 10
    .line 11
    if-ne v1, v2, :cond_1d

    .line 12
    .line 13
    :try_start_c
    iget-object v1, p0, Lcom/kousei/framework/b7;->e:Ljava/lang/Object;

    .line 14
    .line 15
    const-wide/16 v2, 0xfa

    .line 16
    .line 17
    invoke-virtual {v1, v2, v3}, Ljava/lang/Object;->wait(J)V
    :try_end_13
    .catch Ljava/lang/InterruptedException; {:try_start_c .. :try_end_13} :catch_16
    .catchall {:try_start_c .. :try_end_13} :catchall_14

    .line 18
    .line 19
    .line 20
    goto :goto_1d

    .line 21
    :catchall_14
    move-exception p0

    .line 22
    goto :goto_21

    .line 23
    :catch_16
    :try_start_16
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    .line 24
    .line 25
    .line 26
    move-result-object v1

    .line 27
    invoke-virtual {v1}, Ljava/lang/Thread;->interrupt()V

    .line 28
    .line 29
    .line 30
    :cond_1d
    :goto_1d
    iget-object p0, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;

    .line 31
    .line 32
    monitor-exit v0

    .line 33
    return-object p0

    .line 34
    :goto_21
    monitor-exit v0
    :try_end_22
    .catchall {:try_start_16 .. :try_end_22} :catchall_14

    .line 35
    throw p0
.end method

.method public final d(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z
    .registers 9

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p1, :cond_56

    .line 3
    .line 4
    if-nez p3, :cond_6

    .line 5
    .line 6
    goto :goto_56

    .line 7
    :cond_6
    iget-object p1, p1, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 8
    .line 9
    check-cast p1, Lcom/kousei/framework/x6;

    .line 10
    .line 11
    iget-boolean v1, p1, Lcom/kousei/framework/x6;->e:Z

    .line 12
    .line 13
    if-nez v1, :cond_f

    .line 14
    .line 15
    goto :goto_56

    .line 16
    :cond_f
    :try_start_f
    new-instance v1, Lcom/kousei/framework/x;

    .line 17
    .line 18
    invoke-direct {v1, p1}, Lcom/kousei/framework/x;-><init>(Ljava/lang/Object;)V

    .line 19
    .line 20
    .line 21
    invoke-static {p2, p3, v1}, Lcom/kousei/framework/n6;->H(I[Ljava/lang/String;Lcom/kousei/framework/x;)Lcom/kousei/framework/r6;

    .line 22
    .line 23
    .line 24
    move-result-object p2
    :try_end_18
    .catchall {:try_start_f .. :try_end_18} :catchall_19

    .line 25
    goto :goto_1f

    .line 26
    :catchall_19
    const/4 p2, 0x5

    .line 27
    const/4 v1, 0x0

    .line 28
    invoke-static {p2, v1}, Lcom/kousei/framework/r6;->a(ILjava/util/List;)Lcom/kousei/framework/r6;

    .line 29
    .line 30
    .line 31
    move-result-object p2

    .line 32
    :goto_1f
    iget-boolean p2, p2, Lcom/kousei/framework/r6;->a:Z

    .line 33
    .line 34
    if-nez p2, :cond_24

    .line 35
    .line 36
    goto :goto_56

    .line 37
    :cond_24
    invoke-virtual {p0}, Lcom/kousei/framework/b7;->a()Lcom/kousei/framework/a7;

    .line 38
    .line 39
    .line 40
    move-result-object p0

    .line 41
    iget-boolean p2, p1, Lcom/kousei/framework/x6;->f:Z

    .line 42
    .line 43
    iget-object v1, p1, Lcom/kousei/framework/x6;->g:Lcom/kousei/framework/ma;

    .line 44
    .line 45
    iget-object p1, p1, Lcom/kousei/framework/x6;->a:Ljava/util/Map;

    .line 46
    .line 47
    move v2, v0

    .line 48
    :goto_2f
    array-length v3, p3

    .line 49
    if-ge v2, v3, :cond_56

    .line 50
    .line 51
    aget-object v3, p3, v2

    .line 52
    .line 53
    invoke-interface {p1, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 54
    .line 55
    .line 56
    move-result-object v3

    .line 57
    check-cast v3, Lcom/kousei/framework/ma;

    .line 58
    .line 59
    sget-object v4, Lcom/kousei/framework/ma;->d:Lcom/kousei/framework/ma;

    .line 60
    .line 61
    if-ne v3, v4, :cond_3f

    .line 62
    .line 63
    goto :goto_53

    .line 64
    :cond_3f
    if-nez v3, :cond_44

    .line 65
    .line 66
    if-eqz p2, :cond_44

    .line 67
    .line 68
    move-object v3, v1

    .line 69
    :cond_44
    sget-object v4, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 70
    .line 71
    if-ne v3, v4, :cond_49

    .line 72
    .line 73
    goto :goto_51

    .line 74
    :cond_49
    sget-object v4, Lcom/kousei/framework/ma;->a:Lcom/kousei/framework/ma;

    .line 75
    .line 76
    if-ne v3, v4, :cond_53

    .line 77
    .line 78
    sget-object v3, Lcom/kousei/framework/a7;->c:Lcom/kousei/framework/a7;

    .line 79
    .line 80
    if-eq p0, v3, :cond_53

    .line 81
    .line 82
    :goto_51
    const/4 p0, 0x1

    .line 83
    return p0

    .line 84
    :cond_53
    :goto_53
    add-int/lit8 v2, v2, 0x1

    .line 85
    .line 86
    goto :goto_2f

    .line 87
    :cond_56
    :goto_56
    return v0
.end method

.method public final e(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z
    .registers 9

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p1, :cond_56

    .line 3
    .line 4
    if-nez p3, :cond_6

    .line 5
    .line 6
    goto :goto_56

    .line 7
    :cond_6
    iget-object p1, p1, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 8
    .line 9
    check-cast p1, Lcom/kousei/framework/x6;

    .line 10
    .line 11
    iget-boolean v1, p1, Lcom/kousei/framework/x6;->e:Z

    .line 12
    .line 13
    if-nez v1, :cond_f

    .line 14
    .line 15
    goto :goto_56

    .line 16
    :cond_f
    :try_start_f
    new-instance v1, Lcom/kousei/framework/x;

    .line 17
    .line 18
    invoke-direct {v1, p1}, Lcom/kousei/framework/x;-><init>(Ljava/lang/Object;)V

    .line 19
    .line 20
    .line 21
    invoke-static {p2, p3, v1}, Lcom/kousei/framework/n6;->H(I[Ljava/lang/String;Lcom/kousei/framework/x;)Lcom/kousei/framework/r6;

    .line 22
    .line 23
    .line 24
    move-result-object p2
    :try_end_18
    .catchall {:try_start_f .. :try_end_18} :catchall_19

    .line 25
    goto :goto_1f

    .line 26
    :catchall_19
    const/4 p2, 0x5

    .line 27
    const/4 v1, 0x0

    .line 28
    invoke-static {p2, v1}, Lcom/kousei/framework/r6;->a(ILjava/util/List;)Lcom/kousei/framework/r6;

    .line 29
    .line 30
    .line 31
    move-result-object p2

    .line 32
    :goto_1f
    iget-boolean p2, p2, Lcom/kousei/framework/r6;->a:Z

    .line 33
    .line 34
    if-nez p2, :cond_24

    .line 35
    .line 36
    goto :goto_56

    .line 37
    :cond_24
    invoke-virtual {p0}, Lcom/kousei/framework/b7;->a()Lcom/kousei/framework/a7;

    .line 38
    .line 39
    .line 40
    move-result-object p0

    .line 41
    iget-boolean p2, p1, Lcom/kousei/framework/x6;->f:Z

    .line 42
    .line 43
    iget-object v1, p1, Lcom/kousei/framework/x6;->g:Lcom/kousei/framework/ma;

    .line 44
    .line 45
    iget-object p1, p1, Lcom/kousei/framework/x6;->a:Ljava/util/Map;

    .line 46
    .line 47
    move v2, v0

    .line 48
    :goto_2f
    array-length v3, p3

    .line 49
    if-ge v2, v3, :cond_56

    .line 50
    .line 51
    aget-object v3, p3, v2

    .line 52
    .line 53
    invoke-interface {p1, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 54
    .line 55
    .line 56
    move-result-object v3

    .line 57
    check-cast v3, Lcom/kousei/framework/ma;

    .line 58
    .line 59
    sget-object v4, Lcom/kousei/framework/ma;->d:Lcom/kousei/framework/ma;

    .line 60
    .line 61
    if-ne v3, v4, :cond_3f

    .line 62
    .line 63
    goto :goto_53

    .line 64
    :cond_3f
    if-nez v3, :cond_44

    .line 65
    .line 66
    if-eqz p2, :cond_44

    .line 67
    .line 68
    move-object v3, v1

    .line 69
    :cond_44
    sget-object v4, Lcom/kousei/framework/ma;->b:Lcom/kousei/framework/ma;

    .line 70
    .line 71
    if-ne v3, v4, :cond_49

    .line 72
    .line 73
    goto :goto_51

    .line 74
    :cond_49
    sget-object v4, Lcom/kousei/framework/ma;->a:Lcom/kousei/framework/ma;

    .line 75
    .line 76
    if-ne v3, v4, :cond_53

    .line 77
    .line 78
    sget-object v3, Lcom/kousei/framework/a7;->c:Lcom/kousei/framework/a7;

    .line 79
    .line 80
    if-ne p0, v3, :cond_53

    .line 81
    .line 82
    :goto_51
    const/4 p0, 0x1

    .line 83
    return p0

    .line 84
    :cond_53
    :goto_53
    add-int/lit8 v2, v2, 0x1

    .line 85
    .line 86
    goto :goto_2f

    .line 87
    :cond_56
    :goto_56
    return v0
.end method

.method public final k(Z)V
    .registers 14

    .line 1
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    .line 2
    .line 3
    .line 4
    move-result-wide v0

    .line 5
    const-wide/16 v2, 0x1388

    .line 6
    .line 7
    const-wide/16 v4, 0x0

    .line 8
    .line 9
    if-nez p1, :cond_19

    .line 10
    .line 11
    iget-wide v6, p0, Lcom/kousei/framework/b7;->d:J

    .line 12
    .line 13
    cmp-long v6, v6, v4

    .line 14
    .line 15
    if-eqz v6, :cond_19

    .line 16
    .line 17
    iget-wide v6, p0, Lcom/kousei/framework/b7;->d:J

    .line 18
    .line 19
    sub-long/2addr v0, v6

    .line 20
    cmp-long v0, v0, v2

    .line 21
    .line 22
    if-gez v0, :cond_19

    .line 23
    .line 24
    goto/16 :goto_194

    .line 25
    .line 26
    :cond_19
    iget-object v0, p0, Lcom/kousei/framework/b7;->b:Ljava/lang/Object;

    .line 27
    .line 28
    monitor-enter v0

    .line 29
    :try_start_1c
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    .line 30
    .line 31
    .line 32
    move-result-wide v6

    .line 33
    if-nez p1, :cond_35

    .line 34
    .line 35
    iget-wide v8, p0, Lcom/kousei/framework/b7;->d:J

    .line 36
    .line 37
    cmp-long v1, v8, v4

    .line 38
    .line 39
    if-eqz v1, :cond_35

    .line 40
    .line 41
    iget-wide v4, p0, Lcom/kousei/framework/b7;->d:J

    .line 42
    .line 43
    sub-long v4, v6, v4

    .line 44
    .line 45
    cmp-long v1, v4, v2

    .line 46
    .line 47
    if-gez v1, :cond_35

    .line 48
    .line 49
    monitor-exit v0

    .line 50
    return-void

    .line 51
    :catchall_32
    move-exception p0

    .line 52
    goto/16 :goto_195

    .line 53
    .line 54
    :cond_35
    iput-wide v6, p0, Lcom/kousei/framework/b7;->d:J

    .line 55
    .line 56
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    .line 57
    .line 58
    .line 59
    move-result-object v1

    .line 60
    if-nez v1, :cond_5f

    .line 61
    .line 62
    invoke-static {}, Landroid/app/ActivityThread;->currentActivityThread()Landroid/app/ActivityThread;

    .line 63
    .line 64
    .line 65
    move-result-object v2
    :try_end_41
    .catchall {:try_start_1c .. :try_end_41} :catchall_32

    .line 66
    if-eqz v2, :cond_5f

    .line 67
    .line 68
    :try_start_43
    invoke-static {}, Landroid/app/ActivityThread;->currentPackageName()Ljava/lang/String;

    .line 69
    .line 70
    .line 71
    move-result-object v1

    .line 72
    invoke-virtual {v2}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 73
    .line 74
    .line 75
    move-result-object v3

    .line 76
    if-eqz v1, :cond_59

    .line 77
    .line 78
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    .line 79
    .line 80
    .line 81
    move-result v4

    .line 82
    if-nez v4, :cond_59

    .line 83
    .line 84
    const/4 v4, 0x0

    .line 85
    invoke-virtual {v3, v1, v4}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    .line 86
    .line 87
    .line 88
    move-result-object v1
    :try_end_58
    .catch Ljava/lang/Exception; {:try_start_43 .. :try_end_58} :catch_5b
    .catchall {:try_start_43 .. :try_end_58} :catchall_32

    .line 89
    goto :goto_5f

    .line 90
    :cond_59
    move-object v1, v3

    .line 91
    goto :goto_5f

    .line 92
    :catch_5b
    :try_start_5b
    invoke-virtual {v2}, Landroid/app/ActivityThread;->getSystemContext()Landroid/app/ContextImpl;

    .line 93
    .line 94
    .line 95
    move-result-object v1

    .line 96
    :cond_5f
    :goto_5f
    const/4 v2, 0x0

    .line 97
    if-nez v1, :cond_64

    .line 98
    .line 99
    move-object v1, v2

    .line 100
    goto :goto_68

    .line 101
    :cond_64
    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 102
    .line 103
    .line 104
    move-result-object v1

    .line 105
    :goto_68
    if-nez v1, :cond_6d

    .line 106
    .line 107
    monitor-exit v0
    :try_end_6b
    .catchall {:try_start_5b .. :try_end_6b} :catchall_32

    .line 108
    goto/16 :goto_194

    .line 109
    .line 110
    :cond_6d
    :try_start_6d
    invoke-static {v1}, Lcom/kousei/framework/KaoriosFramework;->getKaoriosTimeToken(Landroid/content/ContentResolver;)Ljava/lang/String;

    .line 111
    .line 112
    .line 113
    move-result-object v3
    :try_end_71
    .catchall {:try_start_6d .. :try_end_71} :catchall_193

    .line 114
    if-nez p1, :cond_82

    .line 115
    .line 116
    :try_start_73
    iget-object p1, p0, Lcom/kousei/framework/b7;->c:Ljava/lang/String;

    .line 117
    .line 118
    if-eqz p1, :cond_82

    .line 119
    .line 120
    iget-object p1, p0, Lcom/kousei/framework/b7;->c:Ljava/lang/String;

    .line 121
    .line 122
    invoke-virtual {p1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 123
    .line 124
    .line 125
    move-result p1

    .line 126
    if-eqz p1, :cond_82

    .line 127
    .line 128
    monitor-exit v0
    :try_end_80
    .catchall {:try_start_73 .. :try_end_80} :catchall_32

    .line 129
    goto/16 :goto_194

    .line 130
    .line 131
    :cond_82
    const-wide v4, -0xa7d40dbb5469L

    .line 132
    .line 133
    .line 134
    .line 135
    .line 136
    :try_start_87
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 137
    .line 138
    .line 139
    move-result-object p1

    .line 140
    invoke-static {v1, p1}, Lcom/kousei/framework/KaoriosFramework;->getGlobalString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    .line 141
    .line 142
    .line 143
    move-result-object p1

    .line 144
    const-wide v4, -0xa7f90dbb5469L

    .line 145
    .line 146
    .line 147
    .line 148
    .line 149
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 150
    .line 151
    .line 152
    move-result-object v4

    .line 153
    invoke-static {v1, v4}, Lcom/kousei/framework/KaoriosFramework;->getGlobalString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    .line 154
    .line 155
    .line 156
    move-result-object v4

    .line 157
    const-wide v5, -0xa70a0dbb5469L

    .line 158
    .line 159
    .line 160
    .line 161
    .line 162
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 163
    .line 164
    .line 165
    move-result-object v5

    .line 166
    invoke-static {v1, v5}, Lcom/kousei/framework/KaoriosFramework;->getGlobalString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    .line 167
    .line 168
    .line 169
    move-result-object v5
    :try_end_a9
    .catchall {:try_start_87 .. :try_end_a9} :catchall_191

    .line 170
    :try_start_a9
    invoke-static {v1}, Lcom/kousei/framework/KaoriosFramework;->readPifConfigString(Landroid/content/ContentResolver;)Ljava/lang/String;

    .line 171
    .line 172
    .line 173
    move-result-object v6
    :try_end_ad
    .catchall {:try_start_a9 .. :try_end_ad} :catchall_ae

    .line 174
    goto :goto_af

    .line 175
    :catchall_ae
    move-object v6, v2

    .line 176
    :goto_af
    if-eqz v6, :cond_d4

    .line 177
    .line 178
    :try_start_b1
    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 179
    .line 180
    .line 181
    move-result-object v7

    .line 182
    invoke-virtual {v7}, Ljava/lang/String;->isEmpty()Z

    .line 183
    .line 184
    .line 185
    move-result v7

    .line 186
    if-nez v7, :cond_d4

    .line 187
    .line 188
    iget-object v7, p0, Lcom/kousei/framework/b7;->h:Ljava/lang/String;

    .line 189
    .line 190
    invoke-virtual {v6, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 191
    .line 192
    .line 193
    move-result v7

    .line 194
    if-eqz v7, :cond_ca

    .line 195
    .line 196
    iget-object v7, p0, Lcom/kousei/framework/b7;->i:Lcom/kousei/framework/w6;

    .line 197
    .line 198
    if-eqz v7, :cond_ca

    .line 199
    .line 200
    iget-object v6, p0, Lcom/kousei/framework/b7;->i:Lcom/kousei/framework/w6;

    .line 201
    .line 202
    goto :goto_d9

    .line 203
    :cond_ca
    invoke-static {v6}, Lcom/kousei/framework/b7;->h(Ljava/lang/String;)Lcom/kousei/framework/w6;

    .line 204
    .line 205
    .line 206
    move-result-object v7

    .line 207
    iput-object v6, p0, Lcom/kousei/framework/b7;->h:Ljava/lang/String;

    .line 208
    .line 209
    iput-object v7, p0, Lcom/kousei/framework/b7;->i:Lcom/kousei/framework/w6;

    .line 210
    .line 211
    move-object v6, v7

    .line 212
    goto :goto_d9

    .line 213
    :cond_d4
    iput-object v2, p0, Lcom/kousei/framework/b7;->h:Ljava/lang/String;

    .line 214
    .line 215
    iput-object v2, p0, Lcom/kousei/framework/b7;->i:Lcom/kousei/framework/w6;

    .line 216
    .line 217
    move-object v6, v2

    .line 218
    :goto_d9
    invoke-static {v1}, Lcom/kousei/framework/KaoriosFramework;->isKeyboxKeystoreSpoofEnabled(Landroid/content/ContentResolver;)Z

    .line 219
    .line 220
    .line 221
    move-result v7

    .line 222
    invoke-static {v1}, Lcom/kousei/framework/KaoriosFramework;->isKeyboxApplyToAllPackages(Landroid/content/ContentResolver;)Z

    .line 223
    .line 224
    .line 225
    move-result v8

    .line 226
    invoke-static {v1}, Lcom/kousei/framework/KaoriosFramework;->getKeyboxApplyToAllModeRaw(Landroid/content/ContentResolver;)Ljava/lang/String;

    .line 227
    .line 228
    .line 229
    move-result-object v1

    .line 230
    if-nez v1, :cond_ea

    .line 231
    .line 232
    sget-object v1, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 233
    .line 234
    goto :goto_12c

    .line 235
    :cond_ea
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 236
    .line 237
    .line 238
    move-result-object v1

    .line 239
    sget-object v9, Ljava/util/Locale;->US:Ljava/util/Locale;

    .line 240
    .line 241
    invoke-virtual {v1, v9}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    .line 242
    .line 243
    .line 244
    move-result-object v1

    .line 245
    const-wide v9, -0xa6cc0dbb5469L

    .line 246
    .line 247
    .line 248
    .line 249
    .line 250
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 251
    .line 252
    .line 253
    move-result-object v9

    .line 254
    invoke-virtual {v9, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 255
    .line 256
    .line 257
    move-result v9

    .line 258
    if-eqz v9, :cond_106

    .line 259
    .line 260
    sget-object v1, Lcom/kousei/framework/ma;->b:Lcom/kousei/framework/ma;

    .line 261
    .line 262
    goto :goto_12c

    .line 263
    :cond_106
    const-wide v9, -0xa6c30dbb5469L

    .line 264
    .line 265
    .line 266
    .line 267
    .line 268
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 269
    .line 270
    .line 271
    move-result-object v9

    .line 272
    invoke-virtual {v9, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 273
    .line 274
    .line 275
    move-result v9

    .line 276
    if-eqz v9, :cond_118

    .line 277
    .line 278
    sget-object v1, Lcom/kousei/framework/ma;->a:Lcom/kousei/framework/ma;

    .line 279
    .line 280
    goto :goto_12c

    .line 281
    :cond_118
    const-wide v9, -0xa6c60dbb5469L

    .line 282
    .line 283
    .line 284
    .line 285
    .line 286
    invoke-static {v9, v10}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 287
    .line 288
    .line 289
    move-result-object v9

    .line 290
    invoke-virtual {v9, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 291
    .line 292
    .line 293
    move-result v1

    .line 294
    if-eqz v1, :cond_12a

    .line 295
    .line 296
    sget-object v1, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 297
    .line 298
    goto :goto_12c

    .line 299
    :cond_12a
    sget-object v1, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 300
    .line 301
    :goto_12c
    invoke-static {p1, v5, v7, v8, v1}, Lcom/kousei/framework/b7;->j(Ljava/lang/String;Ljava/lang/String;ZZLcom/kousei/framework/ma;)Lcom/kousei/framework/x6;

    .line 302
    .line 303
    .line 304
    move-result-object p1

    .line 305
    if-eqz v4, :cond_172

    .line 306
    .line 307
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 308
    .line 309
    .line 310
    move-result-object v1

    .line 311
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    .line 312
    .line 313
    .line 314
    move-result v1

    .line 315
    if-eqz v1, :cond_13d

    .line 316
    .line 317
    goto :goto_172

    .line 318
    :cond_13d
    invoke-static {v4}, Lcom/kousei/framework/b7;->m(Ljava/lang/String;)Ljava/lang/String;

    .line 319
    .line 320
    .line 321
    move-result-object v1

    .line 322
    iget-object v5, p0, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 323
    .line 324
    iget-object v7, v5, Lcom/kousei/framework/m0;->d:Ljava/lang/Object;

    .line 325
    .line 326
    check-cast v7, Ljava/lang/String;

    .line 327
    .line 328
    invoke-virtual {v1, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 329
    .line 330
    .line 331
    move-result v7

    .line 332
    if-eqz v7, :cond_150

    .line 333
    .line 334
    iget-object v2, v5, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 335
    .line 336
    goto :goto_175

    .line 337
    :cond_150
    iget-object v5, p0, Lcom/kousei/framework/b7;->j:Lcom/kousei/framework/g3;

    .line 338
    .line 339
    invoke-virtual {v5}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 340
    .line 341
    .line 342
    invoke-static {v4}, Lcom/kousei/framework/g3;->c(Ljava/lang/String;)Lcom/kousei/framework/o4;

    .line 343
    .line 344
    .line 345
    move-result-object v4

    .line 346
    iget-object v5, v4, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    .line 347
    .line 348
    check-cast v5, Lcom/kousei/framework/s5;

    .line 349
    .line 350
    sget-object v7, Lcom/kousei/framework/s5;->c:Lcom/kousei/framework/s5;
    :try_end_15f
    .catchall {:try_start_b1 .. :try_end_15f} :catchall_191

    .line 351
    .line 352
    if-ne v5, v7, :cond_163

    .line 353
    .line 354
    :try_start_161
    monitor-exit v0
    :try_end_162
    .catchall {:try_start_161 .. :try_end_162} :catchall_32

    .line 355
    goto :goto_194

    .line 356
    :cond_163
    :try_start_163
    sget-object v7, Lcom/kousei/framework/s5;->b:Lcom/kousei/framework/s5;

    .line 357
    .line 358
    if-ne v5, v7, :cond_16d

    .line 359
    .line 360
    sget-object v1, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 361
    .line 362
    :goto_169
    move-object v11, v2

    .line 363
    move-object v2, v1

    .line 364
    move-object v1, v11

    .line 365
    goto :goto_175

    .line 366
    :cond_16d
    iget-object v2, v4, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 367
    .line 368
    check-cast v2, Lcom/kousei/framework/u5;

    .line 369
    .line 370
    goto :goto_175

    .line 371
    :cond_172
    :goto_172
    sget-object v1, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 372
    .line 373
    goto :goto_169

    .line 374
    :goto_175
    new-instance v4, Lcom/kousei/framework/m0;

    .line 375
    .line 376
    invoke-direct {v4, p1, v2, v1, v6}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/x6;Lcom/kousei/framework/u5;Ljava/lang/String;Lcom/kousei/framework/w6;)V

    .line 377
    .line 378
    .line 379
    iput-object v4, p0, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 380
    .line 381
    iget-object p1, p0, Lcom/kousei/framework/b7;->j:Lcom/kousei/framework/g3;

    .line 382
    .line 383
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 384
    .line 385
    .line 386
    if-eqz v2, :cond_184

    .line 387
    .line 388
    goto :goto_186

    .line 389
    :cond_184
    sget-object p1, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 390
    .line 391
    :goto_186
    iput-object v3, p0, Lcom/kousei/framework/b7;->c:Ljava/lang/String;

    .line 392
    .line 393
    iget-object p0, p0, Lcom/kousei/framework/b7;->k:Lcom/kousei/framework/z5;

    .line 394
    .line 395
    invoke-virtual {v2}, Lcom/kousei/framework/u5;->a()Ljava/util/Set;

    .line 396
    .line 397
    .line 398
    move-result-object p1

    .line 399
    invoke-virtual {p0, p1}, Lcom/kousei/framework/z5;->e(Ljava/util/Set;)V
    :try_end_191
    .catchall {:try_start_163 .. :try_end_191} :catchall_191

    .line 400
    .line 401
    .line 402
    :catchall_191
    :try_start_191
    monitor-exit v0

    .line 403
    goto :goto_194

    .line 404
    :catchall_193
    monitor-exit v0

    .line 405
    :goto_194
    return-void

    .line 406
    :goto_195
    monitor-exit v0
    :try_end_196
    .catchall {:try_start_191 .. :try_end_196} :catchall_32

    .line 407
    throw p0
.end method

.method public final l()V
    .registers 4

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/b7;->e:Ljava/lang/Object;

    .line 2
    .line 3
    monitor-enter v0

    .line 4
    :try_start_3
    iget-object v1, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;

    .line 5
    .line 6
    sget-object v2, Lcom/kousei/framework/a7;->a:Lcom/kousei/framework/a7;

    .line 7
    .line 8
    if-eq v1, v2, :cond_d

    .line 9
    .line 10
    monitor-exit v0

    .line 11
    return-void

    .line 12
    :catchall_b
    move-exception p0

    .line 13
    goto :goto_2a

    .line 14
    :cond_d
    sget-object v1, Lcom/kousei/framework/a7;->b:Lcom/kousei/framework/a7;

    .line 15
    .line 16
    iput-object v1, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;
    :try_end_11
    .catchall {:try_start_3 .. :try_end_11} :catchall_b

    .line 17
    .line 18
    :try_start_11
    iget-object v1, p0, Lcom/kousei/framework/b7;->f:Ljava/util/concurrent/ExecutorService;

    .line 19
    .line 20
    new-instance v2, Lcom/kousei/framework/u6;

    .line 21
    .line 22
    invoke-direct {v2, p0}, Lcom/kousei/framework/u6;-><init>(Lcom/kousei/framework/b7;)V

    .line 23
    .line 24
    .line 25
    invoke-interface {v1, v2}, Ljava/util/concurrent/Executor;->execute(Ljava/lang/Runnable;)V
    :try_end_1b
    .catch Ljava/lang/RuntimeException; {:try_start_11 .. :try_end_1b} :catch_1c
    .catchall {:try_start_11 .. :try_end_1b} :catchall_b

    .line 26
    .line 27
    .line 28
    goto :goto_28

    .line 29
    :catch_1c
    :try_start_1c
    sget-object v1, Lcom/kousei/framework/a7;->d:Lcom/kousei/framework/a7;

    .line 30
    .line 31
    iput-object v1, p0, Lcom/kousei/framework/b7;->g:Lcom/kousei/framework/a7;

    .line 32
    .line 33
    iget-object p0, p0, Lcom/kousei/framework/b7;->e:Ljava/lang/Object;

    .line 34
    .line 35
    invoke-virtual {p0}, Ljava/lang/Object;->notifyAll()V
    :try_end_25
    .catchall {:try_start_1c .. :try_end_25} :catchall_b

    .line 36
    .line 37
    .line 38
    const/4 p0, 0x1

    .line 39
    :try_start_26
    sput-boolean p0, Lcom/kousei/framework/n0;->a:Z
    :try_end_28
    .catchall {:try_start_26 .. :try_end_28} :catchall_28

    .line 40
    .line 41
    :catchall_28
    :goto_28
    :try_start_28
    monitor-exit v0

    .line 42
    return-void

    .line 43
    :goto_2a
    monitor-exit v0
    :try_end_2b
    .catchall {:try_start_28 .. :try_end_2b} :catchall_b

    .line 44
    throw p0
.end method
