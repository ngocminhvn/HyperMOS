.class public final synthetic Lcom/kousei/framework/w5;
.super Ljava/lang/Object;
.source "r8-map-id-19b2e14f47655f4e58c6258eafc3fc50fa72401ba2aec2522052ea47b5927d9b"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic a:Lcom/kousei/framework/z5;


# direct methods
.method public synthetic constructor <init>(Lcom/kousei/framework/z5;)V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    iput-object p1, p0, Lcom/kousei/framework/w5;->a:Lcom/kousei/framework/z5;

    .line 5
    .line 6
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 7

    .line 1
    iget-object p0, p0, Lcom/kousei/framework/w5;->a:Lcom/kousei/framework/z5;

    .line 2
    .line 3
    const/4 v0, 0x0

    .line 4
    :try_start_3
    iget-object v1, p0, Lcom/kousei/framework/z5;->b:Lcom/kousei/framework/e;

    .line 5
    .line 6
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 7
    .line 8
    .line 9
    invoke-static {}, Lcom/kousei/framework/e;->a()Lcom/kousei/framework/y5;

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    iput-object v1, p0, Lcom/kousei/framework/z5;->e:Lcom/kousei/framework/y5;

    .line 14
    .line 15
    iget-object v2, p0, Lcom/kousei/framework/z5;->c:Ljava/io/File;

    .line 16
    .line 17
    invoke-static {v2, v1}, Lcom/kousei/framework/z5;->f(Ljava/io/File;Lcom/kousei/framework/y5;)V

    .line 18
    .line 19
    .line 20
    iget-object v2, p0, Lcom/kousei/framework/z5;->d:Ljava/lang/Object;

    .line 21
    .line 22
    monitor-enter v2
    :try_end_16
    .catchall {:try_start_3 .. :try_end_16} :catchall_2c

    .line 23
    :try_start_16
    iget-object v3, p0, Lcom/kousei/framework/z5;->g:Ljava/util/Set;

    .line 24
    .line 25
    monitor-exit v2
    :try_end_19
    .catchall {:try_start_16 .. :try_end_19} :catchall_29

    .line 26
    :try_start_19
    iget-object v1, v1, Lcom/kousei/framework/y5;->c:Ljava/util/Map;

    .line 27
    .line 28
    const/4 v2, 0x1

    .line 29
    invoke-static {v3, v1, v2}, Lcom/kousei/framework/z5;->d(Ljava/util/Set;Ljava/util/Map;Z)V
    :try_end_1f
    .catchall {:try_start_19 .. :try_end_1f} :catchall_2c

    .line 30
    .line 31
    .line 32
    iget-object v1, p0, Lcom/kousei/framework/z5;->d:Ljava/lang/Object;

    .line 33
    .line 34
    monitor-enter v1

    .line 35
    :try_start_22
    iput-boolean v0, p0, Lcom/kousei/framework/z5;->f:Z

    .line 36
    .line 37
    monitor-exit v1

    .line 38
    return-void

    .line 39
    :catchall_26
    move-exception p0

    .line 40
    monitor-exit v1
    :try_end_28
    .catchall {:try_start_22 .. :try_end_28} :catchall_26

    .line 41
    throw p0

    .line 42
    :catchall_29
    move-exception v1

    .line 43
    :try_start_2a
    monitor-exit v2
    :try_end_2b
    .catchall {:try_start_2a .. :try_end_2b} :catchall_29

    .line 44
    :try_start_2b
    throw v1
    :try_end_2c
    .catchall {:try_start_2b .. :try_end_2c} :catchall_2c

    .line 45
    :catchall_2c
    :try_start_2c
    iget-object v1, p0, Lcom/kousei/framework/z5;->e:Lcom/kousei/framework/y5;

    .line 46
    .line 47
    iget-wide v2, v1, Lcom/kousei/framework/y5;->a:J

    .line 48
    .line 49
    const-wide/16 v4, 0x0

    .line 50
    .line 51
    cmp-long v2, v2, v4

    .line 52
    .line 53
    if-lez v2, :cond_45

    .line 54
    .line 55
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 56
    .line 57
    .line 58
    move-result-wide v2

    .line 59
    iget-wide v4, v1, Lcom/kousei/framework/y5;->a:J

    .line 60
    .line 61
    sub-long/2addr v2, v4

    .line 62
    const-wide/32 v4, 0x240c8400

    .line 63
    .line 64
    .line 65
    cmp-long v2, v2, v4

    .line 66
    .line 67
    goto :goto_45

    .line 68
    :catchall_43
    move-exception v1

    .line 69
    goto :goto_66

    .line 70
    :cond_45
    :goto_45
    iget-object v2, p0, Lcom/kousei/framework/z5;->d:Ljava/lang/Object;

    .line 71
    .line 72
    monitor-enter v2
    :try_end_48
    .catchall {:try_start_2c .. :try_end_48} :catchall_43

    .line 73
    :try_start_48
    iget-object v3, p0, Lcom/kousei/framework/z5;->g:Ljava/util/Set;

    .line 74
    .line 75
    monitor-exit v2
    :try_end_4b
    .catchall {:try_start_48 .. :try_end_4b} :catchall_63

    .line 76
    if-eqz v3, :cond_59

    .line 77
    .line 78
    :try_start_4d
    invoke-interface {v3}, Ljava/util/Set;->isEmpty()Z

    .line 79
    .line 80
    .line 81
    move-result v2

    .line 82
    if-eqz v2, :cond_54

    .line 83
    .line 84
    goto :goto_59

    .line 85
    :cond_54
    iget-object v1, v1, Lcom/kousei/framework/y5;->c:Ljava/util/Map;

    .line 86
    .line 87
    invoke-static {v3, v1, v0}, Lcom/kousei/framework/z5;->d(Ljava/util/Set;Ljava/util/Map;Z)V
    :try_end_59
    .catchall {:try_start_4d .. :try_end_59} :catchall_43

    .line 88
    .line 89
    .line 90
    :cond_59
    :goto_59
    iget-object v1, p0, Lcom/kousei/framework/z5;->d:Ljava/lang/Object;

    .line 91
    .line 92
    monitor-enter v1

    .line 93
    :try_start_5c
    iput-boolean v0, p0, Lcom/kousei/framework/z5;->f:Z

    .line 94
    .line 95
    monitor-exit v1

    .line 96
    return-void

    .line 97
    :catchall_60
    move-exception p0

    .line 98
    monitor-exit v1
    :try_end_62
    .catchall {:try_start_5c .. :try_end_62} :catchall_60

    .line 99
    throw p0

    .line 100
    :catchall_63
    move-exception v1

    .line 101
    :try_start_64
    monitor-exit v2
    :try_end_65
    .catchall {:try_start_64 .. :try_end_65} :catchall_63

    .line 102
    :try_start_65
    throw v1
    :try_end_66
    .catchall {:try_start_65 .. :try_end_66} :catchall_43

    .line 103
    :goto_66
    iget-object v2, p0, Lcom/kousei/framework/z5;->d:Ljava/lang/Object;

    .line 104
    .line 105
    monitor-enter v2

    .line 106
    :try_start_69
    iput-boolean v0, p0, Lcom/kousei/framework/z5;->f:Z

    .line 107
    .line 108
    monitor-exit v2
    :try_end_6c
    .catchall {:try_start_69 .. :try_end_6c} :catchall_6d

    .line 109
    throw v1

    .line 110
    :catchall_6d
    move-exception p0

    .line 111
    :try_start_6e
    monitor-exit v2
    :try_end_6f
    .catchall {:try_start_6e .. :try_end_6f} :catchall_6d

    .line 112
    throw p0
.end method
