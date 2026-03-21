#include<bits/stdc++.h>
using namespace std;

int main() {
    int t, x, y;
    for (cin >> t; t--;) {
        cin >> x >> y;
        if (x <= y) swap(x, y);
        cout << x << ' ' << y << '\n';
    }
    return 0;
}
