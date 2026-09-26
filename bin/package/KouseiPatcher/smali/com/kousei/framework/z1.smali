.class public final Lcom/kousei/framework/z1;
.super Lcom/kousei/framework/r3;


# static fields
.field public static final h:Ljava/math/BigInteger;

.field public static final i:Ljava/math/BigInteger;

.field public static final j:Ljava/math/BigInteger;

.field public static final k:[Lcom/kousei/framework/h0;


# instance fields
.field public final g:Lcom/kousei/framework/b2;


# direct methods
.method static constructor <clinit>()V
    .registers 5

    .line 1
    sget-object v0, Lcom/kousei/framework/a2;->T:Ljava/math/BigInteger;

    .line 2
    .line 3
    sput-object v0, Lcom/kousei/framework/z1;->h:Ljava/math/BigInteger;

    .line 4
    .line 5
    new-instance v0, Ljava/math/BigInteger;

    .line 6
    .line 7
    const-string v1, "2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA984914A144"

    .line 8
    .line 9
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    const/4 v2, 0x1

    .line 14
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 15
    .line 16
    .line 17
    sput-object v0, Lcom/kousei/framework/z1;->i:Ljava/math/BigInteger;

    .line 18
    .line 19
    new-instance v1, Ljava/math/BigInteger;

    .line 20
    .line 21
    const-string v3, "7B425ED097B425ED097B425ED097B425ED097B425ED097B4260B5E9C7710C864"

    .line 22
    .line 23
    invoke-static {v3}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 24
    .line 25
    .line 26
    move-result-object v3

    .line 27
    invoke-direct {v1, v2, v3}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 28
    .line 29
    .line 30
    sput-object v1, Lcom/kousei/framework/z1;->j:Ljava/math/BigInteger;

    .line 31
    .line 32
    new-instance v1, Lcom/kousei/framework/a2;

    .line 33
    .line 34
    sget-object v3, Lcom/kousei/framework/o3;->b:Ljava/math/BigInteger;

    .line 35
    .line 36
    invoke-direct {v1, v3}, Lcom/kousei/framework/a2;-><init>(Ljava/math/BigInteger;)V

    .line 37
    .line 38
    .line 39
    new-instance v3, Lcom/kousei/framework/a2;

    .line 40
    .line 41
    invoke-direct {v3, v0}, Lcom/kousei/framework/a2;-><init>(Ljava/math/BigInteger;)V

    .line 42
    .line 43
    .line 44
    const/4 v0, 0x2

    .line 45
    new-array v0, v0, [Lcom/kousei/framework/h0;

    .line 46
    .line 47
    const/4 v4, 0x0

    .line 48
    aput-object v1, v0, v4

    .line 49
    .line 50
    aput-object v3, v0, v2

    .line 51
    .line 52
    sput-object v0, Lcom/kousei/framework/z1;->k:[Lcom/kousei/framework/h0;

    .line 53
    .line 54
    return-void
.end method

.method public constructor <init>()V
    .registers 4

    .line 1
    sget-object v0, Lcom/kousei/framework/z1;->h:Ljava/math/BigInteger;

    .line 2
    .line 3
    invoke-direct {p0, v0}, Lcom/kousei/framework/r3;-><init>(Ljava/math/BigInteger;)V

    .line 4
    .line 5
    .line 6
    new-instance v0, Lcom/kousei/framework/b2;

    .line 7
    .line 8
    const/4 v1, 0x0

    .line 9
    const/4 v2, 0x0

    .line 10
    invoke-direct {v0, p0, v1, v1, v2}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 11
    .line 12
    .line 13
    iput-object v0, p0, Lcom/kousei/framework/z1;->g:Lcom/kousei/framework/b2;

    .line 14
    .line 15
    new-instance v0, Lcom/kousei/framework/a2;

    .line 16
    .line 17
    sget-object v1, Lcom/kousei/framework/z1;->i:Ljava/math/BigInteger;

    .line 18
    .line 19
    invoke-direct {v0, v1}, Lcom/kousei/framework/a2;-><init>(Ljava/math/BigInteger;)V

    .line 20
    .line 21
    .line 22
    iput-object v0, p0, Lcom/kousei/framework/v3;->b:Lcom/kousei/framework/h0;

    .line 23
    .line 24
    new-instance v0, Lcom/kousei/framework/a2;

    .line 25
    .line 26
    sget-object v1, Lcom/kousei/framework/z1;->j:Ljava/math/BigInteger;

    .line 27
    .line 28
    invoke-direct {v0, v1}, Lcom/kousei/framework/a2;-><init>(Ljava/math/BigInteger;)V

    .line 29
    .line 30
    .line 31
    iput-object v0, p0, Lcom/kousei/framework/v3;->c:Lcom/kousei/framework/h0;

    .line 32
    .line 33
    new-instance v0, Ljava/math/BigInteger;

    .line 34
    .line 35
    const-string v1, "1000000000000000000000000000000014DEF9DEA2F79CD65812631A5CF5D3ED"

    .line 36
    .line 37
    invoke-static {v1}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    const/4 v2, 0x1

    .line 42
    invoke-direct {v0, v2, v1}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 43
    .line 44
    .line 45
    iput-object v0, p0, Lcom/kousei/framework/v3;->d:Ljava/math/BigInteger;

    .line 46
    .line 47
    const-wide/16 v0, 0x8

    .line 48
    .line 49
    invoke-static {v0, v1}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 50
    .line 51
    .line 52
    move-result-object v0

    .line 53
    iput-object v0, p0, Lcom/kousei/framework/v3;->e:Ljava/math/BigInteger;

    .line 54
    .line 55
    const/4 v0, 0x4

    .line 56
    iput v0, p0, Lcom/kousei/framework/v3;->f:I

    .line 57
    .line 58
    return-void
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/v3;
    .registers 1

    .line 1
    new-instance p0, Lcom/kousei/framework/z1;

    .line 2
    .line 3
    invoke-direct {p0}, Lcom/kousei/framework/z1;-><init>()V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final b([Lcom/kousei/framework/d4;I)Lcom/kousei/framework/h0;
    .registers 9

    .line 1
    mul-int/lit8 v0, p2, 0x10

    .line 2
    .line 3
    new-array v0, v0, [I

    .line 4
    .line 5
    const/4 v1, 0x0

    .line 6
    move v2, v1

    .line 7
    move v3, v2

    .line 8
    :goto_7
    if-ge v2, p2, :cond_24

    .line 9
    .line 10
    aget-object v4, p1, v2

    .line 11
    .line 12
    iget-object v5, v4, Lcom/kousei/framework/d4;->b:Lcom/kousei/framework/h0;

    .line 13
    .line 14
    check-cast v5, Lcom/kousei/framework/a2;

    .line 15
    .line 16
    iget-object v5, v5, Lcom/kousei/framework/a2;->S:[I

    .line 17
    .line 18
    invoke-static {v3, v5, v0}, Lcom/kousei/framework/n6;->u(I[I[I)V

    .line 19
    .line 20
    .line 21
    add-int/lit8 v5, v3, 0x8

    .line 22
    .line 23
    iget-object v4, v4, Lcom/kousei/framework/d4;->c:Lcom/kousei/framework/h0;

    .line 24
    .line 25
    check-cast v4, Lcom/kousei/framework/a2;

    .line 26
    .line 27
    iget-object v4, v4, Lcom/kousei/framework/a2;->S:[I

    .line 28
    .line 29
    invoke-static {v5, v4, v0}, Lcom/kousei/framework/n6;->u(I[I[I)V

    .line 30
    .line 31
    .line 32
    add-int/lit8 v3, v3, 0x10

    .line 33
    .line 34
    add-int/lit8 v2, v2, 0x1

    .line 35
    .line 36
    goto :goto_7

    .line 37
    :cond_24
    new-instance p1, Lcom/kousei/framework/y1;

    .line 38
    .line 39
    invoke-direct {p1, p0, p2, v0, v1}, Lcom/kousei/framework/y1;-><init>(Lcom/kousei/framework/v3;ILjava/lang/Object;I)V

    .line 40
    .line 41
    .line 42
    return-object p1
.end method

.method public final d(Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;)Lcom/kousei/framework/d4;
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/b2;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    invoke-direct {v0, p0, p1, p2, v1}, Lcom/kousei/framework/b2;-><init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/h0;Lcom/kousei/framework/h0;I)V

    .line 5
    .line 6
    .line 7
    return-object v0
.end method

.method public final f(Ljava/math/BigInteger;)Lcom/kousei/framework/h0;
    .registers 2

    .line 1
    new-instance p0, Lcom/kousei/framework/a2;

    .line 2
    .line 3
    invoke-direct {p0, p1}, Lcom/kousei/framework/a2;-><init>(Ljava/math/BigInteger;)V

    .line 4
    .line 5
    .line 6
    return-object p0
.end method

.method public final g()I
    .registers 1

    .line 1
    sget-object p0, Lcom/kousei/framework/z1;->h:Ljava/math/BigInteger;

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

.method public final h()Lcom/kousei/framework/d4;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/z1;->g:Lcom/kousei/framework/b2;

    .line 2
    .line 3
    return-object p0
.end method

.method public final l(Ljava/security/SecureRandom;)Lcom/kousei/framework/h0;
    .registers 7

    .line 1
    const/16 p0, 0x8

    .line 2
    .line 3
    new-array v0, p0, [I

    .line 4
    .line 5
    :cond_4
    const/16 v1, 0x20

    .line 6
    .line 7
    new-array v1, v1, [B

    .line 8
    .line 9
    :cond_8
    invoke-virtual {p1, v1}, Ljava/security/SecureRandom;->nextBytes([B)V

    .line 10
    .line 11
    .line 12
    invoke-static {v1, v0, p0}, Lcom/kousei/framework/n6;->u0([B[II)V

    .line 13
    .line 14
    .line 15
    const/4 v2, 0x7

    .line 16
    aget v3, v0, v2

    .line 17
    .line 18
    const v4, 0x7fffffff

    .line 19
    .line 20
    .line 21
    and-int/2addr v3, v4

    .line 22
    aput v3, v0, v2

    .line 23
    .line 24
    sget-object v2, Lcom/kousei/framework/h0;->f:[I

    .line 25
    .line 26
    invoke-static {p0, v0, v2}, Lcom/kousei/framework/n6;->t0(I[I[I)I

    .line 27
    .line 28
    .line 29
    move-result v2

    .line 30
    if-eqz v2, :cond_8

    .line 31
    .line 32
    invoke-static {p0, v0}, Lcom/kousei/framework/n6;->G(I[I)I

    .line 33
    .line 34
    .line 35
    move-result v1

    .line 36
    if-nez v1, :cond_4

    .line 37
    .line 38
    new-instance p0, Lcom/kousei/framework/a2;

    .line 39
    .line 40
    invoke-direct {p0, v0}, Lcom/kousei/framework/a2;-><init>([I)V

    .line 41
    .line 42
    .line 43
    return-object p0
.end method

.method public final m(I)Z
    .registers 2

    .line 1
    const/4 p0, 0x4

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

.method public final n()Ljava/math/BigInteger;
    .registers 1

    .line 1
    sget-object p0, Lcom/kousei/framework/z1;->h:Ljava/math/BigInteger;

    .line 2
    .line 3
    return-object p0
.end method
