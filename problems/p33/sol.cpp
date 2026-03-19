#include<bits/stdc++.h>
using namespace std;

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    cout << (abs(a-b)+2*c-1) / (2*c) << '\n';
    return 0;
}
