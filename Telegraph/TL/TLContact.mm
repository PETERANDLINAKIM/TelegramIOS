#import "TLContact.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLContact

@synthesize user_id = _user_id;
@synthesize mutual = _mutual;

- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLContact$contact : TLContact


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf911c994;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa9d2a4b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLContact$contact *object = [[TLContact$contact alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.mutual = metaObject->getBool(0xea637e57);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.mutual;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xea637e57, value));
    }
}


@end

