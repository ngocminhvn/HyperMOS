.class public final Lcom/kousei/framework/y1;
.super Lcom/kousei/framework/h0;


# instance fields
.field public final synthetic S:I

.field public final synthetic T:I

.field public final synthetic U:Ljava/lang/Object;

.field public final synthetic V:Lcom/kousei/framework/v3;


# direct methods
.method public synthetic constructor <init>(Lcom/kousei/framework/v3;ILjava/lang/Object;I)V
    .registers 5

    .line 1
    iput p4, p0, Lcom/kousei/framework/y1;->S:I

    .line 2
    .line 3
    const/16 p4, 0x14

    .line 4
    .line 5
    invoke-direct {p0, p4}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 6
    .line 7
    .line 8
    iput p2, p0, Lcom/kousei/framework/y1;->T:I

    .line 9
    .line 10
    iput-object p3, p0, Lcom/kousei/framework/y1;->U:Ljava/lang/Object;

    .line 11
    .line 12
    iput-object p1, p0, Lcom/kousei/framework/y1;->V:Lcom/kousei/framework/v3;

    .line 13
    .line 14
    return-void
.end method


# virtual methods
.method public final J0(I)Lcom/kousei/framework/d4;
    .registers 20

    move-object/from16 v0, p0

    iget v1, v0, Lcom/kousei/framework/y1;->S:I

    const/4 v2, 0x2

    const/4 v3, 0x7

    const/4 v4, 0x3

    const/4 v5, 0x5

    const/4 v6, 0x6

    const/4 v7, 0x4

    const/16 v8, 0x8

    iget-object v9, v0, Lcom/kousei/framework/y1;->V:Lcom/kousei/framework/v3;

    iget-object v10, v0, Lcom/kousei/framework/y1;->U:Ljava/lang/Object;

    iget v0, v0, Lcom/kousei/framework/y1;->T:I

    const/4 v11, 0x0

    packed-switch v1, :pswitch_data_89a

    .line 1
    new-array v1, v3, [J

    new-array v2, v3, [J

    move v4, v11

    move v5, v4

    :goto_1c
    if-ge v4, v0, :cond_48

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_26
    if-ge v8, v3, :cond_43

    .line 2
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x7

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_26

    :cond_43
    add-int/lit8 v5, v5, 0xe

    add-int/lit8 v4, v4, 0x1

    goto :goto_1c

    .line 3
    :cond_48
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/ba;

    new-instance v14, Lcom/kousei/framework/z9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/z9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/z9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/z9;-><init>([J)V

    .line 4
    sget-object v16, Lcom/kousei/framework/ba;->h:[Lcom/kousei/framework/h0;

    .line 5
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x10

    .line 6
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 7
    :pswitch_5f
    new-array v1, v3, [J

    new-array v2, v3, [J

    move v4, v11

    move v5, v4

    :goto_65
    if-ge v4, v0, :cond_91

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_6f
    if-ge v8, v3, :cond_8c

    .line 8
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x7

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_6f

    :cond_8c
    add-int/lit8 v5, v5, 0xe

    add-int/lit8 v4, v4, 0x1

    goto :goto_65

    .line 9
    :cond_91
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/aa;

    new-instance v14, Lcom/kousei/framework/z9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/z9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/z9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/z9;-><init>([J)V

    .line 10
    sget-object v16, Lcom/kousei/framework/aa;->h:[Lcom/kousei/framework/h0;

    .line 11
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xf

    .line 12
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 13
    :pswitch_a8
    new-array v1, v5, [J

    new-array v2, v5, [J

    move v3, v11

    move v4, v3

    :goto_ae
    if-ge v3, v0, :cond_da

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_b8
    if-ge v8, v5, :cond_d5

    .line 14
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x5

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_b8

    :cond_d5
    add-int/lit8 v4, v4, 0xa

    add-int/lit8 v3, v3, 0x1

    goto :goto_ae

    .line 15
    :cond_da
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/y9;

    new-instance v14, Lcom/kousei/framework/w9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/w9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/w9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/w9;-><init>([J)V

    .line 16
    sget-object v16, Lcom/kousei/framework/y9;->h:[Lcom/kousei/framework/h0;

    .line 17
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xe

    .line 18
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 19
    :pswitch_f1
    new-array v1, v5, [J

    new-array v2, v5, [J

    move v3, v11

    move v4, v3

    :goto_f7
    if-ge v3, v0, :cond_123

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_101
    if-ge v8, v5, :cond_11e

    .line 20
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x5

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_101

    :cond_11e
    add-int/lit8 v4, v4, 0xa

    add-int/lit8 v3, v3, 0x1

    goto :goto_f7

    .line 21
    :cond_123
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/x9;

    new-instance v14, Lcom/kousei/framework/w9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/w9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/w9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/w9;-><init>([J)V

    .line 22
    sget-object v16, Lcom/kousei/framework/x9;->h:[Lcom/kousei/framework/h0;

    .line 23
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xd

    .line 24
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 25
    :pswitch_13a
    new-array v1, v7, [J

    new-array v2, v7, [J

    move v3, v11

    move v4, v3

    :goto_140
    if-ge v3, v0, :cond_16c

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    int-to-long v5, v5

    move v8, v11

    :goto_14a
    if-ge v8, v7, :cond_167

    .line 26
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v5

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x4

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v5

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_14a

    :cond_167
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_140

    .line 27
    :cond_16c
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/v9;

    new-instance v14, Lcom/kousei/framework/u9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/u9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/u9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/u9;-><init>([J)V

    .line 28
    sget-object v16, Lcom/kousei/framework/v9;->h:[Lcom/kousei/framework/h0;

    .line 29
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xc

    .line 30
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 31
    :pswitch_183
    new-array v1, v7, [J

    new-array v2, v7, [J

    move v3, v11

    move v4, v3

    :goto_189
    if-ge v3, v0, :cond_1b5

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    int-to-long v5, v5

    move v8, v11

    :goto_193
    if-ge v8, v7, :cond_1b0

    .line 32
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v5

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x4

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v5

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_193

    :cond_1b0
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_189

    .line 33
    :cond_1b5
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/t9;

    new-instance v14, Lcom/kousei/framework/r9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/r9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/r9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 34
    sget-object v16, Lcom/kousei/framework/t9;->h:[Lcom/kousei/framework/h0;

    .line 35
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xb

    .line 36
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 37
    :pswitch_1cc
    new-array v1, v7, [J

    new-array v2, v7, [J

    move v3, v11

    move v4, v3

    :goto_1d2
    if-ge v3, v0, :cond_1fe

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    int-to-long v5, v5

    move v8, v11

    :goto_1dc
    if-ge v8, v7, :cond_1f9

    .line 38
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v5

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x4

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v5

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_1dc

    :cond_1f9
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_1d2

    .line 39
    :cond_1fe
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/s9;

    new-instance v14, Lcom/kousei/framework/r9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/r9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/r9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/r9;-><init>([J)V

    .line 40
    sget-object v16, Lcom/kousei/framework/s9;->h:[Lcom/kousei/framework/h0;

    .line 41
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0xa

    .line 42
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 43
    :pswitch_215
    new-array v1, v7, [J

    new-array v2, v7, [J

    move v3, v11

    move v4, v3

    :goto_21b
    if-ge v3, v0, :cond_247

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    int-to-long v5, v5

    move v8, v11

    :goto_225
    if-ge v8, v7, :cond_242

    .line 44
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v5

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x4

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v5

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_225

    :cond_242
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_21b

    .line 45
    :cond_247
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/q9;

    new-instance v14, Lcom/kousei/framework/o9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/o9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/o9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/o9;-><init>([J)V

    .line 46
    sget-object v16, Lcom/kousei/framework/q9;->h:[Lcom/kousei/framework/h0;

    .line 47
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x9

    .line 48
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 49
    :pswitch_25e
    new-array v1, v7, [J

    new-array v2, v7, [J

    move v3, v11

    move v4, v3

    :goto_264
    if-ge v3, v0, :cond_290

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    int-to-long v5, v5

    move v8, v11

    :goto_26e
    if-ge v8, v7, :cond_28b

    .line 50
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v4, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v5

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v4, 0x4

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v5

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_26e

    :cond_28b
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_264

    .line 51
    :cond_290
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/p9;

    new-instance v14, Lcom/kousei/framework/o9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/o9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/o9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/o9;-><init>([J)V

    .line 52
    sget-object v16, Lcom/kousei/framework/p9;->h:[Lcom/kousei/framework/h0;

    .line 53
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x8

    .line 54
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 55
    :pswitch_2a7
    new-array v1, v4, [J

    new-array v2, v4, [J

    move v3, v11

    move v5, v3

    :goto_2ad
    if-ge v3, v0, :cond_2d9

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_2b7
    if-ge v8, v4, :cond_2d4

    .line 56
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x3

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_2b7

    :cond_2d4
    add-int/lit8 v5, v5, 0x6

    add-int/lit8 v3, v3, 0x1

    goto :goto_2ad

    .line 57
    :cond_2d9
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/n9;

    new-instance v14, Lcom/kousei/framework/k9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/k9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/k9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/k9;-><init>([J)V

    .line 58
    sget-object v16, Lcom/kousei/framework/n9;->h:[Lcom/kousei/framework/h0;

    .line 59
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x7

    .line 60
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 61
    :pswitch_2f0
    new-array v1, v4, [J

    new-array v2, v4, [J

    move v3, v11

    move v5, v3

    :goto_2f6
    if-ge v3, v0, :cond_322

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_300
    if-ge v8, v4, :cond_31d

    .line 62
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x3

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_300

    :cond_31d
    add-int/lit8 v5, v5, 0x6

    add-int/lit8 v3, v3, 0x1

    goto :goto_2f6

    .line 63
    :cond_322
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/m9;

    new-instance v14, Lcom/kousei/framework/k9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/k9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/k9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/k9;-><init>([J)V

    .line 64
    sget-object v16, Lcom/kousei/framework/m9;->h:[Lcom/kousei/framework/h0;

    .line 65
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x6

    .line 66
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 67
    :pswitch_339
    new-array v1, v4, [J

    new-array v2, v4, [J

    move v3, v11

    move v5, v3

    :goto_33f
    if-ge v3, v0, :cond_36b

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_349
    if-ge v8, v4, :cond_366

    .line 68
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x3

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_349

    :cond_366
    add-int/lit8 v5, v5, 0x6

    add-int/lit8 v3, v3, 0x1

    goto :goto_33f

    .line 69
    :cond_36b
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/l9;

    new-instance v14, Lcom/kousei/framework/k9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/k9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/k9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/k9;-><init>([J)V

    .line 70
    sget-object v16, Lcom/kousei/framework/l9;->h:[Lcom/kousei/framework/h0;

    .line 71
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x5

    .line 72
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 73
    :pswitch_382
    new-array v1, v4, [J

    new-array v2, v4, [J

    move v3, v11

    move v5, v3

    :goto_388
    if-ge v3, v0, :cond_3b4

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_392
    if-ge v8, v4, :cond_3af

    .line 74
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x3

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_392

    :cond_3af
    add-int/lit8 v5, v5, 0x6

    add-int/lit8 v3, v3, 0x1

    goto :goto_388

    .line 75
    :cond_3b4
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/j9;

    new-instance v14, Lcom/kousei/framework/h9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/h9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/h9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/h9;-><init>([J)V

    .line 76
    sget-object v16, Lcom/kousei/framework/j9;->h:[Lcom/kousei/framework/h0;

    .line 77
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x4

    .line 78
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 79
    :pswitch_3cb
    new-array v1, v4, [J

    new-array v2, v4, [J

    move v3, v11

    move v5, v3

    :goto_3d1
    if-ge v3, v0, :cond_3fd

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_3db
    if-ge v8, v4, :cond_3f8

    .line 80
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v2, v8

    add-int/lit8 v15, v5, 0x3

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v2, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_3db

    :cond_3f8
    add-int/lit8 v5, v5, 0x6

    add-int/lit8 v3, v3, 0x1

    goto :goto_3d1

    .line 81
    :cond_3fd
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/i9;

    new-instance v14, Lcom/kousei/framework/h9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/h9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/h9;

    invoke-direct {v15, v2}, Lcom/kousei/framework/h9;-><init>([J)V

    .line 82
    sget-object v16, Lcom/kousei/framework/i9;->h:[Lcom/kousei/framework/h0;

    .line 83
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x3

    .line 84
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 85
    :pswitch_414
    new-array v1, v2, [J

    new-array v3, v2, [J

    move v4, v11

    move v5, v4

    :goto_41a
    if-ge v4, v0, :cond_446

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_424
    if-ge v8, v2, :cond_441

    .line 86
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v3, v8

    add-int/lit8 v15, v5, 0x2

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v3, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_424

    :cond_441
    add-int/lit8 v5, v5, 0x4

    add-int/lit8 v4, v4, 0x1

    goto :goto_41a

    .line 87
    :cond_446
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/g9;

    new-instance v14, Lcom/kousei/framework/e9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/e9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/e9;

    invoke-direct {v15, v3}, Lcom/kousei/framework/e9;-><init>([J)V

    .line 88
    sget-object v16, Lcom/kousei/framework/g9;->h:[Lcom/kousei/framework/h0;

    .line 89
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x2

    .line 90
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 91
    :pswitch_45d
    new-array v1, v2, [J

    new-array v3, v2, [J

    move v4, v11

    move v5, v4

    :goto_463
    if-ge v4, v0, :cond_48f

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    int-to-long v6, v6

    move v8, v11

    :goto_46d
    if-ge v8, v2, :cond_48a

    .line 92
    aget-wide v12, v1, v8

    move-object v14, v10

    check-cast v14, [J

    add-int v15, v5, v8

    aget-wide v15, v14, v15

    and-long/2addr v15, v6

    xor-long/2addr v12, v15

    aput-wide v12, v1, v8

    aget-wide v12, v3, v8

    add-int/lit8 v15, v5, 0x2

    add-int/2addr v15, v8

    aget-wide v14, v14, v15

    and-long/2addr v14, v6

    xor-long/2addr v12, v14

    aput-wide v12, v3, v8

    add-int/lit8 v8, v8, 0x1

    goto :goto_46d

    :cond_48a
    add-int/lit8 v5, v5, 0x4

    add-int/lit8 v4, v4, 0x1

    goto :goto_463

    .line 93
    :cond_48f
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/f9;

    new-instance v14, Lcom/kousei/framework/e9;

    invoke-direct {v14, v1}, Lcom/kousei/framework/e9;-><init>([J)V

    new-instance v15, Lcom/kousei/framework/e9;

    invoke-direct {v15, v3}, Lcom/kousei/framework/e9;-><init>([J)V

    .line 94
    sget-object v16, Lcom/kousei/framework/f9;->h:[Lcom/kousei/framework/h0;

    .line 95
    new-instance v12, Lcom/kousei/framework/e4;

    const/16 v17, 0x1

    .line 96
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    :pswitch_4a6
    const/16 v1, 0x11

    .line 97
    new-array v2, v1, [I

    new-array v3, v1, [I

    move v4, v11

    move v5, v4

    :goto_4ae
    if-ge v4, v0, :cond_4d9

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_4b7
    if-ge v7, v1, :cond_4d4

    .line 98
    aget v8, v2, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v5, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v2, v7

    aget v8, v3, v7

    add-int/lit8 v13, v5, 0x11

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v3, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_4b7

    :cond_4d4
    add-int/lit8 v5, v5, 0x22

    add-int/lit8 v4, v4, 0x1

    goto :goto_4ae

    .line 99
    :cond_4d9
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/c9;

    new-instance v14, Lcom/kousei/framework/d9;

    invoke-direct {v14, v2}, Lcom/kousei/framework/d9;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/d9;

    invoke-direct {v15, v3}, Lcom/kousei/framework/d9;-><init>([I)V

    .line 100
    sget-object v16, Lcom/kousei/framework/c9;->i:[Lcom/kousei/framework/h0;

    .line 101
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0xe

    .line 102
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    :pswitch_4f0
    const/16 v1, 0xc

    .line 103
    new-array v2, v1, [I

    new-array v3, v1, [I

    move v4, v11

    move v5, v4

    :goto_4f8
    if-ge v4, v0, :cond_523

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_501
    if-ge v7, v1, :cond_51e

    .line 104
    aget v8, v2, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v5, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v2, v7

    aget v8, v3, v7

    add-int/lit8 v13, v5, 0xc

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v3, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_501

    :cond_51e
    add-int/lit8 v5, v5, 0x18

    add-int/lit8 v4, v4, 0x1

    goto :goto_4f8

    .line 105
    :cond_523
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/a9;

    new-instance v14, Lcom/kousei/framework/b9;

    invoke-direct {v14, v2}, Lcom/kousei/framework/b9;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/b9;

    invoke-direct {v15, v3}, Lcom/kousei/framework/b9;-><init>([I)V

    .line 106
    sget-object v16, Lcom/kousei/framework/a9;->i:[Lcom/kousei/framework/h0;

    .line 107
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0xd

    .line 108
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 109
    :pswitch_53a
    new-array v1, v8, [I

    new-array v2, v8, [I

    move v3, v11

    move v4, v3

    :goto_540
    if-ge v3, v0, :cond_56b

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v6, v11

    :goto_549
    if-ge v6, v8, :cond_566

    .line 110
    aget v7, v1, v6

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v6

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v7, v13

    aput v7, v1, v6

    aget v7, v2, v6

    add-int/lit8 v13, v4, 0x8

    add-int/2addr v13, v6

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v7, v12

    aput v7, v2, v6

    add-int/lit8 v6, v6, 0x1

    goto :goto_549

    :cond_566
    add-int/lit8 v4, v4, 0x10

    add-int/lit8 v3, v3, 0x1

    goto :goto_540

    .line 111
    :cond_56b
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/y8;

    new-instance v14, Lcom/kousei/framework/z8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/z8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/z8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/z8;-><init>([I)V

    .line 112
    sget-object v16, Lcom/kousei/framework/y8;->i:[Lcom/kousei/framework/h0;

    .line 113
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0xc

    .line 114
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 115
    :pswitch_582
    new-array v1, v8, [I

    new-array v2, v8, [I

    move v3, v11

    move v4, v3

    :goto_588
    if-ge v3, v0, :cond_5b3

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v6, v11

    :goto_591
    if-ge v6, v8, :cond_5ae

    .line 116
    aget v7, v1, v6

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v6

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v7, v13

    aput v7, v1, v6

    aget v7, v2, v6

    add-int/lit8 v13, v4, 0x8

    add-int/2addr v13, v6

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v7, v12

    aput v7, v2, v6

    add-int/lit8 v6, v6, 0x1

    goto :goto_591

    :cond_5ae
    add-int/lit8 v4, v4, 0x10

    add-int/lit8 v3, v3, 0x1

    goto :goto_588

    .line 117
    :cond_5b3
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/w8;

    new-instance v14, Lcom/kousei/framework/x8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/x8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/x8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 118
    sget-object v16, Lcom/kousei/framework/w8;->i:[Lcom/kousei/framework/h0;

    .line 119
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0xb

    .line 120
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 121
    :pswitch_5ca
    new-array v1, v3, [I

    new-array v2, v3, [I

    move v4, v11

    move v5, v4

    :goto_5d0
    if-ge v4, v0, :cond_5fb

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_5d9
    if-ge v7, v3, :cond_5f6

    .line 122
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v5, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v5, 0x7

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_5d9

    :cond_5f6
    add-int/lit8 v5, v5, 0xe

    add-int/lit8 v4, v4, 0x1

    goto :goto_5d0

    .line 123
    :cond_5fb
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/u8;

    new-instance v14, Lcom/kousei/framework/v8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/v8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/v8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/v8;-><init>([I)V

    .line 124
    sget-object v16, Lcom/kousei/framework/u8;->i:[Lcom/kousei/framework/h0;

    .line 125
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0xa

    .line 126
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 127
    :pswitch_612
    new-array v1, v3, [I

    new-array v2, v3, [I

    move v4, v11

    move v5, v4

    :goto_618
    if-ge v4, v0, :cond_643

    xor-int v6, v4, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_621
    if-ge v7, v3, :cond_63e

    .line 128
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v5, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v5, 0x7

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_621

    :cond_63e
    add-int/lit8 v5, v5, 0xe

    add-int/lit8 v4, v4, 0x1

    goto :goto_618

    .line 129
    :cond_643
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/s8;

    new-instance v14, Lcom/kousei/framework/t8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/t8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/t8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 130
    sget-object v16, Lcom/kousei/framework/s8;->i:[Lcom/kousei/framework/h0;

    .line 131
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x9

    .line 132
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 133
    :pswitch_65a
    new-array v1, v6, [I

    new-array v2, v6, [I

    move v3, v11

    move v4, v3

    :goto_660
    if-ge v3, v0, :cond_68b

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v7, v11

    :goto_669
    if-ge v7, v6, :cond_686

    .line 134
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v7

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v4, 0x6

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_669

    :cond_686
    add-int/lit8 v4, v4, 0xc

    add-int/lit8 v3, v3, 0x1

    goto :goto_660

    .line 135
    :cond_68b
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/q8;

    new-instance v14, Lcom/kousei/framework/r8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/r8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/r8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/r8;-><init>([I)V

    .line 136
    sget-object v16, Lcom/kousei/framework/q8;->i:[Lcom/kousei/framework/h0;

    .line 137
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x8

    .line 138
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 139
    :pswitch_6a2
    new-array v1, v6, [I

    new-array v2, v6, [I

    move v3, v11

    move v4, v3

    :goto_6a8
    if-ge v3, v0, :cond_6d3

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v7, v11

    :goto_6b1
    if-ge v7, v6, :cond_6ce

    .line 140
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v7

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v4, 0x6

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_6b1

    :cond_6ce
    add-int/lit8 v4, v4, 0xc

    add-int/lit8 v3, v3, 0x1

    goto :goto_6a8

    .line 141
    :cond_6d3
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/o8;

    new-instance v14, Lcom/kousei/framework/p8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/p8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/p8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/p8;-><init>([I)V

    .line 142
    sget-object v16, Lcom/kousei/framework/o8;->i:[Lcom/kousei/framework/h0;

    .line 143
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x7

    .line 144
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 145
    :pswitch_6ea
    new-array v1, v5, [I

    new-array v2, v5, [I

    move v3, v11

    move v4, v3

    :goto_6f0
    if-ge v3, v0, :cond_71b

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_6f9
    if-ge v7, v5, :cond_716

    .line 146
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v4, 0x5

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_6f9

    :cond_716
    add-int/lit8 v4, v4, 0xa

    add-int/lit8 v3, v3, 0x1

    goto :goto_6f0

    .line 147
    :cond_71b
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/m8;

    new-instance v14, Lcom/kousei/framework/n8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/n8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/n8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 148
    sget-object v16, Lcom/kousei/framework/m8;->i:[Lcom/kousei/framework/h0;

    .line 149
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x6

    .line 150
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 151
    :pswitch_732
    new-array v1, v5, [I

    new-array v2, v5, [I

    move v3, v11

    move v4, v3

    :goto_738
    if-ge v3, v0, :cond_763

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_741
    if-ge v7, v5, :cond_75e

    .line 152
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v4, 0x5

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_741

    :cond_75e
    add-int/lit8 v4, v4, 0xa

    add-int/lit8 v3, v3, 0x1

    goto :goto_738

    .line 153
    :cond_763
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/k8;

    new-instance v14, Lcom/kousei/framework/l8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/l8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/l8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/l8;-><init>([I)V

    .line 154
    sget-object v16, Lcom/kousei/framework/k8;->i:[Lcom/kousei/framework/h0;

    .line 155
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x5

    .line 156
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 157
    :pswitch_77a
    new-array v1, v5, [I

    new-array v2, v5, [I

    move v3, v11

    move v4, v3

    :goto_780
    if-ge v3, v0, :cond_7ab

    xor-int v6, v3, p1

    add-int/lit8 v6, v6, -0x1

    shr-int/lit8 v6, v6, 0x1f

    move v7, v11

    :goto_789
    if-ge v7, v5, :cond_7a6

    .line 158
    aget v8, v1, v7

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v7

    aget v13, v12, v13

    and-int/2addr v13, v6

    xor-int/2addr v8, v13

    aput v8, v1, v7

    aget v8, v2, v7

    add-int/lit8 v13, v4, 0x5

    add-int/2addr v13, v7

    aget v12, v12, v13

    and-int/2addr v12, v6

    xor-int/2addr v8, v12

    aput v8, v2, v7

    add-int/lit8 v7, v7, 0x1

    goto :goto_789

    :cond_7a6
    add-int/lit8 v4, v4, 0xa

    add-int/lit8 v3, v3, 0x1

    goto :goto_780

    .line 159
    :cond_7ab
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/j8;

    new-instance v14, Lcom/kousei/framework/n8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/n8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/n8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/n8;-><init>([I)V

    .line 160
    sget-object v16, Lcom/kousei/framework/j8;->i:[Lcom/kousei/framework/h0;

    .line 161
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x4

    .line 162
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 163
    :pswitch_7c2
    new-array v1, v7, [I

    new-array v2, v7, [I

    move v3, v11

    move v4, v3

    :goto_7c8
    if-ge v3, v0, :cond_7f3

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v6, v11

    :goto_7d1
    if-ge v6, v7, :cond_7ee

    .line 164
    aget v8, v1, v6

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v6

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v8, v13

    aput v8, v1, v6

    aget v8, v2, v6

    add-int/lit8 v13, v4, 0x4

    add-int/2addr v13, v6

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v8, v12

    aput v8, v2, v6

    add-int/lit8 v6, v6, 0x1

    goto :goto_7d1

    :cond_7ee
    add-int/lit8 v4, v4, 0x8

    add-int/lit8 v3, v3, 0x1

    goto :goto_7c8

    .line 165
    :cond_7f3
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/h8;

    new-instance v14, Lcom/kousei/framework/i8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/i8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/i8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/i8;-><init>([I)V

    .line 166
    sget-object v16, Lcom/kousei/framework/h8;->i:[Lcom/kousei/framework/h0;

    .line 167
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x3

    .line 168
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 169
    :pswitch_80a
    new-array v1, v8, [I

    new-array v2, v8, [I

    move v3, v11

    move v4, v3

    :goto_810
    if-ge v3, v0, :cond_83b

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v6, v11

    :goto_819
    if-ge v6, v8, :cond_836

    .line 170
    aget v7, v1, v6

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v6

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v7, v13

    aput v7, v1, v6

    aget v7, v2, v6

    add-int/lit8 v13, v4, 0x8

    add-int/2addr v13, v6

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v7, v12

    aput v7, v2, v6

    add-int/lit8 v6, v6, 0x1

    goto :goto_819

    :cond_836
    add-int/lit8 v4, v4, 0x10

    add-int/lit8 v3, v3, 0x1

    goto :goto_810

    .line 171
    :cond_83b
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/f8;

    new-instance v14, Lcom/kousei/framework/g8;

    invoke-direct {v14, v1}, Lcom/kousei/framework/g8;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/g8;

    invoke-direct {v15, v2}, Lcom/kousei/framework/g8;-><init>([I)V

    .line 172
    sget-object v16, Lcom/kousei/framework/f8;->i:[Lcom/kousei/framework/h0;

    .line 173
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x2

    .line 174
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    .line 175
    :pswitch_852
    new-array v1, v8, [I

    new-array v2, v8, [I

    move v3, v11

    move v4, v3

    :goto_858
    if-ge v3, v0, :cond_883

    xor-int v5, v3, p1

    add-int/lit8 v5, v5, -0x1

    shr-int/lit8 v5, v5, 0x1f

    move v6, v11

    :goto_861
    if-ge v6, v8, :cond_87e

    .line 176
    aget v7, v1, v6

    move-object v12, v10

    check-cast v12, [I

    add-int v13, v4, v6

    aget v13, v12, v13

    and-int/2addr v13, v5

    xor-int/2addr v7, v13

    aput v7, v1, v6

    aget v7, v2, v6

    add-int/lit8 v13, v4, 0x8

    add-int/2addr v13, v6

    aget v12, v12, v13

    and-int/2addr v12, v5

    xor-int/2addr v7, v12

    aput v7, v2, v6

    add-int/lit8 v6, v6, 0x1

    goto :goto_861

    :cond_87e
    add-int/lit8 v4, v4, 0x10

    add-int/lit8 v3, v3, 0x1

    goto :goto_858

    .line 177
    :cond_883
    move-object v13, v9

    check-cast v13, Lcom/kousei/framework/z1;

    new-instance v14, Lcom/kousei/framework/a2;

    invoke-direct {v14, v1}, Lcom/kousei/framework/a2;-><init>([I)V

    new-instance v15, Lcom/kousei/framework/a2;

    invoke-direct {v15, v2}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 178
    sget-object v16, Lcom/kousei/framework/z1;->k:[Lcom/kousei/framework/h0;

    .line 179
    new-instance v12, Lcom/kousei/framework/b2;

    const/16 v17, 0x0

    .line 180
    invoke-direct/range {v12 .. v17}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V

    return-object v12

    :pswitch_data_89a
    .packed-switch 0x0
        :pswitch_852
        :pswitch_80a
        :pswitch_7c2
        :pswitch_77a
        :pswitch_732
        :pswitch_6ea
        :pswitch_6a2
        :pswitch_65a
        :pswitch_612
        :pswitch_5ca
        :pswitch_582
        :pswitch_53a
        :pswitch_4f0
        :pswitch_4a6
        :pswitch_45d
        :pswitch_414
        :pswitch_3cb
        :pswitch_382
        :pswitch_339
        :pswitch_2f0
        :pswitch_2a7
        :pswitch_25e
        :pswitch_215
        :pswitch_1cc
        :pswitch_183
        :pswitch_13a
        :pswitch_f1
        :pswitch_a8
        :pswitch_5f
    .end packed-switch
.end method

.method public final b0()I
    .registers 2

    .line 1
    iget v0, p0, Lcom/kousei/framework/y1;->S:I

    .line 2
    .line 3
    packed-switch v0, :pswitch_data_60

    .line 4
    .line 5
    .line 6
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 7
    .line 8
    return p0

    .line 9
    :pswitch_8
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 10
    .line 11
    return p0

    .line 12
    :pswitch_b
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 13
    .line 14
    return p0

    .line 15
    :pswitch_e
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 16
    .line 17
    return p0

    .line 18
    :pswitch_11
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 19
    .line 20
    return p0

    .line 21
    :pswitch_14
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 22
    .line 23
    return p0

    .line 24
    :pswitch_17
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 25
    .line 26
    return p0

    .line 27
    :pswitch_1a
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 28
    .line 29
    return p0

    .line 30
    :pswitch_1d
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 31
    .line 32
    return p0

    .line 33
    :pswitch_20
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 34
    .line 35
    return p0

    .line 36
    :pswitch_23
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 37
    .line 38
    return p0

    .line 39
    :pswitch_26
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 40
    .line 41
    return p0

    .line 42
    :pswitch_29
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 43
    .line 44
    return p0

    .line 45
    :pswitch_2c
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 46
    .line 47
    return p0

    .line 48
    :pswitch_2f
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 49
    .line 50
    return p0

    .line 51
    :pswitch_32
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 52
    .line 53
    return p0

    .line 54
    :pswitch_35
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 55
    .line 56
    return p0

    .line 57
    :pswitch_38
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 58
    .line 59
    return p0

    .line 60
    :pswitch_3b
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 61
    .line 62
    return p0

    .line 63
    :pswitch_3e
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 64
    .line 65
    return p0

    .line 66
    :pswitch_41
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 67
    .line 68
    return p0

    .line 69
    :pswitch_44
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 70
    .line 71
    return p0

    .line 72
    :pswitch_47
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 73
    .line 74
    return p0

    .line 75
    :pswitch_4a
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 76
    .line 77
    return p0

    .line 78
    :pswitch_4d
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 79
    .line 80
    return p0

    .line 81
    :pswitch_50
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 82
    .line 83
    return p0

    .line 84
    :pswitch_53
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 85
    .line 86
    return p0

    .line 87
    :pswitch_56
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 88
    .line 89
    return p0

    .line 90
    :pswitch_59
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 91
    .line 92
    return p0

    .line 93
    :pswitch_5c
    iget p0, p0, Lcom/kousei/framework/y1;->T:I

    .line 94
    .line 95
    return p0

    .line 96
    nop

    .line 97
    :pswitch_data_60
    .packed-switch 0x0
        :pswitch_5c
        :pswitch_59
        :pswitch_56
        :pswitch_53
        :pswitch_50
        :pswitch_4d
        :pswitch_4a
        :pswitch_47
        :pswitch_44
        :pswitch_41
        :pswitch_3e
        :pswitch_3b
        :pswitch_38
        :pswitch_35
        :pswitch_32
        :pswitch_2f
        :pswitch_2c
        :pswitch_29
        :pswitch_26
        :pswitch_23
        :pswitch_20
        :pswitch_1d
        :pswitch_1a
        :pswitch_17
        :pswitch_14
        :pswitch_11
        :pswitch_e
        :pswitch_b
        :pswitch_8
    .end packed-switch
.end method
