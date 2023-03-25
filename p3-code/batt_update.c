#include "batt.h"

int set_batt_from_ports(batt_t *batt){
// Uses the two global variables (ports) BATT_VOLTAGE_PORT and
// BATT_STATUS_PORT to set the fields of the parameter 'batt'.  If
// BATT_VOLTAGE_PORT is negative, then battery has been wired wrong;
// no fields of 'batt' are changed and 1 is returned to indicate an
// error.  Otherwise, sets fields of batt based on reading the voltage
// value and converting to precent using the provided formula. Returns
// 0 on a successful execution with no errors. This function DOES NOT
// modify any global variables but may access global variables.
//
// CONSTRAINT: Avoids the use of the division operation as much as
// possible. Makes use of shift operations in place of division where
// possible.
//
// CONSTRAINT: Uses only integer operations. No floating point
// operations are used as the target machine does not have a FPU.
// 
// CONSTRAINT: Limit the complexity of code as much as possible. Do
// not use deeply nested conditional structures. Seek to make the code
// as short, and simple as possible. Code longer than 40 lines may be
// penalized for complexity.
    if (BATT_VOLTAGE_PORT < 0){ // checks if volts is negative
        return 1;
    }
    batt->mlvolts = BATT_VOLTAGE_PORT >> 1; // converts volts to milivolts
    int battP = (batt->mlvolts - 3000) >> 3; // converts milivolts to percentage
    if (battP > 100){ // checks if percentage exceeds 100 percent
        battP = 100;
    }
    if (battP < 0){ // checks if percentage is below 0 percent
        battP = 0;
    }
    batt->percent = battP;
    if (BATT_STATUS_PORT & (1 << 4)){ // checks the 4th bit of port for status
        batt->mode = 1; //percentage
    }
    else {
        batt->mode = 2; // volts
    }
    return 0;
}
int set_display_from_batt(batt_t batt, int *display){
// Alters the bits of integer pointed to by 'display' to reflect the
// data in struct param 'batt'.  Does not assume any specific bit
// pattern stored at 'display' and completely resets all bits in it on
// successfully completing.  Selects either to show Volts (mode=1) or
// Percent (mode=2). If Volts are displayed, only displays 3 digits
// rounding the lowest digit up or down appropriate to the last digit.
// Calculates each digit to display changes bits at 'display' to show
// the volts/percent according to the pattern for each digit. Modifies
// additional bits to show a decimal place for volts and a 'V' or '%'
// indicator appropriate to the mode. In both modes, places bars in
// the level display as indicated by percentage cutoffs in provided
// diagrams. This function DOES NOT modify any global variables but
// may access global variables. Always returns 0.
// 
// CONSTRAINT: Limit the complexity of code as much as possible. Do
// not use deeply nested conditional structures. Seek to make the code
// as short, and simple as possible. Code longer than 65 lines may be
// penalized for complexity.
    *display = *display ^ *display; // clears all bits in *display
    int masks[] = {0b0111111, 0b0000110, 0b1011011, 0b1001111, 0b1100110, // bit patterns for each digit 0-9 respectively
                   0b1101101, 0b1111101, 0b0000111, 0b1111111, 0b1101111};
    int left;
    int middle;
    int right;
    int battV = batt.mlvolts + 5; // used to help with rounding up or down
    if (batt.mode == 1){ 
       *display = *display | (1 << 0); // sets 0th bit for percentage
    }
    else {
        *display = *display | (1 << 1); // sets 1st bit for volts
        *display = *display | (1 << 2); // sets 2nd bit for decimal
    }
    // sets the percentage digits in display
    if (batt.percent == 100 && batt.mode == 1){ // displays 100 if at 100 percent
        *display = *display | (masks[1] << 17) | (masks[0] << 10) | (masks[0] << 3);
    }
    else if (batt.percent == 0 && batt.mode == 1){ // displays only 0 if 0 percent
        *display = *display | (masks[0] << 3);
    }
    else if (10 <= batt.percent && batt.percent < 100 && batt.mode == 1){ // displays percentages with 2 digits
        middle = (batt.percent / 10) % 10;
        right = batt.percent % 10;
        *display = *display | (masks[middle] << 10) | (masks[right] << 3);
    }
    else if (0 < batt.percent && batt.mode == 1){ // displays percentages with 1 digit
        right = batt.percent % 10;
        *display = *display | (masks[right] << 3);
    }
    else { 
        // sets the volts digits in display
        left = (battV / 1000) % 10; // finds the first digit
        middle = (battV / 100) % 10; // finds the second digit
        right = (battV / 10) % 10; // finds the third digit
        *display = *display | (masks[left] << 17) | (masks[middle] << 10)| (masks[right] << 3);
    }
    // sets the battery meter in display
    if (batt.percent < 5){
        return 0;
    }
    else if (5 <= batt.percent && batt.percent <= 29){ // sets 24th bit
        *display = *display | (1 << 24); 
    }
    else if (batt.percent <= 49){
        *display = *display | (1 << 24) | (1 << 25); // sets 24th and 25th bit
    }
    else if (batt.percent <= 69){
        *display = *display | (1 << 24) | (1 << 25) | (1 << 26); // sets 24-26th bit
    }
    else if (batt.percent <= 89){
        *display = *display | (1 << 24) | (1 << 25) | (1 << 26) | (1 << 27); // sets 24-27th bit
    }
    else if (batt.percent <= 100){
        *display = *display | (1 << 24) | (1 << 25) | (1 << 26) | (1 << 27) | (1 << 28); // sets 24-28th bit
    }
    return 0;
}
int batt_update(){
// Called to update the battery meter display.  Makes use of
// set_batt_from_ports() and set_display_from_batt() to access battery
// voltage sensor then set the display. Checks these functions and if
// they indicate an error, does NOT change the display.  If functions
// succeed, modifies BATT_DISPLAY_PORT to show current battery level.
// 
// CONSTRAINT: Does not allocate any heap memory as malloc() is NOT
// available on the target microcontroller.  Uses stack and global
// memory only.
    batt_t batt = {.mlvolts = -100, .percent = -1, .mode = -1};
    if (set_batt_from_ports(&batt) == 1){
        return 1;
    }
    set_batt_from_ports(&batt);
    set_display_from_batt(batt, &BATT_DISPLAY_PORT);
    return 0;
}