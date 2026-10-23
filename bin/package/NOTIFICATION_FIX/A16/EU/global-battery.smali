.class public Lcom/android/server/MiuiBatteryIntelligence;
.super Ljava/lang/Object;
.source "MiuiBatteryIntelligence.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;,
        Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;,
        Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;,
        Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;,
        Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;,
        Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;,
        Lcom/android/server/MiuiBatteryIntelligence$AICRCapabilityAccess;,
        Lcom/android/server/MiuiBatteryIntelligence$SensorChargeState;,
        Lcom/android/server/MiuiBatteryIntelligence$BatteryNotificationListernerService;
    }
.end annotation


# static fields
.field private static final ACTION_CPUKEEPHEAT_STOP_TEMPBOOST:Ljava/lang/String; = "miui.intent.action.ACTION_CPUKEEPHEAT_STOP_TEMPBOOST"

.field private static final ACTION_DEAD_SLEEP_CONTROL:Ljava/lang/String; = "com.miui.powerkeeper.deadsleep.pad"

.field private static final ACTION_DELAY_STOP_TEMPBOOST:Ljava/lang/String; = "miui.intent.action.ACTION_DELAY_STOP_TEMPBOOST"

.field private static final ACTION_DISCHARGING_TIMER:Ljava/lang/String; = "miui.intent.action.ACTION_DISCHARGING_TIMER"

.field public static final ACTION_ERROR_BATT_TO_IMPL:Ljava/lang/String; = "miui.intent.action.ACTION_ERROR_BATT_TO_IMPL"

.field private static final ACTION_LOW_TEMP_CHARGE:Ljava/lang/String; = "miui.intent.action.ACTION_LOW_TEMP_FAST_CHARGING"

.field private static final ACTION_LOW_TEMP_CHARGE_TIMER:Ljava/lang/String; = "miui.intent.action.ACTION_LOW_TEMP_CHARGE_TIMER"

.field public static final ACTION_NEED_SCAN_WIFI:Ljava/lang/String; = "miui.intent.action.NEED_SCAN_WIFI"

.field private static final ACTION_PK_LOW_TEMP_CHARGE:Ljava/lang/String; = "miui.intent.action.ACTION_POWER_KEEPER_LOW_TEMP_FAST_CHARGING"

.field public static final ADJUST_VOLTAGE:Ljava/lang/String; = "miui.intent.action.ADJUST_VOLTAGE"

.field public static final ADJUST_VOLTAGE_R_EXTRA:Ljava/lang/String; = "miui.intent.extra.ADJUST_VOLTAGE_R_VALUE"

.field public static final ADJUST_VOLTAGE_TL_EXTRA:Ljava/lang/String; = "miui.intent.extra.ADJUST_VOLTAGE_TL"

.field public static final ADJUST_VOLTAGE_TS_EXTRA:Ljava/lang/String; = "miui.intent.extra.ADJUST_VOLTAGE_TS"

.field private static final BOARD_SENSOR_TEMP_PATH:Ljava/lang/String; = "/sys/class/thermal/thermal_message/board_sensor_temp"

.field private static final BOARD_SENSOR_TEMP_THRESHOLD:I = 0x24

.field private static final BOOT_ALARM_INTENT_SERVICE:Ljava/lang/String; = "com.miui.powercenter.provider.BootAlarmIntentService"

.field public static final CYCLE_CHECK:Ljava/lang/String; = "miui.intent.action.CYCLE_CHECK"

.field private static final DEBUG:Z

.field private static final EXTRA_DEAD_SLEEP_CONTROL:Ljava/lang/String; = "deepSleepStatus"

.field public static final EXTRA_ERROR_BATT_TO_IMPL:Ljava/lang/String; = "miui.intent.extra.EXTRA_ERROR_BATT_TO_IMPL"

.field private static final EXTRA_LOW_TEMP_CHARGE:Ljava/lang/String; = "miui.intent.extra.ACTION_LOW_TEMP_FAST_CHARGING"

.field private static final EXTRA_PK_LOW_TEMP_CHARGE:Ljava/lang/String; = "miui.intent.extra.ACTION_POWER_KEEPER_LOW_TEMP_FAST_CHARGING"

.field public static final FUNCTION_GAME_SLOW_CHARGE:I = 0x400

.field public static final FUNCTION_LONG_TERM_CHARGEING_PROTECTION:I = 0x10

.field public static final FUNCTION_LOW_BATTERY_FAST_CHARGE:I = 0x8

.field public static final FUNCTION_LOW_TEMP_CHARGE:I = 0x100

.field public static final FUNCTION_NAVIGATION_CHARGE:I = 0x2

.field public static final FUNCTION_OUT_DOOR_CHARGE:I = 0x4

.field public static final FUNCTION_PERCEPTION_CHARGE:I = 0x40

.field public static final FUNCTION_TRAVEL_CHARGE:I = 0x200

.field private static final GET_CHARGETYPE_DELAY:J = 0x2710L

.field private static final HALFMIN:J = 0x7530L

.field private static volatile INSTANCE:Lcom/android/server/MiuiBatteryIntelligence; = null

.field private static final INTERVAL:J = 0x493e0L

.field private static final INTERVAL_LOW_TEMP_CHARGE:J = 0xea60L

.field private static final KEY_CHARGE_PROTECT_PARAMS:Ljava/lang/String; = "key_for_charge_protect_params"

.field private static final KEY_FOR_PERSIST_BATTERY_SN:Ljava/lang/String; = "key_persist_battery_sn"

.field private static final MIUI_SECURITYCENTER_APP:Ljava/lang/String; = "com.miui.securitycenter"

.field private static final ONE_MINUTE:J = 0xea60L

.field private static final PAD_ENTER_SHIPMODE_TIME:J

.field private static final PERMISSON_MIUIBATTERY_BROADCAST:Ljava/lang/String; = "com.xiaomi.permission.miuibatteryintelligence"

.field public static final SENSOR_SCENE_CLASS0:I = 0x7

.field public static final SENSOR_SCENE_GAME:I = 0x13

.field public static final SENSOR_SCENE_NORMAL:I = 0x0

.field public static final SENSOR_SCENE_OHTER:I = -0x1

.field public static final SENSOR_SCENE_PHONE:I = 0x5

.field public static final SENSOR_SCENE_VIDEO:I = 0xe

.field public static final SENSOR_SCENE_VIDEO_CHAT:I = 0xb

.field private static final TEN_HOUR:J = 0x2255100L

.field private static final THIRTY_MINUTE:J = 0x1b7740L

.field private static mIsSatisfyTempLevelCondition:Z

.field private static mIsSatisfyTempSocCondition:Z

.field private static final mIsSupportShipMode:Z

.field private static final mIsSupportShipModeV2:Z

.field private static mRValue:I


# instance fields
.field private MAP_APP:[Ljava/lang/String;

.field private MIUI_SUPPORT_EXTREME_COLD_CHARGE:[Ljava/lang/String;

.field private MIUI_SUPPORT_LOW_TEMP_CHARGE:[Ljava/lang/String;

.field private final TAG:Ljava/lang/String;

.field private mAlarmManager:Landroid/app/AlarmManager;

.field private mBateryLevel:I

.field private mBatteryTempLevel:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;

.field private mBatteryTempSocTime:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;

.field private mBoardSensorTempListener:Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

.field private mBootCompleted:Z

.field private mChargeCloudControl:Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;

.field private mConnectivityManager:Landroid/net/ConnectivityManager;

.field public mContext:Landroid/content/Context;

.field private mCpuHeatStartTime:J

.field private mCpuHeatTime:J

.field private mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

.field private mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

.field private mDisChargingPendingIntent:Landroid/app/PendingIntent;

.field private mEndScreenOffTime:J

.field private mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

.field private mIsDeadSleep:I

.field private mIsNetWorkConnected:Z

.field private mIsOutDoorDisableFromCloud:Z

.field private mIsScreenOn:Z

.field private mLastBatteryTemp:I

.field private mLastBoardSensorTemp:I

.field private mLastPlugType:I

.field private mLastPlugged:Z

.field private mLastSoc:I

.field private mLowTempAutoReCharge:Z

.field private mLowTempChargeEnabledFromCloud:Z

.field private mLowTempChargeNotificationFlag:Z

.field private mLowTempChargePendingIntent:Landroid/app/PendingIntent;

.field private mMapApplist:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private mMiCharge:Lmiui/util/IMiCharge;

.field private mNeedSendGameStateFlag:Z

.field private mPendingIntentCycleCheck:Landroid/app/PendingIntent;

.field private mPhoneScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

.field private mPlugType:I

.field private mSceneChangeReceiver:Landroid/content/BroadcastReceiver;

.field private mSecurityManager:Lmiui/security/SecurityManager;

.field private mSensorChargeScenceMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/Integer;",
            "Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;",
            ">;"
        }
    .end annotation
.end field

.field private mShipModeEnabledFromCloud:Z

.field private mStartCpuHeat:Z

.field private mStartScreenOffTime:J

.field private mStartTempBoost:Z

.field private mStateChangedReceiver:Landroid/content/BroadcastReceiver;

.field private mSupportedSB:Z

.field private mTemp:I

.field private mVedioChatScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

.field private mVedioScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

.field private mWaitScreenOffOneMinute:Z

.field private mWifiState:I

.field public mfunctions:I

.field private mstartBoostOnGoing:Z


# direct methods
.method static bridge synthetic -$$Nest$fgetMIUI_SUPPORT_EXTREME_COLD_CHARGE(Lcom/android/server/MiuiBatteryIntelligence;)[Ljava/lang/String;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MIUI_SUPPORT_EXTREME_COLD_CHARGE:[Ljava/lang/String;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetMIUI_SUPPORT_LOW_TEMP_CHARGE(Lcom/android/server/MiuiBatteryIntelligence;)[Ljava/lang/String;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MIUI_SUPPORT_LOW_TEMP_CHARGE:[Ljava/lang/String;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmAlarmManager(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/AlarmManager;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmBateryLevel(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBateryLevel:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmBatteryTempLevel(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBatteryTempLevel:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmBatteryTempSocTime(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBatteryTempSocTime:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmBoardSensorTempListener(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBoardSensorTempListener:Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmBootCompleted(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBootCompleted:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmChargeCloudControl(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mChargeCloudControl:Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmCpuHeatStartTime(Lcom/android/server/MiuiBatteryIntelligence;)J
    .registers 3

    iget-wide v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatStartTime:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$fgetmCpuHeatTime(Lcom/android/server/MiuiBatteryIntelligence;)J
    .registers 3

    iget-wide v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatTime:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$fgetmCpuKeepHeatStopTempBoostPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/PendingIntent;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmDelayStopTempBoostPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/PendingIntent;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmDisChargingPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/PendingIntent;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDisChargingPendingIntent:Landroid/app/PendingIntent;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmEndScreenOffTime(Lcom/android/server/MiuiBatteryIntelligence;)J
    .registers 3

    iget-wide v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mEndScreenOffTime:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$fgetmHandler(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmIsDeadSleep(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsDeadSleep:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmIsNetWorkConnected(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsNetWorkConnected:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmIsOutDoorDisableFromCloud(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsOutDoorDisableFromCloud:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmIsScreenOn(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsScreenOn:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLastBatteryTemp(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastBatteryTemp:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLastBoardSensorTemp(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastBoardSensorTemp:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLastPlugType(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugType:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLastPlugged(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugged:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLastSoc(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastSoc:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLowTempAutoReCharge(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempAutoReCharge:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLowTempChargeEnabledFromCloud(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeEnabledFromCloud:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmLowTempChargePendingIntent(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/PendingIntent;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargePendingIntent:Landroid/app/PendingIntent;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmMapApplist(Lcom/android/server/MiuiBatteryIntelligence;)Ljava/util/ArrayList;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMapApplist:Ljava/util/ArrayList;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmMiCharge(Lcom/android/server/MiuiBatteryIntelligence;)Lmiui/util/IMiCharge;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmNeedSendGameStateFlag(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mNeedSendGameStateFlag:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmPendingIntentCycleCheck(Lcom/android/server/MiuiBatteryIntelligence;)Landroid/app/PendingIntent;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPendingIntentCycleCheck:Landroid/app/PendingIntent;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmPhoneScence(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPhoneScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmPlugType(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPlugType:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmSecurityManager(Lcom/android/server/MiuiBatteryIntelligence;)Lmiui/security/SecurityManager;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSecurityManager:Lmiui/security/SecurityManager;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmSensorChargeScenceMap(Lcom/android/server/MiuiBatteryIntelligence;)Ljava/util/HashMap;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSensorChargeScenceMap:Ljava/util/HashMap;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmShipModeEnabledFromCloud(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mShipModeEnabledFromCloud:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmStartCpuHeat(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartCpuHeat:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmStartScreenOffTime(Lcom/android/server/MiuiBatteryIntelligence;)J
    .registers 3

    iget-wide v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartScreenOffTime:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$fgetmStartTempBoost(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartTempBoost:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmSupportedSB(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSupportedSB:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmTemp(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mTemp:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmVedioChatScence(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mVedioChatScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmVedioScence(Lcom/android/server/MiuiBatteryIntelligence;)Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;
    .registers 1

    iget-object p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mVedioScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmWaitScreenOffOneMinute(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mWaitScreenOffOneMinute:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmWifiState(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    iget p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mWifiState:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetmstartBoostOnGoing(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mstartBoostOnGoing:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fputmBateryLevel(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBateryLevel:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmBootCompleted(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBootCompleted:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmCpuHeatStartTime(Lcom/android/server/MiuiBatteryIntelligence;J)V
    .registers 3

    iput-wide p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatStartTime:J

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmCpuHeatTime(Lcom/android/server/MiuiBatteryIntelligence;J)V
    .registers 3

    iput-wide p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatTime:J

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmCpuKeepHeatStopTempBoostPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;Landroid/app/PendingIntent;)V
    .registers 2

    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmDelayStopTempBoostPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;Landroid/app/PendingIntent;)V
    .registers 2

    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmDisChargingPendingIntent(Lcom/android/server/MiuiBatteryIntelligence;Landroid/app/PendingIntent;)V
    .registers 2

    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDisChargingPendingIntent:Landroid/app/PendingIntent;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmEndScreenOffTime(Lcom/android/server/MiuiBatteryIntelligence;J)V
    .registers 3

    iput-wide p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mEndScreenOffTime:J

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmIsDeadSleep(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsDeadSleep:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmIsNetWorkConnected(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsNetWorkConnected:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmIsOutDoorDisableFromCloud(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsOutDoorDisableFromCloud:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmIsScreenOn(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsScreenOn:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLastBatteryTemp(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastBatteryTemp:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLastBoardSensorTemp(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastBoardSensorTemp:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLastPlugType(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugType:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLastPlugged(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugged:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLastSoc(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastSoc:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLowTempAutoReCharge(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempAutoReCharge:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLowTempChargeEnabledFromCloud(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeEnabledFromCloud:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLowTempChargeNotificationFlag(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeNotificationFlag:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmLowTempChargePendingIntent(Lcom/android/server/MiuiBatteryIntelligence;Landroid/app/PendingIntent;)V
    .registers 2

    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargePendingIntent:Landroid/app/PendingIntent;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmNeedSendGameStateFlag(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mNeedSendGameStateFlag:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmPlugType(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPlugType:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmSecurityManager(Lcom/android/server/MiuiBatteryIntelligence;Lmiui/security/SecurityManager;)V
    .registers 2

    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSecurityManager:Lmiui/security/SecurityManager;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmShipModeEnabledFromCloud(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mShipModeEnabledFromCloud:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmStartCpuHeat(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartCpuHeat:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmStartScreenOffTime(Lcom/android/server/MiuiBatteryIntelligence;J)V
    .registers 3

    iput-wide p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartScreenOffTime:J

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmStartTempBoost(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartTempBoost:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmTemp(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mTemp:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmWaitScreenOffOneMinute(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mWaitScreenOffOneMinute:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmWifiState(Lcom/android/server/MiuiBatteryIntelligence;I)V
    .registers 2

    iput p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mWifiState:I

    return-void
.end method

.method static bridge synthetic -$$Nest$fputmstartBoostOnGoing(Lcom/android/server/MiuiBatteryIntelligence;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mstartBoostOnGoing:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$mcancelCpuKeepHeatStopTempBoostAlarm(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->cancelCpuKeepHeatStopTempBoostAlarm()V

    return-void
.end method

.method static bridge synthetic -$$Nest$mcancelDelayStopTempBoostAlarm(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->cancelDelayStopTempBoostAlarm()V

    return-void
.end method

.method static bridge synthetic -$$Nest$mgetBoardSensorTemp(Lcom/android/server/MiuiBatteryIntelligence;)I
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->getBoardSensorTemp()I

    move-result p0

    return p0
.end method

.method static bridge synthetic -$$Nest$mgetTimeHours(Lcom/android/server/MiuiBatteryIntelligence;J)Ljava/lang/String;
    .registers 3

    invoke-direct {p0, p1, p2}, Lcom/android/server/MiuiBatteryIntelligence;->getTimeHours(J)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static bridge synthetic -$$Nest$mhandleBoostNotification(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->handleBoostNotification()V

    return-void
.end method

.method static bridge synthetic -$$Nest$misSupportLowTempProduct(Lcom/android/server/MiuiBatteryIntelligence;)Z
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempProduct()Z

    move-result p0

    return p0
.end method

.method static bridge synthetic -$$Nest$mstartCpuKeepHeatStopTempBoostAlarm(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->startCpuKeepHeatStopTempBoostAlarm()V

    return-void
.end method

.method static bridge synthetic -$$Nest$mstartDelayStopTempBoostAlarm(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->startDelayStopTempBoostAlarm()V

    return-void
.end method

.method static bridge synthetic -$$Nest$mstopCpuHeat(Lcom/android/server/MiuiBatteryIntelligence;)V
    .registers 1

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->stopCpuHeat()V

    return-void
.end method

.method static bridge synthetic -$$Nest$sfgetDEBUG()Z
    .registers 1

    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->DEBUG:Z

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetPAD_ENTER_SHIPMODE_TIME()J
    .registers 2

    sget-wide v0, Lcom/android/server/MiuiBatteryIntelligence;->PAD_ENTER_SHIPMODE_TIME:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$sfgetmIsSatisfyTempLevelCondition()Z
    .registers 1

    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempLevelCondition:Z

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetmIsSatisfyTempSocCondition()Z
    .registers 1

    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempSocCondition:Z

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetmIsSupportShipModeV2()Z
    .registers 1

    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSupportShipModeV2:Z

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetmRValue()I
    .registers 1

    sget v0, Lcom/android/server/MiuiBatteryIntelligence;->mRValue:I

    return v0
.end method

.method static bridge synthetic -$$Nest$sfputmIsSatisfyTempLevelCondition(Z)V
    .registers 1

    sput-boolean p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempLevelCondition:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputmIsSatisfyTempSocCondition(Z)V
    .registers 1

    sput-boolean p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempSocCondition:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputmRValue(I)V
    .registers 1

    sput p0, Lcom/android/server/MiuiBatteryIntelligence;->mRValue:I

    return-void
.end method

.method static constructor <clinit>()V
    .registers 2

    .line 74
    const-string/jumbo v0, "persist.sys.debug_stats"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    sput-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->DEBUG:Z

    .line 105
    const-string/jumbo v0, "persist.vendor.battery.shipmode"

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    sput-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSupportShipMode:Z

    .line 106
    const-string/jumbo v0, "persist.vendor.battery.shipmode.V2"

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    sput-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSupportShipModeV2:Z

    .line 107
    const/4 v0, 0x0

    sput-object v0, Lcom/android/server/MiuiBatteryIntelligence;->INSTANCE:Lcom/android/server/MiuiBatteryIntelligence;

    .line 118
    sput-boolean v1, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempSocCondition:Z

    .line 119
    sput-boolean v1, Lcom/android/server/MiuiBatteryIntelligence;->mIsSatisfyTempLevelCondition:Z

    .line 120
    sput v1, Lcom/android/server/MiuiBatteryIntelligence;->mRValue:I

    .line 125
    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->DEBUG:Z

    if-eqz v0, :cond_2b

    const/4 v0, 0x1

    goto :goto_2d

    :cond_2b
    const/16 v0, 0x10e0

    :goto_2d
    mul-int/lit8 v0, v0, 0x3c

    mul-int/lit16 v0, v0, 0x3e8

    int-to-long v0, v0

    sput-wide v0, Lcom/android/server/MiuiBatteryIntelligence;->PAD_ENTER_SHIPMODE_TIME:J

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;)V
    .registers 12
    .param p1, "context"    # Landroid/content/Context;

    .line 539
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 73
    const-string v0, "MiuiBatteryIntelligence"

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->TAG:Ljava/lang/String;

    .line 134
    const/4 v0, -0x1

    iput v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastSoc:I

    .line 135
    iput v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugType:I

    .line 142
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMapApplist:Ljava/util/ArrayList;

    .line 144
    invoke-static {}, Lmiui/util/IMiCharge;->getInstance()Lmiui/util/IMiCharge;

    move-result-object v0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    .line 145
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;

    invoke-direct {v0, p0}, Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;-><init>(Lcom/android/server/MiuiBatteryIntelligence;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBatteryTempSocTime:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempSocTimeInfo;

    .line 146
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;

    invoke-direct {v0, p0}, Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;-><init>(Lcom/android/server/MiuiBatteryIntelligence;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBatteryTempLevel:Lcom/android/server/MiuiBatteryIntelligence$BatteryTempLevelInfo;

    .line 156
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsOutDoorDisableFromCloud:Z

    .line 157
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mstartBoostOnGoing:Z

    .line 158
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeNotificationFlag:Z

    .line 159
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempAutoReCharge:Z

    .line 160
    iput-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeEnabledFromCloud:Z

    .line 161
    iput-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mShipModeEnabledFromCloud:Z

    .line 163
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsNetWorkConnected:Z

    .line 164
    iput v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsDeadSleep:I

    .line 168
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    const-string v2, "Phone"

    invoke-direct {v0, p0, v2}, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPhoneScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    .line 169
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    const-string v2, "VedioChat"

    invoke-direct {v0, p0, v2}, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mVedioChatScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    .line 170
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    const-string v2, "Vedio"

    invoke-direct {v0, p0, v2}, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mVedioScence:Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    .line 172
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$1;

    invoke-direct {v0, p0}, Lcom/android/server/MiuiBatteryIntelligence$1;-><init>(Lcom/android/server/MiuiBatteryIntelligence;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSensorChargeScenceMap:Ljava/util/HashMap;

    .line 180
    const-string v0, "com.tencent.map"

    const-string v2, "com.baidu.BaiduMap"

    const-string v3, "com.autonavi.minimap"

    filled-new-array {v3, v0, v2}, [Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MAP_APP:[Ljava/lang/String;

    .line 186
    const-string v8, "USB_PD"

    const-string v9, "HVCHG"

    const-string v2, "HVDCP"

    const-string v3, "HVDCP_3"

    const-string v4, "HVDCP_3_B"

    const-string v5, "HVDCP_3P5"

    const-string v6, "PD"

    const-string v7, "PD_PPS"

    filled-new-array/range {v2 .. v9}, [Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MIUI_SUPPORT_EXTREME_COLD_CHARGE:[Ljava/lang/String;

    .line 197
    const-wide/16 v2, 0x0

    iput-wide v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartScreenOffTime:J

    .line 198
    iput-wide v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mEndScreenOffTime:J

    .line 200
    const-string v0, "HVDCP_3P5"

    const-string v4, "PD_PPS"

    const-string v5, "HVDCP_3"

    const-string v6, "HVDCP_3_B"

    filled-new-array {v5, v6, v0, v4}, [Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MIUI_SUPPORT_LOW_TEMP_CHARGE:[Ljava/lang/String;

    .line 218
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartTempBoost:Z

    .line 219
    iput-wide v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatTime:J

    .line 220
    iput-wide v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatStartTime:J

    .line 221
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartCpuHeat:Z

    .line 222
    iput-boolean v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mWaitScreenOffOneMinute:Z

    .line 223
    iput v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastBoardSensorTemp:I

    .line 224
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBoardSensorTempListener:Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

    .line 225
    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDisChargingPendingIntent:Landroid/app/PendingIntent;

    .line 226
    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 227
    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 287
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$2;

    invoke-direct {v0, p0}, Lcom/android/server/MiuiBatteryIntelligence$2;-><init>(Lcom/android/server/MiuiBatteryIntelligence;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStateChangedReceiver:Landroid/content/BroadcastReceiver;

    .line 519
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$3;

    invoke-direct {v0, p0}, Lcom/android/server/MiuiBatteryIntelligence$3;-><init>(Lcom/android/server/MiuiBatteryIntelligence;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSceneChangeReceiver:Landroid/content/BroadcastReceiver;

    .line 540
    invoke-direct {p0, p1}, Lcom/android/server/MiuiBatteryIntelligence;->init(Landroid/content/Context;)V

    .line 541
    return-void
.end method

.method private cancelCpuKeepHeatStopTempBoostAlarm()V
    .registers 3

    .line 754
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    if-eqz v0, :cond_19

    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    if-eqz v0, :cond_19

    .line 755
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    invoke-virtual {v0, v1}, Landroid/app/AlarmManager;->cancel(Landroid/app/PendingIntent;)V

    .line 756
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 757
    const-string v0, "MiuiBatteryIntelligence"

    const-string v1, "cancel delay stop temp boost alarm(cpu keep heat over 10H)"

    invoke-static {v0, v1}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 759
    :cond_19
    return-void
.end method

.method private cancelDelayStopTempBoostAlarm()V
    .registers 3

    .line 735
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    if-eqz v0, :cond_19

    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    if-eqz v0, :cond_19

    .line 736
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    invoke-virtual {v0, v1}, Landroid/app/AlarmManager;->cancel(Landroid/app/PendingIntent;)V

    .line 737
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 738
    const-string v0, "MiuiBatteryIntelligence"

    const-string v1, "cancel delay stop temp boost alarm"

    invoke-static {v0, v1}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 740
    :cond_19
    return-void
.end method

.method private getBoardSensorTemp()I
    .registers 6

    .line 272
    const-string v0, "MiuiBatteryIntelligence"

    const/4 v1, 0x0

    .line 274
    .local v1, "boardSensorTemp":I
    :try_start_3
    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    const-string v3, "board_sensor_temp"

    invoke-virtual {v2, v3}, Lmiui/util/IMiCharge;->getMiChargePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 275
    .local v2, "boardSensorTempStr":Ljava/lang/String;
    sget-boolean v3, Lcom/android/server/MiuiBatteryIntelligence;->DEBUG:Z

    if-eqz v3, :cond_25

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "boardSensorTemp = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v3}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 276
    :cond_25
    invoke-static {v2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v3

    if-nez v3, :cond_33

    .line 277
    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v3

    move v1, v3

    .line 278
    div-int/lit16 v0, v1, 0x3e8
    :try_end_32
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_32} :catch_34

    move v1, v0

    .line 283
    .end local v2    # "boardSensorTempStr":Ljava/lang/String;
    :cond_33
    goto :goto_3e

    .line 280
    :catch_34
    move-exception v2

    .line 281
    .local v2, "e":Ljava/lang/Exception;
    const-string/jumbo v3, "get board_sensor_temp failed"

    invoke-static {v0, v3, v2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 282
    invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V

    .line 284
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_3e
    return v1
.end method

.method public static getInstance(Landroid/content/Context;)Lcom/android/server/MiuiBatteryIntelligence;
    .registers 3
    .param p0, "context"    # Landroid/content/Context;

    .line 529
    sget-object v0, Lcom/android/server/MiuiBatteryIntelligence;->INSTANCE:Lcom/android/server/MiuiBatteryIntelligence;

    if-nez v0, :cond_17

    .line 530
    const-class v0, Lcom/android/server/MiuiBatteryIntelligence;

    monitor-enter v0

    .line 531
    :try_start_7
    sget-object v1, Lcom/android/server/MiuiBatteryIntelligence;->INSTANCE:Lcom/android/server/MiuiBatteryIntelligence;

    if-nez v1, :cond_12

    .line 532
    new-instance v1, Lcom/android/server/MiuiBatteryIntelligence;

    invoke-direct {v1, p0}, Lcom/android/server/MiuiBatteryIntelligence;-><init>(Landroid/content/Context;)V

    sput-object v1, Lcom/android/server/MiuiBatteryIntelligence;->INSTANCE:Lcom/android/server/MiuiBatteryIntelligence;

    .line 534
    :cond_12
    monitor-exit v0

    goto :goto_17

    :catchall_14
    move-exception v1

    monitor-exit v0
    :try_end_16
    .catchall {:try_start_7 .. :try_end_16} :catchall_14

    throw v1

    .line 536
    :cond_17
    :goto_17
    sget-object v0, Lcom/android/server/MiuiBatteryIntelligence;->INSTANCE:Lcom/android/server/MiuiBatteryIntelligence;

    return-object v0
.end method

.method private getTimeHours(J)Ljava/lang/String;
    .registers 17
    .param p1, "totalMilliSeconds"    # J

    .line 704
    const-wide/16 v0, 0x0

    cmp-long v0, p1, v0

    if-lez v0, :cond_43

    .line 705
    const-wide/16 v0, 0x3e8

    div-long v0, p1, v0

    .line 706
    .local v0, "totalSeconds":J
    const-wide/16 v2, 0x3c

    rem-long v4, v0, v2

    .line 707
    .local v4, "currentSecond":J
    div-long v6, v0, v2

    .line 708
    .local v6, "totalMinutes":J
    rem-long v8, v6, v2

    .line 709
    .local v8, "currentMinute":J
    div-long v2, v6, v2

    .line 710
    .local v2, "totalHour":J
    const-wide/16 v10, 0x18

    rem-long v10, v2, v10

    .line 711
    .local v10, "currentHour":J
    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v12, v10, v11}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v12

    const-string/jumbo v13, "h"

    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-virtual {v12, v8, v9}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v12

    const-string/jumbo v13, "min"

    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-virtual {v12, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v12

    const-string/jumbo v13, "s"

    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v12

    return-object v12

    .line 713
    .end local v0    # "totalSeconds":J
    .end local v2    # "totalHour":J
    .end local v4    # "currentSecond":J
    .end local v6    # "totalMinutes":J
    .end local v8    # "currentMinute":J
    .end local v10    # "currentHour":J
    :cond_43
    const-string v0, "None"

    return-object v0
.end method

.method private handleBoostNotification()V
    .registers 5

    .line 774
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mTemp:I

    const/16 v1, -0x64

    if-gt v0, v1, :cond_2d

    iget-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugged:Z

    if-eqz v0, :cond_2d

    iget-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeNotificationFlag:Z

    if-nez v0, :cond_2d

    .line 775
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeNotificationFlag:Z

    .line 776
    new-instance v1, Landroid/content/Intent;

    const-string/jumbo v2, "miui.intent.action.ACTION_LOW_TEMP_FAST_CHARGING"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 777
    .local v1, "intent":Landroid/content/Intent;
    const-string/jumbo v2, "miui.intent.extra.ACTION_LOW_TEMP_FAST_CHARGING"

    invoke-virtual {v1, v2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 778
    const-string v0, "com.miui.securitycenter"

    invoke-virtual {v1, v0}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    .line 779
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    sget-object v2, Landroid/os/UserHandle;->ALL:Landroid/os/UserHandle;

    const-string v3, "com.xiaomi.permission.miuibatteryintelligence"

    invoke-virtual {v0, v1, v2, v3}, Landroid/content/Context;->sendBroadcastAsUser(Landroid/content/Intent;Landroid/os/UserHandle;Ljava/lang/String;)V

    .line 781
    .end local v1    # "intent":Landroid/content/Intent;
    :cond_2d
    return-void
.end method

.method private init(Landroid/content/Context;)V
    .registers 7
    .param p1, "context"    # Landroid/content/Context;

    .line 544
    iput-object p1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    .line 545
    const-string/jumbo v0, "persist.vendor.smartchg"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    iput v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    .line 546
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    const-string/jumbo v2, "smart_batt"

    invoke-virtual {v0, v2}, Lmiui/util/IMiCharge;->isFunctionSupported(Ljava/lang/String;)Z

    move-result v0

    iput-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSupportedSB:Z

    .line 547
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    invoke-static {}, Lcom/android/server/MiuiBgThread;->get()Lcom/android/server/MiuiBgThread;

    move-result-object v2

    invoke-virtual {v2}, Lcom/android/server/MiuiBgThread;->getLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v0, p0, v2}, Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    .line 548
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    const-string v2, "alarm"

    invoke-virtual {v0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    .line 550
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->MAP_APP:[Ljava/lang/String;

    invoke-direct {p0, v0}, Lcom/android/server/MiuiBatteryIntelligence;->initMapList([Ljava/lang/String;)V

    .line 552
    new-instance v0, Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;

    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    invoke-direct {v0, p0, v2}, Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Landroid/content/ContentResolver;)V

    iput-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mChargeCloudControl:Lcom/android/server/MiuiBatteryIntelligence$ChargeCloudControl;

    .line 553
    new-instance v0, Landroid/content/Intent;

    const-string/jumbo v2, "miui.intent.action.CYCLE_CHECK"

    invoke-direct {v0, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 554
    .local v0, "cycleCheck":Landroid/content/Intent;
    const/high16 v2, 0x40000000    # 2.0f

    invoke-virtual {v0, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 555
    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    const/high16 v3, 0x4000000

    invoke-static {v2, v1, v0, v3}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v1

    iput-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mPendingIntentCycleCheck:Landroid/app/PendingIntent;

    .line 558
    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->registerChangeStateReceiver()V

    .line 559
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    if-eqz v1, :cond_6b

    .line 560
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    const/16 v2, 0x11

    const-wide/16 v3, 0x4e20

    invoke-virtual {v1, v2, v3, v4}, Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;->sendMessageDelayed(IJ)V

    .line 562
    :cond_6b
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportTravelCharge()Z

    move-result v1

    if-eqz v1, :cond_74

    .line 563
    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->registerTravelSceneReceiver()V

    .line 565
    :cond_74
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempCharge()Z

    move-result v1

    if-eqz v1, :cond_8a

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempProduct()Z

    move-result v1

    if-eqz v1, :cond_8a

    .line 566
    new-instance v1, Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

    const-string v2, "/sys/class/thermal/thermal_message/board_sensor_temp"

    const/4 v3, 0x2

    invoke-direct {v1, p0, v2, v3}, Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;-><init>(Lcom/android/server/MiuiBatteryIntelligence;Ljava/lang/String;I)V

    iput-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBoardSensorTempListener:Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

    .line 568
    :cond_8a
    return-void
.end method

.method private initMapList([Ljava/lang/String;)V
    .registers 5
    .param p1, "maplist"    # [Ljava/lang/String;

    .line 605
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_1
    array-length v1, p1

    if-ge v0, v1, :cond_e

    .line 606
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMapApplist:Ljava/util/ArrayList;

    aget-object v2, p1, v0

    invoke-virtual {v1, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 605
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 608
    .end local v0    # "i":I
    :cond_e
    return-void
.end method

.method private isSupportLowTempProduct()Z
    .registers 3

    .line 631
    const-string/jumbo v0, "low_temp_charge"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lmiui/os/HyperOSCustFeatureResolve;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    return v0
.end method

.method private registerChangeStateReceiver()V
    .registers 5

    .line 571
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 572
    .local v0, "i":Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.BATTERY_CHANGED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 573
    const-string v1, "android.intent.action.BOOT_COMPLETED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 574
    const-string v1, "android.intent.action.ACTION_SHUTDOWN"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 575
    const-string/jumbo v1, "miui.intent.action.CYCLE_CHECK"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 576
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportOutDoorCharge()Z

    move-result v1

    if-eqz v1, :cond_30

    .line 577
    const-string v1, "android.net.conn.CONNECTIVITY_CHANGE"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 578
    const-string v1, "android.net.wifi.WIFI_STATE_CHANGED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 579
    const-string/jumbo v1, "miui.intent.action.NEED_SCAN_WIFI"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 581
    :cond_30
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempCharge()Z

    move-result v1

    if-nez v1, :cond_3c

    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportShipMode()Z

    move-result v1

    if-eqz v1, :cond_46

    .line 582
    :cond_3c
    const-string v1, "android.intent.action.SCREEN_OFF"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 583
    const-string v1, "android.intent.action.SCREEN_ON"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 585
    :cond_46
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempCharge()Z

    move-result v1

    if-eqz v1, :cond_59

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempProduct()Z

    move-result v1

    if-nez v1, :cond_59

    .line 586
    const-string/jumbo v1, "miui.intent.action.ACTION_LOW_TEMP_CHARGE_TIMER"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    goto :goto_77

    .line 587
    :cond_59
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempCharge()Z

    move-result v1

    if-eqz v1, :cond_77

    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportLowTempProduct()Z

    move-result v1

    if-eqz v1, :cond_77

    .line 588
    const-string/jumbo v1, "miui.intent.action.ACTION_DISCHARGING_TIMER"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 589
    const-string/jumbo v1, "miui.intent.action.ACTION_DELAY_STOP_TEMPBOOST"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 590
    const-string/jumbo v1, "miui.intent.action.ACTION_CPUKEEPHEAT_STOP_TEMPBOOST"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 592
    :cond_77
    :goto_77
    invoke-virtual {p0}, Lcom/android/server/MiuiBatteryIntelligence;->isSupportShipMode()Z

    move-result v1

    if-eqz v1, :cond_82

    .line 593
    const-string v1, "com.miui.powerkeeper.deadsleep.pad"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 595
    :cond_82
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStateChangedReceiver:Landroid/content/BroadcastReceiver;

    const/4 v3, 0x2

    invoke-virtual {v1, v2, v0, v3}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    .line 596
    return-void
.end method

.method private registerTravelSceneReceiver()V
    .registers 5

    .line 599
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 600
    .local v0, "s":Landroid/content/IntentFilter;
    const-string v1, "com.xiaomi.cognition.SCENE_CHANGE"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 601
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSceneChangeReceiver:Landroid/content/BroadcastReceiver;

    const/4 v3, 0x2

    invoke-virtual {v1, v2, v0, v3}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    .line 602
    return-void
.end method

.method private startCpuKeepHeatStopTempBoostAlarm()V
    .registers 7

    .line 762
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    if-nez v0, :cond_32

    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    if-eqz v0, :cond_32

    .line 763
    new-instance v0, Landroid/content/Intent;

    const-string/jumbo v1, "miui.intent.action.ACTION_CPUKEEPHEAT_STOP_TEMPBOOST"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 764
    .local v0, "intent":Landroid/content/Intent;
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    const/4 v2, 0x0

    const/high16 v3, 0x4000000

    invoke-static {v1, v2, v0, v3}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v1

    iput-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 766
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    .line 767
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v2

    const-wide/32 v4, 0x927c0

    add-long/2addr v2, v4

    iget-object v4, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuKeepHeatStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 766
    const/4 v5, 0x2

    invoke-virtual {v1, v5, v2, v3, v4}, Landroid/app/AlarmManager;->setExactAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V

    .line 768
    const-string v1, "MiuiBatteryIntelligence"

    const-string v2, "cpu keep heat over 10H, start delay 10min stop temp boost alarm"

    invoke-static {v1, v2}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 770
    .end local v0    # "intent":Landroid/content/Intent;
    :cond_32
    return-void
.end method

.method private startDelayStopTempBoostAlarm()V
    .registers 7

    .line 743
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    if-nez v0, :cond_33

    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    if-eqz v0, :cond_33

    .line 744
    new-instance v0, Landroid/content/Intent;

    const-string/jumbo v1, "miui.intent.action.ACTION_DELAY_STOP_TEMPBOOST"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 745
    .local v0, "intent":Landroid/content/Intent;
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    const/4 v2, 0x0

    const/high16 v3, 0x4000000

    invoke-static {v1, v2, v0, v3}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v1

    iput-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 747
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mAlarmManager:Landroid/app/AlarmManager;

    .line 748
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v2

    const-wide/32 v4, 0x2bf20

    add-long/2addr v2, v4

    iget-object v4, p0, Lcom/android/server/MiuiBatteryIntelligence;->mDelayStopTempBoostPendingIntent:Landroid/app/PendingIntent;

    .line 747
    const/4 v5, 0x2

    invoke-virtual {v1, v5, v2, v3, v4}, Landroid/app/AlarmManager;->setExactAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V

    .line 749
    const-string v1, "MiuiBatteryIntelligence"

    const-string/jumbo v2, "start delay 3min stop temp boost alarm"

    invoke-static {v1, v2}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 751
    .end local v0    # "intent":Landroid/content/Intent;
    :cond_33
    return-void
.end method

.method private stopCpuHeat()V
    .registers 8

    .line 718
    const-string v0, "MiuiBatteryIntelligence"

    :try_start_2
    const-string/jumbo v1, "enter stopCpuHeat"

    invoke-static {v0, v1}, Landroid/util/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 719
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    const-string/jumbo v2, "unset_cycle_power"

    invoke-virtual {v1, v2}, Lmiui/util/IMiCharge;->getMiChargePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 720
    .local v1, "result":Ljava/lang/String;
    invoke-static {v1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    const/4 v3, 0x0

    if-eqz v2, :cond_32

    .line 721
    const-string/jumbo v2, "stopCpuHeat error"

    invoke-static {v0, v2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 722
    iget v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mTemp:I

    iget-boolean v4, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsScreenOn:Z

    const/4 v5, 0x1

    if-eqz v4, :cond_27

    move v4, v5

    goto :goto_28

    :cond_27
    move v4, v3

    :goto_28
    iget v6, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLastPlugType:I

    if-lez v6, :cond_2e

    move v6, v5

    goto :goto_2f

    :cond_2e
    move v6, v3

    :goto_2f
    invoke-static {v2, v4, v6, v5}, Lcom/android/server/battery/ChargeDFXCode;->supportLowTempChargeError(IIII)V

    .line 724
    :cond_32
    iput-boolean v3, p0, Lcom/android/server/MiuiBatteryIntelligence;->mStartCpuHeat:Z

    .line 725
    const-wide/16 v2, 0x0

    iput-wide v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mCpuHeatStartTime:J

    .line 726
    invoke-direct {p0}, Lcom/android/server/MiuiBatteryIntelligence;->handleBoostNotification()V

    .line 727
    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mBoardSensorTempListener:Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;

    invoke-virtual {v2}, Lcom/android/server/MiuiBatteryIntelligence$BoardSensorTempListener;->stopWatching()V
    :try_end_40
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_40} :catch_41

    .line 731
    .end local v1    # "result":Ljava/lang/String;
    goto :goto_5c

    .line 728
    :catch_41
    move-exception v1

    .line 729
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string/jumbo v3, "stopCpuHeat exception "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 730
    invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V

    .line 732
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_5c
    return-void
.end method


# virtual methods
.method public cotinueCollectSencesChargeInfo()V
    .registers 5

    .line 698
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    if-eqz v0, :cond_d

    .line 699
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mHandler:Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;

    const/16 v1, 0x10

    const-wide/16 v2, 0x0

    invoke-virtual {v0, v1, v2, v3}, Lcom/android/server/MiuiBatteryIntelligence$BatteryInelligenceHandler;->sendMessageDelayed(IJ)V

    .line 701
    :cond_d
    return-void
.end method

.method public getChargeScencesInfo()Ljava/util/HashMap;
    .registers 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/HashMap<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 683
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 684
    .local v0, "scences":Ljava/util/HashMap;, "Ljava/util/HashMap<Ljava/lang/Integer;Ljava/lang/String;>;"
    const/4 v1, 0x0

    .line 685
    .local v1, "i":I
    iget-object v2, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSensorChargeScenceMap:Ljava/util/HashMap;

    invoke-virtual {v2}, Ljava/util/HashMap;->keySet()Ljava/util/Set;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_10
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_38

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    .line 686
    .local v3, "s":I
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    iget-object v5, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSensorChargeScenceMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    invoke-virtual {v5}, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;->getScenceInfo()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v0, v4, v5}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 687
    .end local v3    # "s":I
    goto :goto_10

    .line 688
    :cond_38
    return-object v0
.end method

.method public isNetWorkConnected()Z
    .registers 4

    .line 655
    const/4 v0, 0x0

    .line 657
    .local v0, "isAvailable":Z
    :try_start_1
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mConnectivityManager:Landroid/net/ConnectivityManager;

    if-nez v1, :cond_11

    .line 658
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mContext:Landroid/content/Context;

    const-string v2, "connectivity"

    invoke-virtual {v1, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/net/ConnectivityManager;

    iput-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mConnectivityManager:Landroid/net/ConnectivityManager;

    .line 660
    :cond_11
    iget-object v1, p0, Lcom/android/server/MiuiBatteryIntelligence;->mConnectivityManager:Landroid/net/ConnectivityManager;

    invoke-virtual {v1}, Landroid/net/ConnectivityManager;->getActiveNetworkInfo()Landroid/net/NetworkInfo;

    move-result-object v1

    .line 661
    .local v1, "networkInfo":Landroid/net/NetworkInfo;
    if-eqz v1, :cond_1e

    .line 662
    invoke-virtual {v1}, Landroid/net/NetworkInfo;->isAvailable()Z

    move-result v2
    :try_end_1d
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1d} :catch_1f

    move v0, v2

    .line 666
    .end local v1    # "networkInfo":Landroid/net/NetworkInfo;
    :cond_1e
    goto :goto_23

    .line 664
    :catch_1f
    move-exception v1

    .line 665
    .local v1, "e":Ljava/lang/Exception;
    invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V

    .line 667
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_23
    return v0
.end method

.method public isSupportFan()Z
    .registers 3

    .line 651
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mMiCharge:Lmiui/util/IMiCharge;

    const-string/jumbo v1, "fan_support"

    invoke-virtual {v0, v1}, Lmiui/util/IMiCharge;->getMiChargePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "1"

    invoke-virtual {v1, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method public isSupportGameSlowCharge()Z
    .registers 2

    .line 647
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit16 v0, v0, 0x400

    if-lez v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public isSupportLongTermChargingProtection()Z
    .registers 2

    .line 639
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit8 v0, v0, 0x10

    if-lez v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public isSupportLowBatteryFastCharge()Z
    .registers 2

    .line 619
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit8 v0, v0, 0x8

    if-lez v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public isSupportLowTempCharge()Z
    .registers 2

    .line 627
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit16 v0, v0, 0x100

    if-lez v0, :cond_c

    iget-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mLowTempChargeEnabledFromCloud:Z

    if-eqz v0, :cond_c

    const/4 v0, 0x1

    goto :goto_d

    :cond_c
    const/4 v0, 0x0

    :goto_d
    return v0
.end method

.method public isSupportNavigationCharge()Z
    .registers 2

    .line 611
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit8 v0, v0, 0x2

    if-lez v0, :cond_c

    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z

    if-nez v0, :cond_c

    const/4 v0, 0x1

    goto :goto_d

    :cond_c
    const/4 v0, 0x0

    :goto_d
    return v0
.end method

.method public isSupportOutDoorCharge()Z
    .registers 2

    .line 615
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit8 v0, v0, 0x4

    if-lez v0, :cond_c

    iget-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mIsOutDoorDisableFromCloud:Z

    if-eqz v0, :cond_c

    const/4 v0, 0x1

    goto :goto_d

    :cond_c
    const/4 v0, 0x0

    :goto_d
    return v0
.end method

.method public isSupportPerceptionCharge()Z
    .registers 2

    .line 623
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit8 v0, v0, 0x40

    if-lez v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public isSupportShipMode()Z
    .registers 2

    .line 635
    iget-boolean v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mShipModeEnabledFromCloud:Z

    if-eqz v0, :cond_a

    sget-boolean v0, Lcom/android/server/MiuiBatteryIntelligence;->mIsSupportShipMode:Z

    if-eqz v0, :cond_a

    const/4 v0, 0x1

    goto :goto_b

    :cond_a
    const/4 v0, 0x0

    :goto_b
    return v0
.end method

.method public isSupportTravelCharge()Z
    .registers 2

    .line 643
    iget v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mfunctions:I

    and-int/lit16 v0, v0, 0x200

    if-lez v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public parseInt(Ljava/lang/String;)I
    .registers 6
    .param p1, "argument"    # Ljava/lang/String;

    .line 672
    const/4 v0, -0x1

    :try_start_1
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_c

    .line 673
    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0
    :try_end_b
    .catch Ljava/lang/NumberFormatException; {:try_start_1 .. :try_end_b} :catch_d

    return v0

    .line 675
    :cond_c
    return v0

    .line 676
    :catch_d
    move-exception v1

    .line 677
    .local v1, "e":Ljava/lang/NumberFormatException;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Invalid integer argument "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    const-string v3, "MiuiBatteryIntelligence"

    invoke-static {v3, v2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 678
    return v0
.end method

.method public resetChargeSences()V
    .registers 3

    .line 692
    iget-object v0, p0, Lcom/android/server/MiuiBatteryIntelligence;->mSensorChargeScenceMap:Ljava/util/HashMap;

    invoke-virtual {v0}, Ljava/util/HashMap;->values()Ljava/util/Collection;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_a
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1a

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;

    .line 693
    .local v1, "scence":Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;
    invoke-virtual {v1}, Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;->resetInfo()V

    .line 694
    .end local v1    # "scence":Lcom/android/server/MiuiBatteryIntelligence$SensorChargeScence;
    goto :goto_a

    .line 695
    :cond_1a
    return-void
.end method
