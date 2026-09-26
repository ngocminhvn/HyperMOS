.class public final Landroid/security/kaorios/KaoriosHook;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"


# static fields
.field public static final a:Lcom/kousei/framework/r5;

.field public static volatile b:Z


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 1
    const-wide v0, -0x99a40dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    new-instance v0, Lcom/kousei/framework/r5;

    .line 10
    .line 11
    const/4 v1, 0x0

    .line 12
    invoke-direct {v0, v1}, Lcom/kousei/framework/r5;-><init>(I)V

    .line 13
    .line 14
    .line 15
    sput-object v0, Landroid/security/kaorios/KaoriosHook;->a:Lcom/kousei/framework/r5;

    .line 16
    .line 17
    const/4 v0, 0x0

    .line 18
    sput-boolean v0, Landroid/security/kaorios/KaoriosHook;->b:Z

    .line 19
    .line 20
    return-void
.end method

.method public constructor <init>()V
    .registers 1

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method public static CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;
    .registers 7

    .line 1
    sget-object v0, Landroid/security/kaorios/KaoriosHook;->a:Lcom/kousei/framework/r5;

    .line 2
    .line 3
    if-eqz p0, :cond_66

    .line 4
    .line 5
    array-length v1, p0

    .line 6
    if-nez v1, :cond_8

    .line 7
    .line 8
    goto :goto_66

    .line 9
    :cond_8
    invoke-virtual {v0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    check-cast v1, Ljava/lang/Boolean;

    .line 14
    .line 15
    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    .line 16
    .line 17
    .line 18
    move-result v1

    .line 19
    if-eqz v1, :cond_15

    .line 20
    .line 21
    return-object p0

    .line 22
    :cond_15
    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    .line 23
    .line 24
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 25
    .line 26
    .line 27
    :try_start_1a
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 28
    .line 29
    .line 30
    move-result v1

    .line 31
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    .line 32
    .line 33
    .line 34
    move-result-object v2

    .line 35
    invoke-interface {v2, v1}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 36
    .line 37
    .line 38
    move-result-object v2

    .line 39
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 40
    .line 41
    .line 42
    move-result-object v3

    .line 43
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 44
    .line 45
    .line 46
    move-result-object v4

    .line 47
    const/4 v5, 0x0

    .line 48
    invoke-virtual {v4, v5}, Lcom/kousei/framework/b7;->k(Z)V

    .line 49
    .line 50
    .line 51
    iget-object v4, v4, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 52
    .line 53
    new-instance v5, Lcom/kousei/framework/m0;

    .line 54
    .line 55
    invoke-direct {v5, v4, v2}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/m0;[Ljava/lang/String;)V

    .line 56
    .line 57
    .line 58
    iget-object v4, v5, Lcom/kousei/framework/m0;->a:Lcom/kousei/framework/u5;

    .line 59
    .line 60
    iget-object v4, v4, Lcom/kousei/framework/u5;->a:Ljava/util/Map;

    .line 61
    .line 62
    invoke-interface {v4}, Ljava/util/Map;->isEmpty()Z

    .line 63
    .line 64
    .line 65
    move-result v4
    :try_end_41
    .catch Ljava/lang/Exception; {:try_start_1a .. :try_end_41} :catch_43
    .catchall {:try_start_1a .. :try_end_41} :catchall_5f

    .line 66
    if-eqz v4, :cond_49

    .line 67
    .line 68
    :catch_43
    :cond_43
    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 69
    .line 70
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 71
    .line 72
    .line 73
    return-object p0

    .line 74
    :cond_49
    :try_start_49
    iget-object v4, v5, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 75
    .line 76
    check-cast v4, Lcom/kousei/framework/m0;

    .line 77
    .line 78
    invoke-virtual {v3, v4, v1, v2}, Lcom/kousei/framework/b7;->e(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z

    .line 79
    .line 80
    .line 81
    move-result v1

    .line 82
    if-eqz v1, :cond_43

    .line 83
    .line 84
    invoke-static {v5, p0}, Lcom/kousei/framework/m1;->e(Lcom/kousei/framework/m0;[Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;

    .line 85
    .line 86
    .line 87
    move-result-object v1
    :try_end_57
    .catch Ljava/lang/Exception; {:try_start_49 .. :try_end_57} :catch_43
    .catchall {:try_start_49 .. :try_end_57} :catchall_5f

    .line 88
    if-eqz v1, :cond_43

    .line 89
    .line 90
    sget-object p0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 91
    .line 92
    invoke-virtual {v0, p0}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 93
    .line 94
    .line 95
    return-object v1

    .line 96
    :catchall_5f
    move-exception p0

    .line 97
    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    .line 98
    .line 99
    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 100
    .line 101
    .line 102
    throw p0

    .line 103
    :cond_66
    :goto_66
    return-object p0
.end method

.method public static OnGetKeyEntry(Landroid/system/keystore2/KeyDescriptor;)Landroid/system/keystore2/KeyEntryResponse;
    .registers 1

    .line 1
    const/4 p0, 0x0

    .line 2
    return-object p0
.end method

.method public static Remove(ILjava/lang/String;)V
    .registers 4

    .line 1
    sget-object v0, Lcom/kousei/framework/b6;->a:Ljava/util/concurrent/ConcurrentHashMap;

    .line 2
    .line 3
    new-instance v1, Lcom/kousei/framework/a6;

    .line 4
    .line 5
    invoke-direct {v1, p0, p1}, Lcom/kousei/framework/a6;-><init>(ILjava/lang/String;)V

    .line 6
    .line 7
    .line 8
    invoke-virtual {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 9
    .line 10
    .line 11
    return-void
.end method

.method public static a(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/String;II[Ljava/lang/String;Lcom/kousei/framework/m0;)Lcom/kousei/framework/l1;
    .registers 16

    const-wide v0, -0x96d40dbb5469L

    const/4 v2, 0x0

    .line 1
    :try_start_6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    move-result-object v0

    .line 2
    invoke-virtual {v0, v2}, Ljava/security/KeyStore;->load(Ljava/security/KeyStore$LoadStoreParameter;)V

    .line 3
    invoke-virtual {v0, p2}, Ljava/security/KeyStore;->getCertificate(Ljava/lang/String;)Ljava/security/cert/Certificate;

    move-result-object v0

    .line 4
    instance-of v1, v0, Ljava/security/cert/X509Certificate;

    if-nez v1, :cond_1b

    goto/16 :goto_157

    .line 5
    :cond_1b
    check-cast v0, Ljava/security/cert/X509Certificate;

    .line 6
    invoke-virtual {v0}, Ljava/security/cert/Certificate;->getPublicKey()Ljava/security/PublicKey;

    move-result-object v1

    invoke-interface {v1}, Ljava/security/Key;->getAlgorithm()Ljava/lang/String;

    move-result-object v1

    .line 7
    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->d(Ljava/lang/String;)Ljava/security/KeyPair;

    move-result-object v3

    if-nez v3, :cond_2d

    goto/16 :goto_157

    .line 8
    :cond_2d
    new-instance v4, Lcom/kousei/framework/i1;

    invoke-direct {v4}, Lcom/kousei/framework/i1;-><init>()V

    if-eqz p5, :cond_3b

    .line 9
    invoke-virtual {p5}, [Ljava/lang/String;->clone()Ljava/lang/Object;

    move-result-object p5

    check-cast p5, [Ljava/lang/String;

    goto :goto_3c

    :cond_3b
    move-object p5, v2

    :goto_3c
    iput-object p5, v4, Lcom/kousei/framework/i1;->w:[Ljava/lang/String;

    const-wide v5, -0x96e40dbb5469L

    .line 10
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p5

    invoke-virtual {p5, v1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p5

    const/4 v5, 0x0

    const/4 v6, 0x1

    if-nez p5, :cond_61

    const-wide v7, -0x96f90dbb5469L

    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p5

    invoke-virtual {p5, v1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p5

    if-eqz p5, :cond_5f

    goto :goto_61

    :cond_5f
    move p5, v5

    goto :goto_62

    :cond_61
    :goto_61
    move p5, v6

    :goto_62
    if-eqz p5, :cond_66

    const/4 v1, 0x3

    goto :goto_67

    :cond_66
    move v1, v6

    .line 11
    :goto_67
    iput v1, v4, Lcom/kousei/framework/i1;->b:I

    if-eqz p5, :cond_6e

    const/16 p5, 0x100

    goto :goto_70

    :cond_6e
    const/16 p5, 0x800

    .line 12
    :goto_70
    iput p5, v4, Lcom/kousei/framework/i1;->a:I

    .line 13
    new-instance p5, Ljavax/security/auth/x500/X500Principal;

    .line 14
    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getSubjectX500Principal()Ljavax/security/auth/x500/X500Principal;

    move-result-object v1

    invoke-virtual {v1}, Ljavax/security/auth/x500/X500Principal;->getEncoded()[B

    move-result-object v1

    invoke-direct {p5, v1}, Ljavax/security/auth/x500/X500Principal;-><init>([B)V

    iput-object p5, v4, Lcom/kousei/framework/i1;->f:Ljavax/security/auth/x500/X500Principal;

    .line 15
    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getSerialNumber()Ljava/math/BigInteger;

    move-result-object p5

    iput-object p5, v4, Lcom/kousei/framework/i1;->c:Ljava/math/BigInteger;

    .line 16
    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getNotBefore()Ljava/util/Date;

    move-result-object p5

    iput-object p5, v4, Lcom/kousei/framework/i1;->d:Ljava/util/Date;

    .line 17
    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getNotAfter()Ljava/util/Date;

    move-result-object p5

    iput-object p5, v4, Lcom/kousei/framework/i1;->e:Ljava/util/Date;

    .line 18
    iget-object p5, v4, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    const/4 v1, 0x7

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {p5, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 19
    iget-object p5, v4, Lcom/kousei/framework/i1;->k:Ljava/util/ArrayList;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {p5, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 20
    iput v6, v4, Lcom/kousei/framework/i1;->h:I

    .line 21
    new-instance p5, Ljava/lang/StringBuilder;

    invoke-direct {p5}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v7, -0x96ff0dbb5469L

    invoke-static {v7, v8}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v7

    invoke-virtual {p5, v7, v8}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    invoke-virtual {p5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p5

    sget-object v1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    .line 22
    invoke-virtual {p5, v1}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object p5

    iput-object p5, v4, Lcom/kousei/framework/i1;->q:[B

    .line 23
    invoke-static {p6, v3, v4, p3, p4}, Lcom/kousei/framework/j1;->f(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;II)Ljava/util/ArrayList;

    move-result-object p3

    if-eqz p3, :cond_157

    .line 24
    invoke-virtual {p3}, Ljava/util/ArrayList;->isEmpty()Z

    move-result p4

    if-eqz p4, :cond_db

    goto/16 :goto_157

    :cond_db
    const-wide p4, -0x96010dbb5469L

    .line 25
    invoke-static {p4, p5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p4

    invoke-static {p0, p4}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/security/KeyStore2;

    if-nez p0, :cond_ed

    goto :goto_157

    .line 26
    :cond_ed
    check-cast p1, Landroid/system/keystore2/KeyDescriptor;

    .line 27
    new-instance p4, Landroid/system/keystore2/KeyDescriptor;

    invoke-direct {p4}, Landroid/system/keystore2/KeyDescriptor;-><init>()V

    .line 28
    iput-object p2, p4, Landroid/system/keystore2/KeyDescriptor;->alias:Ljava/lang/String;

    if-eqz p1, :cond_101

    .line 29
    iget p5, p1, Landroid/system/keystore2/KeyDescriptor;->domain:I

    iput p5, p4, Landroid/system/keystore2/KeyDescriptor;->domain:I

    .line 30
    iget-wide p5, p1, Landroid/system/keystore2/KeyDescriptor;->nspace:J

    iput-wide p5, p4, Landroid/system/keystore2/KeyDescriptor;->nspace:J

    goto :goto_107

    .line 31
    :cond_101
    iput v5, p4, Landroid/system/keystore2/KeyDescriptor;->domain:I

    const-wide/16 p5, -0x1

    .line 32
    iput-wide p5, p4, Landroid/system/keystore2/KeyDescriptor;->nspace:J

    .line 33
    :goto_107
    iput-object v2, p4, Landroid/system/keystore2/KeyDescriptor;->blob:[B

    .line 34
    invoke-virtual {p3, v5}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/security/cert/Certificate;

    invoke-virtual {p1}, Ljava/security/cert/Certificate;->getEncoded()[B

    move-result-object p1

    .line 35
    invoke-virtual {p3}, Ljava/util/ArrayList;->size()I

    move-result p5

    if-le p5, v6, :cond_126

    .line 36
    invoke-virtual {p3}, Ljava/util/ArrayList;->size()I

    move-result p5

    invoke-virtual {p3, v6, p5}, Ljava/util/ArrayList;->subList(II)Ljava/util/List;

    move-result-object p3

    invoke-static {p3}, Landroid/security/kaorios/KaoriosHook;->c(Ljava/util/List;)[B

    move-result-object p3
    :try_end_125
    .catchall {:try_start_6 .. :try_end_125} :catchall_157

    goto :goto_127

    :cond_126
    move-object p3, v2

    .line 37
    :goto_127
    :try_start_127
    invoke-virtual {p0, p4, p1, p3}, Landroid/security/KeyStore2;->updateSubcomponents(Landroid/system/keystore2/KeyDescriptor;[B[B)V
    :try_end_12a
    .catchall {:try_start_127 .. :try_end_12a} :catchall_157

    .line 38
    :try_start_12a
    new-instance p0, Lcom/kousei/framework/va;

    .line 39
    invoke-virtual {v0}, Ljava/security/cert/X509Certificate;->getSubjectX500Principal()Ljavax/security/auth/x500/X500Principal;

    move-result-object p1

    const-wide p3, -0x961b0dbb5469L

    invoke-static {p3, p4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p3

    invoke-virtual {p1, p3}, Ljavax/security/auth/x500/X500Principal;->getName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lcom/kousei/framework/va;-><init>(Ljava/lang/String;)V

    if-eqz p2, :cond_150

    .line 40
    sget-object p1, Lcom/kousei/framework/m1;->b:Ljava/util/concurrent/ConcurrentHashMap;

    new-instance p3, Lcom/kousei/framework/l1;

    invoke-direct {p3, v3, p0}, Lcom/kousei/framework/l1;-><init>(Ljava/security/KeyPair;Lcom/kousei/framework/va;)V

    invoke-virtual {p1, p2, p3}, Ljava/util/concurrent/ConcurrentHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/kousei/framework/l1;

    goto :goto_152

    .line 41
    :cond_150
    sget-object p0, Lcom/kousei/framework/m1;->a:Ljava/util/concurrent/ConcurrentHashMap;

    .line 42
    :goto_152
    invoke-static {p2}, Lcom/kousei/framework/m1;->i(Ljava/lang/String;)Lcom/kousei/framework/l1;

    move-result-object p0
    :try_end_156
    .catchall {:try_start_12a .. :try_end_156} :catchall_157

    return-object p0

    :catchall_157
    :cond_157
    :goto_157
    return-object v2
.end method

.method public static b(Ljava/lang/Object;Ljava/lang/Object;Ljava/security/KeyPair;Lcom/kousei/framework/i1;IILjava/lang/String;Ljava/lang/String;ZLcom/kousei/framework/m0;)Ljava/util/ArrayList;
    .registers 17

    move-object/from16 v6, p9

    if-eqz p8, :cond_41

    .line 1
    :try_start_4
    invoke-static {v6, p2, p3, p4, p5}, Lcom/kousei/framework/j1;->f(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;II)Ljava/util/ArrayList;

    move-result-object p0

    if-eqz p0, :cond_40

    .line 2
    invoke-virtual {p0}, Ljava/util/ArrayList;->isEmpty()Z

    move-result p1
    :try_end_e
    .catchall {:try_start_4 .. :try_end_e} :catchall_8e

    if-eqz p1, :cond_11

    goto :goto_40

    :cond_11
    const/4 p1, 0x0

    .line 3
    :try_start_12
    invoke-virtual {p0, p1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/security/cert/X509Certificate;

    .line 4
    new-instance p3, Lcom/kousei/framework/va;

    .line 5
    invoke-virtual {p1}, Ljava/security/cert/X509Certificate;->getSubjectX500Principal()Ljavax/security/auth/x500/X500Principal;

    move-result-object p1

    const-wide p4, -0x96dc0dbb5469L

    invoke-static {p4, p5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object p4

    invoke-virtual {p1, p4}, Ljavax/security/auth/x500/X500Principal;->getName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-direct {p3, p1}, Lcom/kousei/framework/va;-><init>(Ljava/lang/String;)V

    if-eqz p6, :cond_3e

    .line 6
    sget-object p1, Lcom/kousei/framework/m1;->b:Ljava/util/concurrent/ConcurrentHashMap;

    new-instance p4, Lcom/kousei/framework/l1;

    invoke-direct {p4, p2, p3}, Lcom/kousei/framework/l1;-><init>(Ljava/security/KeyPair;Lcom/kousei/framework/va;)V

    invoke-virtual {p1, p6, p4}, Ljava/util/concurrent/ConcurrentHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lcom/kousei/framework/l1;

    return-object p0

    .line 7
    :cond_3e
    sget-object p1, Lcom/kousei/framework/m1;->a:Ljava/util/concurrent/ConcurrentHashMap;
    :try_end_40
    .catchall {:try_start_12 .. :try_end_40} :catchall_40

    :catchall_40
    :cond_40
    :goto_40
    return-object p0

    :cond_41
    if-eqz p7, :cond_89

    .line 8
    :try_start_43
    invoke-static {p7}, Lcom/kousei/framework/m1;->i(Ljava/lang/String;)Lcom/kousei/framework/l1;

    move-result-object v0

    if-eqz v0, :cond_51

    .line 9
    iget-object v1, v0, Lcom/kousei/framework/l1;->a:Ljava/security/KeyPair;

    if-eqz v1, :cond_51

    iget-object v1, v0, Lcom/kousei/framework/l1;->b:Lcom/kousei/framework/va;

    if-nez v1, :cond_5c

    .line 10
    :cond_51
    iget-object v5, p3, Lcom/kousei/framework/i1;->w:[Ljava/lang/String;

    move-object v0, p0

    move-object v1, p1

    move v3, p4

    move v4, p5

    move-object v2, p7

    invoke-static/range {v0 .. v6}, Landroid/security/kaorios/KaoriosHook;->a(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/String;II[Ljava/lang/String;Lcom/kousei/framework/m0;)Lcom/kousei/framework/l1;

    move-result-object v0
    :try_end_5c
    .catchall {:try_start_43 .. :try_end_5c} :catchall_8e

    :cond_5c
    if-eqz v0, :cond_87

    .line 11
    :try_start_5e
    iget-object p0, v0, Lcom/kousei/framework/l1;->a:Ljava/security/KeyPair;

    if-eqz p0, :cond_87

    iget-object p1, v0, Lcom/kousei/framework/l1;->b:Lcom/kousei/framework/va;

    if-eqz p1, :cond_87

    .line 12
    invoke-virtual {p0}, Ljava/security/KeyPair;->getPrivate()Ljava/security/PrivateKey;

    move-result-object v6

    .line 13
    iget-object v5, v0, Lcom/kousei/framework/l1;->b:Lcom/kousei/framework/va;
    :try_end_6c
    .catchall {:try_start_5e .. :try_end_6c} :catchall_84

    move-object v1, p2

    move-object v2, p3

    move v3, p4

    move v4, p5

    move-object/from16 v0, p9

    .line 14
    :try_start_72
    invoke-static/range {v0 .. v6}, Lcom/kousei/framework/j1;->c(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;IILcom/kousei/framework/va;Ljava/security/PrivateKey;)Ljava/security/cert/X509Certificate;

    move-result-object p0
    :try_end_76
    .catchall {:try_start_72 .. :try_end_76} :catchall_82

    move-object v6, v0

    if-eqz p0, :cond_89

    .line 15
    :try_start_79
    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    .line 16
    invoke-virtual {p1, p0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object p1

    :catchall_82
    move-object v6, v0

    goto :goto_8e

    :catchall_84
    move-object/from16 v6, p9

    goto :goto_8e

    :cond_87
    move-object/from16 v6, p9

    .line 17
    :cond_89
    invoke-static {v6, p2, p3, p4, p5}, Lcom/kousei/framework/j1;->f(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;II)Ljava/util/ArrayList;

    move-result-object p0
    :try_end_8d
    .catchall {:try_start_79 .. :try_end_8d} :catchall_8e

    return-object p0

    .line 18
    :catchall_8e
    :goto_8e
    :try_start_8e
    invoke-static {v6, p2, p3, p4, p5}, Lcom/kousei/framework/j1;->f(Lcom/kousei/framework/m0;Ljava/security/KeyPair;Lcom/kousei/framework/i1;II)Ljava/util/ArrayList;

    move-result-object p0
    :try_end_92
    .catchall {:try_start_8e .. :try_end_92} :catchall_93

    return-object p0

    :catchall_93
    const/4 p0, 0x0

    return-object p0
.end method

.method public static c(Ljava/util/List;)[B
    .registers 3

    .line 1
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    .line 2
    .line 3
    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 4
    .line 5
    .line 6
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    .line 7
    .line 8
    .line 9
    move-result-object p0

    .line 10
    :goto_9
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    .line 11
    .line 12
    .line 13
    move-result v1

    .line 14
    if-eqz v1, :cond_1d

    .line 15
    .line 16
    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 17
    .line 18
    .line 19
    move-result-object v1

    .line 20
    check-cast v1, Ljava/security/cert/Certificate;

    .line 21
    .line 22
    invoke-virtual {v1}, Ljava/security/cert/Certificate;->getEncoded()[B

    .line 23
    .line 24
    .line 25
    move-result-object v1

    .line 26
    invoke-virtual {v0, v1}, Ljava/io/OutputStream;->write([B)V

    .line 27
    .line 28
    .line 29
    goto :goto_9

    .line 30
    :cond_1d
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    .line 31
    .line 32
    .line 33
    move-result-object p0

    .line 34
    return-object p0
.end method

.method public static d(Ljava/lang/String;)Ljava/security/KeyPair;
    .registers 4

    .line 1
    const-wide v0, -0x96130dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    :try_start_5
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 11
    .line 12
    .line 13
    move-result v0

    .line 14
    if-nez v0, :cond_68

    .line 15
    .line 16
    const-wide v0, -0x96140dbb5469L

    .line 17
    .line 18
    .line 19
    .line 20
    .line 21
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 26
    .line 27
    .line 28
    move-result v0

    .line 29
    if-eqz v0, :cond_1f

    .line 30
    .line 31
    goto :goto_68

    .line 32
    :cond_1f
    const-wide v0, -0x96390dbb5469L

    .line 33
    .line 34
    .line 35
    .line 36
    .line 37
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 38
    .line 39
    .line 40
    move-result-object v0

    .line 41
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 42
    .line 43
    .line 44
    move-result p0

    .line 45
    if-eqz p0, :cond_45

    .line 46
    .line 47
    const-wide v0, -0x963d0dbb5469L

    .line 48
    .line 49
    .line 50
    .line 51
    .line 52
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 53
    .line 54
    .line 55
    move-result-object p0

    .line 56
    invoke-static {p0}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 57
    .line 58
    .line 59
    move-result-object p0

    .line 60
    const/16 v0, 0x800

    .line 61
    .line 62
    invoke-virtual {p0, v0}, Ljava/security/KeyPairGenerator;->initialize(I)V

    .line 63
    .line 64
    .line 65
    invoke-virtual {p0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;

    .line 66
    .line 67
    .line 68
    move-result-object p0

    .line 69
    return-object p0

    .line 70
    :cond_45
    const-wide v0, -0x96310dbb5469L

    .line 71
    .line 72
    .line 73
    .line 74
    .line 75
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 76
    .line 77
    .line 78
    move-result-object p0

    .line 79
    invoke-static {p0}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 80
    .line 81
    .line 82
    move-result-object p0

    .line 83
    new-instance v0, Ljava/security/spec/ECGenParameterSpec;

    .line 84
    .line 85
    const-wide v1, -0x96320dbb5469L

    .line 86
    .line 87
    .line 88
    .line 89
    .line 90
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 91
    .line 92
    .line 93
    move-result-object v1

    .line 94
    invoke-direct {v0, v1}, Ljava/security/spec/ECGenParameterSpec;-><init>(Ljava/lang/String;)V

    .line 95
    .line 96
    .line 97
    invoke-virtual {p0, v0}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 98
    .line 99
    .line 100
    invoke-virtual {p0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;

    .line 101
    .line 102
    .line 103
    move-result-object p0

    .line 104
    return-object p0

    .line 105
    :cond_68
    :goto_68
    const-wide v0, -0x962a0dbb5469L

    .line 106
    .line 107
    .line 108
    .line 109
    .line 110
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 111
    .line 112
    .line 113
    move-result-object p0

    .line 114
    invoke-static {p0}, Ljava/security/KeyPairGenerator;->getInstance(Ljava/lang/String;)Ljava/security/KeyPairGenerator;

    .line 115
    .line 116
    .line 117
    move-result-object p0

    .line 118
    new-instance v0, Ljava/security/spec/ECGenParameterSpec;

    .line 119
    .line 120
    const-wide v1, -0x962f0dbb5469L

    .line 121
    .line 122
    .line 123
    .line 124
    .line 125
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 126
    .line 127
    .line 128
    move-result-object v1

    .line 129
    invoke-direct {v0, v1}, Ljava/security/spec/ECGenParameterSpec;-><init>(Ljava/lang/String;)V

    .line 130
    .line 131
    .line 132
    invoke-virtual {p0, v0}, Ljava/security/KeyPairGenerator;->initialize(Ljava/security/spec/AlgorithmParameterSpec;)V

    .line 133
    .line 134
    .line 135
    invoke-virtual {p0}, Ljava/security/KeyPairGenerator;->generateKeyPair()Ljava/security/KeyPair;

    .line 136
    .line 137
    .line 138
    move-result-object p0
    :try_end_8a
    .catchall {:try_start_5 .. :try_end_8a} :catchall_8b

    .line 139
    return-object p0

    .line 140
    :catchall_8b
    const/4 p0, 0x0

    .line 141
    return-object p0
.end method

.method public static e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    .registers 6

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p0, :cond_8

    .line 3
    .line 4
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 5
    .line 6
    .line 7
    move-result-object v1

    .line 8
    goto :goto_9

    .line 9
    :cond_8
    move-object v1, v0

    .line 10
    :goto_9
    if-eqz v1, :cond_1d

    .line 11
    .line 12
    :try_start_b
    invoke-virtual {v1, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    .line 13
    .line 14
    .line 15
    move-result-object v2

    .line 16
    const/4 v3, 0x1

    .line 17
    invoke-virtual {v2, v3}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    .line 18
    .line 19
    .line 20
    invoke-virtual {v2, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 21
    .line 22
    .line 23
    move-result-object p0
    :try_end_17
    .catch Ljava/lang/NoSuchFieldException; {:try_start_b .. :try_end_17} :catch_18
    .catchall {:try_start_b .. :try_end_17} :catchall_1d

    .line 24
    return-object p0

    .line 25
    :catch_18
    invoke-virtual {v1}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    .line 26
    .line 27
    .line 28
    move-result-object v1

    .line 29
    goto :goto_9

    .line 30
    :catchall_1d
    :cond_1d
    return-object v0
.end method

.method public static f(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    .registers 6

    .line 1
    const/4 v0, 0x0

    .line 2
    if-eqz p0, :cond_1f

    .line 3
    .line 4
    if-nez p1, :cond_6

    .line 5
    .line 6
    goto :goto_1f

    .line 7
    :cond_6
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 8
    .line 9
    .line 10
    move-result-object v1

    .line 11
    :goto_a
    if-eqz v1, :cond_1f

    .line 12
    .line 13
    :try_start_c
    invoke-virtual {v1, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    .line 14
    .line 15
    .line 16
    move-result-object v2

    .line 17
    const/4 v3, 0x1

    .line 18
    invoke-virtual {v2, v3}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    .line 19
    .line 20
    .line 21
    invoke-virtual {v2, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 22
    .line 23
    .line 24
    move-result-object p0
    :try_end_18
    .catch Ljava/lang/NoSuchFieldException; {:try_start_c .. :try_end_18} :catch_1a
    .catchall {:try_start_c .. :try_end_18} :catchall_19

    .line 25
    return-object p0

    .line 26
    :catchall_19
    return-object v0

    .line 27
    :catch_1a
    invoke-virtual {v1}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    .line 28
    .line 29
    .line 30
    move-result-object v1

    .line 31
    goto :goto_a

    .line 32
    :cond_1f
    :goto_1f
    return-object v0
.end method

.method public static filterInstallerPackageName(Landroid/content/ContentResolver;IILjava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 5

    .line 1
    :try_start_0
    invoke-static {p0, p1, p2, p3, p4}, Lcom/kousei/framework/e5;->a(Landroid/content/ContentResolver;IILjava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 2
    .line 3
    .line 4
    move-result-object p0
    :try_end_4
    .catchall {:try_start_0 .. :try_end_4} :catchall_5

    .line 5
    return-object p0

    .line 6
    :catchall_5
    return-object p4
.end method

.method public static filterSettingValue(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 1
    :try_start_0
    invoke-static {p1, p2}, Lcom/kousei/framework/i0;->b(Ljava/lang/String;Ljava/lang/String;)Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_b

    .line 6
    .line 7
    invoke-static {p1, p2}, Lcom/kousei/framework/i0;->a(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 8
    .line 9
    .line 10
    move-result-object p0

    .line 11
    return-object p0

    .line 12
    :cond_b
    sget-object v0, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 13
    .line 14
    if-eqz p1, :cond_43

    .line 15
    .line 16
    if-nez p2, :cond_12

    .line 17
    .line 18
    goto :goto_43

    .line 19
    :cond_12
    sget-object v0, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 20
    .line 21
    invoke-virtual {v0, p0}, Lcom/kousei/framework/e5;->b(Landroid/content/ContentResolver;)Lcom/kousei/framework/c5;

    .line 22
    .line 23
    .line 24
    move-result-object v1

    .line 25
    invoke-virtual {v1}, Lcom/kousei/framework/c5;->d()Z

    .line 26
    .line 27
    .line 28
    move-result v1

    .line 29
    if-nez v1, :cond_1f

    .line 30
    .line 31
    goto :goto_43

    .line 32
    :cond_1f
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 33
    .line 34
    .line 35
    move-result v1

    .line 36
    if-gtz v1, :cond_26

    .line 37
    .line 38
    goto :goto_43

    .line 39
    :cond_26
    iget-object v0, v0, Lcom/kousei/framework/e5;->a:Lcom/kousei/framework/c5;

    .line 40
    .line 41
    invoke-virtual {v0, v1, p1, p2}, Lcom/kousei/framework/c5;->c(ILjava/lang/String;Ljava/lang/String;)Lcom/kousei/framework/a5;

    .line 42
    .line 43
    .line 44
    move-result-object v0

    .line 45
    if-eqz v0, :cond_43

    .line 46
    .line 47
    iget-object v1, v0, Lcom/kousei/framework/a5;->a:Ljava/lang/String;

    .line 48
    .line 49
    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 50
    .line 51
    .line 52
    move-result v1

    .line 53
    if-eqz v1, :cond_43

    .line 54
    .line 55
    iget-object v1, v0, Lcom/kousei/framework/a5;->b:Ljava/lang/String;

    .line 56
    .line 57
    invoke-virtual {v1, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 58
    .line 59
    .line 60
    move-result v1

    .line 61
    if-eqz v1, :cond_43

    .line 62
    .line 63
    iget-object v0, v0, Lcom/kousei/framework/a5;->c:Ljava/lang/String;

    .line 64
    .line 65
    if-eqz v0, :cond_43

    .line 66
    .line 67
    goto :goto_44

    .line 68
    :cond_43
    :goto_43
    move-object v0, p3

    .line 69
    :goto_44
    invoke-static {p0, p1, p2, v0}, Lcom/kousei/framework/ga;->a(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 70
    .line 71
    .line 72
    move-result-object p0
    :try_end_48
    .catchall {:try_start_0 .. :try_end_48} :catchall_49

    .line 73
    return-object p0

    .line 74
    :catchall_49
    return-object p3
.end method

.method public static g(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;Lcom/kousei/framework/m0;)Ljava/security/KeyPair;
    .registers 25

    move-object/from16 v0, p0

    move-object/from16 v10, p1

    move-object/from16 v9, p3

    const-wide v1, -0x97a30dbb5469L

    .line 1
    :try_start_b
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    move-object v6, v1

    check-cast v6, Ljava/lang/String;

    .line 2
    invoke-static {v6}, Landroid/security/kaorios/KaoriosHook;->h(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_20

    :catch_1c
    :goto_1c
    const/16 v16, 0x0

    goto/16 :goto_485

    .line 3
    :cond_20
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    move-result v5

    .line 4
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    move-result-object v1

    invoke-interface {v1, v5}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    move-result-object v1

    .line 5
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    move-result-object v2

    .line 6
    iget-object v3, v9, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    check-cast v3, Lcom/kousei/framework/m0;

    .line 7
    invoke-virtual {v2, v3, v5, v1}, Lcom/kousei/framework/b7;->d(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_3b

    goto :goto_1c

    :cond_3b
    const-wide v2, -0x97bf0dbb5469L

    .line 8
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    .line 9
    invoke-static {v0, v2}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    .line 10
    instance-of v3, v2, Ljava/lang/Number;

    if-eqz v3, :cond_53

    .line 11
    check-cast v2, Ljava/lang/Number;

    invoke-virtual {v2}, Ljava/lang/Number;->intValue()I

    move-result v2

    goto :goto_55

    :cond_53
    const/16 v2, 0x100

    :goto_55
    const-wide v3, -0x97ca0dbb5469L

    .line 12
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v3

    .line 13
    invoke-static {v0, v3}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    .line 14
    instance-of v4, v3, Ljava/lang/Number;

    if-eqz v4, :cond_6e

    .line 15
    check-cast v3, Ljava/lang/Number;

    invoke-virtual {v3}, Ljava/lang/Number;->intValue()I

    move-result v3

    move v13, v3

    goto :goto_6f

    :cond_6e
    const/4 v13, 0x3

    :goto_6f
    const-wide v3, -0x97de0dbb5469L

    .line 16
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v3}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/security/keystore/KeyGenParameterSpec;

    move-object v4, v3

    .line 17
    new-instance v3, Lcom/kousei/framework/i1;

    invoke-direct {v3}, Lcom/kousei/framework/i1;-><init>()V

    iget-object v7, v3, Lcom/kousei/framework/i1;->m:Ljava/util/ArrayList;

    iget-object v8, v3, Lcom/kousei/framework/i1;->j:Ljava/util/ArrayList;

    iget-object v14, v3, Lcom/kousei/framework/i1;->l:Ljava/util/ArrayList;

    if-eqz v1, :cond_93

    .line 18
    invoke-virtual {v1}, [Ljava/lang/String;->clone()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    goto :goto_94

    :cond_93
    const/4 v1, 0x0

    :goto_94
    iput-object v1, v3, Lcom/kousei/framework/i1;->w:[Ljava/lang/String;

    .line 19
    iput v2, v3, Lcom/kousei/framework/i1;->a:I

    .line 20
    iput v13, v3, Lcom/kousei/framework/i1;->b:I

    .line 21
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getCertificateSubject()Ljavax/security/auth/x500/X500Principal;

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->f:Ljavax/security/auth/x500/X500Principal;

    .line 22
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getCertificateSerialNumber()Ljava/math/BigInteger;

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->c:Ljava/math/BigInteger;

    .line 23
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getCertificateNotBefore()Ljava/util/Date;

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->d:Ljava/util/Date;

    .line 24
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getCertificateNotAfter()Ljava/util/Date;

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->e:Ljava/util/Date;

    const-wide v1, -0x97d40dbb5469L

    .line 25
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    .line 26
    instance-of v2, v1, Ljava/lang/Number;

    if-eqz v2, :cond_d0

    .line 27
    check-cast v1, Ljava/lang/Number;

    invoke-virtual {v1}, Ljava/lang/Number;->longValue()J

    move-result-wide v1

    invoke-static {v1, v2}, Ljava/math/BigInteger;->valueOf(J)Ljava/math/BigInteger;

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->g:Ljava/math/BigInteger;

    goto :goto_d8

    .line 28
    :cond_d0
    instance-of v2, v1, Ljava/math/BigInteger;

    if-eqz v2, :cond_d8

    .line 29
    check-cast v1, Ljava/math/BigInteger;

    iput-object v1, v3, Lcom/kousei/framework/i1;->g:Ljava/math/BigInteger;

    :cond_d8
    :goto_d8
    const-wide v1, -0x97f90dbb5469L

    .line 30
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    .line 31
    instance-of v2, v1, Ljava/lang/String;

    const/4 v15, 0x1

    if-eqz v2, :cond_ef

    .line 32
    check-cast v1, Ljava/lang/String;

    iput-object v1, v3, Lcom/kousei/framework/i1;->i:Ljava/lang/String;

    goto :goto_fe

    .line 33
    :cond_ef
    instance-of v2, v1, Ljava/lang/Number;

    if-eqz v2, :cond_fc

    .line 34
    check-cast v1, Ljava/lang/Number;

    invoke-virtual {v1}, Ljava/lang/Number;->intValue()I

    move-result v1

    iput v1, v3, Lcom/kousei/framework/i1;->h:I

    goto :goto_fe

    .line 35
    :cond_fc
    iput v15, v3, Lcom/kousei/framework/i1;->h:I

    .line 36
    :goto_fe
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getAttestationChallenge()[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->q:[B

    if-eqz v1, :cond_10f

    .line 37
    array-length v1, v1

    .line 38
    invoke-static {}, Lcom/kousei/framework/n0;->b()I

    move-result v2

    if-le v1, v2, :cond_10f

    goto/16 :goto_1c

    :cond_10f
    const-wide v1, -0x97f40dbb5469L

    .line 39
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    .line 40
    instance-of v2, v1, [I

    if-eqz v2, :cond_139

    .line 41
    check-cast v1, [I

    array-length v2, v1

    const/4 v11, 0x0

    const/16 v17, 0x0

    :goto_126
    if-ge v11, v2, :cond_136

    aget v18, v1, v11

    const/16 v19, 0x3

    invoke-static/range {v18 .. v18}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    invoke-virtual {v8, v12}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    add-int/lit8 v11, v11, 0x1

    goto :goto_126

    :cond_136
    :goto_136
    const/16 v19, 0x3

    goto :goto_13c

    :cond_139
    const/16 v17, 0x0

    goto :goto_136

    :goto_13c
    const-wide v1, -0x97190dbb5469L

    .line 42
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    .line 43
    instance-of v2, v1, [I

    if-eqz v2, :cond_166

    .line 44
    check-cast v1, [I

    array-length v2, v1

    move/from16 v11, v17

    :goto_152
    if-ge v11, v2, :cond_166

    aget v12, v1, v11

    move/from16 v18, v15

    iget-object v15, v3, Lcom/kousei/framework/i1;->k:Ljava/util/ArrayList;

    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    invoke-virtual {v15, v12}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_161
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_161} :catch_1c

    add-int/lit8 v11, v11, 0x1

    move/from16 v15, v18

    goto :goto_152

    :cond_166
    move/from16 v18, v15

    .line 45
    :try_start_168
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->isUserAuthenticationRequired()Z

    move-result v1

    xor-int/lit8 v1, v1, 0x1

    iput-boolean v1, v3, Lcom/kousei/framework/i1;->n:Z
    :try_end_170
    .catchall {:try_start_168 .. :try_end_170} :catchall_171

    goto :goto_175

    :catchall_171
    move/from16 v1, v18

    .line 46
    :try_start_173
    iput-boolean v1, v3, Lcom/kousei/framework/i1;->n:Z
    :try_end_175
    .catch Ljava/lang/Exception; {:try_start_173 .. :try_end_175} :catch_1c

    .line 47
    :goto_175
    :try_start_175
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getUserAuthenticationValidityDurationSeconds()I

    move-result v1

    if-lez v1, :cond_17d

    .line 48
    iput v1, v3, Lcom/kousei/framework/i1;->p:I

    .line 49
    :cond_17d
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->isUserAuthenticationRequired()Z

    move-result v1

    if-eqz v1, :cond_18a

    .line 50
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getUserAuthenticationType()I

    move-result v1

    int-to-long v1, v1

    iput-wide v1, v3, Lcom/kousei/framework/i1;->o:J
    :try_end_18a
    .catchall {:try_start_175 .. :try_end_18a} :catchall_18a

    .line 51
    :catchall_18a
    :cond_18a
    :try_start_18a
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getEncryptionPaddings()[Ljava/lang/String;

    move-result-object v1

    array-length v2, v1

    move/from16 v12, v17

    :goto_191
    if-ge v12, v2, :cond_1af

    aget-object v15, v1, v12
    :try_end_195
    .catchall {:try_start_18a .. :try_end_195} :catchall_1ab

    const/16 v20, 0x2

    .line 52
    :try_start_197
    iget v11, v3, Lcom/kousei/framework/i1;->b:I

    invoke-static {v11, v15}, Lcom/kousei/framework/i1;->a(ILjava/lang/String;)Ljava/lang/Integer;

    move-result-object v11

    if-eqz v11, :cond_1a8

    .line 53
    invoke-virtual {v14, v11}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v15

    if-nez v15, :cond_1a8

    invoke-virtual {v14, v11}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    :cond_1a8
    add-int/lit8 v12, v12, 0x1

    goto :goto_191

    :catchall_1ab
    const/16 v20, 0x2

    goto/16 :goto_248

    :cond_1af
    const/16 v20, 0x2

    .line 54
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getSignaturePaddings()[Ljava/lang/String;

    move-result-object v1

    array-length v2, v1

    move/from16 v11, v17

    :goto_1b8
    if-ge v11, v2, :cond_1d0

    aget-object v12, v1, v11

    .line 55
    iget v15, v3, Lcom/kousei/framework/i1;->b:I

    invoke-static {v15, v12}, Lcom/kousei/framework/i1;->a(ILjava/lang/String;)Ljava/lang/Integer;

    move-result-object v12

    if-eqz v12, :cond_1cd

    .line 56
    invoke-virtual {v14, v12}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v15

    if-nez v15, :cond_1cd

    invoke-virtual {v14, v12}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    :cond_1cd
    add-int/lit8 v11, v11, 0x1

    goto :goto_1b8

    .line 57
    :cond_1d0
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->getBlockModes()[Ljava/lang/String;

    move-result-object v1

    array-length v2, v1

    move/from16 v11, v17

    :goto_1d7
    if-ge v11, v2, :cond_248

    aget-object v12, v1, v11

    if-nez v12, :cond_1df

    :cond_1dd
    :goto_1dd
    const/4 v12, 0x0

    goto :goto_23a

    .line 58
    :cond_1df
    invoke-virtual {v12}, Ljava/lang/String;->hashCode()I

    move-result v14

    sparse-switch v14, :sswitch_data_486

    goto :goto_1dd

    :sswitch_1e7
    const-wide v14, -0xa0680dbb5469L

    invoke-static {v14, v15}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_1dd

    const/16 v12, 0x20

    .line 59
    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    goto :goto_23a

    :sswitch_1fd
    const-wide v14, -0xa05c0dbb5469L

    .line 60
    invoke-static {v14, v15}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_1dd

    const/16 v18, 0x1

    .line 61
    invoke-static/range {v18 .. v18}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    goto :goto_23a

    :sswitch_213
    const-wide v14, -0xa0540dbb5469L

    .line 62
    invoke-static {v14, v15}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_1dd

    .line 63
    invoke-static/range {v19 .. v19}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    goto :goto_23a

    :sswitch_227
    const-wide v14, -0xa0500dbb5469L

    .line 64
    invoke-static {v14, v15}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_1dd

    .line 65
    invoke-static/range {v20 .. v20}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    :goto_23a
    if-eqz v12, :cond_245

    .line 66
    invoke-virtual {v7, v12}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_245

    invoke-virtual {v7, v12}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_245
    .catchall {:try_start_197 .. :try_end_245} :catchall_248

    :cond_245
    add-int/lit8 v11, v11, 0x1

    goto :goto_1d7

    .line 67
    :catchall_248
    :cond_248
    :goto_248
    :try_start_248
    invoke-static {v4}, Landroid/security/kaorios/KaoriosHook;->j(Landroid/security/keystore/KeyGenParameterSpec;)Ljava/lang/String;

    move-result-object v1

    if-nez v1, :cond_294

    move/from16 v2, v19

    .line 68
    new-array v7, v2, [Ljava/lang/String;

    const-wide v11, -0x972b0dbb5469L

    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    aput-object v2, v7, v17

    const-wide v11, -0x973b0dbb5469L

    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    const/16 v18, 0x1

    aput-object v2, v7, v18

    const-wide v11, -0x97480dbb5469L

    invoke-static {v11, v12}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    aput-object v2, v7, v20

    move/from16 v2, v17

    :goto_277
    const/4 v11, 0x3

    if-ge v2, v11, :cond_294

    aget-object v11, v7, v2
    :try_end_27c
    .catch Ljava/lang/Exception; {:try_start_248 .. :try_end_27c} :catch_1c

    .line 69
    :try_start_27c
    invoke-static {v0, v11}, Landroid/security/kaorios/KaoriosHook;->f(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v11

    .line 70
    instance-of v12, v11, Ljava/lang/String;

    if-eqz v12, :cond_291

    move-object v12, v11

    check-cast v12, Ljava/lang/String;

    invoke-virtual {v12}, Ljava/lang/String;->isEmpty()Z

    move-result v12

    if-nez v12, :cond_291

    .line 71
    check-cast v11, Ljava/lang/String;
    :try_end_28f
    .catchall {:try_start_27c .. :try_end_28f} :catchall_291

    move-object v7, v11

    goto :goto_295

    :catchall_291
    :cond_291
    add-int/lit8 v2, v2, 0x1

    goto :goto_277

    :cond_294
    move-object v7, v1

    :goto_295
    const/4 v1, 0x7

    .line 72
    :try_start_296
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v8, v1}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v8

    .line 73
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->isDevicePropertiesAttestationIncluded()Z

    move-result v1
    :try_end_2a2
    .catch Ljava/lang/Exception; {:try_start_296 .. :try_end_2a2} :catch_1c

    if-eqz v1, :cond_2f6

    .line 74
    :try_start_2a4
    sget-object v1, Landroid/os/Build;->BRAND_FOR_ATTESTATION:Ljava/lang/String;

    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->i(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2ae

    sget-object v1, Landroid/os/Build;->BRAND:Ljava/lang/String;

    .line 75
    :cond_2ae
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->r:[B

    .line 76
    sget-object v1, Landroid/os/Build;->DEVICE_FOR_ATTESTATION:Ljava/lang/String;

    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->i(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_2c0

    sget-object v1, Landroid/os/Build;->DEVICE:Ljava/lang/String;

    .line 77
    :cond_2c0
    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->s:[B

    .line 78
    sget-object v1, Landroid/os/Build;->PRODUCT_FOR_ATTESTATION:Ljava/lang/String;

    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->i(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_2d0

    sget-object v1, Landroid/os/Build;->PRODUCT:Ljava/lang/String;

    .line 79
    :cond_2d0
    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->t:[B

    .line 80
    sget-object v1, Landroid/os/Build;->MANUFACTURER_FOR_ATTESTATION:Ljava/lang/String;

    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->i(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_2e0

    sget-object v1, Landroid/os/Build;->MANUFACTURER:Ljava/lang/String;

    .line 81
    :cond_2e0
    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->u:[B

    .line 82
    sget-object v1, Landroid/os/Build;->MODEL_FOR_ATTESTATION:Ljava/lang/String;

    invoke-static {v1}, Landroid/security/kaorios/KaoriosHook;->i(Ljava/lang/String;)Z

    move-result v11

    if-eqz v11, :cond_2f0

    sget-object v1, Landroid/os/Build;->MODEL:Ljava/lang/String;

    .line 83
    :cond_2f0
    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    iput-object v1, v3, Lcom/kousei/framework/i1;->v:[B
    :try_end_2f6
    .catch Ljava/lang/Exception; {:try_start_2a4 .. :try_end_2f6} :catch_2f6

    .line 84
    :catch_2f6
    :cond_2f6
    :try_start_2f6
    iget-object v1, v9, Lcom/kousei/framework/m0;->b:Lcom/kousei/framework/w6;

    if-eqz v1, :cond_318

    .line 85
    iget-object v2, v1, Lcom/kousei/framework/w6;->a:[B

    if-eqz v2, :cond_300

    iput-object v2, v3, Lcom/kousei/framework/i1;->r:[B

    .line 86
    :cond_300
    iget-object v2, v1, Lcom/kousei/framework/w6;->b:[B

    if-eqz v2, :cond_306

    iput-object v2, v3, Lcom/kousei/framework/i1;->s:[B

    .line 87
    :cond_306
    iget-object v2, v1, Lcom/kousei/framework/w6;->c:[B

    if-eqz v2, :cond_30c

    iput-object v2, v3, Lcom/kousei/framework/i1;->t:[B

    .line 88
    :cond_30c
    iget-object v2, v1, Lcom/kousei/framework/w6;->d:[B

    if-eqz v2, :cond_312

    iput-object v2, v3, Lcom/kousei/framework/i1;->u:[B

    .line 89
    :cond_312
    iget-object v1, v1, Lcom/kousei/framework/w6;->e:[B

    if-eqz v1, :cond_318

    iput-object v1, v3, Lcom/kousei/framework/i1;->v:[B
    :try_end_318
    .catchall {:try_start_2f6 .. :try_end_318} :catchall_318

    .line 90
    :catchall_318
    :cond_318
    :try_start_318
    invoke-static {v3}, Lcom/kousei/framework/j1;->g(Lcom/kousei/framework/i1;)Ljava/security/KeyPair;

    move-result-object v2

    if-eqz v2, :cond_476

    .line 91
    invoke-virtual {v4}, Landroid/security/keystore/KeyGenParameterSpec;->isStrongBoxBacked()Z

    move-result v1

    if-eqz v1, :cond_329

    move-object/from16 v1, p2

    move/from16 v4, v20

    goto :goto_33b

    .line 92
    :cond_329
    instance-of v1, v10, Ljava/lang/Number;

    if-eqz v1, :cond_338

    .line 93
    move-object v1, v10

    check-cast v1, Ljava/lang/Number;

    invoke-virtual {v1}, Ljava/lang/Number;->intValue()I

    move-result v1

    move v4, v1

    move-object/from16 v1, p2

    goto :goto_33b

    :cond_338
    move-object/from16 v1, p2

    const/4 v4, 0x1

    .line 94
    :goto_33b
    invoke-static/range {v0 .. v9}, Landroid/security/kaorios/KaoriosHook;->b(Ljava/lang/Object;Ljava/lang/Object;Ljava/security/KeyPair;Lcom/kousei/framework/i1;IILjava/lang/String;Ljava/lang/String;ZLcom/kousei/framework/m0;)Ljava/util/ArrayList;

    move-result-object v3

    if-nez v3, :cond_343

    goto/16 :goto_1c

    .line 95
    :cond_343
    invoke-virtual {v2}, Ljava/security/KeyPair;->getPrivate()Ljava/security/PrivateKey;

    move-result-object v1

    invoke-interface {v1}, Ljava/security/Key;->getEncoded()[B

    move-result-object v9

    .line 96
    move-object v4, v10

    check-cast v4, Landroid/security/KeyStoreSecurityLevel;

    .line 97
    move-object/from16 v5, p2

    check-cast v5, Landroid/system/keystore2/KeyDescriptor;

    .line 98
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1
    :try_end_356
    .catch Ljava/lang/Exception; {:try_start_318 .. :try_end_356} :catch_1c

    :goto_356
    if-eqz v1, :cond_370

    const-wide v6, -0x97650dbb5469L

    .line 99
    :try_start_35d
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2
    :try_end_361
    .catch Ljava/lang/NoSuchMethodException; {:try_start_35d .. :try_end_361} :catch_36b
    .catch Ljava/lang/Exception; {:try_start_35d .. :try_end_361} :catch_1c

    const/4 v6, 0x0

    :try_start_362
    invoke-virtual {v1, v2, v6}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1
    :try_end_366
    .catch Ljava/lang/NoSuchMethodException; {:try_start_362 .. :try_end_366} :catch_36b
    .catch Ljava/lang/Exception; {:try_start_362 .. :try_end_366} :catch_367

    goto :goto_371

    :catch_367
    move-object/from16 v16, v6

    goto/16 :goto_485

    .line 100
    :catch_36b
    :try_start_36b
    invoke-virtual {v1}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    move-result-object v1

    goto :goto_356

    :cond_370
    const/4 v1, 0x0

    :goto_371
    if-nez v1, :cond_375

    goto/16 :goto_1c

    :cond_375
    const/4 v2, 0x1

    .line 101
    invoke-virtual {v1, v2}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
    :try_end_379
    .catch Ljava/lang/Exception; {:try_start_36b .. :try_end_379} :catch_1c

    const/4 v6, 0x0

    .line 102
    :try_start_37a
    invoke-virtual {v1, v0, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1
    :try_end_37e
    .catch Ljava/lang/Exception; {:try_start_37a .. :try_end_37e} :catch_367

    :try_start_37e
    check-cast v1, Ljava/util/Collection;

    .line 103
    new-instance v7, Ljava/util/ArrayList;

    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V

    .line 104
    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_389
    :goto_389
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_3ce

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    .line 105
    check-cast v2, Landroid/hardware/security/keymint/KeyParameter;

    .line 106
    iget v6, v2, Landroid/hardware/security/keymint/KeyParameter;->tag:I

    const v8, -0x6ffffd3c

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd3b

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd3a

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd39

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd38

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd37

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd36

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd35

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd34

    if-eq v6, v8, :cond_389

    const v8, -0x6ffffd33

    if-ne v6, v8, :cond_3ca

    goto :goto_389

    .line 107
    :cond_3ca
    invoke-virtual {v7, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_389

    :cond_3ce
    const/4 v6, 0x0

    const/4 v8, 0x0

    .line 108
    invoke-virtual/range {v4 .. v9}, Landroid/security/KeyStoreSecurityLevel;->importKey(Landroid/system/keystore2/KeyDescriptor;Landroid/system/keystore2/KeyDescriptor;Ljava/util/Collection;I[B)Landroid/system/keystore2/KeyMetadata;

    move-result-object v1

    .line 109
    invoke-virtual {v3}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_3fc

    move/from16 v2, v17

    .line 110
    invoke-virtual {v3, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/security/cert/Certificate;

    invoke-virtual {v6}, Ljava/security/cert/Certificate;->getEncoded()[B

    move-result-object v2

    .line 111
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I

    move-result v6

    const/4 v7, 0x1

    if-le v6, v7, :cond_3fa

    .line 112
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I

    move-result v6

    invoke-virtual {v3, v7, v6}, Ljava/util/ArrayList;->subList(II)Ljava/util/List;

    move-result-object v3

    invoke-static {v3}, Landroid/security/kaorios/KaoriosHook;->c(Ljava/util/List;)[B

    move-result-object v3

    goto :goto_3fe

    :cond_3fa
    :goto_3fa
    const/4 v3, 0x0

    goto :goto_3fe

    :cond_3fc
    const/4 v2, 0x0

    goto :goto_3fa

    :goto_3fe
    const-wide v6, -0x96850dbb5469L

    .line 113
    invoke-static {v6, v7}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v6

    invoke-static {v0, v6}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/security/KeyStore2;

    .line 114
    invoke-virtual {v0, v5, v2, v3}, Landroid/security/KeyStore2;->updateSubcomponents(Landroid/system/keystore2/KeyDescriptor;[B[B)V

    .line 115
    const-class v0, Landroid/security/keystore2/AndroidKeyStoreProvider;

    const-wide v2, -0x969f0dbb5469L

    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x4

    new-array v6, v3, [Ljava/lang/Class;

    const-class v7, Landroid/system/keystore2/KeyDescriptor;

    const/16 v17, 0x0

    aput-object v7, v6, v17

    const-class v7, Landroid/system/keystore2/KeyMetadata;

    const/16 v18, 0x1

    aput-object v7, v6, v18

    const-class v7, Landroid/security/KeyStoreSecurityLevel;

    aput-object v7, v6, v20

    sget-object v7, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/16 v19, 0x3

    aput-object v7, v6, v19

    invoke-virtual {v0, v2, v6}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    const/4 v2, 0x1

    .line 116
    invoke-virtual {v0, v2}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    .line 117
    new-array v3, v3, [Ljava/lang/Object;

    const/16 v17, 0x0

    aput-object v5, v3, v17

    aput-object v1, v3, v2

    aput-object v4, v3, v20

    invoke-static {v13}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v19, 0x3

    aput-object v1, v3, v19
    :try_end_44e
    .catch Ljava/lang/Exception; {:try_start_37e .. :try_end_44e} :catch_1c

    const/4 v6, 0x0

    :try_start_44f
    invoke-virtual {v0, v6, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/security/keystore2/AndroidKeyStorePublicKey;

    .line 118
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    const-wide v2, -0x96ce0dbb5469L

    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v6}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    const/4 v2, 0x1

    .line 119
    invoke-virtual {v1, v2}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    .line 120
    invoke-virtual {v1, v0, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1
    :try_end_46e
    .catch Ljava/lang/Exception; {:try_start_44f .. :try_end_46e} :catch_367

    :try_start_46e
    check-cast v1, Ljava/security/PrivateKey;

    .line 121
    new-instance v2, Ljava/security/KeyPair;

    invoke-direct {v2, v0, v1}, Ljava/security/KeyPair;-><init>(Ljava/security/PublicKey;Ljava/security/PrivateKey;)V

    return-object v2

    .line 122
    :cond_476
    new-instance v0, Ljava/security/ProviderException;

    const-wide v1, -0x97450dbb5469L

    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/security/ProviderException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_485
    .catch Ljava/lang/Exception; {:try_start_46e .. :try_end_485} :catch_1c

    :goto_485
    return-object v16

    :sswitch_data_486
    .sparse-switch
        0x103c4 -> :sswitch_227
        0x10601 -> :sswitch_213
        0x10b64 -> :sswitch_1fd
        0x112f1 -> :sswitch_1e7
    .end sparse-switch
.end method

.method public static generateKey(Landroid/system/keystore2/IKeystoreSecurityLevel;Landroid/system/keystore2/KeyDescriptor;Ljava/util/Collection;)Landroid/system/keystore2/KeyMetadata;
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/system/keystore2/IKeystoreSecurityLevel;",
            "Landroid/system/keystore2/KeyDescriptor;",
            "Ljava/util/Collection<",
            "Landroid/hardware/security/keymint/KeyParameter;",
            ">;)",
            "Landroid/system/keystore2/KeyMetadata;"
        }
    .end annotation

    .line 1
    const/4 p0, 0x0

    .line 2
    return-object p0
.end method

.method public static h(Ljava/lang/String;)Z
    .registers 3

    .line 1
    const-wide v0, -0x94370dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 11
    .line 12
    .line 13
    move-result v0

    .line 14
    if-nez v0, :cond_30

    .line 15
    .line 16
    const-wide v0, -0x94430dbb5469L

    .line 17
    .line 18
    .line 19
    .line 20
    .line 21
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 26
    .line 27
    .line 28
    move-result v0

    .line 29
    if-nez v0, :cond_30

    .line 30
    .line 31
    const-wide v0, -0x94570dbb5469L

    .line 32
    .line 33
    .line 34
    .line 35
    .line 36
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 37
    .line 38
    .line 39
    move-result-object v0

    .line 40
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 41
    .line 42
    .line 43
    move-result p0

    .line 44
    if-eqz p0, :cond_2e

    .line 45
    .line 46
    goto :goto_30

    .line 47
    :cond_2e
    const/4 p0, 0x0

    .line 48
    return p0

    .line 49
    :cond_30
    :goto_30
    const/4 p0, 0x1

    .line 50
    return p0
.end method

.method public static hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;
    .registers 3

    .line 1
    const/4 p1, 0x0

    .line 2
    :try_start_1
    invoke-static {p1}, Lcom/kousei/framework/g7;->b(Landroid/content/Context;)Lcom/kousei/framework/g7;

    .line 3
    .line 4
    .line 5
    move-result-object v0

    .line 6
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 7
    .line 8
    .line 9
    invoke-static {p0}, Lcom/kousei/framework/g7;->d(Ljava/lang/String;)Ljava/lang/Boolean;

    .line 10
    .line 11
    .line 12
    move-result-object p0
    :try_end_c
    .catchall {:try_start_1 .. :try_end_c} :catchall_d

    .line 13
    return-object p0

    .line 14
    :catchall_d
    return-object p1
.end method

.method public static i(Ljava/lang/String;)Z
    .registers 3

    .line 1
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-nez v0, :cond_18

    .line 6
    .line 7
    const-wide v0, -0x967f0dbb5469L

    .line 8
    .line 9
    .line 10
    .line 11
    .line 12
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 13
    .line 14
    .line 15
    move-result-object v0

    .line 16
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 17
    .line 18
    .line 19
    move-result p0

    .line 20
    if-eqz p0, :cond_16

    .line 21
    .line 22
    goto :goto_18

    .line 23
    :cond_16
    const/4 p0, 0x0

    .line 24
    return p0

    .line 25
    :cond_18
    :goto_18
    const/4 p0, 0x1

    .line 26
    return p0
.end method

.method public static initActivityThread(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    .registers 5

    const-wide v0, -0x94190dbb5469L

    .line 92
    :try_start_5
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_54

    const-wide v0, -0x94110dbb5469L

    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_54

    const-wide v0, -0x94160dbb5469L

    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2e

    goto :goto_54

    .line 93
    :cond_2e
    invoke-static {p0}, Lcom/kousei/framework/t4;->a(Landroid/content/Context;)Lcom/kousei/framework/t4;

    move-result-object v0

    .line 94
    invoke-virtual {v0, p0}, Lcom/kousei/framework/t4;->c(Landroid/content/Context;)Z

    move-result v1

    if-eqz v1, :cond_3b

    .line 95
    invoke-virtual {v0, p0, p1}, Lcom/kousei/framework/t4;->f(Landroid/content/Context;Ljava/lang/String;)V

    .line 96
    :cond_3b
    invoke-static {p0}, Lcom/kousei/framework/g7;->b(Landroid/content/Context;)Lcom/kousei/framework/g7;

    move-result-object v0

    .line 97
    invoke-virtual {v0, p2}, Lcom/kousei/framework/g7;->j(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_48

    .line 98
    invoke-virtual {v0, p0, p2}, Lcom/kousei/framework/g7;->l(Landroid/content/Context;Ljava/lang/String;)V

    .line 99
    :cond_48
    invoke-static {p0, p1}, Lcom/kousei/framework/g7;->k(Landroid/content/Context;Ljava/lang/String;)Z

    move-result p2

    if-eqz p2, :cond_51

    .line 100
    invoke-static {}, Lcom/kousei/framework/g7;->n()V

    .line 101
    :cond_51
    invoke-static {p0, p1}, Lcom/kousei/framework/pa;->a(Landroid/content/Context;Ljava/lang/String;)V
    :try_end_54
    .catchall {:try_start_5 .. :try_end_54} :catchall_54

    :catchall_54
    :cond_54
    :goto_54
    return-void
.end method

.method public static initActivityThread(Ljava/lang/Object;)V
    .registers 4

    if-nez p0, :cond_3

    goto :goto_3a

    :cond_3
    const-wide v0, -0x94f90dbb5469L

    .line 87
    :try_start_8
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    const-wide v1, -0x94f50dbb5469L

    .line 88
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {p0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    const-wide v1, -0x940d0dbb5469L

    .line 89
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {p0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    .line 90
    instance-of v1, v0, Ljava/lang/String;

    if-eqz v1, :cond_3a

    instance-of v1, p0, Ljava/lang/String;

    if-nez v1, :cond_33

    goto :goto_3a

    .line 91
    :cond_33
    check-cast p0, Ljava/lang/String;

    check-cast v0, Ljava/lang/String;

    invoke-static {p0, v0}, Landroid/security/kaorios/KaoriosHook;->initActivityThread(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_3a
    .catchall {:try_start_8 .. :try_end_3a} :catchall_3a

    :catchall_3a
    :cond_3a
    :goto_3a
    return-void
.end method

.method public static initActivityThread(Ljava/lang/String;Ljava/lang/String;)V
    .registers 5

    .line 1
    const-wide v0, -0x94cb0dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    :try_start_5
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 7
    .line 8
    .line 9
    move-result-object v0

    .line 10
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 11
    .line 12
    .line 13
    move-result v0

    .line 14
    if-nez v0, :cond_55

    .line 15
    .line 16
    const-wide v0, -0x94c30dbb5469L

    .line 17
    .line 18
    .line 19
    .line 20
    .line 21
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 22
    .line 23
    .line 24
    move-result-object v0

    .line 25
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 26
    .line 27
    .line 28
    move-result v0

    .line 29
    if-nez v0, :cond_55

    .line 30
    .line 31
    const-wide v0, -0x94d80dbb5469L

    .line 32
    .line 33
    .line 34
    .line 35
    .line 36
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 37
    .line 38
    .line 39
    move-result-object v0

    .line 40
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 41
    .line 42
    .line 43
    move-result v0

    .line 44
    if-eqz v0, :cond_2e

    .line 45
    .line 46
    goto :goto_55

    .line 47
    :cond_2e
    const/4 v0, 0x0

    .line 48
    invoke-static {v0}, Lcom/kousei/framework/t4;->a(Landroid/content/Context;)Lcom/kousei/framework/t4;

    .line 49
    .line 50
    .line 51
    move-result-object v1

    .line 52
    invoke-virtual {v1, v0}, Lcom/kousei/framework/t4;->c(Landroid/content/Context;)Z

    .line 53
    .line 54
    .line 55
    move-result v2

    .line 56
    if-eqz v2, :cond_3c

    .line 57
    .line 58
    invoke-virtual {v1, v0, p0}, Lcom/kousei/framework/t4;->f(Landroid/content/Context;Ljava/lang/String;)V

    .line 59
    .line 60
    .line 61
    :cond_3c
    invoke-static {v0}, Lcom/kousei/framework/g7;->b(Landroid/content/Context;)Lcom/kousei/framework/g7;

    .line 62
    .line 63
    .line 64
    move-result-object v1

    .line 65
    invoke-virtual {v1, p1}, Lcom/kousei/framework/g7;->j(Ljava/lang/String;)Z

    .line 66
    .line 67
    .line 68
    move-result v2

    .line 69
    if-eqz v2, :cond_49

    .line 70
    .line 71
    invoke-virtual {v1, v0, p1}, Lcom/kousei/framework/g7;->l(Landroid/content/Context;Ljava/lang/String;)V

    .line 72
    .line 73
    .line 74
    :cond_49
    invoke-static {v0, p0}, Lcom/kousei/framework/g7;->k(Landroid/content/Context;Ljava/lang/String;)Z

    .line 75
    .line 76
    .line 77
    move-result p1

    .line 78
    if-eqz p1, :cond_52

    .line 79
    .line 80
    invoke-static {}, Lcom/kousei/framework/g7;->n()V

    .line 81
    .line 82
    .line 83
    :cond_52
    invoke-static {v0, p0}, Lcom/kousei/framework/pa;->a(Landroid/content/Context;Ljava/lang/String;)V
    :try_end_55
    .catchall {:try_start_5 .. :try_end_55} :catchall_55

    .line 84
    .line 85
    .line 86
    :catchall_55
    :cond_55
    :goto_55
    return-void
.end method

.method public static initContext(Landroid/content/Context;)V
    .registers 5

    .line 1
    if-nez p0, :cond_3

    .line 2
    .line 3
    goto :goto_5f

    .line 4
    :cond_3
    :try_start_3
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    .line 5
    .line 6
    .line 7
    move-result-object v0

    .line 8
    invoke-static {}, Landroid/app/Application;->getProcessName()Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object v1

    .line 12
    const-wide v2, -0x949d0dbb5469L

    .line 13
    .line 14
    .line 15
    .line 16
    .line 17
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 18
    .line 19
    .line 20
    move-result-object v2

    .line 21
    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 22
    .line 23
    .line 24
    move-result v2

    .line 25
    if-nez v2, :cond_5f

    .line 26
    .line 27
    const-wide v2, -0x94950dbb5469L

    .line 28
    .line 29
    .line 30
    .line 31
    .line 32
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 33
    .line 34
    .line 35
    move-result-object v2

    .line 36
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 37
    .line 38
    .line 39
    move-result v2

    .line 40
    if-nez v2, :cond_5f

    .line 41
    .line 42
    const-wide v2, -0x94aa0dbb5469L

    .line 43
    .line 44
    .line 45
    .line 46
    .line 47
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 48
    .line 49
    .line 50
    move-result-object v2

    .line 51
    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 52
    .line 53
    .line 54
    move-result v2

    .line 55
    if-eqz v2, :cond_39

    .line 56
    .line 57
    goto :goto_5f

    .line 58
    :cond_39
    invoke-static {p0}, Lcom/kousei/framework/t4;->a(Landroid/content/Context;)Lcom/kousei/framework/t4;

    .line 59
    .line 60
    .line 61
    move-result-object v2

    .line 62
    invoke-virtual {v2, p0}, Lcom/kousei/framework/t4;->c(Landroid/content/Context;)Z

    .line 63
    .line 64
    .line 65
    move-result v3

    .line 66
    if-eqz v3, :cond_46

    .line 67
    .line 68
    invoke-virtual {v2, p0, v0}, Lcom/kousei/framework/t4;->f(Landroid/content/Context;Ljava/lang/String;)V

    .line 69
    .line 70
    .line 71
    :cond_46
    invoke-static {p0}, Lcom/kousei/framework/g7;->b(Landroid/content/Context;)Lcom/kousei/framework/g7;

    .line 72
    .line 73
    .line 74
    move-result-object v2

    .line 75
    invoke-virtual {v2, v1}, Lcom/kousei/framework/g7;->j(Ljava/lang/String;)Z

    .line 76
    .line 77
    .line 78
    move-result v3

    .line 79
    if-eqz v3, :cond_53

    .line 80
    .line 81
    invoke-virtual {v2, p0, v1}, Lcom/kousei/framework/g7;->l(Landroid/content/Context;Ljava/lang/String;)V

    .line 82
    .line 83
    .line 84
    :cond_53
    invoke-static {p0, v0}, Lcom/kousei/framework/g7;->k(Landroid/content/Context;Ljava/lang/String;)Z

    .line 85
    .line 86
    .line 87
    move-result v1

    .line 88
    if-eqz v1, :cond_5c

    .line 89
    .line 90
    invoke-static {}, Lcom/kousei/framework/g7;->n()V

    .line 91
    .line 92
    .line 93
    :cond_5c
    invoke-static {p0, v0}, Lcom/kousei/framework/pa;->a(Landroid/content/Context;Ljava/lang/String;)V
    :try_end_5f
    .catchall {:try_start_3 .. :try_end_5f} :catchall_5f

    .line 94
    .line 95
    .line 96
    :catchall_5f
    :cond_5f
    :goto_5f
    return-void
.end method

.method public static initGenerateKeyPair(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Ljava/security/KeyPair;
    .registers 9

    .line 1
    const-wide v0, -0x97970dbb5469L

    .line 2
    .line 3
    .line 4
    .line 5
    .line 6
    const/4 v2, 0x0

    .line 7
    :try_start_6
    invoke-static {v0, v1}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 8
    .line 9
    .line 10
    move-result-object v0

    .line 11
    invoke-static {p0, v0}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    check-cast v0, Ljava/lang/String;

    .line 16
    .line 17
    invoke-static {v0}, Landroid/security/kaorios/KaoriosHook;->h(Ljava/lang/String;)Z

    .line 18
    .line 19
    .line 20
    move-result v0

    .line 21
    if-eqz v0, :cond_17

    .line 22
    .line 23
    goto :goto_4a

    .line 24
    :cond_17
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 25
    .line 26
    .line 27
    move-result v0

    .line 28
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    .line 29
    .line 30
    .line 31
    move-result-object v1

    .line 32
    if-eqz v1, :cond_26

    .line 33
    .line 34
    invoke-interface {v1, v0}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 35
    .line 36
    .line 37
    move-result-object v1

    .line 38
    goto :goto_27

    .line 39
    :cond_26
    move-object v1, v2

    .line 40
    :goto_27
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 41
    .line 42
    .line 43
    move-result-object v3

    .line 44
    const/4 v4, 0x0

    .line 45
    invoke-virtual {v3, v4}, Lcom/kousei/framework/b7;->k(Z)V

    .line 46
    .line 47
    .line 48
    iget-object v3, v3, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 49
    .line 50
    new-instance v4, Lcom/kousei/framework/m0;

    .line 51
    .line 52
    invoke-direct {v4, v3, v1}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/m0;[Ljava/lang/String;)V

    .line 53
    .line 54
    .line 55
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 56
    .line 57
    .line 58
    move-result-object v3

    .line 59
    iget-object v5, v4, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 60
    .line 61
    check-cast v5, Lcom/kousei/framework/m0;

    .line 62
    .line 63
    invoke-virtual {v3, v5, v0, v1}, Lcom/kousei/framework/b7;->d(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z

    .line 64
    .line 65
    .line 66
    move-result v0

    .line 67
    if-nez v0, :cond_45

    .line 68
    .line 69
    goto :goto_4a

    .line 70
    :cond_45
    invoke-static {p0, p1, p2, v4}, Landroid/security/kaorios/KaoriosHook;->g(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;Lcom/kousei/framework/m0;)Ljava/security/KeyPair;

    .line 71
    .line 72
    .line 73
    move-result-object p0
    :try_end_49
    .catchall {:try_start_6 .. :try_end_49} :catchall_4a

    .line 74
    return-object p0

    .line 75
    :catchall_4a
    :goto_4a
    return-object v2
.end method

.method public static initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;
    .registers 11

    .line 1
    const/4 v0, 0x0

    .line 2
    if-nez p0, :cond_5

    .line 3
    .line 4
    goto/16 :goto_b0

    .line 5
    .line 6
    :cond_5
    const-wide v1, -0x947b0dbb5469L

    .line 7
    .line 8
    .line 9
    .line 10
    .line 11
    :try_start_a
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 12
    .line 13
    .line 14
    move-result-object v1

    .line 15
    invoke-static {p0, v1}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    const-wide v2, -0x94750dbb5469L

    .line 20
    .line 21
    .line 22
    .line 23
    .line 24
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 25
    .line 26
    .line 27
    move-result-object v2

    .line 28
    invoke-static {p0, v2}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 29
    .line 30
    .line 31
    move-result-object v2

    .line 32
    instance-of v3, v1, Landroid/security/KeyStore2;

    .line 33
    .line 34
    if-eqz v3, :cond_b0

    .line 35
    .line 36
    instance-of v3, v2, Landroid/security/keystore/KeyGenParameterSpec;

    .line 37
    .line 38
    if-nez v3, :cond_29

    .line 39
    .line 40
    goto/16 :goto_b0

    .line 41
    .line 42
    :cond_29
    const-wide v3, -0x978b0dbb5469L

    .line 43
    .line 44
    .line 45
    .line 46
    .line 47
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 48
    .line 49
    .line 50
    move-result-object v3

    .line 51
    invoke-static {p0, v3}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 52
    .line 53
    .line 54
    move-result-object v3

    .line 55
    check-cast v3, Ljava/lang/String;

    .line 56
    .line 57
    invoke-static {v3}, Landroid/security/kaorios/KaoriosHook;->h(Ljava/lang/String;)Z

    .line 58
    .line 59
    .line 60
    move-result v4

    .line 61
    if-eqz v4, :cond_40

    .line 62
    .line 63
    goto/16 :goto_b0

    .line 64
    .line 65
    :cond_40
    invoke-static {}, Landroid/app/ActivityThread;->getPackageManager()Landroid/content/pm/IPackageManager;

    .line 66
    .line 67
    .line 68
    move-result-object v4

    .line 69
    if-nez v4, :cond_47

    .line 70
    .line 71
    goto :goto_b0

    .line 72
    :cond_47
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 73
    .line 74
    .line 75
    move-result v5

    .line 76
    invoke-interface {v4, v5}, Landroid/content/pm/IPackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    .line 77
    .line 78
    .line 79
    move-result-object v4

    .line 80
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 81
    .line 82
    .line 83
    move-result-object v6

    .line 84
    const/4 v7, 0x0

    .line 85
    invoke-virtual {v6, v7}, Lcom/kousei/framework/b7;->k(Z)V

    .line 86
    .line 87
    .line 88
    iget-object v6, v6, Lcom/kousei/framework/b7;->a:Lcom/kousei/framework/m0;

    .line 89
    .line 90
    new-instance v8, Lcom/kousei/framework/m0;

    .line 91
    .line 92
    invoke-direct {v8, v6, v4}, Lcom/kousei/framework/m0;-><init>(Lcom/kousei/framework/m0;[Ljava/lang/String;)V

    .line 93
    .line 94
    .line 95
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 96
    .line 97
    .line 98
    move-result-object v6

    .line 99
    iget-object v9, v8, Lcom/kousei/framework/m0;->c:Ljava/lang/Object;

    .line 100
    .line 101
    check-cast v9, Lcom/kousei/framework/m0;

    .line 102
    .line 103
    invoke-virtual {v6, v9, v5, v4}, Lcom/kousei/framework/b7;->d(Lcom/kousei/framework/m0;I[Ljava/lang/String;)Z

    .line 104
    .line 105
    .line 106
    move-result v4

    .line 107
    if-nez v4, :cond_6d

    .line 108
    .line 109
    goto :goto_b0

    .line 110
    :cond_6d
    check-cast v1, Landroid/security/KeyStore2;

    .line 111
    .line 112
    check-cast v2, Landroid/security/keystore/KeyGenParameterSpec;

    .line 113
    .line 114
    invoke-virtual {v2}, Landroid/security/keystore/KeyGenParameterSpec;->isStrongBoxBacked()Z

    .line 115
    .line 116
    .line 117
    move-result v2

    .line 118
    const/4 v4, 0x2

    .line 119
    if-eqz v2, :cond_7a

    .line 120
    .line 121
    move v2, v4

    .line 122
    goto :goto_7b

    .line 123
    :cond_7a
    const/4 v2, 0x1

    .line 124
    :goto_7b
    invoke-virtual {v1, v2}, Landroid/security/KeyStore2;->getSecurityLevel(I)Landroid/security/KeyStoreSecurityLevel;

    .line 125
    .line 126
    .line 127
    move-result-object v1

    .line 128
    new-instance v2, Landroid/system/keystore2/KeyDescriptor;

    .line 129
    .line 130
    invoke-direct {v2}, Landroid/system/keystore2/KeyDescriptor;-><init>()V

    .line 131
    .line 132
    .line 133
    iput-object v3, v2, Landroid/system/keystore2/KeyDescriptor;->alias:Ljava/lang/String;

    .line 134
    .line 135
    const-wide v5, -0x97870dbb5469L

    .line 136
    .line 137
    .line 138
    .line 139
    .line 140
    invoke-static {v5, v6}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 141
    .line 142
    .line 143
    move-result-object v3

    .line 144
    invoke-static {p0, v3}, Landroid/security/kaorios/KaoriosHook;->e(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 145
    .line 146
    .line 147
    move-result-object v3

    .line 148
    instance-of v5, v3, Ljava/lang/Number;

    .line 149
    .line 150
    const/4 v6, -0x1

    .line 151
    if-eqz v5, :cond_9f

    .line 152
    .line 153
    check-cast v3, Ljava/lang/Number;

    .line 154
    .line 155
    invoke-virtual {v3}, Ljava/lang/Number;->intValue()I

    .line 156
    .line 157
    .line 158
    move-result v3

    .line 159
    goto :goto_a0

    .line 160
    :cond_9f
    move v3, v6

    .line 161
    :goto_a0
    if-ne v3, v6, :cond_a3

    .line 162
    .line 163
    goto :goto_a4

    .line 164
    :cond_a3
    move v7, v4

    .line 165
    :goto_a4
    iput v7, v2, Landroid/system/keystore2/KeyDescriptor;->domain:I

    .line 166
    .line 167
    int-to-long v3, v3

    .line 168
    iput-wide v3, v2, Landroid/system/keystore2/KeyDescriptor;->nspace:J

    .line 169
    .line 170
    iput-object v0, v2, Landroid/system/keystore2/KeyDescriptor;->blob:[B

    .line 171
    .line 172
    invoke-static {p0, v1, v2, v8}, Landroid/security/kaorios/KaoriosHook;->g(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;Lcom/kousei/framework/m0;)Ljava/security/KeyPair;

    .line 173
    .line 174
    .line 175
    move-result-object p0
    :try_end_af
    .catchall {:try_start_a .. :try_end_af} :catchall_b0

    .line 176
    return-object p0

    .line 177
    :catchall_b0
    :cond_b0
    :goto_b0
    return-object v0
.end method

.method public static initSystemServer()V
    .registers 2

    .line 1
    :try_start_0
    invoke-static {}, Lcom/kousei/framework/b7;->c()Lcom/kousei/framework/b7;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    const/4 v1, 0x1

    .line 6
    invoke-virtual {v0, v1}, Lcom/kousei/framework/b7;->k(Z)V

    .line 7
    .line 8
    .line 9
    invoke-virtual {v0}, Lcom/kousei/framework/b7;->l()V
    :try_end_b
    .catchall {:try_start_0 .. :try_end_b} :catchall_b

    .line 10
    .line 11
    .line 12
    :catchall_b
    return-void
.end method

.method public static isSecureFlag()Z
    .registers 6

    .line 1
    invoke-static {}, Lcom/kousei/framework/KaoriosFramework;->obtainContentResolver()Landroid/content/ContentResolver;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    sget-boolean v1, Landroid/security/kaorios/KaoriosHook;->b:Z

    .line 6
    .line 7
    const/4 v2, 0x1

    .line 8
    if-nez v1, :cond_32

    .line 9
    .line 10
    if-nez v0, :cond_c

    .line 11
    .line 12
    goto :goto_32

    .line 13
    :cond_c
    const-class v1, Landroid/security/kaorios/KaoriosHook;

    .line 14
    .line 15
    monitor-enter v1

    .line 16
    :try_start_f
    sget-boolean v3, Landroid/security/kaorios/KaoriosHook;->b:Z

    .line 17
    .line 18
    if-eqz v3, :cond_17

    .line 19
    .line 20
    monitor-exit v1
    :try_end_14
    .catchall {:try_start_f .. :try_end_14} :catchall_15

    .line 21
    goto :goto_32

    .line 22
    :catchall_15
    move-exception v0

    .line 23
    goto :goto_30

    .line 24
    :cond_17
    const-wide v3, -0x999b0dbb5469L

    .line 25
    .line 26
    .line 27
    .line 28
    .line 29
    :try_start_1c
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 30
    .line 31
    .line 32
    move-result-object v3

    .line 33
    const-wide v4, -0x99a20dbb5469L

    .line 34
    .line 35
    .line 36
    .line 37
    .line 38
    invoke-static {v4, v5}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 39
    .line 40
    .line 41
    move-result-object v4

    .line 42
    invoke-static {v0, v3, v4}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    .line 43
    .line 44
    .line 45
    sput-boolean v2, Landroid/security/kaorios/KaoriosHook;->b:Z
    :try_end_2e
    .catchall {:try_start_1c .. :try_end_2e} :catchall_2e

    .line 46
    .line 47
    :catchall_2e
    :try_start_2e
    monitor-exit v1

    .line 48
    goto :goto_32

    .line 49
    :goto_30
    monitor-exit v1
    :try_end_31
    .catchall {:try_start_2e .. :try_end_31} :catchall_15

    .line 50
    throw v0

    .line 51
    :cond_32
    :goto_32
    const/4 v1, 0x0

    .line 52
    if-nez v0, :cond_36

    .line 53
    .line 54
    return v1

    .line 55
    :cond_36
    const-wide v3, -0x96770dbb5469L

    .line 56
    .line 57
    .line 58
    .line 59
    .line 60
    invoke-static {v3, v4}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 61
    .line 62
    .line 63
    move-result-object v3

    .line 64
    invoke-static {v0, v3, v1}, Lcom/kousei/framework/KaoriosFramework;->getGlobalInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    .line 65
    .line 66
    .line 67
    move-result v0

    .line 68
    if-ne v0, v2, :cond_46

    .line 69
    .line 70
    goto :goto_47

    .line 71
    :cond_46
    move v2, v1

    .line 72
    :goto_47
    return v2
.end method

.method public static j(Landroid/security/keystore/KeyGenParameterSpec;)Ljava/lang/String;
    .registers 6

    .line 1
    const/4 v0, 0x0

    .line 2
    :try_start_1
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 3
    .line 4
    .line 5
    move-result-object v1

    .line 6
    const-wide v2, -0x964c0dbb5469L

    .line 7
    .line 8
    .line 9
    .line 10
    .line 11
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 12
    .line 13
    .line 14
    move-result-object v2

    .line 15
    invoke-virtual {v1, v2, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    invoke-virtual {v1, p0, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 20
    .line 21
    .line 22
    move-result-object v1

    .line 23
    instance-of v2, v1, Ljava/lang/String;

    .line 24
    .line 25
    if-eqz v2, :cond_26

    .line 26
    .line 27
    move-object v2, v1

    .line 28
    check-cast v2, Ljava/lang/String;

    .line 29
    .line 30
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    .line 31
    .line 32
    .line 33
    move-result v2

    .line 34
    if-nez v2, :cond_26

    .line 35
    .line 36
    check-cast v1, Ljava/lang/String;
    :try_end_25
    .catch Ljava/lang/NoSuchMethodException; {:try_start_1 .. :try_end_25} :catch_26
    .catchall {:try_start_1 .. :try_end_25} :catchall_26

    .line 37
    .line 38
    return-object v1

    .line 39
    :catch_26
    :catchall_26
    :cond_26
    const-wide v1, -0x965e0dbb5469L

    .line 40
    .line 41
    .line 42
    .line 43
    .line 44
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 45
    .line 46
    .line 47
    move-result-object v1

    .line 48
    const-wide v2, -0x966e0dbb5469L

    .line 49
    .line 50
    .line 51
    .line 52
    .line 53
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 54
    .line 55
    .line 56
    move-result-object v2

    .line 57
    filled-new-array {v1, v2}, [Ljava/lang/String;

    .line 58
    .line 59
    .line 60
    move-result-object v1

    .line 61
    const/4 v2, 0x0

    .line 62
    :goto_3d
    const/4 v3, 0x2

    .line 63
    if-ge v2, v3, :cond_56

    .line 64
    .line 65
    aget-object v3, v1, v2

    .line 66
    .line 67
    invoke-static {p0, v3}, Landroid/security/kaorios/KaoriosHook;->f(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    .line 68
    .line 69
    .line 70
    move-result-object v3

    .line 71
    instance-of v4, v3, Ljava/lang/String;

    .line 72
    .line 73
    if-eqz v4, :cond_53

    .line 74
    .line 75
    check-cast v3, Ljava/lang/String;

    .line 76
    .line 77
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    .line 78
    .line 79
    .line 80
    move-result v4

    .line 81
    if-nez v4, :cond_53

    .line 82
    .line 83
    return-object v3

    .line 84
    :cond_53
    add-int/lit8 v2, v2, 0x1

    .line 85
    .line 86
    goto :goto_3d

    .line 87
    :cond_56
    return-object v0
.end method

.method public static shouldHideAppList(Landroid/content/ContentResolver;Ljava/lang/String;)Z
    .registers 6

    .line 1
    :try_start_0
    sget-object v0, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 2
    .line 3
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    const/4 v1, 0x0

    .line 8
    if-lez v0, :cond_34

    .line 9
    .line 10
    if-nez p1, :cond_c

    .line 11
    .line 12
    goto :goto_34

    .line 13
    :cond_c
    const-wide v2, -0xbe970dbb5469L

    .line 14
    .line 15
    .line 16
    .line 17
    .line 18
    invoke-static {v2, v3}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 19
    .line 20
    .line 21
    move-result-object v2

    .line 22
    invoke-static {p0, v2, v1}, Lcom/kousei/framework/KaoriosFramework;->getGlobalBoolean(Landroid/content/ContentResolver;Ljava/lang/String;Z)Z

    .line 23
    .line 24
    .line 25
    move-result v2

    .line 26
    if-nez v2, :cond_1c

    .line 27
    .line 28
    goto :goto_34

    .line 29
    :cond_1c
    sget-object v2, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 30
    .line 31
    invoke-virtual {v2, p0}, Lcom/kousei/framework/e5;->b(Landroid/content/ContentResolver;)Lcom/kousei/framework/c5;

    .line 32
    .line 33
    .line 34
    move-result-object v3

    .line 35
    invoke-virtual {v3}, Lcom/kousei/framework/c5;->d()Z

    .line 36
    .line 37
    .line 38
    move-result v3

    .line 39
    if-nez v3, :cond_29

    .line 40
    .line 41
    goto :goto_34

    .line 42
    :cond_29
    iget-object v1, v2, Lcom/kousei/framework/e5;->a:Lcom/kousei/framework/c5;

    .line 43
    .line 44
    const v2, 0x186a0

    .line 45
    .line 46
    .line 47
    div-int v2, v0, v2

    .line 48
    .line 49
    invoke-virtual {v1, v0, v2, p1}, Lcom/kousei/framework/c5;->g(IILjava/lang/String;)Z

    .line 50
    .line 51
    .line 52
    move-result v1
    :try_end_34
    .catchall {:try_start_0 .. :try_end_34} :catchall_38

    .line 53
    :cond_34
    :goto_34
    if-eqz v1, :cond_38

    .line 54
    .line 55
    const/4 p0, 0x1

    .line 56
    return p0

    .line 57
    :catchall_38
    :cond_38
    invoke-static {p0, p1}, Lcom/kousei/framework/w4;->a(Landroid/content/ContentResolver;Ljava/lang/String;)Z

    .line 58
    .line 59
    .line 60
    move-result p0

    .line 61
    return p0
.end method

.method public static shouldHideAppList(Landroid/content/Context;Ljava/lang/String;)Z
    .registers 2

    if-nez p0, :cond_8

    const/4 p0, 0x0

    .line 62
    invoke-static {p0, p1}, Lcom/kousei/framework/w4;->a(Landroid/content/ContentResolver;Ljava/lang/String;)Z

    move-result p0

    return p0

    .line 63
    :cond_8
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    invoke-static {p0, p1}, Landroid/security/kaorios/KaoriosHook;->shouldHideAppList(Landroid/content/ContentResolver;Ljava/lang/String;)Z

    move-result p0

    return p0
.end method

.method public static shouldHideAppListForCaller(ILandroid/content/ContentResolver;Ljava/lang/String;I)Z
    .registers 7

    .line 1
    const/4 v0, 0x0

    .line 2
    if-ltz p3, :cond_4

    .line 3
    .line 4
    goto :goto_b

    .line 5
    :cond_4
    :try_start_4
    sget-object p3, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 6
    .line 7
    const p3, 0x186a0

    .line 8
    .line 9
    .line 10
    div-int p3, p0, p3

    .line 11
    .line 12
    :goto_b
    sget-object v1, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 13
    .line 14
    if-nez p2, :cond_10

    .line 15
    .line 16
    goto :goto_2c

    .line 17
    :cond_10
    const-wide v1, -0xbeb10dbb5469L

    .line 18
    .line 19
    .line 20
    .line 21
    .line 22
    invoke-static {v1, v2}, Lcom/kousei/framework/h0;->c0(J)Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    move-result-object v1

    .line 26
    invoke-static {p1, v1, v0}, Lcom/kousei/framework/KaoriosFramework;->getGlobalBoolean(Landroid/content/ContentResolver;Ljava/lang/String;Z)Z

    .line 27
    .line 28
    .line 29
    move-result v1

    .line 30
    if-nez v1, :cond_20

    .line 31
    .line 32
    goto :goto_2c

    .line 33
    :cond_20
    sget-object v1, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 34
    .line 35
    invoke-virtual {v1, p1}, Lcom/kousei/framework/e5;->b(Landroid/content/ContentResolver;)Lcom/kousei/framework/c5;

    .line 36
    .line 37
    .line 38
    move-result-object p1

    .line 39
    invoke-virtual {p1}, Lcom/kousei/framework/c5;->d()Z

    .line 40
    .line 41
    .line 42
    move-result p1

    .line 43
    if-nez p1, :cond_2d

    .line 44
    .line 45
    :goto_2c
    return v0

    .line 46
    :cond_2d
    iget-object p1, v1, Lcom/kousei/framework/e5;->a:Lcom/kousei/framework/c5;

    .line 47
    .line 48
    invoke-virtual {p1, p0, p3, p2}, Lcom/kousei/framework/c5;->g(IILjava/lang/String;)Z

    .line 49
    .line 50
    .line 51
    move-result p0
    :try_end_33
    .catchall {:try_start_4 .. :try_end_33} :catchall_34

    .line 52
    return p0

    .line 53
    :catchall_34
    return v0
.end method

.method public static shouldHideAppListForCaller(ILandroid/content/Context;Ljava/lang/String;I)Z
    .registers 4

    if-nez p1, :cond_4

    const/4 p0, 0x0

    return p0

    .line 54
    :cond_4
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p1

    .line 55
    invoke-static {p0, p1, p2, p3}, Landroid/security/kaorios/KaoriosHook;->shouldHideAppListForCaller(ILandroid/content/ContentResolver;Ljava/lang/String;I)Z

    move-result p0

    return p0
.end method

.method public static shouldHideDevStatus(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z
    .registers 3

    .line 1
    invoke-static {p0, p1, p2}, Lcom/kousei/framework/x4;->a(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    .line 2
    .line 3
    .line 4
    move-result p0

    .line 5
    return p0
.end method

.method public static shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z
    .registers 4

    .line 1
    const/4 p2, 0x0

    .line 2
    if-eqz p0, :cond_f

    .line 3
    .line 4
    if-nez p1, :cond_6

    .line 5
    .line 6
    goto :goto_f

    .line 7
    :cond_6
    :try_start_6
    invoke-virtual {p0}, Landroid/content/ContentResolver;->getPackageName()Ljava/lang/String;

    .line 8
    .line 9
    .line 10
    move-result-object v0

    .line 11
    invoke-static {p0, v0, p1}, Lcom/kousei/framework/x4;->a(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    .line 12
    .line 13
    .line 14
    move-result p0
    :try_end_e
    .catchall {:try_start_6 .. :try_end_e} :catchall_f

    .line 15
    return p0

    .line 16
    :catchall_f
    :cond_f
    :goto_f
    return p2
.end method

.method public static shouldRemoveSetting(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z
    .registers 5

    .line 1
    const/4 v0, 0x0

    .line 2
    :try_start_1
    invoke-static {p1, p2}, Lcom/kousei/framework/i0;->b(Ljava/lang/String;Ljava/lang/String;)Z

    .line 3
    .line 4
    .line 5
    move-result v1

    .line 6
    if-eqz v1, :cond_2a

    .line 7
    .line 8
    sget-object p0, Lcom/kousei/framework/i0;->a:Ljava/lang/ThreadLocal;

    .line 9
    .line 10
    invoke-virtual {p0}, Ljava/lang/ThreadLocal;->remove()V

    .line 11
    .line 12
    .line 13
    invoke-static {p1, p2}, Lcom/kousei/framework/i0;->b(Ljava/lang/String;Ljava/lang/String;)Z

    .line 14
    .line 15
    .line 16
    move-result v1

    .line 17
    if-eqz v1, :cond_53

    .line 18
    .line 19
    new-instance v1, Ljava/lang/StringBuilder;

    .line 20
    .line 21
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    .line 22
    .line 23
    .line 24
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 25
    .line 26
    .line 27
    const-string p1, ":"

    .line 28
    .line 29
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 30
    .line 31
    .line 32
    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33
    .line 34
    .line 35
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 36
    .line 37
    .line 38
    move-result-object p1

    .line 39
    invoke-virtual {p0, p1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 40
    .line 41
    .line 42
    return v0

    .line 43
    :cond_2a
    sget-object v1, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 44
    .line 45
    if-eqz p1, :cond_53

    .line 46
    .line 47
    if-nez p2, :cond_31

    .line 48
    .line 49
    goto :goto_53

    .line 50
    :cond_31
    sget-object v1, Lcom/kousei/framework/e5;->e:Lcom/kousei/framework/e5;

    .line 51
    .line 52
    invoke-virtual {v1, p0}, Lcom/kousei/framework/e5;->b(Landroid/content/ContentResolver;)Lcom/kousei/framework/c5;

    .line 53
    .line 54
    .line 55
    move-result-object p0

    .line 56
    invoke-virtual {p0}, Lcom/kousei/framework/c5;->d()Z

    .line 57
    .line 58
    .line 59
    move-result p0

    .line 60
    if-nez p0, :cond_3e

    .line 61
    .line 62
    goto :goto_53

    .line 63
    :cond_3e
    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    .line 64
    .line 65
    .line 66
    move-result p0

    .line 67
    if-gtz p0, :cond_45

    .line 68
    .line 69
    goto :goto_53

    .line 70
    :cond_45
    iget-object v1, v1, Lcom/kousei/framework/e5;->a:Lcom/kousei/framework/c5;

    .line 71
    .line 72
    invoke-virtual {v1, p0, p1, p2}, Lcom/kousei/framework/c5;->c(ILjava/lang/String;Ljava/lang/String;)Lcom/kousei/framework/a5;

    .line 73
    .line 74
    .line 75
    move-result-object p0

    .line 76
    if-eqz p0, :cond_53

    .line 77
    .line 78
    iget-object p0, p0, Lcom/kousei/framework/a5;->c:Ljava/lang/String;
    :try_end_4f
    .catchall {:try_start_1 .. :try_end_4f} :catchall_53

    .line 79
    .line 80
    if-nez p0, :cond_53

    .line 81
    .line 82
    const/4 p0, 0x1

    .line 83
    return p0

    .line 84
    :catchall_53
    :cond_53
    :goto_53
    return v0
.end method
