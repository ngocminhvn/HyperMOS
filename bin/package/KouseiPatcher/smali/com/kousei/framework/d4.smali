.class public abstract Lcom/kousei/framework/d4;
.super Ljava/lang/Object;


# static fields
.field public static final g:[Lcom/kousei/framework/h0;


# instance fields
.field public final a:Lcom/kousei/framework/v3;

.field public final b:Lcom/kousei/framework/h0;

.field public final c:Lcom/kousei/framework/h0;

.field public final d:[Lcom/kousei/framework/h0;

.field public e:Ljava/util/Hashtable;

.field public final synthetic f:I


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 1
    const/4 v0, 0x0

    .line 2
    new-array v0, v0, [Lcom/kousei/framework/h0;

    .line 3
    .line 4
    sput-object v0, Lcom/kousei/framework/d4;->g:[Lcom/kousei/framework/h0;

    .line 5
    .line 6
    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V
    .registers 7

    .line 1
    iput p4, p0, Lcom/kousei/framework/d4;->f:I

    .line 2
    .line 3
    if-nez p1, :cond_6

    .line 4
    .line 5
    const/4 p4, 0x0

    .line 6
    goto :goto_8

    .line 7
    :cond_6
    iget p4, p1, Lcom/kousei/framework/v3;->f:I

    .line 8
    .line 9
    :goto_8
    if-eqz p4, :cond_3b

    .line 10
    .line 11
    const/4 v0, 0x5

    .line 12
    if-eq p4, v0, :cond_3b

    .line 13
    .line 14
    sget-object v0, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p1, v0}, Lcom/kousei/framework/v3;->f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;

    .line 17
    .line 18
    .line 19
    move-result-object v0

    .line 20
    const/4 v1, 0x1

    .line 21
    if-eq p4, v1, :cond_36

    .line 22
    .line 23
    const/4 v1, 0x2

    .line 24
    if-eq p4, v1, :cond_36

    .line 25
    .line 26
    const/4 v1, 0x3

    .line 27
    if-eq p4, v1, :cond_31

    .line 28
    .line 29
    const/4 v1, 0x4

    .line 30
    if-eq p4, v1, :cond_2a

    .line 31
    .line 32
    const/4 v1, 0x6

    .line 33
    if-ne p4, v1, :cond_23

    .line 34
    .line 35
    goto :goto_36

    .line 36
    :cond_23
    const-string p0, "unknown coordinate system"

    .line 37
    .line 38
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 39
    .line 40
    .line 41
    const/4 p0, 0x0

    .line 42
    throw p0

    .line 43
    :cond_2a
    iget-object p4, p1, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 44
    .line 45
    filled-new-array {v0, p4}, [Lcom/kousei/framework/h0;

    .line 46
    .line 47
    .line 48
    move-result-object p4

    .line 49
    goto :goto_3d

    .line 50
    :cond_31
    filled-new-array {v0, v0, v0}, [Lcom/kousei/framework/h0;

    .line 51
    .line 52
    .line 53
    move-result-object p4

    .line 54
    goto :goto_3d

    .line 55
    :cond_36
    :goto_36
    filled-new-array {v0}, [Lcom/kousei/framework/h0;

    .line 56
    .line 57
    .line 58
    move-result-object p4

    .line 59
    goto :goto_3d

    .line 60
    :cond_3b
    sget-object p4, Lcom/kousei/framework/d4;->g:[Lcom/kousei/framework/h0;

    .line 61
    .line 62
    :goto_3d
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/kousei/framework/d4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;)V

    .line 63
    .line 64
    .line 65
    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;)V
    .registers 6

    .line 66
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/kousei/framework/d4;->e:Ljava/util/Hashtable;

    iput-object p1, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    iput-object p2, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    iput-object p3, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    iput-object p4, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    return-void
.end method

.method public synthetic constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;I)V
    .registers 6

    .line 67
    iput p5, p0, Lcom/kousei/framework/d4;->f:I

    invoke-direct {p0, p1, p2, p3, p4}, Lcom/kousei/framework/d4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;[Lcom/kousei/framework/h0;)V

    return-void
.end method


# virtual methods
.method public abstract a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
.end method

.method public final b()V
    .registers 1

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->i()Z

    .line 2
    .line 3
    .line 4
    move-result p0

    .line 5
    if-eqz p0, :cond_7

    .line 6
    .line 7
    return-void

    .line 8
    :cond_7
    const-string p0, "point not in normal form"

    .line 9
    .line 10
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 11
    .line 12
    .line 13
    return-void
.end method

.method public final c(Lcom/kousei/framework/d4;)Z
    .registers 11

    .line 1
    const/4 v0, 0x0

    .line 2
    if-nez p1, :cond_5

    .line 3
    .line 4
    goto/16 :goto_75

    .line 5
    .line 6
    :cond_5
    iget-object v1, p1, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 7
    .line 8
    const/4 v2, 0x1

    .line 9
    iget-object v3, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 10
    .line 11
    if-nez v3, :cond_e

    .line 12
    .line 13
    move v4, v2

    .line 14
    goto :goto_f

    .line 15
    :cond_e
    move v4, v0

    .line 16
    :goto_f
    if-nez v1, :cond_13

    .line 17
    .line 18
    move v5, v2

    .line 19
    goto :goto_14

    .line 20
    :cond_13
    move v5, v0

    .line 21
    :goto_14
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 22
    .line 23
    .line 24
    move-result v6

    .line 25
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 26
    .line 27
    .line 28
    move-result v7

    .line 29
    if-nez v6, :cond_66

    .line 30
    .line 31
    if-eqz v7, :cond_21

    .line 32
    .line 33
    goto :goto_66

    .line 34
    :cond_21
    if-eqz v4, :cond_26

    .line 35
    .line 36
    if-eqz v5, :cond_26

    .line 37
    .line 38
    goto :goto_4d

    .line 39
    :cond_26
    if-eqz v4, :cond_2d

    .line 40
    .line 41
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 42
    .line 43
    .line 44
    move-result-object p1

    .line 45
    goto :goto_4d

    .line 46
    :cond_2d
    if-eqz v5, :cond_34

    .line 47
    .line 48
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 49
    .line 50
    .line 51
    move-result-object p0

    .line 52
    goto :goto_4d

    .line 53
    :cond_34
    invoke-virtual {v3, v1}, Lcom/kousei/framework/v3;->e(Lcom/kousei/framework/v3;)Z

    .line 54
    .line 55
    .line 56
    move-result v1

    .line 57
    if-nez v1, :cond_3b

    .line 58
    .line 59
    goto :goto_75

    .line 60
    :cond_3b
    invoke-virtual {v3, p1}, Lcom/kousei/framework/v3;->i(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 61
    .line 62
    .line 63
    move-result-object p1

    .line 64
    filled-new-array {p0, p1}, [Lcom/kousei/framework/d4;

    .line 65
    .line 66
    .line 67
    move-result-object p0

    .line 68
    invoke-virtual {v3, p0}, Lcom/kousei/framework/v3;->j([Lcom/kousei/framework/d4;)V

    .line 69
    .line 70
    .line 71
    aget-object p1, p0, v0

    .line 72
    .line 73
    aget-object p0, p0, v2

    .line 74
    .line 75
    move-object v8, p1

    .line 76
    move-object p1, p0

    .line 77
    move-object p0, v8

    .line 78
    :goto_4d
    iget-object v1, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 79
    .line 80
    iget-object v3, p1, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 81
    .line 82
    invoke-virtual {v1, v3}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 83
    .line 84
    .line 85
    move-result v1

    .line 86
    if-eqz v1, :cond_75

    .line 87
    .line 88
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 89
    .line 90
    .line 91
    move-result-object p0

    .line 92
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 93
    .line 94
    .line 95
    move-result-object p1

    .line 96
    invoke-virtual {p0, p1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 97
    .line 98
    .line 99
    move-result p0

    .line 100
    if-eqz p0, :cond_75

    .line 101
    .line 102
    goto :goto_74

    .line 103
    :cond_66
    :goto_66
    if-eqz v6, :cond_75

    .line 104
    .line 105
    if-eqz v7, :cond_75

    .line 106
    .line 107
    if-nez v4, :cond_74

    .line 108
    .line 109
    if-nez v5, :cond_74

    .line 110
    .line 111
    invoke-virtual {v3, v1}, Lcom/kousei/framework/v3;->e(Lcom/kousei/framework/v3;)Z

    .line 112
    .line 113
    .line 114
    move-result p0

    .line 115
    if-eqz p0, :cond_75

    .line 116
    .line 117
    :cond_74
    :goto_74
    return v2

    .line 118
    :cond_75
    :goto_75
    return v0
.end method

.method public final d()I
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2
    .line 3
    if-nez p0, :cond_6

    .line 4
    .line 5
    const/4 p0, 0x0

    .line 6
    return p0

    .line 7
    :cond_6
    iget p0, p0, Lcom/kousei/framework/v3;->f:I

    .line 8
    .line 9
    return p0
.end method

.method public e()Lcom/kousei/framework/h0;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 2
    .line 3
    return-object p0
.end method

.method public final equals(Ljava/lang/Object;)Z
    .registers 3

    .line 1
    if-ne p1, p0, :cond_4

    .line 2
    .line 3
    const/4 p0, 0x1

    .line 4
    return p0

    .line 5
    :cond_4
    instance-of v0, p1, Lcom/kousei/framework/d4;

    .line 6
    .line 7
    if-nez v0, :cond_a

    .line 8
    .line 9
    const/4 p0, 0x0

    .line 10
    return p0

    .line 11
    :cond_a
    check-cast p1, Lcom/kousei/framework/d4;

    .line 12
    .line 13
    invoke-virtual {p0, p1}, Lcom/kousei/framework/d4;->c(Lcom/kousei/framework/d4;)Z

    .line 14
    .line 15
    .line 16
    move-result p0

    .line 17
    return p0
.end method

.method public f()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 2
    .line 3
    array-length v0, p0

    .line 4
    if-gtz v0, :cond_7

    .line 5
    .line 6
    const/4 p0, 0x0

    .line 7
    return-object p0

    .line 8
    :cond_7
    const/4 v0, 0x0

    .line 9
    aget-object p0, p0, v0

    .line 10
    .line 11
    return-object p0
.end method

.method public final g(ZZ)Z
    .registers 5

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    const/4 v1, 0x1

    .line 6
    if-eqz v0, :cond_8

    .line 7
    .line 8
    return v1

    .line 9
    :cond_8
    new-instance v0, Lcom/kousei/framework/c4;

    .line 10
    .line 11
    invoke-direct {v0, p0, p1, p2}, Lcom/kousei/framework/c4;-><init>(Lcom/kousei/framework/d4;ZZ)V

    .line 12
    .line 13
    .line 14
    iget-object p1, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 15
    .line 16
    const-string p2, "bc_validity"

    .line 17
    .line 18
    invoke-virtual {p1, p0, p2, v0}, Lcom/kousei/framework/v3;->k(Lcom/kousei/framework/d4;Ljava/lang/String;Lcom/kousei/framework/h7;)Lcom/kousei/framework/i7;

    .line 19
    .line 20
    .line 21
    move-result-object p0

    .line 22
    check-cast p0, Lcom/kousei/framework/ua;

    .line 23
    .line 24
    iget-boolean p0, p0, Lcom/kousei/framework/ua;->a:Z

    .line 25
    .line 26
    xor-int/2addr p0, v1

    .line 27
    return p0
.end method

.method public final h()Z
    .registers 3

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 2
    .line 3
    if-eqz v0, :cond_18

    .line 4
    .line 5
    iget-object v0, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 6
    .line 7
    if-eqz v0, :cond_18

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 10
    .line 11
    array-length v0, p0

    .line 12
    const/4 v1, 0x0

    .line 13
    if-lez v0, :cond_17

    .line 14
    .line 15
    aget-object p0, p0, v1

    .line 16
    .line 17
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->E0()Z

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    if-eqz p0, :cond_17

    .line 22
    .line 23
    goto :goto_18

    .line 24
    :cond_17
    return v1

    .line 25
    :cond_18
    :goto_18
    const/4 p0, 0x1

    .line 26
    return p0
.end method

.method public final hashCode()I
    .registers 3

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 2
    .line 3
    if-nez v0, :cond_6

    .line 4
    .line 5
    const/4 v0, 0x0

    .line 6
    goto :goto_b

    .line 7
    :cond_6
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->hashCode()I

    .line 8
    .line 9
    .line 10
    move-result v0

    .line 11
    not-int v0, v0

    .line 12
    :goto_b
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 13
    .line 14
    .line 15
    move-result v1

    .line 16
    if-nez v1, :cond_2a

    .line 17
    .line 18
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 19
    .line 20
    .line 21
    move-result-object p0

    .line 22
    iget-object v1, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 23
    .line 24
    invoke-virtual {v1}, Ljava/lang/Object;->hashCode()I

    .line 25
    .line 26
    .line 27
    move-result v1

    .line 28
    mul-int/lit8 v1, v1, 0x11

    .line 29
    .line 30
    xor-int/2addr v0, v1

    .line 31
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->e()Lcom/kousei/framework/h0;

    .line 32
    .line 33
    .line 34
    move-result-object p0

    .line 35
    invoke-virtual {p0}, Ljava/lang/Object;->hashCode()I

    .line 36
    .line 37
    .line 38
    move-result p0

    .line 39
    mul-int/lit16 p0, p0, 0x101

    .line 40
    .line 41
    xor-int/2addr p0, v0

    .line 42
    return p0

    .line 43
    :cond_2a
    return v0
.end method

.method public final i()Z
    .registers 3

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->d()I

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_1c

    .line 6
    .line 7
    const/4 v1, 0x5

    .line 8
    if-eq v0, v1, :cond_1c

    .line 9
    .line 10
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 11
    .line 12
    .line 13
    move-result v0

    .line 14
    if-nez v0, :cond_1c

    .line 15
    .line 16
    iget-object p0, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 17
    .line 18
    const/4 v0, 0x0

    .line 19
    aget-object p0, p0, v0

    .line 20
    .line 21
    invoke-virtual {p0}, Lcom/kousei/framework/h0;->A0()Z

    .line 22
    .line 23
    .line 24
    move-result p0

    .line 25
    if-eqz p0, :cond_1b

    .line 26
    .line 27
    goto :goto_1c

    .line 28
    :cond_1b
    return v0

    .line 29
    :cond_1c
    :goto_1c
    const/4 p0, 0x1

    .line 30
    return p0
.end method

.method public abstract j()Lcom/kousei/framework/d4;
.end method

.method public final k()Lcom/kousei/framework/d4;
    .registers 4

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_7

    .line 6
    .line 7
    goto :goto_3e

    .line 8
    :cond_7
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->d()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-eqz v0, :cond_3e

    .line 13
    .line 14
    const/4 v1, 0x5

    .line 15
    if-eq v0, v1, :cond_3e

    .line 16
    .line 17
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->f()Lcom/kousei/framework/h0;

    .line 18
    .line 19
    .line 20
    move-result-object v0

    .line 21
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->A0()Z

    .line 22
    .line 23
    .line 24
    move-result v1

    .line 25
    if-eqz v1, :cond_1b

    .line 26
    .line 27
    goto :goto_3e

    .line 28
    :cond_1b
    iget-object v1, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 29
    .line 30
    if-eqz v1, :cond_38

    .line 31
    .line 32
    invoke-static {}, Lcom/kousei/framework/x1;->a()Ljava/security/SecureRandom;

    .line 33
    .line 34
    .line 35
    move-result-object v2

    .line 36
    invoke-virtual {v1, v2}, Lcom/kousei/framework/v3;->l(Ljava/security/SecureRandom;)Lcom/kousei/framework/h0;

    .line 37
    .line 38
    .line 39
    move-result-object v1

    .line 40
    invoke-virtual {v0, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 41
    .line 42
    .line 43
    move-result-object v0

    .line 44
    invoke-virtual {v0}, Lcom/kousei/framework/h0;->z0()Lcom/kousei/framework/h0;

    .line 45
    .line 46
    .line 47
    move-result-object v0

    .line 48
    invoke-virtual {v0, v1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 49
    .line 50
    .line 51
    move-result-object v0

    .line 52
    invoke-virtual {p0, v0}, Lcom/kousei/framework/d4;->l(Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;

    .line 53
    .line 54
    .line 55
    move-result-object p0

    .line 56
    return-object p0

    .line 57
    :cond_38
    const-string p0, "Detached points must be in affine coordinates"

    .line 58
    .line 59
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 60
    .line 61
    .line 62
    const/4 p0, 0x0

    .line 63
    :cond_3e
    :goto_3e
    return-object p0
.end method

.method public final l(Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;
    .registers 6

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->d()I

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    const/4 v1, 0x1

    .line 6
    iget-object v2, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 7
    .line 8
    iget-object v3, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 9
    .line 10
    iget-object p0, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 11
    .line 12
    if-eq v0, v1, :cond_36

    .line 13
    .line 14
    const/4 v1, 0x2

    .line 15
    if-eq v0, v1, :cond_21

    .line 16
    .line 17
    const/4 v1, 0x3

    .line 18
    if-eq v0, v1, :cond_21

    .line 19
    .line 20
    const/4 v1, 0x4

    .line 21
    if-eq v0, v1, :cond_21

    .line 22
    .line 23
    const/4 v1, 0x6

    .line 24
    if-ne v0, v1, :cond_1a

    .line 25
    .line 26
    goto :goto_36

    .line 27
    :cond_1a
    const-string p0, "not a projective coordinate system"

    .line 28
    .line 29
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 30
    .line 31
    .line 32
    const/4 p0, 0x0

    .line 33
    return-object p0

    .line 34
    :cond_21
    invoke-virtual {p1}, Lcom/kousei/framework/h0;->X1()Lcom/kousei/framework/h0;

    .line 35
    .line 36
    .line 37
    move-result-object v0

    .line 38
    invoke-virtual {v0, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 39
    .line 40
    .line 41
    move-result-object p1

    .line 42
    invoke-virtual {v3, v0}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 43
    .line 44
    .line 45
    move-result-object v0

    .line 46
    invoke-virtual {v2, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 47
    .line 48
    .line 49
    move-result-object p1

    .line 50
    invoke-virtual {p0, v0, p1}, Lcom/kousei/framework/v3;->d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;

    .line 51
    .line 52
    .line 53
    move-result-object p0

    .line 54
    return-object p0

    .line 55
    :cond_36
    :goto_36
    invoke-virtual {v3, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 56
    .line 57
    .line 58
    move-result-object v0

    .line 59
    invoke-virtual {v2, p1}, Lcom/kousei/framework/h0;->Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;

    .line 60
    .line 61
    .line 62
    move-result-object p1

    .line 63
    invoke-virtual {p0, v0, p1}, Lcom/kousei/framework/v3;->d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    return-object p0
.end method

.method public final m()Z
    .registers 9

    .line 1
    sget-object v0, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 4
    .line 5
    iget-object v2, v1, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 6
    .line 7
    invoke-virtual {v0, v2}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 8
    .line 9
    .line 10
    move-result v0

    .line 11
    const/4 v2, 0x1

    .line 12
    if-eqz v0, :cond_e

    .line 13
    .line 14
    goto :goto_4e

    .line 15
    :cond_e
    iget-object v0, v1, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 16
    .line 17
    if-eqz v0, :cond_4e

    .line 18
    .line 19
    invoke-virtual {v0}, Ljava/math/BigInteger;->abs()Ljava/math/BigInteger;

    .line 20
    .line 21
    .line 22
    move-result-object v3

    .line 23
    invoke-virtual {v1}, Lcom/kousei/framework/v3;->h()Lcom/kousei/framework/d4;

    .line 24
    .line 25
    .line 26
    move-result-object v1

    .line 27
    invoke-virtual {v3}, Ljava/math/BigInteger;->bitLength()I

    .line 28
    .line 29
    .line 30
    move-result v4

    .line 31
    const/4 v5, 0x0

    .line 32
    if-lez v4, :cond_3c

    .line 33
    .line 34
    invoke-virtual {v3, v5}, Ljava/math/BigInteger;->testBit(I)Z

    .line 35
    .line 36
    .line 37
    move-result v6

    .line 38
    if-eqz v6, :cond_28

    .line 39
    .line 40
    move-object v1, p0

    .line 41
    :cond_28
    move v6, v2

    .line 42
    :goto_29
    if-ge v6, v4, :cond_3c

    .line 43
    .line 44
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->o()Lcom/kousei/framework/d4;

    .line 45
    .line 46
    .line 47
    move-result-object p0

    .line 48
    invoke-virtual {v3, v6}, Ljava/math/BigInteger;->testBit(I)Z

    .line 49
    .line 50
    .line 51
    move-result v7

    .line 52
    if-eqz v7, :cond_39

    .line 53
    .line 54
    invoke-virtual {v1, p0}, Lcom/kousei/framework/d4;->a(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 55
    .line 56
    .line 57
    move-result-object v1

    .line 58
    :cond_39
    add-int/lit8 v6, v6, 0x1

    .line 59
    .line 60
    goto :goto_29

    .line 61
    :cond_3c
    invoke-virtual {v0}, Ljava/math/BigInteger;->signum()I

    .line 62
    .line 63
    .line 64
    move-result p0

    .line 65
    if-gez p0, :cond_46

    .line 66
    .line 67
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->j()Lcom/kousei/framework/d4;

    .line 68
    .line 69
    .line 70
    move-result-object v1

    .line 71
    :cond_46
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->h()Z

    .line 72
    .line 73
    .line 74
    move-result p0

    .line 75
    if-eqz p0, :cond_4d

    .line 76
    .line 77
    goto :goto_4e

    .line 78
    :cond_4d
    return v5

    .line 79
    :cond_4e
    :goto_4e
    return v2
.end method

.method public n(I)Lcom/kousei/framework/d4;
    .registers 2

    .line 1
    if-ltz p1, :cond_c

    .line 2
    .line 3
    :goto_2
    add-int/lit8 p1, p1, -0x1

    .line 4
    .line 5
    if-ltz p1, :cond_b

    .line 6
    .line 7
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->o()Lcom/kousei/framework/d4;

    .line 8
    .line 9
    .line 10
    move-result-object p0

    .line 11
    goto :goto_2

    .line 12
    :cond_b
    return-object p0

    .line 13
    :cond_c
    const-string p0, "\'e\' cannot be negative"

    .line 14
    .line 15
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 16
    .line 17
    .line 18
    const/4 p0, 0x0

    .line 19
    return-object p0
.end method

.method public abstract o()Lcom/kousei/framework/d4;
.end method

.method public abstract p(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;
.end method

.method public final toString()Ljava/lang/String;
    .registers 6

    .line 1
    invoke-virtual {p0}, Lcom/kousei/framework/d4;->h()Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_9

    .line 6
    .line 7
    const-string p0, "INF"

    .line 8
    .line 9
    return-object p0

    .line 10
    :cond_9
    new-instance v0, Ljava/lang/StringBuilder;

    .line 11
    .line 12
    const-string v1, "("

    .line 13
    .line 14
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 15
    .line 16
    .line 17
    iget-object v1, p0, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 18
    .line 19
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 20
    .line 21
    .line 22
    const/16 v1, 0x2c

    .line 23
    .line 24
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 25
    .line 26
    .line 27
    iget-object v2, p0, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 28
    .line 29
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 30
    .line 31
    .line 32
    const/4 v2, 0x0

    .line 33
    :goto_20
    iget-object v3, p0, Lcom/kousei/framework/d4;->d:[Lcom/kousei/framework/h0;

    .line 34
    .line 35
    array-length v4, v3

    .line 36
    if-ge v2, v4, :cond_30

    .line 37
    .line 38
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 39
    .line 40
    .line 41
    aget-object v3, v3, v2

    .line 42
    .line 43
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 44
    .line 45
    .line 46
    add-int/lit8 v2, v2, 0x1

    .line 47
    .line 48
    goto :goto_20

    .line 49
    :cond_30
    const/16 p0, 0x29

    .line 50
    .line 51
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 52
    .line 53
    .line 54
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 55
    .line 56
    .line 57
    move-result-object p0

    .line 58
    return-object p0
.end method
