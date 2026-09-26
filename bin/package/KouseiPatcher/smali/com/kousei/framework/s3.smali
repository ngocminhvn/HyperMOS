.class public final Lcom/kousei/framework/s3;
.super Lcom/kousei/framework/h0;


# instance fields
.field public final synthetic S:I

.field public final synthetic T:I

.field public final synthetic U:[J

.field public final synthetic V:[I

.field public final synthetic W:Lcom/kousei/framework/t3;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/t3;II[J[I)V
    .registers 7

    .line 1
    const/16 v0, 0x14

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    iput p2, p0, Lcom/kousei/framework/s3;->S:I

    .line 7
    .line 8
    iput p3, p0, Lcom/kousei/framework/s3;->T:I

    .line 9
    .line 10
    iput-object p4, p0, Lcom/kousei/framework/s3;->U:[J

    .line 11
    .line 12
    iput-object p5, p0, Lcom/kousei/framework/s3;->V:[I

    .line 13
    .line 14
    iput-object p1, p0, Lcom/kousei/framework/s3;->W:Lcom/kousei/framework/t3;

    .line 15
    .line 16
    return-void
.end method


# virtual methods
.method public final J0(I)Lcom/kousei/framework/d4;
    .registers 18

    .line 1
    move-object/from16 v0, p0

    .line 2
    .line 3
    iget v1, v0, Lcom/kousei/framework/s3;->T:I

    .line 4
    .line 5
    new-array v2, v1, [J

    .line 6
    .line 7
    new-array v3, v1, [J

    .line 8
    .line 9
    const/4 v4, 0x0

    .line 10
    move v5, v4

    .line 11
    move v6, v5

    .line 12
    :goto_b
    iget v7, v0, Lcom/kousei/framework/s3;->S:I

    .line 13
    .line 14
    if-ge v5, v7, :cond_39

    .line 15
    .line 16
    xor-int v7, v5, p1

    .line 17
    .line 18
    add-int/lit8 v7, v7, -0x1

    .line 19
    .line 20
    shr-int/lit8 v7, v7, 0x1f

    .line 21
    .line 22
    int-to-long v7, v7

    .line 23
    move v9, v4

    .line 24
    :goto_17
    if-ge v9, v1, :cond_33

    .line 25
    .line 26
    aget-wide v10, v2, v9

    .line 27
    .line 28
    add-int v12, v6, v9

    .line 29
    .line 30
    iget-object v13, v0, Lcom/kousei/framework/s3;->U:[J

    .line 31
    .line 32
    aget-wide v14, v13, v12

    .line 33
    .line 34
    and-long/2addr v14, v7

    .line 35
    xor-long/2addr v10, v14

    .line 36
    aput-wide v10, v2, v9

    .line 37
    .line 38
    aget-wide v10, v3, v9

    .line 39
    .line 40
    add-int v12, v6, v1

    .line 41
    .line 42
    add-int/2addr v12, v9

    .line 43
    aget-wide v12, v13, v12

    .line 44
    .line 45
    and-long/2addr v12, v7

    .line 46
    xor-long/2addr v10, v12

    .line 47
    aput-wide v10, v3, v9

    .line 48
    .line 49
    add-int/lit8 v9, v9, 0x1

    .line 50
    .line 51
    goto :goto_17

    .line 52
    :cond_33
    mul-int/lit8 v7, v1, 0x2

    .line 53
    .line 54
    add-int/2addr v6, v7

    .line 55
    add-int/lit8 v5, v5, 0x1

    .line 56
    .line 57
    goto :goto_b

    .line 58
    :cond_39
    new-instance v1, Lcom/kousei/framework/z3;

    .line 59
    .line 60
    iget-object v5, v0, Lcom/kousei/framework/s3;->W:Lcom/kousei/framework/t3;

    .line 61
    .line 62
    iget v6, v5, Lcom/kousei/framework/t3;->g:I

    .line 63
    .line 64
    new-instance v7, Lcom/kousei/framework/g6;

    .line 65
    .line 66
    invoke-direct {v7, v2}, Lcom/kousei/framework/g6;-><init>([J)V

    .line 67
    .line 68
    .line 69
    iget-object v0, v0, Lcom/kousei/framework/s3;->V:[I

    .line 70
    .line 71
    invoke-direct {v1, v6, v0, v7}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 72
    .line 73
    .line 74
    new-instance v2, Lcom/kousei/framework/z3;

    .line 75
    .line 76
    new-instance v7, Lcom/kousei/framework/g6;

    .line 77
    .line 78
    invoke-direct {v7, v3}, Lcom/kousei/framework/g6;-><init>([J)V

    .line 79
    .line 80
    .line 81
    invoke-direct {v2, v6, v0, v7}, Lcom/kousei/framework/z3;-><init>(I[ILcom/kousei/framework/g6;)V

    .line 82
    .line 83
    .line 84
    new-instance v0, Lcom/kousei/framework/e4;

    .line 85
    .line 86
    invoke-direct {v0, v5, v1, v2, v4}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 87
    .line 88
    .line 89
    return-object v0
.end method

.method public final b0()I
    .registers 1

    .line 1
    iget p0, p0, Lcom/kousei/framework/s3;->S:I

    .line 2
    .line 3
    return p0
.end method
