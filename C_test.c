#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>

float calc() {
    float a, b, result;
    char operator;
    printf("Enter A to add, S to subtract, M to multiply, D to divide, or Q to exit: ");
    while ( operator != 'Q') {
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

int test_1()
{
  int a, b;
  scanf("%d %d", &a, &b);
  //returns true if a=b
  if( a == b) {
      printf("True");
  } else {
      printf("False");
  }
    printf("\n %d %d", a, b);
    return 0;
}

int test_2() {
    int array[]={1, 7, 3, 4, 5, 4};
    int max=array[0];
    for(int i=0; i<6; i++) {
        if (array[i]>max) {
            max=array[i];
        } 
    }
    printf("%d", max);
    return 0;
}
 int multiply(int x, int y) {
     return x*y;
 }
 
void test_3() {
    int length=0;
    int upperCount=0;
    int lowerCount=0; 
    int digitCount=0; 
    int specialCount=0;
    //as a string, we have "Happy Birthday." C reads strings as arrays of characters. Thus,
    char string[100];
    //therefore we can use For loops to iterate through them.
    //if we wanted to use any string, fgets(variable to assign, size of array, standard input (keyboard))
    printf("String: ");
    fgets(string,100,stdin);
    for(int t=0;string[t]!='\0';t++){
        //if we wanted to count how long the string is
        length++;
        //uppercase characters
        if(isupper(string[t])) {
            upperCount++;
             //if we wanted to convert uppercase to lowercase, we can use the tolower function.
        //a similar function exists for lowercase, digits, and alphanumeric characters. 
        //(Can you apply this to special characters?)
        }
    }
    printf("\n String is %d characters long and has %d uppercase characters, %d lowercase characters, %d digits, and %d special characters.", length, upperCount, lowerCount, digitCount, specialCount);
}
 
void file_operations() {
    srand(time(0)); // Initialize random number generator
    char filename[100];
    printf("Enter filename: ");
    scanf("%s", filename);
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error opening file.\n");
        return 0;
    }
    char line[256];
    while (fgets(line, sizeof(line), file)) {
        printf("%s", line);
        for(int i=0; line[i]!='\0'; i++) {
            //line[i] = line[i] + rand() % 13 + 1; // Shift character by a random value between 1 and 13
            line[i]= tolower(line[i]);
        }
        printf("%s\n", line);
    }
    //MUST HAVE FCLOSE
    fclose(file);
    printf("File closed successfully.\n");
}
    
int factorial(int n) {
    if (n == 0) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

int main() {
    int c, d;
    //test_1();
    //test_2();
    //scanf("%d %d", &c, &d);
    //printf("\n %d", multiply(c,d));
    //test string = "Ant1m@tter Dimens10n$"
    //test_3();
    //calc();
    //grade_tracker();
    //file_operations();
    scanf("%d", &d);
    printf("%d\n", factorial(d));
    return 0;
    
}

/*  else if (islower(string[t])) {
            lowerCount++;
        } else if (isdigit(string[t])) {
            digitCount++;
        } else if (isalnum(string[t]) != 1 && (string[t]!='\n')) {
            specialCount++;
        }
*/



