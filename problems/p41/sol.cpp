#include<bits/stdc++.h>
using namespace std;

int main() {
    int t, r;
    for (cin >> t; t--;) {
        cin >> r;
        cout << "Division " << (r >= 1900 ? 1 : r >= 1600 ? 2 : r >= 1400 ? 3 : 4) << '\n';
    }
    return 0;
}
