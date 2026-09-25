.class public final Lcom/kousei/framework/e3;
.super Ljava/lang/Object;


# instance fields
.field public final a:[B

.field public final b:I


# direct methods
.method public constructor <init>(I[B)V
    .registers 3

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    invoke-static {p2}, Lcom/kousei/framework/h0;->J([B)[B

    .line 5
    .line 6
    .line 7
    move-result-object p2

    .line 8
    iput-object p2, p0, Lcom/kousei/framework/e3;->a:[B

    .line 9
    .line 10
    iput p1, p0, Lcom/kousei/framework/e3;->b:I

    .line 11
    .line 12
    return-void
.end method


# virtual methods
.method public final equals(Ljava/lang/Object;)Z
    .registers 4

    .line 1
    instance-of v0, p1, Lcom/kousei/framework/e3;

    .line 2
    .line 3
    if-nez v0, :cond_5

    .line 4
    .line 5
    goto :goto_d

    .line 6
    :cond_5
    check-cast p1, Lcom/kousei/framework/e3;

    .line 7
    .line 8
    iget v0, p1, Lcom/kousei/framework/e3;->b:I

    .line 9
    .line 10
    iget v1, p0, Lcom/kousei/framework/e3;->b:I

    .line 11
    .line 12
    if-eq v0, v1, :cond_f

    .line 13
    .line 14
    :goto_d
    const/4 p0, 0x0

    .line 15
    return p0

    .line 16
    :cond_f
    iget-object p0, p0, Lcom/kousei/framework/e3;->a:[B

    .line 17
    .line 18
    iget-object p1, p1, Lcom/kousei/framework/e3;->a:[B

    .line 19
    .line 20
    invoke-static {p0, p1}, Ljava/util/Arrays;->equals([B[B)Z

    .line 21
    .line 22
    .line 23
    move-result p0

    .line 24
    return p0
.end method

.method public final hashCode()I
    .registers 2

    .line 1
    iget-object v0, p0, Lcom/kousei/framework/e3;->a:[B

    .line 2
    .line 3
    invoke-static {v0}, Lcom/kousei/framework/h0;->i0([B)I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    iget p0, p0, Lcom/kousei/framework/e3;->b:I

    .line 8
    .line 9
    xor-int/2addr p0, v0

    .line 10
    return p0
.end method
