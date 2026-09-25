.class public abstract Lcom/kousei/framework/m4;
.super Ljava/lang/Object;


# static fields
.field public static final a:Lcom/kousei/framework/j7;

.field public static final b:Lcom/kousei/framework/j7;


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lcom/kousei/framework/j7;

    .line 2
    .line 3
    const-wide/16 v1, 0x2

    .line 4
    .line 5
    invoke-static {v1, v2}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    invoke-direct {v0, v1}, Lcom/kousei/framework/j7;-><init>(Ljava/math/BigInteger;)V

    .line 10
    .line 11
    .line 12
    sput-object v0, Lcom/kousei/framework/m4;->a:Lcom/kousei/framework/j7;

    .line 13
    .line 14
    new-instance v0, Lcom/kousei/framework/j7;

    .line 15
    .line 16
    const-wide/16 v1, 0x3

    .line 17
    .line 18
    invoke-static {v1, v2}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    .line 19
    .line 20
    .line 21
    move-result-object v1

    .line 22
    invoke-direct {v0, v1}, Lcom/kousei/framework/j7;-><init>(Ljava/math/BigInteger;)V

    .line 23
    .line 24
    .line 25
    sput-object v0, Lcom/kousei/framework/m4;->b:Lcom/kousei/framework/j7;

    .line 26
    .line 27
    return-void
.end method
