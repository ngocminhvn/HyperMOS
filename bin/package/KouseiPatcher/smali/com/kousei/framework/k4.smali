.class public final Lcom/kousei/framework/k4;
.super Ljava/lang/Object;


# static fields
.field public static final c:Ljava/util/Set;


# instance fields
.field public final a:Ljava/util/Hashtable;

.field public final b:Ljava/util/Vector;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    new-instance v0, Ljava/util/HashSet;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V

    .line 4
    .line 5
    .line 6
    sget-object v1, Lcom/kousei/framework/i4;->f:Lcom/kousei/framework/u;

    .line 7
    .line 8
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 9
    .line 10
    .line 11
    sget-object v1, Lcom/kousei/framework/i4;->g:Lcom/kousei/framework/u;

    .line 12
    .line 13
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 14
    .line 15
    .line 16
    sget-object v1, Lcom/kousei/framework/i4;->d:Lcom/kousei/framework/u;

    .line 17
    .line 18
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 19
    .line 20
    .line 21
    sget-object v1, Lcom/kousei/framework/i4;->i:Lcom/kousei/framework/u;

    .line 22
    .line 23
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 24
    .line 25
    .line 26
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableSet(Ljava/util/Set;)Ljava/util/Set;

    .line 27
    .line 28
    .line 29
    move-result-object v0

    .line 30
    sput-object v0, Lcom/kousei/framework/k4;->c:Ljava/util/Set;

    .line 31
    .line 32
    return-void
.end method

.method public constructor <init>()V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    new-instance v0, Ljava/util/Hashtable;

    .line 5
    .line 6
    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    .line 7
    .line 8
    .line 9
    iput-object v0, p0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 10
    .line 11
    new-instance v0, Ljava/util/Vector;

    .line 12
    .line 13
    invoke-direct {v0}, Ljava/util/Vector;-><init>()V

    .line 14
    .line 15
    .line 16
    iput-object v0, p0, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 17
    .line 18
    return-void
.end method


# virtual methods
.method public final a(Lcom/kousei/framework/u;Lcom/kousei/framework/r;)V
    .registers 8

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 2
    .line 3
    invoke-virtual {v0, p1}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v1

    .line 7
    check-cast v1, Lcom/kousei/framework/i4;

    .line 8
    .line 9
    const/4 v2, 0x1

    .line 10
    if-eqz v1, :cond_8d

    .line 11
    .line 12
    invoke-interface {p2}, Lcom/kousei/framework/j;->b()Lcom/kousei/framework/z;

    .line 13
    .line 14
    .line 15
    move-result-object p0

    .line 16
    invoke-virtual {p0}, Lcom/kousei/framework/r;->h()[B

    .line 17
    .line 18
    .line 19
    move-result-object p0

    .line 20
    iget-object p1, v1, Lcom/kousei/framework/i4;->a:Lcom/kousei/framework/u;

    .line 21
    .line 22
    sget-object p2, Lcom/kousei/framework/k4;->c:Ljava/util/Set;

    .line 23
    .line 24
    invoke-interface {p2, p1}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    .line 25
    .line 26
    .line 27
    move-result p2

    .line 28
    if-eqz p2, :cond_85

    .line 29
    .line 30
    iget-object p2, v1, Lcom/kousei/framework/i4;->c:Lcom/kousei/framework/v;

    .line 31
    .line 32
    invoke-static {p2}, Lcom/kousei/framework/v;->r(Ljava/lang/Object;)Lcom/kousei/framework/v;

    .line 33
    .line 34
    .line 35
    move-result-object p2

    .line 36
    iget-object p2, p2, Lcom/kousei/framework/v;->a:[B

    .line 37
    .line 38
    invoke-static {p2}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 39
    .line 40
    .line 41
    move-result-object p2

    .line 42
    invoke-static {p0}, Lcom/kousei/framework/c0;->t(Ljava/lang/Object;)Lcom/kousei/framework/c0;

    .line 43
    .line 44
    .line 45
    move-result-object p0

    .line 46
    new-instance v1, Lcom/kousei/framework/k;

    .line 47
    .line 48
    invoke-virtual {p2}, Lcom/kousei/framework/c0;->size()I

    .line 49
    .line 50
    .line 51
    move-result v3

    .line 52
    invoke-virtual {p0}, Lcom/kousei/framework/c0;->size()I

    .line 53
    .line 54
    .line 55
    move-result v4

    .line 56
    add-int/2addr v4, v3

    .line 57
    invoke-direct {v1, v4}, Lcom/kousei/framework/k;-><init>(I)V

    .line 58
    .line 59
    .line 60
    invoke-virtual {p2}, Lcom/kousei/framework/c0;->v()Ljava/util/Enumeration;

    .line 61
    .line 62
    .line 63
    move-result-object p2

    .line 64
    :goto_3f
    invoke-interface {p2}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 65
    .line 66
    .line 67
    move-result v3

    .line 68
    if-eqz v3, :cond_4f

    .line 69
    .line 70
    invoke-interface {p2}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 71
    .line 72
    .line 73
    move-result-object v3

    .line 74
    check-cast v3, Lcom/kousei/framework/j;

    .line 75
    .line 76
    invoke-virtual {v1, v3}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 77
    .line 78
    .line 79
    goto :goto_3f

    .line 80
    :cond_4f
    invoke-virtual {p0}, Lcom/kousei/framework/c0;->v()Ljava/util/Enumeration;

    .line 81
    .line 82
    .line 83
    move-result-object p0

    .line 84
    :goto_53
    invoke-interface {p0}, Ljava/util/Enumeration;->hasMoreElements()Z

    .line 85
    .line 86
    .line 87
    move-result p2

    .line 88
    if-eqz p2, :cond_63

    .line 89
    .line 90
    invoke-interface {p0}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    .line 91
    .line 92
    .line 93
    move-result-object p2

    .line 94
    check-cast p2, Lcom/kousei/framework/j;

    .line 95
    .line 96
    invoke-virtual {v1, p2}, Lcom/kousei/framework/k;->a(Lcom/kousei/framework/j;)V

    .line 97
    .line 98
    .line 99
    goto :goto_53

    .line 100
    :cond_63
    const/4 p0, 0x0

    .line 101
    :try_start_64
    new-instance p2, Lcom/kousei/framework/i4;

    .line 102
    .line 103
    new-instance v3, Lcom/kousei/framework/n2;

    .line 104
    .line 105
    new-instance v4, Lcom/kousei/framework/q2;

    .line 106
    .line 107
    invoke-direct {v4, v1, p0}, Lcom/kousei/framework/q2;-><init>(Lcom/kousei/framework/k;I)V

    .line 108
    .line 109
    .line 110
    const/4 v1, -0x1

    .line 111
    iput v1, v4, Lcom/kousei/framework/q2;->d:I

    .line 112
    .line 113
    invoke-direct {v3, v4}, Lcom/kousei/framework/n2;-><init>(Lcom/kousei/framework/r;)V

    .line 114
    .line 115
    .line 116
    invoke-direct {p2, p1, v2, v3}, Lcom/kousei/framework/i4;-><init>(Lcom/kousei/framework/u;ZLcom/kousei/framework/n2;)V

    .line 117
    .line 118
    .line 119
    invoke-virtual {v0, p1, p2}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_79
    .catch Ljava/io/IOException; {:try_start_64 .. :try_end_79} :catch_7a

    .line 120
    .line 121
    .line 122
    return-void

    .line 123
    :catch_7a
    move-exception p1

    .line 124
    new-instance p2, Lcom/kousei/framework/y;

    .line 125
    .line 126
    invoke-virtual {p1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 127
    .line 128
    .line 129
    move-result-object v0

    .line 130
    invoke-direct {p2, v0, p1, p0}, Lcom/kousei/framework/y;-><init>(Ljava/lang/String;Ljava/lang/Exception;I)V

    .line 131
    .line 132
    .line 133
    throw p2

    .line 134
    :cond_85
    const-string p0, "extension "

    .line 135
    .line 136
    const-string p2, " already added"

    .line 137
    .line 138
    invoke-static {p0, p1, p2}, Lcom/kousei/framework/e;->g(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)V

    .line 139
    .line 140
    .line 141
    return-void

    .line 142
    :cond_8d
    new-instance v1, Lcom/kousei/framework/i4;

    .line 143
    .line 144
    new-instance v3, Lcom/kousei/framework/n2;

    .line 145
    .line 146
    invoke-direct {v3, p2}, Lcom/kousei/framework/n2;-><init>(Lcom/kousei/framework/r;)V

    .line 147
    .line 148
    .line 149
    invoke-direct {v1, p1, v2, v3}, Lcom/kousei/framework/i4;-><init>(Lcom/kousei/framework/u;ZLcom/kousei/framework/n2;)V

    .line 150
    .line 151
    .line 152
    iget-object p0, p0, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 153
    .line 154
    invoke-virtual {p0, p1}, Ljava/util/Vector;->addElement(Ljava/lang/Object;)V

    .line 155
    .line 156
    .line 157
    invoke-virtual {v0, p1, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 158
    .line 159
    .line 160
    return-void
.end method

.method public final b(Lcom/kousei/framework/i4;)V
    .registers 5

    .line 1
    iget-object v0, p1, Lcom/kousei/framework/i4;->a:Lcom/kousei/framework/u;

    .line 2
    .line 3
    iget-object v1, p1, Lcom/kousei/framework/i4;->a:Lcom/kousei/framework/u;

    .line 4
    .line 5
    iget-object v2, p0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 6
    .line 7
    invoke-virtual {v2, v0}, Ljava/util/Hashtable;->containsKey(Ljava/lang/Object;)Z

    .line 8
    .line 9
    .line 10
    move-result v0

    .line 11
    if-nez v0, :cond_15

    .line 12
    .line 13
    iget-object p0, p0, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 14
    .line 15
    invoke-virtual {p0, v1}, Ljava/util/Vector;->addElement(Ljava/lang/Object;)V

    .line 16
    .line 17
    .line 18
    invoke-virtual {v2, v1, p1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 19
    .line 20
    .line 21
    return-void

    .line 22
    :cond_15
    const-string p0, "extension "

    .line 23
    .line 24
    const-string p1, " already added"

    .line 25
    .line 26
    invoke-static {p0, v1, p1}, Lcom/kousei/framework/e;->g(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)V

    .line 27
    .line 28
    .line 29
    return-void
.end method

.method public final c()Lcom/kousei/framework/j4;
    .registers 8

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/k4;->b:Ljava/util/Vector;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/util/Vector;->size()I

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    new-array v2, v1, [Lcom/kousei/framework/i4;

    .line 8
    .line 9
    const/4 v3, 0x0

    .line 10
    move v4, v3

    .line 11
    :goto_a
    invoke-virtual {v0}, Ljava/util/Vector;->size()I

    .line 12
    .line 13
    .line 14
    move-result v5

    .line 15
    if-eq v4, v5, :cond_21

    .line 16
    .line 17
    iget-object v5, p0, Lcom/kousei/framework/k4;->a:Ljava/util/Hashtable;

    .line 18
    .line 19
    invoke-virtual {v0, v4}, Ljava/util/Vector;->elementAt(I)Ljava/lang/Object;

    .line 20
    .line 21
    .line 22
    move-result-object v6

    .line 23
    invoke-virtual {v5, v6}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 24
    .line 25
    .line 26
    move-result-object v5

    .line 27
    check-cast v5, Lcom/kousei/framework/i4;

    .line 28
    .line 29
    aput-object v5, v2, v4

    .line 30
    .line 31
    add-int/lit8 v4, v4, 0x1

    .line 32
    .line 33
    goto :goto_a

    .line 34
    :cond_21
    new-instance p0, Lcom/kousei/framework/j4;

    .line 35
    .line 36
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 37
    .line 38
    .line 39
    new-instance v0, Ljava/util/Hashtable;

    .line 40
    .line 41
    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    .line 42
    .line 43
    .line 44
    iput-object v0, p0, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 45
    .line 46
    new-instance v0, Ljava/util/Vector;

    .line 47
    .line 48
    invoke-direct {v0}, Ljava/util/Vector;-><init>()V

    .line 49
    .line 50
    .line 51
    iput-object v0, p0, Lcom/kousei/framework/j4;->b:Ljava/util/Vector;

    .line 52
    .line 53
    if-eqz v1, :cond_4c

    .line 54
    .line 55
    :goto_36
    if-eq v3, v1, :cond_4b

    .line 56
    .line 57
    aget-object v0, v2, v3

    .line 58
    .line 59
    iget-object v4, p0, Lcom/kousei/framework/j4;->b:Ljava/util/Vector;

    .line 60
    .line 61
    iget-object v5, v0, Lcom/kousei/framework/i4;->a:Lcom/kousei/framework/u;

    .line 62
    .line 63
    invoke-virtual {v4, v5}, Ljava/util/Vector;->addElement(Ljava/lang/Object;)V

    .line 64
    .line 65
    .line 66
    iget-object v4, p0, Lcom/kousei/framework/j4;->a:Ljava/util/Hashtable;

    .line 67
    .line 68
    iget-object v5, v0, Lcom/kousei/framework/i4;->a:Lcom/kousei/framework/u;

    .line 69
    .line 70
    invoke-virtual {v4, v5, v0}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 71
    .line 72
    .line 73
    add-int/lit8 v3, v3, 0x1

    .line 74
    .line 75
    goto :goto_36

    .line 76
    :cond_4b
    return-object p0

    .line 77
    :cond_4c
    const-string p0, "extension array cannot be null or empty"

    .line 78
    .line 79
    invoke-static {p0}, Lcom/kousei/framework/e;->j(Ljava/lang/String;)V

    .line 80
    .line 81
    .line 82
    const/4 p0, 0x0

    .line 83
    return-object p0
.end method
