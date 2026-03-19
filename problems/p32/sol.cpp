#include<bits/stdc++.h>
using namespace std;

int main() {
    int a, b;
    cin >> a >> b;
    int count = 0;

    for (int i = a; i <= b; ++i) {
        int num = i;
        while (num > 0) {
            if (num % 10 == 5) count++;
            num /= 10;
        }
    }

    cout << count << '\n';

    return 0;
}
