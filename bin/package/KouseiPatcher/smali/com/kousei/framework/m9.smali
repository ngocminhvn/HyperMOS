.class public final Lcom/kousei/framework/m9;
.super Lcom/kousei/framework/q3;


# static fields
.field public static final h:[Lcom/kousei/framework/h0;


# instance fields
.field public final g:Lcom/kousei/framework/e4;


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/k9;

    .line 2
    .line 3
    sget-object v1, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-direct {v0, v1}, Lcom/kousei/framework/k9;-><init>(Ljava/math/BigInteger;)V

    .line 6
    .line 7
    .line 8
    const/4 v1, 0x1

    .line 9
    new-array v1, v1, [Lcom/kousei/framework/h0;

    .line 10
    .line 11
    const/4 v2, 0x0

    .line 12
    aput-object v0, v1, v2

    .line 13
    .line 14
    sput-object v1, Lcom/kousei/framework/m9;->h:[Lcom/kousei/framework/h0;

    .line 15
    .line 16
    return-void
.end method

.method public constructor <init>()V
    .registers 5

    .line 1
    const/4 v0, 0x7

    .line 2
    const/16 v1, 0xa3

    .line 3
    .line 4
    const/4 v2, 0x3

    .line 5
    const/4 v3, 0x6

    .line 6
    invoke-direct {p0, v1, v2, v3, v0}, Lcom/kousei/framework/q3;-><init>(IIII)V

    .line 7
    .line 8
    .line 9
    new-instance v0, Lcom/kousei/framework/e4;

    .line 10
    .line 11
    const/4 v1, 0x0

    .line 12
    invoke-direct {v0, p0, v1, v1, v3}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 13
    .line 14
    .line 15
    iput-object v0, p0, Lcom/kousei/framework/m9;->g:Lcom/kousei/framework/e4;

    .line 16
    .line 17
    new-instance v0, Ljava/math/BigInteger;

    .line 18
    .line 19
    const-string v1, "07B6882CAAEFA84F9554FF8428BD88E246D2782AE2"

    .line 20
    .line 21
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 22
    .line 23
    .line 24
    move-result-object v1

    .line 25
    const/4 v2, 0x1

    .line 26
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 27
    .line 28
    .line 29
    new-instance v1, Lcom/kousei/framework/k9;

    .line 30
    .line 31
    invoke-direct {v1, v0}, Lcom/kousei/framework/k9;-><init>(Ljava/math/BigInteger;)V

    .line 32
    .line 33
    .line 34
    iput-object v1, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 35
    .line 36
    new-instance v0, Ljava/math/BigInteger;

    .line 37
    .line 38
    const-string v1, "0713612DCDDCB40AAB946BDA29CA91F73AF958AFD9"

    .line 39
    .line 40
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 41
    .line 42
    .line 43
    move-result-object v1

    .line 44
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 45
    .line 46
    .line 47
    new-instance v1, Lcom/kousei/framework/k9;

    .line 48
    .line 49
    invoke-direct {v1, v0}, Lcom/kousei/framework/k9;-><init>(Ljava/math/BigInteger;)V

    .line 50
    .line 51
    .line 52
    iput-object v1, p0, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 53
    .line 54
    new-instance v0, Ljava/math/BigInteger;

    .line 55
    .line 56
    const-string v1, "03FFFFFFFFFFFFFFFFFFFF48AAB689C29CA710279B"

    .line 57
    .line 58
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 59
    .line 60
    .line 61
    move-result-object v1

    .line 62
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 63
    .line 64
    .line 65
    iput-object v0, p0, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 66
    .line 67
    const-wide/16 v0, 0x2

    .line 68
    .line 69
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 70
    .line 71
    .line 72
    move-result-object v0

    .line 73
    iput-object v0, p0, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 74
    .line 75
    iput v3, p0, Lcom/kousei/framework/v3;->f:I

    .line 76
    .line 77
    return-void
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 1

    .line 1
    new-instance p0, Lcom/kousei/framework/m9;

    .line 2
    .line 3
    invoke-direct {p0}, Lcom/kousei/framework/m9;-><init>()V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final b([Lcom/kousei/framework/d4;I)Lcom/kousei/framework/h0;
    .registers 8

    .line 1
    mul-int/lit8 v0, p2, 0x6

    .line 2
    .line 3
    new-array v0, v0, [J

    .line 4
    .line 5
    const/4 v1, 0x0

    .line 6
    move v2, v1

    .line 7
    :goto_6
    if-ge v1, p2, :cond_23

    .line 8
    .line 9
    aget-object v3, p1, v1

    .line 10
    .line 11
    iget-object v4, v3, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 12
    .line 13
    check-cast v4, Lcom/kousei/framework/k9;

    .line 14
    .line 15
    iget-object v4, v4, Lcom/kousei/framework/k9;->S:[J

    .line 16
    .line 17
    invoke-static {v2, v4, v0}, Lcom/kousei/framework/h0;->P(I[J[J)V

    .line 18
    .line 19
    .line 20
    add-int/lit8 v4, v2, 0x3

    .line 21
    .line 22
    iget-object v3, v3, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 23
    .line 24
    check-cast v3, Lcom/kousei/framework/k9;

    .line 25
    .line 26
    iget-object v3, v3, Lcom/kousei/framework/k9;->S:[J

    .line 27
    .line 28
    invoke-static {v4, v3, v0}, Lcom/kousei/framework/h0;->P(I[J[J)V

    .line 29
    .line 30
    .line 31
    add-int/lit8 v2, v2, 0x6

    .line 32
    .line 33
    add-int/lit8 v1, v1, 0x1

    .line 34
    .line 35
    goto :goto_6

    .line 36
    :cond_23
    new-instance p1, Lcom/kousei/framework/y1;

    .line 37
    .line 38
    const/16 v1, 0x13

    .line 39
    .line 40
    invoke-direct {p1, p0, p2, v0, v1}, Lcom/kousei/framework/y1;-><init>(Lcom/kousei/framework/v3;ILjava/lang/Object;I)V

    .line 41
    .line 42
    .line 43
    return-object p1
.end method

.method public final d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/e4;

    .line 2
    .line 3
    const/4 v1, 0x6

    .line 4
    invoke-direct {v0, p0, p1, p2, v1}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 5
    .line 6
    .line 7
    return-object v0
.end method

.method public final f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    new-instance p0, Lcom/kousei/framework/k9;

    .line 2
    .line 3
    invoke-direct {p0, p1}, Lcom/kousei/framework/k9;-><init>(Ljava/math/BigInteger;)V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final g()I
    .registers 1

    .line 1
    const/16 p0, 0xa3

    .line 2
    .line 3
    return p0
.end method

.method public final h()Lcom/kousei/framework/d4;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/m9;->g:Lcom/kousei/framework/e4;

    .line 2
    .line 3
    return-object p0
.end method

.method public final m(I)Z
    .registers 2

    .line 1
    const/4 p0, 0x6

    .line 2
    if-eq p1, p0, :cond_5

    .line 3
    .line 4
    const/4 p0, 0x0

    .line 5
    return p0

    .line 6
    :cond_5
    const/4 p0, 0x1

    .line 7
    return p0
.end method
