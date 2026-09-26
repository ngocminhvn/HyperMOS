.class public final Lcom/kousei/framework/w0;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/kousei/framework/w;


# instance fields
.field public final synthetic a:I

.field public b:Ljava/lang/Object;


# direct methods
.method public synthetic constructor <init>()V
    .registers 2

    .line 10
    const/4 v0, 0x1

    iput v0, p0, Lcom/kousei/framework/w0;->a:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/e0;)V
    .registers 3

    .line 1
    const/4 v0, 0x0

    .line 2
    iput v0, p0, Lcom/kousei/framework/w0;->a:I

    .line 3
    .line 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 5
    .line 6
    .line 7
    iput-object p1, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 8
    .line 9
    return-void
.end method


# virtual methods
.method public final a()Ljava/io/InputStream;
    .registers 2

    .line 1
    iget v0, p0, Lcom/kousei/framework/w0;->a:I

    .line 2
    .line 3
    packed-switch v0, :pswitch_data_14

    .line 4
    .line 5
    .line 6
    iget-object p0, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 7
    .line 8
    check-cast p0, Lcom/kousei/framework/j3;

    .line 9
    .line 10
    return-object p0

    .line 11
    :pswitch_a
    new-instance v0, Lcom/kousei/framework/p1;

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 14
    .line 15
    check-cast p0, Lcom/kousei/framework/e0;

    .line 16
    .line 17
    invoke-direct {v0, p0}, Lcom/kousei/framework/p1;-><init>(Lcom/kousei/framework/e0;)V

    .line 18
    .line 19
    .line 20
    return-object v0

    .line 21
    :pswitch_data_14
    .packed-switch 0x0
        :pswitch_a
    .end packed-switch
.end method

.method public final b()Lcom/kousei/framework/z;
    .registers 9

    .line 1
    iget v0, p0, Lcom/kousei/framework/w0;->a:I

    .line 2
    .line 3
    const-string v1, "IOException converting stream to byte array: "

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    packed-switch v0, :pswitch_data_48

    .line 7
    .line 8
    .line 9
    :try_start_8
    invoke-virtual {p0}, Lcom/kousei/framework/w0;->e()Lcom/kousei/framework/z;

    .line 10
    .line 11
    .line 12
    move-result-object v2
    :try_end_c
    .catch Ljava/io/IOException; {:try_start_8 .. :try_end_c} :catch_d

    .line 13
    goto :goto_15

    .line 14
    :catch_d
    move-exception p0

    .line 15
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 16
    .line 17
    .line 18
    move-result-object v0

    .line 19
    invoke-static {v1, v0, p0}, Lcom/kousei/framework/e;->f(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Exception;)V

    .line 20
    .line 21
    .line 22
    :goto_15
    return-object v2

    .line 23
    :pswitch_16
    :try_start_16
    iget-object p0, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 24
    .line 25
    check-cast p0, Lcom/kousei/framework/e0;

    .line 26
    .line 27
    new-instance v0, Lcom/kousei/framework/v0;

    .line 28
    .line 29
    new-instance v3, Lcom/kousei/framework/p1;

    .line 30
    .line 31
    invoke-direct {v3, p0}, Lcom/kousei/framework/p1;-><init>(Lcom/kousei/framework/e0;)V

    .line 32
    .line 33
    .line 34
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    .line 35
    .line 36
    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 37
    .line 38
    .line 39
    const/16 v4, 0x1000

    .line 40
    .line 41
    new-array v5, v4, [B

    .line 42
    .line 43
    :goto_2a
    const/4 v6, 0x0

    .line 44
    invoke-virtual {v3, v5, v6, v4}, Lcom/kousei/framework/p1;->read([BII)I

    .line 45
    .line 46
    .line 47
    move-result v7

    .line 48
    if-ltz v7, :cond_35

    .line 49
    .line 50
    invoke-virtual {p0, v5, v6, v7}, Ljava/io/OutputStream;->write([BII)V

    .line 51
    .line 52
    .line 53
    goto :goto_2a

    .line 54
    :cond_35
    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    .line 55
    .line 56
    .line 57
    move-result-object p0

    .line 58
    invoke-direct {v0, p0, v2}, Lcom/kousei/framework/v0;-><init>([B[Lcom/kousei/framework/v;)V
    :try_end_3c
    .catch Ljava/io/IOException; {:try_start_16 .. :try_end_3c} :catch_3e

    .line 59
    .line 60
    .line 61
    move-object v2, v0

    .line 62
    goto :goto_46

    .line 63
    :catch_3e
    move-exception p0

    .line 64
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 65
    .line 66
    .line 67
    move-result-object v0

    .line 68
    invoke-static {v1, v0, p0}, Lcom/kousei/framework/e;->f(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Exception;)V

    .line 69
    .line 70
    .line 71
    :goto_46
    return-object v2

    .line 72
    nop

    .line 73
    :pswitch_data_48
    .packed-switch 0x0
        :pswitch_16
    .end packed-switch
.end method

.method public final e()Lcom/kousei/framework/z;
    .registers 7

    .line 1
    iget v0, p0, Lcom/kousei/framework/w0;->a:I

    .line 2
    .line 3
    packed-switch v0, :pswitch_data_3c

    .line 4
    .line 5
    .line 6
    new-instance v0, Lcom/kousei/framework/n2;

    .line 7
    .line 8
    iget-object p0, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 9
    .line 10
    check-cast p0, Lcom/kousei/framework/j3;

    .line 11
    .line 12
    invoke-virtual {p0}, Lcom/kousei/framework/j3;->b()[B

    .line 13
    .line 14
    .line 15
    move-result-object p0

    .line 16
    invoke-direct {v0, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 17
    .line 18
    .line 19
    return-object v0

    .line 20
    :pswitch_13
    iget-object p0, p0, Lcom/kousei/framework/w0;->b:Ljava/lang/Object;

    .line 21
    .line 22
    check-cast p0, Lcom/kousei/framework/e0;

    .line 23
    .line 24
    new-instance v0, Lcom/kousei/framework/v0;

    .line 25
    .line 26
    new-instance v1, Lcom/kousei/framework/p1;

    .line 27
    .line 28
    invoke-direct {v1, p0}, Lcom/kousei/framework/p1;-><init>(Lcom/kousei/framework/e0;)V

    .line 29
    .line 30
    .line 31
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    .line 32
    .line 33
    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 34
    .line 35
    .line 36
    const/16 v2, 0x1000

    .line 37
    .line 38
    new-array v3, v2, [B

    .line 39
    .line 40
    :goto_27
    const/4 v4, 0x0

    .line 41
    invoke-virtual {v1, v3, v4, v2}, Lcom/kousei/framework/p1;->read([BII)I

    .line 42
    .line 43
    .line 44
    move-result v5

    .line 45
    if-ltz v5, :cond_32

    .line 46
    .line 47
    invoke-virtual {p0, v3, v4, v5}, Ljava/io/OutputStream;->write([BII)V

    .line 48
    .line 49
    .line 50
    goto :goto_27

    .line 51
    :cond_32
    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    .line 52
    .line 53
    .line 54
    move-result-object p0

    .line 55
    const/4 v1, 0x0

    .line 56
    invoke-direct {v0, p0, v1}, Lcom/kousei/framework/v0;-><init>([B[Lcom/kousei/framework/v;)V

    .line 57
    .line 58
    .line 59
    return-object v0

    .line 60
    nop

    .line 61
    :pswitch_data_3c
    .packed-switch 0x0
        :pswitch_13
    .end packed-switch
.end method
