.class public final Lcom/kousei/framework/c3;
.super Lcom/kousei/framework/b1;


# instance fields
.field public final d:Z


# direct methods
.method public constructor <init>(IIZLcom/kousei/framework/e0;)V
    .registers 5

    .line 1
    invoke-direct {p0, p1, p2, p4}, Lcom/kousei/framework/b1;-><init>(IILcom/kousei/framework/e0;)V

    .line 2
    .line 3
    .line 4
    iput-boolean p3, p0, Lcom/kousei/framework/c3;->d:Z

    .line 5
    .line 6
    return-void
.end method


# virtual methods
.method public final e()Lcom/kousei/framework/z;
    .registers 10

    .line 1
    iget-boolean v0, p0, Lcom/kousei/framework/c3;->d:Z

    .line 2
    .line 3
    const/4 v2, 0x4

    .line 4
    iget-object v1, p0, Lcom/kousei/framework/b1;->c:Lcom/kousei/framework/e0;

    .line 5
    .line 6
    iget v3, p0, Lcom/kousei/framework/b1;->a:I

    .line 7
    .line 8
    iget v4, p0, Lcom/kousei/framework/b1;->b:I

    .line 9
    .line 10
    if-nez v0, :cond_1f

    .line 11
    .line 12
    iget-object p0, v1, Lcom/kousei/framework/e0;->a:Lcom/kousei/framework/e6;

    .line 13
    .line 14
    check-cast p0, Lcom/kousei/framework/j3;

    .line 15
    .line 16
    invoke-virtual {p0}, Lcom/kousei/framework/j3;->b()[B

    .line 17
    .line 18
    .line 19
    move-result-object p0

    .line 20
    new-instance v1, Lcom/kousei/framework/a1;

    .line 21
    .line 22
    new-instance v5, Lcom/kousei/framework/n2;

    .line 23
    .line 24
    invoke-direct {v5, p0}, Lcom/kousei/framework/v;-><init>([B)V

    .line 25
    .line 26
    .line 27
    const/4 v6, 0x2

    .line 28
    invoke-direct/range {v1 .. v6}, Lcom/kousei/framework/a1;-><init>(IIILcom/kousei/framework/j;I)V

    .line 29
    .line 30
    .line 31
    return-object v1

    .line 32
    :cond_1f
    invoke-virtual {v1}, Lcom/kousei/framework/e0;->c()Lcom/kousei/framework/k;

    .line 33
    .line 34
    .line 35
    move-result-object p0

    .line 36
    iget v0, p0, Lcom/kousei/framework/k;->b:I

    .line 37
    .line 38
    const/4 v1, 0x1

    .line 39
    if-ne v0, v1, :cond_37

    .line 40
    .line 41
    move v5, v3

    .line 42
    new-instance v3, Lcom/kousei/framework/a1;

    .line 43
    .line 44
    const/4 v0, 0x0

    .line 45
    invoke-virtual {p0, v0}, Lcom/kousei/framework/k;->c(I)Lcom/kousei/framework/j;

    .line 46
    .line 47
    .line 48
    move-result-object v7

    .line 49
    const/4 v8, 0x2

    .line 50
    move v6, v4

    .line 51
    const/4 v4, 0x3

    .line 52
    invoke-direct/range {v3 .. v8}, Lcom/kousei/framework/a1;-><init>(IIILcom/kousei/framework/j;I)V

    .line 53
    .line 54
    .line 55
    return-object v3

    .line 56
    :cond_37
    new-instance v1, Lcom/kousei/framework/a1;

    .line 57
    .line 58
    invoke-static {p0}, Lcom/kousei/framework/a3;->a(Lcom/kousei/framework/k;)Lcom/kousei/framework/q2;

    .line 59
    .line 60
    .line 61
    move-result-object v5

    .line 62
    const/4 v6, 0x2

    .line 63
    invoke-direct/range {v1 .. v6}, Lcom/kousei/framework/a1;-><init>(IIILcom/kousei/framework/j;I)V

    .line 64
    .line 65
    .line 66
    return-object v1
.end method
