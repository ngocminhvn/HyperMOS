.class public final Lcom/kousei/framework/qa;
.super Lcom/kousei/framework/r;

# interfaces
.implements Lcom/kousei/framework/i;


# instance fields
.field public final a:Lcom/kousei/framework/z;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/z;)V
    .registers 3

    .line 80
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 81
    instance-of v0, p1, Lcom/kousei/framework/g0;

    if-nez v0, :cond_13

    instance-of v0, p1, Lcom/kousei/framework/n;

    if-eqz v0, :cond_c

    goto :goto_13

    :cond_c
    const-string p0, "unknown object passed to Time"

    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    const/4 p0, 0x0

    throw p0

    :cond_13
    :goto_13
    iput-object p1, p0, Lcom/kousei/framework/qa;->a:Lcom/kousei/framework/z;

    return-void
.end method

.method public constructor <init>(Ljava/util/Date;)V
    .registers 8

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    new-instance v0, Ljava/util/SimpleTimeZone;

    .line 5
    .line 6
    const/4 v1, 0x0

    .line 7
    const-string v2, "Z"

    .line 8
    .line 9
    invoke-direct {v0, v1, v2}, Ljava/util/SimpleTimeZone;-><init>(ILjava/lang/String;)V

    .line 10
    .line 11
    .line 12
    new-instance v3, Ljava/text/SimpleDateFormat;

    .line 13
    .line 14
    const-string v4, "yyyyMMddHHmmss"

    .line 15
    .line 16
    sget-object v5, Lcom/kousei/framework/f6;->a:Ljava/util/Locale;

    .line 17
    .line 18
    invoke-direct {v3, v4, v5}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    .line 19
    .line 20
    .line 21
    invoke-virtual {v3, v0}, Ljava/text/DateFormat;->setTimeZone(Ljava/util/TimeZone;)V

    .line 22
    .line 23
    .line 24
    new-instance v0, Ljava/lang/StringBuilder;

    .line 25
    .line 26
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 27
    .line 28
    .line 29
    invoke-virtual {v3, p1}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    .line 30
    .line 31
    .line 32
    move-result-object p1

    .line 33
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 34
    .line 35
    .line 36
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 37
    .line 38
    .line 39
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object p1

    .line 43
    const/4 v0, 0x4

    .line 44
    invoke-virtual {p1, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 45
    .line 46
    .line 47
    move-result-object v0

    .line 48
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 49
    .line 50
    .line 51
    move-result v0

    .line 52
    const/16 v1, 0x79e

    .line 53
    .line 54
    if-lt v0, v1, :cond_49

    .line 55
    .line 56
    const/16 v1, 0x801

    .line 57
    .line 58
    if-le v0, v1, :cond_3c

    .line 59
    .line 60
    goto :goto_49

    .line 61
    :cond_3c
    new-instance v0, Lcom/kousei/framework/t2;

    .line 62
    .line 63
    const/4 v1, 0x2

    .line 64
    invoke-virtual {p1, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    .line 65
    .line 66
    .line 67
    move-result-object p1

    .line 68
    invoke-direct {v0, p1}, Lcom/kousei/framework/g0;-><init>(Ljava/lang/String;)V

    .line 69
    .line 70
    .line 71
    :goto_46
    iput-object v0, p0, Lcom/kousei/framework/qa;->a:Lcom/kousei/framework/z;

    .line 72
    .line 73
    return-void

    .line 74
    :cond_49
    :goto_49
    new-instance v0, Lcom/kousei/framework/i2;

    .line 75
    .line 76
    invoke-direct {v0, p1}, Lcom/kousei/framework/n;-><init>(Ljava/lang/String;)V

    .line 77
    .line 78
    .line 79
    goto :goto_46
.end method

.method public static j(Lcom/kousei/framework/j;)Lcom/kousei/framework/qa;
    .registers 2

    .line 1
    if-eqz p0, :cond_32

    .line 2
    .line 3
    instance-of v0, p0, Lcom/kousei/framework/qa;

    .line 4
    .line 5
    if-eqz v0, :cond_7

    .line 6
    .line 7
    goto :goto_32

    .line 8
    :cond_7
    instance-of v0, p0, Lcom/kousei/framework/g0;

    .line 9
    .line 10
    if-eqz v0, :cond_13

    .line 11
    .line 12
    new-instance v0, Lcom/kousei/framework/qa;

    .line 13
    .line 14
    check-cast p0, Lcom/kousei/framework/g0;

    .line 15
    .line 16
    invoke-direct {v0, p0}, Lcom/kousei/framework/qa;-><init>(Lcom/kousei/framework/z;)V

    .line 17
    .line 18
    .line 19
    return-object v0

    .line 20
    :cond_13
    instance-of v0, p0, Lcom/kousei/framework/n;

    .line 21
    .line 22
    if-eqz v0, :cond_1f

    .line 23
    .line 24
    new-instance v0, Lcom/kousei/framework/qa;

    .line 25
    .line 26
    check-cast p0, Lcom/kousei/framework/n;

    .line 27
    .line 28
    invoke-direct {v0, p0}, Lcom/kousei/framework/qa;-><init>(Lcom/kousei/framework/z;)V

    .line 29
    .line 30
    .line 31
    return-object v0

    .line 32
    :cond_1f
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 33
    .line 34
    .line 35
    move-result-object p0

    .line 36
    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    .line 37
    .line 38
    .line 39
    move-result-object p0

    .line 40
    const-string v0, "unknown object in factory: "

    .line 41
    .line 42
    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 43
    .line 44
    .line 45
    move-result-object p0

    .line 46
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 47
    .line 48
    .line 49
    const/4 p0, 0x0

    .line 50
    return-object p0

    .line 51
    :cond_32
    :goto_32
    check-cast p0, Lcom/kousei/framework/qa;

    .line 52
    .line 53
    return-object p0
.end method


# virtual methods
.method public final b()Lcom/kousei/framework/z;
    .registers 1

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/qa;->a:Lcom/kousei/framework/z;

    .line 2
    .line 3
    return-object p0
.end method

.method public final i()Ljava/util/Date;
    .registers 5

    .line 1
    :try_start_0
    iget-object p0, p0, Lcom/kousei/framework/qa;->a:Lcom/kousei/framework/z;

    .line 2
    .line 3
    instance-of v0, p0, Lcom/kousei/framework/g0;

    .line 4
    .line 5
    if-eqz v0, :cond_37

    .line 6
    .line 7
    check-cast p0, Lcom/kousei/framework/g0;

    .line 8
    .line 9
    new-instance v0, Ljava/text/SimpleDateFormat;

    .line 10
    .line 11
    const-string v1, "yyyyMMddHHmmssz"

    .line 12
    .line 13
    sget-object v2, Lcom/kousei/framework/f6;->a:Ljava/util/Locale;

    .line 14
    .line 15
    invoke-direct {v0, v1, v2}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    .line 16
    .line 17
    .line 18
    new-instance v1, Ljava/util/SimpleTimeZone;

    .line 19
    .line 20
    const-string v2, "Z"

    .line 21
    .line 22
    const/4 v3, 0x0

    .line 23
    invoke-direct {v1, v3, v2}, Ljava/util/SimpleTimeZone;-><init>(ILjava/lang/String;)V

    .line 24
    .line 25
    .line 26
    invoke-virtual {v0, v1}, Ljava/text/DateFormat;->setTimeZone(Ljava/util/TimeZone;)V

    .line 27
    .line 28
    .line 29
    invoke-virtual {p0}, Lcom/kousei/framework/g0;->r()Ljava/lang/String;

    .line 30
    .line 31
    .line 32
    move-result-object p0

    .line 33
    invoke-virtual {p0, v3}, Ljava/lang/String;->charAt(I)C

    .line 34
    .line 35
    .line 36
    move-result v1

    .line 37
    const/16 v2, 0x35

    .line 38
    .line 39
    if-ge v1, v2, :cond_2f

    .line 40
    .line 41
    const-string v1, "20"

    .line 42
    .line 43
    :goto_2a
    invoke-virtual {v1, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 44
    .line 45
    .line 46
    move-result-object p0

    .line 47
    goto :goto_32

    .line 48
    :cond_2f
    const-string v1, "19"

    .line 49
    .line 50
    goto :goto_2a

    .line 51
    :goto_32
    invoke-virtual {v0, p0}, Ljava/text/DateFormat;->parse(Ljava/lang/String;)Ljava/util/Date;

    .line 52
    .line 53
    .line 54
    move-result-object p0

    .line 55
    return-object p0

    .line 56
    :cond_37
    check-cast p0, Lcom/kousei/framework/n;

    .line 57
    .line 58
    invoke-virtual {p0}, Lcom/kousei/framework/n;->t()Ljava/util/Date;

    .line 59
    .line 60
    .line 61
    move-result-object p0
    :try_end_3d
    .catch Ljava/text/ParseException; {:try_start_0 .. :try_end_3d} :catch_3e

    .line 62
    return-object p0

    .line 63
    :catch_3e
    move-exception p0

    .line 64
    new-instance v0, Ljava/lang/IllegalStateException;

    .line 65
    .line 66
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 67
    .line 68
    .line 69
    move-result-object p0

    .line 70
    new-instance v1, Ljava/lang/StringBuilder;

    .line 71
    .line 72
    const-string v2, "invalid date string: "

    .line 73
    .line 74
    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 75
    .line 76
    .line 77
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 78
    .line 79
    .line 80
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 81
    .line 82
    .line 83
    move-result-object p0

    .line 84
    invoke-direct {v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 85
    .line 86
    .line 87
    throw v0
.end method

.method public final toString()Ljava/lang/String;
    .registers 3

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/qa;->a:Lcom/kousei/framework/z;

    .line 2
    .line 3
    instance-of v0, p0, Lcom/kousei/framework/g0;

    .line 4
    .line 5
    if-eqz v0, :cond_23

    .line 6
    .line 7
    check-cast p0, Lcom/kousei/framework/g0;

    .line 8
    .line 9
    invoke-virtual {p0}, Lcom/kousei/framework/g0;->r()Ljava/lang/String;

    .line 10
    .line 11
    .line 12
    move-result-object p0

    .line 13
    const/4 v0, 0x0

    .line 14
    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    .line 15
    .line 16
    .line 17
    move-result v0

    .line 18
    const/16 v1, 0x35

    .line 19
    .line 20
    if-ge v0, v1, :cond_1c

    .line 21
    .line 22
    const-string v0, "20"

    .line 23
    .line 24
    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object p0

    .line 28
    return-object p0

    .line 29
    :cond_1c
    const-string v0, "19"

    .line 30
    .line 31
    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    .line 32
    .line 33
    .line 34
    move-result-object p0

    .line 35
    return-object p0

    .line 36
    :cond_23
    check-cast p0, Lcom/kousei/framework/n;

    .line 37
    .line 38
    invoke-virtual {p0}, Lcom/kousei/framework/n;->u()Ljava/lang/String;

    .line 39
    .line 40
    .line 41
    move-result-object p0

    .line 42
    return-object p0
.end method
