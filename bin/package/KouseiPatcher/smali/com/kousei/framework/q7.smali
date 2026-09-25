.class public final Lcom/kousei/framework/q7;
.super Ljava/lang/Object;


# instance fields
.field public a:Lcom/kousei/framework/r7;

.field public b:Lcom/kousei/framework/u7;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide/16 v0, 0x1

    .line 2
    .line 3
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 4
    .line 5
    .line 6
    return-void
.end method


# virtual methods
.method public final a(I[B)[B
    .registers 7

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/q7;->a:Lcom/kousei/framework/r7;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/q7;->b:Lcom/kousei/framework/u7;

    .line 4
    .line 5
    if-eqz p0, :cond_97

    .line 6
    .line 7
    invoke-virtual {v0}, Lcom/kousei/framework/r7;->a()I

    .line 8
    .line 9
    .line 10
    move-result p0

    .line 11
    const/4 v1, 0x1

    .line 12
    add-int/2addr p0, v1

    .line 13
    const-string v2, "input too large for RSA cipher."

    .line 14
    .line 15
    if-gt p1, p0, :cond_91

    .line 16
    .line 17
    invoke-virtual {v0}, Lcom/kousei/framework/r7;->a()I

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    add-int/2addr p0, v1

    .line 22
    if-ne p1, p0, :cond_22

    .line 23
    .line 24
    iget-boolean p0, v0, Lcom/kousei/framework/r7;->b:Z

    .line 25
    .line 26
    if-eqz p0, :cond_1c

    .line 27
    .line 28
    goto :goto_22

    .line 29
    :cond_1c
    new-instance p0, Lcom/kousei/framework/f3;

    .line 30
    .line 31
    invoke-direct {p0, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    .line 32
    .line 33
    .line 34
    throw p0

    .line 35
    :cond_22
    :goto_22
    array-length p0, p2

    .line 36
    const/4 v3, 0x0

    .line 37
    if-eq p1, p0, :cond_2c

    .line 38
    .line 39
    new-array p0, p1, [B

    .line 40
    .line 41
    invoke-static {p2, v3, p0, v3, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 42
    .line 43
    .line 44
    move-object p2, p0

    .line 45
    :cond_2c
    new-instance p0, Ljava/math/BigInteger;

    .line 46
    .line 47
    invoke-direct {p0, v1, p2}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 48
    .line 49
    .line 50
    iget-object p1, v0, Lcom/kousei/framework/r7;->a:Lcom/kousei/framework/u7;

    .line 51
    .line 52
    iget-object p1, p1, Lcom/kousei/framework/u7;->a:Ljava/math/BigInteger;

    .line 53
    .line 54
    invoke-virtual {p0, p1}, Ljava/math/BigInteger;->compareTo(Ljava/math/BigInteger;)I

    .line 55
    .line 56
    .line 57
    move-result p1

    .line 58
    if-gez p1, :cond_8b

    .line 59
    .line 60
    iget-object p1, v0, Lcom/kousei/framework/r7;->a:Lcom/kousei/framework/u7;

    .line 61
    .line 62
    iget-object p2, p1, Lcom/kousei/framework/u7;->b:Ljava/math/BigInteger;

    .line 63
    .line 64
    iget-object p1, p1, Lcom/kousei/framework/u7;->a:Ljava/math/BigInteger;

    .line 65
    .line 66
    invoke-virtual {p0, p2, p1}, Ljava/math/BigInteger;->modPow(Ljava/math/BigInteger;Ljava/math/BigInteger;)Ljava/math/BigInteger;

    .line 67
    .line 68
    .line 69
    move-result-object p0

    .line 70
    invoke-virtual {p0}, Ljava/math/BigInteger;->toByteArray()[B

    .line 71
    .line 72
    .line 73
    move-result-object p0

    .line 74
    iget-boolean p1, v0, Lcom/kousei/framework/r7;->b:Z

    .line 75
    .line 76
    if-eqz p1, :cond_75

    .line 77
    .line 78
    aget-byte p1, p0, v3

    .line 79
    .line 80
    if-nez p1, :cond_60

    .line 81
    .line 82
    array-length p1, p0

    .line 83
    invoke-virtual {v0}, Lcom/kousei/framework/r7;->b()I

    .line 84
    .line 85
    .line 86
    move-result p2

    .line 87
    if-le p1, p2, :cond_60

    .line 88
    .line 89
    array-length p1, p0

    .line 90
    sub-int/2addr p1, v1

    .line 91
    new-array p2, p1, [B

    .line 92
    .line 93
    invoke-static {p0, v1, p2, v3, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 94
    .line 95
    .line 96
    return-object p2

    .line 97
    :cond_60
    array-length p1, p0

    .line 98
    invoke-virtual {v0}, Lcom/kousei/framework/r7;->b()I

    .line 99
    .line 100
    .line 101
    move-result p2

    .line 102
    if-ge p1, p2, :cond_74

    .line 103
    .line 104
    invoke-virtual {v0}, Lcom/kousei/framework/r7;->b()I

    .line 105
    .line 106
    .line 107
    move-result p1

    .line 108
    new-array p2, p1, [B

    .line 109
    .line 110
    array-length v0, p0

    .line 111
    sub-int/2addr p1, v0

    .line 112
    array-length v0, p0

    .line 113
    invoke-static {p0, v3, p2, p1, v0}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 114
    .line 115
    .line 116
    return-object p2

    .line 117
    :cond_74
    return-object p0

    .line 118
    :cond_75
    aget-byte p1, p0, v3

    .line 119
    .line 120
    if-nez p1, :cond_81

    .line 121
    .line 122
    array-length p1, p0

    .line 123
    sub-int/2addr p1, v1

    .line 124
    new-array p2, p1, [B

    .line 125
    .line 126
    invoke-static {p0, v1, p2, v3, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 127
    .line 128
    .line 129
    goto :goto_87

    .line 130
    :cond_81
    array-length p1, p0

    .line 131
    new-array p2, p1, [B

    .line 132
    .line 133
    invoke-static {p0, v3, p2, v3, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 134
    .line 135
    .line 136
    :goto_87
    invoke-static {p0, v3}, Ljava/util/Arrays;->fill([BB)V

    .line 137
    .line 138
    .line 139
    return-object p2

    .line 140
    :cond_8b
    new-instance p0, Lcom/kousei/framework/f3;

    .line 141
    .line 142
    invoke-direct {p0, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    .line 143
    .line 144
    .line 145
    throw p0

    .line 146
    :cond_91
    new-instance p0, Lcom/kousei/framework/f3;

    .line 147
    .line 148
    invoke-direct {p0, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    .line 149
    .line 150
    .line 151
    throw p0

    .line 152
    :cond_97
    const-string p0, "RSA engine not initialised"

    .line 153
    .line 154
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 155
    .line 156
    .line 157
    const/4 p0, 0x0

    .line 158
    return-object p0
.end method
