//
//  HYDataConst.h
//  CoolMesh
//
//  Created by lijie on 2019/9/12.
//  Copyright © 2019 lijie. All rights reserved.
//

#ifndef HYDataConst_h
#define HYDataConst_h

static uint16_t const KBroadCast_AllNode = 0xFFFF;
static uint16_t const KBroadCast_Time = 0xFEFF;

typedef NS_ENUM(NSUInteger, HYPutType) {
    /**  长长、宽宽、高高 */
    HYPutType_Normal,
    /**  长宽、宽长、高高 */
    HYPutType_NormalAngle90,
    
    
    
    /**  长长、宽高、高宽 */
    HYPutType_BottomLength,
    /**  长高、宽长、高宽 */
    HYPutType_BottomLengthAngle90,
    
    
    
    /**  长高、宽宽、高长 */
    HYPutType_BottomWidth,
    /**  长宽、宽高、高长 */
    HYPutType_BottomWidthAngle90,
    
    
    
    /**  可以随便摆放 */
    HYPutType_AllType,
};








#endif /* HYDataConst_h */
