.class public final Lcom/kousei/framework/y0;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/kousei/framework/j;
.implements Lcom/kousei/framework/h5;


# instance fields
.field public final synthetic a:I

.field public b:Lcom/kousei/framework/e0;


# direct methods
.method public synthetic constructor <init>(I)V
    .registers 2

    .line 10
    iput p1, p0, Lcom/kousei/framework/y0;->a:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/e0;)V
    .registers 3

    .line 1
    const/4 v0, 0x2

    .line 2
    iput v0, p0, Lcom/kousei/framework/y0;->a:I

    .line 3
    .line 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 5
    .line 6
    .line 7
    iput-object p1, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 8
    .line 9
    return-void
.end method


# virtual methods
.method public final b()Lcom/kousei/framework/z;
    .registers 4

    .line 1
    iget v0, p0, Lcom/kousei/framework/y0;->a:I

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    const/4 v2, 0x0

    .line 5
    packed-switch v0, :pswitch_data_68

    .line 6
    .line 7
    .line 8
    :try_start_7
    invoke-virtual {p0}, Lcom/kousei/framework/y0;->e()Lcom/kousei/framework/z;

    .line 9
    .line 10
    .line 11
    move-result-object p0
    :try_end_b
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_b} :catch_c

    .line 12
    return-object p0

    .line 13
    :catch_c
    move-exception p0

    .line 14
    new-instance v0, Lcom/kousei/framework/y;

    .line 15
    .line 16
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 17
    .line 18
    .line 19
    move-result-object v1

    .line 20
    invoke-direct {v0, v1, p0, v2}, Lcom/kousei/framework/y;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 21
    .line 22
    .line 23
    throw v0

    .line 24
    :pswitch_17
    :try_start_17
    invoke-virtual {p0}, Lcom/kousei/framework/y0;->e()Lcom/kousei/framework/z;

    .line 25
    .line 26
    .line 27
    move-result-object v1
    :try_end_1b
    .catch Ljava/io/IOException; {:try_start_17 .. :try_end_1b} :catch_1c

    .line 28
    goto :goto_24

    .line 29
    :catch_1c
    move-exception p0

    .line 30
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 31
    .line 32
    .line 33
    move-result-object p0

    .line 34
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 35
    .line 36
    .line 37
    :goto_24
    return-object v1

    .line 38
    :pswitch_25
    const-string v0, "unable to get DER object"

    .line 39
    .line 40
    :try_start_27
    invoke-virtual {p0}, Lcom/kousei/framework/y0;->e()Lcom/kousei/framework/z;

    .line 41
    .line 42
    .line 43
    move-result-object p0
    :try_end_2b
    .catch Ljava/io/IOException; {:try_start_27 .. :try_end_2b} :catch_33
    .catch Ljava/lang/IllegalArgumentException; {:try_start_27 .. :try_end_2b} :catch_2c

    .line 44
    return-object p0

    .line 45
    :catch_2c
    move-exception p0

    .line 46
    new-instance v1, Lcom/kousei/framework/y;

    .line 47
    .line 48
    invoke-direct {v1, v0, p0, v2}, Lcom/kousei/framework/y;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 49
    .line 50
    .line 51
    throw v1

    .line 52
    :catch_33
    move-exception p0

    .line 53
    new-instance v1, Lcom/kousei/framework/y;

    .line 54
    .line 55
    invoke-direct {v1, v0, p0, v2}, Lcom/kousei/framework/y;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 56
    .line 57
    .line 58
    throw v1

    .line 59
    :pswitch_3a
    :try_start_3a
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 60
    .line 61
    new-instance v0, Lcom/kousei/framework/z0;

    .line 62
    .line 63
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    invoke-direct {v0, p0, v2}, Lcom/kousei/framework/d0;-><init>(Lcom/kousei/framework/k;Z)V
    :try_end_45
    .catch Ljava/io/IOException; {:try_start_3a .. :try_end_45} :catch_46

    .line 68
    .line 69
    .line 70
    return-object v0

    .line 71
    :catch_46
    move-exception p0

    .line 72
    new-instance v0, Lcom/kousei/framework/y;

    .line 73
    .line 74
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 75
    .line 76
    .line 77
    move-result-object v1

    .line 78
    invoke-direct {v0, v1, p0, v2}, Lcom/kousei/framework/y;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 79
    .line 80
    .line 81
    throw v0

    .line 82
    :pswitch_51
    :try_start_51
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 83
    .line 84
    new-instance v0, Lcom/kousei/framework/x0;

    .line 85
    .line 86
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 87
    .line 88
    .line 89
    move-result-object p0

    .line 90
    invoke-direct {v0, p0}, Lcom/kousei/framework/c0;-><init>(Lcom/kousei/framework/k;)V
    :try_end_5c
    .catch Ljava/io/IOException; {:try_start_51 .. :try_end_5c} :catch_5e

    .line 91
    .line 92
    .line 93
    move-object v1, v0

    .line 94
    goto :goto_66

    .line 95
    :catch_5e
    move-exception p0

    .line 96
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 97
    .line 98
    .line 99
    move-result-object p0

    .line 100
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 101
    .line 102
    .line 103
    :goto_66
    return-object v1

    .line 104
    nop

    .line 105
    :pswitch_data_68
    .packed-switch 0x0
        :pswitch_51
        :pswitch_3a
        :pswitch_25
        :pswitch_17
    .end packed-switch
.end method

.method public final e()Lcom/kousei/framework/z;
    .registers 4

    .line 1
    iget v0, p0, Lcom/kousei/framework/y0;->a:I

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    packed-switch v0, :pswitch_data_52

    .line 5
    .line 6
    .line 7
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 8
    .line 9
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 10
    .line 11
    .line 12
    move-result-object p0

    .line 13
    invoke-static {p0}, Lcom/kousei/framework/a3;->b(Lcom/kousei/framework/k;)Lcom/kousei/framework/r2;

    .line 14
    .line 15
    .line 16
    move-result-object p0

    .line 17
    return-object p0

    .line 18
    :pswitch_11
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 19
    .line 20
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 21
    .line 22
    .line 23
    move-result-object p0

    .line 24
    invoke-static {p0}, Lcom/kousei/framework/a3;->a(Lcom/kousei/framework/k;)Lcom/kousei/framework/q2;

    .line 25
    .line 26
    .line 27
    move-result-object p0

    .line 28
    return-object p0

    .line 29
    :pswitch_1c
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 30
    .line 31
    new-instance v0, Lcom/kousei/framework/q2;

    .line 32
    .line 33
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 34
    .line 35
    .line 36
    move-result-object p0

    .line 37
    const/4 v2, 0x1

    .line 38
    invoke-direct {v0, p0, v2}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/k;I)V

    .line 39
    .line 40
    .line 41
    const/4 p0, -0x1

    .line 42
    iput p0, v0, Lcom/kousei/framework/q2;->d:I

    .line 43
    .line 44
    :try_start_2b
    new-instance p0, Lcom/kousei/framework/g2;

    .line 45
    .line 46
    invoke-direct {p0, v0, v2}, Lcom/kousei/framework/g2;-><init>(Lcom/kousei/framework/c0;I)V
    :try_end_30
    .catch Ljava/lang/IllegalArgumentException; {:try_start_2b .. :try_end_30} :catch_31

    .line 47
    .line 48
    .line 49
    return-object p0

    .line 50
    :catch_31
    move-exception p0

    .line 51
    new-instance v0, Lcom/kousei/framework/m;

    .line 52
    .line 53
    const-string v2, "corrupted stream detected"

    .line 54
    .line 55
    invoke-direct {v0, v2, p0, v1}, Lcom/kousei/framework/m;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 56
    .line 57
    .line 58
    throw v0

    .line 59
    :pswitch_3a
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 60
    .line 61
    new-instance v0, Lcom/kousei/framework/z0;

    .line 62
    .line 63
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 64
    .line 65
    .line 66
    move-result-object p0

    .line 67
    invoke-direct {v0, p0, v1}, Lcom/kousei/framework/d0;-><init>(Lcom/kousei/framework/k;Z)V

    .line 68
    .line 69
    .line 70
    return-object v0

    .line 71
    :pswitch_46
    iget-object p0, p0, Lcom/kousei/framework/y0;->b:Lcom/kousei/framework/e0;

    .line 72
    .line 73
    new-instance v0, Lcom/kousei/framework/x0;

    .line 74
    .line 75
    invoke-virtual {p0}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 76
    .line 77
    .line 78
    move-result-object p0

    .line 79
    invoke-direct {v0, p0}, Lcom/kousei/framework/c0;-><init>(Lcom/kousei/framework/k;)V

    .line 80
    .line 81
    .line 82
    return-object v0

    .line 83
    :pswitch_data_52
    .packed-switch 0x0
        :pswitch_46
        :pswitch_3a
        :pswitch_1c
        :pswitch_11
    .end packed-switch
.end method
