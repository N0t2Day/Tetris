//
//  TetrisView.m
//  Tetris
//
//  Created by master on 30.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "TetrisView.h"

@implementation TetrisView
{
    NSTimer *timer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        srand((unsigned int)time(NULL));
        [self clearWorkingArea];
        
        self->allFigures[0] = &chFrstFig;
        self->allFigures[1] = &chScndFig;
        self->allFigures[2] = &chThrdFig;
        self->allFigures[3] = &chFrthFig;
        self->allFigures[4] = &chFvthFig;
        self->allFigures[5] = &chSxthFig;
        self->allFigures[6] = &chSvthFig;
        
        
        self->curFigInterval = 0.7;
        [self nextFigure];
        // Запуск таймера
        self->timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveMethod:) userInfo:nil repeats:true];
    }
    return self;
}

- (void) addFigureToWorkingArea : (BOOL) isAdd {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if((*self->figure)[self->curFigPos][i][j] == 1) {
                if (isAdd) {
                    self->wrkArea[self->curFigRow + i][self->curFigCol +j] = self->curFigColor;
                } else {
                    self->wrkArea[self->curFigRow +i][self->curFigCol +j] = COLOR_BACKGROUND;
                }
            }
        }
    }
}

/**
 *Перемещает фигуру в низ по таймеру
 */
- (void) moveMethod:(NSTimer *)timer {
    NSLog(@"%p", self);
    double delay = self->curFigInterval - (self->deletedLevels/100.f);
    self->tickCounter += 0.1;
    if (self->tickCounter < delay) {
        return;
    }
    self->tickCounter = 0;
    
//    1. Проверить, что фигуре есть куда перемещаеться
//                - если ДА то переместить
//                - если нет то следующая фигура
    
    if ([self canMoveToNextCoords:0 :1])
    {
        [self moveByCoord:0 :1];
    }
    else
    {
        [self addFigureToWorkingArea:true];
        //-----Генирируем следующую фигуру
        if ([self nextFigure])
        {
            
        }
        else
        {
            // Начало новой игры
            self->deletedLevels = 0;
            [self clearWorkingArea];
            [self nextFigure];
        }
    }
    
    // Перерисовка рабочего поля -----
    [self setNeedsDisplay];
}

- (BOOL) canMoveToNextCoords : (int)deltaX :(int) deltaY {
    BOOL isOk = true;
    int x1 = self->curFigCol + deltaX;
    int y1 = self->curFigRow + deltaY;
    
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++) {
            if ((*self->figure)[self->curFigPos][i][j] == 1 && self->wrkArea[y1+i][x1+j]!=COLOR_BACKGROUND) {
                isOk = false;
                i = 4;
                break;
            }
        }
    }
    
    
    return isOk;
}
- (void) moveByCoord:(int)deltaX :(int) deltaY {
    
    // ---- меняем координаты текущей фигуры
    
    self->curFigCol += deltaX;
    self->curFigRow += deltaY;
    
    
    
    
    
}











- (void)drawRect:(CGRect)rect {
    
//     NSLog(@"move row: %i col: %i", self->curFigRow, self->curFigCol);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    
    // ---- Заливаем цветом фона всю область вида -----
    
    CGContextSetRGBFillColor(context,
                             colors[COLOR_BACKGROUND].red,
                             colors[COLOR_BACKGROUND].green,
                             colors[COLOR_BACKGROUND].blue, 1);
    
    CGContextFillRect(context, self.frame);
    // Вычисление размеров одной клеточки ----
    double cellW = self.frame.size.width / wrkAreaWidth;
    double cellH = self.frame.size.height / wrkAreaHeight;
    
    if (cellW < cellH) {
        cellH = cellW;
        
    }
    else {
        cellW = cellH;
    }
    int x = (self.frame.size.width - cellW *wrkAreaWidth)/2; // координаты начала стакана на экране (наружный левый верхний край) на экране
    int y = (self.frame.size.height - cellW * wrkAreaHeight)/2;
    
   
    // Рисуем рабочую область
    
    for (int i = 0; i < wrkAreaHeight; i++)
    {
        for (int j = 0; j < wrkAreaWidth; j++)
        {
            
            int clr = self->wrkArea[i][j];
            
            CGContextSetRGBFillColor(context, colors[clr].red,
                                     colors[clr].green, colors[clr].blue, 1);
            
            CGContextFillRect(context,
                              CGRectMake(x + j*cellW, y + i*cellH, cellW +1, cellH+1));
            
            if (clr != COLOR_BACKGROUND && clr != COLOR_WALLBORDER) {
                CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
                CGContextStrokeRect(context, CGRectMake(x + j*cellW, y + i*cellH,
                                                        cellW +1, cellH+1));
            }
            
        }
    }


    // ###
    CGContextSetRGBFillColor(context, colors[self->curFigColor].red,
                             colors[self->curFigColor].green, colors[self->curFigColor].blue, 1);
    
    
    // ------ Рисуем текущую фигурку
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);

    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
        //    printf("%i", *figure[self->curFigPos][i][j]);
            if (((*figure)[self->curFigPos][i][j] != 0))
            {
                CGContextFillRect(context,
                                  CGRectMake((self->curFigCol + j)*cellW + x,
                                             (self->curFigRow + i)*cellH + y, cellW, cellH));

                CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
                CGContextStrokeRect(context, CGRectMake(x + (self->curFigCol + j)*cellW, y + (self->curFigRow + i)*cellH,
                                                            cellW +1, cellH+1));
                
            }
        }
    //    printf("\n");
    }
    
 //   printf("\n");

    
    
//    self->curFigPos++;
//    if (self->curFigPos > 3) self->curFigPos = 0;
}


- (void) clearWorkingArea {
    
    for (int i = 0; i < wrkAreaHeight; i++) {
        
        for (int j = 0; j < wrkAreaWidth; j++) {
            
            if (j == 0 || j == wrkAreaWidth - 1 || i == wrkAreaHeight - 1)
            {
                self->wrkArea[i][j] = COLOR_BACKGROUND;
            }
            else if (j == 1 || j == wrkAreaWidth - 2 || i == wrkAreaHeight - 2)
            {
                self->wrkArea[i][j] = COLOR_WALLBORDER;
            }
            else
            {
                self->wrkArea[i][j] = COLOR_BACKGROUND;
            }
            
        }
        
    }
    
}

- (BOOL) nextFigure {
    // ----Удаление заполненных уровней
    [self deleteFullLevels];
    
    
    self->curFigRow = 0;
    self->curFigCol = 5;
    self->curFigPos = 0;
    
    int index = rand() % 7;
    self->curFigColor = index + 2;
    self->figure = self->allFigures[index];
    // ---- Проверка, что для новой фигуры есть место
    BOOL isOK = true;
    
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {            if ((*self->figure)[self->curFigPos][i][j] == 1 &&
                self->wrkArea[self->curFigRow+i][self->curFigCol+j] != COLOR_BACKGROUND) {
                isOK = false;
                i = 4;
                break;
            }
        }
    }
    
    
    
    
    
    
    return isOK;
    
    
}




- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint loc = [touch locationInView:self];
    
    if (loc.y > (self.frame.origin.y + self.frame.size.height) *0.77) {
        // --- нажатие в область низ
        while ([self canMoveToNextCoords:0 :1]) {
            [self moveByCoord:0 :1];
        }
        [self addFigureToWorkingArea:true];
        if ([self nextFigure]) {
            
        }
        else {
            self->deletedLevels = 0;
            [self clearWorkingArea];
            [self nextFigure];
        }
        
    }
    else if (loc.x < (self.frame.origin.x + self.frame.size.width) *0.28)
    {
        // --- нажатие в область влево
        if ([self canMoveToNextCoords:-1 :0]) {
            [self moveByCoord:-1 :0];
        }
        else
        {
            // --- Звуковой сигнал
        }
    }
    else if (loc.x > (self.frame.origin.x + self.frame.size.width) *0.72)
    {
        // --- нажатие в область вправо
        if ([self canMoveToNextCoords:1 :0]) {
            [self moveByCoord:1 :0];
        }
        else
        {
            // --- Звуковой сигнал
        }
    }
    else
    {
        // --- нажатие в область центр
        
        
        [self nextPosition];
        
        
    }
    [self setNeedsDisplay];
    
}

- (BOOL) canRotateToNextPossition {
    
    
    BOOL isOk = true;
    int nextPos = self->curFigPos + 1;
    nextPos = (nextPos>=4)?0:nextPos;
    
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            if ((*self->figure)[nextPos][i][j] == 1 &&
                self->wrkArea[self->curFigRow+i][self->curFigCol+j] != COLOR_BACKGROUND) {
                isOk = false;
                i = 4;
                break;
            }
        }
    }
    return isOk;
}

- (void) nextPosition {
    if ([self canRotateToNextPossition]) {
        self->curFigPos++;
        if (self->curFigPos >= 4) {
            self->curFigPos = 0;
        }
    }
}



- (void) deleteFullLevels {
    
    for (int i = wrkAreaHeight - 3; i >=0; i--) {
        BOOL isDelete = true;
        for (int j = 1; j < wrkAreaWidth - 2; j++) {
            if (self->wrkArea[i][j] == COLOR_BACKGROUND) {
                isDelete = false;
                break;
            }
        }
        if (isDelete == true) {
            // ---- Сдвигаем строки на позицию вниз
            for (int k = i; k >= 1; k--) {
                for (int j = 0; j < wrkAreaWidth; j++) {
                    self->wrkArea[k][j] = self->wrkArea[k-1][j];
                }
            }
            for (int j = 2; j < wrkAreaWidth - 4; j++) {
                self->wrkArea[0][j] = COLOR_BACKGROUND;
            }
            i++;
            self->deletedLevels++;

        }


    }

}




@end
