.class public final Lcom/kousei/framework/t8;
.super Lcom/kousei/framework/y3;


# static fields
.field public static final T:Ljava/math/BigInteger;

.field public static final U:[I


# instance fields
.field public final S:[I


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Ljava/math/BigInteger;

    .line 2
    .line 3
    const-string v1, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFE56D"

    .line 4
    .line 5
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    const/4 v2, 0x1

    .line 10
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 11
    .line 12
    .line 13
    sput-object v0, Lcom/kousei/framework/t8;->T:Ljava/math/BigInteger;

    .line 14
    .line 15
    const/4 v0, 0x7

    .line 16
    new-array v0, v0, [I

    .line 17
    .line 18
    fill-array-data v0, :array_18

    .line 19
    .line 20
    .line 21
    sput-object v0, Lcom/kousei/framework/t8;->U:[I

    .line 22
    .line 23
    return-void

    .line 24
    nop

    .line 25
    :array_18
    .array-data 4
        0x33bfd202
        -0x23052ecd
        0x2287624a
        -0x3c7ee458
        -0x57aaa704
        0x1eaef5d7
        -0x7120eab4
    .end array-data
.end method

.method public constructor <init>(Ljava/math/BigInteger;)V
    .registers 4

    .line 1
    const/16 v0, 0x17

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 4
    .line 5
    .line 6
    if-eqz p1, :cond_30

    .line 7
    .line 8
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-ltz v0, :cond_30

    .line 13
    .line 14
    sget-object v0, Lcom/kousei/framework/t8;->T:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 17
    .line 18
    .line 19
    move-result v0

    .line 20
    if-gez v0, :cond_30

    .line 21
    .line 22
    invoke-static {p1}, Lcom/kousei/framework/n6;->J(Ljava/math/BigInteger;)[I

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    const/4 v0, 0x6

    .line 27
    aget v0, p1, v0

    .line 28
    .line 29
    const/4 v1, -0x1

    .line 30
    if-ne v0, v1, :cond_2d

    .line 31
    .line 32
    sget-object v0, Lcom/kousei/framework/h0;->z:[I

    .line 33
    .line 34
    invoke-static {p1, v0}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 35
    .line 36
    .line 37
    move-result v0

    .line 38
    if-eqz v0, :cond_2d

    .line 39
    .line 40
    const/4 v0, 0x7

    .line 41
    const/16 v1, 0x1a93

    .line 42
    .line 43
    invoke-static {v0, v1, p1}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 44
    .line 45
    .line 46
    :cond_2d
    iput-object p1, p0, Lcom/kousei/framework/t8;->S:[I

    .line 47
    .line 48
    return-void

    .line 49
    :cond_30
    const-string p0, "x value invalid for SecP224K1FieldElement"

    .line 50
    .line 51
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 52
    .line 53
    .line 54
    const/4 p0, 0x0

    .line 55
    throw p0
.end method

.method public constructor <init>([I)V
    .registers 3

    const/16 v0, 0x17

    .line 56
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 57
    iput-object p1, p0, Lcom/kousei/framework/t8;->S:[I

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final E0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final L2(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/t8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/t8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->W2([I[I[I)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/t8;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 16
    .line 17
    .line 18
    return-object p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/t8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/t8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 11
    .line 12
    .line 13
    new-instance p0, Lcom/kousei/framework/t8;

    .line 14
    .line 15
    invoke-direct {p0, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 16
    .line 17
    .line 18
    return-object p0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/t8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/t8;->S:[I

    .line 7
    .line 8
    sget-object v1, Lcom/kousei/framework/h0;->z:[I

    .line 9
    .line 10
    invoke-static {v1, p1, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 11
    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 14
    .line 15
    invoke-static {v0, p0, v0}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 16
    .line 17
    .line 18
    new-instance p0, Lcom/kousei/framework/t8;

    .line 19
    .line 20
    invoke-direct {p0, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 21
    .line 22
    .line 23
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 9

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 2
    .line 3
    invoke-static {v0}, Lcom/kousei/framework/n6;->p0([I)Z

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_ab

    .line 8
    .line 9
    invoke-static {v0}, Lcom/kousei/framework/n6;->l0([I)Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_10

    .line 14
    .line 15
    goto/16 :goto_ab

    .line 16
    .line 17
    :cond_10
    const/4 p0, 0x7

    .line 18
    new-array v1, p0, [I

    .line 19
    .line 20
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 21
    .line 22
    .line 23
    invoke-static {v1, v0, v1}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 24
    .line 25
    .line 26
    invoke-static {v1, v1}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 27
    .line 28
    .line 29
    invoke-static {v1, v0, v1}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 30
    .line 31
    .line 32
    new-array v2, p0, [I

    .line 33
    .line 34
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 35
    .line 36
    .line 37
    invoke-static {v2, v0, v2}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 38
    .line 39
    .line 40
    new-array v3, p0, [I

    .line 41
    .line 42
    const/4 v4, 0x4

    .line 43
    invoke-static {v4, v2, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 44
    .line 45
    .line 46
    invoke-static {v3, v2, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 47
    .line 48
    .line 49
    new-array v5, p0, [I

    .line 50
    .line 51
    const/4 v6, 0x3

    .line 52
    invoke-static {v6, v3, v5}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 53
    .line 54
    .line 55
    invoke-static {v5, v1, v5}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 56
    .line 57
    .line 58
    const/16 v7, 0x8

    .line 59
    .line 60
    invoke-static {v7, v5, v5}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 61
    .line 62
    .line 63
    invoke-static {v5, v3, v5}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 64
    .line 65
    .line 66
    invoke-static {v4, v5, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 67
    .line 68
    .line 69
    invoke-static {v3, v2, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 70
    .line 71
    .line 72
    const/16 v7, 0x13

    .line 73
    .line 74
    invoke-static {v7, v3, v2}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 75
    .line 76
    .line 77
    invoke-static {v2, v5, v2}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 78
    .line 79
    .line 80
    new-array p0, p0, [I

    .line 81
    .line 82
    const/16 v7, 0x2a

    .line 83
    .line 84
    invoke-static {v7, v2, p0}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 85
    .line 86
    .line 87
    invoke-static {p0, v2, p0}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 88
    .line 89
    .line 90
    const/16 v7, 0x17

    .line 91
    .line 92
    invoke-static {v7, p0, v2}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 93
    .line 94
    .line 95
    invoke-static {v2, v3, v2}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 96
    .line 97
    .line 98
    const/16 v7, 0x54

    .line 99
    .line 100
    invoke-static {v7, v2, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 101
    .line 102
    .line 103
    invoke-static {v3, p0, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 104
    .line 105
    .line 106
    const/16 v2, 0x14

    .line 107
    .line 108
    invoke-static {v2, v3, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 109
    .line 110
    .line 111
    invoke-static {v3, v5, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 112
    .line 113
    .line 114
    invoke-static {v6, v3, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 115
    .line 116
    .line 117
    invoke-static {v3, v0, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 118
    .line 119
    .line 120
    const/4 v2, 0x2

    .line 121
    invoke-static {v2, v3, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 122
    .line 123
    .line 124
    invoke-static {v3, v0, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 125
    .line 126
    .line 127
    invoke-static {v4, v3, v3}, Lcom/kousei/framework/h0;->A2(I[I[I)V

    .line 128
    .line 129
    .line 130
    invoke-static {v3, v1, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 131
    .line 132
    .line 133
    invoke-static {v3, v3}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 134
    .line 135
    .line 136
    invoke-static {v3, p0}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 137
    .line 138
    .line 139
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->D([I[I)Z

    .line 140
    .line 141
    .line 142
    move-result v1

    .line 143
    if-eqz v1, :cond_96

    .line 144
    .line 145
    new-instance p0, Lcom/kousei/framework/t8;

    .line 146
    .line 147
    invoke-direct {p0, v3}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 148
    .line 149
    .line 150
    return-object p0

    .line 151
    :cond_96
    sget-object v1, Lcom/kousei/framework/t8;->U:[I

    .line 152
    .line 153
    invoke-static {v3, v1, v3}, Lcom/kousei/framework/h0;->g1([I[I[I)V

    .line 154
    .line 155
    .line 156
    invoke-static {v3, p0}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 157
    .line 158
    .line 159
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->D([I[I)Z

    .line 160
    .line 161
    .line 162
    move-result p0

    .line 163
    if-eqz p0, :cond_aa

    .line 164
    .line 165
    new-instance p0, Lcom/kousei/framework/t8;

    .line 166
    .line 167
    invoke-direct {p0, v3}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 168
    .line 169
    .line 170
    return-object p0

    .line 171
    :cond_aa
    const/4 p0, 0x0

    .line 172
    :cond_ab
    :goto_ab
    return-object p0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 5
    .line 6
    invoke-static {p0, v0}, Lcom/kousei/framework/h0;->j2([I[I)V

    .line 7
    .line 8
    .line 9
    new-instance p0, Lcom/kousei/framework/t8;

    .line 10
    .line 11
    invoke-direct {p0, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 12
    .line 13
    .line 14
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->j1([I)Ljava/math/BigInteger;

    .line 4
    .line 5
    .line 6
    move-result-object p0

    .line 7
    return-object p0
.end method

.method public final a0()I
    .registers 1

    .line 1
    sget-object p0, Lcom/kousei/framework/t8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {p0}, Ljava/math/BigInteger;->bitLength()I

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final b(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v1, v0, [I

    .line 3
    .line 4
    check-cast p1, Lcom/kousei/framework/t8;

    .line 5
    .line 6
    iget-object p1, p1, Lcom/kousei/framework/t8;->S:[I

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 9
    .line 10
    invoke-static {p0, p1, v1}, Lcom/kousei/framework/n6;->b([I[I[I)I

    .line 11
    .line 12
    .line 13
    move-result p0

    .line 14
    if-nez p0, :cond_1d

    .line 15
    .line 16
    const/4 p0, 0x6

    .line 17
    aget p0, v1, p0

    .line 18
    .line 19
    const/4 p1, -0x1

    .line 20
    if-ne p0, p1, :cond_22

    .line 21
    .line 22
    sget-object p0, Lcom/kousei/framework/h0;->z:[I

    .line 23
    .line 24
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 25
    .line 26
    .line 27
    move-result p0

    .line 28
    if-eqz p0, :cond_22

    .line 29
    .line 30
    :cond_1d
    const/16 p0, 0x1a93

    .line 31
    .line 32
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 33
    .line 34
    .line 35
    :cond_22
    new-instance p0, Lcom/kousei/framework/t8;

    .line 36
    .line 37
    invoke-direct {p0, v1}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 38
    .line 39
    .line 40
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
    instance-of v0, p1, Lcom/kousei/framework/t8;

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
    check-cast p1, Lcom/kousei/framework/t8;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/t8;->S:[I

    .line 16
    .line 17
    invoke-static {p0, p1}, Lcom/kousei/framework/n6;->D([I[I)Z

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    return p0
.end method

.method public final hashCode()I
    .registers 3

    .line 1
    sget-object v0, Lcom/kousei/framework/t8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 8
    .line 9
    const/4 v1, 0x7

    .line 10
    invoke-static {v1, p0}, Lcom/kousei/framework/h0;->h0(I[I)I

    .line 11
    .line 12
    .line 13
    move-result p0

    .line 14
    xor-int/2addr p0, v0

    .line 15
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v1, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 5
    .line 6
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 7
    .line 8
    .line 9
    move-result v0

    .line 10
    sget-object v2, Lcom/kousei/framework/h0;->z:[I

    .line 11
    .line 12
    if-eqz v0, :cond_11

    .line 13
    .line 14
    invoke-static {v2, v2, v1}, Lcom/kousei/framework/n6;->b1([I[I[I)I

    .line 15
    .line 16
    .line 17
    goto :goto_14

    .line 18
    :cond_11
    invoke-static {v2, p0, v1}, Lcom/kousei/framework/n6;->b1([I[I[I)I

    .line 19
    .line 20
    .line 21
    :goto_14
    new-instance p0, Lcom/kousei/framework/t8;

    .line 22
    .line 23
    invoke-direct {p0, v1}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 24
    .line 25
    .line 26
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v1, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 5
    .line 6
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->f0(I[I[I)I

    .line 7
    .line 8
    .line 9
    move-result p0

    .line 10
    if-nez p0, :cond_19

    .line 11
    .line 12
    const/4 p0, 0x6

    .line 13
    aget p0, v1, p0

    .line 14
    .line 15
    const/4 v2, -0x1

    .line 16
    if-ne p0, v2, :cond_1e

    .line 17
    .line 18
    sget-object p0, Lcom/kousei/framework/h0;->z:[I

    .line 19
    .line 20
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->N([I[I)Z

    .line 21
    .line 22
    .line 23
    move-result p0

    .line 24
    if-eqz p0, :cond_1e

    .line 25
    .line 26
    :cond_19
    const/16 p0, 0x1a93

    .line 27
    .line 28
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 29
    .line 30
    .line 31
    :cond_1e
    new-instance p0, Lcom/kousei/framework/t8;

    .line 32
    .line 33
    invoke-direct {p0, v1}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 34
    .line 35
    .line 36
    return-object p0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/4 v0, 0x7

    .line 2
    new-array v0, v0, [I

    .line 3
    .line 4
    iget-object p0, p0, Lcom/kousei/framework/t8;->S:[I

    .line 5
    .line 6
    sget-object v1, Lcom/kousei/framework/h0;->z:[I

    .line 7
    .line 8
    invoke-static {v1, p0, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 9
    .line 10
    .line 11
    new-instance p0, Lcom/kousei/framework/t8;

    .line 12
    .line 13
    invoke-direct {p0, v0}, Lcom/kousei/framework/t8;-><init>([I)V

    .line 14
    .line 15
    .line 16
    return-object p0
.end method
