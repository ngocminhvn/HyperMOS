.class public abstract Lcom/kousei/framework/na;
.super Ljava/lang/Object;


# static fields
.field public static final a:Ljava/util/Hashtable;

.field public static final b:Ljava/util/Hashtable;

.field public static final c:Ljava/util/Hashtable;


# direct methods
.method static constructor <clinit>()V
    .registers 16

    .line 1
    new-instance v0, Lcom/kousei/framework/b8;

    .line 2
    .line 3
    const/16 v1, 0x14

    .line 4
    .line 5
    invoke-direct {v0, v1}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 6
    .line 7
    .line 8
    new-instance v1, Lcom/kousei/framework/b8;

    .line 9
    .line 10
    const/16 v2, 0x15

    .line 11
    .line 12
    invoke-direct {v1, v2}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 13
    .line 14
    .line 15
    new-instance v2, Lcom/kousei/framework/b8;

    .line 16
    .line 17
    const/16 v3, 0x16

    .line 18
    .line 19
    invoke-direct {v2, v3}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 20
    .line 21
    .line 22
    new-instance v3, Lcom/kousei/framework/b8;

    .line 23
    .line 24
    const/16 v4, 0x17

    .line 25
    .line 26
    invoke-direct {v3, v4}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 27
    .line 28
    .line 29
    new-instance v4, Lcom/kousei/framework/b8;

    .line 30
    .line 31
    const/16 v5, 0x18

    .line 32
    .line 33
    invoke-direct {v4, v5}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 34
    .line 35
    .line 36
    new-instance v5, Lcom/kousei/framework/b8;

    .line 37
    .line 38
    const/16 v6, 0x19

    .line 39
    .line 40
    invoke-direct {v5, v6}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 41
    .line 42
    .line 43
    new-instance v6, Lcom/kousei/framework/b8;

    .line 44
    .line 45
    const/16 v7, 0x1a

    .line 46
    .line 47
    invoke-direct {v6, v7}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 48
    .line 49
    .line 50
    new-instance v7, Lcom/kousei/framework/b8;

    .line 51
    .line 52
    const/16 v8, 0x1b

    .line 53
    .line 54
    invoke-direct {v7, v8}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 55
    .line 56
    .line 57
    new-instance v8, Lcom/kousei/framework/b8;

    .line 58
    .line 59
    const/16 v9, 0x1c

    .line 60
    .line 61
    invoke-direct {v8, v9}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 62
    .line 63
    .line 64
    new-instance v9, Lcom/kousei/framework/b8;

    .line 65
    .line 66
    const/16 v10, 0xf

    .line 67
    .line 68
    invoke-direct {v9, v10}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 69
    .line 70
    .line 71
    new-instance v10, Lcom/kousei/framework/b8;

    .line 72
    .line 73
    const/16 v11, 0x10

    .line 74
    .line 75
    invoke-direct {v10, v11}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 76
    .line 77
    .line 78
    new-instance v11, Lcom/kousei/framework/b8;

    .line 79
    .line 80
    const/16 v12, 0x11

    .line 81
    .line 82
    invoke-direct {v11, v12}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 83
    .line 84
    .line 85
    new-instance v12, Lcom/kousei/framework/b8;

    .line 86
    .line 87
    const/16 v13, 0x12

    .line 88
    .line 89
    invoke-direct {v12, v13}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 90
    .line 91
    .line 92
    new-instance v13, Lcom/kousei/framework/b8;

    .line 93
    .line 94
    const/16 v14, 0x13

    .line 95
    .line 96
    invoke-direct {v13, v14}, Lcom/kousei/framework/b8;-><init>(I)V

    .line 97
    .line 98
    .line 99
    new-instance v14, Ljava/util/Hashtable;

    .line 100
    .line 101
    invoke-direct {v14}, Ljava/util/Hashtable;-><init>()V

    .line 102
    .line 103
    .line 104
    sput-object v14, Lcom/kousei/framework/na;->a:Ljava/util/Hashtable;

    .line 105
    .line 106
    new-instance v14, Ljava/util/Hashtable;

    .line 107
    .line 108
    invoke-direct {v14}, Ljava/util/Hashtable;-><init>()V

    .line 109
    .line 110
    .line 111
    sput-object v14, Lcom/kousei/framework/na;->b:Ljava/util/Hashtable;

    .line 112
    .line 113
    new-instance v14, Ljava/util/Hashtable;

    .line 114
    .line 115
    invoke-direct {v14}, Ljava/util/Hashtable;-><init>()V

    .line 116
    .line 117
    .line 118
    sput-object v14, Lcom/kousei/framework/na;->c:Ljava/util/Hashtable;

    .line 119
    .line 120
    const-string v14, "brainpoolP160r1"

    .line 121
    .line 122
    sget-object v15, Lcom/kousei/framework/oa;->g:Lcom/kousei/framework/u;

    .line 123
    .line 124
    invoke-static {v14, v15, v0}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 125
    .line 126
    .line 127
    const-string v0, "brainpoolP160t1"

    .line 128
    .line 129
    sget-object v14, Lcom/kousei/framework/oa;->h:Lcom/kousei/framework/u;

    .line 130
    .line 131
    invoke-static {v0, v14, v1}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 132
    .line 133
    .line 134
    const-string v0, "brainpoolP192r1"

    .line 135
    .line 136
    sget-object v1, Lcom/kousei/framework/oa;->i:Lcom/kousei/framework/u;

    .line 137
    .line 138
    invoke-static {v0, v1, v2}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 139
    .line 140
    .line 141
    const-string v0, "brainpoolP192t1"

    .line 142
    .line 143
    sget-object v1, Lcom/kousei/framework/oa;->j:Lcom/kousei/framework/u;

    .line 144
    .line 145
    invoke-static {v0, v1, v3}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 146
    .line 147
    .line 148
    const-string v0, "brainpoolP224r1"

    .line 149
    .line 150
    sget-object v1, Lcom/kousei/framework/oa;->k:Lcom/kousei/framework/u;

    .line 151
    .line 152
    invoke-static {v0, v1, v4}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 153
    .line 154
    .line 155
    const-string v0, "brainpoolP224t1"

    .line 156
    .line 157
    sget-object v1, Lcom/kousei/framework/oa;->l:Lcom/kousei/framework/u;

    .line 158
    .line 159
    invoke-static {v0, v1, v5}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 160
    .line 161
    .line 162
    const-string v0, "brainpoolP256r1"

    .line 163
    .line 164
    sget-object v1, Lcom/kousei/framework/oa;->m:Lcom/kousei/framework/u;

    .line 165
    .line 166
    invoke-static {v0, v1, v6}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 167
    .line 168
    .line 169
    const-string v0, "brainpoolP256t1"

    .line 170
    .line 171
    sget-object v1, Lcom/kousei/framework/oa;->n:Lcom/kousei/framework/u;

    .line 172
    .line 173
    invoke-static {v0, v1, v7}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 174
    .line 175
    .line 176
    const-string v0, "brainpoolP320r1"

    .line 177
    .line 178
    sget-object v1, Lcom/kousei/framework/oa;->o:Lcom/kousei/framework/u;

    .line 179
    .line 180
    invoke-static {v0, v1, v8}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 181
    .line 182
    .line 183
    const-string v0, "brainpoolP320t1"

    .line 184
    .line 185
    sget-object v1, Lcom/kousei/framework/oa;->p:Lcom/kousei/framework/u;

    .line 186
    .line 187
    invoke-static {v0, v1, v9}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 188
    .line 189
    .line 190
    const-string v0, "brainpoolP384r1"

    .line 191
    .line 192
    sget-object v1, Lcom/kousei/framework/oa;->q:Lcom/kousei/framework/u;

    .line 193
    .line 194
    invoke-static {v0, v1, v10}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 195
    .line 196
    .line 197
    const-string v0, "brainpoolP384t1"

    .line 198
    .line 199
    sget-object v1, Lcom/kousei/framework/oa;->r:Lcom/kousei/framework/u;

    .line 200
    .line 201
    invoke-static {v0, v1, v11}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 202
    .line 203
    .line 204
    const-string v0, "brainpoolP512r1"

    .line 205
    .line 206
    sget-object v1, Lcom/kousei/framework/oa;->s:Lcom/kousei/framework/u;

    .line 207
    .line 208
    invoke-static {v0, v1, v12}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 209
    .line 210
    .line 211
    const-string v0, "brainpoolP512t1"

    .line 212
    .line 213
    sget-object v1, Lcom/kousei/framework/oa;->t:Lcom/kousei/framework/u;

    .line 214
    .line 215
    invoke-static {v0, v1, v13}, Lcom/kousei/framework/na;->b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V

    .line 216
    .line 217
    .line 218
    return-void
.end method

.method public static a(Ljava/lang/String;)Ljava/math/BigInteger;
    .registers 3

    .line 1
    new-instance v0, Ljava/math/BigInteger;

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    invoke-static {p0}, Lcom/kousei/framework/v4;->a(Ljava/lang/String;)[B

    .line 5
    .line 6
    .line 7
    move-result-object p0

    .line 8
    invoke-direct {v0, v1, p0}, Ljava/math/BigInteger;-><init>(I[B)V

    .line 9
    .line 10
    .line 11
    return-object v0
.end method

.method public static b(Ljava/lang/String;Lcom/kousei/framework/u;Lcom/kousei/framework/bb;)V
    .registers 5

    .line 1
    sget-object v0, Lcom/kousei/framework/na;->a:Ljava/util/Hashtable;

    .line 2
    .line 3
    invoke-static {p0}, Lcom/kousei/framework/ja;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 4
    .line 5
    .line 6
    move-result-object v1

    .line 7
    invoke-virtual {v0, v1, p1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 8
    .line 9
    .line 10
    sget-object v0, Lcom/kousei/framework/na;->c:Ljava/util/Hashtable;

    .line 11
    .line 12
    invoke-virtual {v0, p1, p0}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 13
    .line 14
    .line 15
    sget-object p0, Lcom/kousei/framework/na;->b:Ljava/util/Hashtable;

    .line 16
    .line 17
    invoke-virtual {p0, p1, p2}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 18
    .line 19
    .line 20
    return-void
.end method
