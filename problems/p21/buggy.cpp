#include<bits/stdc++.h>
using namespace std;

int main() {
    int a, b;
    cin >> a >> b;

    int res = 0;
    for (int i = 2; i <= min(a, b); ++i) {
        if (a % i == 0 || b % i == 0) {
            res = i;
        }
    }

    cout << res << '\n';
    return 0;
}
