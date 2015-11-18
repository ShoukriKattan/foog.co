//
//  JBGridView.m
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/10/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

#import "JBGridView.h"

// Numerics
CGFloat const kJBLineChartGridViewSeparatorWidth = 0.5f;
CGFloat const kJBLineChartGridViewSeparatorHeight = 3.0f;
CGFloat const kJBLineChartGridViewSeparatorSectionPadding = 1.0f;
CGFloat const kJBLineChartGridViewLabelHeight = 18.0;

// Colors
static UIColor *kJBLineChartFooterViewDefaultSeparatorColor = nil;

@interface JBGridView ()

@property (nonatomic, strong) UIView *topSeparatorView;

@end

@implementation JBGridView

#pragma mark - Alloc/Init

+ (void)initialize
{
    if (self == [JBGridView class])
    {
        kJBLineChartFooterViewDefaultSeparatorColor = [UIColor whiteColor];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _footerSeparatorColor = kJBLineChartFooterViewDefaultSeparatorColor;
        _gridLineColor = kJBLineChartFooterViewDefaultSeparatorColor;
        _sectionGridLineColor = kJBLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        [self addSubview:_topSeparatorView];
        
        //Init Data
        self.data = [[NSMutableArray alloc] initWithCapacity:0];
        
        //Init Section Data
        self.sectionData = [[NSMutableDictionary alloc] initWithCapacity:0];
        
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetStrokeColorWithColor(context,self.gridLineColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetShouldAntialias(context, YES);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    CGFloat stepLength = ceil((self.bounds.size.width - ((kJBLineChartGridViewSeparatorWidth * 0.5)*(self.data.count-1))) / (self.data.count-1));
    for (int i=0; i<self.data.count; i++)
    {
        NSString* sectionValue = @"";
        if (self.sectionData.count > 0) {
            sectionValue = [self.sectionData objectForKey:[NSString stringWithFormat:@"%d",i]];
            if (sectionValue) {
              CGContextSetStrokeColorWithColor(context,self.sectionGridLineColor.CGColor);
            }else{
                sectionValue = @"";
            }
        }
        CGContextSaveGState(context);
        {
            float lineHeight = yOffset + self.bounds.size.height - kJBLineChartGridViewLabelHeight;
            float midXPoint = xOffset + (kJBLineChartGridViewSeparatorWidth * 0.5);
            if (midXPoint >= self.frame.size.width) {
                midXPoint = self.frame.size.width - (kJBLineChartGridViewSeparatorWidth * 0.5)*2;
            }

            CGContextMoveToPoint(context, midXPoint, yOffset);
            CGContextAddLineToPoint(context, midXPoint, lineHeight);
            CGContextStrokePath(context);
            xOffset += stepLength;
            
            if(sectionValue && sectionValue.length> 0 ){
                UIFont* font = [UIFont fontWithName:@"Arial" size:12.0];
                UIColor* textColor = self.sectionGridLineColor;
                NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
                
                NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:sectionValue attributes:stringAttrs];
                float startXLabelPostion = midXPoint - attrStr.size.width;
                if((startXLabelPostion + attrStr.size.width)>=self.frame.size.width){
                    startXLabelPostion = self.frame.size.width - attrStr.size.width;
                }else if(startXLabelPostion<0){
                    startXLabelPostion = 0;
                }
                [attrStr drawAtPoint:CGPointMake(startXLabelPostion+1, lineHeight)];
            }
        }
        
        CGContextRestoreGState(context);
             CGContextSetStrokeColorWithColor(context,self.gridLineColor.CGColor);
       
    }
}

-(void)reloadData {
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _topSeparatorView.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 20 , self.bounds.size.width, kJBLineChartGridViewSeparatorWidth);

}

#pragma mark - Setters



- (void)setFooterSeparatorColor:(UIColor *)footerSeparatorColor
{
    _footerSeparatorColor = footerSeparatorColor;
    _topSeparatorView.backgroundColor = _footerSeparatorColor;
    [self setNeedsDisplay];
}

- (void)setGridLineColor:(UIColor *)gridLineColor
{
    _gridLineColor = gridLineColor;
    [self setNeedsDisplay];
}

-(void)setSectionGridLineColor:(UIColor *)sectionGridLineColor
{
    _sectionGridLineColor = sectionGridLineColor;
    [self setNeedsDisplay];
}

@end





