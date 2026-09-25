.class public final Lcom/kousei/framework/n5;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"

# interfaces
.implements Ljava/util/Comparator;


# virtual methods
.method public final compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .registers 5

    .line 1
    check-cast p1, Lcom/kousei/framework/p5;

    .line 2
    .line 3
    check-cast p2, Lcom/kousei/framework/p5;

    .line 4
    .line 5
    if-nez p1, :cond_a

    .line 6
    .line 7
    if-nez p2, :cond_a

    .line 8
    .line 9
    const/4 p0, 0x0

    .line 10
    return p0

    .line 11
    :cond_a
    if-nez p1, :cond_e

    .line 12
    .line 13
    const/4 p0, 0x1

    .line 14
    return p0

    .line 15
    :cond_e
    if-nez p2, :cond_12

    .line 16
    .line 17
    const/4 p0, -0x1

    .line 18
    return p0

    .line 19
    :cond_12
    iget-object p0, p1, Lcom/kousei/framework/p5;->b:Ljava/lang/String;

    .line 20
    .line 21
    if-eqz p0, :cond_17

    .line 22
    .line 23
    goto :goto_20

    .line 24
    :cond_17
    const-wide v0, -0xb1890dbb5469L

    .line 25
    .line 26
    .line 27
    .line 28
    .line 29
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 30
    .line 31
    .line 32
    move-result-object p0

    .line 33
    :goto_20
    iget-object v0, p2, Lcom/kousei/framework/p5;->b:Ljava/lang/String;

    .line 34
    .line 35
    if-eqz v0, :cond_25

    .line 36
    .line 37
    goto :goto_2e

    .line 38
    :cond_25
    const-wide v0, -0xb1880dbb5469L

    .line 39
    .line 40
    .line 41
    .line 42
    .line 43
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 44
    .line 45
    .line 46
    move-result-object v0

    .line 47
    :goto_2e
    invoke-virtual {p0, v0}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    .line 48
    .line 49
    .line 50
    move-result p0

    .line 51
    if-eqz p0, :cond_35

    .line 52
    .line 53
    return p0

    .line 54
    :cond_35
    iget-object p0, p1, Lcom/kousei/framework/p5;->a:Ljava/lang/String;

    .line 55
    .line 56
    if-eqz p0, :cond_3a

    .line 57
    .line 58
    goto :goto_43

    .line 59
    :cond_3a
    const-wide p0, -0xb18b0dbb5469L

    .line 60
    .line 61
    .line 62
    .line 63
    .line 64
    invoke-static {p0, p1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 65
    .line 66
    .line 67
    move-result-object p0

    .line 68
    :goto_43
    iget-object p1, p2, Lcom/kousei/framework/p5;->a:Ljava/lang/String;

    .line 69
    .line 70
    if-eqz p1, :cond_48

    .line 71
    .line 72
    goto :goto_51

    .line 73
    :cond_48
    const-wide p1, -0xb18a0dbb5469L

    .line 74
    .line 75
    .line 76
    .line 77
    .line 78
    invoke-static {p1, p2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 79
    .line 80
    .line 81
    move-result-object p1

    .line 82
    :goto_51
    invoke-virtual {p0, p1}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    .line 83
    .line 84
    .line 85
    move-result p0

    .line 86
    return p0
.end method
