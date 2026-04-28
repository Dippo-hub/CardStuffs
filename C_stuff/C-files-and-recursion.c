#include <stdio.h>
#include <ctype.h>
#include <stdlib.h> 


int factorial(int x) {
    if (x == 0) {
        return 1;
    } else {
        return x * factorial(x - 1);
    }
}   

int summation(int x) {
    if (x == 0) {
        return 0;
    } else {
        return x + summation(x - 1);
    }
}

void read_files_and_recurse() {
    char filename[100];
    printf("Enter the filename to read: ");
    scanf("%s", filename);

    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error opening file.\n");
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        switch (line[0]) {
            case 'F':
                printf("Factorial of %d: %d\n", line[1] - '0', factorial(line[1] - '0'));
                break;
            case 'S':
                printf("Summation of number 1 to %d: %d\n", line[1] - '0', summation(line[1] - '0'));
                break;
            default:
                printf("Line: %s", line);
                break;
        }
    }
    fclose(file);
}



int main() {
    read_files_and_recurse();
    return 0;
}