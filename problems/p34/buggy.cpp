#include<bits/stdc++.h>
using namespace std;

int main() {
    int a, b;
    cin >> a >> b;
    vector<int> uoc;
    for (int i=1; i<=int(sqrt(a)); ++i) {
        if (a%i==0) {
            if (b%i==0)
                uoc.push_back(i);
            if (b%(a/i)==0)
                uoc.push_back(a/i);
        }
    }
    sort(uoc.begin(), uoc.end());
    if (uoc.size() < 2) cout << -1 << '\n';
    else cout << uoc[uoc.size() - 2] << '\n';
    return 0;
}
