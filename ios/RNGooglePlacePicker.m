#import "RNGooglePlacePicker.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <React/RCTConvert.h>

@interface RNGooglePlacePicker() <GMSPlacePickerViewControllerDelegate>

@end

@implementation RNGooglePlacePicker {
    GMSPlacePickerViewController *_placePicker;
    RCTResponseSenderBlock _callback;
}

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    if (place.formattedAddress) {
        [response setObject:place.formattedAddress forKey:@"address"];
    } else {
        [response setObject:[NSNull null] forKey:@"address"];
    }
    if (place.name) {
        [response setObject:place.name forKey:@"name"];
    } else {
        [response setObject:[NSNull null] forKey:@"name"];
    }
    if (place.placeID) {
        [response setObject:place.placeID forKey:@"google_id"];
    } else {
        [response setObject:[NSNull null] forKey:@"google_id"];
    }
    [response setObject:@(place.coordinate.latitude) forKey:@"latitude"];
    [response setObject:@(place.coordinate.longitude) forKey:@"longitude"];
    _callback(@[response]);
    [_placePicker dismissViewControllerAnimated:true completion:nil];
}
    
- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
    _callback(@[@{@"didCancel" : @YES}]);
    [_placePicker dismissViewControllerAnimated:true completion:nil];
}

- (void)placePicker:(GMSPlacePickerViewController *)viewController didFailWithError:(NSError *)error {
    _callback(@[@{@"error" : error.localizedFailureReason}]);
    [_placePicker dismissViewControllerAnimated:true completion:nil];
}

    
RCT_EXPORT_METHOD(show:
(RCTResponseSenderBlock) callback) {
    _callback = callback;
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
    _placePicker = [[GMSPlacePickerViewController alloc] initWithConfig:config];
    _placePicker.delegate = self;
    UIViewController *root = RCTPresentedViewController();
    [root presentViewController:_placePicker animated:true completion:nil];
}


@end
