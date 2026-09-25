.class public interface abstract Lcom/kousei/framework/g5;
.super Ljava/lang/Object;


# static fields
.field public static final a:Lcom/kousei/framework/u;

.field public static final b:Lcom/kousei/framework/u;

.field public static final c:Lcom/kousei/framework/u;


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    new-instance v0, Lcom/kousei/framework/u;

    .line 2
    .line 3
    const-string v1, "1.0.10118"

    .line 4
    .line 5
    invoke-direct {v0, v1}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 6
    .line 7
    .line 8
    const-string v1, "3.0"

    .line 9
    .line 10
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 11
    .line 12
    .line 13
    move-result-object v0

    .line 14
    const-string v1, "49"

    .line 15
    .line 16
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 17
    .line 18
    .line 19
    move-result-object v1

    .line 20
    sput-object v1, Lcom/kousei/framework/g5;->a:Lcom/kousei/framework/u;

    .line 21
    .line 22
    const-string v1, "50"

    .line 23
    .line 24
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 25
    .line 26
    .line 27
    move-result-object v1

    .line 28
    sput-object v1, Lcom/kousei/framework/g5;->b:Lcom/kousei/framework/u;

    .line 29
    .line 30
    const-string v1, "55"

    .line 31
    .line 32
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 33
    .line 34
    .line 35
    move-result-object v0

    .line 36
    sput-object v0, Lcom/kousei/framework/g5;->c:Lcom/kousei/framework/u;

    .line 37
    .line 38
    new-instance v0, Lcom/kousei/framework/u;

    .line 39
    .line 40
    const-string v1, "1.0.18033.2"

    .line 41
    .line 42
    invoke-direct {v0, v1}, Lcom/kousei/framework/u;-><init>(Ljava/lang/String;)V

    .line 43
    .line 44
    .line 45
    const-string v1, "1.2"

    .line 46
    .line 47
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 48
    .line 49
    .line 50
    const-string v1, "2.4"

    .line 51
    .line 52
    invoke-virtual {v0, v1}, Lcom/kousei/framework/u;->r(Ljava/lang/String;)Lcom/kousei/framework/u;

    .line 53
    .line 54
    .line 55
    return-void
.end method
