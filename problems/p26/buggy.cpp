#include<bits/stdc++.h>
using namespace std;

int main() {
    int n, y;
    cin >> n >> y;

    bool leap = (y % 400 == 0) || (y % 4 == 0 && y % 100 != 0);

    int days[12] = {31, 28, 31, 30, 31, 30,
                    31, 31, 30, 31, 30, 31};



    int month = 0;

    while (n > days[month]) {
        n -= days[month];
        month++;
    }

    cout << n << "/" << month + 1;

    return 0;
}
