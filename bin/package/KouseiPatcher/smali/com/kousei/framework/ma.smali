.class public final enum Lcom/kousei/framework/ma;
.super Ljava/lang/Enum;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final enum a:Lcom/kousei/framework/ma;

.field public static final enum b:Lcom/kousei/framework/ma;

.field public static final enum c:Lcom/kousei/framework/ma;

.field public static final enum d:Lcom/kousei/framework/ma;

.field public static final synthetic e:[Lcom/kousei/framework/ma;


# direct methods
.method static constructor <clinit>()V
    .registers 6

    .line 1
    new-instance v0, Lcom/kousei/framework/ma;

    .line 2
    .line 3
    const-wide v1, -0xab0a0dbb5469L

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
    sput-object v0, Lcom/kousei/framework/ma;->a:Lcom/kousei/framework/ma;

    .line 17
    .line 18
    new-instance v1, Lcom/kousei/framework/ma;

    .line 19
    .line 20
    const-wide v2, -0xab010dbb5469L

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
    sput-object v1, Lcom/kousei/framework/ma;->b:Lcom/kousei/framework/ma;

    .line 34
    .line 35
    new-instance v2, Lcom/kousei/framework/ma;

    .line 36
    .line 37
    const-wide v3, -0xab1b0dbb5469L

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
    sput-object v2, Lcom/kousei/framework/ma;->c:Lcom/kousei/framework/ma;

    .line 51
    .line 52
    new-instance v3, Lcom/kousei/framework/ma;

    .line 53
    .line 54
    const-wide v4, -0xab120dbb5469L

    .line 55
    .line 56
    .line 57
    .line 58
    .line 59
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 60
    .line 61
    .line 62
    move-result-object v4

    .line 63
    const/4 v5, 0x3

    .line 64
    invoke-direct {v3, v4, v5}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 65
    .line 66
    .line 67
    sput-object v3, Lcom/kousei/framework/ma;->d:Lcom/kousei/framework/ma;

    .line 68
    .line 69
    filled-new-array {v0, v1, v2, v3}, [Lcom/kousei/framework/ma;

    .line 70
    .line 71
    .line 72
    move-result-object v0

    .line 73
    sput-object v0, Lcom/kousei/framework/ma;->e:[Lcom/kousei/framework/ma;

    .line 74
    .line 75
    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/kousei/framework/ma;
    .registers 2

    .line 1
    const-class v0, Lcom/kousei/framework/ma;

    .line 2
    .line 3
    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    .line 4
    .line 5
    .line 6
    move-result-object p0

    .line 7
    check-cast p0, Lcom/kousei/framework/ma;

    .line 8
    .line 9
    return-object p0
.end method

.method public static values()[Lcom/kousei/framework/ma;
    .registers 1

    .line 1
    sget-object v0, Lcom/kousei/framework/ma;->e:[Lcom/kousei/framework/ma;

    .line 2
    .line 3
    invoke-virtual {v0}, [Lcom/kousei/framework/ma;->clone()Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    check-cast v0, [Lcom/kousei/framework/ma;

    .line 8
    .line 9
    return-object v0
.end method
