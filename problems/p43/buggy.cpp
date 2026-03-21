#include<bits/stdc++.h>
using namespace std;
#define MAX 50

int main() {
    int t, n, a[MAX], i;
    cin >> t;
    while (t--) {
        cin >> n;
        for (int i = 0; i < n; ++i) cin >> a[i];
        string s;
        cin >> s;
        char m[MAX] = {0};
        bool ok = true;
        for (int i = 0; i < n; ++i) {
            if (m[a[i]] && m[a[i]] != s[i]) ok = false;
            m[a[i]] = s[i];
        }
        cout << (ok ? "YES" : "NO") << '\n';
    }
    return 0;
}
