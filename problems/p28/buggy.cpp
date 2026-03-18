#include<bits/stdc++.h>
using namespace std;

int main() {
    int n;
    cin >> n;

    int* a = new int[n];
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    bool found = false;
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            if (a[i] == a[j]) {
                cout << i << ' ' << j << '\n';
                found = true;
            }
        }
    }

    if (found == false) cout << -1 << '\n';

    return 0;
}
