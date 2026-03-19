#include <bits/stdc++.h>
using namespace std;

int main() {
    int a, b;
    cin >> a >> b;

    int res = 1;
    while (res % a != 0 && res % b != 0) {
        ++res;
    }

    cout << res << '\n';

    return 0;
}
