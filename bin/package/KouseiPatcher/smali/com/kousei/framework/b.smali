.class public abstract Lcom/kousei/framework/b;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/Hashtable;

.field public static final b:Ljava/util/Hashtable;


# direct methods
.method static constructor <clinit>()V
    .registers 7

    .line 1
    new-instance v0, Lcom/kousei/framework/a;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    invoke-direct {v0, v1}, Lcom/kousei/framework/a;-><init>(I)V

    .line 5
    .line 6
    .line 7
    new-instance v1, Ljava/util/Hashtable;

    .line 8
    .line 9
    invoke-direct {v1}, Ljava/util/Hashtable;-><init>()V

    .line 10
    .line 11
    .line 12
    sput-object v1, Lcom/kousei/framework/b;->a:Ljava/util/Hashtable;

    .line 13
    .line 14
    new-instance v2, Ljava/util/Hashtable;

    .line 15
    .line 16
    invoke-direct {v2}, Ljava/util/Hashtable;-><init>()V

    .line 17
    .line 18
    .line 19
    sput-object v2, Lcom/kousei/framework/b;->b:Ljava/util/Hashtable;

    .line 20
    .line 21
    new-instance v3, Ljava/util/Hashtable;

    .line 22
    .line 23
    invoke-direct {v3}, Ljava/util/Hashtable;-><init>()V

    .line 24
    .line 25
    .line 26
    sget-object v4, Lcom/kousei/framework/c;->a:Lcom/kousei/framework/u;

    .line 27
    .line 28
    const-string v5, "FRP256v1"

    .line 29
    .line 30
    invoke-static {v5}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 31
    .line 32
    .line 33
    move-result-object v6

    .line 34
    invoke-virtual {v1, v6, v4}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 35
    .line 36
    .line 37
    invoke-virtual {v3, v4, v5}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 38
    .line 39
    .line 40
    invoke-virtual {v2, v4, v0}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 41
    .line 42
    .line 43
    return-void
.end method
