#include<bits/stdc++.h>
using namespace std;

int main() {
    int n;
    cin >> n;
    int* a = new int[n];

    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    for (int i = 0; i < n; ++i) {
        int sqr = sqrt(a[i]);
        if (sqr * sqr == a[i]) {
            cout << "Yes\n";
        }
        else {
            cout << "No\n";
        }
    }

    return 0;
}
