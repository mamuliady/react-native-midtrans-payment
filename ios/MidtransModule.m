#import "MidtransModule.h"
#import <React/RCTLog.h>

@interface MidtransModule ()
@property (nonatomic, copy) RCTResponseSenderBlock callback;
@end

@implementation MidtransModule

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(checkOut:(NSDictionary*) optionConect
                  :(NSDictionary*) transRequest
                  : (NSArray*) items
                  : (NSDictionary*) creditCardOptions
                  : (NSDictionary*) mapUserDetail
                  : (NSDictionary*) optionColorTheme
                  : (NSDictionary*) optionFont
                  :(RCTResponseSenderBlock)callback){
    
    [CONFIG setClientKey:[optionConect valueForKey:@"clientKey"]
             environment:[[optionConect valueForKey:@"sandbox"] boolValue] ? MidtransServerEnvironmentSandbox : MidtransServerEnvironmentProduction
       merchantServerURL:[optionConect valueForKey:@"urlMerchant"]];

    CC_CONFIG.secure3DEnabled = YES;

    NSMutableArray *itemitems = [[NSMutableArray alloc] init];
    for (NSDictionary *ele in items) {
        MidtransItemDetail *tmp =
        [[MidtransItemDetail alloc] initWithItemID:[ele valueForKey:@"id"]
                                              name:[ele valueForKey:@"name"]
                                             price:[ele valueForKey:@"price"]
                                          quantity:[ele valueForKey:@"qty"]];
        [itemitems addObject:tmp];
    }

    MidtransAddress *shippingAddress = [MidtransAddress addressWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                                                    lastName:@""
                                                                       phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                                                     address:[mapUserDetail valueForKey:@"address"]
                                                                        city:[mapUserDetail valueForKey:@"city"]
                                                                  postalCode:[mapUserDetail valueForKey:@"zipcode"]
                                                                 countryCode:[mapUserDetail valueForKey:@"country"]];
    MidtransAddress *billingAddress = [MidtransAddress addressWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                                                    lastName:@""
                                                                       phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                                                     address:[mapUserDetail valueForKey:@"address"]
                                                                        city:[mapUserDetail valueForKey:@"city"]
                                                                  postalCode:[mapUserDetail valueForKey:@"zipcode"]
                                                                 countryCode:[mapUserDetail valueForKey:@"country"]];

    MidtransCustomerDetails *customerDetail =
    [[MidtransCustomerDetails alloc] initWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                              lastName:@"lastname"
                                                 email:[mapUserDetail valueForKey:@"email"]
                                                 phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                       shippingAddress:shippingAddress
                                        billingAddress:billingAddress];

    NSNumber *totalAmount = [NSNumber numberWithInt:[[transRequest valueForKey:@"totalAmount"] intValue]];
    MidtransTransactionDetails *transactionDetail =
    [[MidtransTransactionDetails alloc] initWithOrderID:[transRequest valueForKey:@"transactionId"]
                                         andGrossAmount:totalAmount];

    self.callback = callback;
    
    [[MidtransMerchantClient shared]
     requestTransactionTokenWithTransactionDetails:transactionDetail
     itemDetails:itemitems
     customerDetails:customerDetail
     completion:^(MidtransTransactionTokenResponse * _Nullable token, NSError * _Nullable error) {
         if (token) {
             UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

             MidtransUIPaymentViewController *vc = [[MidtransUIPaymentViewController alloc] initWithToken:token andPaymentFeature:[self getPaymentType:transRequest]];

             [ctrl presentViewController:vc animated:NO completion:nil];
             //set the delegate
             vc.paymentDelegate = self;
         }
         else {
             NSLog(@"%@", error);
             callback(@[@"failed"]);
         }
     }];
};

#pragma mark - MidtransUIPaymentViewControllerDelegate

- (void)finishPayment:(MidtransTransactionResult *)result error:(NSError *)error finishedStatus:(NSString *)status
{
    if (self.callback == nil) {
        RCTLogInfo(@"callback is null");
        return;
    }
    
    RCTLogInfo(@"finishPayment: %@", result);
    
    if (error) {
        self.callback(@[@"failed"]);
//        self.callback(@[error]);
        self.callback = nil;
    } else if (result) {
        if (![result.paymentType isEqual: @"gopay"] || [result.transactionStatus isEqual: @"settlement"]) // add this to temporary fix gopay return status pending instead of cancelled
        {
            self.callback(@[status]);
//            self.callback(@[result.transactionStatus, [NSNull null]]);
            self.callback = nil;
        }
    } else {
        self.callback(@[@"cancelled"]);
//        self.callback(@[@"cancelled", [NSNull null]]);
        self.callback = nil;
    }
}

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentSuccess:(MidtransTransactionResult *)result{
    RCTLogInfo(@"%@", result);
    [self finishPayment:result error:nil finishedStatus:@"success"];
}

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentFailed:(NSError *)error {
    RCTLogInfo(@"%@", error);
    [self finishPayment:nil error:error finishedStatus:@"failed"];
}

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentPending:(MidtransTransactionResult *)result {
    RCTLogInfo(@"%@", result);
    [self finishPayment:result error:nil finishedStatus:@"pending"];
}

- (void)paymentViewController_paymentCanceled:(MidtransUIPaymentViewController *)viewController {
    RCTLogInfo(@"Cancel Transaction");
    [self finishPayment:nil error:nil finishedStatus:@"cancelled"];
}

- (enum MidtransPaymentFeature) getPaymentType:(NSDictionary*) paymentType{
    NSNumber* objectNumber = [paymentType valueForKey:@"paymentType"];
    int type = [objectNumber intValue];
    if(type == 0){
        return MidtransPaymentFeatureCreditCard;
    }
    else if(type == 3) {
            return MidtransPaymentFeatureBankTransferMandiriVA;
    }
    else if(type == 4) {
        return MidtransPaymentFeatureBankTransferPermataVA;
    }
    else if(type == 5) {
         return MidtransPaymentFeatureBankTransferBNIVA;
    }
    else if(type == 6) {
         return MidtransPaymentFeatureBankTransferOtherVA;
    }
    else if(type == 7) {
             return MidtransPaymentFeatureGOPAY;
    }
    else{
        return MidtransPaymentFeatureGOPAY;
    }
}
@end