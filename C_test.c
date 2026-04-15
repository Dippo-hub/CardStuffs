#include <stdio.h>
#include <ctype.h>

float calc() {
    float a, b, result;
    char operator;
    printf("Enter A to add, S to subtract, M to multiply, D to divide, or Q to exit: ");
    while ( operator != EOF) {
        scanf(" %c", &operator); // Read operator input
        operator = toupper(operator); // Convert operator to uppercase for uniformity
        if (operator != 'Q') {
            printf("Enter two numbers: ");
            scanf("%f %f", &a, &b);
        }
        switch (operator) {
            case 'A':
                result = a + b;
                printf("Result: %.2f\n", result);
                break;
            case 'S':
                result = a - b;
                printf("Result: %.2f\n", result);
                break;
            case 'M':
                result = a * b;
                printf("Result: %.2f\n", result);
                break;
            case 'D':
                if (b != 0) {
                    result = a / b;
                    printf("Result: %.2f\n", result);
                } else {
                    printf("Error: Division by zero is not allowed.\n");
                }
                break;
            case 'Q':
                // Handle quit case
                printf("Exiting the program.\n");
                return 0;
            default:
                printf("Invalid operator. Please try again.\n");
        }
        printf("Enter A to add, S to subtract, M to multiply, D to divide, or Q to exit: ");
    }
    return 0;
}

void grade_tracker() {
    int count = 0, aCount = 0, bCount = 0, cCount = 0, dCount = 0, fCount = 0;
    float grade, total = 0.0;
    printf("Enter grades (0-100) or -1 to finish: \n");
    while (1) {
        scanf("%f", &grade);
        if (grade == -1) {
            break;
        }
        total += grade;
        count++;
        if (grade >= 90) {
            aCount++;
            printf("Grade: A\n");
        } else if (grade >= 80) {
            bCount++;
            printf("Grade: B\n");
        } else if (grade >= 70) {
            cCount++;
            printf("Grade: C\n");   
        } else if (grade >= 60) {
            dCount++;
            printf("Grade: D\n");
        } else {
            fCount++;
            printf("Grade: F\n");   
        }
    }
    if (count > 0) {
        printf("Average grade: %.2f\n", (float)total / count);
    }
    printf("Grade distribution:\n");
    printf("A: %d, %.2f%% of total.\n", aCount, (float)aCount / count * 100);
    printf("B: %d, %.2f%% of total.\n", bCount, (float)bCount / count * 100);
    printf("C: %d, %.2f%% of total.\n", cCount, (float)cCount / count * 100);
    printf("D: %d, %.2f%% of total.\n", dCount, (float)dCount / count * 100);
    printf("F: %d, %.2f%% of total.\n", fCount, (float)fCount / count * 100);
}
int main() {
    //calc();
    grade_tracker();
    return 0;
}