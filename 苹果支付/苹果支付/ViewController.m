//
//  ViewController.m
//  苹果支付
//
//  Created by 王顺子 on 16/2/23.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *payView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];



    // 1. 判断当前设备是否支持苹果支付
    if (![PKPaymentAuthorizationViewController canMakePayments])
    {
        NSLog(@"当前设备不支持Applepay");
        self.payView.hidden = YES;

        // 判断是否添加了银行卡(PKPaymentNetworkChinaUnionPay 银联卡, 在iOS9.才支持)
    }else if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay]])
    {
        // 创建一个跳转按钮, 当用户点击按钮时, 跳转到添加银行卡的界面
        PKPaymentButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
        [button addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];

    }else
    {
        // 创建一个购买按钮, 当用户点击按钮时, 购买一个商品
        PKPaymentButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        [button addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];
    }



}


#pragma mark - 私有方法
// 跳转到添加银行卡界面
- (void)jump
{
    PKPassLibrary *pl = [[PKPassLibrary alloc] init];
    [pl openPaymentSetup];
}

// 购买
-(void)buy
{
    NSLog(@"购买商品, 开始支付");


    // 1. 创建一个支付请求
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];

    // 1.1 配置支付请求
    // 1.1.1 配置商家ID
    request.merchantIdentifier = @"merchant.xiaomageApplePay.com";

    // 1.1.2 配置货币代码, 以及国家代码
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";

    // 1.1.3 配置请求支持的支付网络
    request.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay];

    // 1.1.4 配置商户的处理方式
    request.merchantCapabilities = PKMerchantCapability3DS;

    // 1.1.5 配置购买的商品列表
    NSDecimalNumber *price1 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"苹果6s" amount:price1];

    NSDecimalNumber *price11 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKPaymentSummaryItem *item11 = [PKPaymentSummaryItem summaryItemWithLabel:@"苹果6s" amount:price11];

    NSDecimalNumber *price111 = [NSDecimalNumber decimalNumberWithString:@"20.0"];
    PKPaymentSummaryItem *item111 = [PKPaymentSummaryItem summaryItemWithLabel:@"小码哥财务" amount:price111];

    // 注意: 支付列表最后一个, 代表汇总
    request.paymentSummaryItems = @[item1, item11, item111];



    // 1.2 配置请求的附加项
    // 1.2.1 是否显示发票收货地址, 显示哪些选项
    request.requiredBillingAddressFields = PKAddressFieldAll;
    // 1.2.2 是否显示快递地址, 显示哪些选项
    request.requiredShippingAddressFields = PKAddressFieldAll;
    // 1.2.3 配置快递方式NSArray<PKShippingMethod *>
    NSDecimalNumber *price2 = [NSDecimalNumber decimalNumberWithString:@"18.0"];
    PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:price2];
    method.detail = @"24小时内送到";
    method.identifier = @"shunfeng";

    NSDecimalNumber *price3 = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    PKShippingMethod *method2 = [PKShippingMethod summaryItemWithLabel:@"韵达快递" amount:price3];
    method2.identifier = @"yunda";
    method2.detail = @"送货上门";
    request.shippingMethods = @[method, method2];
    // 1.2.3.2 配置快递的类型
    request.shippingType = PKShippingTypeStorePickup;


    // 1.3 添加一些附加数据
    request.applicationData = [@"buyID=12345" dataUsingEncoding:NSUTF8StringEncoding];




    // 2. 验证用户的支付授权
    PKPaymentAuthorizationViewController *avc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    avc.delegate = self;
    [self presentViewController:avc animated:YES completion:nil];
}


#pragma mark - PKPaymentAuthorizationViewControllerDelegate
// 如果当用户授权成功, 就会调用这个方法
// 参数一: 授权控制器
// 参数二 : 支付对象
// 参数三: 系统给定的一个回调代码块, 我们需要执行这个代码块, 来告诉系统当前的支付状态是否成功.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    // 一般在此处,拿到支付信息, 发送给服务器处理, 处理完毕之后, 服务器会返回一个状态, 告诉客户端,是否支付成功, 然后由客户端进行处理
    BOOL isSucess = YES;




    if (isSucess) {
        completion(PKPaymentAuthorizationStatusSuccess);
    }else
    {
        completion(PKPaymentAuthorizationStatusFailure);

    }


}

// 当用户授权成功, 或者取消授权时调用

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"授权结束");
    [self dismissViewControllerAnimated:controller completion:nil];
}


@end
