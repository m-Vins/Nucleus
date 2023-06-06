#include<stdio.h>
#include<stdlib.h>

int the_answer(int number) {
    if (number==42)
        return 42;
    else return -1;
}

void print_err(const char* err) {
    fprintf(stderr, "%s\n", err);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        print_err("I'm panicking! *dies*");
        return 1;
    }
    int answ = the_answer(atoi(argv[1]));
    if (answ == -1)
        print_err("You are wrong, dude!");
    else print_err("CORRECT!");
    return 0;
}