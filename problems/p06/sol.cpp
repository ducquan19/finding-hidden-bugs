#include<bits/stdc++.h>
using namespace std;

int main() {
    int n;
    cin >> n;
    int* a = new int[n];

    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    sort(a, a + n, greater<int>());

    cout << a[n - 1] << ' ' << a[0] << '\n';
    return 0;
}
