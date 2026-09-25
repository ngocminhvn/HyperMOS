.class public final Lcom/kousei/framework/o4;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/kousei/framework/h7;


# instance fields
.field public a:Ljava/lang/Object;

.field public b:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/va;Ljava/math/BigInteger;Ljava/util/Date;Ljava/util/Date;Lcom/kousei/framework/va;Lcom/kousei/framework/ka;)V
    .registers 9

    .line 1
    new-instance v0, Lcom/kousei/framework/qa;

    .line 2
    .line 3
    invoke-direct {v0, p3}, Lcom/kousei/framework/qa;-><init>(Ljava/util/Date;)V

    .line 4
    .line 5
    .line 6
    new-instance p3, Lcom/kousei/framework/qa;

    .line 7
    .line 8
    invoke-direct {p3, p4}, Lcom/kousei/framework/qa;-><init>(Ljava/util/Date;)V

    .line 9
    .line 10
    .line 11
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 12
    .line 13
    .line 14
    new-instance p4, Lcom/kousei/framework/sa;

    .line 15
    .line 16
    invoke-direct {p4}, Ljava/lang/Object;-><init>()V

    .line 17
    .line 18
    .line 19
    iput-object p4, p0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    .line 20
    .line 21
    new-instance v1, Lcom/kousei/framework/p;

    .line 22
    .line 23
    invoke-direct {v1, p2}, Lcom/kousei/framework/p;-><init>(Ljava/math/BigInteger;)V

    .line 24
    .line 25
    .line 26
    iput-object v1, p4, Lcom/kousei/framework/sa;->a:Lcom/kousei/framework/p;

    .line 27
    .line 28
    iput-object p1, p4, Lcom/kousei/framework/sa;->c:Lcom/kousei/framework/va;

    .line 29
    .line 30
    iput-object v0, p4, Lcom/kousei/framework/sa;->d:Lcom/kousei/framework/qa;

    .line 31
    .line 32
    iput-object p3, p4, Lcom/kousei/framework/sa;->e:Lcom/kousei/framework/qa;

    .line 33
    .line 34
    iput-object p5, p4, Lcom/kousei/framework/sa;->f:Lcom/kousei/framework/va;

    .line 35
    .line 36
    iput-object p6, p4, Lcom/kousei/framework/sa;->g:Lcom/kousei/framework/ka;

    .line 37
    .line 38
    new-instance p1, Lcom/kousei/framework/k4;

    .line 39
    .line 40
    invoke-direct {p1}, Lcom/kousei/framework/k4;-><init>()V

    .line 41
    .line 42
    .line 43
    iput-object p1, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 44
    .line 45
    return-void
.end method

.method public synthetic constructor <init>(Ljava/lang/Object;Ljava/lang/Object;)V
    .registers 3

    .line 46
    iput-object p1, p0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    iput-object p2, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public constructor <init>(Ljava/util/LinkedHashMap;Ljava/util/LinkedHashSet;)V
    .registers 3

    .line 47
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 48
    invoke-static {p1}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object p1

    iput-object p1, p0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    .line 49
    invoke-static {p2}, Ljava/util/Collections;->unmodifiableSet(Ljava/util/Set;)Ljava/util/Set;

    move-result-object p1

    iput-object p1, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    return-void
.end method


# virtual methods
.method public a(Lcom/kousei/framework/i7;)Lcom/kousei/framework/i7;
    .registers 12

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    .line 2
    .line 3
    check-cast v0, Lcom/kousei/framework/v3;

    .line 4
    .line 5
    instance-of v1, p1, Lcom/kousei/framework/n4;

    .line 6
    .line 7
    const/4 v2, 0x0

    .line 8
    if-eqz v1, :cond_c

    .line 9
    .line 10
    check-cast p1, Lcom/kousei/framework/n4;

    .line 11
    .line 12
    goto :goto_d

    .line 13
    :cond_c
    move-object p1, v2

    .line 14
    :goto_d
    iget-object v1, v0, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 15
    .line 16
    const/4 v3, 0x1

    .line 17
    if-nez v1, :cond_18

    .line 18
    .line 19
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->g()I

    .line 20
    .line 21
    .line 22
    move-result v1

    .line 23
    add-int/2addr v1, v3

    .line 24
    goto :goto_1c

    .line 25
    :cond_18
    invoke-virtual {v1}, Ljava/math/BigInteger;->bitLength()I

    .line 26
    .line 27
    .line 28
    move-result v1

    .line 29
    :goto_1c
    const/16 v4, 0xfa

    .line 30
    .line 31
    if-le v1, v4, :cond_22

    .line 32
    .line 33
    const/4 v4, 0x6

    .line 34
    goto :goto_23

    .line 35
    :cond_22
    const/4 v4, 0x5

    .line 36
    :goto_23
    shl-int v5, v3, v4

    .line 37
    .line 38
    if-eqz p1, :cond_32

    .line 39
    .line 40
    iget-object v6, p1, Lcom/kousei/framework/n4;->b:Lcom/kousei/framework/h0;

    .line 41
    .line 42
    if-eqz v6, :cond_32

    .line 43
    .line 44
    invoke-virtual {v6}, Lcom/kousei/framework/h0;->b0()I

    .line 45
    .line 46
    .line 47
    move-result v6

    .line 48
    if-lt v6, v5, :cond_32

    .line 49
    .line 50
    return-object p1

    .line 51
    :cond_32
    add-int/2addr v1, v4

    .line 52
    sub-int/2addr v1, v3

    .line 53
    div-int/2addr v1, v4

    .line 54
    add-int/lit8 p1, v4, 0x1

    .line 55
    .line 56
    new-array p1, p1, [Lcom/kousei/framework/d4;

    .line 57
    .line 58
    iget-object p0, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 59
    .line 60
    check-cast p0, Lcom/kousei/framework/d4;

    .line 61
    .line 62
    const/4 v6, 0x0

    .line 63
    aput-object p0, p1, v6

    .line 64
    .line 65
    move p0, v3

    .line 66
    :goto_41
    if-ge p0, v4, :cond_50

    .line 67
    .line 68
    add-int/lit8 v7, p0, -0x1

    .line 69
    .line 70
    aget-object v7, p1, v7

    .line 71
    .line 72
    invoke-virtual {v7, v1}, Lcom/kousei/framework/d4;->n(I)Lcom/kousei/framework/d4;

    .line 73
    .line 74
    .line 75
    move-result-object v7

    .line 76
    aput-object v7, p1, p0

    .line 77
    .line 78
    add-int/lit8 p0, p0, 0x1

    .line 79
    .line 80
    goto :goto_41

    .line 81
    :cond_50
    aget-object p0, p1, v6

    .line 82
    .line 83
    aget-object v1, p1, v3

    .line 84
    .line 85
    iget v7, p0, Lcom/kousei/framework/d4;->f:I

    .line 86
    .line 87
    packed-switch v7, :pswitch_data_bc

    .line 88
    .line 89
    .line 90
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 91
    .line 92
    .line 93
    move-result v7

    .line 94
    if-eqz v7, :cond_60

    .line 95
    .line 96
    goto :goto_78

    .line 97
    :cond_60
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->j()Lcom/kousei/framework/d4;

    .line 98
    .line 99
    .line 100
    move-result-object v1

    .line 101
    invoke-virtual {p0, v1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 102
    .line 103
    .line 104
    move-result-object p0

    .line 105
    goto :goto_78

    .line 106
    :pswitch_69
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 107
    .line 108
    .line 109
    move-result v7

    .line 110
    if-eqz v7, :cond_70

    .line 111
    .line 112
    goto :goto_78

    .line 113
    :cond_70
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->j()Lcom/kousei/framework/d4;

    .line 114
    .line 115
    .line 116
    move-result-object v1

    .line 117
    invoke-virtual {p0, v1}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 118
    .line 119
    .line 120
    move-result-object p0

    .line 121
    :goto_78
    aput-object p0, p1, v4

    .line 122
    .line 123
    invoke-virtual {v0, p1}, Lcom/kousei/framework/v3;->j([Lcom/kousei/framework/d4;)V

    .line 124
    .line 125
    .line 126
    new-array p0, v5, [Lcom/kousei/framework/d4;

    .line 127
    .line 128
    aget-object v1, p1, v6

    .line 129
    .line 130
    aput-object v1, p0, v6

    .line 131
    .line 132
    add-int/lit8 v1, v4, -0x1

    .line 133
    .line 134
    :goto_85
    if-ltz v1, :cond_9f

    .line 135
    .line 136
    aget-object v6, p1, v1

    .line 137
    .line 138
    shl-int v7, v3, v1

    .line 139
    .line 140
    move v8, v7

    .line 141
    :goto_8c
    if-ge v8, v5, :cond_9c

    .line 142
    .line 143
    sub-int v9, v8, v7

    .line 144
    .line 145
    aget-object v9, p0, v9

    .line 146
    .line 147
    invoke-virtual {v9, v6}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 148
    .line 149
    .line 150
    move-result-object v9

    .line 151
    aput-object v9, p0, v8

    .line 152
    .line 153
    shl-int/lit8 v9, v7, 0x1

    .line 154
    .line 155
    add-int/2addr v8, v9

    .line 156
    goto :goto_8c

    .line 157
    :cond_9c
    add-int/lit8 v1, v1, -0x1

    .line 158
    .line 159
    goto :goto_85

    .line 160
    :cond_9f
    invoke-virtual {v0, p0}, Lcom/kousei/framework/v3;->j([Lcom/kousei/framework/d4;)V

    .line 161
    .line 162
    .line 163
    new-instance v1, Lcom/kousei/framework/n4;

    .line 164
    .line 165
    invoke-direct {v1}, Ljava/lang/Object;-><init>()V

    .line 166
    .line 167
    .line 168
    iput-object v2, v1, Lcom/kousei/framework/n4;->a:Lcom/kousei/framework/d4;

    .line 169
    .line 170
    iput-object v2, v1, Lcom/kousei/framework/n4;->b:Lcom/kousei/framework/h0;

    .line 171
    .line 172
    const/4 v2, -0x1

    .line 173
    iput v2, v1, Lcom/kousei/framework/n4;->c:I

    .line 174
    .line 175
    invoke-virtual {v0, p0, v5}, Lcom/kousei/framework/v3;->b([Lcom/kousei/framework/d4;I)Lcom/kousei/framework/h0;

    .line 176
    .line 177
    .line 178
    move-result-object p0

    .line 179
    iput-object p0, v1, Lcom/kousei/framework/n4;->b:Lcom/kousei/framework/h0;

    .line 180
    .line 181
    aget-object p0, p1, v4

    .line 182
    .line 183
    iput-object p0, v1, Lcom/kousei/framework/n4;->a:Lcom/kousei/framework/d4;

    .line 184
    .line 185
    iput v4, v1, Lcom/kousei/framework/n4;->c:I

    .line 186
    .line 187
    return-object v1

    .line 188
    nop

    .line 189
    :pswitch_data_bc
    .packed-switch 0x0
        :pswitch_69
    .end packed-switch
.end method

.method public b(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V
    .registers 5

    .line 1
    :try_start_0
    iget-object p0, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 2
    .line 3
    check-cast p0, Lcom/kousei/framework/k4;

    .line 4
    .line 5
    invoke-virtual {p0, p1, p2}, Lcom/kousei/framework/k4;->a(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V
    :try_end_7
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_7} :catch_8

    .line 6
    .line 7
    .line 8
    return-void

    .line 9
    :catch_8
    move-exception p0

    .line 10
    new-instance p1, Lcom/kousei/framework/m;

    .line 11
    .line 12
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 13
    .line 14
    .line 15
    move-result-object p2

    .line 16
    new-instance v0, Ljava/lang/StringBuilder;

    .line 17
    .line 18
    const-string v1, "cannot encode extension: "

    .line 19
    .line 20
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 21
    .line 22
    .line 23
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 24
    .line 25
    .line 26
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 27
    .line 28
    .line 29
    move-result-object p2

    .line 30
    const/4 v0, 0x1

    .line 31
    invoke-direct {p1, p2, p0, v0}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 32
    .line 33
    .line 34
    throw p1
.end method

.method public c(Lcom/kousei/framework/k1;)Lcom/kousei/framework/xa;
    .registers 21

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    move-object/from16 v1, p1

    .line 4
    .line 5
    iget v2, v1, Lcom/kousei/framework/k1;->e:I

    .line 6
    .line 7
    packed-switch v2, :pswitch_data_1bc

    .line 8
    .line 9
    .line 10
    iget-object v2, v1, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 11
    .line 12
    check-cast v2, Lcom/kousei/framework/j0;

    .line 13
    .line 14
    goto :goto_17

    .line 15
    :pswitch_e
    iget-object v2, v1, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 16
    .line 17
    check-cast v2, Lcom/kousei/framework/j0;

    .line 18
    .line 19
    goto :goto_17

    .line 20
    :pswitch_13
    iget-object v2, v1, Lcom/kousei/framework/k1;->f:Ljava/lang/Object;

    .line 21
    .line 22
    check-cast v2, Lcom/kousei/framework/j0;

    .line 23
    .line 24
    :goto_17
    iget-object v3, v0, Lcom/kousei/framework/o4;->a:Ljava/lang/Object;

    .line 25
    .line 26
    check-cast v3, Lcom/kousei/framework/sa;

    .line 27
    .line 28
    iput-object v2, v3, Lcom/kousei/framework/sa;->b:Lcom/kousei/framework/j0;

    .line 29
    .line 30
    iget-object v0, v0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 31
    .line 32
    check-cast v0, Lcom/kousei/framework/k4;

    .line 33
    .line 34
    iget-object v4, v0, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 35
    .line 36
    invoke-virtual {v4}, Ljava/util/Vector;->isEmpty()Z

    .line 37
    .line 38
    .line 39
    move-result v4

    .line 40
    if-nez v4, :cond_167

    .line 41
    .line 42
    sget-object v4, Lcom/kousei/framework/i4;->j:Lcom/kousei/framework/u;

    .line 43
    .line 44
    iget-object v5, v0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 45
    .line 46
    invoke-virtual {v5, v4}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 47
    .line 48
    .line 49
    move-result-object v4

    .line 50
    check-cast v4, Lcom/kousei/framework/i4;

    .line 51
    .line 52
    if-eqz v4, :cond_14e

    .line 53
    .line 54
    :try_start_35
    iget-object v6, v4, Lcom/kousei/framework/i4;->c:Lcom/kousei/framework/v;

    .line 55
    .line 56
    iget-object v6, v6, Lcom/kousei/framework/v;->a:[B

    .line 57
    .line 58
    invoke-static {v6}, Lcom/kousei/framework/z;->o([B)Lcom/kousei/framework/z;

    .line 59
    .line 60
    .line 61
    move-result-object v6
    :try_end_3d
    .catch Ljava/io/IOException; {:try_start_35 .. :try_end_3d} :catch_145

    .line 62
    if-eqz v6, :cond_49

    .line 63
    .line 64
    new-instance v7, Lcom/kousei/framework/k3;

    .line 65
    .line 66
    invoke-static {v6}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 67
    .line 68
    .line 69
    move-result-object v6

    .line 70
    invoke-direct {v7, v6}, Lcom/kousei/framework/k3;-><init>(Lcom/kousei/framework/c0;)V

    .line 71
    .line 72
    .line 73
    goto :goto_4a

    .line 74
    :cond_49
    const/4 v7, 0x0

    .line 75
    :goto_4a
    invoke-virtual {v3}, Lcom/kousei/framework/sa;->a()Lcom/kousei/framework/la;

    .line 76
    .line 77
    .line 78
    move-result-object v6

    .line 79
    invoke-virtual {v0}, Lcom/kousei/framework/k4;->c()Lcom/kousei/framework/j4;

    .line 80
    .line 81
    .line 82
    move-result-object v8

    .line 83
    iget-object v10, v7, Lcom/kousei/framework/k3;->a:Lcom/kousei/framework/p;

    .line 84
    .line 85
    iget-object v9, v7, Lcom/kousei/framework/k3;->b:Lcom/kousei/framework/j0;

    .line 86
    .line 87
    if-eqz v9, :cond_62

    .line 88
    .line 89
    iget-object v11, v6, Lcom/kousei/framework/la;->d:Lcom/kousei/framework/j0;

    .line 90
    .line 91
    invoke-virtual {v9, v11}, Lcom/kousei/framework/r;->equals(Ljava/lang/Object;)Z

    .line 92
    .line 93
    .line 94
    move-result v11

    .line 95
    if-eqz v11, :cond_62

    .line 96
    .line 97
    const/4 v11, 0x0

    .line 98
    goto :goto_63

    .line 99
    :cond_62
    move-object v11, v9

    .line 100
    :goto_63
    iget-object v9, v7, Lcom/kousei/framework/k3;->c:Lcom/kousei/framework/va;

    .line 101
    .line 102
    if-eqz v9, :cond_71

    .line 103
    .line 104
    iget-object v12, v6, Lcom/kousei/framework/la;->e:Lcom/kousei/framework/va;

    .line 105
    .line 106
    invoke-virtual {v9, v12}, Lcom/kousei/framework/va;->equals(Ljava/lang/Object;)Z

    .line 107
    .line 108
    .line 109
    move-result v12

    .line 110
    if-eqz v12, :cond_71

    .line 111
    .line 112
    const/4 v12, 0x0

    .line 113
    goto :goto_72

    .line 114
    :cond_71
    move-object v12, v9

    .line 115
    :goto_72
    iget-object v9, v7, Lcom/kousei/framework/k3;->d:Lcom/kousei/framework/ta;

    .line 116
    .line 117
    if-eqz v9, :cond_80

    .line 118
    .line 119
    iget-object v13, v6, Lcom/kousei/framework/la;->f:Lcom/kousei/framework/ta;

    .line 120
    .line 121
    invoke-virtual {v9, v13}, Lcom/kousei/framework/r;->equals(Ljava/lang/Object;)Z

    .line 122
    .line 123
    .line 124
    move-result v13

    .line 125
    if-eqz v13, :cond_80

    .line 126
    .line 127
    const/4 v13, 0x0

    .line 128
    goto :goto_81

    .line 129
    :cond_80
    move-object v13, v9

    .line 130
    :goto_81
    iget-object v9, v7, Lcom/kousei/framework/k3;->e:Lcom/kousei/framework/va;

    .line 131
    .line 132
    if-eqz v9, :cond_8f

    .line 133
    .line 134
    iget-object v6, v6, Lcom/kousei/framework/la;->g:Lcom/kousei/framework/va;

    .line 135
    .line 136
    invoke-virtual {v9, v6}, Lcom/kousei/framework/va;->equals(Ljava/lang/Object;)Z

    .line 137
    .line 138
    .line 139
    move-result v6

    .line 140
    if-eqz v6, :cond_8f

    .line 141
    .line 142
    const/4 v14, 0x0

    .line 143
    goto :goto_90

    .line 144
    :cond_8f
    move-object v14, v9

    .line 145
    :goto_90
    iget-object v15, v7, Lcom/kousei/framework/k3;->f:Lcom/kousei/framework/ka;

    .line 146
    .line 147
    iget-object v6, v7, Lcom/kousei/framework/k3;->g:Lcom/kousei/framework/j4;

    .line 148
    .line 149
    if-eqz v6, :cond_f9

    .line 150
    .line 151
    new-instance v9, Lcom/kousei/framework/k4;

    .line 152
    .line 153
    invoke-direct {v9}, Lcom/kousei/framework/k4;-><init>()V

    .line 154
    .line 155
    .line 156
    const/16 p0, 0x0

    .line 157
    .line 158
    iget-object v5, v8, Lcom/kousei/framework/j4;->b:Ljava/util/Vector;

    .line 159
    .line 160
    invoke-virtual {v5}, Ljava/util/Vector;->elements()Ljava/util/Enumeration;

    .line 161
    .line 162
    .line 163
    move-result-object v5

    .line 164
    :goto_a3
    invoke-interface {v5}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 165
    .line 166
    .line 167
    move-result v16

    .line 168
    if-eqz v16, :cond_e6

    .line 169
    .line 170
    invoke-interface {v5}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 171
    .line 172
    .line 173
    move-result-object v16

    .line 174
    move-object/from16 v17, v5

    .line 175
    .line 176
    move-object/from16 v5, v16

    .line 177
    .line 178
    check-cast v5, Lcom/kousei/framework/u;

    .line 179
    .line 180
    move-object/from16 v16, v10

    .line 181
    .line 182
    sget-object v10, Lcom/kousei/framework/i4;->j:Lcom/kousei/framework/u;

    .line 183
    .line 184
    invoke-virtual {v10, v5}, Lcom/kousei/framework/z;->n(Lcom/kousei/framework/z;)Z

    .line 185
    .line 186
    .line 187
    move-result v10

    .line 188
    if-eqz v10, :cond_c2

    .line 189
    .line 190
    move-object/from16 v10, v16

    .line 191
    .line 192
    move-object/from16 v5, v17

    .line 193
    .line 194
    goto :goto_a3

    .line 195
    :cond_c2
    iget-object v10, v6, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 196
    .line 197
    invoke-virtual {v10, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 198
    .line 199
    .line 200
    move-result-object v10

    .line 201
    check-cast v10, Lcom/kousei/framework/i4;

    .line 202
    .line 203
    move-object/from16 v18, v6

    .line 204
    .line 205
    if-eqz v10, :cond_df

    .line 206
    .line 207
    iget-object v6, v8, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 208
    .line 209
    invoke-virtual {v6, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 210
    .line 211
    .line 212
    move-result-object v5

    .line 213
    check-cast v5, Lcom/kousei/framework/i4;

    .line 214
    .line 215
    invoke-virtual {v10, v5}, Lcom/kousei/framework/i4;->equals(Ljava/lang/Object;)Z

    .line 216
    .line 217
    .line 218
    move-result v5

    .line 219
    if-nez v5, :cond_df

    .line 220
    .line 221
    invoke-virtual {v9, v10}, Lcom/kousei/framework/k4;->b(Lcom/kousei/framework/i4;)V

    .line 222
    .line 223
    .line 224
    :cond_df
    move-object/from16 v10, v16

    .line 225
    .line 226
    move-object/from16 v5, v17

    .line 227
    .line 228
    move-object/from16 v6, v18

    .line 229
    .line 230
    goto :goto_a3

    .line 231
    :cond_e6
    move-object/from16 v16, v10

    .line 232
    .line 233
    iget-object v5, v9, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 234
    .line 235
    invoke-virtual {v5}, Ljava/util/Vector;->isEmpty()Z

    .line 236
    .line 237
    .line 238
    move-result v5

    .line 239
    if-eqz v5, :cond_f3

    .line 240
    .line 241
    move-object/from16 v5, p0

    .line 242
    .line 243
    goto :goto_f7

    .line 244
    :cond_f3
    invoke-virtual {v9}, Lcom/kousei/framework/k4;->c()Lcom/kousei/framework/j4;

    .line 245
    .line 246
    .line 247
    move-result-object v5

    .line 248
    :goto_f7
    move-object v6, v5

    .line 249
    goto :goto_fd

    .line 250
    :cond_f9
    move-object/from16 v18, v6

    .line 251
    .line 252
    move-object/from16 v16, v10

    .line 253
    .line 254
    :goto_fd
    iget-object v5, v7, Lcom/kousei/framework/k3;->h:Lcom/kousei/framework/f;

    .line 255
    .line 256
    new-instance v9, Lcom/kousei/framework/k3;

    .line 257
    .line 258
    move-object/from16 v17, v5

    .line 259
    .line 260
    move-object/from16 v10, v16

    .line 261
    .line 262
    move-object/from16 v16, v6

    .line 263
    .line 264
    invoke-direct/range {v9 .. v17}, Lcom/kousei/framework/k3;-><init>(Lcom/kousei/framework/p;Lcom/kousei/framework/j0;Lcom/kousei/framework/va;Lcom/kousei/framework/ta;Lcom/kousei/framework/va;Lcom/kousei/framework/ka;Lcom/kousei/framework/j4;Lcom/kousei/framework/f;)V

    .line 265
    .line 266
    .line 267
    :try_start_10a
    sget-object v5, Lcom/kousei/framework/i4;->j:Lcom/kousei/framework/u;

    .line 268
    .line 269
    iget-boolean v4, v4, Lcom/kousei/framework/i4;->b:Z

    .line 270
    .line 271
    new-instance v6, Lcom/kousei/framework/i4;

    .line 272
    .line 273
    new-instance v7, Lcom/kousei/framework/n2;

    .line 274
    .line 275
    invoke-direct {v7, v9}, Lcom/kousei/framework/n2;-><init>(Lcom/kousei/framework/r;)V

    .line 276
    .line 277
    .line 278
    invoke-direct {v6, v5, v4, v7}, Lcom/kousei/framework/i4;-><init>(Lcom/kousei/framework/u;ZLcom/kousei/framework/n2;)V

    .line 279
    .line 280
    .line 281
    iget-object v4, v0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 282
    .line 283
    invoke-virtual {v4, v5}, Ljava/util/Hashtable;->containsKey(Ljava/lang/Object;)Z

    .line 284
    .line 285
    .line 286
    move-result v7

    .line 287
    if-eqz v7, :cond_124

    .line 288
    .line 289
    invoke-virtual {v4, v5, v6}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 290
    .line 291
    .line 292
    goto :goto_14e

    .line 293
    :cond_124
    const-string v4, "extension "

    .line 294
    .line 295
    const-string v6, " not present"

    .line 296
    .line 297
    invoke-static {v4, v5, v6}, Lcom/kousei/framework/e;->g(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)V
    :try_end_12b
    .catch Ljava/io/IOException; {:try_start_10a .. :try_end_12b} :catch_12c

    .line 298
    .line 299
    .line 300
    goto :goto_14e

    .line 301
    :catch_12c
    move-exception v0

    .line 302
    new-instance v1, Ljava/lang/IllegalStateException;

    .line 303
    .line 304
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 305
    .line 306
    .line 307
    move-result-object v0

    .line 308
    new-instance v2, Ljava/lang/StringBuilder;

    .line 309
    .line 310
    const-string v3, "unable to replace deltaCertificateDescriptor: "

    .line 311
    .line 312
    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 313
    .line 314
    .line 315
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 316
    .line 317
    .line 318
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 319
    .line 320
    .line 321
    move-result-object v0

    .line 322
    invoke-direct {v1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 323
    .line 324
    .line 325
    throw v1

    .line 326
    :catch_145
    move-exception v0

    .line 327
    const/16 p0, 0x0

    .line 328
    .line 329
    const-string v1, "can\'t convert extension: "

    .line 330
    .line 331
    invoke-static {v0, v1}, Lcom/kousei/framework/e;->k(Ljava/lang/Object;Ljava/lang/String;)V

    .line 332
    .line 333
    .line 334
    return-object p0

    .line 335
    :cond_14e
    :goto_14e
    invoke-virtual {v0}, Lcom/kousei/framework/k4;->c()Lcom/kousei/framework/j4;

    .line 336
    .line 337
    .line 338
    move-result-object v0

    .line 339
    iput-object v0, v3, Lcom/kousei/framework/sa;->h:Lcom/kousei/framework/j4;

    .line 340
    .line 341
    sget-object v4, Lcom/kousei/framework/i4;->f:Lcom/kousei/framework/u;

    .line 342
    .line 343
    iget-object v0, v0, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 344
    .line 345
    invoke-virtual {v0, v4}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 346
    .line 347
    .line 348
    move-result-object v0

    .line 349
    check-cast v0, Lcom/kousei/framework/i4;

    .line 350
    .line 351
    if-eqz v0, :cond_167

    .line 352
    .line 353
    iget-boolean v0, v0, Lcom/kousei/framework/i4;->b:Z

    .line 354
    .line 355
    if-eqz v0, :cond_167

    .line 356
    .line 357
    const/4 v0, 0x1

    .line 358
    iput-boolean v0, v3, Lcom/kousei/framework/sa;->i:Z

    .line 359
    .line 360
    :cond_167
    :try_start_167
    invoke-virtual {v3}, Lcom/kousei/framework/sa;->a()Lcom/kousei/framework/la;

    .line 361
    .line 362
    .line 363
    move-result-object v0

    .line 364
    iget v3, v1, Lcom/kousei/framework/k1;->e:I

    .line 365
    .line 366
    packed-switch v3, :pswitch_data_1c4

    .line 367
    .line 368
    .line 369
    iget-object v3, v1, Lcom/kousei/framework/k1;->h:Ljava/lang/Object;

    .line 370
    .line 371
    check-cast v3, Lcom/kousei/framework/ha;

    .line 372
    .line 373
    goto :goto_17e

    .line 374
    :pswitch_175
    iget-object v3, v1, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 375
    .line 376
    check-cast v3, Ljava/io/ByteArrayOutputStream;

    .line 377
    .line 378
    goto :goto_17e

    .line 379
    :pswitch_17a
    iget-object v3, v1, Lcom/kousei/framework/k1;->g:Ljava/lang/Object;

    .line 380
    .line 381
    check-cast v3, Ljava/io/ByteArrayOutputStream;

    .line 382
    .line 383
    :goto_17e
    invoke-virtual {v0}, Lcom/kousei/framework/la;->b()Lcom/kousei/framework/z;

    .line 384
    .line 385
    .line 386
    move-result-object v4

    .line 387
    invoke-virtual {v4, v3}, Lcom/kousei/framework/z;->l(Ljava/io/OutputStream;)V

    .line 388
    .line 389
    .line 390
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V

    .line 391
    .line 392
    .line 393
    invoke-virtual {v1}, Lcom/kousei/framework/k1;->b()[B

    .line 394
    .line 395
    .line 396
    move-result-object v1

    .line 397
    new-instance v3, Lcom/kousei/framework/xa;

    .line 398
    .line 399
    new-instance v4, Lcom/kousei/framework/k;

    .line 400
    .line 401
    const/4 v5, 0x3

    .line 402
    invoke-direct {v4, v5}, Lcom/kousei/framework/k;-><init>(I)V

    .line 403
    .line 404
    .line 405
    invoke-virtual {v4, v0}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 406
    .line 407
    .line 408
    invoke-virtual {v4, v2}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 409
    .line 410
    .line 411
    new-instance v0, Lcom/kousei/framework/f2;

    .line 412
    .line 413
    const/4 v2, 0x0

    .line 414
    invoke-direct {v0, v2, v1}, Lcom/kousei/framework/f2;-><init>(I[B)V

    .line 415
    .line 416
    .line 417
    invoke-virtual {v4, v0}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 418
    .line 419
    .line 420
    new-instance v0, Lcom/kousei/framework/q2;

    .line 421
    .line 422
    invoke-direct {v0, v4, v2}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/k;I)V

    .line 423
    .line 424
    .line 425
    const/4 v1, -0x1

    .line 426
    iput v1, v0, Lcom/kousei/framework/q2;->d:I

    .line 427
    .line 428
    invoke-static {v0}, Lcom/kousei/framework/h1;->i(Lcom/kousei/framework/z;)Lcom/kousei/framework/h1;

    .line 429
    .line 430
    .line 431
    move-result-object v0

    .line 432
    invoke-direct {v3, v0}, Lcom/kousei/framework/xa;-><init>(Lcom/kousei/framework/h1;)V
    :try_end_1b2
    .catch Ljava/io/IOException; {:try_start_167 .. :try_end_1b2} :catch_1b3

    .line 433
    .line 434
    .line 435
    return-object v3

    .line 436
    :catch_1b3
    move-exception v0

    .line 437
    new-instance v1, Ljava/lang/IllegalArgumentException;

    .line 438
    .line 439
    const-string v2, "cannot produce certificate signature"

    .line 440
    .line 441
    invoke-direct {v1, v2, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 442
    .line 443
    .line 444
    throw v1

    .line 445
    :pswitch_data_1bc
    .packed-switch 0x0
        :pswitch_13
        :pswitch_e
    .end packed-switch

    .line 446
    .line 447
    .line 448
    .line 449
    .line 450
    .line 451
    .line 452
    .line 453
    :pswitch_data_1c4
    .packed-switch 0x0
        :pswitch_17a
        :pswitch_175
    .end packed-switch
.end method

.method public d(IILjava/lang/String;)[B
    .registers 8

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/o4;->b:Ljava/lang/Object;

    .line 2
    .line 3
    check-cast p0, [B

    .line 4
    .line 5
    if-eqz p3, :cond_50

    .line 6
    .line 7
    if-ltz p1, :cond_48

    .line 8
    .line 9
    if-ltz p2, :cond_48

    .line 10
    .line 11
    invoke-virtual {p3}, Ljava/lang/String;->length()I

    .line 12
    .line 13
    .line 14
    move-result v0

    .line 15
    sub-int/2addr v0, p2

    .line 16
    if-gt p1, v0, :cond_48

    .line 17
    .line 18
    and-int/lit8 v0, p2, 0x1

    .line 19
    .line 20
    if-nez v0, :cond_40

    .line 21
    .line 22
    ushr-int/lit8 p2, p2, 0x1

    .line 23
    .line 24
    new-array v0, p2, [B

    .line 25
    .line 26
    const/4 v1, 0x0

    .line 27
    :goto_1a
    if-ge v1, p2, :cond_3f

    .line 28
    .line 29
    add-int/lit8 v2, p1, 0x1

    .line 30
    .line 31
    invoke-virtual {p3, p1}, Ljava/lang/String;->charAt(I)C

    .line 32
    .line 33
    .line 34
    move-result v3

    .line 35
    aget-byte v3, p0, v3

    .line 36
    .line 37
    add-int/lit8 p1, p1, 0x2

    .line 38
    .line 39
    invoke-virtual {p3, v2}, Ljava/lang/String;->charAt(I)C

    .line 40
    .line 41
    .line 42
    move-result v2

    .line 43
    aget-byte v2, p0, v2

    .line 44
    .line 45
    shl-int/lit8 v3, v3, 0x4

    .line 46
    .line 47
    or-int/2addr v2, v3

    .line 48
    if-ltz v2, :cond_37

    .line 49
    .line 50
    int-to-byte v2, v2

    .line 51
    aput-byte v2, v0, v1

    .line 52
    .line 53
    add-int/lit8 v1, v1, 0x1

    .line 54
    .line 55
    goto :goto_1a

    .line 56
    :cond_37
    new-instance p0, Ljava/io/IOException;

    .line 57
    .line 58
    const-string p1, "invalid characters encountered in Hex string"

    .line 59
    .line 60
    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 61
    .line 62
    .line 63
    throw p0

    .line 64
    :cond_3f
    return-object v0

    .line 65
    :cond_40
    new-instance p0, Ljava/io/IOException;

    .line 66
    .line 67
    const-string p1, "a hexadecimal encoding must have an even number of characters"

    .line 68
    .line 69
    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 70
    .line 71
    .line 72
    throw p0

    .line 73
    :cond_48
    new-instance p0, Ljava/lang/IndexOutOfBoundsException;

    .line 74
    .line 75
    const-string p1, "invalid offset and/or length specified"

    .line 76
    .line 77
    invoke-direct {p0, p1}, Ljava/lang/IndexOutOfBoundsException;-><init>(Ljava/lang/String;)V

    .line 78
    .line 79
    .line 80
    throw p0

    .line 81
    :cond_50
    const-string p0, "\'str\' cannot be null"

    .line 82
    .line 83
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 84
    .line 85
    .line 86
    const/4 p0, 0x0

    .line 87
    return-object p0
.end method
