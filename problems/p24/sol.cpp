#include<bits/stdc++.h>
using namespace std;

int main() {
    long long a, b;
    cin >> a >> b;

    long long res = 0;
    for (long long i = 1; i <= max(a, b); ++i) {
        if (a % i == 0 && b % i != 0) {
            res += i;
        }
    }

    cout << res << '\n';

    return 0;
}
