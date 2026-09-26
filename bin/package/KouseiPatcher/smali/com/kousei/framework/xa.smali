.class public final Lcom/kousei/framework/xa;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/io/Serializable;


# instance fields
.field public final transient a:Lcom/kousei/framework/h1;

.field public final transient b:Lcom/kousei/framework/j4;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/h1;)V
    .registers 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 76
    iput-object p1, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    .line 77
    iget-object p1, p1, Lcom/kousei/framework/h1;->b:Lcom/kousei/framework/la;

    .line 78
    iget-object p1, p1, Lcom/kousei/framework/la;->k:Lcom/kousei/framework/j4;

    .line 79
    iput-object p1, p0, Lcom/kousei/framework/xa;->b:Lcom/kousei/framework/j4;

    return-void
.end method

.method public constructor <init>([B)V
    .registers 6

    .line 1
    const-string v0, "malformed data: "

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    :try_start_3
    sget v2, Lcom/kousei/framework/g1;->a:I

    .line 5
    .line 6
    invoke-static {p1}, Lcom/kousei/framework/z;->o([B)Lcom/kousei/framework/z;

    .line 7
    .line 8
    .line 9
    move-result-object p1

    .line 10
    if-eqz p1, :cond_17

    .line 11
    .line 12
    invoke-static {p1}, Lcom/kousei/framework/h1;->i(Lcom/kousei/framework/z;)Lcom/kousei/framework/h1;

    .line 13
    .line 14
    .line 15
    move-result-object p1
    :try_end_f
    .catch Ljava/lang/ClassCastException; {:try_start_3 .. :try_end_f} :catch_15
    .catch Ljava/lang/IllegalArgumentException; {:try_start_3 .. :try_end_f} :catch_13

    .line 16
    invoke-direct {p0, p1}, Lcom/kousei/framework/xa;-><init>(Lcom/kousei/framework/h1;)V

    .line 17
    .line 18
    .line 19
    return-void

    .line 20
    :catch_13
    move-exception p0

    .line 21
    goto :goto_1f

    .line 22
    :catch_15
    move-exception p0

    .line 23
    goto :goto_35

    .line 24
    :cond_17
    :try_start_17
    new-instance p0, Ljava/io/IOException;

    .line 25
    .line 26
    const-string p1, "no content found"

    .line 27
    .line 28
    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 29
    .line 30
    .line 31
    throw p0
    :try_end_1f
    .catch Ljava/lang/ClassCastException; {:try_start_17 .. :try_end_1f} :catch_15
    .catch Ljava/lang/IllegalArgumentException; {:try_start_17 .. :try_end_1f} :catch_13

    .line 32
    :goto_1f
    new-instance p1, Lcom/kousei/framework/m;

    .line 33
    .line 34
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 35
    .line 36
    .line 37
    move-result-object v2

    .line 38
    new-instance v3, Ljava/lang/StringBuilder;

    .line 39
    .line 40
    invoke-direct {v3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 41
    .line 42
    .line 43
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 44
    .line 45
    .line 46
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 47
    .line 48
    .line 49
    move-result-object v0

    .line 50
    invoke-direct {p1, v0, p0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 51
    .line 52
    .line 53
    throw p1

    .line 54
    :goto_35
    new-instance p1, Lcom/kousei/framework/m;

    .line 55
    .line 56
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 57
    .line 58
    .line 59
    move-result-object v2

    .line 60
    new-instance v3, Ljava/lang/StringBuilder;

    .line 61
    .line 62
    invoke-direct {v3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 63
    .line 64
    .line 65
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 66
    .line 67
    .line 68
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 69
    .line 70
    .line 71
    move-result-object v0

    .line 72
    invoke-direct {p1, v0, p0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 73
    .line 74
    .line 75
    throw p1
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/u;)Lcom/kousei/framework/i4;
    .registers 2

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/xa;->b:Lcom/kousei/framework/j4;

    .line 2
    .line 3
    if-eqz p0, :cond_d

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 6
    .line 7
    invoke-virtual {p0, p1}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 8
    .line 9
    .line 10
    move-result-object p0

    .line 11
    check-cast p0, Lcom/kousei/framework/i4;

    .line 12
    .line 13
    return-object p0

    .line 14
    :cond_d
    const/4 p0, 0x0

    .line 15
    return-object p0
.end method

.method public final b()Lcom/kousei/framework/va;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/h1;->b:Lcom/kousei/framework/la;

    .line 4
    .line 5
    iget-object p0, p0, Lcom/kousei/framework/la;->g:Lcom/kousei/framework/va;

    .line 6
    .line 7
    invoke-static {p0}, Lcom/kousei/framework/va;->i(Ljava/lang/Object;)Lcom/kousei/framework/va;

    .line 8
    .line 9
    .line 10
    move-result-object p0

    .line 11
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
    instance-of v0, p1, Lcom/kousei/framework/xa;

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
    check-cast p1, Lcom/kousei/framework/xa;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    .line 14
    .line 15
    iget-object p1, p1, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    .line 16
    .line 17
    invoke-virtual {p0, p1}, Lcom/kousei/framework/r;->equals(Ljava/lang/Object;)Z

    .line 18
    .line 19
    .line 20
    move-result p0

    .line 21
    return p0
.end method

.method public final hashCode()I
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/xa;->a:Lcom/kousei/framework/h1;

    .line 2
    .line 3
    invoke-virtual {p0}, Lcom/kousei/framework/r;->hashCode()I

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method
