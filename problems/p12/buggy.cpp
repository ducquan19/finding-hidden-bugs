#include<bits/stdc++.h>
using namespace std;

int main() {
    int n, x;
    cin >> n >> x;

    int* a = new int[n];
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    int cnt = 0;
    for (int i = 0; i < n; ++i) {
        if (a[i] != x) {
            ++cnt;
        }
    }

    cout << cnt << '\n';

    return 0;
}
