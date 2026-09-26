.class public final Lcom/kousei/framework/sa;
.super Ljava/lang/Object;


# instance fields
.field public a:Lcom/kousei/framework/p;

.field public b:Lcom/kousei/framework/j0;

.field public c:Lcom/kousei/framework/va;

.field public d:Lcom/kousei/framework/qa;

.field public e:Lcom/kousei/framework/qa;

.field public f:Lcom/kousei/framework/va;

.field public g:Lcom/kousei/framework/ka;

.field public h:Lcom/kousei/framework/j4;

.field public i:Z


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    sget-object v0, Lcom/kousei/framework/p;->g:Lcom/kousei/framework/p;

    .line 2
    .line 3
    if-eqz v0, :cond_11

    .line 4
    .line 5
    const/16 v0, 0x80

    .line 6
    .line 7
    and-int/lit16 v1, v0, 0xc0

    .line 8
    .line 9
    if-ne v1, v0, :cond_b

    .line 10
    .line 11
    return-void

    .line 12
    :cond_b
    const-string v1, "invalid tag class: "

    .line 13
    .line 14
    invoke-static {v0, v1}, Lcom/kousei/framework/e;->c(ILjava/lang/String;)V

    .line 15
    .line 16
    .line 17
    return-void

    .line 18
    :cond_11
    const-string v0, "\'obj\' cannot be null"

    .line 19
    .line 20
    invoke-static {v0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 21
    .line 22
    .line 23
    return-void
.end method


# virtual methods
.method public final a()Lcom/kousei/framework/la;
    .registers 10

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/sa;->a:Lcom/kousei/framework/p;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    if-eqz v0, :cond_6f

    .line 5
    .line 6
    iget-object v2, p0, Lcom/kousei/framework/sa;->b:Lcom/kousei/framework/j0;

    .line 7
    .line 8
    if-eqz v2, :cond_6f

    .line 9
    .line 10
    iget-object v3, p0, Lcom/kousei/framework/sa;->c:Lcom/kousei/framework/va;

    .line 11
    .line 12
    if-eqz v3, :cond_6f

    .line 13
    .line 14
    iget-object v4, p0, Lcom/kousei/framework/sa;->d:Lcom/kousei/framework/qa;

    .line 15
    .line 16
    if-eqz v4, :cond_6f

    .line 17
    .line 18
    iget-object v5, p0, Lcom/kousei/framework/sa;->e:Lcom/kousei/framework/qa;

    .line 19
    .line 20
    if-eqz v5, :cond_6f

    .line 21
    .line 22
    iget-object v6, p0, Lcom/kousei/framework/sa;->f:Lcom/kousei/framework/va;

    .line 23
    .line 24
    if-nez v6, :cond_1d

    .line 25
    .line 26
    iget-boolean v6, p0, Lcom/kousei/framework/sa;->i:Z

    .line 27
    .line 28
    if-eqz v6, :cond_6f

    .line 29
    .line 30
    :cond_1d
    iget-object v6, p0, Lcom/kousei/framework/sa;->g:Lcom/kousei/framework/ka;

    .line 31
    .line 32
    if-eqz v6, :cond_6f

    .line 33
    .line 34
    new-instance v6, Lcom/kousei/framework/la;

    .line 35
    .line 36
    sget-object v7, Lcom/kousei/framework/p;->g:Lcom/kousei/framework/p;

    .line 37
    .line 38
    new-instance v8, Lcom/kousei/framework/ta;

    .line 39
    .line 40
    invoke-direct {v8, v4, v5}, Lcom/kousei/framework/ta;-><init>(Lcom/kousei/framework/qa;Lcom/kousei/framework/qa;)V

    .line 41
    .line 42
    .line 43
    iget-object v4, p0, Lcom/kousei/framework/sa;->f:Lcom/kousei/framework/va;

    .line 44
    .line 45
    if-eqz v4, :cond_2f

    .line 46
    .line 47
    goto :goto_3c

    .line 48
    :cond_2f
    new-instance v4, Lcom/kousei/framework/q2;

    .line 49
    .line 50
    const/4 v5, 0x0

    .line 51
    invoke-direct {v4, v5}, Lcom/kousei/framework/q2;-><init>(I)V

    .line 52
    .line 53
    .line 54
    const/4 v5, -0x1

    .line 55
    iput v5, v4, Lcom/kousei/framework/q2;->d:I

    .line 56
    .line 57
    invoke-static {v4}, Lcom/kousei/framework/va;->i(Ljava/lang/Object;)Lcom/kousei/framework/va;

    .line 58
    .line 59
    .line 60
    move-result-object v4

    .line 61
    :goto_3c
    iget-object v5, p0, Lcom/kousei/framework/sa;->g:Lcom/kousei/framework/ka;

    .line 62
    .line 63
    iget-object p0, p0, Lcom/kousei/framework/sa;->h:Lcom/kousei/framework/j4;

    .line 64
    .line 65
    invoke-direct {v6}, Ljava/lang/Object;-><init>()V

    .line 66
    .line 67
    .line 68
    if-eqz v4, :cond_69

    .line 69
    .line 70
    if-eqz v5, :cond_63

    .line 71
    .line 72
    if-eqz v7, :cond_4a

    .line 73
    .line 74
    goto :goto_4c

    .line 75
    :cond_4a
    sget-object v7, Lcom/kousei/framework/p;->e:Lcom/kousei/framework/p;

    .line 76
    .line 77
    :goto_4c
    iput-object v7, v6, Lcom/kousei/framework/la;->b:Lcom/kousei/framework/p;

    .line 78
    .line 79
    iput-object v0, v6, Lcom/kousei/framework/la;->c:Lcom/kousei/framework/p;

    .line 80
    .line 81
    iput-object v2, v6, Lcom/kousei/framework/la;->d:Lcom/kousei/framework/j0;

    .line 82
    .line 83
    iput-object v3, v6, Lcom/kousei/framework/la;->e:Lcom/kousei/framework/va;

    .line 84
    .line 85
    iput-object v8, v6, Lcom/kousei/framework/la;->f:Lcom/kousei/framework/ta;

    .line 86
    .line 87
    iput-object v4, v6, Lcom/kousei/framework/la;->g:Lcom/kousei/framework/va;

    .line 88
    .line 89
    iput-object v5, v6, Lcom/kousei/framework/la;->h:Lcom/kousei/framework/ka;

    .line 90
    .line 91
    iput-object v1, v6, Lcom/kousei/framework/la;->i:Lcom/kousei/framework/f;

    .line 92
    .line 93
    iput-object v1, v6, Lcom/kousei/framework/la;->j:Lcom/kousei/framework/f;

    .line 94
    .line 95
    iput-object p0, v6, Lcom/kousei/framework/la;->k:Lcom/kousei/framework/j4;

    .line 96
    .line 97
    iput-object v1, v6, Lcom/kousei/framework/la;->a:Lcom/kousei/framework/c0;

    .line 98
    .line 99
    return-object v6

    .line 100
    :cond_63
    const-string p0, "\'subjectPublicKeyInfo\' cannot be null"

    .line 101
    .line 102
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 103
    .line 104
    .line 105
    return-object v1

    .line 106
    :cond_69
    const-string p0, "\'subject\' cannot be null"

    .line 107
    .line 108
    invoke-static {p0}, Lcom/kousei/framework/e;->e(Ljava/lang/String;)V

    .line 109
    .line 110
    .line 111
    return-object v1

    .line 112
    :cond_6f
    const-string p0, "not all mandatory fields set in V3 TBScertificate generator"

    .line 113
    .line 114
    invoke-static {p0}, Lcom/kousei/framework/e;->l(Ljava/lang/String;)V

    .line 115
    .line 116
    .line 117
    return-object v1
.end method
