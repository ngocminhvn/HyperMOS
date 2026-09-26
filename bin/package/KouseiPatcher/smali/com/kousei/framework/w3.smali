.class public Lcom/kousei/framework/w3;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/kousei/framework/o3;


# instance fields
.field public final e:Lcom/kousei/framework/v3;

.field public final f:Lcom/kousei/framework/d4;

.field public final g:Ljava/math/BigInteger;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/v3;Lcom/kousei/framework/d4;Ljava/math/BigInteger;[B)V
    .registers 7

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    const/4 v0, 0x0

    .line 5
    if-eqz p3, :cond_48

    .line 6
    .line 7
    iput-object p1, p0, Lcom/kousei/framework/w3;->e:Lcom/kousei/framework/v3;

    .line 8
    .line 9
    if-eqz p2, :cond_42

    .line 10
    .line 11
    iget-object v1, p2, Lcom/kousei/framework/d4;->a:Lcom/kousei/framework/v3;

    .line 12
    .line 13
    invoke-virtual {p1, v1}, Lcom/kousei/framework/v3;->e(Lcom/kousei/framework/v3;)Z

    .line 14
    .line 15
    .line 16
    move-result v1

    .line 17
    if-eqz v1, :cond_3c

    .line 18
    .line 19
    invoke-virtual {p1, p2}, Lcom/kousei/framework/v3;->i(Lcom/kousei/framework/d4;)Lcom/kousei/framework/d4;

    .line 20
    .line 21
    .line 22
    move-result-object p1

    .line 23
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->k()Lcom/kousei/framework/d4;

    .line 24
    .line 25
    .line 26
    move-result-object p1

    .line 27
    invoke-virtual {p1}, Lcom/kousei/framework/d4;->h()Z

    .line 28
    .line 29
    .line 30
    move-result p2

    .line 31
    if-nez p2, :cond_36

    .line 32
    .line 33
    const/4 p2, 0x0

    .line 34
    const/4 v1, 0x1

    .line 35
    invoke-virtual {p1, p2, v1}, Lcom/kousei/framework/d4;->g(ZZ)Z

    .line 36
    .line 37
    .line 38
    move-result p2

    .line 39
    if-eqz p2, :cond_30

    .line 40
    .line 41
    iput-object p1, p0, Lcom/kousei/framework/w3;->f:Lcom/kousei/framework/d4;

    .line 42
    .line 43
    iput-object p3, p0, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 44
    .line 45
    invoke-static {p4}, Lcom/kousei/framework/h0;->J([B)[B

    .line 46
    .line 47
    .line 48
    return-void

    .line 49
    :cond_30
    const-string p0, "Point not on curve"

    .line 50
    .line 51
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 52
    .line 53
    .line 54
    throw v0

    .line 55
    :cond_36
    const-string p0, "Point at infinity"

    .line 56
    .line 57
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 58
    .line 59
    .line 60
    throw v0

    .line 61
    :cond_3c
    const-string p0, "Point must be on the same curve"

    .line 62
    .line 63
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 64
    .line 65
    .line 66
    throw v0

    .line 67
    :cond_42
    const-string p0, "Point cannot be null"

    .line 68
    .line 69
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 70
    .line 71
    .line 72
    throw v0

    .line 73
    :cond_48
    const-string p0, "n"

    .line 74
    .line 75
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 76
    .line 77
    .line 78
    throw v0
.end method


# virtual methods
.method public final equals(Ljava/lang/Object;)Z
    .registers 6

    .line 1
    const/4 v0, 0x1

    .line 2
    if-ne p0, p1, :cond_4

    .line 3
    .line 4
    return v0

    .line 5
    :cond_4
    instance-of v1, p1, Lcom/kousei/framework/w3;

    .line 6
    .line 7
    const/4 v2, 0x0

    .line 8
    if-nez v1, :cond_a

    .line 9
    .line 10
    return v2

    .line 11
    :cond_a
    check-cast p1, Lcom/kousei/framework/w3;

    .line 12
    .line 13
    iget-object v1, p0, Lcom/kousei/framework/w3;->e:Lcom/kousei/framework/v3;

    .line 14
    .line 15
    iget-object v3, p1, Lcom/kousei/framework/w3;->e:Lcom/kousei/framework/v3;

    .line 16
    .line 17
    invoke-virtual {v1, v3}, Lcom/kousei/framework/v3;->e(Lcom/kousei/framework/v3;)Z

    .line 18
    .line 19
    .line 20
    move-result v1

    .line 21
    if-eqz v1, :cond_2b

    .line 22
    .line 23
    iget-object v1, p0, Lcom/kousei/framework/w3;->f:Lcom/kousei/framework/d4;

    .line 24
    .line 25
    iget-object v3, p1, Lcom/kousei/framework/w3;->f:Lcom/kousei/framework/d4;

    .line 26
    .line 27
    invoke-virtual {v1, v3}, Lcom/kousei/framework/d4;->c(Lcom/kousei/framework/d4;)Z

    .line 28
    .line 29
    .line 30
    move-result v1

    .line 31
    if-eqz v1, :cond_2b

    .line 32
    .line 33
    iget-object p0, p0, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 34
    .line 35
    iget-object p1, p1, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 36
    .line 37
    invoke-virtual {p0, p1}, Ljava/math/BigInteger;->equals(Ljava/lang/Object;)Z

    .line 38
    .line 39
    .line 40
    move-result p0

    .line 41
    if-eqz p0, :cond_2b

    .line 42
    .line 43
    return v0

    .line 44
    :cond_2b
    return v2
.end method

.method public final hashCode()I
    .registers 3

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/w3;->e:Lcom/kousei/framework/v3;

    .line 2
    .line 3
    invoke-virtual {v0}, Lcom/kousei/framework/v3;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    const/16 v1, 0x404

    .line 8
    .line 9
    xor-int/2addr v0, v1

    .line 10
    mul-int/lit16 v0, v0, 0x101

    .line 11
    .line 12
    iget-object v1, p0, Lcom/kousei/framework/w3;->f:Lcom/kousei/framework/d4;

    .line 13
    .line 14
    invoke-virtual {v1}, Lcom/kousei/framework/d4;->hashCode()I

    .line 15
    .line 16
    .line 17
    move-result v1

    .line 18
    xor-int/2addr v0, v1

    .line 19
    mul-int/lit16 v0, v0, 0x101

    .line 20
    .line 21
    iget-object p0, p0, Lcom/kousei/framework/w3;->g:Ljava/math/BigInteger;

    .line 22
    .line 23
    invoke-virtual {p0}, Ljava/math/BigInteger;->hashCode()I

    .line 24
    .line 25
    .line 26
    move-result p0

    .line 27
    xor-int/2addr p0, v0

    .line 28
    return p0
.end method
