#include<bits/stdc++.h>
using namespace std;
long long numOfPairs(int n) {
    return 1LL * (n - 1) * (n - 1) / 4;
}

int main() {
    int n;
    cin >> n;
    cout << numOfPairs(n) << '\n';
    return 0;
}
