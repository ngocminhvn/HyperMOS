.class public interface abstract Lcom/kousei/framework/m3;
.super Ljava/lang/Object;


# static fields
.field public static final a:Lcom/kousei/framework/u;

.field public static final b:Lcom/kousei/framework/u;

.field public static final c:Lcom/kousei/framework/u;

.field public static final d:Lcom/kousei/framework/u;

.field public static final e:Lcom/kousei/framework/u;


# direct methods
.method static constructor <clinit>()V
    .registers 9

    .line 1
    new-instance v0, Lcom/kousei/framework/u;

    .line 2
    .line 3
    const-string v1, "0.4.0.127.0.7"

    .line 4
    .line 5
    invoke-direct {v0, v1}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 6
    .line 7
    .line 8
    const-string v1, "2.2.1"

    .line 9
    .line 10
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 11
    .line 12
    .line 13
    move-result-object v1

    .line 14
    const-string v2, "1"

    .line 15
    .line 16
    invoke-virtual {v1, v2}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 17
    .line 18
    .line 19
    const-string v3, "2"

    .line 20
    .line 21
    invoke-virtual {v1, v3}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 22
    .line 23
    .line 24
    const-string v1, "2.2.3"

    .line 25
    .line 26
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 27
    .line 28
    .line 29
    move-result-object v1

    .line 30
    invoke-virtual {v1, v2}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 31
    .line 32
    .line 33
    move-result-object v4

    .line 34
    invoke-virtual {v4, v2}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 35
    .line 36
    .line 37
    invoke-virtual {v1, v3}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 38
    .line 39
    .line 40
    move-result-object v1

    .line 41
    invoke-virtual {v1, v2}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 42
    .line 43
    .line 44
    const-string v1, "2.2.2"

    .line 45
    .line 46
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 47
    .line 48
    .line 49
    move-result-object v1

    .line 50
    const-string v4, "3"

    .line 51
    .line 52
    invoke-static {v1, v2, v2, v3, v4}, Lcom/kousei/framework/p0;->b(Lcom/kousei/framework/u;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 53
    .line 54
    .line 55
    move-result-object v5

    .line 56
    const-string v6, "4"

    .line 57
    .line 58
    invoke-virtual {v5, v6}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 59
    .line 60
    .line 61
    const-string v7, "5"

    .line 62
    .line 63
    invoke-virtual {v5, v7}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 64
    .line 65
    .line 66
    const-string v8, "6"

    .line 67
    .line 68
    invoke-virtual {v5, v8}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 69
    .line 70
    .line 71
    invoke-virtual {v1, v3}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 72
    .line 73
    .line 74
    move-result-object v1

    .line 75
    invoke-virtual {v1, v2}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 76
    .line 77
    .line 78
    move-result-object v2

    .line 79
    sput-object v2, Lcom/kousei/framework/m3;->a:Lcom/kousei/framework/u;

    .line 80
    .line 81
    invoke-virtual {v1, v3}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 82
    .line 83
    .line 84
    move-result-object v2

    .line 85
    sput-object v2, Lcom/kousei/framework/m3;->b:Lcom/kousei/framework/u;

    .line 86
    .line 87
    invoke-virtual {v1, v4}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 88
    .line 89
    .line 90
    move-result-object v2

    .line 91
    sput-object v2, Lcom/kousei/framework/m3;->c:Lcom/kousei/framework/u;

    .line 92
    .line 93
    invoke-virtual {v1, v6}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 94
    .line 95
    .line 96
    move-result-object v2

    .line 97
    sput-object v2, Lcom/kousei/framework/m3;->d:Lcom/kousei/framework/u;

    .line 98
    .line 99
    invoke-virtual {v1, v7}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 100
    .line 101
    .line 102
    move-result-object v1

    .line 103
    sput-object v1, Lcom/kousei/framework/m3;->e:Lcom/kousei/framework/u;

    .line 104
    .line 105
    const-string v1, "3.1.2.1"

    .line 106
    .line 107
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 108
    .line 109
    .line 110
    return-void
.end method
