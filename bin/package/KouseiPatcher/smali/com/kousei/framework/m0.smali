.class public final Lcom/kousei/framework/m0;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# instance fields
.field public final a:Lcom/kousei/framework/u5;

.field public final b:Lcom/kousei/framework/w6;

.field public final c:Ljava/lang/Object;

.field public final d:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Lcom/kousei/framework/m0;[Ljava/lang/String;)V
    .registers 12

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    const/4 v0, 0x0

    .line 5
    if-eqz p1, :cond_7

    .line 6
    .line 7
    goto :goto_1d

    .line 8
    :cond_7
    new-instance p1, Lcom/kousei/framework/m0;

    .line 9
    .line 10
    new-instance v1, Lcom/kousei/framework/x6;

    .line 11
    .line 12
    sget-object v2, Ljava/util/Collections;->EMPTY_MAP:Ljava/util/Map;

    .line 13
    .line 14
    sget-object v3, Ljava/util/Collections;->EMPTY_SET:Ljava/util/Set;

    .line 15
    .line 16
    const/4 v7, 0x0

    .line 17
    sget-object v8, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 18
    .line 19
    const/4 v4, 0x0

    .line 20
    const/4 v6, 0x0

    .line 21
    move-object v5, v2

    .line 22
    invoke-direct/range {v1 .. v8}, Lcom/kousei/framework/x6;-><init>(Ljava/util/Map;Ljava/util/Set;Lcom/kousei/framework/v6;Ljava/util/Map;ZZLcom/kousei/framework/ma;)V

    .line 23
    .line 24
    .line 25
    sget-object v2, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 26
    .line 27
    invoke-direct {p1, v1, v2, v0, v0}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/x6;Lcom/kousei/framework/u5;Ljava/lang/String;Lcom/kousei/framework/w6;)V

    .line 28
    .line 29
    .line 30
    :goto_1d
    iput-object p1, p0, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 31
    .line 32
    iget-object v1, p1, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 33
    .line 34
    if-eqz v1, :cond_24

    .line 35
    .line 36
    goto :goto_26

    .line 37
    :cond_24
    sget-object v1, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    .line 38
    .line 39
    :goto_26
    iput-object v1, p0, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 40
    .line 41
    iget-object p1, p1, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 42
    .line 43
    check-cast p1, Lcom/kousei/framework/x6;

    .line 44
    .line 45
    const/4 v1, 0x0

    .line 46
    if-eqz p2, :cond_6e

    .line 47
    .line 48
    array-length v2, p2

    .line 49
    if-lez v2, :cond_6e

    .line 50
    .line 51
    iget-object v2, p1, Lcom/kousei/framework/x6;->d:Ljava/util/Map;

    .line 52
    .line 53
    invoke-interface {v2}, Ljava/util/Map;->isEmpty()Z

    .line 54
    .line 55
    .line 56
    move-result v2

    .line 57
    if-nez v2, :cond_6e

    .line 58
    .line 59
    invoke-static {p2}, Ljava/util/Arrays;->stream([Ljava/lang/Object;)Ljava/util/stream/Stream;

    .line 60
    .line 61
    .line 62
    move-result-object v2

    .line 63
    new-instance v3, Lcom/kousei/framework/y6;

    .line 64
    .line 65
    invoke-direct {v3}, Ljava/lang/Object;-><init>()V

    .line 66
    .line 67
    .line 68
    invoke-interface {v2, v3}, Ljava/util/stream/Stream;->filter(Ljava/util/function/Predicate;)Ljava/util/stream/Stream;

    .line 69
    .line 70
    .line 71
    move-result-object v2

    .line 72
    invoke-interface {v2}, Ljava/util/stream/Stream;->distinct()Ljava/util/stream/Stream;

    .line 73
    .line 74
    .line 75
    move-result-object v2

    .line 76
    invoke-interface {v2}, Ljava/util/stream/Stream;->sorted()Ljava/util/stream/Stream;

    .line 77
    .line 78
    .line 79
    move-result-object v2

    .line 80
    new-instance v3, Lcom/kousei/framework/z6;

    .line 81
    .line 82
    invoke-direct {v3}, Ljava/lang/Object;-><init>()V

    .line 83
    .line 84
    .line 85
    invoke-interface {v2, v3}, Ljava/util/stream/Stream;->toArray(Ljava/util/function/IntFunction;)[Ljava/lang/Object;

    .line 86
    .line 87
    .line 88
    move-result-object v2

    .line 89
    check-cast v2, [Ljava/lang/String;

    .line 90
    .line 91
    array-length v3, v2

    .line 92
    move v4, v1

    .line 93
    :goto_5c
    if-ge v4, v3, :cond_6e

    .line 94
    .line 95
    aget-object v5, v2, v4

    .line 96
    .line 97
    iget-object v6, p1, Lcom/kousei/framework/x6;->d:Ljava/util/Map;

    .line 98
    .line 99
    invoke-interface {v6, v5}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 100
    .line 101
    .line 102
    move-result-object v5

    .line 103
    check-cast v5, Lcom/kousei/framework/v6;

    .line 104
    .line 105
    if-eqz v5, :cond_6b

    .line 106
    .line 107
    goto :goto_70

    .line 108
    :cond_6b
    add-int/lit8 v4, v4, 0x1

    .line 109
    .line 110
    goto :goto_5c

    .line 111
    :cond_6e
    iget-object v5, p1, Lcom/kousei/framework/x6;->c:Lcom/kousei/framework/v6;

    .line 112
    .line 113
    :goto_70
    iput-object v5, p0, Lcom/kousei/framework/m0;->d:Ljava/lang/Object;

    .line 114
    .line 115
    iget-object p1, p0, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 116
    .line 117
    check-cast p1, Lcom/kousei/framework/m0;

    .line 118
    .line 119
    iget-object v2, p1, Lcom/kousei/framework/m0;->b:Lcom/kousei/framework/w6;

    .line 120
    .line 121
    if-eqz p2, :cond_a1

    .line 122
    .line 123
    array-length v3, p2

    .line 124
    if-eqz v3, :cond_a1

    .line 125
    .line 126
    if-nez v2, :cond_80

    .line 127
    .line 128
    goto :goto_a1

    .line 129
    :cond_80
    iget-object p1, p1, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 130
    .line 131
    check-cast p1, Lcom/kousei/framework/x6;

    .line 132
    .line 133
    iget-object p1, p1, Lcom/kousei/framework/x6;->b:Ljava/util/Set;

    .line 134
    .line 135
    if-eqz p1, :cond_a1

    .line 136
    .line 137
    invoke-interface {p1}, Ljava/util/Set;->isEmpty()Z

    .line 138
    .line 139
    .line 140
    move-result v3

    .line 141
    if-eqz v3, :cond_8f

    .line 142
    .line 143
    goto :goto_a1

    .line 144
    :cond_8f
    array-length v3, p2

    .line 145
    :goto_90
    if-ge v1, v3, :cond_a1

    .line 146
    .line 147
    aget-object v4, p2, v1

    .line 148
    .line 149
    if-eqz v4, :cond_9e

    .line 150
    .line 151
    invoke-interface {p1, v4}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    .line 152
    .line 153
    .line 154
    move-result v4

    .line 155
    if-eqz v4, :cond_9e

    .line 156
    .line 157
    move-object v0, v2

    .line 158
    goto :goto_a1

    .line 159
    :cond_9e
    add-int/lit8 v1, v1, 0x1

    .line 160
    .line 161
    goto :goto_90

    .line 162
    :cond_a1
    :goto_a1
    iput-object v0, p0, Lcom/kousei/framework/m0;->b:Lcom/kousei/framework/w6;

    .line 163
    .line 164
    return-void
.end method

.method public constructor <init>(Lcom/kousei/framework/x6;Lcom/kousei/framework/u5;Ljava/lang/String;Lcom/kousei/framework/w6;)V
    .registers 5

    .line 165
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 166
    iput-object p1, p0, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    if-eqz p2, :cond_8

    goto :goto_a

    .line 167
    :cond_8
    sget-object p2, Lcom/kousei/framework/u5;->b:Lcom/kousei/framework/u5;

    :goto_a
    iput-object p2, p0, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 168
    iput-object p3, p0, Lcom/kousei/framework/m0;->d:Ljava/lang/Object;

    .line 169
    iput-object p4, p0, Lcom/kousei/framework/m0;->b:Lcom/kousei/framework/w6;

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/String;)Lcom/kousei/framework/t5;
    .registers 4

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 2
    .line 3
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 4
    .line 5
    .line 6
    iget-object p0, p0, Lcom/kousei/framework/u5;->a:Ljava/util/Map;

    .line 7
    .line 8
    invoke-static {p1}, Lcom/kousei/framework/g3;->b(Ljava/lang/String;)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object p1

    .line 12
    if-nez p1, :cond_f

    .line 13
    .line 14
    const/4 p0, 0x0

    .line 15
    return-object p0

    .line 16
    :cond_f
    invoke-interface {p0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 17
    .line 18
    .line 19
    move-result-object v0

    .line 20
    check-cast v0, Lcom/kousei/framework/t5;

    .line 21
    .line 22
    if-eqz v0, :cond_18

    .line 23
    .line 24
    return-object v0

    .line 25
    :cond_18
    const-wide v0, -0xa1fa0dbb5469L

    .line 26
    .line 27
    .line 28
    .line 29
    .line 30
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 31
    .line 32
    .line 33
    move-result-object v0

    .line 34
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 35
    .line 36
    .line 37
    move-result p1

    .line 38
    if-eqz p1, :cond_31

    .line 39
    .line 40
    const-wide v0, -0xa1ff0dbb5469L

    .line 41
    .line 42
    .line 43
    .line 44
    .line 45
    :goto_2c
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 46
    .line 47
    .line 48
    move-result-object p1

    .line 49
    goto :goto_37

    .line 50
    :cond_31
    const-wide v0, -0xa1f30dbb5469L

    .line 51
    .line 52
    .line 53
    .line 54
    .line 55
    goto :goto_2c

    .line 56
    :goto_37
    invoke-interface {p0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 57
    .line 58
    .line 59
    move-result-object p0

    .line 60
    check-cast p0, Lcom/kousei/framework/t5;

    .line 61
    .line 62
    return-object p0
.end method
