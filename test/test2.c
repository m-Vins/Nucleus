#include <stdio.h>

// Function to calculate the square of a number
int square(int num) {
    return num * num;
}

// Function to print a welcome message
void printWelcomeMessage() {
    printf("Welcome to the program!\n");
}

// Function to add two numbers
int add(int a, int b) {
    return a + b;
}

// Main function
int main() {
    int x = 5;
    int y = 3;
    int result = add(x, y);
    
    printf("The sum of %d and %d is %d\n", x, y, result);
    
    printWelcomeMessage();
    
    int squared = square(result);
    printf("The square of %d is %d\n", result, squared);
    
    return 0;
}
