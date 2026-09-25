.class public abstract Lcom/kousei/framework/v;
.super Lcom/kousei/framework/z;

# interfaces
.implements Lcom/kousei/framework/w;


# static fields
.field public static final b:Lcom/kousei/framework/d;

.field public static final c:[B


# instance fields
.field public final a:[B


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/d;

    .line 2
    .line 3
    const-class v1, Lcom/kousei/framework/v;

    .line 4
    .line 5
    const/16 v2, 0xe

    .line 6
    .line 7
    invoke-direct {v0, v1, v2}, Lcom/kousei/framework/d;-><init>(Ljava/lang/Class;I)V

    .line 8
    .line 9
    .line 10
    sput-object v0, Lcom/kousei/framework/v;->b:Lcom/kousei/framework/d;

    .line 11
    .line 12
    const/4 v0, 0x0

    .line 13
    new-array v0, v0, [B

    .line 14
    .line 15
    sput-object v0, Lcom/kousei/framework/v;->c:[B

    .line 16
    .line 17
    return-void
.end method

.method public constructor <init>([B)V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    if-eqz p1, :cond_8

    .line 5
    .line 6
    iput-object p1, p0, Lcom/kousei/framework/v;->a:[B

    .line 7
    .line 8
    return-void

    .line 9
    :cond_8
    const-string p0, "\'string\' cannot be null"

    .line 10
    .line 11
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 12
    .line 13
    .line 14
    const/4 p0, 0x0

    .line 15
    throw p0
.end method

.method public static r(Ljava/lang/Object;)Lcom/kousei/framework/v;
    .registers 4

    .line 1
    if-eqz p0, :cond_46

    .line 2
    .line 3
    instance-of v0, p0, Lcom/kousei/framework/v;

    .line 4
    .line 5
    if-eqz v0, :cond_7

    .line 6
    .line 7
    goto :goto_46

    .line 8
    :cond_7
    instance-of v0, p0, Lcom/kousei/framework/j;

    .line 9
    .line 10
    const/4 v1, 0x0

    .line 11
    if-eqz v0, :cond_1a

    .line 12
    .line 13
    move-object v0, p0

    .line 14
    check-cast v0, Lcom/kousei/framework/j;

    .line 15
    .line 16
    invoke-interface {v0}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 17
    .line 18
    .line 19
    move-result-object v0

    .line 20
    instance-of v2, v0, Lcom/kousei/framework/v;

    .line 21
    .line 22
    if-eqz v2, :cond_34

    .line 23
    .line 24
    check-cast v0, Lcom/kousei/framework/v;

    .line 25
    .line 26
    return-object v0

    .line 27
    :cond_1a
    instance-of v0, p0, [B

    .line 28
    .line 29
    if-eqz v0, :cond_34

    .line 30
    .line 31
    :try_start_1e
    sget-object v0, Lcom/kousei/framework/v;->b:Lcom/kousei/framework/d;

    .line 32
    .line 33
    check-cast p0, [B

    .line 34
    .line 35
    invoke-virtual {v0, p0}, Lcom/kousei/framework/d;->b([B)Lcom/kousei/framework/z;

    .line 36
    .line 37
    .line 38
    move-result-object p0

    .line 39
    check-cast p0, Lcom/kousei/framework/v;
    :try_end_28
    .catch Ljava/io/IOException; {:try_start_1e .. :try_end_28} :catch_29

    .line 40
    .line 41
    return-object p0

    .line 42
    :catch_29
    move-exception p0

    .line 43
    const-string v0, "failed to construct OCTET STRING from byte[]: "

    .line 44
    .line 45
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 46
    .line 47
    .line 48
    move-result-object p0

    .line 49
    invoke-static {p0, v0}, Lcom/kousei/framework/e;->d(Ljava/lang/Object;Ljava/lang/String;)V

    .line 50
    .line 51
    .line 52
    return-object v1

    .line 53
    :cond_34
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 54
    .line 55
    .line 56
    move-result-object p0

    .line 57
    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    .line 58
    .line 59
    .line 60
    move-result-object p0

    .line 61
    const-string v0, "illegal object in getInstance: "

    .line 62
    .line 63
    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 68
    .line 69
    .line 70
    return-object v1

    .line 71
    :cond_46
    :goto_46
    check-cast p0, Lcom/kousei/framework/v;

    .line 72
    .line 73
    return-object p0
.end method


# virtual methods
.method public final a()Ljava/io/InputStream;
    .registers 2

    .line 1
    new-instance v0, Ljava/io/ByteArrayInputStream;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 4
    .line 5
    invoke-direct {v0, p0}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    .line 6
    .line 7
    .line 8
    return-object v0
.end method

.method public final e()Lcom/kousei/framework/z;
    .registers 1

    .line 1
    return-object p0
.end method

.method public final hashCode()I
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/h0;->i0([B)I

    .line 4
    .line 5
    .line 6
    move-result p0

    .line 7
    return p0
.end method

.method public final i(Lcom/kousei/framework/z;)Z
    .registers 3

    .line 1
    instance-of v0, p1, Lcom/kousei/framework/v;

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
    check-cast p1, Lcom/kousei/framework/v;

    .line 8
    .line 9
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 10
    .line 11
    iget-object p1, p1, Lcom/kousei/framework/v;->a:[B

    .line 12
    .line 13
    invoke-static {p0, p1}, Ljava/util/Arrays;->equals([B[B)Z

    .line 14
    .line 15
    .line 16
    move-result p0

    .line 17
    return p0
.end method

.method public p()Lcom/kousei/framework/z;
    .registers 2

    .line 1
    new-instance v0, Lcom/kousei/framework/n2;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 4
    .line 5
    invoke-direct {v0, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 6
    .line 7
    .line 8
    return-object v0
.end method

.method public q()Lcom/kousei/framework/z;
    .registers 2

    .line 1
    new-instance v0, Lcom/kousei/framework/n2;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 4
    .line 5
    invoke-direct {v0, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 6
    .line 7
    .line 8
    return-object v0
.end method

.method public final toString()Ljava/lang/String;
    .registers 2

    .line 1
    sget-object v0, Lcom/kousei/framework/v4;->a:Lcom/kousei/framework/o4;

    .line 2
    .line 3
    iget-object p0, p0, Lcom/kousei/framework/v;->a:[B

    .line 4
    .line 5
    array-length v0, p0

    .line 6
    invoke-static {v0, p0}, Lcom/kousei/framework/v4;->b(I[B)[B

    .line 7
    .line 8
    .line 9
    move-result-object p0

    .line 10
    invoke-static {p0}, Lcom/kousei/framework/ja;->a([B)Ljava/lang/String;

    .line 11
    .line 12
    .line 13
    move-result-object p0

    .line 14
    const-string v0, "#"

    .line 15
    .line 16
    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 17
    .line 18
    .line 19
    move-result-object p0

    .line 20
    return-object p0
.end method
