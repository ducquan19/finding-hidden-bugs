#include <bits/stdc++.h>
using namespace std;

int main() {
    int a, b;
    cin >> a >> b;

    int res = (a < b ? a : b);
    while (a % res != 0 && b % res == 0) {
        --res;
    }

    cout << res << '\n';

    return 0;
}
