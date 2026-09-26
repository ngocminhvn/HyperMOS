.class public final Lcom/kousei/framework/da;
.super Lcom/kousei/framework/h0;


# instance fields
.field public final synthetic S:I

.field public final synthetic T:I

.field public final synthetic U:[J

.field public final synthetic V:Lcom/kousei/framework/q3;


# direct methods
.method public synthetic constructor <init>(Lcom/kousei/framework/q3;I[JI)V
    .registers 5

    .line 1
    iput p4, p0, Lcom/kousei/framework/da;->S:I

    .line 2
    .line 3
    const/16 p4, 0x14

    .line 4
    .line 5
    invoke-direct {p0, p4}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 6
    .line 7
    .line 8
    iput p2, p0, Lcom/kousei/framework/da;->T:I

    .line 9
    .line 10
    iput-object p3, p0, Lcom/kousei/framework/da;->U:[J

    .line 11
    .line 12
    iput-object p1, p0, Lcom/kousei/framework/da;->V:Lcom/kousei/framework/q3;

    .line 13
    .line 14
    return-void
.end method


# virtual methods
.method public final J0(I)Lcom/kousei/framework/d4;
    .registers 18

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget v1, v0, Lcom/kousei/framework/da;->S:I

    .line 4
    .line 5
    iget-object v2, v0, Lcom/kousei/framework/da;->V:Lcom/kousei/framework/q3;

    .line 6
    .line 7
    iget-object v3, v0, Lcom/kousei/framework/da;->U:[J

    .line 8
    .line 9
    iget v0, v0, Lcom/kousei/framework/da;->T:I

    .line 10
    .line 11
    const/4 v4, 0x0

    .line 12
    const/16 v5, 0x9

    .line 13
    .line 14
    packed-switch v1, :pswitch_data_9c

    .line 15
    .line 16
    .line 17
    new-array v1, v5, [J

    .line 18
    .line 19
    new-array v6, v5, [J

    .line 20
    .line 21
    move v7, v4

    .line 22
    move v8, v7

    .line 23
    :goto_16
    if-ge v7, v0, :cond_3f

    .line 24
    .line 25
    xor-int v9, v7, p1

    .line 26
    .line 27
    add-int/lit8 v9, v9, -0x1

    .line 28
    .line 29
    shr-int/lit8 v9, v9, 0x1f

    .line 30
    .line 31
    int-to-long v9, v9

    .line 32
    move v11, v4

    .line 33
    :goto_20
    if-ge v11, v5, :cond_3a

    .line 34
    .line 35
    aget-wide v12, v1, v11

    .line 36
    .line 37
    add-int v14, v8, v11

    .line 38
    .line 39
    aget-wide v14, v3, v14

    .line 40
    .line 41
    and-long/2addr v14, v9

    .line 42
    xor-long/2addr v12, v14

    .line 43
    aput-wide v12, v1, v11

    .line 44
    .line 45
    aget-wide v12, v6, v11

    .line 46
    .line 47
    add-int/lit8 v14, v8, 0x9

    .line 48
    .line 49
    add-int/2addr v14, v11

    .line 50
    aget-wide v14, v3, v14

    .line 51
    .line 52
    and-long/2addr v14, v9

    .line 53
    xor-long/2addr v12, v14

    .line 54
    aput-wide v12, v6, v11

    .line 55
    .line 56
    add-int/lit8 v11, v11, 0x1

    .line 57
    .line 58
    goto :goto_20

    .line 59
    :cond_3a
    add-int/lit8 v8, v8, 0x12

    .line 60
    .line 61
    add-int/lit8 v7, v7, 0x1

    .line 62
    .line 63
    goto :goto_16

    .line 64
    :cond_3f
    move-object v10, v2

    .line 65
    check-cast v10, Lcom/kousei/framework/fa;

    .line 66
    .line 67
    new-instance v11, Lcom/kousei/framework/ca;

    .line 68
    .line 69
    invoke-direct {v11, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 70
    .line 71
    .line 72
    new-instance v12, Lcom/kousei/framework/ca;

    .line 73
    .line 74
    invoke-direct {v12, v6}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 75
    .line 76
    .line 77
    sget-object v13, Lcom/kousei/framework/fa;->h:[Lcom/kousei/framework/h0;

    .line 78
    .line 79
    new-instance v9, Lcom/kousei/framework/e4;

    .line 80
    .line 81
    const/16 v14, 0x12

    .line 82
    .line 83
    invoke-direct/range {v9 .. v14}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 84
    .line 85
    .line 86
    return-object v9

    .line 87
    :pswitch_56
    new-array v1, v5, [J

    .line 88
    .line 89
    new-array v6, v5, [J

    .line 90
    .line 91
    move v7, v4

    .line 92
    move v8, v7

    .line 93
    :goto_5c
    if-ge v7, v0, :cond_85

    .line 94
    .line 95
    xor-int v9, v7, p1

    .line 96
    .line 97
    add-int/lit8 v9, v9, -0x1

    .line 98
    .line 99
    shr-int/lit8 v9, v9, 0x1f

    .line 100
    .line 101
    int-to-long v9, v9

    .line 102
    move v11, v4

    .line 103
    :goto_66
    if-ge v11, v5, :cond_80

    .line 104
    .line 105
    aget-wide v12, v1, v11

    .line 106
    .line 107
    add-int v14, v8, v11

    .line 108
    .line 109
    aget-wide v14, v3, v14

    .line 110
    .line 111
    and-long/2addr v14, v9

    .line 112
    xor-long/2addr v12, v14

    .line 113
    aput-wide v12, v1, v11

    .line 114
    .line 115
    aget-wide v12, v6, v11

    .line 116
    .line 117
    add-int/lit8 v14, v8, 0x9

    .line 118
    .line 119
    add-int/2addr v14, v11

    .line 120
    aget-wide v14, v3, v14

    .line 121
    .line 122
    and-long/2addr v14, v9

    .line 123
    xor-long/2addr v12, v14

    .line 124
    aput-wide v12, v6, v11

    .line 125
    .line 126
    add-int/lit8 v11, v11, 0x1

    .line 127
    .line 128
    goto :goto_66

    .line 129
    :cond_80
    add-int/lit8 v8, v8, 0x12

    .line 130
    .line 131
    add-int/lit8 v7, v7, 0x1

    .line 132
    .line 133
    goto :goto_5c

    .line 134
    :cond_85
    move-object v10, v2

    .line 135
    check-cast v10, Lcom/kousei/framework/ea;

    .line 136
    .line 137
    new-instance v11, Lcom/kousei/framework/ca;

    .line 138
    .line 139
    invoke-direct {v11, v1}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 140
    .line 141
    .line 142
    new-instance v12, Lcom/kousei/framework/ca;

    .line 143
    .line 144
    invoke-direct {v12, v6}, Lcom/kousei/framework/ca;-><init>([J)V

    .line 145
    .line 146
    .line 147
    sget-object v13, Lcom/kousei/framework/ea;->h:[Lcom/kousei/framework/h0;

    .line 148
    .line 149
    new-instance v9, Lcom/kousei/framework/e4;

    .line 150
    .line 151
    const/16 v14, 0x11

    .line 152
    .line 153
    invoke-direct/range {v9 .. v14}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    .line 154
    .line 155
    .line 156
    return-object v9

    .line 157
    :pswitch_data_9c
    .packed-switch 0x0
        :pswitch_56
    .end packed-switch
.end method

.method public final b0()I
    .registers 2

    .line 1
    iget v0, p0, Lcom/kousei/framework/da;->S:I

    .line 2
    .line 3
    packed-switch v0, :pswitch_data_c

    .line 4
    .line 5
    .line 6
    iget p0, p0, Lcom/kousei/framework/da;->T:I

    .line 7
    .line 8
    return p0

    .line 9
    :pswitch_8
    iget p0, p0, Lcom/kousei/framework/da;->T:I

    .line 10
    .line 11
    return p0

    .line 12
    nop

    .line 13
    :pswitch_data_c
    .packed-switch 0x0
        :pswitch_8
    .end packed-switch
.end method
