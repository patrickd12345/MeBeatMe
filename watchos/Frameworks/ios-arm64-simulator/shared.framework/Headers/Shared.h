#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class SharedBestsDTOCompanion, SharedBestsDTO, SharedErrorResponseCompanion, SharedErrorResponse, SharedRunDTOCompanion, SharedRunDTO, SharedSyncRunsResponseCompanion, SharedSyncRunsResponse, SharedDistanceBucket, SharedBucketStats, SharedPerformanceBucketManager, SharedChallengeOption, SharedPaceUtils, SharedRunSession, SharedPurdyCalculator, SharedPurdyPointsCalculator, SharedBestsDTO_Companion, SharedBestsDTO_, SharedChallengeOptionCompanion, SharedKotlinEnumCompanion, SharedKotlinEnum<E>, SharedDistanceBucketCompanion, SharedKotlinArray<T>, SharedDistanceUnitCompanion, SharedDistanceUnit, SharedRunDTO_Companion, SharedRunDTO_, SharedKotlinx_datetimeInstant, SharedRunSampleCompanion, SharedRunSample, SharedRunSessionCompanion, SharedScoreCompanion, SharedScore, SharedUserPrefsCompanion, SharedUserPrefs, SharedRealTimeFeedback, SharedPaceZone, SharedKotlinThrowable, SharedKotlinException, SharedKotlinRuntimeException, SharedKotlinx_datetimeInstantCompanion, SharedKotlinx_serialization_coreSerializersModule, SharedKotlinx_serialization_coreSerialKind, SharedKotlinNothing, SharedKotlinIllegalStateException;

@protocol SharedKotlinx_serialization_coreKSerializer, SharedKotlinComparable, SharedKotlinx_coroutines_coreStateFlow, SharedKotlinx_serialization_coreEncoder, SharedKotlinx_serialization_coreSerialDescriptor, SharedKotlinx_serialization_coreSerializationStrategy, SharedKotlinx_serialization_coreDecoder, SharedKotlinx_serialization_coreDeserializationStrategy, SharedKotlinIterator, SharedKotlinx_coroutines_coreFlowCollector, SharedKotlinx_coroutines_coreFlow, SharedKotlinx_coroutines_coreSharedFlow, SharedKotlinx_serialization_coreCompositeEncoder, SharedKotlinAnnotation, SharedKotlinx_serialization_coreCompositeDecoder, SharedKotlinx_serialization_coreSerializersModuleCollector, SharedKotlinKClass, SharedKotlinKDeclarationContainer, SharedKotlinKAnnotatedElement, SharedKotlinKClassifier;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface SharedBase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface SharedBase (SharedBaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface SharedMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface SharedMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorSharedKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface SharedNumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface SharedByte : SharedNumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface SharedUByte : SharedNumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface SharedShort : SharedNumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface SharedUShort : SharedNumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface SharedInt : SharedNumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface SharedUInt : SharedNumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface SharedLong : SharedNumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface SharedULong : SharedNumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface SharedFloat : SharedNumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface SharedDouble : SharedNumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface SharedBoolean : SharedNumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BestsDTO")))
@interface SharedBestsDTO : SharedBase
- (instancetype)initWithBest5kSec:(SharedInt * _Nullable)best5kSec best10kSec:(SharedInt * _Nullable)best10kSec bestHalfSec:(SharedInt * _Nullable)bestHalfSec bestFullSec:(SharedInt * _Nullable)bestFullSec highestPPILast90Days:(SharedDouble * _Nullable)highestPPILast90Days __attribute__((swift_name("init(best5kSec:best10kSec:bestHalfSec:bestFullSec:highestPPILast90Days:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedBestsDTOCompanion *companion __attribute__((swift_name("companion")));
- (SharedBestsDTO *)doCopyBest5kSec:(SharedInt * _Nullable)best5kSec best10kSec:(SharedInt * _Nullable)best10kSec bestHalfSec:(SharedInt * _Nullable)bestHalfSec bestFullSec:(SharedInt * _Nullable)bestFullSec highestPPILast90Days:(SharedDouble * _Nullable)highestPPILast90Days __attribute__((swift_name("doCopy(best5kSec:best10kSec:bestHalfSec:bestFullSec:highestPPILast90Days:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedInt * _Nullable best10kSec __attribute__((swift_name("best10kSec")));
@property (readonly) SharedInt * _Nullable best5kSec __attribute__((swift_name("best5kSec")));
@property (readonly) SharedInt * _Nullable bestFullSec __attribute__((swift_name("bestFullSec")));
@property (readonly) SharedInt * _Nullable bestHalfSec __attribute__((swift_name("bestHalfSec")));
@property (readonly) SharedDouble * _Nullable highestPPILast90Days __attribute__((swift_name("highestPPILast90Days")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BestsDTO.Companion")))
@interface SharedBestsDTOCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedBestsDTOCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ErrorResponse")))
@interface SharedErrorResponse : SharedBase
- (instancetype)initWithError:(NSString *)error detail:(NSString *)detail __attribute__((swift_name("init(error:detail:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedErrorResponseCompanion *companion __attribute__((swift_name("companion")));
- (SharedErrorResponse *)doCopyError:(NSString *)error detail:(NSString *)detail __attribute__((swift_name("doCopy(error:detail:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *detail __attribute__((swift_name("detail")));
@property (readonly) NSString *error __attribute__((swift_name("error")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ErrorResponse.Companion")))
@interface SharedErrorResponseCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedErrorResponseCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunDTO")))
@interface SharedRunDTO : SharedBase
- (instancetype)initWithId:(NSString *)id source:(NSString *)source startedAtEpochMs:(int64_t)startedAtEpochMs endedAtEpochMs:(int64_t)endedAtEpochMs distanceMeters:(double)distanceMeters elapsedSeconds:(int32_t)elapsedSeconds avgPaceSecPerKm:(double)avgPaceSecPerKm avgHr:(SharedInt * _Nullable)avgHr ppi:(SharedDouble * _Nullable)ppi notes:(NSString * _Nullable)notes __attribute__((swift_name("init(id:source:startedAtEpochMs:endedAtEpochMs:distanceMeters:elapsedSeconds:avgPaceSecPerKm:avgHr:ppi:notes:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedRunDTOCompanion *companion __attribute__((swift_name("companion")));
- (SharedRunDTO *)doCopyId:(NSString *)id source:(NSString *)source startedAtEpochMs:(int64_t)startedAtEpochMs endedAtEpochMs:(int64_t)endedAtEpochMs distanceMeters:(double)distanceMeters elapsedSeconds:(int32_t)elapsedSeconds avgPaceSecPerKm:(double)avgPaceSecPerKm avgHr:(SharedInt * _Nullable)avgHr ppi:(SharedDouble * _Nullable)ppi notes:(NSString * _Nullable)notes __attribute__((swift_name("doCopy(id:source:startedAtEpochMs:endedAtEpochMs:distanceMeters:elapsedSeconds:avgPaceSecPerKm:avgHr:ppi:notes:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedInt * _Nullable avgHr __attribute__((swift_name("avgHr")));
@property (readonly) double avgPaceSecPerKm __attribute__((swift_name("avgPaceSecPerKm")));
@property (readonly) double distanceMeters __attribute__((swift_name("distanceMeters")));
@property (readonly) int32_t elapsedSeconds __attribute__((swift_name("elapsedSeconds")));
@property (readonly) int64_t endedAtEpochMs __attribute__((swift_name("endedAtEpochMs")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString * _Nullable notes __attribute__((swift_name("notes")));
@property (readonly) SharedDouble * _Nullable ppi __attribute__((swift_name("ppi")));
@property (readonly) NSString *source __attribute__((swift_name("source")));
@property (readonly) int64_t startedAtEpochMs __attribute__((swift_name("startedAtEpochMs")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunDTO.Companion")))
@interface SharedRunDTOCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedRunDTOCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SyncRunsResponse")))
@interface SharedSyncRunsResponse : SharedBase
- (instancetype)initWithStatus:(NSString *)status stored:(int32_t)stored __attribute__((swift_name("init(status:stored:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedSyncRunsResponseCompanion *companion __attribute__((swift_name("companion")));
- (SharedSyncRunsResponse *)doCopyStatus:(NSString *)status stored:(int32_t)stored __attribute__((swift_name("doCopy(status:stored:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *status __attribute__((swift_name("status")));
@property (readonly) int32_t stored __attribute__((swift_name("stored")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SyncRunsResponse.Companion")))
@interface SharedSyncRunsResponseCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSyncRunsResponseCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BucketStats")))
@interface SharedBucketStats : SharedBase
- (instancetype)initWithBucket:(SharedDistanceBucket *)bucket historicalBest:(double)historicalBest hasData:(BOOL)hasData __attribute__((swift_name("init(bucket:historicalBest:hasData:)"))) __attribute__((objc_designated_initializer));
- (SharedBucketStats *)doCopyBucket:(SharedDistanceBucket *)bucket historicalBest:(double)historicalBest hasData:(BOOL)hasData __attribute__((swift_name("doCopy(bucket:historicalBest:hasData:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedDistanceBucket *bucket __attribute__((swift_name("bucket")));
@property (readonly) BOOL hasData __attribute__((swift_name("hasData")));
@property (readonly) double historicalBest __attribute__((swift_name("historicalBest")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChallengeGenerator")))
@interface SharedChallengeGenerator : SharedBase
- (instancetype)initWithBucketManager:(SharedPerformanceBucketManager *)bucketManager __attribute__((swift_name("init(bucketManager:)"))) __attribute__((objc_designated_initializer));
- (NSArray<SharedChallengeOption *> *)generateChallenges __attribute__((swift_name("generateChallenges()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PaceUtils")))
@interface SharedPaceUtils : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)paceUtils __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedPaceUtils *shared __attribute__((swift_name("shared")));
- (NSString *)formatPaceSecondsPerKm:(double)secondsPerKm __attribute__((swift_name("formatPace(secondsPerKm:)")));
- (double)metersPerSecondToMinutesPerKmMetersPerSecond:(double)metersPerSecond __attribute__((swift_name("metersPerSecondToMinutesPerKm(metersPerSecond:)")));
- (double)metersPerSecondToSecondsPerKmMetersPerSecond:(double)metersPerSecond __attribute__((swift_name("metersPerSecondToSecondsPerKm(metersPerSecond:)")));
- (double)minutesPerKmToMetersPerSecondMinutesPerKm:(double)minutesPerKm __attribute__((swift_name("minutesPerKmToMetersPerSecond(minutesPerKm:)")));
- (double)minutesPerKmToSecondsPerKmMinutesPerKm:(double)minutesPerKm __attribute__((swift_name("minutesPerKmToSecondsPerKm(minutesPerKm:)")));
- (double)parsePacePaceString:(NSString *)paceString __attribute__((swift_name("parsePace(paceString:)")));
- (double)secondsPerKmToMetersPerSecondSecondsPerKm:(double)secondsPerKm __attribute__((swift_name("secondsPerKmToMetersPerSecond(secondsPerKm:)")));
- (double)secondsPerKmToMinutesPerKmSecondsPerKm:(double)secondsPerKm __attribute__((swift_name("secondsPerKmToMinutesPerKm(secondsPerKm:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PerformanceBucketManager")))
@interface SharedPerformanceBucketManager : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSDictionary<SharedDistanceBucket *, SharedDouble *> *)getAllHistoricalBests __attribute__((swift_name("getAllHistoricalBests()")));
- (SharedDistanceBucket *)getBucketForDistanceDistance:(double)distance __attribute__((swift_name("getBucketForDistance(distance:)")));
- (NSDictionary<SharedDistanceBucket *, SharedBucketStats *> *)getBucketStats __attribute__((swift_name("getBucketStats()")));
- (double)getHistoricalBestBucket:(SharedDistanceBucket *)bucket __attribute__((swift_name("getHistoricalBest(bucket:)")));
- (double)updateHistoricalBestSession:(SharedRunSession *)session __attribute__((swift_name("updateHistoricalBest(session:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PurdyCalculator")))
@interface SharedPurdyCalculator : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)purdyCalculator __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedPurdyCalculator *shared __attribute__((swift_name("shared")));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (double)purdyScoreDistanceMeters:(double)distanceMeters durationSec:(int32_t)durationSec error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("purdyScore(distanceMeters:durationSec:)"))) __attribute__((swift_error(nonnull_error)));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (double)targetPaceDistanceMeters:(double)distanceMeters windowSec:(int32_t)windowSec error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("targetPace(distanceMeters:windowSec:)"))) __attribute__((swift_error(nonnull_error)));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PurdyPointsCalculator")))
@interface SharedPurdyPointsCalculator : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)purdyPointsCalculator __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedPurdyPointsCalculator *shared __attribute__((swift_name("shared")));
- (double)calculatePPIDistance:(double)distance time:(int64_t)time __attribute__((swift_name("calculatePPI(distance:time:)")));
- (double)calculateRequiredPaceDistance:(double)distance targetPPI:(double)targetPPI __attribute__((swift_name("calculateRequiredPace(distance:targetPPI:)")));
- (int64_t)calculateRequiredTimeDistance:(double)distance targetPPI:(double)targetPPI __attribute__((swift_name("calculateRequiredTime(distance:targetPPI:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BestsDTO_")))
@interface SharedBestsDTO_ : SharedBase
- (instancetype)initWithBest5kSec:(SharedInt * _Nullable)best5kSec best10kSec:(SharedInt * _Nullable)best10kSec bestHalfSec:(SharedInt * _Nullable)bestHalfSec bestFullSec:(SharedInt * _Nullable)bestFullSec highestPPILast90Days:(SharedDouble * _Nullable)highestPPILast90Days __attribute__((swift_name("init(best5kSec:best10kSec:bestHalfSec:bestFullSec:highestPPILast90Days:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedBestsDTO_Companion *companion __attribute__((swift_name("companion")));
- (SharedBestsDTO_ *)doCopyBest5kSec:(SharedInt * _Nullable)best5kSec best10kSec:(SharedInt * _Nullable)best10kSec bestHalfSec:(SharedInt * _Nullable)bestHalfSec bestFullSec:(SharedInt * _Nullable)bestFullSec highestPPILast90Days:(SharedDouble * _Nullable)highestPPILast90Days __attribute__((swift_name("doCopy(best5kSec:best10kSec:bestHalfSec:bestFullSec:highestPPILast90Days:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedInt * _Nullable best10kSec __attribute__((swift_name("best10kSec")));
@property (readonly) SharedInt * _Nullable best5kSec __attribute__((swift_name("best5kSec")));
@property (readonly) SharedInt * _Nullable bestFullSec __attribute__((swift_name("bestFullSec")));
@property (readonly) SharedInt * _Nullable bestHalfSec __attribute__((swift_name("bestHalfSec")));
@property (readonly) SharedDouble * _Nullable highestPPILast90Days __attribute__((swift_name("highestPPILast90Days")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BestsDTO_.Companion")))
@interface SharedBestsDTO_Companion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedBestsDTO_Companion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChallengeOption")))
@interface SharedChallengeOption : SharedBase
- (instancetype)initWithId:(NSString *)id title:(NSString *)title description:(NSString *)description targetPace:(double)targetPace targetDuration:(int64_t)targetDuration targetDistance:(double)targetDistance expectedPpi:(double)expectedPpi bucket:(SharedDistanceBucket *)bucket __attribute__((swift_name("init(id:title:description:targetPace:targetDuration:targetDistance:expectedPpi:bucket:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedChallengeOptionCompanion *companion __attribute__((swift_name("companion")));
- (SharedChallengeOption *)doCopyId:(NSString *)id title:(NSString *)title description:(NSString *)description targetPace:(double)targetPace targetDuration:(int64_t)targetDuration targetDistance:(double)targetDistance expectedPpi:(double)expectedPpi bucket:(SharedDistanceBucket *)bucket __attribute__((swift_name("doCopy(id:title:description:targetPace:targetDuration:targetDistance:expectedPpi:bucket:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedDistanceBucket *bucket __attribute__((swift_name("bucket")));
@property (readonly) NSString *description_ __attribute__((swift_name("description_")));
@property (readonly) double expectedPpi __attribute__((swift_name("expectedPpi")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) double targetDistance __attribute__((swift_name("targetDistance")));
@property (readonly) int64_t targetDuration __attribute__((swift_name("targetDuration")));
@property (readonly) double targetPace __attribute__((swift_name("targetPace")));
@property (readonly) NSString *title __attribute__((swift_name("title")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChallengeOption.Companion")))
@interface SharedChallengeOptionCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedChallengeOptionCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("KotlinComparable")))
@protocol SharedKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface SharedKotlinEnum<E> : SharedBase <SharedKotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DistanceBucket")))
@interface SharedDistanceBucket : SharedKotlinEnum<SharedDistanceBucket *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) SharedDistanceBucketCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedDistanceBucket *shortSprint __attribute__((swift_name("shortSprint")));
@property (class, readonly) SharedDistanceBucket *sprint __attribute__((swift_name("sprint")));
@property (class, readonly) SharedDistanceBucket *shortRun __attribute__((swift_name("shortRun")));
@property (class, readonly) SharedDistanceBucket *mediumRun __attribute__((swift_name("mediumRun")));
@property (class, readonly) SharedDistanceBucket *longRun __attribute__((swift_name("longRun")));
@property (class, readonly) SharedDistanceBucket *ultraRun __attribute__((swift_name("ultraRun")));
+ (SharedKotlinArray<SharedDistanceBucket *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<SharedDistanceBucket *> *entries __attribute__((swift_name("entries")));
- (BOOL)containsDistanceKm:(double)distanceKm __attribute__((swift_name("contains(distanceKm:)")));
@property (readonly) NSString *label __attribute__((swift_name("label")));
@property (readonly) double maxKm __attribute__((swift_name("maxKm")));
@property (readonly) double minKm __attribute__((swift_name("minKm")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DistanceBucket.Companion")))
@interface SharedDistanceBucketCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedDistanceBucketCompanion *shared __attribute__((swift_name("shared")));
- (SharedDistanceBucket * _Nullable)fromLabelLabel:(NSString *)label __attribute__((swift_name("fromLabel(label:)")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(SharedKotlinArray<id<SharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DistanceUnit")))
@interface SharedDistanceUnit : SharedKotlinEnum<SharedDistanceUnit *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) SharedDistanceUnitCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedDistanceUnit *metric __attribute__((swift_name("metric")));
@property (class, readonly) SharedDistanceUnit *imperial __attribute__((swift_name("imperial")));
+ (SharedKotlinArray<SharedDistanceUnit *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<SharedDistanceUnit *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DistanceUnit.Companion")))
@interface SharedDistanceUnitCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedDistanceUnitCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(SharedKotlinArray<id<SharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunDTO_")))
@interface SharedRunDTO_ : SharedBase
- (instancetype)initWithId:(NSString *)id source:(NSString *)source startedAtEpochMs:(int64_t)startedAtEpochMs endedAtEpochMs:(int64_t)endedAtEpochMs distanceMeters:(double)distanceMeters elapsedSeconds:(int32_t)elapsedSeconds avgPaceSecPerKm:(double)avgPaceSecPerKm avgHr:(SharedInt * _Nullable)avgHr ppi:(SharedDouble * _Nullable)ppi notes:(NSString * _Nullable)notes __attribute__((swift_name("init(id:source:startedAtEpochMs:endedAtEpochMs:distanceMeters:elapsedSeconds:avgPaceSecPerKm:avgHr:ppi:notes:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedRunDTO_Companion *companion __attribute__((swift_name("companion")));
- (SharedRunDTO_ *)doCopyId:(NSString *)id source:(NSString *)source startedAtEpochMs:(int64_t)startedAtEpochMs endedAtEpochMs:(int64_t)endedAtEpochMs distanceMeters:(double)distanceMeters elapsedSeconds:(int32_t)elapsedSeconds avgPaceSecPerKm:(double)avgPaceSecPerKm avgHr:(SharedInt * _Nullable)avgHr ppi:(SharedDouble * _Nullable)ppi notes:(NSString * _Nullable)notes __attribute__((swift_name("doCopy(id:source:startedAtEpochMs:endedAtEpochMs:distanceMeters:elapsedSeconds:avgPaceSecPerKm:avgHr:ppi:notes:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedInt * _Nullable avgHr __attribute__((swift_name("avgHr")));
@property (readonly) double avgPaceSecPerKm __attribute__((swift_name("avgPaceSecPerKm")));
@property (readonly) double distanceMeters __attribute__((swift_name("distanceMeters")));
@property (readonly) int32_t elapsedSeconds __attribute__((swift_name("elapsedSeconds")));
@property (readonly) int64_t endedAtEpochMs __attribute__((swift_name("endedAtEpochMs")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString * _Nullable notes __attribute__((swift_name("notes")));
@property (readonly) SharedDouble * _Nullable ppi __attribute__((swift_name("ppi")));
@property (readonly) NSString *source __attribute__((swift_name("source")));
@property (readonly) int64_t startedAtEpochMs __attribute__((swift_name("startedAtEpochMs")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunDTO_.Companion")))
@interface SharedRunDTO_Companion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedRunDTO_Companion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunSample")))
@interface SharedRunSample : SharedBase
- (instancetype)initWithTimestamp:(SharedKotlinx_datetimeInstant *)timestamp distance:(double)distance pace:(double)pace __attribute__((swift_name("init(timestamp:distance:pace:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedRunSampleCompanion *companion __attribute__((swift_name("companion")));
- (SharedRunSample *)doCopyTimestamp:(SharedKotlinx_datetimeInstant *)timestamp distance:(double)distance pace:(double)pace __attribute__((swift_name("doCopy(timestamp:distance:pace:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) double distance __attribute__((swift_name("distance")));
@property (readonly) double pace __attribute__((swift_name("pace")));
@property (readonly) SharedKotlinx_datetimeInstant *timestamp __attribute__((swift_name("timestamp")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunSample.Companion")))
@interface SharedRunSampleCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedRunSampleCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunSession")))
@interface SharedRunSession : SharedBase
- (instancetype)initWithId:(NSString *)id distance:(double)distance duration:(int64_t)duration timestamp:(SharedKotlinx_datetimeInstant *)timestamp pace:(double)pace samples:(NSArray<SharedRunSample *> *)samples __attribute__((swift_name("init(id:distance:duration:timestamp:pace:samples:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedRunSessionCompanion *companion __attribute__((swift_name("companion")));
- (SharedRunSession *)doCopyId:(NSString *)id distance:(double)distance duration:(int64_t)duration timestamp:(SharedKotlinx_datetimeInstant *)timestamp pace:(double)pace samples:(NSArray<SharedRunSample *> *)samples __attribute__((swift_name("doCopy(id:distance:duration:timestamp:pace:samples:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) double distance __attribute__((swift_name("distance")));
@property (readonly) int64_t duration __attribute__((swift_name("duration")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) double pace __attribute__((swift_name("pace")));
@property (readonly) NSArray<SharedRunSample *> *samples __attribute__((swift_name("samples")));
@property (readonly) SharedKotlinx_datetimeInstant *timestamp __attribute__((swift_name("timestamp")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RunSession.Companion")))
@interface SharedRunSessionCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedRunSessionCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Score")))
@interface SharedScore : SharedBase
- (instancetype)initWithPpi:(double)ppi bucket:(SharedDistanceBucket *)bucket targetPace:(SharedDouble * _Nullable)targetPace targetDuration:(SharedLong * _Nullable)targetDuration achieved:(BOOL)achieved __attribute__((swift_name("init(ppi:bucket:targetPace:targetDuration:achieved:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedScoreCompanion *companion __attribute__((swift_name("companion")));
- (SharedScore *)doCopyPpi:(double)ppi bucket:(SharedDistanceBucket *)bucket targetPace:(SharedDouble * _Nullable)targetPace targetDuration:(SharedLong * _Nullable)targetDuration achieved:(BOOL)achieved __attribute__((swift_name("doCopy(ppi:bucket:targetPace:targetDuration:achieved:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) BOOL achieved __attribute__((swift_name("achieved")));
@property (readonly) SharedDistanceBucket *bucket __attribute__((swift_name("bucket")));
@property (readonly) double ppi __attribute__((swift_name("ppi")));
@property (readonly) SharedLong * _Nullable targetDuration __attribute__((swift_name("targetDuration")));
@property (readonly) SharedDouble * _Nullable targetPace __attribute__((swift_name("targetPace")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Score.Companion")))
@interface SharedScoreCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedScoreCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UserPrefs")))
@interface SharedUserPrefs : SharedBase
- (instancetype)initWithUnits:(SharedDistanceUnit *)units hapticsEnabled:(BOOL)hapticsEnabled privacyMode:(BOOL)privacyMode __attribute__((swift_name("init(units:hapticsEnabled:privacyMode:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedUserPrefsCompanion *companion __attribute__((swift_name("companion")));
- (SharedUserPrefs *)doCopyUnits:(SharedDistanceUnit *)units hapticsEnabled:(BOOL)hapticsEnabled privacyMode:(BOOL)privacyMode __attribute__((swift_name("doCopy(units:hapticsEnabled:privacyMode:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) BOOL hapticsEnabled __attribute__((swift_name("hapticsEnabled")));
@property (readonly) BOOL privacyMode __attribute__((swift_name("privacyMode")));
@property (readonly) SharedDistanceUnit *units __attribute__((swift_name("units")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UserPrefs.Companion")))
@interface SharedUserPrefsCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedUserPrefsCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("JsonRunStore")))
@interface SharedJsonRunStore : SharedBase
- (instancetype)initWithDataFile:(id)dataFile __attribute__((swift_name("init(dataFile:)"))) __attribute__((objc_designated_initializer));
- (void)clear __attribute__((swift_name("clear()")));
- (BOOL)deleteByIdId:(NSString *)id __attribute__((swift_name("deleteById(id:)")));
- (NSArray<SharedRunDTO_ *> *)getAll __attribute__((swift_name("getAll()")));
- (SharedRunDTO_ * _Nullable)getByIdId:(NSString *)id __attribute__((swift_name("getById(id:)")));
- (SharedDouble * _Nullable)getHighestPpiLast90DaysNowMs:(int64_t)nowMs days:(int32_t)days __attribute__((swift_name("getHighestPpiLast90Days(nowMs:days:)")));
- (NSArray<SharedRunDTO_ *> *)listSinceSinceMs:(int64_t)sinceMs __attribute__((swift_name("listSince(sinceMs:)")));
- (int32_t)size __attribute__((swift_name("size()")));
- (int32_t)upsertAllNewRuns:(NSArray<SharedRunDTO_ *> *)newRuns __attribute__((swift_name("upsertAll(newRuns:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MeBeatMeService")))
@interface SharedMeBeatMeService : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedScore * _Nullable)completeSession __attribute__((swift_name("completeSession()")));
- (void)generateChallenges __attribute__((swift_name("generateChallenges()")));
- (SharedRealTimeFeedback * _Nullable)getRealTimeFeedback __attribute__((swift_name("getRealTimeFeedback()")));
- (void)selectChallengeChallenge:(SharedChallengeOption *)challenge __attribute__((swift_name("selectChallenge(challenge:)")));
- (void)updateSessionDistance:(double)distance duration:(int64_t)duration currentPace:(double)currentPace __attribute__((swift_name("updateSession(distance:duration:currentPace:)")));
@property (readonly) id<SharedKotlinx_coroutines_coreStateFlow> currentChallenges __attribute__((swift_name("currentChallenges")));
@property (readonly) id<SharedKotlinx_coroutines_coreStateFlow> currentSession __attribute__((swift_name("currentSession")));
@property (readonly) id<SharedKotlinx_coroutines_coreStateFlow> selectedChallenge __attribute__((swift_name("selectedChallenge")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PaceZone")))
@interface SharedPaceZone : SharedKotlinEnum<SharedPaceZone *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) SharedPaceZone *tooFast __attribute__((swift_name("tooFast")));
@property (class, readonly) SharedPaceZone *onTarget __attribute__((swift_name("onTarget")));
@property (class, readonly) SharedPaceZone *tooSlow __attribute__((swift_name("tooSlow")));
+ (SharedKotlinArray<SharedPaceZone *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<SharedPaceZone *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RealTimeFeedback")))
@interface SharedRealTimeFeedback : SharedBase
- (instancetype)initWithCurrentPace:(double)currentPace targetPace:(double)targetPace paceDifference:(double)paceDifference paceZone:(SharedPaceZone *)paceZone progressPercentage:(double)progressPercentage __attribute__((swift_name("init(currentPace:targetPace:paceDifference:paceZone:progressPercentage:)"))) __attribute__((objc_designated_initializer));
- (SharedRealTimeFeedback *)doCopyCurrentPace:(double)currentPace targetPace:(double)targetPace paceDifference:(double)paceDifference paceZone:(SharedPaceZone *)paceZone progressPercentage:(double)progressPercentage __attribute__((swift_name("doCopy(currentPace:targetPace:paceDifference:paceZone:progressPercentage:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) double currentPace __attribute__((swift_name("currentPace")));
@property (readonly) double paceDifference __attribute__((swift_name("paceDifference")));
@property (readonly) SharedPaceZone *paceZone __attribute__((swift_name("paceZone")));
@property (readonly) double progressPercentage __attribute__((swift_name("progressPercentage")));
@property (readonly) double targetPace __attribute__((swift_name("targetPace")));
@end

@interface SharedRunDTO_ (Extensions)
- (SharedRunDTO_ *)calculatePpi __attribute__((swift_name("calculatePpi()")));
@end

@interface SharedRunSession (Extensions)
- (SharedRunDTO_ *)toRunDTO __attribute__((swift_name("toRunDTO()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedFunctionsKt")))
@interface SharedSharedFunctionsKt : SharedBase
+ (SharedBestsDTO_ *)calculateBestsRuns:(NSArray<SharedRunDTO_ *> *)runs sinceMs:(int64_t)sinceMs __attribute__((swift_name("calculateBests(runs:sinceMs:)")));
+ (SharedDouble * _Nullable)highestPpiInWindowRuns:(NSArray<SharedRunDTO_ *> *)runs nowMs:(int64_t)nowMs days:(int32_t)days __attribute__((swift_name("highestPpiInWindow(runs:nowMs:days:)")));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
+ (double)purdyScoreDistanceMeters:(double)distanceMeters durationSec:(int32_t)durationSec error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("purdyScore(distanceMeters:durationSec:)"))) __attribute__((swift_error(nonnull_error)));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
+ (double)targetPaceDistanceMeters:(double)distanceMeters windowSec:(int32_t)windowSec error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("targetPace(distanceMeters:windowSec:)"))) __attribute__((swift_error(nonnull_error)));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerializationStrategy")))
@protocol SharedKotlinx_serialization_coreSerializationStrategy
@required
- (void)serializeEncoder:(id<SharedKotlinx_serialization_coreEncoder>)encoder value:(id _Nullable)value __attribute__((swift_name("serialize(encoder:value:)")));
@property (readonly) id<SharedKotlinx_serialization_coreSerialDescriptor> descriptor __attribute__((swift_name("descriptor")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreDeserializationStrategy")))
@protocol SharedKotlinx_serialization_coreDeserializationStrategy
@required
- (id _Nullable)deserializeDecoder:(id<SharedKotlinx_serialization_coreDecoder>)decoder __attribute__((swift_name("deserialize(decoder:)")));
@property (readonly) id<SharedKotlinx_serialization_coreSerialDescriptor> descriptor __attribute__((swift_name("descriptor")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreKSerializer")))
@protocol SharedKotlinx_serialization_coreKSerializer <SharedKotlinx_serialization_coreSerializationStrategy, SharedKotlinx_serialization_coreDeserializationStrategy>
@required
@end

__attribute__((swift_name("KotlinThrowable")))
@interface SharedKotlinThrowable : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));

/**
 * @note annotations
 *   kotlin.experimental.ExperimentalNativeApi
*/
- (SharedKotlinArray<NSString *> *)getStackTrace __attribute__((swift_name("getStackTrace()")));
- (void)printStackTrace __attribute__((swift_name("printStackTrace()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (NSError *)asError __attribute__((swift_name("asError()")));
@end

__attribute__((swift_name("KotlinException")))
@interface SharedKotlinException : SharedKotlinThrowable
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinRuntimeException")))
@interface SharedKotlinRuntimeException : SharedKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinIllegalArgumentException")))
@interface SharedKotlinIllegalArgumentException : SharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface SharedKotlinEnumCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface SharedKotlinArray<T> : SharedBase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(SharedInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<SharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=kotlinx/datetime/serializers/InstantIso8601Serializer))
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_datetimeInstant")))
@interface SharedKotlinx_datetimeInstant : SharedBase <SharedKotlinComparable>
@property (class, readonly, getter=companion) SharedKotlinx_datetimeInstantCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(SharedKotlinx_datetimeInstant *)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (SharedKotlinx_datetimeInstant *)minusDuration:(int64_t)duration __attribute__((swift_name("minus(duration:)")));
- (int64_t)minusOther:(SharedKotlinx_datetimeInstant *)other __attribute__((swift_name("minus(other:)")));
- (SharedKotlinx_datetimeInstant *)plusDuration:(int64_t)duration __attribute__((swift_name("plus(duration:)")));
- (int64_t)toEpochMilliseconds __attribute__((swift_name("toEpochMilliseconds()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int64_t epochSeconds __attribute__((swift_name("epochSeconds")));
@property (readonly) int32_t nanosecondsOfSecond __attribute__((swift_name("nanosecondsOfSecond")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlow")))
@protocol SharedKotlinx_coroutines_coreFlow
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<SharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSharedFlow")))
@protocol SharedKotlinx_coroutines_coreSharedFlow <SharedKotlinx_coroutines_coreFlow>
@required
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreStateFlow")))
@protocol SharedKotlinx_coroutines_coreStateFlow <SharedKotlinx_coroutines_coreSharedFlow>
@required
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreEncoder")))
@protocol SharedKotlinx_serialization_coreEncoder
@required
- (id<SharedKotlinx_serialization_coreCompositeEncoder>)beginCollectionDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor collectionSize:(int32_t)collectionSize __attribute__((swift_name("beginCollection(descriptor:collectionSize:)")));
- (id<SharedKotlinx_serialization_coreCompositeEncoder>)beginStructureDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("beginStructure(descriptor:)")));
- (void)encodeBooleanValue:(BOOL)value __attribute__((swift_name("encodeBoolean(value:)")));
- (void)encodeByteValue:(int8_t)value __attribute__((swift_name("encodeByte(value:)")));
- (void)encodeCharValue:(unichar)value __attribute__((swift_name("encodeChar(value:)")));
- (void)encodeDoubleValue:(double)value __attribute__((swift_name("encodeDouble(value:)")));
- (void)encodeEnumEnumDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)enumDescriptor index:(int32_t)index __attribute__((swift_name("encodeEnum(enumDescriptor:index:)")));
- (void)encodeFloatValue:(float)value __attribute__((swift_name("encodeFloat(value:)")));
- (id<SharedKotlinx_serialization_coreEncoder>)encodeInlineDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("encodeInline(descriptor:)")));
- (void)encodeIntValue:(int32_t)value __attribute__((swift_name("encodeInt(value:)")));
- (void)encodeLongValue:(int64_t)value __attribute__((swift_name("encodeLong(value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNotNullMark __attribute__((swift_name("encodeNotNullMark()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNull __attribute__((swift_name("encodeNull()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNullableSerializableValueSerializer:(id<SharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeNullableSerializableValue(serializer:value:)")));
- (void)encodeSerializableValueSerializer:(id<SharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeSerializableValue(serializer:value:)")));
- (void)encodeShortValue:(int16_t)value __attribute__((swift_name("encodeShort(value:)")));
- (void)encodeStringValue:(NSString *)value __attribute__((swift_name("encodeString(value:)")));
@property (readonly) SharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerialDescriptor")))
@protocol SharedKotlinx_serialization_coreSerialDescriptor
@required

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (NSArray<id<SharedKotlinAnnotation>> *)getElementAnnotationsIndex:(int32_t)index __attribute__((swift_name("getElementAnnotations(index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<SharedKotlinx_serialization_coreSerialDescriptor>)getElementDescriptorIndex:(int32_t)index __attribute__((swift_name("getElementDescriptor(index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (int32_t)getElementIndexName:(NSString *)name __attribute__((swift_name("getElementIndex(name:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (NSString *)getElementNameIndex:(int32_t)index __attribute__((swift_name("getElementName(index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)isElementOptionalIndex:(int32_t)index __attribute__((swift_name("isElementOptional(index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
@property (readonly) NSArray<id<SharedKotlinAnnotation>> *annotations __attribute__((swift_name("annotations")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
@property (readonly) int32_t elementsCount __attribute__((swift_name("elementsCount")));
@property (readonly) BOOL isInline __attribute__((swift_name("isInline")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
@property (readonly) BOOL isNullable __attribute__((swift_name("isNullable")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
@property (readonly) SharedKotlinx_serialization_coreSerialKind *kind __attribute__((swift_name("kind")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
@property (readonly) NSString *serialName __attribute__((swift_name("serialName")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreDecoder")))
@protocol SharedKotlinx_serialization_coreDecoder
@required
- (id<SharedKotlinx_serialization_coreCompositeDecoder>)beginStructureDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("beginStructure(descriptor:)")));
- (BOOL)decodeBoolean __attribute__((swift_name("decodeBoolean()")));
- (int8_t)decodeByte __attribute__((swift_name("decodeByte()")));
- (unichar)decodeChar __attribute__((swift_name("decodeChar()")));
- (double)decodeDouble __attribute__((swift_name("decodeDouble()")));
- (int32_t)decodeEnumEnumDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)enumDescriptor __attribute__((swift_name("decodeEnum(enumDescriptor:)")));
- (float)decodeFloat __attribute__((swift_name("decodeFloat()")));
- (id<SharedKotlinx_serialization_coreDecoder>)decodeInlineDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeInline(descriptor:)")));
- (int32_t)decodeInt __attribute__((swift_name("decodeInt()")));
- (int64_t)decodeLong __attribute__((swift_name("decodeLong()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)decodeNotNullMark __attribute__((swift_name("decodeNotNullMark()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (SharedKotlinNothing * _Nullable)decodeNull __attribute__((swift_name("decodeNull()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id _Nullable)decodeNullableSerializableValueDeserializer:(id<SharedKotlinx_serialization_coreDeserializationStrategy>)deserializer __attribute__((swift_name("decodeNullableSerializableValue(deserializer:)")));
- (id _Nullable)decodeSerializableValueDeserializer:(id<SharedKotlinx_serialization_coreDeserializationStrategy>)deserializer __attribute__((swift_name("decodeSerializableValue(deserializer:)")));
- (int16_t)decodeShort __attribute__((swift_name("decodeShort()")));
- (NSString *)decodeString __attribute__((swift_name("decodeString()")));
@property (readonly) SharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol SharedKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_datetimeInstant.Companion")))
@interface SharedKotlinx_datetimeInstantCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedKotlinx_datetimeInstantCompanion *shared __attribute__((swift_name("shared")));
- (SharedKotlinx_datetimeInstant *)fromEpochMillisecondsEpochMilliseconds:(int64_t)epochMilliseconds __attribute__((swift_name("fromEpochMilliseconds(epochMilliseconds:)")));
- (SharedKotlinx_datetimeInstant *)fromEpochSecondsEpochSeconds:(int64_t)epochSeconds nanosecondAdjustment:(int32_t)nanosecondAdjustment __attribute__((swift_name("fromEpochSeconds(epochSeconds:nanosecondAdjustment:)")));
- (SharedKotlinx_datetimeInstant *)fromEpochSecondsEpochSeconds:(int64_t)epochSeconds nanosecondAdjustment_:(int64_t)nanosecondAdjustment __attribute__((swift_name("fromEpochSeconds(epochSeconds:nanosecondAdjustment_:)")));
- (SharedKotlinx_datetimeInstant *)now __attribute__((swift_name("now()"))) __attribute__((unavailable("Use Clock.System.now() instead")));
- (SharedKotlinx_datetimeInstant *)parseIsoString:(NSString *)isoString __attribute__((swift_name("parse(isoString:)")));
- (id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@property (readonly) SharedKotlinx_datetimeInstant *DISTANT_FUTURE __attribute__((swift_name("DISTANT_FUTURE")));
@property (readonly) SharedKotlinx_datetimeInstant *DISTANT_PAST __attribute__((swift_name("DISTANT_PAST")));
@end

__attribute__((swift_name("KotlinIllegalStateException")))
@interface SharedKotlinIllegalStateException : SharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.4")
*/
__attribute__((swift_name("KotlinCancellationException")))
@interface SharedKotlinCancellationException : SharedKotlinIllegalStateException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlowCollector")))
@protocol SharedKotlinx_coroutines_coreFlowCollector
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(id _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreCompositeEncoder")))
@protocol SharedKotlinx_serialization_coreCompositeEncoder
@required
- (void)encodeBooleanElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(BOOL)value __attribute__((swift_name("encodeBooleanElement(descriptor:index:value:)")));
- (void)encodeByteElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int8_t)value __attribute__((swift_name("encodeByteElement(descriptor:index:value:)")));
- (void)encodeCharElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(unichar)value __attribute__((swift_name("encodeCharElement(descriptor:index:value:)")));
- (void)encodeDoubleElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(double)value __attribute__((swift_name("encodeDoubleElement(descriptor:index:value:)")));
- (void)encodeFloatElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(float)value __attribute__((swift_name("encodeFloatElement(descriptor:index:value:)")));
- (id<SharedKotlinx_serialization_coreEncoder>)encodeInlineElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("encodeInlineElement(descriptor:index:)")));
- (void)encodeIntElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int32_t)value __attribute__((swift_name("encodeIntElement(descriptor:index:value:)")));
- (void)encodeLongElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int64_t)value __attribute__((swift_name("encodeLongElement(descriptor:index:value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNullableSerializableElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index serializer:(id<SharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeNullableSerializableElement(descriptor:index:serializer:value:)")));
- (void)encodeSerializableElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index serializer:(id<SharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeSerializableElement(descriptor:index:serializer:value:)")));
- (void)encodeShortElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int16_t)value __attribute__((swift_name("encodeShortElement(descriptor:index:value:)")));
- (void)encodeStringElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(NSString *)value __attribute__((swift_name("encodeStringElement(descriptor:index:value:)")));
- (void)endStructureDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("endStructure(descriptor:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)shouldEncodeElementDefaultDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("shouldEncodeElementDefault(descriptor:index:)")));
@property (readonly) SharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerializersModule")))
@interface SharedKotlinx_serialization_coreSerializersModule : SharedBase

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)dumpToCollector:(id<SharedKotlinx_serialization_coreSerializersModuleCollector>)collector __attribute__((swift_name("dumpTo(collector:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<SharedKotlinx_serialization_coreKSerializer> _Nullable)getContextualKClass:(id<SharedKotlinKClass>)kClass typeArgumentsSerializers:(NSArray<id<SharedKotlinx_serialization_coreKSerializer>> *)typeArgumentsSerializers __attribute__((swift_name("getContextual(kClass:typeArgumentsSerializers:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<SharedKotlinx_serialization_coreSerializationStrategy> _Nullable)getPolymorphicBaseClass:(id<SharedKotlinKClass>)baseClass value:(id)value __attribute__((swift_name("getPolymorphic(baseClass:value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<SharedKotlinx_serialization_coreDeserializationStrategy> _Nullable)getPolymorphicBaseClass:(id<SharedKotlinKClass>)baseClass serializedClassName:(NSString * _Nullable)serializedClassName __attribute__((swift_name("getPolymorphic(baseClass:serializedClassName:)")));
@end

__attribute__((swift_name("KotlinAnnotation")))
@protocol SharedKotlinAnnotation
@required
@end


/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
__attribute__((swift_name("Kotlinx_serialization_coreSerialKind")))
@interface SharedKotlinx_serialization_coreSerialKind : SharedBase
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreCompositeDecoder")))
@protocol SharedKotlinx_serialization_coreCompositeDecoder
@required
- (BOOL)decodeBooleanElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeBooleanElement(descriptor:index:)")));
- (int8_t)decodeByteElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeByteElement(descriptor:index:)")));
- (unichar)decodeCharElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeCharElement(descriptor:index:)")));
- (int32_t)decodeCollectionSizeDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeCollectionSize(descriptor:)")));
- (double)decodeDoubleElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeDoubleElement(descriptor:index:)")));
- (int32_t)decodeElementIndexDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeElementIndex(descriptor:)")));
- (float)decodeFloatElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeFloatElement(descriptor:index:)")));
- (id<SharedKotlinx_serialization_coreDecoder>)decodeInlineElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeInlineElement(descriptor:index:)")));
- (int32_t)decodeIntElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeIntElement(descriptor:index:)")));
- (int64_t)decodeLongElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeLongElement(descriptor:index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id _Nullable)decodeNullableSerializableElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index deserializer:(id<SharedKotlinx_serialization_coreDeserializationStrategy>)deserializer previousValue:(id _Nullable)previousValue __attribute__((swift_name("decodeNullableSerializableElement(descriptor:index:deserializer:previousValue:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)decodeSequentially __attribute__((swift_name("decodeSequentially()")));
- (id _Nullable)decodeSerializableElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index deserializer:(id<SharedKotlinx_serialization_coreDeserializationStrategy>)deserializer previousValue:(id _Nullable)previousValue __attribute__((swift_name("decodeSerializableElement(descriptor:index:deserializer:previousValue:)")));
- (int16_t)decodeShortElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeShortElement(descriptor:index:)")));
- (NSString *)decodeStringElementDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeStringElement(descriptor:index:)")));
- (void)endStructureDescriptor:(id<SharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("endStructure(descriptor:)")));
@property (readonly) SharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinNothing")))
@interface SharedKotlinNothing : SharedBase
@end


/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
__attribute__((swift_name("Kotlinx_serialization_coreSerializersModuleCollector")))
@protocol SharedKotlinx_serialization_coreSerializersModuleCollector
@required
- (void)contextualKClass:(id<SharedKotlinKClass>)kClass provider:(id<SharedKotlinx_serialization_coreKSerializer> (^)(NSArray<id<SharedKotlinx_serialization_coreKSerializer>> *))provider __attribute__((swift_name("contextual(kClass:provider:)")));
- (void)contextualKClass:(id<SharedKotlinKClass>)kClass serializer:(id<SharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("contextual(kClass:serializer:)")));
- (void)polymorphicBaseClass:(id<SharedKotlinKClass>)baseClass actualClass:(id<SharedKotlinKClass>)actualClass actualSerializer:(id<SharedKotlinx_serialization_coreKSerializer>)actualSerializer __attribute__((swift_name("polymorphic(baseClass:actualClass:actualSerializer:)")));
- (void)polymorphicDefaultBaseClass:(id<SharedKotlinKClass>)baseClass defaultDeserializerProvider:(id<SharedKotlinx_serialization_coreDeserializationStrategy> _Nullable (^)(NSString * _Nullable))defaultDeserializerProvider __attribute__((swift_name("polymorphicDefault(baseClass:defaultDeserializerProvider:)"))) __attribute__((deprecated("Deprecated in favor of function with more precise name: polymorphicDefaultDeserializer")));
- (void)polymorphicDefaultDeserializerBaseClass:(id<SharedKotlinKClass>)baseClass defaultDeserializerProvider:(id<SharedKotlinx_serialization_coreDeserializationStrategy> _Nullable (^)(NSString * _Nullable))defaultDeserializerProvider __attribute__((swift_name("polymorphicDefaultDeserializer(baseClass:defaultDeserializerProvider:)")));
- (void)polymorphicDefaultSerializerBaseClass:(id<SharedKotlinKClass>)baseClass defaultSerializerProvider:(id<SharedKotlinx_serialization_coreSerializationStrategy> _Nullable (^)(id))defaultSerializerProvider __attribute__((swift_name("polymorphicDefaultSerializer(baseClass:defaultSerializerProvider:)")));
@end

__attribute__((swift_name("KotlinKDeclarationContainer")))
@protocol SharedKotlinKDeclarationContainer
@required
@end

__attribute__((swift_name("KotlinKAnnotatedElement")))
@protocol SharedKotlinKAnnotatedElement
@required
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
__attribute__((swift_name("KotlinKClassifier")))
@protocol SharedKotlinKClassifier
@required
@end

__attribute__((swift_name("KotlinKClass")))
@protocol SharedKotlinKClass <SharedKotlinKDeclarationContainer, SharedKotlinKAnnotatedElement, SharedKotlinKClassifier>
@required

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
- (BOOL)isInstanceValue:(id _Nullable)value __attribute__((swift_name("isInstance(value:)")));
@property (readonly) NSString * _Nullable qualifiedName __attribute__((swift_name("qualifiedName")));
@property (readonly) NSString * _Nullable simpleName __attribute__((swift_name("simpleName")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
