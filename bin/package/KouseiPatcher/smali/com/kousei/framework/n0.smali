.class public abstract Lcom/kousei/framework/n0;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static volatile a:Z

.field public static volatile b:Ljava/lang/Integer;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0xa45f0dbb5469L

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
    sput-boolean v0, Lcom/kousei/framework/n0;->a:Z

    .line 11
    .line 12
    return-void
.end method

.method public static a(Lcom/kousei/framework/v6;)I
    .registers 5

    .line 1
    const/4 v0, 0x1

    .line 2
    if-eqz p0, :cond_12

    .line 3
    .line 4
    iget-object v1, p0, Lcom/kousei/framework/v6;->c:Ljava/lang/String;

    .line 5
    .line 6
    if-eqz v1, :cond_12

    .line 7
    .line 8
    invoke-static {v1, v0}, Lcom/kousei/framework/n0;->f(Ljava/lang/String;Z)Ljava/lang/Integer;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    if-eqz v1, :cond_12

    .line 13
    .line 14
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    .line 15
    .line 16
    .line 17
    move-result p0

    .line 18
    return p0

    .line 19
    :cond_12
    const-wide v1, -0xa4230dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v1

    .line 28
    const-wide v2, -0xa4410dbb5469L

    .line 29
    .line 30
    .line 31
    .line 32
    .line 33
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 34
    .line 35
    .line 36
    move-result-object v2

    .line 37
    invoke-static {v1, v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    if-eqz v1, :cond_43

    .line 42
    .line 43
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 44
    .line 45
    .line 46
    move-result-object v2

    .line 47
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    .line 48
    .line 49
    .line 50
    move-result v2

    .line 51
    if-nez v2, :cond_43

    .line 52
    .line 53
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v1

    .line 57
    invoke-static {v1, v0}, Lcom/kousei/framework/n0;->f(Ljava/lang/String;Z)Ljava/lang/Integer;

    .line 58
    .line 59
    .line 60
    move-result-object v1

    .line 61
    if-eqz v1, :cond_43

    .line 62
    .line 63
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    .line 64
    .line 65
    .line 66
    move-result p0

    .line 67
    return p0

    .line 68
    :cond_43
    invoke-static {v0, p0}, Lcom/kousei/framework/n0;->d(ZLcom/kousei/framework/v6;)I

    .line 69
    .line 70
    .line 71
    move-result p0

    .line 72
    return p0
.end method

.method public static b()I
    .registers 6

    .line 1
    sget-object v0, Lcom/kousei/framework/n0;->b:Ljava/lang/Integer;

    .line 2
    .line 3
    if-eqz v0, :cond_9

    .line 4
    .line 5
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    return v0

    .line 10
    :cond_9
    const-class v0, Lcom/kousei/framework/n0;

    .line 11
    .line 12
    monitor-enter v0

    .line 13
    :try_start_c
    sget-object v1, Lcom/kousei/framework/n0;->b:Ljava/lang/Integer;

    .line 14
    .line 15
    if-eqz v1, :cond_1a

    .line 16
    .line 17
    sget-object v1, Lcom/kousei/framework/n0;->b:Ljava/lang/Integer;

    .line 18
    .line 19
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    .line 20
    .line 21
    .line 22
    move-result v1

    .line 23
    monitor-exit v0

    .line 24
    return v1

    .line 25
    :catchall_18
    move-exception v1

    .line 26
    goto :goto_41

    .line 27
    :cond_1a
    const/16 v1, 0x400

    .line 28
    .line 29
    const/16 v2, 0x800

    .line 30
    .line 31
    const/16 v3, 0x100

    .line 32
    .line 33
    const/16 v4, 0x200

    .line 34
    .line 35
    filled-new-array {v3, v4, v1, v2}, [I

    .line 36
    .line 37
    .line 38
    move-result-object v1

    .line 39
    const/16 v2, 0x80

    .line 40
    .line 41
    const/4 v3, 0x0

    .line 42
    :goto_29
    const/4 v4, 0x4

    .line 43
    if-ge v3, v4, :cond_39

    .line 44
    .line 45
    aget v4, v1, v3

    .line 46
    .line 47
    invoke-static {v4}, Lcom/kousei/framework/n0;->g(I)Z

    .line 48
    .line 49
    .line 50
    move-result v5

    .line 51
    if-nez v5, :cond_35

    .line 52
    .line 53
    goto :goto_39

    .line 54
    :cond_35
    add-int/lit8 v3, v3, 0x1

    .line 55
    .line 56
    move v2, v4

    .line 57
    goto :goto_29

    .line 58
    :cond_39
    :goto_39
    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 59
    .line 60
    .line 61
    move-result-object v1

    .line 62
    sput-object v1, Lcom/kousei/framework/n0;->b:Ljava/lang/Integer;

    .line 63
    .line 64
    monitor-exit v0

    .line 65
    return v2

    .line 66
    :goto_41
    monitor-exit v0
    :try_end_42
    .catchall {:try_start_c .. :try_end_42} :catchall_18

    .line 67
    throw v1
.end method

.method public static c()I
    .registers 8

    .line 1
    :try_start_0
    sget-object v0, Landroid/os/Build$VERSION;->RELEASE:Ljava/lang/String;

    .line 2
    .line 3
    if-eqz v0, :cond_8a

    .line 4
    .line 5
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-nez v1, :cond_8a

    .line 14
    .line 15
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 16
    .line 17
    .line 18
    move-result-object v0

    .line 19
    const-wide v1, -0xa4e20dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v1

    .line 28
    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    .line 29
    .line 30
    .line 31
    move-result-object v0

    .line 32
    const/4 v1, 0x0

    .line 33
    aget-object v2, v0, v1

    .line 34
    .line 35
    const-wide v3, -0xa4fb0dbb5469L

    .line 36
    .line 37
    .line 38
    .line 39
    .line 40
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 41
    .line 42
    .line 43
    move-result-object v3

    .line 44
    const-wide v4, -0xa4f00dbb5469L

    .line 45
    .line 46
    .line 47
    .line 48
    .line 49
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 50
    .line 51
    .line 52
    move-result-object v4

    .line 53
    invoke-virtual {v2, v3, v4}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v2

    .line 57
    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 58
    .line 59
    .line 60
    move-result v2

    .line 61
    if-lez v2, :cond_8a

    .line 62
    .line 63
    const/16 v3, 0x64

    .line 64
    .line 65
    if-ge v2, v3, :cond_8a

    .line 66
    .line 67
    array-length v4, v0

    .line 68
    const/4 v5, 0x1

    .line 69
    if-le v4, v5, :cond_63

    .line 70
    .line 71
    aget-object v4, v0, v5

    .line 72
    .line 73
    const-wide v5, -0xa4f30dbb5469L

    .line 74
    .line 75
    .line 76
    .line 77
    .line 78
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 79
    .line 80
    .line 81
    move-result-object v5

    .line 82
    const-wide v6, -0xa4080dbb5469L

    .line 83
    .line 84
    .line 85
    .line 86
    .line 87
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 88
    .line 89
    .line 90
    move-result-object v6

    .line 91
    invoke-virtual {v4, v5, v6}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 92
    .line 93
    .line 94
    move-result-object v4

    .line 95
    invoke-static {v4}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 96
    .line 97
    .line 98
    move-result v4

    .line 99
    goto :goto_64

    .line 100
    :cond_63
    move v4, v1

    .line 101
    :goto_64
    array-length v5, v0

    .line 102
    const/4 v6, 0x2

    .line 103
    if-le v5, v6, :cond_84

    .line 104
    .line 105
    aget-object v0, v0, v6

    .line 106
    .line 107
    const-wide v5, -0xa40b0dbb5469L

    .line 108
    .line 109
    .line 110
    .line 111
    .line 112
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 113
    .line 114
    .line 115
    move-result-object v1

    .line 116
    const-wide v5, -0xa4000dbb5469L

    .line 117
    .line 118
    .line 119
    .line 120
    .line 121
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 122
    .line 123
    .line 124
    move-result-object v5

    .line 125
    invoke-virtual {v0, v1, v5}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 126
    .line 127
    .line 128
    move-result-object v0

    .line 129
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 130
    .line 131
    .line 132
    move-result v1
    :try_end_84
    .catchall {:try_start_0 .. :try_end_84} :catchall_8a

    .line 133
    :cond_84
    mul-int/lit16 v2, v2, 0x2710

    .line 134
    .line 135
    mul-int/2addr v4, v3

    .line 136
    add-int/2addr v4, v2

    .line 137
    add-int/2addr v4, v1

    .line 138
    return v4

    .line 139
    :catchall_8a
    :cond_8a
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    .line 140
    .line 141
    packed-switch v0, :pswitch_data_a8

    .line 142
    .line 143
    .line 144
    const v0, 0x27100

    .line 145
    .line 146
    .line 147
    goto :goto_a6

    .line 148
    :pswitch_93
    const v0, 0x249f0

    .line 149
    .line 150
    .line 151
    goto :goto_a6

    .line 152
    :pswitch_97
    const v0, 0x222e0

    .line 153
    .line 154
    .line 155
    goto :goto_a6

    .line 156
    :pswitch_9b
    const v0, 0x1fbd0

    .line 157
    .line 158
    .line 159
    goto :goto_a6

    .line 160
    :pswitch_9f
    const v0, 0x1d524

    .line 161
    .line 162
    .line 163
    goto :goto_a6

    .line 164
    :pswitch_a3
    const v0, 0x1d4c0

    .line 165
    .line 166
    .line 167
    :goto_a6
    return v0

    .line 168
    nop

    .line 169
    :pswitch_data_a8
    .packed-switch 0x1f
        :pswitch_a3
        :pswitch_9f
        :pswitch_9b
        :pswitch_97
        :pswitch_93
    .end packed-switch
.end method

.method public static d(ZLcom/kousei/framework/v6;)I
    .registers 6

    .line 1
    if-eqz p1, :cond_11

    .line 2
    .line 3
    iget-object p1, p1, Lcom/kousei/framework/v6;->a:Ljava/lang/String;

    .line 4
    .line 5
    if-eqz p1, :cond_11

    .line 6
    .line 7
    invoke-static {p1, p0}, Lcom/kousei/framework/n0;->f(Ljava/lang/String;Z)Ljava/lang/Integer;

    .line 8
    .line 9
    .line 10
    move-result-object p1

    .line 11
    if-eqz p1, :cond_11

    .line 12
    .line 13
    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    .line 14
    .line 15
    .line 16
    move-result p0

    .line 17
    return p0

    .line 18
    :cond_11
    sget-object p1, Landroid/os/Build$VERSION;->SECURITY_PATCH:Ljava/lang/String;

    .line 19
    .line 20
    const-wide v0, -0xa45d0dbb5469L

    .line 21
    .line 22
    .line 23
    .line 24
    .line 25
    :try_start_18
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 26
    .line 27
    .line 28
    move-result-object v0

    .line 29
    invoke-virtual {p1, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    .line 30
    .line 31
    .line 32
    move-result-object p1

    .line 33
    const/4 v0, 0x2

    .line 34
    const/4 v1, 0x1

    .line 35
    const/4 v2, 0x0

    .line 36
    if-eqz p0, :cond_42

    .line 37
    .line 38
    array-length p0, p1

    .line 39
    const/4 v3, 0x3

    .line 40
    if-lt p0, v3, :cond_42

    .line 41
    .line 42
    aget-object p0, p1, v2

    .line 43
    .line 44
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 45
    .line 46
    .line 47
    move-result p0

    .line 48
    mul-int/lit16 p0, p0, 0x2710

    .line 49
    .line 50
    aget-object v1, p1, v1

    .line 51
    .line 52
    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 53
    .line 54
    .line 55
    move-result v1

    .line 56
    mul-int/lit8 v1, v1, 0x64

    .line 57
    .line 58
    add-int/2addr v1, p0

    .line 59
    aget-object p0, p1, v0

    .line 60
    .line 61
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 62
    .line 63
    .line 64
    move-result p0

    .line 65
    add-int/2addr v1, p0

    .line 66
    return v1

    .line 67
    :cond_42
    array-length p0, p1

    .line 68
    if-lt p0, v0, :cond_55

    .line 69
    .line 70
    aget-object p0, p1, v2

    .line 71
    .line 72
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 73
    .line 74
    .line 75
    move-result p0

    .line 76
    mul-int/lit8 p0, p0, 0x64

    .line 77
    .line 78
    aget-object p1, p1, v1

    .line 79
    .line 80
    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 81
    .line 82
    .line 83
    move-result p1
    :try_end_53
    .catch Ljava/lang/Exception; {:try_start_18 .. :try_end_53} :catch_55

    .line 84
    add-int/2addr p0, p1

    .line 85
    return p0

    .line 86
    :catch_55
    :cond_55
    const p0, 0x316a4

    .line 87
    .line 88
    .line 89
    return p0
.end method

.method public static e(Lcom/kousei/framework/v6;)I
    .registers 5

    .line 1
    const/4 v0, 0x1

    .line 2
    if-eqz p0, :cond_12

    .line 3
    .line 4
    iget-object v1, p0, Lcom/kousei/framework/v6;->b:Ljava/lang/String;

    .line 5
    .line 6
    if-eqz v1, :cond_12

    .line 7
    .line 8
    invoke-static {v1, v0}, Lcom/kousei/framework/n0;->f(Ljava/lang/String;Z)Ljava/lang/Integer;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    if-eqz v1, :cond_12

    .line 13
    .line 14
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    .line 15
    .line 16
    .line 17
    move-result p0

    .line 18
    return p0

    .line 19
    :cond_12
    const-wide v1, -0xa4030dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v1

    .line 28
    const-wide v2, -0xa4200dbb5469L

    .line 29
    .line 30
    .line 31
    .line 32
    .line 33
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 34
    .line 35
    .line 36
    move-result-object v2

    .line 37
    invoke-static {v1, v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    if-eqz v1, :cond_43

    .line 42
    .line 43
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 44
    .line 45
    .line 46
    move-result-object v2

    .line 47
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    .line 48
    .line 49
    .line 50
    move-result v2

    .line 51
    if-nez v2, :cond_43

    .line 52
    .line 53
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v1

    .line 57
    invoke-static {v1, v0}, Lcom/kousei/framework/n0;->f(Ljava/lang/String;Z)Ljava/lang/Integer;

    .line 58
    .line 59
    .line 60
    move-result-object v1

    .line 61
    if-eqz v1, :cond_43

    .line 62
    .line 63
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    .line 64
    .line 65
    .line 66
    move-result p0

    .line 67
    return p0

    .line 68
    :cond_43
    invoke-static {v0, p0}, Lcom/kousei/framework/n0;->d(ZLcom/kousei/framework/v6;)I

    .line 69
    .line 70
    .line 71
    move-result p0

    .line 72
    return p0
.end method

.method public static f(Ljava/lang/String;Z)Ljava/lang/Integer;
    .registers 7

    .line 1
    if-eqz p0, :cond_91

    .line 2
    .line 3
    const-wide v0, -0xa4400dbb5469L

    .line 4
    .line 5
    .line 6
    .line 7
    .line 8
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object v0

    .line 12
    invoke-virtual {p0, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 13
    .line 14
    .line 15
    move-result v0

    .line 16
    if-nez v0, :cond_91

    .line 17
    .line 18
    const-wide v0, -0xa4450dbb5469L

    .line 19
    .line 20
    .line 21
    .line 22
    .line 23
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 24
    .line 25
    .line 26
    move-result-object v0

    .line 27
    invoke-virtual {p0, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 28
    .line 29
    .line 30
    move-result v0

    .line 31
    if-eqz v0, :cond_21

    .line 32
    .line 33
    goto :goto_91

    .line 34
    :cond_21
    const-wide v0, -0xa4580dbb5469L

    .line 35
    .line 36
    .line 37
    .line 38
    .line 39
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object v0

    .line 43
    const-wide v1, -0xa45a0dbb5469L

    .line 44
    .line 45
    .line 46
    .line 47
    .line 48
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 49
    .line 50
    .line 51
    move-result-object v1

    .line 52
    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    .line 53
    .line 54
    .line 55
    move-result-object p0

    .line 56
    :try_start_37
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    .line 57
    .line 58
    .line 59
    move-result v0

    .line 60
    const/4 v1, 0x0

    .line 61
    const/16 v2, 0x8

    .line 62
    .line 63
    const/4 v3, 0x6

    .line 64
    const/4 v4, 0x4

    .line 65
    if-ne v0, v2, :cond_6b

    .line 66
    .line 67
    invoke-virtual {p0, v1, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 68
    .line 69
    .line 70
    move-result-object v0

    .line 71
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 72
    .line 73
    .line 74
    move-result v0

    .line 75
    invoke-virtual {p0, v4, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 76
    .line 77
    .line 78
    move-result-object v1

    .line 79
    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 80
    .line 81
    .line 82
    move-result v1

    .line 83
    invoke-virtual {p0, v3, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 84
    .line 85
    .line 86
    move-result-object p0

    .line 87
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 88
    .line 89
    .line 90
    move-result p0

    .line 91
    if-eqz p1, :cond_63

    .line 92
    .line 93
    mul-int/lit16 v0, v0, 0x2710

    .line 94
    .line 95
    mul-int/lit8 v1, v1, 0x64

    .line 96
    .line 97
    add-int/2addr v1, v0

    .line 98
    add-int/2addr v1, p0

    .line 99
    goto :goto_66

    .line 100
    :cond_63
    mul-int/lit8 v0, v0, 0x64

    .line 101
    .line 102
    add-int/2addr v1, v0

    .line 103
    :goto_66
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 104
    .line 105
    .line 106
    move-result-object p0

    .line 107
    return-object p0

    .line 108
    :cond_6b
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    .line 109
    .line 110
    .line 111
    move-result v0

    .line 112
    if-ne v0, v3, :cond_91

    .line 113
    .line 114
    invoke-virtual {p0, v1, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 115
    .line 116
    .line 117
    move-result-object v0

    .line 118
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 119
    .line 120
    .line 121
    move-result v0

    .line 122
    invoke-virtual {p0, v4, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 123
    .line 124
    .line 125
    move-result-object p0

    .line 126
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 127
    .line 128
    .line 129
    move-result p0

    .line 130
    if-eqz p1, :cond_89

    .line 131
    .line 132
    mul-int/lit16 v0, v0, 0x2710

    .line 133
    .line 134
    mul-int/lit8 p0, p0, 0x64

    .line 135
    .line 136
    add-int/2addr p0, v0

    .line 137
    goto :goto_8c

    .line 138
    :cond_89
    mul-int/lit8 v0, v0, 0x64

    .line 139
    .line 140
    add-int/2addr p0, v0

    .line 141
    :goto_8c
    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 142
    .line 143
    .line 144
    move-result-object p0
    :try_end_90
    .catch Ljava/lang/NumberFormatException; {:try_start_37 .. :try_end_90} :catch_91

    .line 145
    return-object p0

    .line 146
    :catch_91
    :cond_91
    :goto_91
    const/4 p0, 0x0

    .line 147
    return-object p0
.end method

.method public static g(I)Z
    .registers 8

    .line 1
    const-wide v0, -0xa5db0dbb5469L

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
    const-wide v4, -0xa5dc0dbb5469L

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
    const-wide v4, -0xa5ec0dbb5469L

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
    const/4 v5, 0x4

    .line 37
    invoke-direct {v1, v4, v5}, Landroid/security/keystore/KeyGenParameterSpec$Builder;-><init>(Ljava/lang/String;I)V

    .line 38
    .line 39
    .line 40
    new-instance v4, Ljava/security/spec/ECGenParameterSpec;

    .line 41
    .line 42
    const-wide v5, -0xa5f00dbb5469L

    .line 43
    .line 44
    .line 45
    .line 46
    .line 47
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 48
    .line 49
    .line 50
    move-result-object v5

    .line 51
    invoke-direct {v4, v5}, Ljava/security/spec/ECGenParameterSpec;-><init>(Ljava/lang/String;)V

    .line 52
    .line 53
    .line 54
    invoke-virtual {v1, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setAlgorithmParameterSpec(Ljava/security/spec/AlgorithmParameterSpec;)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 55
    .line 56
    .line 57
    move-result-object v1

    .line 58
    const-wide v4, -0xa50a0dbb5469L

    .line 59
    .line 60
    .line 61
    .line 62
    .line 63
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 64
    .line 65
    .line 66
    move-result-object v4

    .line 67
    filled-new-array {v4}, [Ljava/lang/String;

    .line 68
    .line 69
    .line 70
    move-result-object v4

    .line 71
    invoke-virtual {v1, v4}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setDigests([Ljava/lang/String;)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 72
    .line 73
    .line 74
    move-result-object v1

    .line 75
    new-array p0, p0, [B

    .line 76
    .line 77
    invoke-virtual {v1, p0}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->setAttestationChallenge([B)Landroid/security/keystore/KeyGenParameterSpec$Builder;

    .line 78
    .line 79
    .line 80
    move-result-object p0

    .line 81
    invoke-virtual {p0}, Landroid/security/keystore/KeyGenParameterSpec$Builder;->build()Landroid/security/keystore/KeyGenParameterSpec;

    .line 82
    .line 83
    .line 84
    move-result-object p0

    .line 85
    invoke-virtual {v0, p0}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 86
    .line 87
    .line 88
    invoke-virtual {v0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;
    :try_end_5a
    .catch Ljava/security/ProviderException; {:try_start_7 .. :try_end_5a} :catch_b3
    .catchall {:try_start_7 .. :try_end_5a} :catchall_87

    .line 89
    .line 90
    .line 91
    const-wide v0, -0xa5020dbb5469L

    .line 92
    .line 93
    .line 94
    .line 95
    .line 96
    const/4 p0, 0x1

    .line 97
    :try_start_60
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 98
    .line 99
    .line 100
    move-result-object v0

    .line 101
    invoke-static {v0}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 102
    .line 103
    .line 104
    move-result-object v0

    .line 105
    invoke-virtual {v0, v3}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 106
    .line 107
    .line 108
    const-wide v1, -0xa5120dbb5469L

    .line 109
    .line 110
    .line 111
    .line 112
    .line 113
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 114
    .line 115
    .line 116
    move-result-object v1

    .line 117
    invoke-virtual {v0, v1}, Ljava/security/KeyStore;->containsAlias(Ljava/lang/String;)Z

    .line 118
    .line 119
    .line 120
    move-result v1

    .line 121
    if-eqz v1, :cond_86

    .line 122
    .line 123
    const-wide v1, -0xa5260dbb5469L

    .line 124
    .line 125
    .line 126
    .line 127
    .line 128
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 129
    .line 130
    .line 131
    move-result-object v1

    .line 132
    invoke-virtual {v0, v1}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_86
    .catchall {:try_start_60 .. :try_end_86} :catchall_86

    .line 133
    .line 134
    .line 135
    :catchall_86
    :cond_86
    return p0

    .line 136
    :catchall_87
    const-wide v0, -0xa5720dbb5469L

    .line 137
    .line 138
    .line 139
    .line 140
    .line 141
    :try_start_8c
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 142
    .line 143
    .line 144
    move-result-object p0

    .line 145
    invoke-static {p0}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 146
    .line 147
    .line 148
    move-result-object p0

    .line 149
    invoke-virtual {p0, v3}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 150
    .line 151
    .line 152
    const-wide v0, -0xa4820dbb5469L

    .line 153
    .line 154
    .line 155
    .line 156
    .line 157
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 158
    .line 159
    .line 160
    move-result-object v0

    .line 161
    invoke-virtual {p0, v0}, Ljava/security/KeyStore;->containsAlias(Ljava/lang/String;)Z

    .line 162
    .line 163
    .line 164
    move-result v0

    .line 165
    if-eqz v0, :cond_b2

    .line 166
    .line 167
    const-wide v0, -0xa4960dbb5469L

    .line 168
    .line 169
    .line 170
    .line 171
    .line 172
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 173
    .line 174
    .line 175
    move-result-object v0

    .line 176
    invoke-virtual {p0, v0}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_b2
    .catchall {:try_start_8c .. :try_end_b2} :catchall_b2

    .line 177
    .line 178
    .line 179
    :catchall_b2
    :cond_b2
    return v2

    .line 180
    :catch_b3
    const-wide v0, -0xa54a0dbb5469L

    .line 181
    .line 182
    .line 183
    .line 184
    .line 185
    :try_start_b8
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 186
    .line 187
    .line 188
    move-result-object p0

    .line 189
    invoke-static {p0}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    .line 190
    .line 191
    .line 192
    move-result-object p0

    .line 193
    invoke-virtual {p0, v3}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 194
    .line 195
    .line 196
    const-wide v0, -0xa55a0dbb5469L

    .line 197
    .line 198
    .line 199
    .line 200
    .line 201
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 202
    .line 203
    .line 204
    move-result-object v0

    .line 205
    invoke-virtual {p0, v0}, Ljava/security/KeyStore;->containsAlias(Ljava/lang/String;)Z

    .line 206
    .line 207
    .line 208
    move-result v0

    .line 209
    if-eqz v0, :cond_de

    .line 210
    .line 211
    const-wide v0, -0xa56e0dbb5469L

    .line 212
    .line 213
    .line 214
    .line 215
    .line 216
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 217
    .line 218
    .line 219
    move-result-object v0

    .line 220
    invoke-virtual {p0, v0}, Ljava/security/KeyStore;->deleteEntry(Ljava/lang/String;)V
    :try_end_de
    .catchall {:try_start_b8 .. :try_end_de} :catchall_de

    .line 221
    .line 222
    .line 223
    :catchall_de
    :cond_de
    return v2
.end method
