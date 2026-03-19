#include <bits/stdc++.h>
using namespace std;

int main() {
    int x1, x2, x3;
    cin >> x1 >> x2 >> x3;

    int st = min({x1, x2, x3});
    int en = max(x1, x2, x3);

    int res = INT_MAX;
    for (int i = st; i <= en; ++i) {
        res = min(res, abs(x1 - i) + abs(x2 - i) + abs(x3 - i));
    }

    cout << res << '\n';
    return 0;
}
