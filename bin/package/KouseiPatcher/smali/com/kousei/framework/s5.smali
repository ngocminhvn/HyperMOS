.class public final enum Lcom/kousei/framework/s5;
.super Ljava/lang/Enum;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final enum a:Lcom/kousei/framework/s5;

.field public static final enum b:Lcom/kousei/framework/s5;

.field public static final enum c:Lcom/kousei/framework/s5;

.field public static final synthetic d:[Lcom/kousei/framework/s5;


# direct methods
.method static constructor <clinit>()V
    .registers 5

    .line 1
    new-instance v0, Lcom/kousei/framework/s5;

    .line 2
    .line 3
    const-wide v1, -0xa4630dbb5469L

    .line 4
    .line 5
    .line 6
    .line 7
    .line 8
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    const/4 v2, 0x0

    .line 13
    invoke-direct {v0, v1, v2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 14
    .line 15
    .line 16
    sput-object v0, Lcom/kousei/framework/s5;->a:Lcom/kousei/framework/s5;

    .line 17
    .line 18
    new-instance v1, Lcom/kousei/framework/s5;

    .line 19
    .line 20
    const-wide v2, -0xa4790dbb5469L

    .line 21
    .line 22
    .line 23
    .line 24
    .line 25
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 26
    .line 27
    .line 28
    move-result-object v2

    .line 29
    const/4 v3, 0x1

    .line 30
    invoke-direct {v1, v2, v3}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 31
    .line 32
    .line 33
    sput-object v1, Lcom/kousei/framework/s5;->b:Lcom/kousei/framework/s5;

    .line 34
    .line 35
    new-instance v2, Lcom/kousei/framework/s5;

    .line 36
    .line 37
    const-wide v3, -0xa47f0dbb5469L

    .line 38
    .line 39
    .line 40
    .line 41
    .line 42
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 43
    .line 44
    .line 45
    move-result-object v3

    .line 46
    const/4 v4, 0x2

    .line 47
    invoke-direct {v2, v3, v4}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 48
    .line 49
    .line 50
    sput-object v2, Lcom/kousei/framework/s5;->c:Lcom/kousei/framework/s5;

    .line 51
    .line 52
    filled-new-array {v0, v1, v2}, [Lcom/kousei/framework/s5;

    .line 53
    .line 54
    .line 55
    move-result-object v0

    .line 56
    sput-object v0, Lcom/kousei/framework/s5;->d:[Lcom/kousei/framework/s5;

    .line 57
    .line 58
    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/kousei/framework/s5;
    .registers 2

    .line 1
    const-class v0, Lcom/kousei/framework/s5;

    .line 2
    .line 3
    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    .line 4
    .line 5
    .line 6
    move-result-object p0

    .line 7
    check-cast p0, Lcom/kousei/framework/s5;

    .line 8
    .line 9
    return-object p0
.end method

.method public static values()[Lcom/kousei/framework/s5;
    .registers 1

    .line 1
    sget-object v0, Lcom/kousei/framework/s5;->d:[Lcom/kousei/framework/s5;

    .line 2
    .line 3
    invoke-virtual {v0}, [Lcom/kousei/framework/s5;->clone()Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    check-cast v0, [Lcom/kousei/framework/s5;

    .line 8
    .line 9
    return-object v0
.end method
