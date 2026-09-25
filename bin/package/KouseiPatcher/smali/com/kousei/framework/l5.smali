.class public final Lcom/kousei/framework/l5;
.super Ljava/lang/Object;


# static fields
.field public static final c:Ljava/util/HashSet;

.field public static final d:Lcom/kousei/framework/h3;


# instance fields
.field public final a:Ljava/lang/String;

.field public final b:Lcom/kousei/framework/c7;


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
    sput-object v0, Lcom/kousei/framework/l5;->c:Ljava/util/HashSet;

    .line 7
    .line 8
    new-instance v1, Lcom/kousei/framework/h3;

    .line 9
    .line 10
    invoke-direct {v1}, Ljava/lang/Object;-><init>()V

    .line 11
    .line 12
    .line 13
    sput-object v1, Lcom/kousei/framework/l5;->d:Lcom/kousei/framework/h3;

    .line 14
    .line 15
    const-string v1, "COMPOSITE"

    .line 16
    .line 17
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 18
    .line 19
    .line 20
    const-string v1, "DILITHIUM"

    .line 21
    .line 22
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 23
    .line 24
    .line 25
    const-string v1, "SPHINCS+"

    .line 26
    .line 27
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 28
    .line 29
    .line 30
    const-string v1, "SPHINCSPlus"

    .line 31
    .line 32
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 33
    .line 34
    .line 35
    const-string v1, "ML-DSA"

    .line 36
    .line 37
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 38
    .line 39
    .line 40
    const-string v1, "SLH-DSA"

    .line 41
    .line 42
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 43
    .line 44
    .line 45
    const-string v1, "HASH-ML-DSA"

    .line 46
    .line 47
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 48
    .line 49
    .line 50
    const-string v1, "HASH-SLH-DSA"

    .line 51
    .line 52
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 53
    .line 54
    .line 55
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;)V
    .registers 3

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    new-instance v0, Lcom/kousei/framework/c7;

    .line 5
    .line 6
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 7
    .line 8
    .line 9
    iput-object v0, p0, Lcom/kousei/framework/l5;->b:Lcom/kousei/framework/c7;

    .line 10
    .line 11
    iput-object p1, p0, Lcom/kousei/framework/l5;->a:Ljava/lang/String;

    .line 12
    .line 13
    return-void
.end method


# virtual methods
.method public final a(Ljava/security/PrivateKey;)Lcom/kousei/framework/k1;
    .registers 6

    .line 1
    :try_start_0
    sget-object v0, Lcom/kousei/framework/l5;->d:Lcom/kousei/framework/h3;

    .line 2
    .line 3
    sget-object v1, Lcom/kousei/framework/l5;->c:Ljava/util/HashSet;

    .line 4
    .line 5
    iget-object v2, p0, Lcom/kousei/framework/l5;->a:Ljava/lang/String;

    .line 6
    .line 7
    invoke-static {v2}, Lcom/kousei/framework/ja;->e(Ljava/lang/String;)Ljava/lang/String;

    .line 8
    .line 9
    .line 10
    move-result-object v3

    .line 11
    invoke-virtual {v1, v3}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    .line 12
    .line 13
    .line 14
    move-result v1

    .line 15
    if-eqz v1, :cond_1c

    .line 16
    .line 17
    invoke-interface {p1}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object v1

    .line 21
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 22
    .line 23
    .line 24
    invoke-static {v1}, Lcom/kousei/framework/h3;->e(Ljava/lang/String;)Lcom/kousei/framework/j0;

    .line 25
    .line 26
    .line 27
    move-result-object v0

    .line 28
    goto :goto_23

    .line 29
    :cond_1c
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 30
    .line 31
    .line 32
    invoke-static {v2}, Lcom/kousei/framework/h3;->e(Ljava/lang/String;)Lcom/kousei/framework/j0;

    .line 33
    .line 34
    .line 35
    move-result-object v0

    .line 36
    :goto_23
    iget-object p0, p0, Lcom/kousei/framework/l5;->b:Lcom/kousei/framework/c7;

    .line 37
    .line 38
    invoke-virtual {p0, v0}, Lcom/kousei/framework/c7;->a(Lcom/kousei/framework/j0;)Ljava/security/Signature;

    .line 39
    .line 40
    .line 41
    move-result-object p0

    .line 42
    invoke-virtual {p0, p1}, Ljava/security/Signature;->initSign(Ljava/security/PrivateKey;)V

    .line 43
    .line 44
    .line 45
    new-instance p1, Lcom/kousei/framework/k1;

    .line 46
    .line 47
    invoke-direct {p1, p0, v0}, Lcom/kousei/framework/k1;-><init>(Ljava/security/Signature;Lcom/kousei/framework/j0;)V
    :try_end_31
    .catch Ljava/security/GeneralSecurityException; {:try_start_0 .. :try_end_31} :catch_32

    .line 48
    .line 49
    .line 50
    return-object p1

    .line 51
    :catch_32
    move-exception p0

    .line 52
    new-instance p1, Lcom/kousei/framework/r1;

    .line 53
    .line 54
    new-instance v0, Ljava/lang/StringBuilder;

    .line 55
    .line 56
    const-string v1, "cannot create signer: "

    .line 57
    .line 58
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 59
    .line 60
    .line 61
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 62
    .line 63
    .line 64
    move-result-object v1

    .line 65
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 66
    .line 67
    .line 68
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 69
    .line 70
    .line 71
    move-result-object v0

    .line 72
    const/4 v1, 0x1

    .line 73
    invoke-direct {p1, v1, v0}, Lcom/kousei/framework/r1;-><init>(ILjava/lang/String;)V

    .line 74
    .line 75
    .line 76
    iput-object p0, p1, Lcom/kousei/framework/r1;->b:Ljava/lang/Exception;

    .line 77
    .line 78
    throw p1
.end method
