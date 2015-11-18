//
//  JBGridView.h
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/10/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRIDVIEW_SECTIONDATA   @"Section"
#define GRIDVIEW_Data          @"Data"

@interface JBGridView : UIView

@property (nonatomic, strong) UIColor *footerSeparatorColor; // footer separator (default = white)
@property (nonatomic, strong) UIColor *gridLineColor;
@property (nonatomic, strong) UIColor *sectionGridLineColor;
@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSMutableDictionary* sectionData;

-(void)reloadData;

@end
