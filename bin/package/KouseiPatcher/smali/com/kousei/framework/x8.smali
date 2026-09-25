.class public final Lcom/kousei/framework/x8;
.super Lcom/kousei/framework/y3;


# static fields
.field public static final T:Ljava/math/BigInteger;


# instance fields
.field public final S:[I


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Ljava/math/BigInteger;

    .line 2
    .line 3
    const-string v1, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F"

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
    sput-object v0, Lcom/kousei/framework/x8;->T:Ljava/math/BigInteger;

    .line 14
    .line 15
    return-void
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
    if-eqz p1, :cond_2d

    .line 7
    .line 8
    invoke-virtual {p1}, Ljava/math/BigInteger;->signum()I

    .line 9
    .line 10
    .line 11
    move-result v0

    .line 12
    if-ltz v0, :cond_2d

    .line 13
    .line 14
    sget-object v0, Lcom/kousei/framework/x8;->T:Ljava/math/BigInteger;

    .line 15
    .line 16
    invoke-virtual {p1, v0}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 17
    .line 18
    .line 19
    move-result v0

    .line 20
    if-gez v0, :cond_2d

    .line 21
    .line 22
    invoke-static {p1}, Lcom/kousei/framework/n6;->K(Ljava/math/BigInteger;)[I

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    const/4 v0, 0x7

    .line 27
    aget v0, p1, v0

    .line 28
    .line 29
    const/4 v1, -0x1

    .line 30
    if-ne v0, v1, :cond_2a

    .line 31
    .line 32
    sget-object v0, Lcom/kousei/framework/h0;->F:[I

    .line 33
    .line 34
    invoke-static {p1, v0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 35
    .line 36
    .line 37
    move-result v1

    .line 38
    if-eqz v1, :cond_2a

    .line 39
    .line 40
    invoke-static {v0, p1}, Lcom/kousei/framework/n6;->h1([I[I)V

    .line 41
    .line 42
    .line 43
    :cond_2a
    iput-object p1, p0, Lcom/kousei/framework/x8;->S:[I

    .line 44
    .line 45
    return-void

    .line 46
    :cond_2d
    const-string p0, "x value invalid for SecP256K1FieldElement"

    .line 47
    .line 48
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 49
    .line 50
    .line 51
    const/4 p0, 0x0

    .line 52
    throw p0
.end method

.method public constructor <init>([I)V
    .registers 3

    const/16 v0, 0x17

    .line 53
    invoke-direct {p0, v0}, Lcom/kousei/framework/h0;-><init>(I)V

    .line 54
    iput-object p1, p0, Lcom/kousei/framework/x8;->S:[I

    return-void
.end method


# virtual methods
.method public final A0()Z
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->m0([I)Z

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
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->q0([I)Z

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
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/x8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/x8;->S:[I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, p1, v0}, Lcom/kousei/framework/h0;->Y2([I[I[I)V

    .line 12
    .line 13
    .line 14
    new-instance p0, Lcom/kousei/framework/x8;

    .line 15
    .line 16
    invoke-direct {p0, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 17
    .line 18
    .line 19
    return-object p0
.end method

.method public final Q0(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/x8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/x8;->S:[I

    .line 8
    .line 9
    const/16 v1, 0x10

    .line 10
    .line 11
    new-array v1, v1, [I

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 14
    .line 15
    invoke-static {p0, p1, v1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 16
    .line 17
    .line 18
    invoke-static {v1, v0}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 19
    .line 20
    .line 21
    new-instance p0, Lcom/kousei/framework/x8;

    .line 22
    .line 23
    invoke-direct {p0, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 24
    .line 25
    .line 26
    return-object p0
.end method

.method public final R(Lcom/kousei/framework/h0;)Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/x8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/x8;->S:[I

    .line 8
    .line 9
    sget-object v1, Lcom/kousei/framework/h0;->F:[I

    .line 10
    .line 11
    invoke-static {v1, p1, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 12
    .line 13
    .line 14
    const/16 p1, 0x10

    .line 15
    .line 16
    new-array p1, p1, [I

    .line 17
    .line 18
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 19
    .line 20
    invoke-static {v0, p0, p1}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 21
    .line 22
    .line 23
    invoke-static {p1, v0}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 24
    .line 25
    .line 26
    new-instance p0, Lcom/kousei/framework/x8;

    .line 27
    .line 28
    invoke-direct {p0, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 29
    .line 30
    .line 31
    return-object p0
.end method

.method public final W1()Lcom/kousei/framework/h0;
    .registers 12

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 2
    .line 3
    invoke-static {v0}, Lcom/kousei/framework/n6;->q0([I)Z

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    if-nez v1, :cond_c0

    .line 8
    .line 9
    invoke-static {v0}, Lcom/kousei/framework/n6;->m0([I)Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_10

    .line 14
    .line 15
    goto/16 :goto_c0

    .line 16
    .line 17
    :cond_10
    const/16 p0, 0x10

    .line 18
    .line 19
    new-array p0, p0, [I

    .line 20
    .line 21
    const/16 v1, 0x8

    .line 22
    .line 23
    new-array v2, v1, [I

    .line 24
    .line 25
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 26
    .line 27
    .line 28
    invoke-static {p0, v2}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 29
    .line 30
    .line 31
    invoke-static {v2, v0, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 32
    .line 33
    .line 34
    invoke-static {p0, v2}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 35
    .line 36
    .line 37
    new-array v3, v1, [I

    .line 38
    .line 39
    invoke-static {v2, p0}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 40
    .line 41
    .line 42
    invoke-static {p0, v3}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 43
    .line 44
    .line 45
    invoke-static {v3, v0, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 46
    .line 47
    .line 48
    invoke-static {p0, v3}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 49
    .line 50
    .line 51
    new-array v4, v1, [I

    .line 52
    .line 53
    const/4 v5, 0x3

    .line 54
    invoke-static {v5, v3, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 55
    .line 56
    .line 57
    invoke-static {v4, v3, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 58
    .line 59
    .line 60
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 61
    .line 62
    .line 63
    invoke-static {v5, v4, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 64
    .line 65
    .line 66
    invoke-static {v4, v3, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 67
    .line 68
    .line 69
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 70
    .line 71
    .line 72
    const/4 v6, 0x2

    .line 73
    invoke-static {v6, v4, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 74
    .line 75
    .line 76
    invoke-static {v4, v2, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 77
    .line 78
    .line 79
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 80
    .line 81
    .line 82
    new-array v7, v1, [I

    .line 83
    .line 84
    const/16 v8, 0xb

    .line 85
    .line 86
    invoke-static {v8, v4, v7, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 87
    .line 88
    .line 89
    invoke-static {v7, v4, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 90
    .line 91
    .line 92
    invoke-static {p0, v7}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 93
    .line 94
    .line 95
    const/16 v8, 0x16

    .line 96
    .line 97
    invoke-static {v8, v7, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 98
    .line 99
    .line 100
    invoke-static {v4, v7, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 101
    .line 102
    .line 103
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 104
    .line 105
    .line 106
    new-array v8, v1, [I

    .line 107
    .line 108
    const/16 v9, 0x2c

    .line 109
    .line 110
    invoke-static {v9, v4, v8, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 111
    .line 112
    .line 113
    invoke-static {v8, v4, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 114
    .line 115
    .line 116
    invoke-static {p0, v8}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 117
    .line 118
    .line 119
    new-array v1, v1, [I

    .line 120
    .line 121
    const/16 v10, 0x58

    .line 122
    .line 123
    invoke-static {v10, v8, v1, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 124
    .line 125
    .line 126
    invoke-static {v1, v8, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 127
    .line 128
    .line 129
    invoke-static {p0, v1}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 130
    .line 131
    .line 132
    invoke-static {v9, v1, v8, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 133
    .line 134
    .line 135
    invoke-static {v8, v4, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 136
    .line 137
    .line 138
    invoke-static {p0, v8}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 139
    .line 140
    .line 141
    invoke-static {v5, v8, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 142
    .line 143
    .line 144
    invoke-static {v4, v3, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 145
    .line 146
    .line 147
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 148
    .line 149
    .line 150
    const/16 v1, 0x17

    .line 151
    .line 152
    invoke-static {v1, v4, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 153
    .line 154
    .line 155
    invoke-static {v4, v7, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 156
    .line 157
    .line 158
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 159
    .line 160
    .line 161
    const/4 v1, 0x6

    .line 162
    invoke-static {v1, v4, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 163
    .line 164
    .line 165
    invoke-static {v4, v2, p0}, Lcom/kousei/framework/n6;->x0([I[I[I)V

    .line 166
    .line 167
    .line 168
    invoke-static {p0, v4}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 169
    .line 170
    .line 171
    invoke-static {v6, v4, v4, p0}, Lcom/kousei/framework/h0;->n2(I[I[I[I)V

    .line 172
    .line 173
    .line 174
    invoke-static {v4, p0}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 175
    .line 176
    .line 177
    invoke-static {p0, v2}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 178
    .line 179
    .line 180
    invoke-static {v0, v2}, Lcom/kousei/framework/n6;->E([I[I)Z

    .line 181
    .line 182
    .line 183
    move-result p0

    .line 184
    if-eqz p0, :cond_bf

    .line 185
    .line 186
    new-instance p0, Lcom/kousei/framework/x8;

    .line 187
    .line 188
    invoke-direct {p0, v4}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 189
    .line 190
    .line 191
    return-object p0

    .line 192
    :cond_bf
    const/4 p0, 0x0

    .line 193
    :cond_c0
    :goto_c0
    return-object p0
.end method

.method public final X1()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    const/16 v1, 0x10

    .line 6
    .line 7
    new-array v1, v1, [I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, v1}, Lcom/kousei/framework/n6;->S0([I[I)V

    .line 12
    .line 13
    .line 14
    invoke-static {v1, v0}, Lcom/kousei/framework/h0;->I1([I[I)V

    .line 15
    .line 16
    .line 17
    new-instance p0, Lcom/kousei/framework/x8;

    .line 18
    .line 19
    invoke-direct {p0, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 20
    .line 21
    .line 22
    return-object p0
.end method

.method public final Z2()Ljava/math/BigInteger;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/n6;->k1([I)Ljava/math/BigInteger;

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
    sget-object p0, Lcom/kousei/framework/x8;->T:Ljava/math/BigInteger;

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
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v1, v0, [I

    .line 4
    .line 5
    check-cast p1, Lcom/kousei/framework/x8;

    .line 6
    .line 7
    iget-object p1, p1, Lcom/kousei/framework/x8;->S:[I

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 10
    .line 11
    invoke-static {p0, p1, v1}, Lcom/kousei/framework/n6;->c([I[I[I)I

    .line 12
    .line 13
    .line 14
    move-result p0

    .line 15
    if-nez p0, :cond_1e

    .line 16
    .line 17
    const/4 p0, 0x7

    .line 18
    aget p0, v1, p0

    .line 19
    .line 20
    const/4 p1, -0x1

    .line 21
    if-ne p0, p1, :cond_23

    .line 22
    .line 23
    sget-object p0, Lcom/kousei/framework/h0;->F:[I

    .line 24
    .line 25
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 26
    .line 27
    .line 28
    move-result p0

    .line 29
    if-eqz p0, :cond_23

    .line 30
    .line 31
    :cond_1e
    const/16 p0, 0x3d1

    .line 32
    .line 33
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 34
    .line 35
    .line 36
    :cond_23
    new-instance p0, Lcom/kousei/framework/x8;

    .line 37
    .line 38
    invoke-direct {p0, v1}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 39
    .line 40
    .line 41
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
    instance-of v0, p1, Lcom/kousei/framework/x8;

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
    check-cast p1, Lcom/kousei/framework/x8;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/x8;->S:[I

    .line 16
    .line 17
    invoke-static {p0, p1}, Lcom/kousei/framework/n6;->E([I[I)Z

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
    sget-object v0, Lcom/kousei/framework/x8;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/math/BigInteger;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 8
    .line 9
    const/16 v1, 0x8

    .line 10
    .line 11
    invoke-static {v1, p0}, Lcom/kousei/framework/h0;->h0(I[I)I

    .line 12
    .line 13
    .line 14
    move-result p0

    .line 15
    xor-int/2addr p0, v0

    .line 16
    return p0
.end method

.method public final n1()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v1, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 6
    .line 7
    invoke-static {v0, p0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 8
    .line 9
    .line 10
    move-result v0

    .line 11
    sget-object v2, Lcom/kousei/framework/h0;->F:[I

    .line 12
    .line 13
    if-eqz v0, :cond_12

    .line 14
    .line 15
    invoke-static {v2, v2, v1}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 16
    .line 17
    .line 18
    goto :goto_15

    .line 19
    :cond_12
    invoke-static {v2, p0, v1}, Lcom/kousei/framework/n6;->d1([I[I[I)I

    .line 20
    .line 21
    .line 22
    :goto_15
    new-instance p0, Lcom/kousei/framework/x8;

    .line 23
    .line 24
    invoke-direct {p0, v1}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 25
    .line 26
    .line 27
    return-object p0
.end method

.method public final r()Lcom/kousei/framework/h0;
    .registers 4

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v1, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 6
    .line 7
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->f0(I[I[I)I

    .line 8
    .line 9
    .line 10
    move-result p0

    .line 11
    if-nez p0, :cond_1a

    .line 12
    .line 13
    const/4 p0, 0x7

    .line 14
    aget p0, v1, p0

    .line 15
    .line 16
    const/4 v2, -0x1

    .line 17
    if-ne p0, v2, :cond_1f

    .line 18
    .line 19
    sget-object p0, Lcom/kousei/framework/h0;->F:[I

    .line 20
    .line 21
    invoke-static {v1, p0}, Lcom/kousei/framework/n6;->O([I[I)Z

    .line 22
    .line 23
    .line 24
    move-result p0

    .line 25
    if-eqz p0, :cond_1f

    .line 26
    .line 27
    :cond_1a
    const/16 p0, 0x3d1

    .line 28
    .line 29
    invoke-static {v0, p0, v1}, Lcom/kousei/framework/n6;->d(II[I)V

    .line 30
    .line 31
    .line 32
    :cond_1f
    new-instance p0, Lcom/kousei/framework/x8;

    .line 33
    .line 34
    invoke-direct {p0, v1}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 35
    .line 36
    .line 37
    return-object p0
.end method

.method public final z0()Lcom/kousei/framework/h0;
    .registers 3

    .line 1
    const/16 v0, 0x8

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/x8;->S:[I

    .line 6
    .line 7
    sget-object v1, Lcom/kousei/framework/h0;->F:[I

    .line 8
    .line 9
    invoke-static {v1, p0, v0}, Lcom/kousei/framework/h0;->I([I[I[I)V

    .line 10
    .line 11
    .line 12
    new-instance p0, Lcom/kousei/framework/x8;

    .line 13
    .line 14
    invoke-direct {p0, v0}, Lcom/kousei/framework/x8;-><init>([I)V

    .line 15
    .line 16
    .line 17
    return-object p0
.end method
