.class public final Lcom/kousei/framework/e2;
.super Lcom/kousei/framework/z;

# interfaces
.implements Lcom/kousei/framework/f0;


# instance fields
.field public final a:[C


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/d;

    .line 2
    .line 3
    const-class v1, Lcom/kousei/framework/e2;

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    invoke-direct {v0, v1, v2}, Lcom/kousei/framework/d;-><init>(Ljava/lang/Class;I)V

    .line 7
    .line 8
    .line 9
    return-void
.end method

.method public constructor <init>([B)V
    .registers 7

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    const/4 v0, 0x0

    .line 5
    if-eqz p1, :cond_2e

    .line 6
    .line 7
    array-length v1, p1

    .line 8
    and-int/lit8 v2, v1, 0x1

    .line 9
    .line 10
    if-nez v2, :cond_28

    .line 11
    .line 12
    div-int/lit8 v1, v1, 0x2

    .line 13
    .line 14
    new-array v0, v1, [C

    .line 15
    .line 16
    const/4 v2, 0x0

    .line 17
    :goto_10
    if-eq v2, v1, :cond_25

    .line 18
    .line 19
    mul-int/lit8 v3, v2, 0x2

    .line 20
    .line 21
    aget-byte v4, p1, v3

    .line 22
    .line 23
    shl-int/lit8 v4, v4, 0x8

    .line 24
    .line 25
    add-int/lit8 v3, v3, 0x1

    .line 26
    .line 27
    aget-byte v3, p1, v3

    .line 28
    .line 29
    and-int/lit16 v3, v3, 0xff

    .line 30
    .line 31
    or-int/2addr v3, v4

    .line 32
    int-to-char v3, v3

    .line 33
    aput-char v3, v0, v2

    .line 34
    .line 35
    add-int/lit8 v2, v2, 0x1

    .line 36
    .line 37
    goto :goto_10

    .line 38
    :cond_25
    iput-object v0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 39
    .line 40
    return-void

    .line 41
    :cond_28
    const-string p0, "malformed BMPString encoding encountered"

    .line 42
    .line 43
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 44
    .line 45
    .line 46
    throw v0

    .line 47
    :cond_2e
    const-string p0, "\'string\' cannot be null"

    .line 48
    .line 49
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 50
    .line 51
    .line 52
    throw v0
.end method

.method public constructor <init>([C)V
    .registers 2

    .line 53
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 54
    iput-object p1, p0, Lcom/kousei/framework/e2;->a:[C

    return-void
.end method


# virtual methods
.method public final c()Ljava/lang/String;
    .registers 2

    .line 1
    new-instance v0, Ljava/lang/String;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 4
    .line 5
    invoke-direct {v0, p0}, Ljava/lang/String;-><init>([C)V

    .line 6
    .line 7
    .line 8
    return-object v0
.end method

.method public final hashCode()I
    .registers 4

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 2
    .line 3
    array-length v0, p0

    .line 4
    add-int/lit8 v1, v0, 0x1

    .line 5
    .line 6
    :goto_5
    add-int/lit8 v0, v0, -0x1

    .line 7
    .line 8
    if-ltz v0, :cond_f

    .line 9
    .line 10
    mul-int/lit16 v1, v1, 0x101

    .line 11
    .line 12
    aget-char v2, p0, v0

    .line 13
    .line 14
    xor-int/2addr v1, v2

    .line 15
    goto :goto_5

    .line 16
    :cond_f
    return v1
.end method

.method public final i(Lcom/kousei/framework/z;)Z
    .registers 3

    .line 1
    instance-of v0, p1, Lcom/kousei/framework/e2;

    .line 2
    .line 3
    if-nez v0, :cond_6

    .line 4
    .line 5
    const/4 p0, 0x0

    .line 6
    return p0

    .line 7
    :cond_6
    check-cast p1, Lcom/kousei/framework/e2;

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 10
    .line 11
    iget-object p1, p1, Lcom/kousei/framework/e2;->a:[C

    .line 12
    .line 13
    invoke-static {p0, p1}, Ljava/util/Arrays;->equals([C[C)Z

    .line 14
    .line 15
    .line 16
    move-result p0

    .line 17
    return p0
.end method

.method public final j(Lcom/kousei/framework/x;Z)V
    .registers 15

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 2
    .line 3
    array-length v0, p0

    .line 4
    const/16 v1, 0x1e

    .line 5
    .line 6
    invoke-virtual {p1, p2, v1}, Lcom/kousei/framework/x;->m(ZI)V

    .line 7
    .line 8
    .line 9
    mul-int/lit8 p2, v0, 0x2

    .line 10
    .line 11
    invoke-virtual {p1, p2}, Lcom/kousei/framework/x;->h(I)V

    .line 12
    .line 13
    .line 14
    const/16 p2, 0x8

    .line 15
    .line 16
    new-array v1, p2, [B

    .line 17
    .line 18
    and-int/lit8 v2, v0, -0x4

    .line 19
    .line 20
    const/4 v3, 0x0

    .line 21
    move v4, v3

    .line 22
    :goto_15
    const/4 v5, 0x1

    .line 23
    const/4 v6, 0x2

    .line 24
    if-ge v4, v2, :cond_52

    .line 25
    .line 26
    aget-char v7, p0, v4

    .line 27
    .line 28
    add-int/lit8 v8, v4, 0x1

    .line 29
    .line 30
    aget-char v8, p0, v8

    .line 31
    .line 32
    add-int/lit8 v9, v4, 0x2

    .line 33
    .line 34
    aget-char v9, p0, v9

    .line 35
    .line 36
    add-int/lit8 v10, v4, 0x3

    .line 37
    .line 38
    aget-char v10, p0, v10

    .line 39
    .line 40
    add-int/lit8 v4, v4, 0x4

    .line 41
    .line 42
    shr-int/lit8 v11, v7, 0x8

    .line 43
    .line 44
    int-to-byte v11, v11

    .line 45
    aput-byte v11, v1, v3

    .line 46
    .line 47
    int-to-byte v7, v7

    .line 48
    aput-byte v7, v1, v5

    .line 49
    .line 50
    shr-int/lit8 v5, v8, 0x8

    .line 51
    .line 52
    int-to-byte v5, v5

    .line 53
    aput-byte v5, v1, v6

    .line 54
    .line 55
    int-to-byte v5, v8

    .line 56
    const/4 v6, 0x3

    .line 57
    aput-byte v5, v1, v6

    .line 58
    .line 59
    shr-int/lit8 v5, v9, 0x8

    .line 60
    .line 61
    int-to-byte v5, v5

    .line 62
    const/4 v6, 0x4

    .line 63
    aput-byte v5, v1, v6

    .line 64
    .line 65
    const/4 v5, 0x5

    .line 66
    int-to-byte v6, v9

    .line 67
    aput-byte v6, v1, v5

    .line 68
    .line 69
    shr-int/lit8 v5, v10, 0x8

    .line 70
    .line 71
    int-to-byte v5, v5

    .line 72
    const/4 v6, 0x6

    .line 73
    aput-byte v5, v1, v6

    .line 74
    .line 75
    const/4 v5, 0x7

    .line 76
    int-to-byte v6, v10

    .line 77
    aput-byte v6, v1, v5

    .line 78
    .line 79
    invoke-virtual {p1, v1, v3, p2}, Lcom/kousei/framework/x;->g([BII)V

    .line 80
    .line 81
    .line 82
    goto :goto_15

    .line 83
    :cond_52
    if-ge v4, v0, :cond_68

    .line 84
    .line 85
    move p2, v3

    .line 86
    :cond_55
    aget-char v2, p0, v4

    .line 87
    .line 88
    add-int/2addr v4, v5

    .line 89
    add-int/lit8 v7, p2, 0x1

    .line 90
    .line 91
    shr-int/lit8 v8, v2, 0x8

    .line 92
    .line 93
    int-to-byte v8, v8

    .line 94
    aput-byte v8, v1, p2

    .line 95
    .line 96
    add-int/2addr p2, v6

    .line 97
    int-to-byte v2, v2

    .line 98
    aput-byte v2, v1, v7

    .line 99
    .line 100
    if-lt v4, v0, :cond_55

    .line 101
    .line 102
    invoke-virtual {p1, v1, v3, p2}, Lcom/kousei/framework/x;->g([BII)V

    .line 103
    .line 104
    .line 105
    :cond_68
    return-void
.end method

.method public final k()Z
    .registers 1

    .line 1
    const/4 p0, 0x0

    .line 2
    return p0
.end method

.method public final m(Z)I
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/e2;->a:[C

    .line 2
    .line 3
    array-length p0, p0

    .line 4
    mul-int/lit8 p0, p0, 0x2

    .line 5
    .line 6
    invoke-static {p1, p0}, Lcom/kousei/framework/x;->d(ZI)I

    .line 7
    .line 8
    .line 9
    move-result p0

    .line 10
    return p0
.end method

.method public final toString()Ljava/lang/String;
    .registers 1

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/e2;->c()Ljava/lang/String;

    .line 2
    .line 3
    .line 4
    move-result-object p0

    .line 5
    return-object p0
.end method
