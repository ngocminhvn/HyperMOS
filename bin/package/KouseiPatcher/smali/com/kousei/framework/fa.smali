.class public final Lcom/kousei/framework/fa;
.super Lcom/kousei/framework/q3;


# static fields
.field public static final h:[Lcom/kousei/framework/h0;

.field public static final i:Lcom/kousei/framework/ca;

.field public static final j:Lcom/kousei/framework/ca;


# instance fields
.field public final g:Lcom/kousei/framework/e4;


# direct methods
.method static constructor <clinit>()V
    .registers 4

    .line 1
    new-instance v0, Lcom/kousei/framework/ca;

    .line 2
    .line 3
    sget-object v1, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 4
    .line 5
    invoke-direct {v0, v1}, Lcom/kousei/framework/ca;-><init>(Ljava/math/BigInteger;)V

    .line 6
    .line 7
    .line 8
    const/4 v1, 0x1

    .line 9
    new-array v2, v1, [Lcom/kousei/framework/h0;

    .line 10
    .line 11
    const/4 v3, 0x0

    .line 12
    aput-object v0, v2, v3

    .line 13
    .line 14
    sput-object v2, Lcom/kousei/framework/fa;->h:[Lcom/kousei/framework/h0;

    .line 15
    .line 16
    new-instance v0, Lcom/kousei/framework/ca;

    .line 17
    .line 18
    new-instance v2, Ljava/math/BigInteger;

    .line 19
    .line 20
    const-string v3, "02F40E7E2221F295DE297117B7F3D62F5C6A97FFCB8CEFF1CD6BA8CE4A9A18AD84FFABBD8EFA59332BE7AD6756A66E294AFD185A78FF12AA520E4DE739BACA0C7FFEFF7F2955727A"

    .line 21
    .line 22
    invoke-static {v3}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 23
    .line 24
    .line 25
    move-result-object v3

    .line 26
    invoke-direct {v2, v1, v3}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 27
    .line 28
    .line 29
    invoke-direct {v0, v2}, Lcom/kousei/framework/ca;-><init>(Ljava/math/BigInteger;)V

    .line 30
    .line 31
    .line 32
    sput-object v0, Lcom/kousei/framework/fa;->i:Lcom/kousei/framework/ca;

    .line 33
    .line 34
    invoke-virtual {v0}, Lcom/kousei/framework/ca;->W1()Lcom/kousei/framework/h0;

    .line 35
    .line 36
    .line 37
    move-result-object v0

    .line 38
    check-cast v0, Lcom/kousei/framework/ca;

    .line 39
    .line 40
    sput-object v0, Lcom/kousei/framework/fa;->j:Lcom/kousei/framework/ca;

    .line 41
    .line 42
    return-void
.end method

.method public constructor <init>()V
    .registers 5

    .line 1
    const/4 v0, 0x5

    .line 2
    const/16 v1, 0xa

    .line 3
    .line 4
    const/16 v2, 0x23b

    .line 5
    .line 6
    const/4 v3, 0x2

    .line 7
    invoke-direct {p0, v2, v3, v0, v1}, Lcom/kousei/framework/q3;-><init>(IIII)V

    .line 8
    .line 9
    .line 10
    new-instance v0, Lcom/kousei/framework/e4;

    .line 11
    .line 12
    const/4 v1, 0x0

    .line 13
    const/16 v2, 0x12

    .line 14
    .line 15
    invoke-direct {v0, p0, v1, v1, v2}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 16
    .line 17
    .line 18
    iput-object v0, p0, Lcom/kousei/framework/fa;->g:Lcom/kousei/framework/e4;

    .line 19
    .line 20
    const-wide/16 v0, 0x1

    .line 21
    .line 22
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 23
    .line 24
    .line 25
    move-result-object v0

    .line 26
    new-instance v1, Lcom/kousei/framework/ca;

    .line 27
    .line 28
    invoke-direct {v1, v0}, Lcom/kousei/framework/ca;-><init>(Ljava/math/BigInteger;)V

    .line 29
    .line 30
    .line 31
    iput-object v1, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 32
    .line 33
    sget-object v0, Lcom/kousei/framework/fa;->i:Lcom/kousei/framework/ca;

    .line 34
    .line 35
    iput-object v0, p0, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 36
    .line 37
    new-instance v0, Ljava/math/BigInteger;

    .line 38
    .line 39
    const-string v1, "03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE661CE18FF55987308059B186823851EC7DD9CA1161DE93D5174D66E8382E9BB2FE84E47"

    .line 40
    .line 41
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 42
    .line 43
    .line 44
    move-result-object v1

    .line 45
    const/4 v2, 0x1

    .line 46
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 47
    .line 48
    .line 49
    iput-object v0, p0, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 50
    .line 51
    const-wide/16 v0, 0x2

    .line 52
    .line 53
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 54
    .line 55
    .line 56
    move-result-object v0

    .line 57
    iput-object v0, p0, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 58
    .line 59
    const/4 v0, 0x6

    .line 60
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 61
    .line 62
    return-void
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 1

    .line 1
    new-instance p0, Lcom/kousei/framework/fa;

    .line 2
    .line 3
    invoke-direct {p0}, Lcom/kousei/framework/fa;-><init>()V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final b([Lcom/kousei/framework/d4;I)Lcom/kousei/framework/h0;
    .registers 8

    .line 1
    mul-int/lit8 v0, p2, 0x12

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
    check-cast v4, Lcom/kousei/framework/ca;

    .line 14
    .line 15
    iget-object v4, v4, Lcom/kousei/framework/ca;->S:[J

    .line 16
    .line 17
    invoke-static {v2, v4, v0}, Lcom/kousei/framework/n6;->z(I[J[J)V

    .line 18
    .line 19
    .line 20
    add-int/lit8 v4, v2, 0x9

    .line 21
    .line 22
    iget-object v3, v3, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 23
    .line 24
    check-cast v3, Lcom/kousei/framework/ca;

    .line 25
    .line 26
    iget-object v3, v3, Lcom/kousei/framework/ca;->S:[J

    .line 27
    .line 28
    invoke-static {v4, v3, v0}, Lcom/kousei/framework/n6;->z(I[J[J)V

    .line 29
    .line 30
    .line 31
    add-int/lit8 v2, v2, 0x12

    .line 32
    .line 33
    add-int/lit8 v1, v1, 0x1

    .line 34
    .line 35
    goto :goto_6

    .line 36
    :cond_23
    new-instance p1, Lcom/kousei/framework/da;

    .line 37
    .line 38
    const/4 v1, 0x1

    .line 39
    invoke-direct {p1, p0, p2, v0, v1}, Lcom/kousei/framework/da;-><init>(Lcom/kousei/framework/q3;I[JI)V

    .line 40
    .line 41
    .line 42
    return-object p1
.end method

.method public final d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/e4;

    .line 2
    .line 3
    const/16 v1, 0x12

    .line 4
    .line 5
    invoke-direct {v0, p0, p1, p2, v1}, Lcom/kousei/framework/e4;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 6
    .line 7
    .line 8
    return-object v0
.end method

.method public final f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    new-instance p0, Lcom/kousei/framework/ca;

    .line 2
    .line 3
    invoke-direct {p0, p1}, Lcom/kousei/framework/ca;-><init>(Ljava/math/BigInteger;)V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final g()I
    .registers 1

    .line 1
    const/16 p0, 0x23b

    .line 2
    .line 3
    return p0
.end method

.method public final h()Lcom/kousei/framework/d4;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/fa;->g:Lcom/kousei/framework/e4;

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
