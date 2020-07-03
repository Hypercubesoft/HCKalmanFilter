//
//  GMSPlacePickerViewController.h
//  Google Places SDK for iOS
//
//  Copyright 2017 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif
#import "GMSPlacePickerConfig.h"

@class GMSPlacePickerViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol used by |GMSPlacePickerViewController|, to communicate the user's interaction with the
 * Place Picker to the application.
 */
@protocol GMSPlacePickerViewControllerDelegate <NSObject>

@required

/**
 * Called when a place has been selected.
 *
 * Implementations of this method should dismiss the view controller as the view controller will not
 * dismiss itself.
 *
 * @param viewController The |GMSPlacePickerViewController| that generated the event.
 * @param place The |GMSPlace| that was selected.
 */
- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place;

@optional

/**
 * Called when an error has occurred within the Place Picker.
 *
 * The Place Picker displays a UI informing the user of the error, and provides the user with a way
 * to retry the operation if appropriate. In most cases your app need not perform any action in
 * response to the calling of this method. The purpose of this method is to provide information
 * about errors.
 *
 * @param viewController The |GMSPlacePickerViewController| that generated the event.
 * @param error The error that occurred.
 */
- (void)placePicker:(GMSPlacePickerViewController *)viewController
    didFailWithError:(NSError *)error;

/**
 * Called when the place picking operation has been cancelled.
 *
 * @param viewController The |GMSPlacePickerViewControler| that generated the event.
 */
- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController;

@end

/**
 * GMSPlacePickerViewController provides an interface that displays the Place Picker. Place
 * selections made by the user are returned to the app via the
 * |GMSPlacePickerViewControllerDelegate| protocol.
 *
 * To use GMSPlacePickerViewController, set its delegate to an object in your app that
 * conforms to the |GMSPlacePickerViewControllerDelegate| protocol and present the controller
 * (for example using presentViewController). The |GMSPlacePickerViewControllerDelegate| delegate
 * methods can be used to determine when the user has selected a place, cancelled selection, or when
 * an error has occurred.
 */
@interface GMSPlacePickerViewController : UIViewController

/** Delegate to be notified when a place is selected or picking is cancelled. */
@property(nonatomic, weak, nullable) IBOutlet id<GMSPlacePickerViewControllerDelegate> delegate;

/**
 * Initializes the place picker with a given configuration. This does not start the process of
 * picking a place.
 */
- (instancetype)initWithConfig:(GMSPlacePickerConfig *)config;

@end

NS_ASSUME_NONNULL_END
